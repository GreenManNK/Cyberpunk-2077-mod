local Text = require("mcm_ui/mcm_text")

local Input = {}

function Input.keyInputTag(value, isHold)
  local text = Text.safe(value)
  local action = "None"
  if isHold == true then
    action = "hold_input"
  end
  local ok, tag = pcall(function()
    return SettingsSelectorControllerKeyBinding.PrepareInputTag(text, "None", action)
  end)
  if ok then
    return Text.safe(tag)
  end

  return text
end

return Input
