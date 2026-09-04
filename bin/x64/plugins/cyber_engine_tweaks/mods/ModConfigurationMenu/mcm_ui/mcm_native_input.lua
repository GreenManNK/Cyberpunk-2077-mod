local SurfaceInput = {}
local SEARCH_SETTLE_FRAMES = 12

local function direction(forward)
  return forward == true and 1 or -1
end

local function inputBinding(surface, id)
  local binding = surface.bindings[id]
  if
    binding ~= nil
    and surface.runtime.state.activeOperationId ~= nil
    and binding.allowDuringOperation ~= true
  then
    return nil
  end
  return binding
end

local function ensureSearchState(state)
  state.searchQueries = state.searchQueries or { sidebar = "", content = "" }
  state.searchDrafts = state.searchDrafts
    or {
      sidebar = state.searchQueries.sidebar or "",
      content = state.searchQueries.content or "",
    }
  state.searchPendingFrames = state.searchPendingFrames or { sidebar = 0, content = 0 }
end

function SurfaceInput.attach(RedscriptSurface)
  function RedscriptSurface:handleAction(id)
    local binding = inputBinding(self, id)
    if binding == nil then
      return false
    end
    self:capturePositions()
    return self:invoke(binding.callback)
  end

  function RedscriptSurface:handleStep(id, forward)
    local binding = inputBinding(self, id)
    if binding == nil or binding.setting == nil then
      return false
    end
    return self:invoke(function()
      self.runtime.model:changeSetting(binding.setting, direction(forward))
    end)
  end

  function RedscriptSurface:handleNumber(id, value)
    local binding = inputBinding(self, id)
    if binding == nil or binding.setting == nil then
      return false
    end
    local nextValue = tonumber(value)
    if binding.setting.type == "int" then
      nextValue = math.floor(nextValue or 0)
    end
    return self:invoke(function()
      self.runtime.model:setSettingDraft(binding.setting, nextValue)
      self.runtime:queueRender()
    end)
  end

  function RedscriptSurface:handleKey(id, value)
    local binding = inputBinding(self, id)
    if binding == nil or binding.setting == nil then
      return false
    end
    return self:invoke(function()
      self.runtime.state.inputModalActive = false
      self.runtime.state.suppressResetKeyRelease = value == "IK_Backspace"
      self.runtime.model:setSettingDraft(binding.setting, self.runtime:safe(value))
      self.runtime:queueRender()
    end)
  end

  function RedscriptSurface:handleKeyListening(id, active)
    local binding = inputBinding(self, id)
    if binding == nil or binding.kind ~= "setting" or binding.setting == nil then
      return false
    end
    self.runtime.state.inputModalActive = active == true
    return true
  end

  function RedscriptSurface:handleHover(id, _, hovered)
    local state = self.runtime.state
    if not IsDefined(state.controller) then
      return false
    end
    local binding = self.bindings[id]
    if binding == nil then
      return false
    end
    if binding.kind == "sidebar" then
      if hovered == true then
        state.hoveredSidebarItem = id
      elseif state.hoveredSidebarItem == id then
        state.hoveredSidebarItem = nil
      end
    end
    if hovered == true then
      state.hoveredSetting = binding.setting
    elseif state.hoveredSetting == binding.setting then
      state.hoveredSetting = nil
    end
    local text = hovered == true and binding.description or self.baseDescription
    if self.runtime.layout.currentProfile.description == true then
      state.controller:McmUiUpdateDescription(
        self.runtime:descriptionText(text),
        self:descriptionHeight()
      )
    end
    return true
  end

  function RedscriptSurface:handleReset(id)
    local binding = inputBinding(self, id)
    if binding == nil or binding.setting == nil then
      return false
    end
    return self:invoke(function()
      self.runtime.model:setSettingToDefault(binding.setting)
    end)
  end

  function RedscriptSurface:handleText(context, value)
    if self.runtime.state.activeOperationId ~= nil then
      return false
    end
    if self.textPrompt ~= nil and self.textPrompt.context == context then
      self.textPrompt.value = self.runtime:safe(value)
    end
    return true
  end

  function RedscriptSurface:handleSearch(context, value)
    local state = self.runtime.state
    if state.activeOperationId ~= nil or state.route == nil or state.route.view ~= "mods" then
      return false
    end
    if context ~= "sidebar" and context ~= "content" then
      return false
    end
    local nextValue = self.runtime:safe(value)
    ensureSearchState(state)
    if state.searchDrafts[context] == nextValue then
      return true
    end
    state.searchDrafts[context] = nextValue
    state.searchPendingFrames[context] = SEARCH_SETTLE_FRAMES
    return true
  end

  function RedscriptSurface:applySearch(context)
    local state = self.runtime.state
    ensureSearchState(state)
    state.searchPendingFrames[context] = 0
    local nextValue = state.searchDrafts[context]
    if state.searchQueries[context] == nextValue then
      return false
    end

    self:capturePositions()
    state.searchQueries[context] = nextValue
    if context == "sidebar" then
      state.scrollPositions.mods_scroll = 0
    else
      state.scrollPositions.settings_scroll = 0
    end
    self.runtime:queueRender()
    return true
  end

  function RedscriptSurface:updateSearch()
    local state = self.runtime.state
    ensureSearchState(state)
    if state.route == nil or state.route.view ~= "mods" then
      state.searchPendingFrames.sidebar = 0
      state.searchPendingFrames.content = 0
      state.searchDrafts.sidebar = state.searchQueries.sidebar
      state.searchDrafts.content = state.searchQueries.content
      return
    end

    for _, context in ipairs({ "sidebar", "content" }) do
      local remaining = tonumber(state.searchPendingFrames[context]) or 0
      if remaining > 1 then
        state.searchPendingFrames[context] = remaining - 1
      elseif remaining == 1 then
        self:applySearch(context)
      end
    end
  end

  function RedscriptSurface:handleSearchFocus(context, focused)
    local state = self.runtime.state
    if context ~= "sidebar" and context ~= "content" then
      return false
    end
    ensureSearchState(state)
    if focused == true then
      state.searchInputContext = context
    elseif state.searchInputContext == context then
      state.searchInputContext = nil
      if state.searchPendingFrames[context] > 0 then
        self:applySearch(context)
      end
    end
    return true
  end

  function RedscriptSurface:handleKeyInput(key, action)
    local state = self.runtime.state
    if action ~= "IACT_Release" then
      return false
    end
    if
      not state.active
      or state.inputModalActive
      or state.searchInputContext ~= nil
      or state.activeOperationId ~= nil
    then
      return false
    end

    if key == "IK_Backspace" then
      if state.suppressResetKeyRelease == true then
        state.suppressResetKeyRelease = false
        return false
      end
      if state.hoveredSetting == nil then
        return false
      end
      return self:invoke(function()
        self.runtime.model:setSettingToDefault(state.hoveredSetting)
      end)
    end

    local letter = tostring(key or ""):match("^IK_([A-Z])$")
    if
      letter == nil
      or state.route == nil
      or state.route.view ~= "mods"
      or state.hoveredSidebarItem == nil
    then
      return false
    end

    local mods = self.runtime.model:filteredMods()
    if #mods == 0 then
      return false
    end

    local selectedIndex = 0
    for index, mod in ipairs(mods) do
      if mod.key == state.selectedModKey then
        selectedIndex = index
        break
      end
    end

    local targetIndex = nil
    for offset = 1, #mods do
      local index = ((selectedIndex + offset - 1) % #mods) + 1
      local first = self.runtime:safe(mods[index].name):match("^%s*([%a])")
      if first ~= nil and string.upper(first) == letter then
        targetIndex = index
        break
      end
    end
    if targetIndex == nil then
      return false
    end

    self:capturePositions()
    local rowHeight = self.runtime.layout.metrics.leftRowH
    local viewportHeight = self.runtime.layout.metrics.leftScrollH
    local contentHeight = math.max(viewportHeight, (#mods * rowHeight) + 20)
    local overflow = math.max(0, contentHeight - viewportHeight)
    if overflow > 0 then
      local rowY = (targetIndex - 1) * rowHeight
      state.scrollPositions.mods_scroll =
        math.max(0, math.min(1, (rowY - (viewportHeight * 0.35)) / overflow))
    else
      state.scrollPositions.mods_scroll = 0
    end
    self.runtime.model:selectMod(mods[targetIndex])
    return true
  end
end

return SurfaceInput
