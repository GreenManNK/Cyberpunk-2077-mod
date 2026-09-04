local Lang = { version = "2.0.0-integrated" }

local aliases = {
    ["ko-kr"] = "ko-kr",
    ["kr-kr"] = "ko-kr",
    ["zh-cn"] = "zh-cn",
    ["zh-tw"] = "zh-tw",
    ["de-de"] = "de-de",
    ["es-es"] = "es-es",
    ["es-mx"] = "es-mx",
    ["fr-fr"] = "fr-fr",
    ["pl-pl"] = "pl-pl",
    ["pt-br"] = "pt-br",
    ["ru-ru"] = "ru-ru",
    ["tr-tr"] = "tr-tr",
    ["vi-vn"] = "vi-vn",
    ["ja-jp"] = "ja-jp",
    ["en-us"] = "en-us",
}

local localeCache = "en-us"
local localeCacheUntil = 0
local tableCache = {}
local replacementCache = {}

local function buildReplacementList(exact)
    local items = {}
    for source, value in pairs(exact or {}) do
        if source ~= value then
            local isFragment = (#source >= 12 and string.find(source, " ", 1, true) ~= nil)
                or string.sub(source, 1, 1) == "."
                or string.sub(source, 1, 1) == ":"
                or string.sub(source, 1, 1) == ";"
                or string.sub(source, 1, 1) == ","
                or string.sub(source, 1, 1) == "\n"
                or string.sub(source, -1) == " "
                or string.sub(source, -1) == ":"
                or string.sub(source, -2) == ": "
                or string.sub(source, -2) == ". "
            if isFragment then
                table.insert(items, { source = source, value = value })
            end
        end
    end
    table.sort(items, function(a, b)
        if #a.source == #b.source then return a.source < b.source end
        return #a.source > #b.source
    end)
    return items
end

local function safeRequire(locale)
    locale = aliases[string.lower(tostring(locale or ""))] or string.lower(tostring(locale or ""))
    if locale == "" then return nil end
    if tableCache[locale] ~= nil then return tableCache[locale] or nil end
    local ok, lang = pcall(require, "localization/" .. locale)
    if ok and type(lang) == "table" then
        tableCache[locale] = lang
        replacementCache[locale] = buildReplacementList(lang.__translations)
        return lang
    end
    tableCache[locale] = false
    return nil
end

local function getOnScreenLocale()
    local locale = "en-us"
    pcall(function()
        local settings = Game.GetSettingsSystem()
        local value = settings and settings:GetVar("/language", "OnScreen")
        if value then
            locale = value:GetValue().value or locale
        end
    end)
    locale = string.lower(tostring(locale or "en-us"))
    return aliases[locale] or locale
end

local function getConfiguredLocale()
    local locale = nil
    pcall(function()
        if not Game or not Game.GetScriptableSystemsContainer then return end
        local container = Game.GetScriptableSystemsContainer()
        if not container then return end
        local system = container:Get("NightCityBank.NCBankSystem")
        if system and system.GetLanguageCode then
            locale = system:GetLanguageCode()
        end
    end)
    locale = string.lower(tostring(locale or ""))
    if locale == "" then return nil end
    return aliases[locale] or locale
end

function Lang.invalidate()
    localeCacheUntil = 0
end

function Lang.getActiveLocale()
    local now = tonumber(os.clock()) or 0
    if now > 0 and now < localeCacheUntil then return localeCache end

    local locale = getConfiguredLocale() or getOnScreenLocale() or "en-us"
    if not safeRequire(locale) then locale = "en-us" end
    localeCache = locale
    localeCacheUntil = now > 0 and (now + 0.25) or 0
    return localeCache
end

function Lang.getLocale(key)
    local locale = Lang.getActiveLocale()
    local selected = safeRequire(locale)
    if selected and selected[key] ~= nil and selected[key] ~= "" then return locale end
    return "en-us"
end

function Lang.getText(key)
    local locale = Lang.getActiveLocale()
    local selected = safeRequire(locale) or {}
    local english = safeRequire("en-us") or {}
    local text = selected[key]
    if text == nil or text == "" then text = english[key] end
    if text == nil or text == "" then return "Not Localized" end
    return text
end

local function replacePlain(value, source, replacement)
    if source == nil or source == "" then return value end
    local startAt = 1
    local parts = {}
    while true do
        local first, last = string.find(value, source, startAt, true)
        if not first then
            table.insert(parts, string.sub(value, startAt))
            break
        end
        table.insert(parts, string.sub(value, startAt, first - 1))
        table.insert(parts, replacement or "")
        startAt = last + 1
    end
    return table.concat(parts)
end

function Lang.translate(value)
    local text = tostring(value or "")
    if text == "" then return text end
    local locale = Lang.getActiveLocale()
    local lang = safeRequire(locale) or safeRequire("en-us") or {}
    local exact = lang.__translations or {}
    local translated = exact[text]
    if translated ~= nil and translated ~= "" then return translated end

    translated = text
    for _, item in ipairs(lang.__prefixTranslations or {}) do
        local source = item.source
        if source and source ~= "" and string.sub(translated, 1, #source) == source then
            translated = tostring(item.value or "") .. string.sub(translated, #source + 1)
            break
        end
    end
    for _, item in ipairs(replacementCache[locale] or {}) do
        translated = replacePlain(translated, item.source, item.value)
    end
    return translated
end

function Lang.getFontFamily()
    local lang = safeRequire(Lang.getActiveLocale()) or safeRequire("en-us") or {}
    return lang.__fontFamily or "base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily"
end

function Lang.getFontStyle()
    local lang = safeRequire(Lang.getActiveLocale()) or safeRequire("en-us") or {}
    return lang.__fontStyle or "Regular"
end

return Lang
