-- Immersive Odometer and Fuel System
-- CET is intentionally limited to this configuration/3D/location editor and
-- the one-time handoff of legacy JSON. All gameplay and normal persistence
-- live in VehicleMileage.Runtime.VMRuntimeSystem (REDscript).

local VM = {
  overlayOpen = false,
  message = "REDscript bridge not queried yet.",
  specLabel = "",
  spec = { l100 = 12.0, tank = 40.0, oilMin = 80.0, oilMax = 120.0 },
  presetName = "Vehicle",
  selectedPreset = "",
  devGasRadius = 2.0,
  devRepairRadius = 3.0,
  devRepairPrice = 500.0,
  devRepairFx = { "", "", "", "", "", "", "", "", "", "" },
}

-- Developer-only location editor. Set to false for release builds that should
-- hide the gas-point and repair-zone authoring controls.
local DEV_LOCATION_EDITOR = false

local PublicAPI = {}

-- Keep reset values aligned with VMSettings.CreateDefault() and
-- VMWorldObjectSettings.CreateDefault() in VMRuntimeTypes.reds.
local settingDefaults = {
  fuel_enabled = true,
  dynamic_price = true,
  price_epl = 50.0,
  maintenance_enabled = true,
  maintenance_min_km = 20,
  maintenance_max_km = 30,
  repair_automatic = false,
  repair_price_adjust_pct = 0,
  stolen_stall = true,
  gas_pins_world = true,
  gas_pins_vehicle_only = false,
  theme = 0,
  fg_enabled = true,
  fg_temp_enabled = true,
  lb_enabled = true,
  auto_hide = false,
  auto_hide_seconds = 20.0,
  auto_hide_fuel_pct = 25,
  hud_x = 280.0 / 3840.0,
  hud_y = 443.0 / 2160.0,
  price_dx = 0.0,
  price_dy = 350.0,
  fg_dx = -1510.0,
  fg_dy = 275.0,
  fg_scale = 330.0,
  lb_dx = -850.0,
  lb_dy = 800.0,
  lb_scale = 480.0,
}

local worldDefaults = {
  lb = { theme = 0, font = 6, font_size = 28, brightness = 1000, scale = 1000, x = 0, y = 0, hidden = false, border_hidden = false },
  aux1 = { theme = 0, font = 6, font_size = 32, brightness = 1000, scale = 1000, x = -360, y = 0, hidden = true, border_hidden = false },
  aux2 = { theme = 0, font = 6, font_size = 32, brightness = 1000, scale = 1000, x = 0, y = 0, hidden = true, border_hidden = false },
  aux3 = { theme = 0, font = 6, font_size = 32, brightness = 1000, scale = 1000, x = 360, y = 0, hidden = true, border_hidden = false },
}

local unpackArgs = table.unpack or unpack
local windowHost = ImGui

local function resolveWindowHost()
  windowHost = ImGui
  if type(GetMod) ~= "function" then return end

  local ok, candidate = pcall(GetMod, "WindowUtils")
  if ok and candidate and type(candidate.Begin) == "function" and type(candidate.End) == "function" then
    windowHost = candidate
  end
end

local function bridge()
  local ok, system = pcall(function()
    local container = Game.GetScriptableSystemsContainer()
    if not container then return nil end
    return container:Get("VehicleMileage.Runtime.VMRuntimeSystem")
  end)
  if ok then return system end
  return nil
end

local function invoke(method, default, ...)
  local system = bridge()
  if not system then return default end
  local args = { ... }
  local ok, value = pcall(function()
    return system[method](system, unpackArgs(args))
  end)
  if ok and value ~= nil then return value end
  return default
end

local function setMessage(value)
  if value ~= nil then VM.message = tostring(value) end
end

local function readLegacy(path)
  local file = io.open(path, "rb")
  if not file then return nil end
  local raw = file:read("*a")
  file:close()
  return raw
end

local function importLegacyJson()
  local needsLegacyImport = invoke("NeedsLegacyImport", false)
  local needsPresetImport = invoke("NeedsLegacyPresetImport", false)
  if not needsLegacyImport and not needsPresetImport then return end

  local imported = 0
  local names = {
    "vm_config_cars.json",
    "vm_config_bikes.json",
    "vm_settings.json",
    "vm_vehicle_ignore.json",
    "vm_gas_locations.json",
    "vm_repair_stations.json",
    "vm_ignore_seeds.json",
  }

  if needsLegacyImport then
    for _, name in ipairs(names) do
      local raw = readLegacy(name)
      if raw and raw ~= "" and invoke("ImportLegacyJson", false, name, raw) then
        imported = imported + 1
      end
    end
  end

  -- Legacy preset files are read once and written by REDscript into the
  -- RedFileSystem storage. CET never writes normal configuration JSON.
  local presetScanComplete = not needsPresetImport
  if needsPresetImport and type(dir) == "function" then
    local ok, files = pcall(dir, "3DPresets")
    if ok then
      -- CET returns nil when the legacy folder does not exist. That is a
      -- successful empty scan on a clean install, not a migration failure.
      presetScanComplete = true
      if type(files) == "table" then
        for _, entry in ipairs(files) do
          local name = type(entry) == "table" and entry.name or tostring(entry or "")
          if type(name) == "string" and name:lower():match("%.json$") then
            local raw = readLegacy("3DPresets/" .. name)
            local base = name:gsub("%.json$", "")
            if raw and raw ~= "" and invoke("ImportLegacyJson", false, "preset:" .. base, raw) then
              imported = imported + 1
            end
          end
        end
      end
    end
  end

  local legacyFinished = not needsLegacyImport or invoke("FinishLegacyImport", false)
  local presetsFinished = not needsPresetImport
    or (presetScanComplete and invoke("FinishLegacyPresetImport", false))
  if legacyFinished and presetsFinished then
    VM.message = ("Legacy JSON migration complete: %d file(s) imported."):format(imported)
    print("[VehicleMileage] " .. VM.message)
  else
    VM.message = "Legacy migration could not be finalized. It will retry next CET reload."
    print("[VehicleMileage] " .. VM.message)
  end
