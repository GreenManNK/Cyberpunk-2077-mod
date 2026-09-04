local Text = {}

local CASE_FOLD = {
  ["À"] = "à",
  ["Á"] = "á",
  ["Â"] = "â",
  ["Ã"] = "ã",
  ["Ä"] = "ä",
  ["Å"] = "å",
  ["Æ"] = "æ",
  ["Ç"] = "ç",
  ["È"] = "è",
  ["É"] = "é",
  ["Ê"] = "ê",
  ["Ë"] = "ë",
  ["Ì"] = "ì",
  ["Í"] = "í",
  ["Î"] = "î",
  ["Ï"] = "ï",
  ["Ð"] = "ð",
  ["Ñ"] = "ñ",
  ["Ò"] = "ò",
  ["Ó"] = "ó",
  ["Ô"] = "ô",
  ["Õ"] = "õ",
  ["Ö"] = "ö",
  ["Ø"] = "ø",
  ["Ù"] = "ù",
  ["Ú"] = "ú",
  ["Û"] = "û",
  ["Ü"] = "ü",
  ["Ý"] = "ý",
  ["Þ"] = "þ",
  ["Ą"] = "ą",
  ["Ć"] = "ć",
  ["Č"] = "č",
  ["Ď"] = "ď",
  ["Ę"] = "ę",
  ["Ě"] = "ě",
  ["Ğ"] = "ğ",
  ["İ"] = "i",
  ["ı"] = "i",
  ["Ł"] = "ł",
  ["Ń"] = "ń",
  ["Ň"] = "ň",
  ["Ő"] = "ő",
  ["Ř"] = "ř",
  ["Ś"] = "ś",
  ["Ş"] = "ş",
  ["Š"] = "š",
  ["Ť"] = "ť",
  ["Ů"] = "ů",
  ["Ű"] = "ű",
  ["Ź"] = "ź",
  ["Ż"] = "ż",
  ["Ž"] = "ž",
  ["Œ"] = "œ",
  ["Ÿ"] = "ÿ",
  ["ẞ"] = "ss",
  ["ß"] = "ss",
  ["А"] = "а",
  ["Б"] = "б",
  ["В"] = "в",
  ["Г"] = "г",
  ["Д"] = "д",
  ["Е"] = "е",
  ["Ё"] = "ё",
  ["Ж"] = "ж",
  ["З"] = "з",
  ["И"] = "и",
  ["Й"] = "й",
  ["К"] = "к",
  ["Л"] = "л",
  ["М"] = "м",
  ["Н"] = "н",
  ["О"] = "о",
  ["П"] = "п",
  ["Р"] = "р",
  ["С"] = "с",
  ["Т"] = "т",
  ["У"] = "у",
  ["Ф"] = "ф",
  ["Х"] = "х",
  ["Ц"] = "ц",
  ["Ч"] = "ч",
  ["Ш"] = "ш",
  ["Щ"] = "щ",
  ["Ъ"] = "ъ",
  ["Ы"] = "ы",
  ["Ь"] = "ь",
  ["Э"] = "э",
  ["Ю"] = "ю",
  ["Я"] = "я",
  ["Є"] = "є",
  ["І"] = "і",
  ["Ї"] = "ї",
  ["Ґ"] = "ґ",
}

local function decimalPlaces(step)
  local scaled = math.abs(tonumber(step) or 0)
  if scaled <= 0 then
    return nil
  end

  for decimals = 0, 8 do
    local nearest = math.floor(scaled + 0.5)
    local tolerance = math.max(0.000000001, math.abs(scaled) * 0.000001)
    if math.abs(scaled - nearest) <= tolerance then
      return decimals
    end
    scaled = scaled * 10
  end

  return 8
end

local function trimFraction(value)
  local text = tostring(value)
  if string.find(text, ".", 1, true) ~= nil then
    text = string.gsub(text, "0+$", "")
    text = string.gsub(text, "%.$", "")
  end
  return text
