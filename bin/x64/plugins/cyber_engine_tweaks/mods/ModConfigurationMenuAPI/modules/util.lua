local Util = {}

local function isUsefulString(value)
  if type(value) ~= "string" or value == "" then
    return false
  end

  if string.find(value, "ToCName{", 1, true) ~= nil then
    return false
  end

  return true
end

local function tryStringConverter(converter, value)
  if type(converter) ~= "function" then
    return nil
  end

  local ok, result = pcall(function()
    return converter(value)
  end)

  if ok and isUsefulString(result) then
    return result
  end

  return nil
end

local function extractCNameDebugName(text)
  if type(text) ~= "string" or string.find(text, "ToCName{", 1, true) == nil then
    return nil
  end

  local debugName = string.match(text, "%-%-%[%[(.-)%-%-%]%]")
  if debugName == nil then
    debugName = string.match(text, "%-%[%[(.-)%-%]%]")
  end

  if debugName ~= nil then
    debugName = string.gsub(debugName, "^%s+", "")
    debugName = string.gsub(debugName, "%s+$", "")
    debugName = string.gsub(debugName, "%s*%-+$", "")
    if debugName ~= "" then
      return debugName
    end
  end

  return nil
end

function Util.safeCall(label, fn, ...)
  local ok, result = pcall(fn, ...)
  if ok then
    return true, result
  end
  return false, string.format("%s: %s", tostring(label), tostring(result))
end

function Util.cnameToString(value)
  if value == nil then
    return ""
  end

  if type(value) == "string" then
    local debugName = extractCNameDebugName(value)
    if debugName ~= nil then
      return debugName
    end

    return value
  end

  if type(value) == "table" and value.value ~= nil then
    return tostring(value.value)
  end

  local converted = tryStringConverter(NameToString, value)
  if converted ~= nil then
    return converted
  end

  converted = tryStringConverter(ToString, value)
  if converted ~= nil then
    return converted
  end

  converted = tryStringConverter(LocKeyToString, value)
  if converted ~= nil then
    return converted
  end

  local text = tostring(value)
  local debugName = extractCNameDebugName(text)
  if debugName ~= nil then
    return debugName
  end

  return text
end

function Util.cname(value)
  if CName and CName.new and type(value) == "string" then
    return CName.new(value)
  end
  return value
end

function Util.localize(value)
  if value == nil then
    return ""
  end

  local key = Util.cnameToString(value)
  if key == "" then
    return ""
  end

  local function resolvedText(text)
    if type(text) ~= "string" or text == "" then
      return nil
    end

    local normalized = Util.cnameToString(text)
    if normalized == "" or normalized == key then
      return nil
    end

    return normalized
  end

  local byKeyCandidates = { value }
  local cnameValue = Util.cname(key)
  if cnameValue ~= value then
    byKeyCandidates[#byKeyCandidates + 1] = cnameValue
  end
  if key ~= value and key ~= cnameValue then
    byKeyCandidates[#byKeyCandidates + 1] = key
  end

  if type(GetLocalizedTextByKey) == "function" then
    for _, candidate in ipairs(byKeyCandidates) do
      local ok, text = pcall(GetLocalizedTextByKey, candidate)
      if ok then
        local resolved = resolvedText(text)
        if resolved ~= nil then
          return resolved
        end
      end
    end
  end

  if type(GetLocalizedText) == "function" then
    local ok, text = pcall(GetLocalizedText, key)
    if ok then
      local resolved = resolvedText(text)
      if resolved ~= nil then
        return resolved
      end
    end
  end

  return key
end

function Util.tableCount(value)
  local count = 0
  if type(value) ~= "table" then
    return count
  end

  for _ in pairs(value) do
    count = count + 1
  end

  return count
end

function Util.sortedValues(values, field)
  table.sort(values, function(a, b)
    return tostring(a[field] or ""):lower() < tostring(b[field] or ""):lower()
  end)
  return values
end

function Util.contains(haystack, needle)
  if needle == nil or needle == "" then
    return true
  end

  if haystack == nil then
    return false
  end

  return string.find(tostring(haystack):lower(), tostring(needle):lower(), 1, true) ~= nil
end

return Util
