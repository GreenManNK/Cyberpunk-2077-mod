local Theme = {}

Theme.ROLES = {
  {
    key = "background",
    labelKey = "settings.theme.background",
    default = "MainColors.Fullscreen_PrimaryBackgroundDarkest",
  },
  {
    key = "panel",
    labelKey = "settings.theme.panel",
    default = "MainColors.Fullscreen_PrimaryBackgroundDark",
  },
  {
    key = "panelSelected",
    labelKey = "settings.theme.panel_selected",
    default = "MainColors.DarkBlue",
  },
  {
    key = "primary",
    labelKey = "settings.theme.primary",
    default = "MainColors.Blue",
  },
  {
    key = "secondary",
    labelKey = "settings.theme.secondary",
    default = "MainColors.Red",
  },
  {
    key = "success",
    labelKey = "settings.theme.success",
    default = "MainColors.Green",
  },
  {
    key = "modified",
    labelKey = "settings.theme.modified",
    default = "MainColors.LightPurple",
  },
  {
    key = "favorite",
    labelKey = "settings.theme.favorite",
    default = "MainColors.Gold",
  },
  {
    key = "text",
    labelKey = "settings.theme.text",
    default = "MainColors.White",
  },
  {
    key = "muted",
    labelKey = "settings.theme.muted",
    default = "MainColors.MildBlue",
  },
}

-- This is the complete color-property set from the game's MainColors style.
-- Its order is deliberately grouped by hue first, then by semantic/background use.
Theme.PALETTE = {
  -- Red
  "MainColors.Red",
  "MainColors.PanelRed",
  "MainColors.ActiveRed",
  "MainColors.MildRed",
  "MainColors.FaintRed",
  "MainColors.DarkRed",
  "MainColors.PanelDarkRed",
  "MainColors.CombatRed",
  "MainColors.CombatRedNoHDR",
  "MainColors.DamageType_Critical",
  "MainColors.SupRed",
  "MainColors.SubtitleSpeaker",
  "MainColors.NameplateBackground",

  -- Orange
  "MainColors.Orange",
  "MainColors.MildOrange",
  "MainColors.Warning",
  "MainColors.GettingHacked",
  "MainColors.DarkGold",
  "MainColors.PanelDarkGold",

  -- Yellow and gold
  "MainColors.Yellow",
  "MainColors.Gold",
  "MainColors.PanelGold",
  "MainColors.ActiveYellow",
  "MainColors.MildYellow",
  "MainColors.FaintYellow",
  "MainColors.Overshield",
  "MainColors.EnemyBase",
  "MainColors.EnemyBaseNoHDR",
  "MainColors.EnemyMinimapBase",
  "MainColors.DamageTypeThermal",
  "MainColors.DamageTypeThermal_Critical",

  -- Green
  "MainColors.Green",
  "MainColors.PanelGreen",
  "MainColors.ActiveGreen",
  "MainColors.MildGreen",
  "MainColors.DarkGreen",
  "MainColors.PanelDarkGreen",
  "MainColors.DamageTypeChemical",
  "MainColors.DamageTypeChemical_Critical",
  "MainColors.StreetCred",
  "MainColors.Hacking",
  "MainColors.Cyberspace",
  "MainColors.TutorialColor",
  "MainColors.TutorialColorIntensity",
  "MainColors.TutorialIntensity",
  "MainColors.NPC_Chatter",

  -- Blue and cyan
  "MainColors.Blue",
  "MainColors.PanelBlue",
  "MainColors.ActiveBlue",
  "MainColors.MediumBlue",
  "MainColors.MildBlue",
  "MainColors.FaintBlue",
  "MainColors.DarkBlue",
  "MainColors.PanelDarkBlue",
  "MainColors.DamageTypeEMP",
  "MainColors.DamageTypeEMP_Critical",
  "MainColors.FastTravel",
  "MainColors.StrongFastTravel",
  "MainColors.QuickhackAccent",
  "MainColors.SupBlue",
  "MainColors.RelicColor",

  -- Purple
  "MainColors.Purple",
  "MainColors.LightPurple",
  "MainColors.Fullscreen_VioletBackground",
  "MainColors.RelicDark",

  -- Neutral
  "MainColors.White",
  "MainColors.PanelWhite",
  "MainColors.ActiveWhite",
  "MainColors.Neutral",
  "MainColors.Grey",
  "MainColors.PanelGrey",
  "MainColors.DarkGrey",
  "MainColors.Black",
  "MainColors.PanelBlack",
  "MainColors.DamageTypePhysical",
  "MainColors.DamageTypePhysical_Critical",

  -- Full-screen backgrounds
  "MainColors.Fullscreen_PrimaryForegroundDarker",
  "MainColors.Fullscreen_PrimaryBackgroundDark",
  "MainColors.Fullscreen_PrimaryBackgroundDarkest",
  "MainColors.Fullscreen_SecondaryBackground1",
  "MainColors.Fullscreen_SecondaryBackground2",
  "MainColors.Fullscreen_SecondaryBackground3",
  "MainColors.Fullscreen_SecondaryBackground4",
  "MainColors.Fullscreen_RedDarkBackground",
}

local paletteIndex = {}
local paletteLabels = {}

local function humanize(key)
  local value = tostring(key):gsub("^MainColors%.", ""):gsub("_", " ")
  value = value:gsub("(%u)(%u%l)", "%1 %2")
  value = value:gsub("(%l)(%u)", "%1 %2")
  return value
end

for index, key in ipairs(Theme.PALETTE) do
  paletteIndex[key] = index
  paletteLabels[index] = humanize(key)
end

function Theme.defaults()
  local result = {}
  for _, role in ipairs(Theme.ROLES) do
    result[role.key] = role.default
  end
  return result
end

function Theme.normalize(value)
  local result = Theme.defaults()
  if type(value) ~= "table" then
    return result
  end

  for _, role in ipairs(Theme.ROLES) do
    local candidate = value[role.key]
    if type(candidate) == "string" and paletteIndex[candidate] ~= nil then
      result[role.key] = candidate
    end
  end
  return result
end

function Theme.elements()
  local result = {}
  for index, label in ipairs(paletteLabels) do
    result[index] = label
  end
  return result
end

function Theme.indexOf(key)
  return paletteIndex[key]
end

function Theme.keyAt(index)
  return Theme.PALETTE[math.max(1, math.min(#Theme.PALETTE, math.floor(tonumber(index) or 1)))]
end

function Theme.role(roleKey)
  for _, role in ipairs(Theme.ROLES) do
    if role.key == roleKey then
      return role
    end
  end
  return nil
end

return Theme
