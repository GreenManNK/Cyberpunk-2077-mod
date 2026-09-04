local ProviderRegistry = {}

local REQUIRED_API_VERSION = 2

local function validate(provider)
  if type(provider) ~= "table" then
    return false, "Provider descriptor must be a table."
  end
  if type(provider.id) ~= "string" or provider.id == "" then
    return false, "Provider ID must be a non-empty string."
  end
  if type(provider.registrationKey) ~= "string" or provider.registrationKey == "" then
    return false, "Provider registrationKey must be a non-empty string."
  end
  if tonumber(provider.apiVersion) ~= REQUIRED_API_VERSION then
    return false,
      string.format("Provider '%s' requires API version %d.", provider.id, REQUIRED_API_VERSION)
  end
  if type(provider.listMods) ~= "function" then
    return false, string.format("Provider '%s' does not implement listMods.", provider.id)
  end
  if type(provider.loadMod) ~= "function" then
    return false, string.format("Provider '%s' does not implement loadMod.", provider.id)
  end
  return true, nil
end

function ProviderRegistry.new(events, diagnostics)
  local entries = {}
  local order = {}
  local nextOrder = 1

  local registry = {}

  function registry.validateRegistration(provider)
    local valid, err = validate(provider)
    if not valid then
      return false, err
    end

    local existing = entries[provider.id]
    if existing ~= nil and existing.registrationKey ~= provider.registrationKey then
      return false,
        string.format(
          "Provider ID '%s' is already owned by registration key '%s'.",
          provider.id,
          tostring(existing.registrationKey)
        )
    end

    return true, nil
  end

  function registry.register(provider)
    local valid, err = registry.validateRegistration(provider)
    if not valid then
      return false, err
    end

    local existing = entries[provider.id]
    if existing ~= nil and existing.provider == provider then
      return true, "unchanged"
    end

    local replaced = existing ~= nil
    local ordinal = nextOrder
    if replaced then
      ordinal = existing.ordinal
    end

    if not replaced then
      nextOrder = nextOrder + 1
      order[#order + 1] = provider.id
    end

    entries[provider.id] = {
      id = provider.id,
      registrationKey = provider.registrationKey,
      ordinal = ordinal,
      provider = provider,
    }
    diagnostics.ensureProvider(provider)
    local eventName = "provider.registered"
    local result = "registered"
    if replaced then
      eventName = "provider.replaced"
      result = "replaced"
    end

    events.emit(eventName, {
      providerId = provider.id,
    })
    return true, result
  end

  function registry.validateUnregistration(providerId, registrationKey)
    providerId = tostring(providerId or "")
    local existing = entries[providerId]
    if existing == nil then
      return false, "Provider is not registered: " .. providerId
    end
    if registrationKey ~= nil and registrationKey ~= existing.registrationKey then
      return false, "Provider registration key does not match."
    end

    return true, nil
  end

  function registry.unregister(providerId, registrationKey)
    providerId = tostring(providerId or "")
    local valid, err = registry.validateUnregistration(providerId, registrationKey)
    if not valid then
      return false, err
    end

    entries[providerId] = nil
    for index, id in ipairs(order) do
      if id == providerId then
        table.remove(order, index)
        break
      end
    end
    diagnostics.unregisterProvider(providerId)
    events.emit("provider.unregistered", { providerId = providerId })
    return true, nil
  end

  function registry.get(providerId)
    local entry = entries[tostring(providerId or "")]
    if entry == nil then
      return nil
    end

    return entry.provider
  end

  function registry.getEntry(providerId)
    return entries[tostring(providerId or "")]
  end

  function registry.list()
    local result = {}
    for _, id in ipairs(order) do
      local entry = entries[id]
      if entry ~= nil then
        result[#result + 1] = entry.provider
      end
    end
    return result
  end

  function registry.ids()
    local result = {}
    for _, id in ipairs(order) do
      if entries[id] ~= nil then
        result[#result + 1] = id
      end
    end
    return result
  end

  function registry.count()
    return #registry.ids()
  end

  return registry
end

return ProviderRegistry
