-- V2
local M = {}

local SIDE_LABELS = {
  [0] = "Back Left",
  [1] = "Back Right",
  [2] = "Front Left",
  [3] = "Front Right",
}

local FUEL_STYLE_LABELS = {
  [0] = "Arc Gauge",
  [1] = "Progress Bar",
  [2] = "Digits Only",
  [3] = "Classic Needle Gauge",
  [4] = "Vertical Segment Gauge",
  [5] = "Pump Icon Only",
}

local THEME_LABELS = {
  [0] = "Default",
  [1] = "Cyberpunk Yellow",
  [2] = "E3 Red",
  [3] = "Mox Pink",
  [4] = "Blue",
  [5] = "Light Blue",
  [6] = "Neon Green",
  [7] = "Silver",
  [8] = "Gold",
  [9] = "Pure Yellow",
}

local THEME_ORDER = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }

local FONT_OPTIONS = {
  [0]  = "Digital Readout",
  [1]  = "Raj",
  [2]  = "Raj RU",
  [3]  = "Industry",
  [4]  = "Arial",
  [5]  = "Blender",
  [6]  = "Orbitron",
  [7]  = "Nawar Arabic",
  [8]  = "Jing Xi Traditional Chinese",
  [9]  = "Mgenplus JP",
  [10] = "Nanum KOR",
  [11] = "Arame",
  [12] = "Smart Font JP",
  [13] = "Printable4U Thai",
}

local FONT_ORDER = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13 }

local ORDER = {
  "side",
  "out_cm",
  "y_cm",
  "z_cm",
  "roll_deg",
  "pitch_deg",
  "yaw_deg",
  "scale_milli",
}

