if type(package) == "table" and type(package.loaded) == "table" then
  package.loaded["modules/catalog"] = nil
  package.loaded["modules/collections"] = nil
  package.loaded["modules/core"] = nil
  package.loaded["modules/defaults"] = nil
  package.loaded["modules/diagnostics"] = nil
  package.loaded["modules/drafts"] = nil
  package.loaded["modules/dynamic_snapshots"] = nil
  package.loaded["modules/events"] = nil
  package.loaded["modules/logger"] = nil
  package.loaded["modules/operations"] = nil
  package.loaded["modules/portable_collections"] = nil
  package.loaded["modules/provider_registry"] = nil
  package.loaded["modules/presets"] = nil
  package.loaded["modules/snapshots"] = nil
  package.loaded["modules/storage"] = nil
  package.loaded["modules/transactions"] = nil
  package.loaded["modules/util"] = nil
  package.loaded["modules/values"] = nil
  package.loaded["modules/workflows/collections"] = nil
  package.loaded["modules/workflows/presets"] = nil
  package.loaded["bridges/loader"] = nil
end

local Logger = require("modules/logger")
local Core = require("modules/core")
local BridgeLoader = require("bridges/loader")

local PublicApi = Core.getApi()
local loadedBridges = BridgeLoader.load(Core, Logger)

Logger.info(string.format("MCM API v2 loaded with %d bridge package(s)", #loadedBridges))

registerForEvent("onInit", function()
  Core.init()
  Logger.info("MCM API v2 initialized")
end)

registerForEvent("onUpdate", function(deltaTime)
  Core.update(deltaTime)
end)

registerForEvent("onShutdown", function()
  Core.shutdown()
end)

return PublicApi
