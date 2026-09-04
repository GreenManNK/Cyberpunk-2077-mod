local Workflow = {}

local function portableDate(value)
  local year, month, day, hour, minute =
    tostring(value or ""):match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):%d%dZ$")
  if year == nil then
    return tostring(value or "")
  end
  return string.format("%s-%s-%s %s:%s UTC", year, month, day, hour, minute)
end

function Workflow.attach(Model)
  function Model:refreshCollections()
    local runtime = self.runtime
    local state = runtime.state
    local api = state.api
    if api == nil or type(api.listCollections) ~= "function" then
      state.collections = {}
      state.selectedCollection = nil
      state.collectionMissingEntries = {}
      state.collectionCleanupPlan = nil
      return false
    end

    local collections, err = api.listCollections()
    if type(collections) ~= "table" then
      state.collections = {}
      state.selectedCollection = nil
      state.collectionMissingEntries = {}
      state.collectionCleanupPlan = nil
      runtime:setStatus(err or runtime:t("error.collections_unavailable"), "error")
      return false
    end

    state.collections = collections
    local selectedExists = false
    for _, collection in ipairs(collections) do
      if collection.id == state.selectedCollectionId then
        selectedExists = true
        break
      end
    end
    if not selectedExists then
      state.selectedCollectionId = collections[1] and collections[1].id or nil
      state.route.collectionId = state.selectedCollectionId
      state.route.entryId = nil
    end
    self:loadSelectedCollection()
    return true
  end

  function Model:selectedCollection()
    return self.runtime.state.selectedCollection
  end

  function Model:refreshPortableCollections()
    local runtime = self.runtime
    local state = runtime.state
    local api = state.api
    if
      api == nil
      or type(api.listPortableCollections) ~= "function"
      or type(api.inspectPortableCollection) ~= "function"
    then
      state.portableCollections = {}
      state.portableCollectionPreview = nil
      runtime:setStatus(runtime:t("error.portable_collections_unavailable"), "error")
      return false
    end

    if type(api.refreshIndex) == "function" then
      local refreshed, refreshError = api.refreshIndex()
      if refreshed == nil and refreshError ~= nil then
        state.portableCollections = {}
        state.portableCollectionPreview = nil
        runtime:setStatus(runtime:currentApiStatus(refreshError), "error")
        return false
      end

      if type(api.listMods) == "function" then
        local mods = api.listMods()
        if type(mods) == "table" then
          state.mods = mods
        end
      end
    end

    local directory = nil
    if type(api.getPortableCollectionDirectory) == "function" then
      directory = api.getPortableCollectionDirectory()
    end
    state.portableCollectionDirectory = directory

    local files, err = api.listPortableCollections()
    if type(files) ~= "table" then
      state.portableCollections = {}
      state.portableCollectionPreview = nil
      runtime:setStatus(err or runtime:t("error.portable_collections_unavailable"), "error")
      return false
    end

    state.portableCollections = files
    local selected = nil
    for _, file in ipairs(files) do
      if file.fileName == state.selectedPortableFileName then
        selected = file
        break
      end
    end
    if selected == nil then
      selected = files[1]
    end
    state.selectedPortableFileName = selected and selected.fileName or nil
    state.portableCollectionPreview = nil
    if selected ~= nil then
      self:selectPortableCollection(selected, false)
    end
    runtime:queueRender()
    return true
  end

  function Model:enterCollectionImportMode()
    local state = self.runtime.state
    state.collectionImportMode = true
    state.selectedPortableFileName = nil
    state.portableCollectionPreview = nil
    state.scrollPositions.portable_collections_scroll = 0
    state.scrollPositions.portable_preview_scroll = 0
    self:refreshPortableCollections()
  end

  function Model:leaveCollectionImportMode()
    local state = self.runtime.state
    state.collectionImportMode = false
    state.selectedPortableFileName = nil
    state.portableCollectionPreview = nil
    self.runtime:queueRender()
  end

  function Model:selectPortableCollection(file, queueRender)
    local runtime = self.runtime
    local state = runtime.state
    if file == nil then
      return
    end

    state.selectedPortableFileName = file.fileName
    state.portableCollectionPreview = nil
    state.scrollPositions.portable_preview_scroll = 0
    if file.valid ~= true then
      state.portableCollectionPreview = {
        fileName = file.fileName,
        valid = false,
        error = file.error or runtime:t("error.portable_collection_invalid"),
      }
    else
      local preview, err = state.api.inspectPortableCollection(file.fileName)
      if preview == nil then
        state.portableCollectionPreview = {
          fileName = file.fileName,
          valid = false,
          error = err or runtime:t("error.portable_collection_invalid"),
        }
      else
        preview.valid = true
        state.portableCollectionPreview = preview
      end
    end
    if queueRender ~= false then
      runtime:queueRender()
    end
  end

  function Model:portableCollectionRows()
    local runtime = self.runtime
    local state = runtime.state
    local preview = state.portableCollectionPreview
    local rows = {}
    local overview = runtime:t("collections.portable_directory", {
      path = runtime:safe(
        state.portableCollectionDirectory or "<CET>/mods/ModConfigurationMenuAPI/data/portable"
      ),
    })
    if preview == nil then
      rows[#rows + 1] = {
        kind = "message",
        label = overview .. "\n\n" .. (#state.portableCollections == 0 and runtime:t(
          "collections.import_empty"
        ) or runtime:t("collections.import_select")),
      }
      return rows
    end
    if preview.valid ~= true then
      rows[#rows + 1] = {
        kind = "message",
        label = overview .. "\n\n" .. runtime:t("collections.import_invalid", {
          file = runtime:safe(preview.fileName),
          error = runtime:safe(preview.error),
        }),
      }
      return rows
    end

    local details = {}
    local created = portableDate(preview.exportedAt)
    if created ~= "" then
      details[#details + 1] = runtime:t("collections.import_created", { date = created })
    end
    details[#details + 1] = runtime:t("collections.import_summary", {
      mods = tonumber(preview.entryCount) or 0,
      settings = tonumber(preview.settingCount) or 0,
    })
    details[#details + 1] = runtime:t("collections.import_ready", {
      ready = tonumber(preview.counts and preview.counts.ready) or 0,
    })
    details[#details + 1] = runtime:t("collections.import_unavailable", {
      unavailable = (tonumber(preview.counts and preview.counts.missing) or 0)
        + (tonumber(preview.counts and preview.counts.provider_unavailable) or 0),
    })
    rows[#rows + 1] = {
      kind = "message",
      label = overview .. "\n\n" .. table.concat(details, "\n") .. "\n\n" .. runtime:t(
        "collections.import_scope_warning"
      ),
    }
    for _, entry in ipairs(preview.entries or {}) do
      rows[#rows + 1] = {
        kind = "portable_entry",
        label = runtime:safe(entry.sourceModName or entry.sourceModKey),
        description = runtime:t("collections.import_entry", {
          status = runtime:t("collections.import_status." .. tostring(entry.status)),
          provider = runtime:safe(entry.providerId),
          count = tonumber(entry.settingCount) or 0,
        }),
      }
    end
    return rows
  end

  function Model:exportSelectedCollection()
    local runtime = self.runtime
    local state = runtime.state
    local collection = self:selectedCollection()
    if collection == nil or state.api == nil or type(state.api.exportCollection) ~= "function" then
      runtime:setStatus(runtime:t("error.portable_collections_unavailable"), "error")
      return false
    end

    local result, err = state.api.exportCollection(collection.id)
    runtime:setStatus(runtime:currentApiStatus(err), result ~= nil and "success" or "error")
    runtime:queueRender()
    return result ~= nil
  end

  function Model:importSelectedPortableCollection()
    local runtime = self.runtime
    local state = runtime.state
    if
      state.selectedPortableFileName == nil
      or state.portableCollectionPreview == nil
      or state.portableCollectionPreview.valid ~= true
      or state.api == nil
      or type(state.api.importPortableCollection) ~= "function"
    then
      return false
    end

    local collection, err = state.api.importPortableCollection(state.selectedPortableFileName)
    runtime:setStatus(runtime:currentApiStatus(err), collection ~= nil and "success" or "error")
    if collection ~= nil then
      state.collectionImportMode = false
      state.selectedPortableFileName = nil
      state.portableCollectionPreview = nil
      state.selectedCollectionId = collection.id
      state.route.collectionId = collection.id
      state.route.entryId = nil
      self:refreshCollections()
    end
    runtime:queueRender()
    return collection ~= nil
  end

  function Model:deleteSelectedPortableCollection()
    local runtime = self.runtime
    local state = runtime.state
    if
      state.selectedPortableFileName == nil
      or state.api == nil
      or type(state.api.deletePortableCollection) ~= "function"
    then
      runtime:setStatus(runtime:t("error.portable_collections_unavailable"), "error")
      return false
    end

    local deleted, err = state.api.deletePortableCollection(state.selectedPortableFileName)
    runtime:setStatus(runtime:currentApiStatus(err), deleted == true and "success" or "error")
    if deleted == true then
      if self:refreshPortableCollections() then
        runtime:setStatus("", "info")
      end
    else
      runtime:queueRender()
    end
    return deleted == true
  end

  function Model:loadSelectedCollection()
    local runtime = self.runtime
    local state = runtime.state
    state.selectedCollection = nil
    state.collectionEntryPreview = nil
    state.collectionMissingEntries = {}
    state.collectionCleanupPlan = nil
    if state.selectedCollectionId == nil or state.api == nil then
      return
    end

    local collection, err = state.api.getCollection(state.selectedCollectionId)
    if collection == nil then
      runtime:setStatus(err or runtime:t("error.collection_load"), "error")
      return
    end
    state.selectedCollection = collection

    if type(state.api.listMissingCollectionEntries) == "function" then
      local missing, missingError = state.api.listMissingCollectionEntries(collection.id)
      if type(missing) == "table" then
        state.collectionMissingEntries = missing
      elseif missingError ~= nil then
        runtime:setStatus(missingError, "error")
      end
    else
      local availableModKeys = {}
      for _, mod in ipairs(state.mods or {}) do
        availableModKeys[mod.key] = true
      end
      for _, entry in ipairs(collection.entries or {}) do
        if
          entry.sourceModKey ~= nil
          and entry.status ~= "invalid"
          and availableModKeys[entry.sourceModKey] ~= true
        then
          state.collectionMissingEntries[#state.collectionMissingEntries + 1] = entry
        end
      end
    end

    local entryExists = false
    for _, entry in ipairs(collection.entries or {}) do
      if entry.id == state.selectedCollectionEntryId then
        entryExists = true
        break
      end
    end
    if entryExists and type(state.api.previewCollectionEntry) == "function" then
      local preview, previewError =
        state.api.previewCollectionEntry(collection.id, state.selectedCollectionEntryId)
      state.collectionEntryPreview = preview
      if preview == nil and previewError ~= nil then
        runtime:setStatus(previewError, "error")
      end
    elseif not entryExists then
      state.selectedCollectionEntryId = nil
      state.route.entryId = nil
    end
  end

  function Model:selectCollection(collection)
    local state = self.runtime.state
    if collection == nil then
      return
    end
    state.selectedCollectionId = collection.id
    state.route.collectionId = collection.id
    state.route.entryId = nil
    state.selectedCollectionEntryId = nil
    state.scrollPositions.collection_entries_scroll = 0
    self:loadSelectedCollection()
    self.runtime:queueRender()
  end

  function Model:createCollection(name)
    local runtime = self.runtime
    local state = runtime.state
    name = tostring(name or ""):match("^%s*(.-)%s*$")
    if name == "" then
      name = runtime:t("collections.default_name", { index = #state.collections + 1 })
    end

    local collection, err = state.api.createCollection({ name = name })
    runtime:setStatus(runtime:currentApiStatus(err), collection ~= nil and "success" or "error")
    if collection ~= nil then
      state.selectedCollectionId = collection.id
      self:refreshCollections()
    end
    runtime:queueRender()
  end

  function Model:renameCollection(name)
    local runtime = self.runtime
    local state = runtime.state
    local collection = self:selectedCollection()
    if collection == nil then
      return
    end

    name = tostring(name or ""):match("^%s*(.-)%s*$")
    if name == "" then
      name = collection.name
    end

    local updated, err = state.api.updateCollection(collection.id, { name = name })
    runtime:setStatus(runtime:currentApiStatus(err), updated ~= nil and "success" or "error")
    if updated ~= nil then
      self:refreshCollections()
    end
    runtime:queueRender()
  end

  function Model:deleteCollection()
    local runtime = self.runtime
    local state = runtime.state
    local collection = self:selectedCollection()
    if collection == nil and state.selectedCollectionId ~= nil then
      for _, metadata in ipairs(state.collections or {}) do
        if metadata.id == state.selectedCollectionId then
          collection = metadata
          break
        end
      end
    end
    if collection == nil then
      return
    end

    self:requestConfirmation(
      "delete_collection:" .. tostring(collection.id),
      runtime:t("collections.delete_prompt", { name = runtime:safe(collection.name) }),
      function()
        local ok, err = state.api.deleteCollection(collection.id)
        runtime:setStatus(runtime:currentApiStatus(err), ok and "success" or "error")
        if ok then
          state.selectedCollectionId = nil
          state.selectedCollection = nil
          state.route.collectionId = nil
          state.route.entryId = nil
          self:refreshCollections()
        end
        runtime:queueRender()
      end,
      "error"
    )
  end

  function Model:addCurrentModToCollection()
    local runtime = self.runtime
    local state = runtime.state
    local collection = self:selectedCollection()
    local modKey = state.rememberedModKey or state.selectedModKey
    if collection == nil or modKey == nil then
      return
    end

    local function storeCurrentMod()
      local mod = self:selectedMod()
      if mod == nil or mod.key ~= modKey then
        for _, candidate in ipairs(state.mods) do
          if candidate.key == modKey then
            self:selectModNow(candidate)
            break
          end
        end
      end

      local entry, err = state.api.putCollectionEntry(collection.id, modKey, {})
      runtime:setStatus(runtime:currentApiStatus(err), entry ~= nil and "success" or "error")
      if entry ~= nil then
        state.selectedCollectionEntryId = entry.id
        self:refreshCollections()
      end
      runtime:queueRender()
    end

    return self:resolvePendingDrafts(storeCurrentMod)
  end

  function Model:captureBaseline(name)
    local runtime = self.runtime
    local state = runtime.state
    name = tostring(name or ""):match("^%s*(.-)%s*$")
    if name == "" then
      name = "Baseline - " .. os.date("%Y-%m-%d")
    end

    local result, err = state.api.captureCurrentSetup({ name = name })
    runtime:setStatus(runtime:currentApiStatus(err), result ~= nil and "info" or "error")
    if result ~= nil then
      state.activeOperationId = result.operationId
      state.selectedCollectionId = result.collectionId
      self:refreshCollections()
    end
    runtime:queueRender()
  end

  function Model:updateSelectedCollectionFromCurrent()
    local runtime = self.runtime
    local state = runtime.state
    local collection = self:selectedCollection()
    if
      collection == nil
      or state.api == nil
      or type(state.api.updateCollectionFromCurrent) ~= "function"
    then
      runtime:setStatus(runtime:t("error.collections_unavailable"), "error")
      return false
    end

    local result, err = state.api.updateCollectionFromCurrent(collection.id)
    runtime:setStatus(runtime:currentApiStatus(err), result ~= nil and "info" or "error")
    if result ~= nil then
      state.activeOperationId = result.operationId
    end
    runtime:queueRender()
    return result ~= nil
  end

  function Model:missingCollectionEntryCount()
    return #(self.runtime.state.collectionMissingEntries or {})
  end

  function Model:collectionCleanupCounts()
    local plan = self.runtime.state.collectionCleanupPlan
    if type(plan) == "table" and type(plan.counts) == "table" then
      return tonumber(plan.counts.mods) or 0,
        tonumber(plan.counts.settings) or 0,
        tonumber(plan.counts.preserved) or 0
    end
    return self:missingCollectionEntryCount(), 0, 0
  end

  function Model:requestCollectionCleanup()
    local runtime = self.runtime
    local state = runtime.state
    local collection = self:selectedCollection()
    if collection == nil or state.api == nil then
      return false
    end

    local plan = state.collectionCleanupPlan
    if type(state.api.inspectCollectionCleanup) == "function" then
      local inspected, inspectError = state.api.inspectCollectionCleanup(collection.id)
      if type(inspected) ~= "table" then
        runtime:setStatus(runtime:currentApiStatus(inspectError), "error")
        runtime:queueRender()
        return false
      end
      plan = inspected
      state.collectionCleanupPlan = inspected
    end

    local counts = (plan and plan.counts)
      or {
        mods = self:missingCollectionEntryCount(),
        settings = 0,
        preserved = 0,
      }
    local removable = (tonumber(counts.mods) or 0) + (tonumber(counts.settings) or 0)
    if removable == 0 then
      runtime:setStatus(runtime:t("collections.cleanup_none"), "info")
      runtime:queueRender()
      return false
    end

    local items = {}
    for _, item in ipairs((plan and plan.missingMods) or {}) do
      if #items >= 6 then
        break
      end
      items[#items + 1] = runtime:t("collections.cleanup_item_mod", {
        mod = runtime:safe(item.modName or item.modKey),
      })
    end
    for _, item in ipairs((plan and plan.missingSettings) or {}) do
      if #items >= 6 then
        break
      end
      items[#items + 1] = runtime:t("collections.cleanup_item_setting", {
        mod = runtime:safe(item.modName or item.modKey),
        setting = runtime:safe(item.label or item.settingKey or item.settingId),
      })
    end
    if removable > #items then
      items[#items + 1] = runtime:t("collections.cleanup_more", { count = removable - #items })
    end

    self:requestConfirmation(
      "clean_collection:" .. tostring(collection.id),
      runtime:t("collections.cleanup_prompt", {
        name = runtime:safe(collection.name),
        mods = tonumber(counts.mods) or 0,
        settings = tonumber(counts.settings) or 0,
        preserved = tonumber(counts.preserved) or 0,
        items = table.concat(items, "\n"),
      }),
      function()
        self:cleanMissingCollectionEntries()
      end,
      "error",
      {
        title = runtime:t("collections.cleanup_title"),
        confirmLabel = runtime:t("collections.remove_missing"),
      }
    )
    return true
  end

  function Model:cleanMissingCollectionEntries()
    local runtime = self.runtime
    local state = runtime.state
    local collection = self:selectedCollection()
    if
      collection == nil
      or state.api == nil
      or (
        type(state.api.cleanCollectionUnavailableContent) ~= "function"
        and type(state.api.cleanMissingCollectionEntries) ~= "function"
      )
    then
      runtime:setStatus(runtime:t("error.collections_unavailable"), "error")
      return false
    end

    local result, err
    if type(state.api.cleanCollectionUnavailableContent) == "function" then
      result, err = state.api.cleanCollectionUnavailableContent(collection.id)
    else
      result, err = state.api.cleanMissingCollectionEntries(collection.id)
    end
    runtime:setStatus(runtime:currentApiStatus(err), result ~= nil and "info" or "error")
    if result ~= nil then
      state.activeOperationId = result.operationId
    end
    runtime:queueRender()
    return result ~= nil
  end

  function Model:selectCollectionEntry(entry)
    local runtime = self.runtime
    local state = runtime.state
    local collection = self:selectedCollection()
    if collection == nil or entry == nil then
      return
    end

    state.selectedCollectionEntryId = entry.id
    state.route.entryId = entry.id
    state.collectionEntryPreview = nil
    local preview, err = state.api.previewCollectionEntry(collection.id, entry.id)
    state.collectionEntryPreview = preview
    runtime:setStatus(runtime:currentApiStatus(err), preview ~= nil and "info" or "error")
    runtime:queueRender()
  end

  function Model:removeSelectedCollectionEntry()
    local runtime = self.runtime
    local state = runtime.state
    local collection = self:selectedCollection()
    local entryId = state.selectedCollectionEntryId
    if collection == nil or entryId == nil then
      return
    end

    local entry = nil
    for _, candidate in ipairs(collection.entries or {}) do
      if candidate.id == entryId then
        entry = candidate
        break
      end
    end
    if entry == nil then
      return
    end

    self:requestConfirmation(
      "remove_collection_entry:" .. tostring(entry.id),
      runtime:t("collections.remove_entry_prompt", {
        mod = runtime:safe(entry.sourceModName or entry.sourceModKey),
      }),
      function()
        local ok, err = state.api.removeCollectionEntry(collection.id, entry.id)
        runtime:setStatus(runtime:currentApiStatus(err), ok and "success" or "error")
        if ok then
          state.selectedCollectionEntryId = nil
          state.route.entryId = nil
          state.collectionEntryPreview = nil
          self:refreshCollections()
        end
        runtime:queueRender()
      end,
      "error"
    )
  end

  function Model:collectionRows()
    local runtime = self.runtime
    local state = runtime.state
    local collection = self:selectedCollection()
    if collection == nil then
      return {}
    end

    local rows = {}
    for _, entry in ipairs(collection.entries or {}) do
      local rowEntry = entry
      rows[#rows + 1] = {
        kind = "collection_entry",
        entry = rowEntry,
        selected = rowEntry.id == state.selectedCollectionEntryId,
        callback = function()
          self:selectCollectionEntry(rowEntry)
        end,
      }
      if rowEntry.id == state.selectedCollectionEntryId and state.collectionEntryPreview ~= nil then
        for _, previewRow in ipairs(state.collectionEntryPreview.rows or {}) do
          if previewRow.status ~= "matches" then
            rows[#rows + 1] = {
              kind = "preview",
              label = previewRow.label or previewRow.settingKey or previewRow.settingId,
              currentValue = self:previewValue(
                previewRow.valueType,
                previewRow.currentValue,
                previewRow
              ),
              targetValue = self:previewValue(
                previewRow.valueType,
                previewRow.presetValue,
                previewRow
              ),
              status = previewRow.status,
              nested = true,
            }
          end
        end
      end
    end
    return rows
  end

  function Model:applySelectedCollection()
    local runtime = self.runtime
    local state = runtime.state
    local collection = self:selectedCollection()
    if collection == nil then
      return
    end

    local result, err = state.api.applyCollection(collection.id)
    runtime:setStatus(runtime:currentApiStatus(err), result ~= nil and "info" or "error")
    if result ~= nil then
      state.activeOperationId = result.operationId
    end
    runtime:queueRender()
  end

  function Model:requestCollectionApplyConfirmation(operation)
    local runtime = self.runtime
    local state = runtime.state
    local result = operation and operation.result
    local summary = result and result.compatibility
    if
      state.api == nil
      or result == nil
      or result.requiresConfirmation ~= true
      or summary == nil
    then
      return false
    end

    local message = runtime:t("collections.compatibility_prompt", {
      mods = summary.compatibleMods or 0,
      settings = summary.compatibleSettings or 0,
      skippedMods = summary.skippedMods or 0,
      skippedSettings = summary.skippedSettings or 0,
    })
    local skippedItems = {}
    local skipped = result.skipped or {}
    for _, item in ipairs(skipped.mods or {}) do
      if #skippedItems >= 6 then
        break
      end
      skippedItems[#skippedItems + 1] = tostring(item.modName or item.modKey or "?")
    end
    for _, item in ipairs(skipped.settings or {}) do
      if #skippedItems >= 6 then
        break
      end
      skippedItems[#skippedItems + 1] = string.format(
        "%s — %s",
        tostring(item.modName or item.modKey or "?"),
        tostring(item.label or item.settingKey or item.settingId or "?")
      )
    end
    local skippedCount = (summary.skippedMods or 0) + (summary.skippedSettings or 0)
    if #skippedItems > 0 then
      local more = ""
      if skippedCount > #skippedItems then
        more = runtime:t("collections.compatibility_more", {
          count = skippedCount - #skippedItems,
        })
      end
      message = message
        .. "\n\n"
        .. runtime:t("collections.compatibility_details", {
          items = table.concat(skippedItems, "; "),
          more = more,
        })
    end
    self:requestConfirmation(
      "apply_compatible_collection:" .. tostring(operation.id),
      message,
      function()
        local applyResult, err = state.api.applyCompatibleCollection(operation.id)
        runtime:setStatus(runtime:currentApiStatus(err), applyResult ~= nil and "info" or "error")
        if applyResult ~= nil then
          state.activeOperationId = applyResult.operationId
        end
        runtime:queueRender()
      end,
      "warning",
      {
        title = runtime:t("collections.compatibility_title"),
        confirmLabel = runtime:t("collections.apply_compatible"),
      }
    )
    return true
  end

  function Model:cancelActiveOperation()
    local runtime = self.runtime
    local state = runtime.state
    if state.api == nil or state.activeOperationId == nil then
      return false
    end

    local cancelled, err = state.api.cancelOperation(state.activeOperationId)
    runtime:setStatus(runtime:currentApiStatus(err), cancelled and "info" or "error")
    if cancelled then
      state.activeOperationId = nil
      self:refreshCollections()
    end
    runtime:queueRender()
    return cancelled == true
  end

  function Model:rollbackLastCollectionOperation()
    local runtime = self.runtime
    local state = runtime.state
    local operation = state.lastCollectionApply
    if
      state.api == nil
      or operation == nil
      or operation.result == nil
      or operation.result.rollbackAvailable ~= true
    then
      return false
    end

    local result, err = state.api.rollbackCollection(operation.id)
    runtime:setStatus(runtime:currentApiStatus(err), result ~= nil and "info" or "error")
    if result ~= nil then
      state.activeOperationId = result.operationId
    end
    runtime:queueRender()
    return result ~= nil
  end
end

return Workflow
