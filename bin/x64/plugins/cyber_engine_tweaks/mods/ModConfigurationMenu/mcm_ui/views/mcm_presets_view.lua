local ModPresetsView = {}

function ModPresetsView.render(surface, controller)
  local runtime = surface.runtime
  local state = runtime.state
  local entries = {}

  for _, preset in ipairs(state.presets or {}) do
    local rowPreset = preset
    local label = runtime:safe(rowPreset.name)
    if rowPreset.virtual == true then
      label = runtime:t("presets.virtual." .. runtime:safe(rowPreset.virtualKind))
    end
    entries[#entries + 1] = {
      label = label,
      description = runtime:safe(rowPreset.description),
      selected = rowPreset.id == state.selectedPresetId,
      callback = function()
        runtime.model:selectPreset(rowPreset)
      end,
    }
  end

  surface:sidebar(controller, runtime:t("sidebar.presets"), entries, "presets_scroll", false)

  local mod = runtime.model:selectedMod()
  if mod == nil then
    surface:content(controller, {
      { kind = "message", label = runtime:t("error.select_mod_for_presets") },
    }, "preset_settings_scroll")
    return runtime:t("empty.title"), nil
  end

  surface:content(controller, runtime.model:presetPreviewRows(), "preset_settings_scroll")

  local selected = runtime.model:selectedPreset()
  local userPreset = selected ~= nil and selected.virtual ~= true
  local canApply = selected ~= nil and selected.virtualKind ~= "current"
  surface:renderActionRows(controller, {
    {
      label = runtime:t("presets.action.new"),
      callback = function()
        surface:openTextPrompt({
          title = runtime:t("presets.new"),
          message = runtime:t("presets.name_prompt", { mod = runtime:safe(mod.name) }),
          placeholder = runtime:t("presets.name_prompt", { mod = runtime:safe(mod.name) }),
          confirmLabel = runtime:t("action.create"),
          submit = function(value)
            runtime.model:createPreset(value)
          end,
        })
      end,
    },
    {
      label = runtime:t("presets.action.duplicate"),
      visible = selected ~= nil,
      callback = function()
        surface:openTextPrompt({
          title = runtime:t("presets.duplicate"),
          message = runtime:t("presets.duplicate_prompt"),
          placeholder = runtime:t("presets.duplicate_prompt"),
          value = runtime:t("presets.copy_name", { name = runtime:safe(selected.name) }),
          confirmLabel = runtime:t("action.create"),
          submit = function(value)
            runtime.model:duplicatePreset(value)
          end,
        })
      end,
    },
    {
      label = runtime:t("action.rename"),
      visible = userPreset,
      callback = function()
        surface:openTextPrompt({
          title = runtime:t("presets.rename"),
          message = runtime:t("presets.rename_prompt"),
          placeholder = runtime:t("presets.rename_prompt"),
          value = runtime:safe(selected.name),
          confirmLabel = runtime:t("action.rename"),
          submit = function(value)
            runtime.model:renamePreset(value)
          end,
        })
      end,
    },
    {
      label = runtime:t("presets.update"),
      visible = userPreset,
      callback = function()
        runtime.model:updatePresetFromCurrent()
      end,
    },
    {
      label = runtime:t("action.delete"),
      visible = userPreset,
      callback = function()
        runtime.model:deletePreset()
      end,
    },
    {
      label = runtime:t("action.apply"),
      visible = canApply,
      active = canApply,
      callback = function()
        runtime.model:applySelectedPreset()
      end,
    },
  })

  return runtime:safe(mod.name), mod
end

return ModPresetsView
