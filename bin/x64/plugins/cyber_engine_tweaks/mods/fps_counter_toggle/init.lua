fps_counter_toggle = {
	rootPath = "fps_counter_toggle",
	showUI = false
}

local f = string.format

function fps_counter_toggle:new()

  local cet_is_enabled = false;

  setmetatable(fps_counter_toggle, self)

   registerHotkey("toggle_fps_counter", "Toggle FPS counter", function()
    cet_is_enabled = not cet_is_enabled
    Game.GetUISystem():QueueEvent(FpsCounter_FPSCounterChangeStateEvent.new({ enabled = cet_is_enabled }))
   end)


	return fps_counter_toggle
end


return fps_counter_toggle:new()

