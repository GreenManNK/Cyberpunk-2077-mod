local Catalog = require("modules/catalog")
local Collections = require("modules/collections")
local Defaults = require("modules/defaults")
local Diagnostics = require("modules/diagnostics")
local Drafts = require("modules/drafts")
local DynamicSnapshots = require("modules/dynamic_snapshots")
local Events = require("modules/events")
local Logger = require("modules/logger")
local Operations = require("modules/operations")
local ProviderRegistry = require("modules/provider_registry")
local Presets = require("modules/presets")
local PortableCollections = require("modules/portable_collections")
local Snapshots = require("modules/snapshots")
local Storage = require("modules/storage")
local Transactions = require("modules/transactions")
local Util = require("modules/util")

local Core = {}
local PUBLIC_VERSION = "0.10.2"

local events = Events.new(Logger)
local diagnostics = Diagnostics.new()
local registry = ProviderRegistry.new(events, diagnostics)
local storage = Storage.new()
local presets = Presets.new(storage)
local dynamicSnapshots = DynamicSnapshots.new(storage)
local collections = Collections.new(storage)
local portableCollections = PortableCollections.new(storage, { mcmVersion = PUBLIC_VERSION })
local operations = Operations.new()

local state = {
  initialized = false,
  indexLoaded = false,
  catalog = Catalog.new(),
  drafts = Drafts.new(),
  activeModKey = nil,
  status = "MCM API is loading.",
  refreshingIndex = false,
  refreshingProviders = {},
  loadingModKey = nil,
  providerStates = {},
}

local publicApi
local providerHost

local function now()
  if type(os.clock) == "function" then
    return os.clock()
  end

  return 0
end

local function traceback(message)
  if type(debug) == "table" and type(debug.traceback) == "function" then
    return debug.traceback(tostring(message), 2)
  end
  return tostring(message)
end

local function setStatus(message)
  state.status = tostring(message or "")
  events.emit("status.changed", { status = state.status })
  return state.status
end

local function recordError(message, providerId, details)
  local text = diagnostics.error(message, providerId, details)
  Logger.error(text)
  setStatus(text)
  return text
end

local function providerContext(interaction)
  local context = {
    apiVersion = 2,
    indexLoaded = state.indexLoaded,
    activeModKey = state.activeModKey,
    now = now(),
    log = {
      info = Logger.info,
      warn = Logger.warn,
      error = Logger.error,
    },
  }
  if type(interaction) == "table" then
    context.interaction = interaction
  end
  return context
end

local function shutdownProvider(provider, reason)
  if provider == nil or type(provider.shutdown) ~= "function" then
    return true
  end

  local ok, err = pcall(provider.shutdown, providerContext())
  if ok then
    return true
  end

  local message = string.format(
    "Provider %s shutdown failed during %s: %s",
    tostring(provider.id),
    tostring(reason),
    tostring(err)
  )
  diagnostics.error(message, provider.id)
  Logger.warn(message)
  return false
end

local function firstErrorText(primary, secondary, fallback)
  if primary ~= nil then
    return tostring(primary)
  end

  if secondary ~= nil then
    return tostring(secondary)
  end

  return tostring(fallback)
end

local function normalizeProbe(provider, incoming)
  local status = {}
  if type(incoming) == "table" then
    for key, value in pairs(incoming) do
      status[key] = value
    end
  end

  if type(incoming) == "boolean" then
    status.detected = incoming
    status.ready = incoming
  end

  if status.detected == nil then
    status.detected = true
  end
  if status.ready == nil then
    status.ready = status.detected == true
  end

  if status.state == nil or status.state == "" then
    if status.detected ~= true then
      status.state = "absent"
    elseif status.ready ~= true then
      status.state = "waiting"
    else
      status.state = "ready"
    end
  end

  return {
    id = provider.id,
    detected = status.detected == true,
    ready = status.ready == true,
    state = tostring(status.state),
    revision = status.revision,
    epoch = status.epoch,
    message = status.message,
    stale = status.stale == true,
    error = status.error,
  }
end

local function probeProvider(provider)
  if type(provider.probe) ~= "function" then
    return normalizeProbe(provider, true), nil
  end

  local ok, result, message = pcall(provider.probe, providerContext())
  if not ok then
    return normalizeProbe(provider, {
      detected = true,
      ready = false,
      state = "faulted",
      error = tostring(result),
    }),
      tostring(result)
  end
  if type(result) ~= "table" and type(result) ~= "boolean" then
    local probeError = firstErrorText(message, nil, "Provider probe returned no status.")
    return normalizeProbe(provider, {
      detected = true,
      ready = false,
      state = "faulted",
      error = probeError,
    }),
      probeError
  end

  local status = normalizeProbe(provider, result)
  if message ~= nil and status.message == nil then
    status.message = tostring(message)
  end

  return status, status.error
end

local function providerInfo(provider)
  local current = state.providerStates[provider.id] or {}
  local snapshot = state.catalog.providerSnapshots[provider.id]
  local modCount = 0
  if snapshot ~= nil then
    modCount = snapshot.modCount
  end

  local capabilities = {}
  local sourceCapabilities = {}
  if type(provider.capabilities) == "table" then
    sourceCapabilities = provider.capabilities
  end
  for key, value in pairs(sourceCapabilities) do
    capabilities[key] = value
  end
  return {
    id = provider.id,
    name = tostring(provider.name or provider.id),
    shortName = tostring(provider.shortName or provider.id),
    registered = true,
    available = current.detected,
    detected = current.detected,
    ready = current.ready,
    state = current.state or "registered",
    revision = current.revision,
    epoch = current.epoch,
    message = current.message,
    error = current.error,
    stale = current.stale == true,
    duration = current.duration or 0,
    mods = modCount,
    capabilities = capabilities,
  }
