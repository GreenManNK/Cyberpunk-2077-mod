local Controller = require("mcm_ui/mcm_controller")
local Model = require("mcm_ui/mcm_model")
local RedscriptSurface = require("mcm_ui/mcm_native_surface")
local Runtime = require("mcm_ui/mcm_runtime")

local runtime = Runtime.new()
runtime.model = Model.new(runtime)
runtime.screenView = RedscriptSurface.new(runtime)

return Controller.new(runtime):facade()