end

local function glyphCount(value)
  if type(utf8) == "table" and type(utf8.len) == "function" then
    local ok, length = pcall(utf8.len, value)
    if ok and length ~= nil then
      return length
    end
  end

  local length = 0
  for index = 1, #value do
    local byte = string.byte(value, index)
    if byte < 0x80 or byte >= 0xC0 then
      length = length + 1
    end
  end
  return length
end

local function glyphPrefix(value, maximum)
  local limit = math.max(0, math.floor(tonumber(maximum) or 0))
  if limit == 0 then
    return ""
  end
  if type(utf8) == "table" and type(utf8.offset) == "function" then
    local ok, nextByte = pcall(utf8.offset, value, limit + 1)
    if ok then
      return nextByte == nil and value or string.sub(value, 1, nextByte - 1)
    end
  end

  local byteIndex = 1
  local glyphs = 0
  while byteIndex <= #value and glyphs < limit do
    local lead = string.byte(value, byteIndex)
    local width = 1
    if lead >= 0xC2 and lead <= 0xDF then
      width = 2
    elseif lead >= 0xE0 and lead <= 0xEF then
      width = 3
    elseif lead >= 0xF0 and lead <= 0xF4 then
      width = 4
    end
    if byteIndex + width - 1 > #value then
      width = 1
    end
    byteIndex = byteIndex + width
    glyphs = glyphs + 1
  end
  return string.sub(value, 1, byteIndex - 1)
end

function Text.safe(value)
  if value == nil then
    return ""
  end

  return tostring(value)
end

function Text.casefold(value)
  local text = string.gsub(Text.safe(value), "[A-Z]", function(character)
    return string.char(string.byte(character) + 32)
  end)
  for upper, lower in pairs(CASE_FOLD) do
    text = string.gsub(text, upper, lower)
  end
  return text
end

function Text.number(value, step)
  local number = tonumber(value)
  if number == nil or number ~= number or number == math.huge or number == -math.huge then
    return Text.safe(value)
  end

  local decimals = decimalPlaces(step)
  if decimals ~= nil then
    return string.format("%." .. tostring(decimals) .. "f", number)
  end

  local fixed = trimFraction(string.format("%.6f", number))
  if tonumber(fixed) == 0 and number ~= 0 then
    return string.format("%.8g", number)
  end
  return fixed
end

function Text.floatPrecision(format, step)
  local explicit = Text.safe(format):match("%%%.(%d+)[fF]")
  if explicit ~= nil then
    return math.max(0, math.min(8, math.floor(tonumber(explicit) or 0)))
  end

  return decimalPlaces(step) or 2
end

function Text.hasRichMarkup(value)
  local text = Text.safe(value)
  return string.find(text, "<Rich[%s>]", 1) ~= nil or string.find(text, "</>", 1, true) ~= nil
end

function Text.normalizeRichMarkup(value)
  return Text.safe(value)
end

function Text.plain(value)
  local text = Text.normalizeRichMarkup(value)
  text = string.gsub(text, "<[^>]+>", "")
  return text
end

function Text.clamp(value, maxChars)
  local text = Text.safe(value)
  text = string.gsub(text, "%s+", " ")
  text = string.gsub(text, "^%s+", "")
  text = string.gsub(text, "%s+$", "")
  local limit = maxChars ~= nil and math.max(0, math.floor(tonumber(maxChars) or 0)) or nil
  if limit ~= nil and glyphCount(text) > limit then
    if limit <= 3 then
      return string.sub("...", 1, limit)
    end
    return glyphPrefix(text, limit - 3) .. "..."
  end

  return text
end

function Text.description(value, maxChars)
  if Text.hasRichMarkup(value) then
    return Text.normalizeRichMarkup(value)
  end
  if maxChars == nil then
    return Text.safe(value)
  end
  return Text.clamp(value, maxChars)
end

return Text