local GROUPS = {
  fuel = {
    title = "Fuel Gauge",
    fields = {
      side        = { fact = "vm_3d_fuel_side",        label = "Side",              min = 0,    max = 3,    default = 0 },
      out_cm      = { fact = "vm_3d_fuel_out_cm",      label = "Out / Depth cm",    min = -300, max = 300,  default = 0 },
      y_cm        = { fact = "vm_3d_fuel_y_cm",        label = "Forward / Back cm", min = -300, max = 300,  default = 0 },
      z_cm        = { fact = "vm_3d_fuel_z_cm",        label = "Height cm",         min = -200, max = 300,  default = 0 },
      roll_deg    = { fact = "vm_3d_fuel_roll_deg",    label = "Roll deg",          min = -180, max = 180,  default = 0 },
      pitch_deg   = { fact = "vm_3d_fuel_pitch_deg",   label = "Pitch deg",         min = -180, max = 180,  default = 0 },
      yaw_deg     = { fact = "vm_3d_fuel_yaw_deg",     label = "Yaw deg",           min = -180, max = 180,  default = 0 },
      scale_milli = { fact = "vm_3d_fuel_scale_milli", label = "Scale milli",       min = 10,  max = 2000, default = 600 },
    },
  },

  odo = {
    title = "ODO Plate",
    fields = {
      side        = { fact = "vm_3d_odo_side",        label = "Side",              min = 0,    max = 3,    default = 0 },
      out_cm      = { fact = "vm_3d_odo_out_cm",      label = "Out / Depth cm",    min = -300, max = 300,  default = 0 },
      y_cm        = { fact = "vm_3d_odo_y_cm",        label = "Forward / Back cm", min = -300, max = 300,  default = 0 },
      z_cm        = { fact = "vm_3d_odo_z_cm",        label = "Height cm",         min = -200, max = 300,  default = 0 },
      roll_deg    = { fact = "vm_3d_odo_roll_deg",    label = "Roll deg",          min = -180, max = 180,  default = 0 },
      pitch_deg   = { fact = "vm_3d_odo_pitch_deg",   label = "Pitch deg",         min = -180, max = 180,  default = 0 },
      yaw_deg     = { fact = "vm_3d_odo_yaw_deg",     label = "Yaw deg",           min = -180, max = 180,  default = 0 },
      scale_milli = { fact = "vm_3d_odo_scale_milli", label = "Scale milli",       min = 10,  max = 2000, default = 600 },
    },
  },
	
	fuel_alt = {
    title = "Fuel Gauge Alt",
    fields = {
      side        = { fact = "vm_3d_fuel_alt_side",        label = "Side",              min = 0,    max = 3,    default = 1 },
      out_cm      = { fact = "vm_3d_fuel_alt_out_cm",      label = "Out / Depth cm",    min = -300, max = 300,  default = 0 },
      y_cm        = { fact = "vm_3d_fuel_alt_y_cm",        label = "Forward / Back cm", min = -300, max = 300,  default = 0 },
      z_cm        = { fact = "vm_3d_fuel_alt_z_cm",        label = "Height cm",         min = -200, max = 300,  default = 0 },
      roll_deg    = { fact = "vm_3d_fuel_alt_roll_deg",    label = "Roll deg",          min = -180, max = 180,  default = 0 },
      pitch_deg   = { fact = "vm_3d_fuel_alt_pitch_deg",   label = "Pitch deg",         min = -180, max = 180,  default = 0 },
      yaw_deg     = { fact = "vm_3d_fuel_alt_yaw_deg",     label = "Yaw deg",           min = -180, max = 180,  default = 0 },
      scale_milli = { fact = "vm_3d_fuel_alt_scale_milli", label = "Scale milli",       min = 10,  max = 2000, default = 600 },
    },
  },

  odo_alt = {
    title = "ODO Plate Alt",
    fields = {
      side        = { fact = "vm_3d_odo_alt_side",        label = "Side",              min = 0,    max = 3,    default = 1 },
      out_cm      = { fact = "vm_3d_odo_alt_out_cm",      label = "Out / Depth cm",    min = -300, max = 300,  default = 0 },
      y_cm        = { fact = "vm_3d_odo_alt_y_cm",        label = "Forward / Back cm", min = -300, max = 300,  default = 0 },
      z_cm        = { fact = "vm_3d_odo_alt_z_cm",        label = "Height cm",         min = -200, max = 300,  default = 0 },
      roll_deg    = { fact = "vm_3d_odo_alt_roll_deg",    label = "Roll deg",          min = -180, max = 180,  default = 0 },
      pitch_deg   = { fact = "vm_3d_odo_alt_pitch_deg",   label = "Pitch deg",         min = -180, max = 180,  default = 0 },
      yaw_deg     = { fact = "vm_3d_odo_alt_yaw_deg",     label = "Yaw deg",           min = -180, max = 180,  default = 0 },
      scale_milli = { fact = "vm_3d_odo_alt_scale_milli", label = "Scale milli",       min = 10,  max = 2000, default = 600 },
    },
  },
}

local state = {
  fuel = {},
  odo = {},
  fuel_alt = {},
  odo_alt = {},
  fuel_style = 0,
  fuel_alt_style = 0,
  theme = 0,
  font_index = 0,
  font_scale_milli = 1000,
	emissive_ev_deci = 60,
  hide_fuel = false,
  hide_odo = false,
  hide_odo_frame = false,
  hide_fuel_alt = false,
  hide_odo_alt = false,
  hide_odo_alt_frame = false,
}

local loaded = false
local loadedVehicleId = nil

local presetNames = {}
local selectedPreset = nil
local presetsLoaded = false
local presetStatus = ""

local function toInt(v)
  v = tonumber(v) or 0

  if v >= 0 then
    return math.floor(v + 0.5)
  end

  return math.ceil(v - 0.5)
end

local function clamp(v, minV, maxV)
  v = toInt(v)

  if v < minV then return minV end
  if v > maxV then return maxV end

  return v
end

local function takeSliderInt(label, value, minV, maxV)
  local a, b = ImGui.SliderInt(label, value, minV, maxV)

  -- CET usually returns: value, changed
  if type(a) == "number" and type(b) == "boolean" then
    return b, toInt(a)
  end

  -- Fallback for other ImGui bindings: changed, value
  if type(a) == "boolean" and type(b) == "number" then
    return a, toInt(b)
  end

  return false, value
end

local function takeCheckbox(label, value)
  local checked, changed = ImGui.Checkbox(label, value)

  -- CET shape: checked, changed
  if type(checked) == "boolean" and type(changed) == "boolean" then
    return changed, checked
  end

  return false, value
