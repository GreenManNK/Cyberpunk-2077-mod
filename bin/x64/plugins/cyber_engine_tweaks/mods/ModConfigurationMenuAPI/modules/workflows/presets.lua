local Workflow = {}

local function copy(value)
  if type(value) ~= "table" then
    return value
  end

  local result = {}
  for key, item in pairs(value) do
    result[key] = copy(item)
  end
  return result
end

local function snapshotWithSettings(snapshot, settings)
  local result = copy(snapshot)
  result.settings = {}
  for _, item in ipairs(settings or {}) do
    result.settings[#result.settings + 1] = copy(item)
  end
  result.settingCount = #result.settings
  return result
end

local function rowName(row)
  return tostring(row.label or row.settingKey or row.settingId or "unknown setting")
end

local function unavailableMessage(rows)
  local names = {}
  for index, row in ipairs(rows or {}) do
    if index > 4 then
      break
    end
    names[#names + 1] = rowName(row)
  end
  local suffix = ""
  if #(rows or {}) > #names then
    suffix = string.format(" and %d more", #rows - #names)
  end
  return "Snapshot settings are not currently available: " .. table.concat(names, ", ") .. suffix
end

function Workflow.attach(Core, context)
  local Catalog = context.Catalog
  local Defaults = context.Defaults
  local Drafts = context.Drafts
  local Snapshots = context.Snapshots
  local state = context.state
  local events = context.events
  local presets = context.presets
  local collections = context.collections
  local setStatus = context.setStatus
  local loadedMod = context.loadedMod
  local loadModForRead = context.loadModForRead
  local dynamicSnapshots = context.dynamicSnapshots
  local logWarning = context.logWarning

  local snapshotCatalog = {
    findSetting = function(settingId)
      return Catalog.findSetting(state.catalog, settingId)
    end,
  }

  local snapshotDrafts = {
    get = function(setting)
      return Drafts.get(state.drafts, setting)
    end,
    set = function(setting, value)
      return Drafts.set(state.drafts, setting, value)
    end,
  }

  local function prepareSnapshot(snapshot)
    if dynamicSnapshots == nil then
      return snapshot
    end
    local prepared, prepareError = dynamicSnapshots:annotate(snapshot)
    if prepareError ~= nil and type(logWarning) == "function" then
      logWarning(
        "Dynamic snapshot metadata could not be loaded for "
          .. tostring(snapshot and snapshot.sourceModName)
          .. ": "
          .. tostring(prepareError)
      )
    end
    return prepared or snapshot
  end

  local function previewSnapshot(snapshot)
    snapshot = prepareSnapshot(snapshot)
    local preview = Snapshots.preview(snapshot, snapshotCatalog, snapshotDrafts)
    if dynamicSnapshots == nil then
      return preview
    end

    for index, row in ipairs(preview.rows or {}) do
      local item = (snapshot.settings or {})[index]
      if row.status == "missing" and item ~= nil and type(item.revealSettingId) == "string" then
        local value, found = dynamicSnapshots:observedValue(snapshot.sourceModKey, item.settingId)
        if found then
          row.currentValue = value
        end
        row.status = "deferred"
        row.dynamicDeferred = true
        preview.summary.missing = math.max(0, preview.summary.missing - 1)
        preview.summary.deferred = (preview.summary.deferred or 0) + 1
      end
    end
    preview.compatible = preview.summary.missing == 0
      and preview.summary.readOnly == 0
      and preview.summary.invalid == 0
    return preview
  end

  local function captureLoadedMod(mod, options)
    if mod == nil or mod.loaded ~= true then
      return nil, "Mod settings are not loaded."
    end

    local snapshot = Snapshots.capture(mod, snapshotDrafts, options)
    if
      (mod.capabilities or {}).dynamicSchema == true
      and snapshot.captureMode ~= "rollback"
      and dynamicSnapshots ~= nil
    then
      local completed, cacheError = dynamicSnapshots:complete(snapshot)
      if cacheError ~= nil and type(logWarning) == "function" then
        logWarning(
          "Dynamic snapshot cache could not be updated for "
            .. tostring(mod.name)
            .. ": "
            .. tostring(cacheError)
        )
      end
      snapshot = completed or snapshot
    end

    return snapshot, nil
  end

  local function mergeRollbackSnapshot(seed, captured, settingIds, metadataBySettingId)
    local rollback = seed ~= nil and copy(seed) or snapshotWithSettings(captured, {})
    rollback.captureMode = "rollback"
    rollback.settings = rollback.settings or {}

    local seen = {}
    for _, item in ipairs(rollback.settings) do
      seen[item.settingId] = true
    end
    local rollbackSettingIds = copy(settingIds or {})
    for settingId in pairs(settingIds or {}) do
      local metadata = (metadataBySettingId or {})[settingId]
      if metadata ~= nil and metadata.revealSettingId ~= nil then
        rollbackSettingIds[metadata.revealSettingId] = true
      end
    end
    for _, item in ipairs(captured.settings or {}) do
      if rollbackSettingIds[item.settingId] == true and seen[item.settingId] ~= true then
        local rollbackItem = copy(item)
        local metadata = (metadataBySettingId or {})[item.settingId]
        if metadata ~= nil and metadata.revealSettingId ~= nil then
          rollbackItem.revealSettingId = metadata.revealSettingId
          rollbackItem.revealValue = copy(metadata.revealValue)
        end
        rollback.settings[#rollback.settings + 1] = rollbackItem
        seen[item.settingId] = true
      end
    end
    table.sort(rollback.settings, function(left, right)
      return tostring(left.settingId) < tostring(right.settingId)
    end)
    rollback.settingCount = #rollback.settings
    return rollback
  end

  local function runSnapshotApply(snapshot, options)
    options = options or {}
    snapshot = prepareSnapshot(snapshot)
    local mod = Catalog.findMod(state.catalog, snapshot and snapshot.sourceModKey)
    if mod == nil then
      return nil, "Snapshot mod is not installed: " .. tostring(snapshot and snapshot.sourceModName)
    end
    if mod.loaded ~= true then
      local _, openError = Core.openMod(mod.key)
      if openError ~= nil and mod.loaded ~= true then
        return nil, openError
      end
    end

    local dynamicSchema = (mod.capabilities or {}).dynamicSchema == true
    local allowUnresolved = options.allowUnresolved == true
    local rollback = options.rollbackSnapshot ~= nil and copy(options.rollbackSnapshot) or nil
    local appliedSettingIds = {}
    local appliedSettingIdSet = {}
    local resolvedDependentIds = {}
    local skippedDependentIds = {}
    local attemptedRevealGroups = {}
    local snapshotItemsById = {}
    local dependentsByControllerId = {}
    for _, item in ipairs(snapshot.settings or {}) do
      snapshotItemsById[item.settingId] = item
      if type(item.revealSettingId) == "string" and item.revealValue ~= nil then
        dependentsByControllerId[item.revealSettingId] = dependentsByControllerId[item.revealSettingId]
          or {}
        dependentsByControllerId[item.revealSettingId][#dependentsByControllerId[item.revealSettingId] + 1] =
          item
      end
    end
    local maximumPasses = math.max(1, math.min(128, #(snapshot.settings or {}) * 2 + 4))

    local function revealGroupKey(item)
      return table.concat({
        tostring(item.revealSettingId),
        type(item.revealValue),
        tostring(item.revealValue),
      }, "\31")
    end

    local function rememberApplied(settingId)
      if appliedSettingIdSet[settingId] ~= true then
        appliedSettingIds[#appliedSettingIds + 1] = settingId
        appliedSettingIdSet[settingId] = true
      end
    end

    for pass = 1, maximumPasses do
      local preview = Snapshots.preview(snapshot, snapshotCatalog, snapshotDrafts)
      local changes = {}
      local changeIds = {}
      local missing = {}
      local unavailable = {}
      local rowsBySettingId = {}

      for index, row in ipairs(preview.rows or {}) do
        rowsBySettingId[row.settingId] = row
        local item = (snapshot.settings or {})[index]
        if item ~= nil and item.revealSettingId ~= nil and row.status == "matches" then
          resolvedDependentIds[item.settingId] = true
        end
      end

      local function controllerMustRemainRevealed(controllerSettingId)
        for _, dependent in ipairs(dependentsByControllerId[controllerSettingId] or {}) do
          if
            resolvedDependentIds[dependent.settingId] ~= true
            and appliedSettingIdSet[dependent.settingId] ~= true
            and skippedDependentIds[dependent.settingId] ~= true
          then
            local dependentRow = rowsBySettingId[dependent.settingId]
            if
              dependentRow ~= nil
              and (dependentRow.status == "change" or dependentRow.status == "missing")
            then
              return true
            end
          end
        end
        return false
      end

      for index, row in ipairs(preview.rows or {}) do
        local item = (snapshot.settings or {})[index]
        if item ~= nil and row.status == "change" then
          if
            dependentsByControllerId[item.settingId] == nil
            or not controllerMustRemainRevealed(item.settingId)
          then
            changes[#changes + 1] = item
            changeIds[item.settingId] = true
          end
        elseif
          row.status == "missing"
          and not (
            dynamicSchema
            and (
              appliedSettingIdSet[row.settingId]
              or resolvedDependentIds[row.settingId]
              or skippedDependentIds[row.settingId]
            )
          )
        then
          missing[#missing + 1] = row
          unavailable[#unavailable + 1] = row
        elseif row.status ~= "matches" and row.status ~= "missing" then
          unavailable[#unavailable + 1] = row
        end
      end

      if #changes == 0 and dynamicSchema then
        local revealItem = nil
        for _, row in ipairs(missing) do
          local dependent = snapshotItemsById[row.settingId]
          if
            dependent ~= nil
            and dependent.revealSettingId ~= nil
            and dependent.revealValue ~= nil
            and attemptedRevealGroups[revealGroupKey(dependent)] ~= true
          then
            revealItem = dependent
            break
          end
        end

        if revealItem ~= nil then
          local controller = snapshotItemsById[revealItem.revealSettingId]
          if controller == nil then
            return nil,
              "Snapshot has no controller for dynamic setting " .. rowName(revealItem) .. ".",
              rollback
          end

          local temporaryController = copy(controller)
          temporaryController.value = copy(revealItem.revealValue)
          local temporarySnapshot = snapshotWithSettings(snapshot, { temporaryController })
          local revealPreview =
            Snapshots.preview(temporarySnapshot, snapshotCatalog, snapshotDrafts)
          local revealRow = (revealPreview.rows or {})[1]
          attemptedRevealGroups[revealGroupKey(revealItem)] = true
          if revealRow ~= nil and revealRow.status == "change" then
            changes[1] = temporaryController
            changeIds[temporaryController.settingId] = true
          elseif revealRow == nil or revealRow.status ~= "matches" then
            return nil,
              "Could not reveal dynamic setting "
                .. rowName(revealItem)
                .. ": "
                .. unavailableMessage({
                  revealRow or revealItem,
                }),
              rollback
          elseif not allowUnresolved then
            return nil,
              "The saved controller value did not reveal dynamic setting "
                .. rowName(revealItem)
                .. ".",
              rollback
          end
        end
      end

      if #unavailable > 0 and not allowUnresolved then
        local onlyDynamicMissing = dynamicSchema and #missing == #unavailable
        if not onlyDynamicMissing or #changes == 0 then
          return nil, unavailableMessage(unavailable), rollback
        end
      end

      if #changes == 0 then
        local skippedNewDependent = false
        if allowUnresolved then
          for _, row in ipairs(missing) do
            local item = snapshotItemsById[row.settingId]
            if item ~= nil and item.revealSettingId ~= nil then
              skippedDependentIds[item.settingId] = true
              skippedNewDependent = true
            end
          end
        end

        if not skippedNewDependent then
          local resolvedSettingIds = {}
          for _, row in ipairs(preview.rows or {}) do
            if
              row.status == "matches"
              or appliedSettingIdSet[row.settingId] == true
              or resolvedDependentIds[row.settingId] == true
            then
              resolvedSettingIds[#resolvedSettingIds + 1] = row.settingId
            end
          end
          return {
            ok = true,
            passes = pass - 1,
            appliedSettingIds = appliedSettingIds,
            resolvedSettingIds = resolvedSettingIds,
            unresolvedRows = unavailable,
            rollbackSnapshot = rollback,
          },
            nil,
            rollback
        end
      end

      if #changes > 0 and options.captureRollback ~= false then
        local captured = Snapshots.capture(mod, snapshotDrafts, { captureMode = "rollback" })
        rollback = mergeRollbackSnapshot(rollback, captured, changeIds, snapshotItemsById)
      end

      if #changes > 0 then
        local staged, stageError =
          Snapshots.stage(snapshotWithSettings(snapshot, changes), snapshotCatalog, snapshotDrafts)
        if staged == nil then
          return nil, "Could not stage snapshot values: " .. tostring(stageError), rollback
        end

        local applied, applyError = Core.apply(mod.key)
        if not applied then
          return nil, applyError, rollback
        end
        for _, item in ipairs(changes) do
          rememberApplied(item.settingId)
        end
      end
    end

    return nil, "Dynamic settings did not stabilize within the bounded apply passes.", rollback
  end

  local function applySnapshot(snapshot, options)
    options = options or {}
    local result, applyError, rollback = runSnapshotApply(snapshot, options)
    if result ~= nil then
      return result, nil
    end

    if state.drafts.dirtyModKey ~= nil then
      Core.revert(state.drafts.dirtyModKey)
    end
    if
      options.rollbackOnFailure ~= false
      and rollback ~= nil
      and #(rollback.settings or {}) > 0
    then
      local restored, restoreError = runSnapshotApply(rollback, {
        allowUnresolved = false,
        captureRollback = false,
        rollbackOnFailure = false,
      })
      if restored == nil then
        return nil,
          tostring(applyError) .. " Automatic rollback also failed: " .. tostring(restoreError)
      end
    end
    return nil, applyError
  end

  local function virtualPresetId(kind, modKey)
    return "virtual-" .. tostring(kind) .. ":" .. tostring(modKey)
  end

  local function virtualPreset(kind, mod)
    local snapshot, err = captureLoadedMod(mod, {
      defaults = kind == "defaults",
      captureMode = kind,
    })
    if snapshot == nil then
      return nil, err
    end

    snapshot.schemaVersion = 1
    snapshot.id = virtualPresetId(kind, mod.key)
    snapshot.revision = mod.schemaRevision or mod.revision or 0
    snapshot.name = string.upper(kind)
    snapshot.description = ""
    snapshot.virtual = true
    snapshot.virtualKind = kind
    snapshot.createdAt = nil
    snapshot.updatedAt = nil
    return snapshot, nil
  end

  local function parseVirtualPreset(presetId)
    local currentPrefix = "virtual-current:"
    local defaultsPrefix = "virtual-defaults:"
    if string.sub(tostring(presetId), 1, #currentPrefix) == currentPrefix then
      return "current", string.sub(tostring(presetId), #currentPrefix + 1)
    end
    if string.sub(tostring(presetId), 1, #defaultsPrefix) == defaultsPrefix then
      return "defaults", string.sub(tostring(presetId), #defaultsPrefix + 1)
    end
    return nil, nil
  end

  local function resolvePreset(presetId)
    local kind, modKey = parseVirtualPreset(presetId)
    if kind ~= nil then
      local mod, loadError = loadedMod(modKey)
      if mod == nil then
        return nil, loadError
      end
      return virtualPreset(kind, mod)
    end

    local preset, presetError = presets:get(presetId)
    if preset == nil then
      return nil, presetError
    end
    return prepareSnapshot(preset), nil
  end

  function Core.listModPresets(modKey)
    local mod, err = loadedMod(modKey)
    if mod == nil then
      return {}, err
    end

    local result = {}
    local current = virtualPreset("current", mod)
    if current ~= nil then
      result[#result + 1] = current
    end

    local coverage = Defaults.coverage(state.drafts, mod)
    if coverage.resettable > 0 then
      local defaults = virtualPreset("defaults", mod)
      if defaults ~= nil then
        result[#result + 1] = defaults
      end
    end

    local stored, listError = presets:list(mod.key)
    if stored == nil then
      return result, listError
    end
    for _, preset in ipairs(stored) do
      result[#result + 1] = preset
    end
    return result, nil
  end

  function Core.getModPreset(presetId)
    return resolvePreset(presetId)
  end

  function Core.createModPreset(modKey, options)
    local mod, err = loadedMod(modKey)
    if mod == nil then
      return nil, err
    end

    local snapshot, captureError = captureLoadedMod(mod, options)
    if snapshot == nil then
      return nil, captureError
    end

    local preset, createError = presets:create(snapshot, options)
    if preset ~= nil then
      setStatus("Created preset " .. tostring(preset.name) .. ".")
      events.emit("presets.changed", { modKey = mod.key, preset = preset, action = "created" })
    end
    return preset, createError
  end

  function Core.updateModPreset(presetId, options)
    options = options or {}
    local current, readError = presets:get(presetId)
    if current == nil then
      return nil, readError
    end

    local snapshot = nil
    if options.captureCurrent == true then
      local mod, modError = loadedMod(current.sourceModKey)
      if mod == nil then
        return nil, modError
      end
      snapshot = captureLoadedMod(mod, options)
    end

    local preset, updateError = presets:update(presetId, snapshot, options)
    if preset ~= nil then
      setStatus("Updated preset " .. tostring(preset.name) .. ".")
      events.emit(
        "presets.changed",
        { modKey = preset.sourceModKey, preset = preset, action = "updated" }
      )
    end
    return preset, updateError
  end

  function Core.duplicateModPreset(presetId, options)
    options = options or {}
    local source, sourceError = resolvePreset(presetId)
    if source == nil then
      return nil, sourceError
    end

    local name = options.name or (tostring(source.name) .. " Copy")
    local preset, createError = presets:create(source, {
      name = name,
      description = options.description ~= nil and options.description or source.description,
    })
    if preset ~= nil then
      setStatus("Created preset " .. tostring(preset.name) .. ".")
      events.emit(
        "presets.changed",
        { modKey = preset.sourceModKey, preset = preset, action = "created" }
      )
    end
    return preset, createError
  end

  function Core.getPresetReferences(presetId)
    local kind = parseVirtualPreset(presetId)
    if kind ~= nil then
      return {}, nil
    end
    return collections:linkedPresetReferences(presetId)
  end

  function Core.deleteModPreset(presetId, options)
    options = options or {}
    local preset, readError = presets:get(presetId)
    if preset == nil then
      return false, readError
    end

    local references, referenceError = collections:linkedPresetReferences(presetId)
    if references == nil then
      return false, referenceError
    end
    if #references > 0 and options.detachLinked ~= true then
      return false,
        string.format(
          "Preset is linked by %d collection(s). Detach those entries before deleting it.",
          #references
        )
    end
    if #references > 0 then
      local detached, detachError = collections:detachPresetReferences(presetId)
      if detached == nil then
        return false, detachError
      end
    end

    local deleted, deleteError = presets:delete(presetId)
    if deleted then
      setStatus("Deleted preset " .. tostring(preset.name) .. ".")
      events.emit(
        "presets.changed",
        { modKey = preset.sourceModKey, presetId = presetId, action = "deleted" }
      )
    end
    return deleted, deleteError
  end

  function Core.previewModPreset(presetId)
    local preset, presetError = resolvePreset(presetId)
    if preset == nil then
      return nil, presetError
    end

    local mod = Catalog.findMod(state.catalog, preset.sourceModKey)
    if mod == nil then
      return {
        preset = preset,
        compatible = false,
        summary = { total = #(preset.settings or {}), missingMod = 1 },
        rows = {},
      },
        nil
    end
    local loaded, loadError = loadModForRead(mod, "preset_preview")
    if loaded == nil then
      return nil, loadError
    end

    local preview = previewSnapshot(preset)
    preview.preset = preset
    preview.mod = Catalog.publicMod(mod)
    return preview, nil
  end

  function Core.stageModPreset(presetId)
    local preset, presetError = resolvePreset(presetId)
    if preset == nil then
      return nil, presetError
    end

    local mod = Catalog.findMod(state.catalog, preset.sourceModKey)
    if mod == nil then
      return nil, "Preset mod is not installed: " .. tostring(preset.sourceModName)
    end
    if mod.loaded ~= true then
      local _, openError = Core.openMod(mod.key)
      if openError ~= nil and mod.loaded ~= true then
        return nil, openError
      end
    end

    local result, stageError = Snapshots.stage(preset, snapshotCatalog, snapshotDrafts)
    if result == nil then
      return nil, stageError
    end

    setStatus(string.format("Staged %d value(s) from %s.", result.staged, preset.name))
    events.emit("drafts.changed", {
      modKey = mod.key,
      count = Drafts.countForMod(state.drafts, mod.key),
    })
    events.emit("preset.staged", { preset = preset, result = result })
    return result, nil
  end

  function Core.applyModPreset(presetId)
    local preset, presetError = resolvePreset(presetId)
    if preset == nil then
      return false, presetError
    end

    local applied, applyError = applySnapshot(preset)
    if applied == nil then
      return false, applyError
    end
    return true, nil
  end

  return {
    captureLoadedMod = captureLoadedMod,
    resolvePreset = resolvePreset,
    snapshotCatalog = snapshotCatalog,
    snapshotDrafts = snapshotDrafts,
    prepareSnapshot = prepareSnapshot,
    previewSnapshot = previewSnapshot,
    applySnapshot = applySnapshot,
  }
end

return Workflow
