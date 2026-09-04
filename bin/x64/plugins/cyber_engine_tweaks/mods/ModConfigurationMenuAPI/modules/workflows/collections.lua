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

function Workflow.attach(Core, context, presetWorkflow)
  local Catalog = context.Catalog
  local Defaults = context.Defaults
  local Drafts = context.Drafts
  local Logger = context.Logger
  local Storage = context.Storage
  local state = context.state
  local events = context.events
  local presets = context.presets
  local collections = context.collections
  local portableCollections = context.portableCollections
  local operations = context.operations
  local setStatus = context.setStatus
  local recordError = context.recordError
  local loadedMod = context.loadedMod
  local loadModForRead = context.loadModForRead
  local captureLoadedMod = presetWorkflow.captureLoadedMod
  local resolvePreset = presetWorkflow.resolvePreset
  local snapshotCatalog = presetWorkflow.snapshotCatalog
  local snapshotDrafts = presetWorkflow.snapshotDrafts
  local prepareSnapshot = presetWorkflow.prepareSnapshot
  local previewSnapshot = presetWorkflow.previewSnapshot
  local applySnapshot = presetWorkflow.applySnapshot

  local function restoreOriginal(operationContext)
    local restored, restoreError
    if operationContext.originalModKey ~= nil then
      restored, restoreError = Core.openMod(operationContext.originalModKey)
    else
      restored, restoreError = Core.closeMod()
    end
    if not restored then
      error("Could not restore the original MCM mod: " .. tostring(restoreError))
    end
  end

  function Core.listCollections()
    return collections:list()
  end

  function Core.getCollection(collectionId)
    return collections:get(collectionId, true)
  end

  function Core.createCollection(options)
    local collection, err = collections:create(options)
    if collection ~= nil then
      setStatus("Created collection " .. tostring(collection.name) .. ".")
      events.emit("collections.changed", { collection = collection, action = "created" })
    elseif err ~= nil then
      recordError("Collection creation failed: " .. tostring(err))
    end
    return collection, err
  end

  function Core.updateCollection(collectionId, options)
    local collection, err = collections:update(collectionId, options)
    if collection ~= nil then
      setStatus("Updated collection " .. tostring(collection.name) .. ".")
      events.emit("collections.changed", { collection = collection, action = "updated" })
    end
    return collection, err
  end

  function Core.deleteCollection(collectionId)
    local collection, _, metadataError = collections:findMetadata(collectionId)
    if collection == nil then
      return false, metadataError
    end

    local deleted, deleteError = collections:delete(collectionId)
    if deleted then
      setStatus("Deleted collection " .. tostring(collection.name) .. ".")
      events.emit(
        "collections.changed",
        { collectionId = collectionId, collection = collection, action = "deleted" }
      )
    end
    return deleted, deleteError
  end

  local function collectionEntryFromSnapshot(snapshot, options)
    options = options or {}
    return {
      id = Storage.component(snapshot.sourceModKey),
      providerId = snapshot.providerId,
      sourceModId = snapshot.sourceModId,
      sourceModKey = snapshot.sourceModKey,
      sourceModName = snapshot.sourceModName,
      sourceModVersion = snapshot.sourceModVersion,
      bindingMode = options.bindingMode == "linked" and "linked" or "snapshot",
      sourcePresetId = options.sourcePresetId,
      sourcePresetRevision = options.sourcePresetRevision,
      sourcePresetName = options.sourcePresetName,
      captureMode = snapshot.captureMode,
      settings = snapshot.settings,
      settingCount = #(snapshot.settings or {}),
    }
  end

  local function resolveCollectionEntry(entry)
    if entry.bindingMode ~= "linked" or entry.sourcePresetId == nil then
      return entry, nil
    end

    local preset, err = presets:get(entry.sourcePresetId)
    if preset == nil then
      local missing = {}
      for key, value in pairs(entry) do
        missing[key] = value
      end
      missing.status = "missing_preset"
      missing.error = err
      return missing, err
    end

    local resolved = collectionEntryFromSnapshot(preset, {
      bindingMode = "linked",
      sourcePresetId = preset.id,
      sourcePresetRevision = preset.revision,
      sourcePresetName = preset.name,
    })
    resolved.id = entry.id
    return resolved, nil
  end

  local function canonicalIdentifier(value)
    return string.lower(tostring(value or ""):gsub("[^%w]", ""))
  end

  local function resolveInstalledMod(entry)
    local exact = Catalog.findMod(state.catalog, entry.sourceModKey)
    if exact ~= nil then
      return exact
    end

    local expected = canonicalIdentifier(entry.sourceModId)
    if expected == "" then
      return nil
    end

    local match = nil
    for _, modKey in ipairs(state.catalog.providerModKeys[entry.providerId] or {}) do
      local candidate = Catalog.findMod(state.catalog, modKey)
      if candidate ~= nil and canonicalIdentifier(candidate.sourceId) == expected then
        if match ~= nil then
          return nil
        end
        match = candidate
      end
    end
    return match
  end

  local function snapshotSettingIdentity(item, sourceModKey)
    local sourceId = tostring(item.settingId or "")
    local prefix = tostring(sourceModKey or "") .. ":"
    if sourceId:sub(1, #prefix) == prefix then
      sourceId = sourceId:sub(#prefix + 1)
    end

    local duplicate = sourceId:match(":duplicate:(%d+)$") or "1"
    sourceId = sourceId:gsub(":duplicate:%d+$", "")
    return table.concat({
      canonicalIdentifier(sourceId),
      duplicate,
      tostring(item.valueType or ""),
    }, ":")
  end

  local function catalogSettingIdentity(setting)
    local sourceId = tostring(setting.sourceId or "")
    local duplicate = sourceId:match(":duplicate:(%d+)$") or "1"
    sourceId = sourceId:gsub(":duplicate:%d+$", "")
    return table.concat({
      canonicalIdentifier(sourceId),
      duplicate,
      tostring(setting.type or ""),
    }, ":")
  end

  local function rebindCollectionEntry(entry, mod)
    if entry.sourceModKey == mod.key then
      return entry, nil
    end

    local loaded, loadError = loadModForRead(mod, "collection_identity_migration")
    if loaded == nil then
      return nil, loadError
    end

    local currentSettings = {}
    local currentCategoryNames = {}
    for _, category in ipairs(mod.categories or {}) do
      currentCategoryNames[category.key] = category.name
      for _, setting in ipairs(category.settings or {}) do
        currentSettings[catalogSettingIdentity(setting)] = setting
      end
    end

    local rebound = {}
    for key, value in pairs(entry) do
      rebound[key] = value
    end
    rebound.providerId = mod.provider
    rebound.sourceModId = mod.sourceId
    rebound.sourceModKey = mod.key
    rebound.sourceModName = mod.name
    rebound.settings = {}
    local reboundSettingIds = {}

    for _, item in ipairs(entry.settings or {}) do
      local setting = currentSettings[snapshotSettingIdentity(item, entry.sourceModKey)]
      if setting == nil then
        return nil,
          "Could not migrate setting " .. tostring(item.settingKey or item.settingId) .. "."
      end

      local reboundItem = {
        settingId = setting.id,
        settingKey = setting.key,
        categoryKey = setting.categoryKey,
        categoryName = currentCategoryNames[setting.categoryKey],
        label = setting.label,
        valueType = setting.type,
        value = item.value,
        elements = setting.type == "select" and copy(setting.elements) or nil,
        step = setting.step,
        format = setting.format,
        isHold = setting.isHold == true,
      }
      rebound.settings[#rebound.settings + 1] = reboundItem
      reboundSettingIds[item.settingId] = setting.id
    end
    for index, item in ipairs(entry.settings or {}) do
      if item.revealSettingId ~= nil then
        local reboundControllerId = reboundSettingIds[item.revealSettingId]
        if reboundControllerId == nil then
          return nil,
            "Could not migrate dynamic controller " .. tostring(item.revealSettingId) .. "."
        end
        rebound.settings[index].revealSettingId = reboundControllerId
        rebound.settings[index].revealValue = copy(item.revealValue)
      end
    end
    rebound.settingCount = #rebound.settings
    Logger.info(
      string.format(
        "Migrated collection identity %s to %s.",
        tostring(entry.sourceModKey),
        tostring(mod.key)
      )
    )
    return rebound, nil
  end

  local function prepareCollectionEntry(entry)
    local mod = resolveInstalledMod(entry)
    if mod == nil then
      return nil, nil
    end
    local rebound, rebindError = rebindCollectionEntry(entry, mod)
    if rebound == nil then
      Logger.warn(
        string.format(
          "Collection identity migration failed for %s: %s",
          tostring(entry.sourceModKey),
          tostring(rebindError)
        )
      )
      return nil, rebindError
    end
    return rebound, nil
  end

  local function portableCompatibility(entry)
    local prepared = prepareCollectionEntry(entry)
    if prepared ~= nil then
      return "ready"
    end
    local providerState = state.providerStates[entry.providerId]
    if providerState == nil or providerState.detected ~= true or providerState.ready ~= true then
      return "provider_unavailable"
    end
    return "missing"
  end

  function Core.getPortableCollectionDirectory()
    return portableCollections:displayDirectory(), nil
  end

  function Core.listPortableCollections()
    return portableCollections:list()
  end

  function Core.inspectPortableCollection(fileName)
    local package, readError, summary = portableCollections:read(fileName)
    if package == nil then
      return nil, readError
    end

    local result = {
      fileName = fileName,
      path = portableCollections:path(fileName),
      directory = portableCollections:displayDirectory(),
      name = package.collection.name,
      description = package.collection.description,
      exportedAt = package.exportedAt,
      mcmVersion = package.mcmVersion,
      entryCount = summary.entryCount,
      settingCount = summary.settingCount,
      entries = {},
      counts = {
        ready = 0,
        missing = 0,
        provider_unavailable = 0,
      },
    }
    for _, entry in ipairs(package.entries) do
      local status = portableCompatibility(entry)
      result.counts[status] = (result.counts[status] or 0) + 1
      result.entries[#result.entries + 1] = {
        providerId = entry.providerId,
        sourceModId = entry.sourceModId,
        sourceModKey = entry.sourceModKey,
        sourceModName = entry.sourceModName,
        sourceModVersion = entry.sourceModVersion,
        settingCount = #(entry.settings or {}),
        status = status,
      }
    end
    return result, nil
  end

  function Core.exportCollection(collectionId)
    local collection, collectionError = collections:get(collectionId, true)
    if collection == nil then
      return nil, collectionError
    end

    local entries = {}
    for _, entry in ipairs(collection.entries or {}) do
      if entry.status == "invalid" then
        return nil, "Collection contains an unreadable entry: " .. tostring(entry.id)
      end
      local resolved, resolveError = resolveCollectionEntry(entry)
      if resolveError ~= nil then
        return nil,
          "Collection entry could not resolve its linked preset: " .. tostring(resolveError)
      end
      local prepared = prepareCollectionEntry(resolved)
      entries[#entries + 1] = prepareSnapshot(prepared or resolved)
    end

    local result, exportError = portableCollections:export(collection, entries)
    if result ~= nil then
      setStatus(
        "Exported "
          .. tostring(collection.name)
          .. " to "
          .. tostring(result.directory)
          .. "/"
          .. tostring(result.fileName)
          .. "."
      )
    else
      recordError("Collection export failed: " .. tostring(exportError))
    end
    return result, exportError
  end

  function Core.importPortableCollection(fileName)
    local collection, importError = portableCollections:import(fileName, collections)
    if collection ~= nil then
      setStatus("Imported collection " .. tostring(collection.name) .. ".")
      events.emit("collections.changed", { collection = collection, action = "imported" })
    else
      recordError("Collection import failed: " .. tostring(importError))
    end
    return collection, importError
  end

  function Core.deletePortableCollection(fileName)
    local deleted, deleteError = portableCollections:delete(fileName)
    if deleted then
      setStatus("Deleted portable Collection " .. tostring(fileName) .. ".")
    else
      recordError("Portable Collection deletion failed: " .. tostring(deleteError))
    end
    return deleted, deleteError
  end

  function Core.putCollectionEntry(collectionId, modKey, options)
    options = options or {}
    local snapshot = nil
    local preset = nil

    if options.presetId ~= nil then
      preset = resolvePreset(options.presetId)
      if preset == nil then
        return nil, "Could not resolve preset: " .. tostring(options.presetId)
      end
      if preset.sourceModKey ~= modKey then
        return nil, "Preset belongs to another mod."
      end
      snapshot = preset
    else
      local mod, modError = loadedMod(modKey)
      if mod == nil then
        return nil, modError
      end
      snapshot = captureLoadedMod(mod, {
        defaults = options.defaults == true,
        captureMode = options.defaults == true and "defaults" or "full",
      })
    end

    snapshot = prepareSnapshot(snapshot)
    local entry = collectionEntryFromSnapshot(snapshot, {
      bindingMode = options.bindingMode,
      sourcePresetId = preset ~= nil and preset.virtual ~= true and preset.id or nil,
      sourcePresetRevision = preset ~= nil and preset.revision or nil,
      sourcePresetName = preset ~= nil and preset.name or nil,
    })
    local stored, storeError = collections:putEntry(collectionId, entry)
    if stored ~= nil then
      setStatus("Stored " .. tostring(stored.sourceModName) .. " in the collection.")
      events.emit(
        "collections.changed",
        { collectionId = collectionId, entry = stored, action = "entry_updated" }
      )
    end
    return stored, storeError
  end

  function Core.removeCollectionEntry(collectionId, entryId)
    local removed, err = collections:removeEntry(collectionId, entryId)
    if removed then
      setStatus("Removed collection entry.")
      events.emit(
        "collections.changed",
        { collectionId = collectionId, entryId = entryId, action = "entry_removed" }
      )
    end
    return removed, err
  end

  function Core.previewCollectionEntry(collectionId, entryId)
    local collection, collectionError = collections:get(collectionId, true)
    if collection == nil then
      return nil, collectionError
    end

    local entry = nil
    for _, candidate in ipairs(collection.entries or {}) do
      if candidate.id == entryId then
        entry = candidate
        break
      end
    end
    if entry == nil then
      return nil, "Unknown collection entry: " .. tostring(entryId)
    end

    local resolved, resolveError = resolveCollectionEntry(entry)
    if resolveError ~= nil then
      return { entry = resolved, compatible = false, rows = {}, summary = { missingPreset = 1 } },
        nil
    end

    local prepared = prepareCollectionEntry(resolved)
    local mod = prepared ~= nil and Catalog.findMod(state.catalog, prepared.sourceModKey) or nil
    if mod == nil then
      return {
        entry = resolved,
        compatible = false,
        rows = {},
        summary = { total = #(resolved.settings or {}), missingMod = 1 },
      },
        nil
    end
    local loaded, loadError = loadModForRead(mod, "collection_preview")
    if loaded == nil then
      return nil, loadError
    end

    local preview = previewSnapshot(prepared)
    preview.entry = prepared
    preview.mod = Catalog.publicMod(mod)
    return preview, nil
  end

  function Core.captureCurrentSetup(options)
    options = options or {}
    if state.drafts.dirtyModKey ~= nil then
      return nil, "Apply or revert pending changes before capturing a collection."
    end

    local collectionId = options.collectionId
    local createdCollection = false
    local originalCollection = nil
    if collectionId == nil then
      local name = options.name or ("Baseline - " .. os.date("%Y-%m-%d %H-%M-%S"))
      local collection, createError = collections:create({
        name = name,
        description = options.description,
      })
      if collection == nil then
        return nil, createError
      end
      collectionId = collection.id
      createdCollection = true
    else
      local collectionError = nil
      originalCollection, collectionError = collections:get(collectionId, true)
      if originalCollection == nil then
        return nil, collectionError
      end
    end

    local selectedProviders = {}
    for _, providerId in ipairs(options.providerIds or {}) do
      selectedProviders[tostring(providerId)] = true
    end
    local requestedKeys = {}
    for _, modKey in ipairs(options.modKeys or {}) do
      requestedKeys[tostring(modKey)] = true
    end

    local mods = {}
    for _, mod in ipairs(Catalog.listMods(state.catalog)) do
      local providerAllowed = next(selectedProviders) == nil
        or selectedProviders[tostring(mod.provider)] == true
      local modAllowed = next(requestedKeys) == nil or requestedKeys[mod.key] == true
      if providerAllowed and modAllowed then
        mods[#mods + 1] = mod
      end
    end

    local originalEntriesByModKey = {}
    for _, entry in ipairs((originalCollection and originalCollection.entries) or {}) do
      local installedMod = resolveInstalledMod(entry)
      local lookupKey = installedMod ~= nil and installedMod.key or entry.sourceModKey
      if lookupKey ~= nil then
        if originalEntriesByModKey[lookupKey] ~= nil then
          return nil, "Collection contains multiple entries for mod: " .. tostring(lookupKey)
        end
        originalEntriesByModKey[lookupKey] = entry
      end
    end

    local originalModKey = state.activeModKey
    local updatingCollection = options.updateExistingCollection == true
    local context = {
      collectionId = collectionId,
      mods = mods,
      index = 0,
      originalModKey = originalModKey,
      originalEntriesByModKey = originalEntriesByModKey,
      nonDefaultOnly = options.nonDefaultOnly == true,
      captured = 0,
      updated = 0,
      added = 0,
      skipped = 0,
      createdCollection = createdCollection,
      changes = {},
    }

    local function rollbackCapture(operationContext)
      if operationContext.createdCollection == true then
        local deleted, deleteError = collections:delete(operationContext.collectionId)
        if not deleted then
          error("Could not discard the new collection: " .. tostring(deleteError))
        end
        return
      end

      local rollbackErrors = {}
      for changeIndex = #operationContext.changes, 1, -1 do
        local change = operationContext.changes[changeIndex]
        if change.original ~= nil then
          local restored, restoreError =
            collections:putEntry(operationContext.collectionId, change.original)
          if restored == nil then
            rollbackErrors[#rollbackErrors + 1] = tostring(restoreError)
          end
        else
          local removed, removeError =
            collections:removeEntry(operationContext.collectionId, change.entryId)
          if not removed then
            rollbackErrors[#rollbackErrors + 1] = tostring(removeError)
          end
        end
      end

      if #rollbackErrors > 0 then
        error("Collection capture rollback failed: " .. table.concat(rollbackErrors, "; "))
      end
    end

    local function cleanupCapture(operationContext)
      local cleanupErrors = {}
      local rolledBack, rollbackError = pcall(rollbackCapture, operationContext)
      if not rolledBack then
        cleanupErrors[#cleanupErrors + 1] = "rollback: " .. tostring(rollbackError)
      end

      local restored, restoreError = pcall(restoreOriginal, operationContext)
      if not restored then
        cleanupErrors[#cleanupErrors + 1] = "lifecycle: " .. tostring(restoreError)
      end

      if #cleanupErrors > 0 then
        error("Collection capture cleanup failed: " .. table.concat(cleanupErrors, "; "))
      end
    end

    local function progressMessage(operationContext)
      local verb = updatingCollection and "Updating collection" or "Reading settings"
      return string.format("%s %d / %d", verb, operationContext.index, #operationContext.mods)
    end

    local operation, operationError = operations:start({
      kind = updatingCollection and "update_collection" or "capture_collection",
      total = #mods,
      message = string.format(
        "%s 0 / %d",
        updatingCollection and "Updating collection" or "Reading settings",
        #mods
      ),
      context = context,
      cancel = function(operationContext)
        cleanupCapture(operationContext)
      end,
      failed = function(operationContext)
        cleanupCapture(operationContext)
      end,
      step = function(operationContext, operationState)
        operationContext.index = operationContext.index + 1
        local mod = operationContext.mods[operationContext.index]
        if mod == nil then
          restoreOriginal(operationContext)
          local result = {
            collectionId = operationContext.collectionId,
            captured = operationContext.captured,
            updated = operationContext.updated,
            added = operationContext.added,
            skipped = operationContext.skipped,
          }
          local message = nil
          if updatingCollection then
            message = string.format(
              "Updated %d mod snapshot(s), added %d, and skipped %d.",
              operationContext.updated,
              operationContext.added,
              operationContext.skipped
            )
          else
            message = string.format(
              "Captured %d mod(s); skipped %d.",
              operationContext.captured,
              operationContext.skipped
            )
          end
          return true, result, message
        end

        local _, openError = Core.openMod(mod.key)
        local loaded = Catalog.findMod(state.catalog, mod.key)
        if openError ~= nil and (loaded == nil or loaded.loaded ~= true) then
          operationContext.skipped = operationContext.skipped + 1
          operationState.current = operationContext.index
          Logger.warn(
            string.format(
              "Skipping %s during collection capture: %s",
              tostring(mod.name or mod.key),
              tostring(openError)
            )
          )
          return nil, nil, progressMessage(operationContext)
        end
        if loaded == nil or loaded.loaded ~= true then
          operationContext.skipped = operationContext.skipped + 1
          operationState.current = operationContext.index
          Logger.warn(
            string.format(
              "Skipping %s during collection capture because its loaded schema is unavailable.",
              tostring(mod.name or mod.key)
            )
          )
          return nil, nil, progressMessage(operationContext)
        end
        if operationContext.nonDefaultOnly then
          local coverage = Defaults.coverage(state.drafts, loaded)
          if coverage.nonDefault == 0 then
            operationContext.skipped = operationContext.skipped + 1
            operationState.current = operationContext.index
            return nil, nil, progressMessage(operationContext)
          end
        end

        local snapshot, snapshotError = captureLoadedMod(loaded, { captureMode = "full" })
        if snapshot == nil then
          operationContext.skipped = operationContext.skipped + 1
          operationState.current = operationContext.index
          Logger.warn(
            string.format(
              "Skipping %s during collection capture: %s",
              tostring(loaded.name or loaded.key),
              tostring(snapshotError or "snapshot unavailable")
            )
          )
          return nil, nil, progressMessage(operationContext)
        end
        local entry = collectionEntryFromSnapshot(snapshot, {})
        local originalEntry = operationContext.originalEntriesByModKey[loaded.key]
        if originalEntry ~= nil then
          entry.id = originalEntry.id
        end
        local stored, storeError = collections:putEntry(operationContext.collectionId, entry)
        if stored == nil then
          return false, storeError, "Collection capture failed."
        end

        operationContext.changes[#operationContext.changes + 1] = {
          entryId = stored.id,
          original = originalEntry,
        }
        operationContext.captured = operationContext.captured + 1
        if originalEntry ~= nil then
          operationContext.updated = operationContext.updated + 1
        else
          operationContext.added = operationContext.added + 1
        end
        operationState.current = operationContext.index
        return nil, nil, progressMessage(operationContext)
      end,
    })
    if operation == nil then
      rollbackCapture(context)
      return nil, operationError
    end

    events.emit("operation.started", { operation = operation })
    return { operationId = operation.id, collectionId = collectionId }, nil
  end

  function Core.updateCollectionFromCurrent(collectionId)
    return Core.captureCurrentSetup({
      collectionId = collectionId,
      updateExistingCollection = true,
    })
  end

  local function missingCollectionEntries(collection)
    local result = {}
    for _, entry in ipairs(collection.entries or {}) do
      if
        entry.sourceModKey ~= nil
        and entry.status ~= "invalid"
        and resolveInstalledMod(entry) == nil
      then
        result[#result + 1] = entry
      end
    end
    return result
  end

  local function copyEntryWithSettings(entry, settings)
    local result = {}
    for key, value in pairs(entry or {}) do
      result[key] = value
    end
    result.settings = settings or {}
    result.settingCount = #result.settings
    return result
  end

  local function cleanupPreservedItem(entry, reason, err, settingCount)
    return {
      entryId = entry.id,
      modKey = entry.sourceModKey,
      modName = entry.sourceModName,
      providerId = entry.providerId,
      settingCount = settingCount or #(entry.settings or {}),
      reason = reason,
      error = err,
    }
  end

  local function buildCollectionCleanupPlan(collection)
    local plan = {
      collectionId = collection.id,
      collectionName = collection.name,
      missingMods = {},
      missingSettings = {},
      preserved = {},
      counts = {
        mods = 0,
        settings = 0,
        preserved = 0,
      },
      changes = {},
    }

    for _, storedEntry in ipairs(collection.entries or {}) do
      if storedEntry.status == "invalid" then
        plan.preserved[#plan.preserved + 1] = cleanupPreservedItem(storedEntry, "invalid_entry")
      else
        local resolved, resolveError = resolveCollectionEntry(storedEntry)
        if resolveError ~= nil then
          plan.preserved[#plan.preserved + 1] =
            cleanupPreservedItem(storedEntry, "missing_preset", resolveError)
        else
          local mod = resolveInstalledMod(resolved)
          if mod == nil then
            local providerState = state.providerStates[resolved.providerId]
            if
              providerState == nil
              or (
                providerState.detected == true
                and providerState.ready == true
                and providerState.stale ~= true
              )
            then
              local missingMod = cleanupPreservedItem(resolved, "missing_mod")
              plan.missingMods[#plan.missingMods + 1] = missingMod
              plan.changes[#plan.changes + 1] = {
                action = "remove",
                original = storedEntry,
              }
            else
              plan.preserved[#plan.preserved + 1] = cleanupPreservedItem(
                resolved,
                "provider_unavailable",
                providerState and providerState.error or nil
              )
            end
          elseif storedEntry.bindingMode == "linked" then
            plan.preserved[#plan.preserved + 1] = cleanupPreservedItem(storedEntry, "linked_preset")
          else
            local prepared, prepareError = prepareCollectionEntry(resolved)
            if prepared == nil then
              plan.preserved[#plan.preserved + 1] =
                cleanupPreservedItem(storedEntry, "migration_unavailable", prepareError)
            else
              local loaded, loadError = loadModForRead(mod, "collection_cleanup_preview")
              if loaded == nil then
                plan.preserved[#plan.preserved + 1] =
                  cleanupPreservedItem(storedEntry, "mod_unavailable", loadError)
              else
                local preview = previewSnapshot(prepared)
                if (mod.capabilities or {}).dynamicSchema == true then
                  local uncertain = 0
                  for _, row in ipairs(preview.rows or {}) do
                    if row.status == "missing" or row.status == "deferred" then
                      uncertain = uncertain + 1
                    end
                  end
                  if uncertain > 0 then
                    plan.preserved[#plan.preserved + 1] =
                      cleanupPreservedItem(storedEntry, "dynamic_schema", nil, uncertain)
                  end
                else
                  local retained = {}
                  local removed = {}
                  for index, row in ipairs(preview.rows or {}) do
                    local item = (prepared.settings or {})[index]
                    if item ~= nil and row.status == "missing" then
                      local missingSetting = {
                        entryId = storedEntry.id,
                        modKey = prepared.sourceModKey,
                        modName = prepared.sourceModName,
                        settingId = row.settingId,
                        settingKey = row.settingKey,
                        label = row.label,
                      }
                      plan.missingSettings[#plan.missingSettings + 1] = missingSetting
                      removed[#removed + 1] = missingSetting
                    elseif item ~= nil then
                      retained[#retained + 1] = item
                    end
                  end
                  if #removed > 0 then
                    plan.changes[#plan.changes + 1] = {
                      action = "rewrite",
                      original = storedEntry,
                      updated = copyEntryWithSettings(prepared, retained),
                      removedSettings = #removed,
                    }
                  end
                end
              end
            end
          end
        end
      end
    end

    plan.counts.mods = #plan.missingMods
    plan.counts.settings = #plan.missingSettings
    plan.counts.preserved = #plan.preserved
    return plan
  end

  local function publicCleanupPlan(plan)
    return {
      collectionId = plan.collectionId,
      collectionName = plan.collectionName,
      missingMods = copy(plan.missingMods),
      missingSettings = copy(plan.missingSettings),
      preserved = copy(plan.preserved),
      counts = copy(plan.counts),
    }
  end

  function Core.inspectCollectionCleanup(collectionId)
    if not state.indexLoaded then
      return nil, "Index is not loaded."
    end

    local collection, collectionError = collections:get(collectionId, true)
    if collection == nil then
      return nil, collectionError
    end
    return publicCleanupPlan(buildCollectionCleanupPlan(collection)), nil
  end

  function Core.cleanCollectionUnavailableContent(collectionId)
    if not state.indexLoaded then
      return nil, "Index is not loaded."
    end

    local collection, collectionError = collections:get(collectionId, true)
    if collection == nil then
      return nil, collectionError
    end

    -- Rebuild immediately before mutation so a stale UI preview cannot choose the targets.
    local plan = buildCollectionCleanupPlan(collection)
    if #plan.changes == 0 then
      return nil, "Collection has no definitively unavailable content."
    end

    local context = {
      collectionId = collectionId,
      collectionName = collection.name,
      changes = plan.changes,
      index = 0,
      completed = {},
      removedMods = 0,
      removedSettings = 0,
      preserved = plan.counts.preserved,
    }

    local function restoreCleanup(operationContext)
      local restoreErrors = {}
      for changeIndex = #operationContext.completed, 1, -1 do
        local restored, restoreError = collections:putEntry(
          operationContext.collectionId,
          operationContext.completed[changeIndex].original
        )
        if restored == nil then
          restoreErrors[#restoreErrors + 1] = tostring(restoreError)
        end
      end
      if #restoreErrors > 0 then
        error("Collection cleanup rollback failed: " .. table.concat(restoreErrors, "; "))
      end
    end

    local operation, operationError = operations:start({
      kind = "clean_collection",
      total = #plan.changes,
      message = string.format("Cleaning collection 0 / %d", #plan.changes),
      context = context,
      cancel = restoreCleanup,
      failed = restoreCleanup,
      step = function(operationContext, operationState)
        operationContext.index = operationContext.index + 1
        local change = operationContext.changes[operationContext.index]
        if change == nil then
          return true,
            {
              collectionId = operationContext.collectionId,
              removedMods = operationContext.removedMods,
              removedSettings = operationContext.removedSettings,
              preserved = operationContext.preserved,
            },
            string.format(
              "Removed %d unavailable mod(s) and %d removed setting(s) from %s.",
              operationContext.removedMods,
              operationContext.removedSettings,
              operationContext.collectionName
            )
        end

        local changed, changeError
        if change.action == "remove" then
          changed, changeError =
            collections:removeEntry(operationContext.collectionId, change.original.id)
          if changed then
            operationContext.removedMods = operationContext.removedMods + 1
          end
        else
          changed, changeError = collections:putEntry(operationContext.collectionId, change.updated)
          if changed ~= nil then
            operationContext.removedSettings = operationContext.removedSettings
              + (change.removedSettings or 0)
          end
        end
        if not changed then
          return false, changeError, "Collection cleanup failed."
        end

        operationContext.completed[#operationContext.completed + 1] = change
        operationState.current = operationContext.index
        return nil,
          nil,
          string.format(
            "Cleaning collection %d / %d",
            operationContext.index,
            #operationContext.changes
          )
      end,
    })
    if operation == nil then
      return nil, operationError
    end

    events.emit("operation.started", { operation = operation })
    return {
      operationId = operation.id,
      collectionId = collectionId,
      plan = publicCleanupPlan(plan),
    },
      nil
  end

  function Core.listMissingCollectionEntries(collectionId)
    if not state.indexLoaded then
      return {}, "Index is not loaded."
    end

    local collection, collectionError = collections:get(collectionId, true)
    if collection == nil then
      return {}, collectionError
    end
    return missingCollectionEntries(collection), nil
  end

  function Core.cleanMissingCollectionEntries(collectionId)
    if not state.indexLoaded then
      return nil, "Index is not loaded."
    end

    local collection, collectionError = collections:get(collectionId, true)
    if collection == nil then
      return nil, collectionError
    end

    local missing = missingCollectionEntries(collection)
    if #missing == 0 then
      return nil, "Collection has no unavailable mod entries."
    end

    local context = {
      collectionId = collectionId,
      collectionName = collection.name,
      entries = missing,
      index = 0,
      removed = {},
    }

    local function restoreRemoved(operationContext)
      local restoreErrors = {}
      for entryIndex = #operationContext.removed, 1, -1 do
        local restored, restoreError =
          collections:putEntry(operationContext.collectionId, operationContext.removed[entryIndex])
        if restored == nil then
          restoreErrors[#restoreErrors + 1] = tostring(restoreError)
        end
      end
      if #restoreErrors > 0 then
        error("Missing-entry cleanup rollback failed: " .. table.concat(restoreErrors, "; "))
      end
    end

    local operation, operationError = operations:start({
      kind = "clean_collection",
      total = #missing,
      message = string.format("Cleaning unavailable mods 0 / %d", #missing),
      context = context,
      cancel = restoreRemoved,
      failed = restoreRemoved,
      step = function(operationContext, operationState)
        operationContext.index = operationContext.index + 1
        local entry = operationContext.entries[operationContext.index]
        if entry == nil then
          return true,
            {
              collectionId = operationContext.collectionId,
              removed = #operationContext.removed,
            },
            string.format(
              "Removed %d unavailable mod(s) from %s.",
              #operationContext.removed,
              operationContext.collectionName
            )
        end

        local removed, removeError =
          collections:removeEntry(operationContext.collectionId, entry.id)
        if not removed then
          return false, removeError, "Collection cleanup failed."
        end

        operationContext.removed[#operationContext.removed + 1] = entry
        operationState.current = operationContext.index
        return nil,
          nil,
          string.format(
            "Cleaning unavailable mods %d / %d",
            operationContext.index,
            #operationContext.entries
          )
      end,
    })
    if operation == nil then
      return nil, operationError
    end

    events.emit("operation.started", { operation = operation })
    return { operationId = operation.id, collectionId = collectionId }, nil
  end

  local function newCollectionApplyResult(collectionId)
    return {
      collectionId = collectionId,
      applied = {},
      failed = nil,
      rollbackAvailable = false,
      requiresConfirmation = false,
      skipped = {
        mods = {},
        settings = {},
      },
      compatibility = {
        totalMods = 0,
        compatibleMods = 0,
        skippedMods = 0,
        totalSettings = 0,
        compatibleSettings = 0,
        skippedSettings = 0,
        missingMods = 0,
        unavailableMods = 0,
        missingPresets = 0,
        migrationFailures = 0,
        missingSettings = 0,
        readOnlySettings = 0,
        invalidSettings = 0,
      },
    }
  end

  local function skipCollectionMod(operationContext, candidate, reason, err, countKey)
    local entry = candidate.entry
    local summary = operationContext.publicResult.compatibility
    summary.skippedMods = summary.skippedMods + 1
    countKey = countKey or reason
    if summary[countKey] ~= nil then
      summary[countKey] = summary[countKey] + 1
    end
    operationContext.publicResult.skipped.mods[#operationContext.publicResult.skipped.mods + 1] = {
      modKey = entry.sourceModKey,
      modName = entry.sourceModName,
      providerId = entry.providerId,
      settingCount = #(entry.settings or {}),
      reason = reason,
      error = err,
    }
  end

  local function skipCollectionSetting(operationContext, item)
    local summary = operationContext.publicResult.compatibility
    summary.skippedSettings = summary.skippedSettings + 1
    if item.reason == "missing" then
      summary.missingSettings = summary.missingSettings + 1
    elseif item.reason == "read_only" then
      summary.readOnlySettings = summary.readOnlySettings + 1
    elseif item.reason == "invalid" then
      summary.invalidSettings = summary.invalidSettings + 1
    end
    operationContext.publicResult.skipped.settings[#operationContext.publicResult.skipped.settings + 1] =
      item
  end

  local function filterCompatibleCollectionSettings(operationContext, entry, preview, allowDeferred)
    local compatible = {}
    local deferred = {}
    local summary = operationContext.publicResult.compatibility
    local entrySettingIds = {}
    for _, item in ipairs(entry.settings or {}) do
      entrySettingIds[item.settingId] = true
    end
    for index, row in ipairs(preview.rows or {}) do
      local item = (entry.settings or {})[index]
      if item ~= nil and (row.status == "matches" or row.status == "change") then
        compatible[#compatible + 1] = item
        summary.compatibleSettings = summary.compatibleSettings + 1
      elseif item ~= nil then
        local deferredStatus = row.status == "missing" or row.status == "deferred"
        local expectedDeferred = deferredStatus
          and allowDeferred
          and type(item.revealSettingId) == "string"
          and entrySettingIds[item.revealSettingId] == true
        if deferredStatus and allowDeferred then
          compatible[#compatible + 1] = item
          deferred[item.settingId] = {
            expected = expectedDeferred,
            skippedItem = {
              modKey = entry.sourceModKey,
              modName = entry.sourceModName,
              settingId = row.settingId,
              settingKey = row.settingKey,
              label = row.label,
              reason = "missing",
              error = row.error,
            },
          }
        end
        if expectedDeferred then
          summary.compatibleSettings = summary.compatibleSettings + 1
        else
          skipCollectionSetting(operationContext, {
            modKey = entry.sourceModKey,
            modName = entry.sourceModName,
            settingId = row.settingId,
            settingKey = row.settingKey,
            label = row.label,
            reason = row.status,
            error = row.error,
          })
        end
      end
    end
    return compatible, deferred
  end

  local function reconcileDeferredCollectionSettings(operationContext, modKey, result)
    local deferred = operationContext.deferred[modKey]
    if deferred == nil or next(deferred) == nil then
      return
    end

    local resolved = {}
    for _, settingId in ipairs(result.resolvedSettingIds or {}) do
      resolved[settingId] = true
    end
    local retained = {}
    local recovered = 0
    for _, item in ipairs(operationContext.publicResult.skipped.settings or {}) do
      if
        item.modKey == modKey
        and deferred[item.settingId] ~= nil
        and deferred[item.settingId].expected ~= true
        and resolved[item.settingId] == true
      then
        recovered = recovered + 1
      else
        retained[#retained + 1] = item
      end
    end

    if recovered > 0 then
      local compatibility = operationContext.publicResult.compatibility
      operationContext.publicResult.skipped.settings = retained
      compatibility.skippedSettings = math.max(0, compatibility.skippedSettings - recovered)
      compatibility.missingSettings = math.max(0, compatibility.missingSettings - recovered)
      compatibility.compatibleSettings = compatibility.compatibleSettings + recovered
    end

    local compatibility = operationContext.publicResult.compatibility
    for settingId, deferredItem in pairs(deferred) do
      if deferredItem.expected == true and resolved[settingId] ~= true then
        compatibility.compatibleSettings = math.max(0, compatibility.compatibleSettings - 1)
        skipCollectionSetting(operationContext, deferredItem.skippedItem)
      end
    end
  end

  local function collectionOperationCleanup(operationContext)
    if state.drafts.dirtyModKey ~= nil then
      Core.revert(state.drafts.dirtyModKey)
    end
    operationContext.publicResult.rollbackAvailable = #operationContext.applied > 0
    restoreOriginal(operationContext)
  end

  local function collectionOperationStep(operationContext, operationState)
    if operationContext.phase == "preflight" then
      operationContext.index = operationContext.index + 1
      local candidate = operationContext.candidates[operationContext.index]
      if candidate == nil then
        local compatibility = operationContext.publicResult.compatibility
        local hasIncompatibilities = compatibility.skippedMods > 0
          or compatibility.skippedSettings > 0
        if hasIncompatibilities then
          restoreOriginal(operationContext)
          if compatibility.compatibleSettings > 0 then
            operationContext.publicResult.requiresConfirmation = true
            return true,
              operationContext.publicResult,
              "Collection has incompatible entries. Confirmation is required."
          end
          return true,
            operationContext.publicResult,
            "No compatible collection settings were found."
        end

        operationContext.phase = "apply"
        operationContext.index = 0
        operationState.total = #operationContext.candidates + #operationContext.entries
        return nil, nil, "Collection preflight complete."
      end

      local entry = candidate.entry
      entry = prepareSnapshot(entry)
      local compatibility = operationContext.publicResult.compatibility
      compatibility.totalMods = compatibility.totalMods + 1
      compatibility.totalSettings = compatibility.totalSettings + #(entry.settings or {})

      if candidate.reason ~= nil then
        skipCollectionMod(
          operationContext,
          candidate,
          candidate.reason,
          candidate.error,
          candidate.countKey
        )
      else
        local mod = Catalog.findMod(state.catalog, entry.sourceModKey)
        if mod == nil then
          local providerState = state.providerStates[entry.providerId]
          local reason = "missing_mod"
          local countKey = "missingMods"
          if
            providerState == nil
            or providerState.detected ~= true
            or providerState.ready ~= true
          then
            reason = "provider_unavailable"
            countKey = "unavailableMods"
          end
          skipCollectionMod(operationContext, candidate, reason, "Mod is not available.", countKey)
        else
          local _, openError = Core.openMod(mod.key)
          if openError ~= nil and mod.loaded ~= true then
            skipCollectionMod(
              operationContext,
              candidate,
              "mod_unavailable",
              openError,
              "unavailableMods"
            )
          else
            local preview = previewSnapshot(entry)
            local compatibleSettings, deferredSettings = filterCompatibleCollectionSettings(
              operationContext,
              entry,
              preview,
              (mod.capabilities or {}).dynamicSchema == true
            )
            if #compatibleSettings > 0 then
              local compatibleEntry = copyEntryWithSettings(entry, compatibleSettings)
              operationContext.entries[#operationContext.entries + 1] = compatibleEntry
              operationContext.rollback[entry.sourceModKey] =
                captureLoadedMod(mod, { captureMode = "rollback" })
              if next(deferredSettings) ~= nil then
                operationContext.deferred[entry.sourceModKey] = deferredSettings
              end
              compatibility.compatibleMods = compatibility.compatibleMods + 1
            end
          end
        end
      end

      operationState.current = operationContext.index
      return nil,
        nil,
        string.format(
          "Checking collection %d / %d",
          operationContext.index,
          #operationContext.candidates
        )
    end

    operationContext.index = operationContext.index + 1
    local entry = operationContext.entries[operationContext.index]
    if entry == nil then
      restoreOriginal(operationContext)
      operationContext.publicResult.rollbackAvailable = #operationContext.applied > 0
      return true,
        operationContext.publicResult,
        string.format(
          "Applied collection %s to %d mod(s); skipped %d mod(s) and %d setting(s).",
          operationContext.collection.name,
          #operationContext.applied,
          operationContext.publicResult.compatibility.skippedMods,
          operationContext.publicResult.compatibility.skippedSettings
        )
    end

    local mod = Catalog.findMod(state.catalog, entry.sourceModKey)
    if mod == nil then
      restoreOriginal(operationContext)
      local errorText = "Collection mod became unavailable after preflight: "
        .. tostring(entry.sourceModName or entry.sourceModKey)
      operationContext.publicResult.failed = {
        modKey = entry.sourceModKey,
        error = errorText,
      }
      operationContext.publicResult.rollbackAvailable = #operationContext.applied > 0
      return false, errorText, "Collection apply failed."
    end
    local _, openError = Core.openMod(mod.key)
    if openError ~= nil and mod.loaded ~= true then
      restoreOriginal(operationContext)
      operationContext.publicResult.failed = { modKey = mod.key, error = openError }
      operationContext.publicResult.rollbackAvailable = #operationContext.applied > 0
      return false, openError, "Collection apply failed."
    end

    local deferred = operationContext.deferred[mod.key]
    local applied, applyError = applySnapshot(entry, {
      allowUnresolved = deferred ~= nil and next(deferred) ~= nil,
      rollbackSnapshot = operationContext.rollback[mod.key],
    })
    if applied == nil then
      restoreOriginal(operationContext)
      operationContext.publicResult.failed = { modKey = mod.key, error = applyError }
      operationContext.publicResult.rollbackAvailable = #operationContext.applied > 0
      return false, applyError, "Collection apply failed."
    end
    operationContext.rollback[mod.key] = applied.rollbackSnapshot
      or operationContext.rollback[mod.key]
    reconcileDeferredCollectionSettings(operationContext, mod.key, applied)

    operationContext.applied[#operationContext.applied + 1] = mod.key
    operationContext.publicResult.applied[#operationContext.publicResult.applied + 1] = mod.key
    operationState.current = operationContext.preflightCount + operationContext.index
    return nil,
      nil,
      string.format(
        "Applying collection %d / %d",
        operationContext.index,
        #operationContext.entries
      )
  end

  local function startCollectionOperation(context, total)
    local operation, operationError = operations:start({
      kind = "apply_collection",
      total = total,
      message = context.phase == "preflight"
          and string.format("Checking collection 0 / %d", #context.candidates)
        or string.format("Applying collection 0 / %d", #context.entries),
      context = context,
      cancel = collectionOperationCleanup,
      failed = collectionOperationCleanup,
      step = collectionOperationStep,
    })
    if operation == nil then
      return nil, operationError
    end
    events.emit("operation.started", { operation = operation })
    return operation, nil
  end

  function Core.applyCollection(collectionId)
    if state.drafts.dirtyModKey ~= nil then
      return nil, "Apply or revert pending changes before applying a collection."
    end

    local collection, collectionError = collections:get(collectionId, true)
    if collection == nil then
      return nil, collectionError
    end
    if #(collection.entries or {}) == 0 then
      return nil, "Collection is empty."
    end

    local context = {
      collection = collection,
      candidates = {},
      entries = {},
      rollback = {},
      deferred = {},
      applied = {},
      phase = "preflight",
      index = 0,
      preflightCount = 0,
      originalModKey = state.activeModKey,
      publicResult = newCollectionApplyResult(collectionId),
    }

    local seenTargetKeys = {}
    for _, entry in ipairs(collection.entries) do
      if entry.status == "invalid" then
        return nil, "Collection contains an unreadable entry: " .. tostring(entry.id)
      end
      local resolved, resolveError = resolveCollectionEntry(entry)
      if resolveError ~= nil then
        context.candidates[#context.candidates + 1] = {
          entry = resolved,
          reason = "missing_preset",
          countKey = "missingPresets",
          error = resolveError,
        }
      else
        local prepared, prepareError = prepareCollectionEntry(resolved)
        if prepared == nil and prepareError ~= nil then
          context.candidates[#context.candidates + 1] = {
            entry = resolved,
            reason = "migration_failed",
            countKey = "migrationFailures",
            error = prepareError,
          }
        else
          local target = prepared or resolved
          if prepared ~= nil then
            if seenTargetKeys[target.sourceModKey] then
              return nil,
                "Collection contains multiple entries for installed mod: " .. tostring(
                  target.sourceModKey
                )
            end
            seenTargetKeys[target.sourceModKey] = true
          end
          context.candidates[#context.candidates + 1] = { entry = target }
        end
      end
    end
    context.preflightCount = #context.candidates

    local operation, operationError = startCollectionOperation(context, #context.candidates * 2)
    if operation == nil then
      return nil, operationError
    end

    return { operationId = operation.id, collectionId = collectionId }, nil
  end

  function Core.applyCompatibleCollection(operationId)
    if state.drafts.dirtyModKey ~= nil then
      return nil, "Apply or revert pending changes before applying a collection."
    end

    local source, sourceError = operations:getInternal(operationId)
    if source == nil then
      return nil, sourceError
    end
    if source.kind ~= "apply_collection" or source.state ~= "completed" then
      return nil, "The selected operation is not a completed collection preflight."
    end
    if source.result == nil or source.result.requiresConfirmation ~= true then
      return nil, "The selected collection apply does not require confirmation."
    end
    if source.context.continued == true then
      return nil, "This collection preflight has already been continued."
    end

    local currentCollection, collectionError = collections:get(source.context.collection.id, true)
    if currentCollection == nil then
      return nil, collectionError
    end
    if
      currentCollection.revision ~= nil
      and source.context.collection.revision ~= nil
      and currentCollection.revision ~= source.context.collection.revision
    then
      return nil, "Collection changed after preflight. Check it again before applying."
    end

    local context = source.context
    context.phase = "apply"
    context.index = 0
    context.preflightCount = 0
    context.applied = {}
    context.originalModKey = state.activeModKey
    context.publicResult.applied = {}
    context.publicResult.failed = nil
    context.publicResult.rollbackAvailable = false
    context.publicResult.requiresConfirmation = false
    context.publicResult.preflightOperationId = operationId

    local operation, operationError = startCollectionOperation(context, #context.entries)
    if operation == nil then
      return nil, operationError
    end
    source.context.continued = true
    return {
      operationId = operation.id,
      collectionId = context.collection.id,
      preflightOperationId = operationId,
    },
      nil
  end

  function Core.rollbackCollection(operationId)
    if state.drafts.dirtyModKey ~= nil then
      return nil, "Apply or revert pending changes before rolling back a collection."
    end

    local source, sourceError = operations:getInternal(operationId)
    if source == nil then
      return nil, sourceError
    end
    if source.kind ~= "apply_collection" then
      return nil, "The selected operation is not a collection apply."
    end
    if source.context.rollbackStarted == true then
      return nil, "Rollback has already been started for this operation."
    end

    local applied = source.context.applied or {}
    local rollback = source.context.rollback or {}
    if #applied == 0 then
      return nil, "The collection operation did not apply any mods."
    end

    source.context.rollbackStarted = true
    local context = {
      sourceOperationId = operationId,
      originalModKey = state.activeModKey,
      applied = applied,
      rollback = rollback,
      index = #applied + 1,
      restored = {},
      publicResult = {
        sourceOperationId = operationId,
        restored = {},
        rollbackAvailable = true,
      },
    }

    local operation, operationError = operations:start({
      kind = "rollback_collection",
      total = #applied,
      message = string.format("Rolling back collection 0 / %d", #applied),
      context = context,
      cancel = function(operationContext, operationState)
        if state.drafts.dirtyModKey ~= nil then
          Core.revert(state.drafts.dirtyModKey)
        end
        source.context.rollbackStarted = false
        operationContext.publicResult.restored = operationContext.restored
        operationState.result = operationContext.publicResult
        restoreOriginal(operationContext)
      end,
      failed = function(operationContext)
        if state.drafts.dirtyModKey ~= nil then
          Core.revert(state.drafts.dirtyModKey)
        end
        source.context.rollbackStarted = false
        operationContext.publicResult.restored = operationContext.restored
        restoreOriginal(operationContext)
      end,
      step = function(operationContext, operationState)
        operationContext.index = operationContext.index - 1
        local modKey = operationContext.applied[operationContext.index]
        if modKey == nil then
          restoreOriginal(operationContext)
          operationContext.publicResult.restored = operationContext.restored
          operationContext.publicResult.rollbackAvailable = false
          return true,
            operationContext.publicResult,
            string.format("Rolled back %d mod(s).", #operationContext.restored)
        end

        local snapshot = operationContext.rollback[modKey]
        local mod = Catalog.findMod(state.catalog, modKey)
        if snapshot == nil or mod == nil then
          restoreOriginal(operationContext)
          return false,
            "Rollback data is unavailable for " .. tostring(modKey) .. ".",
            "Collection rollback failed."
        end

        local _, openError = Core.openMod(mod.key)
        if openError ~= nil and mod.loaded ~= true then
          restoreOriginal(operationContext)
          return false, openError, "Collection rollback failed."
        end

        local restored, restoreError = applySnapshot(snapshot, { allowUnresolved = false })
        if restored == nil then
          restoreOriginal(operationContext)
          return false, restoreError, "Collection rollback failed."
        end

        operationContext.restored[#operationContext.restored + 1] = mod.key
        operationState.current = #operationContext.restored
        return nil,
          nil,
          string.format(
            "Rolling back collection %d / %d",
            #operationContext.restored,
            #operationContext.applied
          )
      end,
    })
    if operation == nil then
      source.context.rollbackStarted = false
      return nil, operationError
    end

    events.emit("operation.started", { operation = operation })
    return {
      operationId = operation.id,
      sourceOperationId = operationId,
    }, nil
  end

  function Core.getOperation(operationId)
    return operations:get(operationId)
  end

  function Core.cancelOperation(operationId)
    local cancelled, err, changed = operations:cancel(operationId)
    if changed then
      events.emit("operation.changed", { operation = operations:get(operationId) })
    end
    return cancelled, err
  end
end

return Workflow