end

local function takeItemDefault(changed, value, defaultValue)
  if defaultValue ~= nil and ImGui.IsItemClicked(1) then
    return true, defaultValue, true
  end
  return changed, value, false
end

local function takeCheckbox(label, value, defaultValue)
  local checked, changed = ImGui.Checkbox(label, value)
  if type(checked) == "boolean" and type(changed) == "boolean" then
    return takeItemDefault(changed, checked, defaultValue)
  end
  if type(checked) == "boolean" then
    return takeItemDefault(checked ~= value, checked, defaultValue)
  end
  return takeItemDefault(false, value, defaultValue)
end

local function takeSelectable(label, selected)
  ImGui.Selectable(label, selected)
  return ImGui.IsItemClicked()
end

local function takeSliderInt(label, value, minimum, maximum, defaultValue)
  local a, b = ImGui.SliderInt(label, value, minimum, maximum)
  if type(a) == "number" and type(b) == "boolean" then return takeItemDefault(b, math.floor(a), defaultValue) end
  if type(a) == "boolean" and type(b) == "number" then return takeItemDefault(a, math.floor(b), defaultValue) end
  if type(a) == "number" then return takeItemDefault(a ~= value, math.floor(a), defaultValue) end
  return takeItemDefault(false, value, defaultValue)
end

local function takeSliderFloat(label, value, minimum, maximum, format, defaultValue)
  local a, b = ImGui.SliderFloat(label, value, minimum, maximum, format or "%.2f")
  if type(a) == "number" and type(b) == "boolean" then return takeItemDefault(b, a, defaultValue) end
  if type(a) == "boolean" and type(b) == "number" then return takeItemDefault(a, b, defaultValue) end
  if type(a) == "number" then return takeItemDefault(a ~= value, a, defaultValue) end
  return takeItemDefault(false, value, defaultValue)
end

local function takeInputFloat(label, value, step, format, defaultValue)
  local a, b = ImGui.InputFloat(label, value, step or 0.1, (step or 0.1) * 10.0, format or "%.2f")
  if type(a) == "number" and type(b) == "boolean" then return takeItemDefault(b, a, defaultValue) end
  if type(a) == "boolean" and type(b) == "number" then return takeItemDefault(a, b, defaultValue) end
  if type(a) == "number" then return takeItemDefault(a ~= value, a, defaultValue) end
  return takeItemDefault(false, value, defaultValue)
end

local function takeInputText(label, value, capacity)
  local a, b = ImGui.InputText(label, value, capacity or 128)
  if type(a) == "string" then return type(b) == "boolean" and b or a ~= value, a end
  if type(b) == "string" then return type(a) == "boolean" and a or b ~= value, b end
  return false, value
end

local function drawTooltip(description, resettable)
  if description and description ~= "" and ImGui.IsItemHovered() then
    ImGui.SetTooltip(description .. (resettable and "\nRight-click to restore the default value." or ""))
  end
end

local function drawBoolSetting(key, label, description)
  local value = invoke("GetSettingBool", false, key)
  local changed, nextValue = takeCheckbox(label, value, settingDefaults[key])
  drawTooltip(description, true)
  if changed then invoke("SetSettingBool", false, key, nextValue) end
end

local function drawIntSetting(key, label, minimum, maximum, description)
  local value = invoke("GetSettingInt", 0, key)
  local changed, nextValue, reset = takeSliderInt(label, value, minimum, maximum, settingDefaults[key])
  drawTooltip(description, true)
  if reset and key == "maintenance_min_km" and invoke("GetSettingInt", 0, "maintenance_max_km") < nextValue then
    invoke("SetSettingInt", false, "maintenance_max_km", settingDefaults.maintenance_max_km)
  elseif reset and key == "maintenance_max_km" and invoke("GetSettingInt", 0, "maintenance_min_km") > nextValue then
    invoke("SetSettingInt", false, "maintenance_min_km", settingDefaults.maintenance_min_km)
  end
  if changed then invoke("SetSettingInt", false, key, nextValue) end
end

local function drawFloatSetting(key, label, minimum, maximum, format, description)
  local value = invoke("GetSettingFloat", 0.0, key)
  local changed, nextValue = takeSliderFloat(label, value, minimum, maximum, format, settingDefaults[key])
  drawTooltip(description, true)
  if changed then invoke("SetSettingFloat", false, key, nextValue) end
end

