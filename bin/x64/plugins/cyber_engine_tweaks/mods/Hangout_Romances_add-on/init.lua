mod = {}
local isMale = true -- Track current state

print("[Hangout Addon] Mod loaded.")

registerForEvent("onInit", function()
    print("[Hangout Addon] Initialized.")
end)

-- Single keybind to toggle anim type
registerHotkey("toggleAnimType", "Toggle Joytoy Anim: Top/Bottom", function()
    local animType = isMale and 1 or 2
    local animLabel = isMale and "Top (1)" or "Bottom (2)"

    Game.GetQuestsSystem():SetFactStr("a3_hangout_romances_anim_type", animType)
    print("[Hangout Addon] Animation type set to " .. animLabel)

    isMale = not isMale -- Flip state
end)