end

local function getFact(name, default)
  local qs = Game.GetQuestsSystem()
  if not qs then return default or 0 end

  local ok, value = pcall(function()
    return qs:GetFactStr(name)
  end)

  if ok then
    return toInt(value)
  end

  return default or 0
end

local function setFact(ctx, name, value)
  value = toInt(value)

  if ctx and type(ctx.setFactInt) == "function" then
    ctx.setFactInt(name, value)
    return
  end

  local qs = Game.GetQuestsSystem()
  if qs then
    qs:SetFactStr(name, tostring(value))
  end
end

function M.reloadFromFacts()
  for groupKey, group in pairs(GROUPS) do
    for _, key in ipairs(ORDER) do
      local f = group.fields[key]
      state[groupKey][key] = clamp(getFact(f.fact, f.default), f.min, f.max)
    end
  end

	state.fuel_style = clamp(getFact("vm_3d_fuel_style", 0), 0, 5)
	state.fuel_alt_style = clamp(getFact("vm_3d_fuel_alt_style", 0), 0, 5)
	state.theme = clamp(getFact("vm_3d_theme", 0), 0, 9)
	state.font_index = clamp(getFact("vm_3d_font_index", 0), 0, 13)
	state.emissive_ev_deci = clamp(getFact("vm_3d_emissive_ev_deci", 60), 0, 120)

  local fs = getFact("vm_3d_font_scale_milli", 1000)
  if fs <= 0 then fs = 1000 end
  state.font_scale_milli = clamp(fs, 500, 2000)

  state.hide_fuel = getFact("vm_3d_fuel_hidden", 0) > 0
  state.hide_odo = getFact("vm_3d_odo_hidden", 0) > 0
  state.hide_odo_frame = getFact("vm_3d_odo_hide_frame", 0) > 0
	
	state.hide_fuel_alt = getFact("vm_3d_fuel_alt_hidden", 0) > 0
  state.hide_odo_alt = getFact("vm_3d_odo_alt_hidden", 0) > 0
  state.hide_odo_alt_frame = getFact("vm_3d_odo_alt_hide_frame", 0) > 0

  loaded = true
end

local function drawHideCheckbox(ctx, label, key, fact)
  local changed, checked = takeCheckbox(label, state[key] == true)

  if changed then
    state[key] = checked and true or false
    setFact(ctx, fact, checked and 1 or 0)
  end
end

local function sliderInt(ctx, groupKey, key)
  local group = GROUPS[groupKey]
  local f = group.fields[key]

  local value = state[groupKey][key]
  if value == nil then value = f.default end

  local id = "##vm3d_" .. groupKey .. "_" .. key

  -- Precise -1 button before the slider
  if ImGui.Button("-" .. id .. "_minus") then
    value = clamp(value - 1, f.min, f.max)
    state[groupKey][key] = value
    setFact(ctx, f.fact, value)
  end

  ImGui.SameLine()

  -- Main slider
  local changed
  changed, value = takeSliderInt(
    f.label .. id,
    value,
    f.min,
    f.max
  )

  if changed then
    value = clamp(value, f.min, f.max)
    state[groupKey][key] = value
    setFact(ctx, f.fact, value)
  end

  ImGui.SameLine()

  -- Precise +1 button after the slider
  if ImGui.Button("+" .. id .. "_plus") then
    value = state[groupKey][key]
    if value == nil then value = f.default end

    value = clamp(value + 1, f.min, f.max)
    state[groupKey][key] = value
    setFact(ctx, f.fact, value)
  end
end

local function drawFontControls(ctx)
  local current = FONT_OPTIONS[state.font_index] or FONT_OPTIONS[0]

  ImGui.Text("3D Widget Font")

  if ImGui.BeginCombo("Font##vm3d_font", current) then
    for _, idx in ipairs(FONT_ORDER) do
      local label = FONT_OPTIONS[idx]
      local selected = state.font_index == idx

      if ImGui.Selectable(label .. "##vm3d_font_" .. tostring(idx), selected) then
        state.font_index = idx
        setFact(ctx, "vm_3d_font_index", idx)
      end
    end

    ImGui.EndCombo()
  end

  local pct = toInt((state.font_scale_milli or 1000) / 10)
  local changed
  changed, pct = takeSliderInt("Font Size %##vm3d_font_size", pct, 50, 200)

  if changed then
    state.font_scale_milli = clamp(pct * 10, 500, 2000)
    setFact(ctx, "vm_3d_font_scale_milli", state.font_scale_milli)
  end
