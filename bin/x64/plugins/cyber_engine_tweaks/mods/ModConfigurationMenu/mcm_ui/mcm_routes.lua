local Routes = {}

local validViews = {
  mods = true,
  settings = true,
  mod_presets = true,
  collections = true,
}

function Routes.new()
  return {
    view = "mods",
    modKey = nil,
    presetId = nil,
    collectionId = nil,
    entryId = nil,
    mode = "browse",
  }
end

function Routes.go(state, view, values)
  if validViews[view] ~= true then
    return false, "Unknown MCM route: " .. tostring(view)
  end

  values = values or {}
  local previous = state.route or Routes.new()
  local modKey = values.modKey
  if modKey == nil then
    modKey = previous.modKey or state.selectedModKey or state.rememberedModKey
  end
  if modKey ~= nil then
    state.rememberedModKey = modKey
  end

  state.route = {
    view = view,
    modKey = modKey,
    presetId = values.presetId,
    collectionId = values.collectionId,
    entryId = values.entryId,
    mode = values.mode or "browse",
  }
  return true, nil
end

return Routes
