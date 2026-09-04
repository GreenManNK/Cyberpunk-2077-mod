local Loader = {}

local function discover()
  if type(dir) ~= "function" then
    return {}, "CET directory enumeration is unavailable."
  end

  local ok, entries = pcall(dir, "bridges")
  if not ok then
    return {}, tostring(entries)
  end
  if type(entries) ~= "table" then
    return {}, "CET returned an invalid bridge directory listing."
  end

  local names = {}
  for _, entry in ipairs(entries) do
    local name = ""
    if type(entry) == "table" and entry.name ~= nil then
      name = tostring(entry.name)
    end

    if name ~= "" and not name:match("^[_%.]") and not name:find(".", 1, true) then
      names[#names + 1] = name
    end
  end
  table.sort(names)
  return names, nil
end

function Loader.load(core, logger)
  local loaded = {}
  local bridgeNames, discoveryError = discover()
  if discoveryError ~= nil then
    logger.error("Bridge discovery failed: " .. tostring(discoveryError))
  end

  for _, name in ipairs(bridgeNames) do
    local moduleName = "bridges/" .. name .. "/init"
    if type(package) == "table" and type(package.loaded) == "table" then
      package.loaded[moduleName] = nil
      package.loaded["bridges/" .. name .. "/provider"] = nil
    end

    local ok, provider = pcall(require, moduleName)
    if not ok then
      logger.error(
        string.format("Bridge package '%s' failed to load: %s", name, tostring(provider))
      )
    elseif type(provider) ~= "table" then
      logger.warn(string.format("Bridge package '%s' returned no provider descriptor.", name))
    else
      local registered, message = core.registerProvider(provider)
      if registered then
        loaded[#loaded + 1] = provider.id
      else
        logger.error(string.format("Bridge package '%s' was rejected: %s", name, tostring(message)))
      end
    end
  end
  return loaded
end

return Loader