end

local function drawEmissiveControls(ctx)
  ImGui.Text("3D Widget Brightness")

  local value = state.emissive_ev_deci or 60
  local changed
  changed, value = takeSliderInt("EmissiveEV x10##vm3d_emissive_ev", value, 0, 120)

  if changed then
    value = clamp(value, 0, 120)
    state.emissive_ev_deci = value
    setFact(ctx, "vm_3d_emissive_ev_deci", value)
  end

  ImGui.Text(("EmissiveEV: %.1f"):format((state.emissive_ev_deci or 60) / 10.0))
end

local function drawThemeControls(ctx)
  local current = THEME_LABELS[state.theme] or THEME_LABELS[0]

  ImGui.Text("3D Widget Theme")

  if ImGui.BeginCombo("Theme##vm3d_theme", current) then
    for _, idx in ipairs(THEME_ORDER) do
      local label = THEME_LABELS[idx]
      local selected = state.theme == idx

      if ImGui.Selectable(label .. "##vm3d_theme_" .. tostring(idx), selected) then
        state.theme = idx
        setFact(ctx, "vm_3d_theme", idx)
      end
    end

    ImGui.EndCombo()
  end
end

local function drawFuelStyle(ctx, stateKey, factName, idSuffix)
  stateKey = stateKey or "fuel_style"
  factName = factName or "vm_3d_fuel_style"
  idSuffix = idSuffix or "main"

  local currentStyle = state[stateKey] or 0

  ImGui.Text("Fuel Gauge Style")
  ImGui.Text("Current: " .. tostring(FUEL_STYLE_LABELS[currentStyle] or "Unknown"))

  if ImGui.Button((currentStyle == 0 and "[Arc Gauge]" or "Arc Gauge") .. "##vm3d_style_arc_" .. idSuffix) then
    state[stateKey] = 0
    setFact(ctx, factName, 0)
  end

  ImGui.SameLine()

  if ImGui.Button((currentStyle == 1 and "[Progress Bar]" or "Progress Bar") .. "##vm3d_style_bar_" .. idSuffix) then
    state[stateKey] = 1
    setFact(ctx, factName, 1)
  end

  ImGui.SameLine()

  if ImGui.Button((currentStyle == 2 and "[Digits Only]" or "Digits Only") .. "##vm3d_style_digits_" .. idSuffix) then
    state[stateKey] = 2
    setFact(ctx, factName, 2)
  end
	
	ImGui.SameLine()

  if ImGui.Button((currentStyle == 3 and "[Classic Needle]" or "Classic Needle") .. "##vm3d_style_classic_" .. idSuffix) then
    state[stateKey] = 3
    setFact(ctx, factName, 3)
  end
	
	ImGui.SameLine()

  if ImGui.Button((currentStyle == 4 and "[Vertical Segment]" or "Vertical Segment") .. "##vm3d_style_segment_" .. idSuffix) then
    state[stateKey] = 4
    setFact(ctx, factName, 4)
  end
	
	--ImGui.SameLine()

  if ImGui.Button((currentStyle == 5 and "[Pump Only]" or "Pump Only") .. "##vm3d_style_pump_" .. idSuffix) then
    state[stateKey] = 5
    setFact(ctx, factName, 5)
  end
	
end

