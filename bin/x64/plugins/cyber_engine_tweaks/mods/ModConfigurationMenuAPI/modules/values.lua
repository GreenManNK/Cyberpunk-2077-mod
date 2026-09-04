local Values = {}

local EPSILON = 0.000001

local function clamp(number, minimum, maximum)
  if minimum ~= nil then
    number = math.max(number, minimum)
  end
  if maximum ~= nil then
    number = math.min(number, maximum)
  end
  return number
end

local function quantize(number, minimum, step)
  step = tonumber(step)
  if step == nil or step <= 0 then
    return number
  end

  local origin = tonumber(minimum) or 0
  return origin + math.floor(((number - origin) / step) + 0.5) * step
end

function Values.normalize(setting, value)
  if setting == nil then
    return nil, "Unknown setting."
  end

  if setting.type == "bool" then
    if type(value) ~= "boolean" then
      return nil, "Boolean setting requires true or false."
    end
    return value, nil
  end

  if setting.type == "int" or setting.type == "select" then
    local number = tonumber(value)
    if number == nil then
      return nil, "Integer setting requires a number."
    end

    number = math.floor(number)
    if setting.type == "select" then
      local count = #(setting.elements or {})
      if count > 0 and (number < 1 or number > count) then
        return nil, "Selection index is outside the available values."
      end
    else
      number = clamp(
        number,
        setting.min ~= nil and math.ceil(tonumber(setting.min) or number) or nil,
        setting.max ~= nil and math.floor(tonumber(setting.max) or number) or nil
      )
      number = math.floor(quantize(number, setting.min, setting.step))
    end
    return number, nil
  end

  if setting.type == "float" then
    local number = tonumber(value)
    if number == nil then
      return nil, "Numeric setting requires a number."
    end

    number = clamp(number, tonumber(setting.min), tonumber(setting.max))
    number = quantize(number, setting.min, setting.step)
    number = clamp(number, tonumber(setting.min), tonumber(setting.max))
    return number, nil
  end

  if setting.type == "key" or setting.type == "name" or setting.type == "string" then
    if value == nil then
      return "", nil
    end
    return tostring(value), nil
  end

  return value, nil
end

function Values.equal(setting, left, right)
  if left == nil or right == nil then
    return left == right
  end

  local normalizedLeft = Values.normalize(setting, left)
  local normalizedRight = Values.normalize(setting, right)
  if normalizedLeft == nil or normalizedRight == nil then
    return left == right or tostring(left) == tostring(right)
  end

  if setting.type == "float" then
    local step = math.abs(tonumber(setting.step) or 0)
    local epsilon = math.max(EPSILON, step * EPSILON)
    return math.abs(normalizedLeft - normalizedRight) <= epsilon
  end

  return normalizedLeft == normalizedRight
end

return Values