end

local function refreshCounts()
  local available = 0
  for _, provider in ipairs(registry.list()) do
    local providerState = state.providerStates[provider.id]
    if providerState ~= nil and providerState.ready == true then
      available = available + 1
    end
  end
  state.catalog.counts.providers = registry.count()
  state.catalog.counts.availableProviders = available
end

local function modMatchesFilter(mod, filter)
  if filter == nil or filter == "" then
    return true
  end

  if type(filter) == "string" then
    return Util.contains(mod.name, filter)
      or Util.contains(mod.id, filter)
      or Util.contains(mod.key, filter)
      or Util.contains(mod.provider, filter)
  end
  if type(filter) == "table" then
    if
      filter.provider ~= nil
      and filter.provider ~= mod.provider
      and filter.provider ~= mod.bridge
    then
      return false
    end
    if filter.bridge ~= nil and filter.bridge ~= mod.bridge then
      return false
    end
    if filter.search ~= nil and not modMatchesFilter(mod, filter.search) then
      return false
    end
  end
  return true
end

local function providerForMod(mod)
  if mod == nil then
    return nil
  end

  return registry.get(mod.provider)
end

local function loadModSchema(mod, reason)
  if mod == nil then
    return nil, "No mod selected."
  end

  if state.loadingModKey ~= nil then
    return nil, "Another mod is already loading: " .. tostring(state.loadingModKey)
  end

  local provider = providerForMod(mod)
  if provider == nil then
    return nil, "Provider is not registered: " .. tostring(mod.provider)
  end
  local providerState = state.providerStates[provider.id]
  if providerState ~= nil and providerState.ready == false then
    return nil, providerState.message or "Provider is not ready."
  end

  state.loadingModKey = mod.key
  local startedAt = now()
  local ok, schema, message = pcall(provider.loadMod, mod.sourceId, providerContext())
  state.loadingModKey = nil

  if not ok or type(schema) ~= "table" then
    local err = firstErrorText(message, schema, "Provider returned no schema.")
    mod.loadAttempted = true
    mod.loadError = err
    mod.schemaStale = mod.loaded == true
    diagnostics.error(
      "Loading settings failed for " .. tostring(mod.name) .. ": " .. err,
      provider.id
    )
    return nil, err
  end

  local attached, attachError = Catalog.attachSchema(state.catalog, mod, schema)
  if not attached then
    mod.loadAttempted = true
    mod.loadError = attachError
    mod.schemaStale = mod.loaded == true
    diagnostics.error(
      "Invalid schema for " .. tostring(mod.name) .. ": " .. tostring(attachError),
      provider.id
    )
    return nil, attachError
  end

  mod.loadDuration = now() - startedAt
  Drafts.reconcileMod(state.drafts, mod, state.catalog.settingById)
  events.emit("schema.changed", {
    mod = Catalog.publicMod(mod),
    reason = reason or "load",
  })
  return Catalog.publicMod(mod), nil
end

function Core.registerProvider(provider)
  local valid, validationError = registry.validateRegistration(provider)
  if not valid then
    local providerId = nil
    if type(provider) == "table" then
      providerId = provider.id
    end

    return false, recordError(validationError, providerId)
  end

  local previous = registry.get(provider.id)

  if previous ~= nil and previous ~= provider then
    local active = Catalog.findMod(state.catalog, state.activeModKey)
    if active ~= nil and active.provider == provider.id then
      if Drafts.hasForMod(state.drafts, active.key) then
        return false, "Cannot replace an active provider while its mod has pending changes."
      end

      local closed, closeError = Core.closeMod()
      if not closed then
        return false, "Cannot replace an active provider: " .. tostring(closeError)
      end
    end
  end

  local ok, result = registry.register(provider)
  if not ok then
    return false, recordError(result, provider.id)
  end

  if result == "replaced" and previous ~= nil and previous ~= provider then
    shutdownProvider(previous, "replacement")
  end

  Catalog.setProviderOrder(state.catalog, registry.ids())
  Logger.info(string.format("Provider %s: %s", tostring(provider.id), tostring(result)))
  return true, result
end

function Core.unregisterProvider(providerId, registrationKey)
  local valid, validationError = registry.validateUnregistration(providerId, registrationKey)
  if not valid then
    return false, validationError
  end

  local active = Catalog.findMod(state.catalog, state.activeModKey)
  if active ~= nil and active.provider == providerId then
    local closed, closeError = Core.closeMod()
    if not closed then
      return false, closeError
    end
  end

  local provider = registry.get(providerId)
  shutdownProvider(provider, "unregistration")

  local ok, err = registry.unregister(providerId, registrationKey)
  if not ok then
    return false, err
  end

  Catalog.removeProvider(state.catalog, providerId)
  Catalog.setProviderOrder(state.catalog, registry.ids())
  state.providerStates[providerId] = nil
  refreshCounts()
  return true, nil
end

function Core.init()
  state.initialized = true
  setStatus(string.format("Ready. %d provider package(s) registered.", registry.count()))
  return true, nil
end