local function drawPlacement(ctx, groupKey)
  local group = GROUPS[groupKey]

  ImGui.Text(group.title .. " Placement")

  sliderInt(ctx, groupKey, "side")
  ImGui.Text("Current side: " .. tostring(SIDE_LABELS[state[groupKey].side] or "Unknown"))

  ImGui.Separator()

  sliderInt(ctx, groupKey, "out_cm")
  sliderInt(ctx, groupKey, "y_cm")
  sliderInt(ctx, groupKey, "z_cm")

  ImGui.Separator()

  sliderInt(ctx, groupKey, "roll_deg")
  sliderInt(ctx, groupKey, "pitch_deg")
  sliderInt(ctx, groupKey, "yaw_deg")

  ImGui.Separator()

  sliderInt(ctx, groupKey, "scale_milli")
  ImGui.Text("Scale: 600 = normal size")
end

local function presetKey(preset)
  if type(preset) == "table" then
    return tostring(preset.file_name or preset.name or "")
  end

  return tostring(preset or "")
end

local function presetDisplayName(preset)
  if type(preset) == "table" then
    return tostring(preset.name or preset.file_name or "Preset")
  end

  return tostring(preset or "Preset")
end

local function presetExists(preset)
  local wanted = presetKey(preset)

  for _, v in ipairs(presetNames or {}) do
    if presetKey(v) == wanted then
      return true
    end
  end

  return false
end

local function reloadPresetList(ctx)
  presetNames = {}

  if type(ctx.listPresets) == "function" then
    local ok, list = pcall(ctx.listPresets)

    if ok and type(list) == "table" then
      presetNames = list
    end
  end

  if #presetNames <= 0 then
    selectedPreset = nil
    presetsLoaded = true
    return
  end

  if not selectedPreset or not presetExists(selectedPreset) then
    selectedPreset = presetNames[1]
  end

  presetsLoaded = true
end

local function drawPresetControls(ctx)
  if not presetsLoaded then
    reloadPresetList(ctx)
  end

  ImGui.Separator()
	ImGui.Separator()
  ImGui.Text("3D Presets")
  ImGui.Text("Load only applies a live preview. Use Save vehicle to persist it.")

  if ImGui.Button("Save preset##vm3d_save_preset") then
    if type(ctx.savePreset) == "function" then
      local ok, msg = ctx.savePreset()

      presetStatus = tostring(msg or (ok and "Preset saved." or "Preset save failed."))

      -- Refresh dropdown so the newly saved preset appears immediately.
      reloadPresetList(ctx)
    else
      presetStatus = "Preset save function missing."
    end
  end

  ImGui.SameLine()

if ImGui.Button("Load preset##vm3d_load_preset") then
    if not selectedPreset or selectedPreset == "" then
      presetStatus = "No preset selected."
    elseif type(ctx.loadPreset) == "function" then
      local ok, msg = ctx.loadPreset(selectedPreset)

      presetStatus = tostring(msg or (ok and "Preset loaded." or "Preset load failed."))

      if ok then
        -- Reload UI values from the facts changed by the loaded preset.
        M.reloadFromFacts()
      end
    else
      presetStatus = "Preset load function missing."
    end
  end

  ImGui.SameLine()

  if ImGui.Button("Delete preset##vm3d_delete_preset") then
    if not selectedPreset or selectedPreset == "" then
      presetStatus = "No preset selected."
    elseif type(ctx.deletePreset) == "function" then
      local deletedName = selectedPreset
      local ok, msg = ctx.deletePreset(deletedName)

      presetStatus = tostring(msg or (ok and "Preset deleted." or "Preset delete failed."))

      if ok then
        selectedPreset = nil
        presetsLoaded = false
        reloadPresetList(ctx)
      end
    else
      presetStatus = "Preset delete function missing."
    end
  end

  ImGui.SameLine()

	if ImGui.Button("Refresh##vm3d_refresh_presets") then
		if type(ctx.refreshPresets) == "function" then
			local ok, msg = ctx.refreshPresets()
			presetStatus = tostring(msg or (ok and "Preset list refreshed." or "Preset refresh failed."))
		else
			presetStatus = "Preset list refreshed."
		end

		presetsLoaded = false
		reloadPresetList(ctx)
	end

	ImGui.SameLine()

	local comboLabel = selectedPreset and presetDisplayName(selectedPreset) or "No presets found"

	if ImGui.BeginCombo("Preset##vm3d_preset_combo", comboLabel) then
		for i, preset in ipairs(presetNames or {}) do
			local selected = presetKey(selectedPreset) == presetKey(preset)
			local label = presetDisplayName(preset)
			local id = presetKey(preset)

			if ImGui.Selectable(label .. "##vm3d_preset_" .. tostring(i) .. "_" .. id, selected) then
				selectedPreset = preset
			end
		end

    ImGui.EndCombo()
  end

  if presetStatus and presetStatus ~= "" then
    if ImGui.TextDisabled then
      ImGui.TextDisabled(presetStatus)
    else
      ImGui.Text(presetStatus)
    end
  end