local function drawWidgetMode(description)
  local current = tostring(invoke("GetWidgetMode", "fuelgauge"))
  local labels = {
    vmhud = "Legacy Digits",
    fuelgauge = "Fuel Gauge",
    ["3dwidget"] = "3D Widget",
  }
  local comboOpen = ImGui.BeginCombo("Active HUD Widget##vm_mode", labels[current] or current)
  local reset, nextMode = takeItemDefault(false, current, "fuelgauge")
  drawTooltip(description, true)
  if reset and invoke("SetWidgetMode", false, nextMode) then
    current = nextMode
    VM.message = "Active HUD widget: " .. (labels[nextMode] or nextMode)
  end
  if comboOpen then
    for _, mode in ipairs({ "vmhud", "fuelgauge", "3dwidget" }) do
      if takeSelectable((labels[mode] or mode) .. "##vm_mode_" .. mode, current == mode) then
        if invoke("SetWidgetMode", false, mode) then
          VM.message = "Active HUD widget: " .. (labels[mode] or mode)
        else
          VM.message = "Could not change the active HUD widget."
        end
      end
    end
    ImGui.EndCombo()
  end
end

local function getSpecDefault(key)
  local lower = VM.specLabel:lower()
  local isBike = lower:find("bike", 1, true)
    or lower:find("yaiba", 1, true)
    or lower:find("arch", 1, true)
  local isAV = lower:find("vehicle.av_", 1, true)
    or lower:find(".av_", 1, true)
    or lower:find("_dav", 1, true)

  if key == "l100" then return (isBike or isAV) and 6.0 or 12.0 end
  if key == "tank" then return isBike and 18.0 or isAV and 120.0 or 40.0 end
  if key == "oil_min" then return 80.0 end
  if key == "oil_max" then return isBike and 100.0 or 120.0 end
  return 0.0
end

local function refreshSpecDraft()
  local label = tostring(invoke("GetMountedLabel", ""))
  if label == "" then
    VM.specLabel = ""
    return
  end
  if label ~= VM.specLabel then
    VM.specLabel = label
    VM.spec.l100 = invoke("GetSpecL100Km", 12.0)
    VM.spec.tank = invoke("GetSpecTankL", 40.0)
    VM.spec.oilMin = invoke("GetSpecOilMinC", 80.0)
    VM.spec.oilMax = invoke("GetSpecOilMaxC", 120.0)
    VM.presetName = label:gsub("^Vehicle%.", ""):gsub("_", " ")
  end
end

local function drawStatusTab()
  ImGui.Text("Runtime")
  ImGui.Text("Storage: " .. (invoke("IsReady", false) and "Available" or "Unavailable"))
  ImGui.TextWrapped(tostring(invoke("GetStatus", "REDscript bridge unavailable.")))

  local modes = {
    vmhud = "Legacy Digits",
    fuelgauge = "Fuel Gauge",
    ["3dwidget"] = "3D Widget",
  }
  local mode = tostring(invoke("GetWidgetMode", "fuelgauge"))
  ImGui.Text("Active HUD: " .. (modes[mode] or mode))

  ImGui.Separator()
  ImGui.Text("Mounted vehicle")
  local label = tostring(invoke("GetMountedLabel", ""))
  if label == "" then
    if ImGui.TextDisabled then ImGui.TextDisabled("No vehicle mounted.") else ImGui.Text("No vehicle mounted.") end
  else
    ImGui.TextWrapped(label)
    ImGui.Text("Ownership: " .. (invoke("IsMountedOwned", false) and "Owned" or "Unowned / stolen"))
    ImGui.Text("Ignored: " .. (invoke("IsMountedIgnored", false) and "Yes" or "No"))
    ImGui.Text(("Odometer: %.3f km"):format(invoke("GetCurrentMeters", 0) / 1000.0))
    ImGui.Text(("Fuel: %.1f%%"):format(invoke("GetCurrentFuelPermille", 0) / 10.0))
    ImGui.Text(("Oil: %.1f C | Speed: %.1f km/h"):format(
      invoke("GetCurrentOilTempC", 0.0),
      invoke("GetLiveSpeedKmh", 0.0)
    ))
    ImGui.Text(("Instant consumption: %.2f L/100 km"):format(invoke("GetLiveConsumption", 0.0)))
  end

end

