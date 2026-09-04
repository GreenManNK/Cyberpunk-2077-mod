local CollectionsView = {}

function CollectionsView.render(surface, controller)
  local runtime = surface.runtime
  local state = runtime.state
  local entries = {}

  if state.collectionImportMode == true then
    for _, file in ipairs(state.portableCollections or {}) do
      local rowFile = file
      entries[#entries + 1] = {
        label = runtime:safe(rowFile.name or rowFile.fileName),
        description = runtime:safe(rowFile.fileName)
          .. (rowFile.valid == true and "" or (" - " .. runtime:t("common.error"))),
        selected = rowFile.fileName == state.selectedPortableFileName,
        callback = function()
          runtime.model:selectPortableCollection(rowFile)
        end,
      }
    end

    surface:sidebar(
      controller,
      runtime:t("collections.portable_files"),
      entries,
      "portable_collections_scroll",
      false
    )
    surface:content(controller, runtime.model:portableCollectionRows(), "portable_preview_scroll")

    local preview = state.portableCollectionPreview
    surface:renderActionGroups(controller, {
      {
        {
          label = runtime:t("action.refresh"),
          callback = function()
            runtime.model:refreshPortableCollections()
          end,
        },
        {
          label = runtime:t("collections.import"),
          visible = preview ~= nil and preview.valid == true,
          active = preview ~= nil and preview.valid == true,
          callback = function()
            runtime.model:requestConfirmation(
              "import_collection:" .. tostring(state.selectedPortableFileName),
              runtime:t("collections.import_prompt", {
                name = runtime:safe(preview and preview.name),
              }),
              function()
                runtime.model:importSelectedPortableCollection()
              end,
              "warning"
            )
          end,
        },
        {
          label = runtime:t("action.delete"),
          visible = state.selectedPortableFileName ~= nil,
          callback = function()
            runtime.model:requestConfirmation(
              "delete_portable_collection:" .. tostring(state.selectedPortableFileName),
              runtime:t("collections.delete_backup_prompt", {
                name = runtime:safe(preview and preview.name or state.selectedPortableFileName),
              }),
              function()
                runtime.model:deleteSelectedPortableCollection()
              end,
              "warning"
            )
          end,
        },
        {
          label = runtime:t("action.cancel"),
          callback = function()
            runtime.model:leaveCollectionImportMode()
          end,
        },
      },
    })

    return preview and runtime:safe(preview.name) or runtime:t("collections.import_title"), nil
  end

  for _, collection in ipairs(state.collections or {}) do
    local rowCollection = collection
    entries[#entries + 1] = {
      label = runtime:safe(rowCollection.name),
      description = runtime:t("collections.count", {
        count = tonumber(rowCollection.entryCount) or 0,
      }),
      selected = rowCollection.id == state.selectedCollectionId,
      callback = function()
        runtime.model:selectCollection(rowCollection)
      end,
    }
  end

  surface:sidebar(
    controller,
    runtime:t("sidebar.collections"),
    entries,
    "collections_scroll",
    false
  )

  local collection = runtime.model:selectedCollection()
  local rows = {}
  local title = runtime:t("collections.title")
  if collection ~= nil then
    title = runtime:safe(collection.name)
    rows = runtime.model:collectionRows()
    if #rows == 0 then
      rows[1] = { kind = "message", label = runtime:t("collections.empty") }
    end
  elseif #state.collections == 0 then
    rows[1] = { kind = "message", label = runtime:t("collections.first_use") }
  else
    rows[1] = { kind = "message", label = runtime:t("collections.select") }
  end
  surface:content(controller, rows, "collection_entries_scroll")

  local hasCollection = collection ~= nil
  local hasSelectedCollection = hasCollection or state.selectedCollectionId ~= nil
  local hasRememberedMod = state.rememberedModKey ~= nil or state.selectedModKey ~= nil
  local hasEntries = hasCollection and #(collection.entries or {}) > 0
  local hasSelectedEntry = hasCollection and state.selectedCollectionEntryId ~= nil
  local availableModCount = #(state.mods or {})
  local operationRunning = state.activeOperationId ~= nil
  local rollbackAvailable = state.lastCollectionApply ~= nil
    and state.lastCollectionApply.result ~= nil
    and state.lastCollectionApply.result.rollbackAvailable == true

  surface:renderSidebarActionGrid(controller, {
    {
      {
        label = runtime:t("collections.action.new"),
        visible = not operationRunning,
        callback = function()
          surface:openTextPrompt({
            title = runtime:t("collections.new"),
            message = runtime:t("collections.name_prompt"),
            placeholder = runtime:t("collections.name_prompt"),
            confirmLabel = runtime:t("action.create"),
            kind = "collection",
            submit = function(value)
              runtime.model:createCollection(value)
            end,
          })
        end,
      },
      {
        label = runtime:t("collections.quick_baseline"),
        visible = not operationRunning,
        callback = function()
          runtime.model:requestConfirmation(
            "quick_baseline",
            runtime:t("collections.baseline_prompt"),
            function()
              runtime.model:captureBaseline("")
            end,
            "info"
          )
        end,
      },
    },
    {
      {
        label = runtime:t("collections.import"),
        visible = not operationRunning,
        callback = function()
          runtime.model:enterCollectionImportMode()
        end,
      },
      {
        label = runtime:t("collections.export"),
        visible = not operationRunning and hasCollection,
        callback = function()
          runtime.model:requestConfirmation(
            "export_collection:" .. tostring(collection.id),
            runtime:t("collections.export_prompt", {
              name = runtime:safe(collection.name),
            }),
            function()
              runtime.model:exportSelectedCollection()
            end,
            "info"
          )
        end,
      },
    },
  })

  surface:renderActionGroups(controller, {
    {
      {
        label = runtime:t("collections.add_current"),
        visible = not operationRunning and hasCollection and hasRememberedMod,
        callback = function()
          runtime.model:addCurrentModToCollection()
        end,
      },
      {
        label = runtime:t("collections.update_from_current"),
        visible = not operationRunning and hasCollection and availableModCount > 0,
        callback = function()
          runtime.model:requestConfirmation(
            "update_collection:" .. tostring(collection.id),
            runtime:t("collections.update_prompt", {
              name = runtime:safe(collection.name),
              count = availableModCount,
            }),
            function()
              runtime.model:updateSelectedCollectionFromCurrent()
            end,
            "warning"
          )
        end,
      },
      {
        label = runtime:t("collections.clean_missing"),
        visible = not operationRunning and hasEntries,
        callback = function()
          runtime.model:requestCollectionCleanup()
        end,
      },
    },
    {
      {
        label = runtime:t("collections.remove_entry"),
        visible = not operationRunning and hasSelectedEntry,
        callback = function()
          runtime.model:removeSelectedCollectionEntry()
        end,
      },
      {
        label = runtime:t("action.rename"),
        visible = not operationRunning and hasCollection,
        callback = function()
          surface:openTextPrompt({
            title = runtime:t("collections.rename"),
            message = runtime:t("collections.rename_prompt"),
            placeholder = runtime:t("collections.rename_prompt"),
            value = runtime:safe(collection.name),
            confirmLabel = runtime:t("action.rename"),
            submit = function(value)
              runtime.model:renameCollection(value)
            end,
          })
        end,
      },
      {
        label = runtime:t("action.delete"),
        visible = not operationRunning and hasSelectedCollection,
        callback = function()
          runtime.model:deleteCollection()
        end,
      },
      {
        label = runtime:t("collections.rollback"),
        visible = not operationRunning and rollbackAvailable,
        active = rollbackAvailable,
        callback = function()
          runtime.model:rollbackLastCollectionOperation()
        end,
      },
      {
        label = runtime:t("action.cancel"),
        visible = operationRunning,
        active = operationRunning,
        allowDuringOperation = true,
        callback = function()
          runtime.model:cancelActiveOperation()
        end,
      },
      {
        label = runtime:t("action.apply"),
        visible = not operationRunning and hasEntries,
        active = not operationRunning and hasEntries,
        callback = function()
          runtime.model:applySelectedCollection()
        end,
      },
    },
  })

  return title, nil
end

return CollectionsView