end

function M.drawIfActive(ctx)
  ctx = ctx or {}

  local vehicle = nil
  local reason = nil

  if type(ctx.getContext) == "function" then
    vehicle, reason = ctx.getContext()
  end

  if not vehicle then
    ImGui.Text("3D controls are only available in a player-owned mounted vehicle.")
    ImGui.Text(tostring(reason or "No valid vehicle."))
    return
  end

	if loadedVehicleId ~= vehicle.id then
		loaded = false
		loadedVehicleId = vehicle.id

		-- Refresh preset dropdown when changing vehicle/context.
		presetsLoaded = false
		presetStatus = ""
	end

  if not loaded then
    M.reloadFromFacts()
  end

  ImGui.Text("Vehicle: " .. tostring(vehicle.name or vehicle.label or "Unknown"))
  ImGui.Text("Live preview is active. Use Save vehicle to persist this vehicle's 3D setup.")
  ImGui.Separator()

	drawThemeControls(ctx)

	ImGui.Separator()

	drawFontControls(ctx)

	ImGui.Separator()
	
	ImGui.Separator()

	drawEmissiveControls(ctx)

	if ImGui.BeginTabBar("VM3D_Setup_Tabs") then
    if ImGui.BeginTabItem("Fuel Gauge") then
      drawHideCheckbox(ctx, "Hide Fuel Gauge", "hide_fuel", "vm_3d_fuel_hidden")

      ImGui.Separator()
      drawFuelStyle(ctx, "fuel_style", "vm_3d_fuel_style", "main")

      ImGui.Separator()
      drawPlacement(ctx, "fuel")

      ImGui.EndTabItem()
    end

    if ImGui.BeginTabItem("ODO Plate") then
      drawHideCheckbox(ctx, "Hide ODO Plate", "hide_odo", "vm_3d_odo_hidden")
      drawHideCheckbox(ctx, "Hide ODO Frame", "hide_odo_frame", "vm_3d_odo_hide_frame")

      ImGui.Separator()
      drawPlacement(ctx, "odo")

      ImGui.EndTabItem()
    end

    if ImGui.BeginTabItem("Fuel Gauge Alt") then
      drawHideCheckbox(ctx, "Hide Fuel Gauge Alt", "hide_fuel_alt", "vm_3d_fuel_alt_hidden")

      ImGui.Separator()
      drawFuelStyle(ctx, "fuel_alt_style", "vm_3d_fuel_alt_style", "alt")

      ImGui.Separator()
      drawPlacement(ctx, "fuel_alt")

      ImGui.EndTabItem()
    end

    if ImGui.BeginTabItem("ODO Plate Alt") then
      drawHideCheckbox(ctx, "Hide ODO Plate Alt", "hide_odo_alt", "vm_3d_odo_alt_hidden")
      drawHideCheckbox(ctx, "Hide ODO Alt Frame", "hide_odo_alt_frame", "vm_3d_odo_alt_hide_frame")

      ImGui.Separator()
      drawPlacement(ctx, "odo_alt")

      ImGui.EndTabItem()
    end

    ImGui.EndTabBar()
  end

  ImGui.Separator()

  if ImGui.Button("Reset vehicle##vm3d_reset_vehicle") then
    if type(ctx.resetVehicle) == "function" then
      ctx.resetVehicle()
      M.reloadFromFacts()
    end
  end

  ImGui.SameLine()

  if ImGui.Button("Save vehicle##vm3d_save_vehicle") then
    if type(ctx.saveVehicle) == "function" then
      ctx.saveVehicle()
    end
  end
	drawPresetControls(ctx)
end

return M