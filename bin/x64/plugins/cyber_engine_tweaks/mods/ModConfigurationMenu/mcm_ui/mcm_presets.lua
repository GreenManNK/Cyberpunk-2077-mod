local Text = require("mcm_ui/mcm_text")

local Workflow = {}

local function valuesEqual(left, right)
  if type(left) ~= type(right) then
    return false
  end
  if type(left) ~= "table" then
    return left == right
  end

  for key, value in pairs(left) do
    if not valuesEqual(value, right[key]) then
      return false
    end
  end
  for key in pairs(right) do
    if left[key] == nil then
      return false
    end
  end
  return true
end

function Workflow.attach(Model)
  function Model:refreshPresets()
    local runtime = self.runtime
    local state = runtime.state
    local api = state.api
    local modKey = state.route.modKey or state.selectedModKey or state.rememberedModKey
    if api == nil or type(api.listModPresets) ~= "function" or modKey == nil then
      state.presets = {}
      return false
    end

    local presets, err = api.listModPresets(modKey)
    if type(presets) ~= "table" then
      state.presets = {}
      runtime:setStatus(err or runtime:t("error.presets_unavailable"), "error")
      return false
    end

    state.presets = presets
    local selectedExists = false
    for _, preset in ipairs(presets) do
      if preset.id == state.selectedPresetId then
        selectedExists = true
        break
      end
    end
    if not selectedExists then
      state.selectedPresetId = presets[1] and presets[1].id or nil
    end
    self:refreshPresetPreview()
    return true
  end

  function Model:selectedPreset()
    local state = self.runtime.state
    for _, preset in ipairs(state.presets or {}) do
      if preset.id == state.selectedPresetId then
        return preset
      end
    end
    return nil
  end

  function Model:selectPreset(preset)
    local state = self.runtime.state
    if preset == nil then
      return
    end
    state.selectedPresetId = preset.id
    state.route.presetId = preset.id
    state.scrollPositions.preset_settings_scroll = 0
    self:refreshPresetPreview()
    self.runtime:queueRender()
  end

  function Model:refreshPresetPreview()
    local runtime = self.runtime
    local state = runtime.state
    local api = state.api
    if api == nil or type(api.previewModPreset) ~= "function" or state.selectedPresetId == nil then
      state.presetPreview = nil
      return false
    end

    local preview, err = api.previewModPreset(state.selectedPresetId)
    state.presetPreview = preview
    if preview == nil then
      runtime:setStatus(err or runtime:t("error.preset_preview"), "error")
      return false
    end
    return true
  end

  function Model:previewValue(valueType, value, metadata)
    local runtime = self.runtime
    if value == nil then
      return "—"
    end
    if valueType == "bool" then
      return value == true and runtime:t("common.on") or runtime:t("common.off")
    end
    if valueType == "float" then
      return Text.number(value, metadata and metadata.step)
    end
    if valueType == "select" and type(metadata and metadata.elements) == "table" then
      local index = tonumber(value)
      if index ~= nil then
        local label = metadata.elements[math.floor(index)]
        if label ~= nil then
          return runtime:safe(label)
        end
      end
    end
    return runtime:safe(value)
  end

  function Model:requestConfirmation(key, message, callback, kind, options)
    local runtime = self.runtime
    options = options or {}
    runtime.state.pendingConfirmation = {
      key = key,
      message = message,
      callback = callback,
      kind = kind or "warning",
      title = options.title,
      confirmLabel = options.confirmLabel,
      secondaryLabel = options.secondaryLabel,
      secondaryCallback = options.secondaryCallback,
    }
    runtime:setStatus(message, "info")
    runtime:queueRender()
  end

  function Model:confirmPendingAction()
    local runtime = self.runtime
    local confirmation = runtime.state.pendingConfirmation
    if confirmation == nil then
      return
    end

    runtime.state.pendingConfirmation = nil
    local ok, err = pcall(confirmation.callback)
    if not ok then
      runtime:setStatus(tostring(err), "error")
    end
    runtime:queueRender()
  end

  function Model:cancelPendingAction()
    local runtime = self.runtime
    runtime.state.pendingConfirmation = nil
    runtime:setStatus(runtime:currentApiStatus(), "info")
    runtime:queueRender()
  end

  function Model:runPendingSecondaryAction()
    local runtime = self.runtime
    local confirmation = runtime.state.pendingConfirmation
    if confirmation == nil or type(confirmation.secondaryCallback) ~= "function" then
      return
    end

    runtime.state.pendingConfirmation = nil
    local ok, err = pcall(confirmation.secondaryCallback)
    if not ok then
      runtime:setStatus(tostring(err), "error")
    end
    runtime:queueRender()
  end

  function Model:resolvePendingDrafts(continuation)
    local runtime = self.runtime
    local state = runtime.state
    local modKey = state.selectedModKey
    if modKey == nil or not self:hasDrafts(modKey) then
      if type(continuation) == "function" then
        continuation()
      end
      return false
    end

    local mod = self:selectedMod()
    local modName = runtime:safe(mod and mod.name or modKey)
    local function continueAfter(action)
      local resolved = action(modKey)
      if resolved == true and not self:hasDrafts(modKey) and type(continuation) == "function" then
        continuation()
      end
    end

    self:requestConfirmation(
      "resolve_drafts:" .. tostring(modKey),
      runtime:t("drafts.leave_prompt", { mod = modName }),
      function()
        continueAfter(function(key)
          return self:apply(key)
        end)
      end,
      "warning",
      {
        title = runtime:t("drafts.leave_title"),
        confirmLabel = runtime:t("action.apply"),
        secondaryLabel = runtime:t("action.discard"),
        secondaryCallback = function()
          continueAfter(function(key)
            return self:revert(key)
          end)
        end,
      }
    )
    return true
  end

  function Model:presetPreviewRows()
    local runtime = self.runtime
    local state = runtime.state
    local preview = state.presetPreview
    if preview == nil then
      return {}
    end

    local settingById = {}
    local categoryByKey = {}
    if state.api ~= nil and state.route.modKey ~= nil then
      local categories = runtime:first(state.api.listCategories, state.route.modKey) or {}
      for _, category in ipairs(categories) do
        categoryByKey[category.key] = category.name or category.key
        for _, setting in ipairs(category.settings or {}) do
          settingById[setting.id] = setting
        end
      end
    end

    local grouped = {}
    local categoryOrder = {}
    for _, row in ipairs(preview.rows or {}) do
      local setting = settingById[row.settingId]
      local include = row.status ~= "matches"
        or (preview.preset and preview.preset.virtualKind == "current")
      if
        include
        and state.presetNonDefaultOnly
        and setting ~= nil
        and setting.defaultValue ~= nil
        and valuesEqual(row.presetValue, setting.defaultValue)
      then
        include = false
      end
      if include then
        local categoryKey = row.categoryKey or "unknown"
        if grouped[categoryKey] == nil then
          grouped[categoryKey] = {}
          categoryOrder[#categoryOrder + 1] = categoryKey
        end
        grouped[categoryKey][#grouped[categoryKey] + 1] = {
          kind = "preview",
          categoryName = row.categoryName,
          label = row.label or (setting and setting.label) or row.settingKey or row.settingId,
          currentValue = self:previewValue(row.valueType, row.currentValue, row),
          targetValue = self:previewValue(row.valueType, row.presetValue, row),
          status = row.status,
        }
      end
    end

    local result = {}
    for _, categoryKey in ipairs(categoryOrder) do
      result[#result + 1] = {
        kind = "category",
        label = categoryByKey[categoryKey]
          or (grouped[categoryKey][1] and grouped[categoryKey][1].categoryName)
          or categoryKey,
      }
      for _, row in ipairs(grouped[categoryKey]) do
        result[#result + 1] = row
      end
    end
    if #result == 0 then
      result[#result + 1] = {
        kind = "message",
        label = runtime:t("presets.matches_current"),
      }
    end
    return result
  end

  function Model:createPreset(name)
    local runtime = self.runtime
    local state = runtime.state
    local mod = self:selectedMod()
    if mod == nil or state.api == nil then
      return
    end

    name = tostring(name or ""):match("^%s*(.-)%s*$")
    if name == "" then
      name = runtime:t("presets.default_name", { index = #state.presets + 1 })
    end

    local preset, err = state.api.createModPreset(mod.key, { name = name })
    runtime:setStatus(runtime:currentApiStatus(err), preset ~= nil and "success" or "error")
    if preset ~= nil then
      state.selectedPresetId = preset.id
      self:refreshPresets()
    end
    runtime:queueRender()
  end

  function Model:updatePresetFromCurrent()
    local runtime = self.runtime
    local state = runtime.state
    local preset = self:selectedPreset()
    if preset == nil or preset.virtual == true then
      return
    end

    local updated, err = state.api.updateModPreset(preset.id, { captureCurrent = true })
    runtime:setStatus(runtime:currentApiStatus(err), updated ~= nil and "success" or "error")
    if updated ~= nil then
      self:refreshPresets()
    end
    runtime:queueRender()
  end

  function Model:duplicatePreset(name)
    local runtime = self.runtime
    local state = runtime.state
    local preset = self:selectedPreset()
    if preset == nil then
      return
    end

    name = tostring(name or ""):match("^%s*(.-)%s*$")
    if name == "" then
      name = runtime:t("presets.copy_name", { name = runtime:safe(preset.name) })
    end

    local copy, err = state.api.duplicateModPreset(preset.id, { name = name })
    runtime:setStatus(runtime:currentApiStatus(err), copy ~= nil and "success" or "error")
    if copy ~= nil then
      state.selectedPresetId = copy.id
      self:refreshPresets()
    end
    runtime:queueRender()
  end

  function Model:renamePreset(name)
    local runtime = self.runtime
    local state = runtime.state
    local preset = self:selectedPreset()
    if preset == nil or preset.virtual == true then
      return
    end

    name = tostring(name or ""):match("^%s*(.-)%s*$")
    if name == "" then
      name = preset.name
    end

    local updated, err = state.api.updateModPreset(preset.id, { name = name })
    runtime:setStatus(runtime:currentApiStatus(err), updated ~= nil and "success" or "error")
    if updated ~= nil then
      self:refreshPresets()
    end
    runtime:queueRender()
  end

  function Model:deletePreset()
    local runtime = self.runtime
    local state = runtime.state
    local preset = self:selectedPreset()
    if preset == nil or preset.virtual == true then
      return
    end

    local references = {}
    if type(state.api.getPresetReferences) == "function" then
      local listed, referenceError = state.api.getPresetReferences(preset.id)
      if type(listed) ~= "table" then
        runtime:setStatus(referenceError or runtime:t("error.preset_references"), "error")
        runtime:queueRender()
        return
      end
      references = listed
    end

    local message = runtime:t("presets.delete_prompt", { name = runtime:safe(preset.name) })
    if #references > 0 then
      message = runtime:t("presets.delete_linked_prompt", {
        name = runtime:safe(preset.name),
        count = #references,
      })
    end

    self:requestConfirmation("delete_preset:" .. tostring(preset.id), message, function()
      local ok, err = state.api.deleteModPreset(preset.id, {
        detachLinked = #references > 0,
      })
      runtime:setStatus(runtime:currentApiStatus(err), ok and "success" or "error")
      if ok then
        state.selectedPresetId = nil
        self:refreshPresets()
      end
      runtime:queueRender()
    end, "error")
  end

  function Model:applySelectedPreset()
    local runtime = self.runtime
    local state = runtime.state
    local preset = self:selectedPreset()
    if preset == nil then
      return
    end

    local ok, err = state.api.applyModPreset(preset.id)
    runtime:setStatus(runtime:currentApiStatus(err), ok and "success" or "error")
    if ok then
      self:refreshPresets()
    end
    runtime:queueRender()
  end
end

return Workflow
