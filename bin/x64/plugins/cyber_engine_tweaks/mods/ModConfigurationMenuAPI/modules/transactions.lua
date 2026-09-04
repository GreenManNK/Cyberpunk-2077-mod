local Transactions = {}

function Transactions.apply(provider, sourceModId, changes, context)
  if type(provider) ~= "table" or type(provider.applyBatch) ~= "function" then
    return nil, "Provider does not support writable transactions."
  end
  if type(changes) ~= "table" or #changes == 0 then
    return {
      ok = true,
      atomic = true,
      partial = false,
      appliedIds = {},
      schemaChanged = false,
    },
      nil
  end

  local ok, result, message = pcall(provider.applyBatch, sourceModId, changes, context)
  if not ok then
    return nil, tostring(result)
  end

  if result == true then
    local appliedIds = {}
    for _, change in ipairs(changes) do
      appliedIds[#appliedIds + 1] = change.id
    end
    return {
      ok = true,
      atomic = false,
      partial = false,
      appliedIds = appliedIds,
      schemaChanged = false,
    },
      nil
  end

  if type(result) ~= "table" then
    if message ~= nil then
      return nil, tostring(message)
    end

    if result ~= nil then
      return nil, tostring(result)
    end

    return nil, "Provider returned no transaction result."
  end

  if result.ok ~= true then
    return result, tostring(result.error or message or "Provider rejected the transaction.")
  end

  result.atomic = result.atomic == true
  result.partial = result.partial == true
  if result.partial then
    return result,
      tostring(result.error or "Provider reported a partial transaction as successful.")
  end
  if type(result.appliedIds) ~= "table" then
    return nil, "Provider transaction result has no appliedIds array."
  end

  local expected = {}
  for _, change in ipairs(changes) do
    expected[tostring(change.id)] = true
  end

  local applied = {}
  for _, settingId in ipairs(result.appliedIds) do
    local id = tostring(settingId)
    if not expected[id] then
      return nil, "Provider transaction reported an unknown applied setting: " .. id
    end
    applied[id] = true
  end

  for settingId in pairs(expected) do
    if not applied[settingId] then
      return nil, "Provider transaction did not confirm setting: " .. settingId
    end
  end

  result.schemaChanged = result.schemaChanged == true
  return result, nil
end

return Transactions