local function drawSettingsTab()
  ImGui.Text("Gameplay")
  drawBoolSetting("fuel_enabled", "Fuel system enabled", "Enables fuel consumption, refueling, empty-tank stalling, and fuel persistence.")
  drawBoolSetting("dynamic_price", "Dynamic fuel price", "Changes the live fuel price over game time around the configured base price.")
  drawFloatSetting("price_epl", "Base price per liter", 0.0, 500.0, "%.2f", "Sets the base E$ price per liter and the center value used by dynamic pricing.")
  drawBoolSetting("maintenance_enabled", "Maintenance enabled", "Enables mileage-based service intervals and overdue fuel-system failures.")
  drawIntSetting("maintenance_min_km", "Minimum maintenance interval (km)", 1, 1000, "Sets the shortest randomized distance before the next maintenance is due.")
  drawIntSetting("maintenance_max_km", "Maximum maintenance interval (km)", 1, 1000, "Sets the longest randomized distance before the next maintenance is due.")
  drawBoolSetting("repair_automatic", "Automatic repair sequence", "Lets repair bays automatically dismount, replace, reposition, and remount the vehicle.")
  drawIntSetting("repair_price_adjust_pct", "Repair price adjustment (%)", -100, 2000, "Adjusts repair-bay cost: negative is cheaper, positive is more expensive, and -100% is free.")
  drawBoolSetting("stolen_stall", "Stolen vehicles stall at empty", "Also applies empty-tank stalling to unowned or stolen vehicles. Owned vehicles always stall.")

  ImGui.Separator()
  ImGui.Text("Gas-station markers")
  drawBoolSetting("gas_pins_world", "Show floating in-world markers", "Controls only the floating 3D gas-station markers. World-map and minimap icons are unaffected.")
  if invoke("GetSettingBool", false, "gas_pins_world") then
    drawBoolSetting("gas_pins_vehicle_only", "In-world markers: vehicle-only", "When floating in-world markers are enabled, hides them on foot and shows them while mounted in any vehicle. World-map and minimap icons are unaffected.")
  end

  ImGui.Separator()
  ImGui.Text("HUD")
  drawWidgetMode("Selects the active odometer and fuel display: Legacy Digits, Fuel Gauge, or the vehicle-mounted 3D Widget.")
  drawIntSetting("theme", "Fuel gauge theme", 0, 9, "Selects the visual theme used by the Fuel Gauge HUD.")
  drawBoolSetting("fg_enabled", "Fuel gauge enabled", "Allows the Fuel Gauge HUD to render when Fuel Gauge is the active HUD widget.")
  drawBoolSetting("fg_temp_enabled", "Fuel gauge temperature", "Shows the vehicle oil temperature in the Fuel Gauge HUD.")
  drawBoolSetting("lb_enabled", "Leaderboard enabled", "Shows the vehicle mileage leaderboard HUD.")
  drawBoolSetting("auto_hide", "HUD auto-hide (Only 2D Widgets)", "Hides the active 2D HUD after a delay while fuel remains above the warning threshold.")
  drawFloatSetting("auto_hide_seconds", "Auto-hide delay (seconds)", 0.0, 120.0, "%.1f", "Sets how many seconds the HUD stays visible before auto-hiding.")
  drawIntSetting("auto_hide_fuel_pct", "Keep visible below fuel (%)", 0, 100, "Keeps the HUD visible whenever fuel is at or below this percentage.")

  ImGui.Separator()
  ImGui.Text("Layout")
  drawFloatSetting("hud_x", "Legacy HUD X (normalized)", 0.0, 1.0, "%.4f", "Sets the Legacy Digits horizontal screen position from 0.0 to 1.0.")
  drawFloatSetting("hud_y", "Legacy HUD Y (normalized)", 0.0, 1.0, "%.4f", "Sets the Legacy Digits vertical screen position from 0.0 to 1.0.")
  drawFloatSetting("price_dx", "Price X offset", -3000.0, 3000.0, "%.0f", "Moves the refueling price display horizontally by this pixel offset.")
  drawFloatSetting("price_dy", "Price Y offset", -3000.0, 3000.0, "%.0f", "Moves the refueling price display vertically by this pixel offset.")
  drawFloatSetting("fg_dx", "Fuel gauge X offset", -3000.0, 3000.0, "%.0f", "Moves the Fuel Gauge HUD horizontally by this pixel offset.")
  drawFloatSetting("fg_dy", "Fuel gauge Y offset", -3000.0, 3000.0, "%.0f", "Moves the Fuel Gauge HUD vertically by this pixel offset.")
  drawFloatSetting("fg_scale", "Fuel gauge scale (milli)", 1.0, 2000.0, "%.0f", "Scales the Fuel Gauge HUD in thousandths; 1000 equals 1.0x size.")
  drawFloatSetting("lb_dx", "Leaderboard X offset", -3000.0, 3000.0, "%.0f", "Moves the leaderboard HUD horizontally by this pixel offset.")
  drawFloatSetting("lb_dy", "Leaderboard Y offset", -3000.0, 3000.0, "%.0f", "Moves the leaderboard HUD vertically by this pixel offset.")
  drawFloatSetting("lb_scale", "Leaderboard scale (milli)", 1.0, 2000.0, "%.0f", "Scales the leaderboard HUD in thousandths; 1000 equals 1.0x size.")

  ImGui.Separator()
  ImGui.Text("Vehicle ignore list")
  local mountedLabel = tostring(invoke("GetMountedLabel", ""))
  if mountedLabel == "" then
    if ImGui.TextDisabled then ImGui.TextDisabled("Mount a vehicle to change its ignore state.") else ImGui.Text("Mount a vehicle to change its ignore state.") end
  else
    ImGui.TextWrapped("Current vehicle: " .. mountedLabel)
    local ignored = invoke("IsMountedIgnored", false)
    local ignorePressed = ImGui.Button((ignored and "Stop ignoring vehicle" or "Ignore vehicle") .. "##vm_settings_ignore")
    drawTooltip(ignored
      and "Removes the mounted vehicle from vm_vehicle_ignore.json so tracking and HUD features resume."
      or "Adds the mounted vehicle to vm_vehicle_ignore.json so its mileage, fuel, and HUD features are skipped.")
    if ignorePressed then
      setMessage(invoke("SetCurrentIgnored", "Ignore update failed.", not ignored))
    end
  end

  ImGui.Separator()
  local savePressed = ImGui.Button("Save settings##vm_settings_save")
  drawTooltip("Persists the current options to vm_settings.json through RedFileSystem.")
  if savePressed then
    setMessage(invoke("SaveSettingsFromOverlay", "Settings save failed."))
  end
end