local function refreshProviderImpl(providerId, options)
  providerId = tostring(providerId or "")
  local provider = registry.get(providerId)
  if provider == nil then
    return nil, "Unknown provider: " .. providerId
  end

  if state.refreshingProviders[providerId] then
    return nil, "Provider refresh is already in progress: " .. providerId
  end

  state.refreshingProviders[providerId] = true
  local startedAt = now()
  local probe, probeError = probeProvider(provider)
  probe.duration = 0
  probe.error = probeError or probe.error

  if not probe.detected or not probe.ready then
    probe.stale = state.catalog.providerSnapshots[providerId] ~= nil
    Catalog.markProviderStale(state.catalog, providerId, probe.stale)
    probe.duration = now() - startedAt
    state.providerStates[providerId] = probe
    state.refreshingProviders[providerId] = nil
    diagnostics.updateProvider(provider, probe)
    events.emit("provider.state", providerInfo(provider))
    refreshCounts()
    return providerInfo(provider), probe.error
  end

  local ok, snapshot, message = pcall(provider.listMods, providerContext())
  if not ok or type(snapshot) ~= "table" or type(snapshot.mods) ~= "table" then
    local err = firstErrorText(message, snapshot, "Provider returned no mod index.")
    probe.state = "faulted"
    probe.ready = false
    probe.error = err
    probe.stale = state.catalog.providerSnapshots[providerId] ~= nil
    probe.duration = now() - startedAt
    Catalog.markProviderStale(state.catalog, providerId, probe.stale)
    state.providerStates[providerId] = probe
    state.refreshingProviders[providerId] = nil
    diagnostics.updateProvider(provider, probe)
    recordError(provider.name .. " index refresh failed: " .. err, providerId)
    events.emit("provider.state", providerInfo(provider))
    refreshCounts()
    return providerInfo(provider), err
  end

  snapshot.revision = snapshot.revision or probe.revision
  snapshot.epoch = snapshot.epoch or probe.epoch
  local replaced, replaceError = Catalog.replaceProviderIndex(state.catalog, provider, snapshot)
  if not replaced then
    probe.state = "faulted"
    probe.ready = false
    probe.error = replaceError
    probe.stale = state.catalog.providerSnapshots[providerId] ~= nil
    probe.duration = now() - startedAt
    state.providerStates[providerId] = probe
    state.refreshingProviders[providerId] = nil
    diagnostics.updateProvider(provider, probe)
    recordError(provider.name .. " index was rejected: " .. tostring(replaceError), providerId)
    refreshCounts()
    return providerInfo(provider), replaceError
  end

  probe.state = "ready"
  probe.ready = true
  probe.stale = false
  if message ~= nil then
    probe.error = tostring(message)
  else
    probe.error = nil
  end
  probe.revision = snapshot.revision
  probe.epoch = snapshot.epoch
  probe.duration = now() - startedAt
  state.providerStates[providerId] = probe
  state.refreshingProviders[providerId] = nil
  Catalog.markProviderStale(state.catalog, providerId, false)
  diagnostics.updateProvider(provider, {
    detected = true,
    ready = true,
    state = "ready",
    stale = false,
    revision = probe.revision,
    epoch = probe.epoch,
    mods = state.catalog.providerSnapshots[providerId].modCount,
    refreshCount = ((diagnostics.ensureProvider(provider) or {}).refreshCount or 0) + 1,
    lastDuration = probe.duration,
    lastRefreshAt = now(),
    lastError = probe.error,
    message = probe.message,
  })

  local active = Catalog.findMod(state.catalog, state.activeModKey)
  if active ~= nil and active.provider == providerId and active.schemaStale == true then
    if Drafts.hasForMod(state.drafts, active.key) then
      active.schemaStale = true
    elseif not (options and options.skipActiveReload) then
      loadModSchema(active, "provider revision")
    end
  end

  refreshCounts()
  events.emit("provider.state", providerInfo(provider))
  events.emit("index.changed", {
    providerId = providerId,
    counts = {
      providers = state.catalog.counts.providers,
      availableProviders = state.catalog.counts.availableProviders,
      mods = state.catalog.counts.mods,
      categories = state.catalog.counts.categories,
      settings = state.catalog.counts.settings,
    },
  })
  return providerInfo(provider), probe.error
end

function Core.refreshProvider(providerId, options)
  local id = tostring(providerId or "")
  local ok, result, err = xpcall(function()
    return refreshProviderImpl(id, options)
  end, traceback)
  if ok then
    return result, err
  end

  state.refreshingProviders[id] = nil
  local provider = registry.get(id)
  if provider ~= nil then
    local previous = state.providerStates[id] or {}
    local failure = {
      detected = previous.detected == true,
      ready = false,
      state = "faulted",
      stale = state.catalog.providerSnapshots[id] ~= nil,
      revision = previous.revision,
      epoch = previous.epoch,
      error = tostring(result),
      message = "Provider refresh failed unexpectedly.",
    }
    state.providerStates[id] = failure
    Catalog.markProviderStale(state.catalog, id, failure.stale)
    diagnostics.updateProvider(provider, failure)
    events.emit("provider.state", providerInfo(provider))
  end
  refreshCounts()
  recordError("Provider refresh crashed: " .. tostring(result), id)
  return nil, tostring(result)
end

