local InstallHealth = {}

local LEGACY_BOOTSTRAP_DIRECTORY = "../!MCM_Bootstrap"
local MAX_LISTED_STALE_PATHS = 4

local LEGACY_FILES = {
  "mcm_game_screen.lua",
  "mcm_ui/controller.lua",
  "mcm_ui/input.lua",
  "mcm_ui/layout.lua",
  "mcm_ui/local_settings.lua",
  "mcm_ui/localization.lua",
  "mcm_ui/logger.lua",
  "mcm_ui/menu_integration.lua",
  "mcm_ui/mod_list.lua",
  "mcm_ui/model.lua",
  "mcm_ui/model_collections.lua",
  "mcm_ui/model_presets.lua",
  "mcm_ui/preferences.lua",
  "mcm_ui/redscript_surface.lua",
  "mcm_ui/redscript_surface_input.lua",
  "mcm_ui/redscript_surface_render.lua",
  "mcm_ui/routes.lua",
  "mcm_ui/runtime.lua",
  "mcm_ui/state.lua",
  "mcm_ui/text.lua",
  "mcm_ui/theme.lua",
  "mcm_ui/event_router.lua",
  "mcm_ui/palette.lua",
  "mcm_ui/views/collections.lua",
  "mcm_ui/views/content.lua",
  "mcm_ui/views/mcm_settings.lua",
  "mcm_ui/views/mod_browser.lua",
  "mcm_ui/views/mod_presets.lua",
  "mcm_ui/views/screen.lua",
}

local LEGACY_DIRECTORIES = {
  LEGACY_BOOTSTRAP_DIRECTORY,
  "mcm_game",
  "mcm_ui/components",
}

local function splitPath(path)
  local normalized = tostring(path or ""):gsub("\\", "/")
  local directory, name = normalized:match("^(.*)/([^/]+)$")
  if name == nil then
    return ".", normalized
  end
  if directory == "" then
    directory = "."
  end
  return directory, name
end

local function directoryIndex(listDirectory, path, cache)
  if cache[path] ~= nil then
    return cache[path]
  end

  local index = {}
  local ok, entries = pcall(listDirectory, path)
  if ok and type(entries) == "table" then
    for _, entry in ipairs(entries) do
      if type(entry) == "table" and entry.name ~= nil then
        index[string.lower(tostring(entry.name))] = string.lower(tostring(entry.type or ""))
      end
    end
  end
  cache[path] = index
  return index
end

local function pathExists(path, expectedType, listDirectory, cache)
  local directory, name = splitPath(path)
  local entryType = directoryIndex(listDirectory, directory, cache)[string.lower(name)]
  return entryType == expectedType
end

function InstallHealth.scan(listDirectory)
  listDirectory = listDirectory or dir
  if type(listDirectory) ~= "function" then
    return {}
  end

  local cache = {}
  local stalePaths = {}
  local stalePathCount = 0
  local function recordStalePath(path)
    stalePathCount = stalePathCount + 1
    if #stalePaths < MAX_LISTED_STALE_PATHS then
      stalePaths[#stalePaths + 1] = path
    end
  end
  for _, path in ipairs(LEGACY_FILES) do
    if pathExists(path, "file", listDirectory, cache) then
      recordStalePath(path)
    end
  end

  local legacyBootstrapDetected = false
  for _, path in ipairs(LEGACY_DIRECTORIES) do
    if pathExists(path, "directory", listDirectory, cache) then
      if path == LEGACY_BOOTSTRAP_DIRECTORY then
        legacyBootstrapDetected = true
      else
        recordStalePath(path)
      end
    end
  end

  local notices = {}
  if legacyBootstrapDetected then
    notices[#notices + 1] = {
      id = "legacy_bootstrap",
      messageKey = "install_health.legacy_bootstrap",
    }
  end
  if #stalePaths > 0 then
    notices[#notices + 1] = {
      id = "stale_install",
      messageKey = "install_health.clean_reinstall",
      values = {
        paths = table.concat(stalePaths, ", ") .. (stalePathCount > #stalePaths and ", …" or ""),
      },
    }
  end
  return notices
end

return InstallHealth