local function drawVehicleTab()
  refreshSpecDraft()
  if VM.specLabel == "" then
    ImGui.Text("Mount an owned vehicle to configure it.")
    return
  end

  ImGui.Text("Vehicle: " .. VM.specLabel)
  ImGui.Text(("Odometer: %.3f km"):format(invoke("GetCurrentMeters", 0) / 1000.0))
  ImGui.Text(("Fuel: %.1f%%"):format(invoke("GetCurrentFuelPermille", 0) / 10.0))
  ImGui.Text(("Oil: %.1f C | Speed: %.1f km/h"):format(
    invoke("GetCurrentOilTempC", 0.0),
    invoke("GetLiveSpeedKmh", 0.0)
  ))
  ImGui.Text(("Instant consumption: %.2f L/100 km"):format(invoke("GetLiveConsumption", 0.0)))

  if not invoke("IsMountedOwned", false) then
    ImGui.Text("This vehicle is not owned; its state is intentionally ephemeral.")
    return
  end

  ImGui.Separator()
  ImGui.Text("Vehicle specification")
  local _, value, reset
  _, value = takeInputFloat("L/100 km##vm_spec_l100", VM.spec.l100, 0.1, "%.2f", getSpecDefault("l100"))
  drawTooltip("Sets this vehicle's base fuel consumption in liters per 100 kilometers.", true)
  VM.spec.l100 = value
  _, value = takeInputFloat("Tank liters##vm_spec_tank", VM.spec.tank, 1.0, "%.1f", getSpecDefault("tank"))
  drawTooltip("Sets this vehicle's fuel-tank capacity in liters.", true)
  VM.spec.tank = value
  _, value, reset = takeInputFloat("Oil optimum minimum C##vm_spec_oil_min", VM.spec.oilMin, 1.0, "%.0f", getSpecDefault("oil_min"))
  drawTooltip("Sets the lower edge of this vehicle's optimal oil-temperature range.", true)
  VM.spec.oilMin = value
  if reset and VM.spec.oilMax < value then VM.spec.oilMax = getSpecDefault("oil_max") end
  _, value, reset = takeInputFloat("Oil optimum maximum C##vm_spec_oil_max", VM.spec.oilMax, 1.0, "%.0f", getSpecDefault("oil_max"))
  drawTooltip("Sets the upper edge of this vehicle's optimal oil-temperature range.", true)
  VM.spec.oilMax = value
  if reset and VM.spec.oilMin > value then VM.spec.oilMin = getSpecDefault("oil_min") end

  local saveSpecPressed = ImGui.Button("Save vehicle specification##vm_spec_save")
  drawTooltip("Persists this vehicle's consumption, tank, and oil-temperature specification.")
  if saveSpecPressed then
    setMessage(invoke(
      "SaveCurrentSpec",
      "Vehicle save failed.",
      VM.spec.l100,
      VM.spec.tank,
      VM.spec.oilMin,
      VM.spec.oilMax
    ))
  end
  ImGui.SameLine()
  local ignored = invoke("IsMountedIgnored", false)
  local ignorePressed = ImGui.Button((ignored and "Stop ignoring" or "Ignore vehicle") .. "##vm_ignore")
  drawTooltip(ignored
    and "Removes this vehicle from the ignore list so tracking and HUD features resume."
    or "Adds this vehicle to the ignore list so its mileage, fuel, and HUD features are skipped.")
  if ignorePressed then
    setMessage(invoke("SetCurrentIgnored", "Ignore update failed.", not ignored))
  end
end

local function get3DDefault(key)
  if key == "font_scale_milli" then return 1000 end
  if key == "emissive_ev_deci" then return 60 end
  if key:match("%.scale_milli$") then return 600 end
  if key == "fuel_alt.side" or key == "odo_alt.side" then return 1 end
  return 0
end

local function draw3DInt(key, label, minimum, maximum, description, shortStep)
  local value = invoke("Get3DInt", 0, key)
  local changed = false
  local nextValue = value

  if shortStep then
    if ImGui.Button("-##vm3d_step_minus_" .. key) then
      nextValue = math.max(minimum, nextValue - shortStep)
      changed = nextValue ~= value
    end
    drawTooltip("Decreases this value by " .. tostring(shortStep) .. ".")
    ImGui.SameLine()
  end

  local sliderLabel = shortStep and "##vm3d_" .. key or label .. "##vm3d_" .. key
  local sliderChanged, sliderValue = takeSliderInt(
    sliderLabel,
    nextValue,
    minimum,
    maximum,
    get3DDefault(key)
  )
  if sliderChanged then
    changed = true
    nextValue = sliderValue
  end
  drawTooltip(description, true)

  if shortStep then
    ImGui.SameLine()
    if ImGui.Button("+##vm3d_step_plus_" .. key) then
      nextValue = math.min(maximum, nextValue + shortStep)
      changed = nextValue ~= value
    end
    drawTooltip("Increases this value by " .. tostring(shortStep) .. ".")
    ImGui.SameLine()
    ImGui.Text(label)
    drawTooltip(description)
  end

  if changed then invoke("Set3DInt", false, key, nextValue) end
end

local function draw3DBool(key, label, description)
  local value = invoke("Get3DInt", 0, key) > 0
  local changed, nextValue = takeCheckbox(label .. "##vm3d_" .. key, value, false)
  drawTooltip(description, true)
  if changed then invoke("Set3DInt", false, key, nextValue and 1 or 0) end
end

