local Text = require("mcm_ui/mcm_text")

local Mods = {}

local function safe(value)
  return Text.safe(value)
end

function Mods.providerPrefix(mod)
  return string.upper(safe(mod.providerShortName or mod.provider or mod.bridge or "?"))
end

function Mods.providerDisplayName(mod)
  return safe(
    mod.providerName or mod.providerShortName or mod.provider or mod.bridge or "Unknown provider"
  )
end

function Mods.hoverDescription(mod)
  return string.format("%s (%s)", safe(mod.name), Mods.providerDisplayName(mod))
end

function Mods.providerKey(mod)
  return string.lower(safe(mod.provider or mod.bridge or mod.providerShortName))
end

function Mods.sortLabel(mode)
  if mode == "za" then
    return "Z-A"
  end

  return "A-Z"
end

function Mods.settingsSortLabel(mode)
  if mode == "az" then
    return "A-Z"
  end
  if mode == "za" then
    return "Z-A"
  end

  return "Original"
end

function Mods.sortName(mod, includeProvider)
  local name = safe(mod.name)
  if includeProvider then
    name = Mods.providerPrefix(mod) .. " " .. name
  end
  return string.lower(name)
end

function Mods.displayName(mod, showProviderPrefix)
  if showProviderPrefix then
    return string.format("[%s] %s", Mods.providerPrefix(mod), safe(mod.name))
  end

  return safe(mod.name)
end

function Mods.filtered(mods, options)
  options = options or {}
  local providerFilter = options.providerFilter or "all"
  local textFilter = Text.casefold(options.textFilter)
  local result = {}

  for _, mod in ipairs(mods or {}) do
    local passesProvider = providerFilter == "all" or Mods.providerKey(mod) == providerFilter
    local display =
      Text.casefold(string.format("[%s] %s", Mods.providerPrefix(mod), safe(mod.name)))
    local passesText = textFilter == "" or string.find(display, textFilter, 1, true) ~= nil
    if passesProvider and passesText then
      table.insert(result, mod)
    end
  end

  table.sort(result, function(a, b)
    local favoriteKeys = options.favoriteKeys or {}
    local leftFavorite = favoriteKeys[safe(a.key)] == true
    local rightFavorite = favoriteKeys[safe(b.key)] == true
    if leftFavorite ~= rightFavorite then
      return leftFavorite
    end

    local left = Mods.sortName(a, options.sortWithProvider == true)
    local right = Mods.sortName(b, options.sortWithProvider == true)
    if left == right then
      return safe(a.key) < safe(b.key)
    end
    if options.sortMode == "za" then
      return left > right
    end

    return left < right
  end)

  return result
end

return Mods