local function refreshIndexImpl()
  if state.refreshingIndex then
    return nil, "An index refresh is already in progress."
  end

  state.refreshingIndex = true
  setStatus("Refreshing mod index...")

  local errors = {}
  for _, provider in ipairs(registry.list()) do
    local _, err = Core.refreshProvider(provider.id, { skipActiveReload = false })
    if err ~= nil then
      errors[#errors + 1] = provider.id .. ": " .. tostring(err)
    end
  end

  state.refreshingIndex = false
  state.indexLoaded = true
  refreshCounts()

  if state.activeModKey ~= nil and Catalog.findMod(state.catalog, state.activeModKey) == nil then
    Drafts.clearMod(state.drafts, state.activeModKey)
    state.activeModKey = nil
  end

  setStatus(
    string.format(
      "Indexed %d mods from %d/%d ready providers. Settings load on selected mod open.",
      state.catalog.counts.mods,
      state.catalog.counts.availableProviders,
      state.catalog.counts.providers
    )
  )
  local snapshot = Catalog.snapshot(state.catalog)
  snapshot.providers = Core.listProviders()
  if #errors > 0 then
    return snapshot, table.concat(errors, " | ")
  end

  return snapshot, nil
end

function Core.refreshIndex()
  local ok, result, err = xpcall(refreshIndexImpl, traceback)
  state.refreshingIndex = false
  if ok then
    return result, err
  end

  recordError("Index refresh crashed: " .. tostring(result))
  setStatus("Mod index refresh failed unexpectedly.")
  return nil, tostring(result)
end

function Core.prepareProviders(reason)
  local results = {}
  local errors = {}
  for _, provider in ipairs(registry.list()) do
    if type(provider.prepare) == "function" then
      local ok, result, message =
        pcall(provider.prepare, providerContext(), tostring(reason or "manual"))
      if ok then
        results[#results + 1] = {
          providerId = provider.id,
          result = result,
        }
        if message ~= nil then
          errors[#errors + 1] = provider.id .. ": " .. tostring(message)
        end
      else
        errors[#errors + 1] = provider.id .. ": " .. tostring(result)
      end
    end
  end

  if #errors > 0 then
    return results, table.concat(errors, " | ")
  end
  return results, nil
end

function Core.listProviders()
  local providers = {}
  for _, provider in ipairs(registry.list()) do
    providers[#providers + 1] = providerInfo(provider)
  end
  return providers, nil
end

function Core.listMods(filter)
  if not state.indexLoaded then
    return {}, "Index is not loaded."
  end

  local result = {}
  for _, mod in ipairs(Catalog.listMods(state.catalog)) do
    if modMatchesFilter(mod, filter) then
      result[#result + 1] = mod
    end
  end
  return result, nil
end

function Core.openMod(modKey)
  if not state.indexLoaded then
    return nil, "Index is not loaded."
  end

  local mod = Catalog.findMod(state.catalog, modKey)
  if mod == nil then
    return nil, "Unknown mod: " .. tostring(modKey)
  end

  if state.activeModKey ~= nil and state.activeModKey ~= mod.key then
    local closed, closeError = Core.closeMod()
    if not closed then
      return nil, closeError
    end
  end

  local loaded, loadError = loadModSchema(mod, "open")
  if loaded == nil and not mod.loaded then
    return nil, loadError
  end

  state.activeModKey = mod.key
  if loadError ~= nil then
    setStatus("Opened stale settings for " .. mod.name .. ".")
  else
    setStatus("Opened " .. mod.name .. ".")
  end

  events.emit("mod.opened", { mod = Catalog.publicMod(mod), stale = loadError ~= nil })
  return Catalog.publicMod(mod), loadError
end

function Core.closeMod()
  if state.activeModKey == nil then
    return true, nil
  end

  local modKey = state.activeModKey
  local mod = Catalog.findMod(state.catalog, modKey)

  if mod ~= nil then
    local provider = providerForMod(mod)
    if provider ~= nil and type(provider.closeMod) == "function" then
      local ok, result, message = pcall(provider.closeMod, mod.sourceId, providerContext())
      if not ok or result == false then
        return false, firstErrorText(message, result, "Provider failed to close the mod.")
      end
    end
  end

  Drafts.clearMod(state.drafts, modKey)
  events.emit("drafts.changed", { modKey = modKey, count = 0 })
  state.activeModKey = nil
  if mod ~= nil then
    mod.schemaStale = true
  end

  events.emit("mod.closed", { modKey = modKey })
  return true, nil
end

function Core.listCategories(modKey)
  local mod = Catalog.findMod(state.catalog, modKey)
  if mod == nil then
    return {}, "Unknown mod: " .. tostring(modKey)
  end
  if not mod.loaded then
    return {}, "Mod settings are not loaded. Call openMod first."
  end

  return Catalog.listCategories(state.catalog, mod), nil
end

function Core.listSettings(modKey, categoryKey)
  local mod = Catalog.findMod(state.catalog, modKey)
  if mod == nil then
    return {}, "Unknown mod: " .. tostring(modKey)
  end
  if not mod.loaded then
    return {}, "Mod settings are not loaded. Call openMod first."
  end

  return Catalog.listSettings(state.catalog, mod, categoryKey), nil
end

function Core.getValue(settingId)
  local setting = Catalog.findSetting(state.catalog, settingId)
  if setting == nil then
    return nil, "Unknown setting: " .. tostring(settingId)
  end

  return Drafts.get(state.drafts, setting), nil
end

function Core.hasDefault(settingId)
  local setting = Catalog.findSetting(state.catalog, settingId)
  if setting == nil then
    return false, "Unknown setting: " .. tostring(settingId)
  end

  return Defaults.has(setting), nil
end

function Core.getDefault(settingId)
  local setting = Catalog.findSetting(state.catalog, settingId)
  if setting == nil then
    return nil, "Unknown setting: " .. tostring(settingId)
  end
  if not Defaults.has(setting) then
    return nil, "No reliable default value is available for this setting."
  end

  return setting.defaultValue, nil
end

function Core.isDefault(settingId, value)
  local setting = Catalog.findSetting(state.catalog, settingId)
  if setting == nil then
    return nil, "Unknown setting: " .. tostring(settingId)
  end

  return Defaults.isDefault(state.drafts, setting, value)
end

local function loadedMod(modKey)
  local mod = Catalog.findMod(state.catalog, modKey or state.activeModKey)
  if mod == nil then
    return nil, "No mod selected."
  end
  if not mod.loaded then
    return nil, "Mod settings are not loaded. Call openMod first."
  end
  return mod, nil
end

local function writableMod(modKey)
  local mod, err = loadedMod(modKey)
  if mod == nil then
    return nil, err
  end
  if mod.schemaStale ~= true then
    return mod, nil
  end
  if Drafts.hasForMod(state.drafts, mod.key) then
    return nil,
      "Settings changed outside MCM. Revert pending changes to reload the current schema before editing."
  end

  local _, reloadError = loadModSchema(mod, "pre-edit refresh")
  if reloadError ~= nil then
    return nil, reloadError
  end
  return mod, nil
end

local function writableSetting(settingId)
  local setting = Catalog.findSetting(state.catalog, settingId)
  if setting == nil then
    return nil, "Unknown setting: " .. tostring(settingId)
  end

  local mod, err = writableMod(setting.modKey)
  if mod == nil then
    return nil, err
  end

  setting = Catalog.findSetting(state.catalog, settingId)
  if setting == nil or setting.modKey ~= mod.key then
    return nil,
      "Setting is no longer available after refreshing its schema: " .. tostring(settingId)
  end
  return setting, nil
end

local function loadModForRead(mod, reason)
  if mod.loaded == true then
    return mod, nil
  end

  local _, loadError = loadModSchema(mod, reason)
  if loadError ~= nil and mod.loaded ~= true then
    return nil, loadError
  end
  return mod, loadError
end

function Core.getDefaultDiff(modKey)
  local mod, err = loadedMod(modKey)
  if mod == nil then
    return {}, err
  end

  return Defaults.diff(state.drafts, mod), nil
end

function Core.getDefaultCoverage(modKey)
  local mod, err = loadedMod(modKey)
  if mod == nil then
    return nil, err
  end

  return Defaults.coverage(state.drafts, mod), nil
end

function Core.setDraft(settingId, value)
  local setting, settingError = writableSetting(settingId)
  if setting == nil then
    return false, settingError
  end

  local ok, err = Drafts.set(state.drafts, setting, value)
  if not ok then
    return false, err
  end

  if Drafts.hasForMod(state.drafts, setting.modKey) then
    setStatus("Pending: " .. tostring(setting.label))
  else
    setStatus("Pending changes cleared for " .. tostring(setting.label))
  end

  events.emit("drafts.changed", {
    modKey = setting.modKey,
    count = Drafts.countForMod(state.drafts, setting.modKey),
  })
  return true, nil
end

function Core.setDraftToDefault(settingId)
  local setting, settingError = writableSetting(settingId)
  if setting == nil then
    return false, settingError
  end

  if not Defaults.canReset(setting) then
    return false, "No reliable default value is available for this setting."
  end

  local ok, err = Drafts.set(state.drafts, setting, setting.defaultValue)
  if ok then
    setStatus("Staged default: " .. tostring(setting.label))
    events.emit("drafts.changed", {
      modKey = setting.modKey,
      count = Drafts.countForMod(state.drafts, setting.modKey),
    })
  end
  return ok, err
end

function Core.resetDraft(settingId)
  return Core.setDraftToDefault(settingId)
end

function Core.setModDraftsToDefaults(modKey)
  local mod, err = writableMod(modKey)
  if mod == nil then
    return nil, err
  end

  local result, stageError = Defaults.stageMod(state.drafts, mod)
  if result == nil then
    return nil, stageError
  end

  local draftCount = Drafts.countForMod(state.drafts, mod.key)
  if result.staged > 0 then
    setStatus(
      string.format(
        "Staged %d default value(s) for %s; skipped %d.",
        result.staged,
        mod.name,
        result.skipped + result.failed
      )
    )
  else
    setStatus("No non-default values could be staged for " .. tostring(mod.name) .. ".")
  end
  events.emit("drafts.changed", { modKey = mod.key, count = draftCount })
  events.emit("defaults.staged", {
    mod = Catalog.publicMod(mod),
    result = result,
    count = draftCount,
  })

  if result.failed > 0 then
    return result, string.format("Failed to stage %d default value(s).", result.failed)
  end
  return result, nil
end

function Core.clearDraft(settingId)
  local setting = Catalog.findSetting(state.catalog, settingId)
  if setting == nil then
    return false, "Unknown setting: " .. tostring(settingId)
  end

  local ok, err = Drafts.clearSetting(state.drafts, setting)
  if ok then
    events.emit("drafts.changed", {
      modKey = setting.modKey,
      count = Drafts.countForMod(state.drafts, setting.modKey),
    })
  end
  return ok, err
end

function Core.invokeAction(settingId, interaction)
  local setting = Catalog.findSetting(state.catalog, settingId)
  if setting == nil then
    return false, "Unknown setting: " .. tostring(settingId)
  end

  if setting.type ~= "action" or setting.capabilities.action ~= true then
    return false, "Setting is not an executable action."
  end

  local mod = Catalog.findMod(state.catalog, setting.modKey)
  if mod == nil then
    return false, "Owning mod is unavailable."
  end

  if Drafts.hasForMod(state.drafts, mod.key) then
    return false, "Apply or revert pending changes before running this action."
  end

  local provider = providerForMod(mod)
  if provider == nil or type(provider.invokeAction) ~= "function" then
    return false, "Provider does not support action settings."
  end

  local ok, result, err =
    pcall(provider.invokeAction, mod.sourceId, setting.sourceId, providerContext(interaction))
  if not ok then
    err = tostring(result)
  end

  if not ok or type(result) ~= "table" or result.ok == false then
    local resultError = nil
    if type(result) == "table" then
      resultError = result.error
    elseif result ~= nil and ok then
      resultError = "Provider returned an invalid action result: " .. tostring(result)
    end

    local message = firstErrorText(err, resultError, "Action failed.")
    recordError("Failed to run action for " .. mod.name .. ": " .. message, mod.provider, result)
    return false, message
  end

  if result.schemaChanged == true then
    local _, reloadError = loadModSchema(mod, "action schema change")
    if reloadError ~= nil then
      return false,
        "Action completed, but the updated settings could not be loaded: " .. reloadError
    end
  end

  setStatus("Completed: " .. tostring(setting.label))
  events.emit("action.completed", {
    mod = Catalog.publicMod(mod),
    settingId = setting.id,
    result = result,
  })
  return true, nil, result
end

function Core.mountCustom(settingId, host)
  local setting = Catalog.findSetting(state.catalog, settingId)
  if setting == nil then
    return false, "Unknown setting: " .. tostring(settingId)
  end

  if setting.type ~= "custom" or setting.capabilities.customRender ~= true then
    return false, "Setting is not renderable custom content."
  end

  local mod = Catalog.findMod(state.catalog, setting.modKey)
  if mod == nil then
    return false, "Owning mod is unavailable."
  end

  local provider = providerForMod(mod)
  if provider == nil or type(provider.mountCustom) ~= "function" then
    return false, "Provider does not support custom content rendering."
  end

  local ok, result, err =
    pcall(provider.mountCustom, mod.sourceId, setting.sourceId, host, providerContext())
  if not ok then
    err = tostring(result)
  end
  if not ok or type(result) ~= "table" or result.ok == false then
    local resultError = type(result) == "table" and result.error or nil
    local message = firstErrorText(err, resultError, "Custom content rendering failed.")
    recordError("Failed to render custom content for " .. mod.name .. ": " .. message, mod.provider)
    return false, message
  end

  return true, nil
end

function Core.hasDrafts(modKey)
  local key = modKey
  if type(key) == "table" then
    key = key.key
  end
  if key == nil then
    key = state.activeModKey
  end
  if key == nil then
    key = state.drafts.dirtyModKey
  end
  if key == nil then
    return false, nil
  end

  return Drafts.hasForMod(state.drafts, key), nil
end

function Core.apply(modKey)
  local mod = Catalog.findMod(state.catalog, modKey or state.activeModKey)
  if mod == nil then
    return false, "No mod selected."
  end

  Logger.info(
    string.format("Apply requested for %s through %s", tostring(mod.name), tostring(mod.provider))
  )

  if not mod.loaded then
    local _, loadError = loadModSchema(mod, "apply")
    if loadError ~= nil then
      return false, loadError
    end
  end

  local changes, valuesBySettingId = Drafts.changesForMod(state.drafts, mod)
  if #changes == 0 then
    setStatus("No pending changes.")
    Logger.info("Apply skipped for " .. tostring(mod.name) .. ": no pending changes")
    return true, nil
  end
  if mod.schemaStale == true then
    Logger.warn("Apply blocked for " .. tostring(mod.name) .. ": the selected mod schema is stale")
    return false,
      "Settings changed outside MCM. Revert pending changes to reload the current schema before applying."
  end

  local provider = providerForMod(mod)
  if provider == nil then
    return false, "Provider is not registered: " .. tostring(mod.provider)
  end

  local currentProviderState = state.providerStates[provider.id]
  if currentProviderState ~= nil and currentProviderState.ready == false then
    return false, currentProviderState.message or "Provider is not ready to apply changes."
  end

  local dynamicBefore = nil
  if (mod.capabilities or {}).dynamicSchema == true then
    dynamicBefore = Snapshots.capture(mod, {
      get = function(setting)
        return setting.value
      end,
    }, { captureMode = "observation" })
  end

  local result, err = Transactions.apply(provider, mod.sourceId, changes, providerContext())
  if err ~= nil then
    Logger.warn(
      string.format(
        "Apply failed for %s through %s: %s",
        tostring(mod.name),
        tostring(mod.provider),
        tostring(err)
      )
    )
    recordError("Failed to apply settings for " .. mod.name .. ": " .. err, mod.provider, result)
    if result ~= nil and result.partial == true then
      mod.schemaStale = true
      setStatus(
        "The provider reported a partial transaction. Pending values were preserved for review."
      )
      events.emit("apply.partial", {
        mod = Catalog.publicMod(mod),
        result = result,
        count = #changes,
      })
    end
    return false, err
  end

  local _, reloadError = loadModSchema(mod, "post-apply verification")
  if reloadError ~= nil then
    Catalog.updateValues(state.catalog, mod, valuesBySettingId)
    Drafts.clearMod(state.drafts, mod.key)
    mod.schemaStale = true
    Logger.warn(
      string.format(
        "Apply succeeded for %s, but schema verification failed: %s",
        tostring(mod.name),
        tostring(reloadError)
      )
    )
  else
    if dynamicBefore ~= nil then
      local dynamicAfter = Snapshots.capture(mod, {
        get = function(setting)
          return setting.value
        end,
      }, { captureMode = "observation" })
      local changedSettingIds = {}
      for settingId in pairs(valuesBySettingId) do
        changedSettingIds[settingId] = true
      end
      local observed, learned, observationError = pcall(
        dynamicSnapshots.observeTransition,
        dynamicSnapshots,
        dynamicBefore,
        dynamicAfter,
        changedSettingIds
      )
      if not observed then
        Logger.warn(
          "Dynamic schema transition could not be observed for "
            .. tostring(mod.name)
            .. ": "
            .. tostring(learned)
        )
      elseif observationError ~= nil then
        Logger.warn(
          "Dynamic schema transition could not be cached for "
            .. tostring(mod.name)
            .. ": "
            .. tostring(observationError)
        )
      end
    end

    local remainingDrafts = Drafts.countForMod(state.drafts, mod.key)
    if remainingDrafts > 0 then
      local verificationError = string.format(
        "The provider accepted the transaction, but %d setting(s) did not keep the requested value.",
        remainingDrafts
      )
      setStatus(verificationError)
      Logger.warn(
        string.format(
          "Apply verification failed for %s through %s: %d draft(s) remain",
          tostring(mod.name),
          tostring(mod.provider),
          remainingDrafts
        )
      )
      events.emit("apply.verification_failed", {
        mod = Catalog.publicMod(mod),
        result = result,
        count = #changes,
        remaining = remainingDrafts,
      })
      events.emit("drafts.changed", { modKey = mod.key, count = remainingDrafts })
      return false, verificationError
    end
  end

  setStatus(string.format("Applied %d change(s) for %s.", #changes, mod.name))
  Logger.info(
    string.format(
      "Applied %d change(s) for %s through %s",
      #changes,
      tostring(mod.name),
      tostring(mod.provider)
    )
  )
  events.emit("apply.completed", {
    mod = Catalog.publicMod(mod),
    result = result,
    count = #changes,
  })
  events.emit("drafts.changed", { modKey = mod.key, count = 0 })

  return true, nil
end

function Core.revert(modKey)
  local mod = Catalog.findMod(state.catalog, modKey or state.activeModKey)
  local key = modKey
  if mod ~= nil then
    key = mod.key
  elseif key == nil then
    key = state.activeModKey
  end
  if key == nil then
    return true, nil
  end

  Drafts.clearMod(state.drafts, key)
  setStatus("Reverted pending changes.")
  events.emit("drafts.changed", { modKey = key, count = 0 })
  if mod ~= nil and mod.schemaStale == true then
    local _, reloadError = loadModSchema(mod, "revert stale schema")
    if reloadError ~= nil then
      return false,
        "Pending changes were reverted, but the current schema could not be loaded: " .. reloadError
    end
  end
  return true, nil
end

local workflowContext = {
  Catalog = Catalog,
  Defaults = Defaults,
  Drafts = Drafts,
  Logger = Logger,
  Snapshots = Snapshots,
  Storage = Storage,
  state = state,
  events = events,
  presets = presets,
  collections = collections,
  portableCollections = portableCollections,
  operations = operations,
  setStatus = setStatus,
  recordError = recordError,
  loadedMod = loadedMod,
  loadModForRead = loadModForRead,
  dynamicSnapshots = dynamicSnapshots,
  logWarning = Logger.warn,
}

local presetWorkflow = require("modules/workflows/presets").attach(Core, workflowContext)
require("modules/workflows/collections").attach(Core, workflowContext, presetWorkflow)

function Core.reloadMod(modKey)
  local mod = Catalog.findMod(state.catalog, modKey or state.activeModKey)
  if mod == nil then
    return nil, "No mod selected."
  end

  if Drafts.hasForMod(state.drafts, mod.key) then
    return nil, "Apply or revert pending changes before reloading this mod."
  end
  return loadModSchema(mod, "manual reload")
end

function Core.getStatus()
  return state.status, nil
end

function Core.getDiagnostics()
  local snapshot = diagnostics.snapshot()
  snapshot.status = state.status
  snapshot.indexLoaded = state.indexLoaded
  snapshot.activeModKey = state.activeModKey
  snapshot.dirtyModKey = state.drafts.dirtyModKey
  snapshot.counts = {
    providers = state.catalog.counts.providers,
    availableProviders = state.catalog.counts.availableProviders,
    mods = state.catalog.counts.mods,
    categories = state.catalog.counts.categories,
    settings = state.catalog.counts.settings,
  }
  return snapshot, nil
end

function Core.update(deltaTime)
  if not state.initialized then
    return
  end

  local operation = operations:update()
  if operation ~= nil then
    if operation.state == "failed" then
      recordError(
        "Operation failed: " .. tostring(operation.error or operation.message),
        nil,
        { operationId = operation.id, kind = operation.kind }
      )
    elseif operation.state == "completed" then
      setStatus(operation.message)
      events.emit("collections.changed", {
        collectionId = operation.result and operation.result.collectionId,
        action = operation.kind,
      })
    else
      setStatus(operation.message)
    end
    events.emit("operation.changed", { operation = operation })
  end
end

function Core.shutdown()
  local closed, closeError = Core.closeMod()
  if not closed then
    Logger.warn("Active mod close failed during shutdown: " .. tostring(closeError))
  end

  for _, provider in ipairs(registry.list()) do
    shutdownProvider(provider, "core shutdown")
  end
  events.clear()
  state.initialized = false
end

function Core.getProviderHost()
  if providerHost ~= nil then
    return providerHost
  end

  providerHost = {
    apiVersion = 2,
    registerProvider = function(first, second)
      return Core.registerProvider(second or first)
    end,
    unregisterProvider = function(first, second, third)
      if first == providerHost then
        return Core.unregisterProvider(second, third)
      end
      return Core.unregisterProvider(first, second)
    end,
    getProvider = function(first, second)
      local providerId = first
      if first == providerHost then
        providerId = second
      end

      return registry.get(providerId)
    end,
    listProviderIds = function()
      return registry.ids()
    end,
  }
  return providerHost
end

function Core.getApi()
  if publicApi ~= nil then
    return publicApi
  end

  local function bind(fn)
    return function(first, ...)
      if first == publicApi then
        return fn(...)
      end
      return fn(first, ...)
    end
  end

  publicApi = {
    version = PUBLIC_VERSION,
    apiVersion = 2,
    providers = Core.getProviderHost(),
    prepareProviders = bind(Core.prepareProviders),
    refreshIndex = bind(Core.refreshIndex),
    refreshProvider = bind(Core.refreshProvider),
    listProviders = bind(Core.listProviders),
    listMods = bind(Core.listMods),
    openMod = bind(Core.openMod),
    closeMod = bind(Core.closeMod),
    listCategories = bind(Core.listCategories),
    listSettings = bind(Core.listSettings),
    getValue = bind(Core.getValue),
    hasDefault = bind(Core.hasDefault),
    getDefault = bind(Core.getDefault),
    isDefault = bind(Core.isDefault),
    getDefaultDiff = bind(Core.getDefaultDiff),
    getDefaultCoverage = bind(Core.getDefaultCoverage),
    listModPresets = bind(Core.listModPresets),
    getModPreset = bind(Core.getModPreset),
    createModPreset = bind(Core.createModPreset),
    updateModPreset = bind(Core.updateModPreset),
    duplicateModPreset = bind(Core.duplicateModPreset),
    getPresetReferences = bind(Core.getPresetReferences),
    deleteModPreset = bind(Core.deleteModPreset),
    previewModPreset = bind(Core.previewModPreset),
    stageModPreset = bind(Core.stageModPreset),
    applyModPreset = bind(Core.applyModPreset),
    listCollections = bind(Core.listCollections),
    getCollection = bind(Core.getCollection),
    createCollection = bind(Core.createCollection),
    updateCollection = bind(Core.updateCollection),
    deleteCollection = bind(Core.deleteCollection),
    putCollectionEntry = bind(Core.putCollectionEntry),
    removeCollectionEntry = bind(Core.removeCollectionEntry),
    previewCollectionEntry = bind(Core.previewCollectionEntry),
    captureCurrentSetup = bind(Core.captureCurrentSetup),
    updateCollectionFromCurrent = bind(Core.updateCollectionFromCurrent),
    listMissingCollectionEntries = bind(Core.listMissingCollectionEntries),
    cleanMissingCollectionEntries = bind(Core.cleanMissingCollectionEntries),
    inspectCollectionCleanup = bind(Core.inspectCollectionCleanup),
    cleanCollectionUnavailableContent = bind(Core.cleanCollectionUnavailableContent),
    getPortableCollectionDirectory = bind(Core.getPortableCollectionDirectory),
    listPortableCollections = bind(Core.listPortableCollections),
    inspectPortableCollection = bind(Core.inspectPortableCollection),
    exportCollection = bind(Core.exportCollection),
    importPortableCollection = bind(Core.importPortableCollection),
    deletePortableCollection = bind(Core.deletePortableCollection),
    applyCollection = bind(Core.applyCollection),
    applyCompatibleCollection = bind(Core.applyCompatibleCollection),
    rollbackCollection = bind(Core.rollbackCollection),
    getOperation = bind(Core.getOperation),
    cancelOperation = bind(Core.cancelOperation),
    setDraft = bind(Core.setDraft),
    setDraftToDefault = bind(Core.setDraftToDefault),
    setModDraftsToDefaults = bind(Core.setModDraftsToDefaults),
    resetDraft = bind(Core.resetDraft),
    clearDraft = bind(Core.clearDraft),
    invokeAction = bind(Core.invokeAction),
    mountCustom = bind(Core.mountCustom),
    hasDrafts = bind(Core.hasDrafts),
    apply = bind(Core.apply),
    reloadMod = bind(Core.reloadMod),
    revert = bind(Core.revert),
    getStatus = bind(Core.getStatus),
    getDiagnostics = bind(Core.getDiagnostics),
    subscribe = bind(events.subscribe),
    unsubscribe = bind(events.unsubscribe),
  }
  return publicApi
end

return Core