local function draw3DPlacement(prefix, title)
  ImGui.Separator()
  ImGui.Text(title)
  draw3DInt(prefix .. ".side", "Side (0-3)", 0, 3, "Selects the vehicle attachment side and its base orientation.", 1)
  draw3DInt(prefix .. ".out_cm", "Out / depth (cm)", -300, 300, "Moves this element inward or outward from the selected vehicle side.", 1)
  draw3DInt(prefix .. ".y_cm", "Forward / back (cm)", -300, 300, "Moves this element forward or backward along the vehicle.", 1)
  draw3DInt(prefix .. ".z_cm", "Height (cm)", -200, 300, "Moves this element up or down relative to the vehicle.", 1)
  draw3DInt(prefix .. ".roll_deg", "Roll (deg)", -180, 180, "Rotates this element around its forward axis.", 1)
  draw3DInt(prefix .. ".pitch_deg", "Pitch (deg)", -180, 180, "Tilts this element up or down.", 1)
  draw3DInt(prefix .. ".yaw_deg", "Yaw (deg)", -180, 180, "Turns this element left or right.", 1)
  draw3DInt(prefix .. ".scale_milli", "Scale (milli)", 10, 2000, "Scales this element in thousandths; 1000 equals 1.0x size.", 1)
end

local function splitPresets(raw)
  local result = {}
  for name in tostring(raw or ""):gmatch("([^|]+)") do
    result[#result + 1] = name
  end
  return result
end

local function drawPresetControls()
  ImGui.Separator()
  ImGui.Text("3D presets (stored by RedFileSystem)")
  local _, nextName = takeInputText("Preset name##vm3d_preset_name", VM.presetName, 128)
  drawTooltip("Sets the filename-safe display name used when saving this 3D preset.")
  VM.presetName = nextName
  local savePresetPressed = ImGui.Button("Save preset##vm3d_preset_save")
  drawTooltip("Saves the current 3D layout as a reusable JSON preset in the VehicleMileage storage root.")
  if savePresetPressed then
    setMessage(invoke("Save3DPreset", "Preset save failed.", VM.presetName))
  end

  local names = splitPresets(invoke("GetPresetNames", ""))
  local found = false
  for _, name in ipairs(names) do
    if name == VM.selectedPreset then found = true end
  end
  if not found then VM.selectedPreset = names[1] or "" end

  local presetComboOpen = ImGui.BeginCombo("Saved presets##vm3d_presets", VM.selectedPreset ~= "" and VM.selectedPreset or "None")
  drawTooltip("Selects one of the 3D presets stored by RedFileSystem.")
  if presetComboOpen then
    for _, name in ipairs(names) do
      if takeSelectable(name .. "##vm3d_preset_" .. name, VM.selectedPreset == name) then
        VM.selectedPreset = name
      end
    end
    ImGui.EndCombo()
  end
  local loadPresetPressed = ImGui.Button("Load preview##vm3d_preset_load")
  drawTooltip("Loads the selected preset into the live preview without overwriting the saved vehicle setup.")
  if loadPresetPressed and VM.selectedPreset ~= "" then
    setMessage(invoke("Load3DPreset", "Preset load failed.", VM.selectedPreset))
  end
  ImGui.SameLine()
  local deletePresetPressed = ImGui.Button("Delete##vm3d_preset_delete")
  drawTooltip("Deletes the selected preset from the VehicleMileage storage root.")
  if deletePresetPressed and VM.selectedPreset ~= "" then
    setMessage(invoke("Delete3DPreset", "Preset delete failed.", VM.selectedPreset))
    VM.selectedPreset = ""
  end
end

local function draw3DTab()
  if tostring(invoke("GetWidgetMode", "fuelgauge")) ~= "3dwidget" then
    ImGui.TextWrapped("Enable the 3D Widget in Settings > HUD > Active HUD Widget to use the 3D Setup editor.")
    return
  end

  refreshSpecDraft()
  if not invoke("IsMountedOwned", false) then
    ImGui.Text("Mount an owned vehicle to edit its 3D setup.")
    return
  end

  ImGui.Text("Live preview; save the vehicle setup when finished.")
  draw3DInt("fuel_style", "Primary fuel style", 0, 5, "Selects the visual style used by the primary 3D fuel gauge.")
  draw3DInt("fuel_alt_style", "Alternate fuel style", 0, 5, "Selects the visual style used by the alternate 3D fuel gauge.")
  draw3DInt("theme", "Theme", 0, 9, "Selects the color theme used by this vehicle's 3D displays.")
  draw3DInt("font_index", "Font", 0, 13, "Selects the font used for the 3D odometer digits.")
  draw3DInt("font_scale_milli", "Font scale (milli)", 500, 2000, "Scales the 3D odometer font in thousandths; 1000 equals 1.0x size.")
  draw3DInt("emissive_ev_deci", "Emissive EV x10", 0, 120, "Sets the emissive brightness in tenths of an exposure value.")
  draw3DBool("hide_fuel", "Hide primary fuel gauge", "Hides the primary 3D fuel-gauge element.")
  draw3DBool("hide_odo", "Hide primary odometer", "Hides the primary 3D odometer digits.")
  draw3DBool("hide_odo_frame", "Hide primary odometer frame", "Hides the frame behind the primary 3D odometer.")
  draw3DBool("hide_fuel_alt", "Hide alternate fuel gauge", "Hides the alternate 3D fuel-gauge element.")
  draw3DBool("hide_odo_alt", "Hide alternate odometer", "Hides the alternate 3D odometer digits.")
  draw3DBool("hide_odo_alt_frame", "Hide alternate odometer frame", "Hides the frame behind the alternate 3D odometer.")

  draw3DPlacement("fuel", "Primary fuel gauge")
  draw3DPlacement("odo", "Primary odometer")
  draw3DPlacement("fuel_alt", "Alternate fuel gauge")
  draw3DPlacement("odo_alt", "Alternate odometer")

  ImGui.Separator()
  local save3DPressed = ImGui.Button("Save vehicle 3D setup##vm3d_save_vehicle")
  drawTooltip("Persists the current preview as this vehicle's active 3D setup.")
  if save3DPressed then
    setMessage(invoke("SaveCurrent3D", "3D setup save failed."))
  end
  ImGui.SameLine()
  local reload3DPressed = ImGui.Button("Reload saved##vm3d_reload_vehicle")
  drawTooltip("Discards unsaved preview edits and reloads this vehicle's saved 3D setup.")
  if reload3DPressed then
    setMessage(invoke("ReloadCurrent3D", "3D setup reload failed."))
  end
  ImGui.SameLine()
  local defaults3DPressed = ImGui.Button("Preview defaults##vm3d_default_vehicle")
  drawTooltip("Loads default values into the live preview without saving them.")
  if defaults3DPressed then
    setMessage(invoke("ResetCurrent3DPreview", "3D setup reset failed."))
  end
  drawPresetControls()
end

local function drawWorldInt(objectName, key, label, minimum, maximum, description)
  local value = invoke("GetWorldInt", 0, objectName, key)
  local changed, nextValue = takeSliderInt(label .. "##vmworld_" .. objectName .. "_" .. key, value, minimum, maximum, worldDefaults[objectName][key])
  drawTooltip(description, true)
  if changed then invoke("SetWorldInt", false, objectName, key, nextValue) end
end

local function drawWorldBool(objectName, key, label, description)
  local value = invoke("GetWorldBool", false, objectName, key)
  local changed, nextValue = takeCheckbox(label .. "##vmworld_" .. objectName .. "_" .. key, value, worldDefaults[objectName][key])
  drawTooltip(description, true)
  if changed then invoke("SetWorldBool", false, objectName, key, nextValue) end
end

local function drawWorldObject(objectName, title)
  ImGui.Text(title)
  drawWorldInt(objectName, "theme", "Theme", 0, 9, "Selects the color theme used by this 3D World display.")
  drawWorldInt(objectName, "font", "Font", 0, 13, "Selects the font used by this 3D World display.")
  drawWorldInt(objectName, "font_size", "Font size", 8, 120, "Sets the text size used by this 3D World display.")
  drawWorldInt(objectName, "brightness", "Brightness (milli)", 0, 3000, "Sets display brightness in thousandths; 1000 is the normal level.")
  drawWorldInt(objectName, "scale", "Scale (milli)", 1, 3000, "Scales the display in thousandths; 1000 equals 1.0x size.")
  drawWorldInt(objectName, "x", "X offset", -7000, 7000, "Moves this display horizontally by the configured offset.")
  drawWorldInt(objectName, "y", "Y offset", -7000, 7000, "Moves this display vertically by the configured offset.")
  drawWorldBool(objectName, "hidden", "Hide object", "Hides this complete 3D World display.")
  drawWorldBool(objectName, "border_hidden", "Hide border", "Hides only the border around this 3D World display.")
end

local function drawWorldTab()
  drawWorldObject("lb", "3D World leaderboard")
  ImGui.Separator()
  local saveWorldPressed = ImGui.Button("Save 3D World settings##vmworld_save")
  drawTooltip("Persists the 3D World leaderboard settings to vm_settings.json.")
  if saveWorldPressed then
    setMessage(invoke("SaveSettingsFromOverlay", "3D World settings save failed."))
  end
end

local function drawDeveloperTab()
  ImGui.Text("Location editor")
  ImGui.TextWrapped("Locations use the mounted vehicle position, or the player position when on foot. Changes are written by REDscript and applied immediately.")

  ImGui.Separator()
  ImGui.Text(("Gas points: %d"):format(invoke("GetGasPointCount", 0)))
  local _, gasRadius = takeInputFloat(
    "Gas radius (m)##vm_dev_gas_radius",
    VM.devGasRadius,
    0.1,
    "%.1f",
    2.0
  )
  drawTooltip("Sets the activation radius stored for the new gas point.", true)
  VM.devGasRadius = gasRadius

  local addGasPressed = ImGui.Button("Add gas point here##vm_dev_add_gas")
  drawTooltip("Adds a gas point at the mounted vehicle position, or at the player position when on foot.")
  if addGasPressed then
    setMessage(invoke("DevAddGasLocation", "Gas-point creation failed.", VM.devGasRadius))
  end
  ImGui.SameLine()
  local removeGasPressed = ImGui.Button("Remove nearest gas point (5 m)##vm_dev_remove_gas")
  drawTooltip("Removes the nearest gas point when it is within five meters in the XY plane.")
  if removeGasPressed then
    setMessage(invoke("DevRemoveGasLocation", "Gas-point removal failed.", 5.0))
  end

  ImGui.Separator()
  ImGui.Text(("Repair zones: %d"):format(invoke("GetRepairPointCount", 0)))
  local _, repairRadius = takeInputFloat(
    "Repair radius (m)##vm_dev_repair_radius",
    VM.devRepairRadius,
    0.1,
    "%.1f",
    3.0
  )
  drawTooltip("Sets the activation radius stored for the new repair zone.", true)
  VM.devRepairRadius = repairRadius

  local _, repairPrice = takeInputFloat(
    "Base repair price##vm_dev_repair_price",
    VM.devRepairPrice,
    50.0,
    "%.0f",
    500.0
  )
  drawTooltip("Sets the base E$ repair price before the gameplay price adjustment is applied.", true)
  VM.devRepairPrice = repairPrice

  ImGui.Text("Repair FX world nodes")
  for i = 1, 10 do
    local _, fxPath = takeInputText(
      ("FX node %d##vm_dev_repair_fx_%d"):format(i, i),
      VM.devRepairFx[i] or "",
      256
    )
    drawTooltip("Stores the world-state node path used for this repair-bay FX stage. Leave it empty when unused.")
    VM.devRepairFx[i] = fxPath
  end

  local addRepairPressed = ImGui.Button("Add repair zone here##vm_dev_add_repair")
  drawTooltip("Adds a repair zone at the mounted vehicle or player position and stores the player's current facing rotation.")
  if addRepairPressed then
    setMessage(invoke(
      "DevAddRepairLocation",
      "Repair-zone creation failed.",
      VM.devRepairRadius,
      math.max(0, math.floor(VM.devRepairPrice + 0.5)),
      VM.devRepairFx[1] or "",
      VM.devRepairFx[2] or "",
      VM.devRepairFx[3] or "",
      VM.devRepairFx[4] or "",
      VM.devRepairFx[5] or "",
      VM.devRepairFx[6] or "",
      VM.devRepairFx[7] or "",
      VM.devRepairFx[8] or "",
      VM.devRepairFx[9] or "",
      VM.devRepairFx[10] or ""
    ))
  end
  ImGui.SameLine()
  local removeRepairPressed = ImGui.Button("Remove nearest repair zone (5 m)##vm_dev_remove_repair")
  drawTooltip("Removes the nearest repair zone when it is within five meters in the XY plane.")
  if removeRepairPressed then
    setMessage(invoke("DevRemoveRepairLocation", "Repair-zone removal failed.", 5.0))
  end
end

registerForEvent("onInit", function()
  resolveWindowHost()
  importLegacyJson()
  invoke("Refresh3DPresets", 0)
  setMessage(invoke("GetStatus", VM.message))
end)

registerForEvent("onOverlayOpen", function()
  resolveWindowHost()
  VM.overlayOpen = true
  VM.specLabel = ""
  importLegacyJson()
  invoke("Refresh3DPresets", 0)
end)

registerForEvent("onOverlayClose", function()
  invoke("SaveSettingsFromOverlay", "")
  VM.overlayOpen = false
end)

registerForEvent("onDraw", function()
  if not VM.overlayOpen then return end
  if not windowHost.Begin("Immersive Odometer and Fuel System") then
    windowHost.End()
    return
  end

  if not bridge() then
    ImGui.Text("REDscript bridge unavailable.")
    ImGui.Text("Check r6/logs/redscript_rCURRENT.log for compilation errors.")
    windowHost.End()
    return
  end

  if ImGui.BeginTabBar("VM_Redscript_Overlay_Tabs") then
    if ImGui.BeginTabItem("Status") then drawStatusTab(); ImGui.EndTabItem() end
    if ImGui.BeginTabItem("Settings") then drawSettingsTab(); ImGui.EndTabItem() end
    if ImGui.BeginTabItem("Vehicle") then drawVehicleTab(); ImGui.EndTabItem() end
    if ImGui.BeginTabItem("3D Setup") then draw3DTab(); ImGui.EndTabItem() end
    if ImGui.BeginTabItem("3D World") then drawWorldTab(); ImGui.EndTabItem() end
    if DEV_LOCATION_EDITOR and ImGui.BeginTabItem("Developer") then drawDeveloperTab(); ImGui.EndTabItem() end
    ImGui.EndTabBar()
  end

  ImGui.Separator()
  if ImGui.TextDisabled then ImGui.TextDisabled(VM.message) else ImGui.Text(VM.message) end
  windowHost.End()
end)

-- Public API v1 for other CET mods. Obtain this table with
-- GetMod("VehicleMileage") and use dot-call syntax.
function PublicAPI.GetVersion()
  return 1
end

function PublicAPI.IsAvailable()
  return invoke("IsReady", false)
end

function PublicAPI.HasMountedVehicle()
  return invoke("HasMountedVehicle", false)
end

function PublicAPI.GetMountedVehicleLabel()
  return tostring(invoke("GetMountedLabel", ""))
end

function PublicAPI.IsFuelSystemEnabled()
  return invoke("IsFuelSystemEnabled", false)
end

function PublicAPI.CanModifyFuel()
  return invoke("CanModifyFuel", false)
end

function PublicAPI.GetMeters()
  return invoke("GetCurrentMeters", 0)
end

function PublicAPI.GetFuelPercent()
  return invoke("GetCurrentFuelPercent", 0.0)
end

function PublicAPI.GetFuelLiters()
  return invoke("GetCurrentFuelLiters", 0.0)
end

function PublicAPI.GetTankCapacityLiters()
  return invoke("GetCurrentTankCapacityLiters", 0.0)
end

function PublicAPI.DrainFuel(liters)
  local amount = tonumber(liters)
  if not amount or amount ~= amount or amount <= 0.0 then return 0.0 end
  return invoke("DrainFuel", 0.0, amount)
end

function PublicAPI.Refuel(liters)
  local amount = tonumber(liters)
  if not amount or amount ~= amount or amount <= 0.0 then return 0.0 end
  return invoke("Refuel", 0.0, amount)
end

return PublicAPI
