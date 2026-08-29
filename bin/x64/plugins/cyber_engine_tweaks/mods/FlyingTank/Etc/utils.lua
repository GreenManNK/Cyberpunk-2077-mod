local Utils = {}
Utils.__index = Utils

Utils.log_obj = Log:New()
Utils.log_obj:SetLevel(LogLevel.Info, "Utils")

READ_COUNT = 0
WRITE_COUNT = 0

function Utils:GetKeyFromValue(table_, target_value)
   for key, value in pairs(table_) do
       if value == target_value then
           return key
       end
   end
   return nil
end

function Utils:GetKeys(table_)
   local keys = {}
   for key, _ in pairs(table_) do
       table.insert(keys, key)
   end
   return keys
end

function Utils:Normalize(v)
   local norm = math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
   v.x = v.x / norm
   v.y = v.y / norm
   v.z = v.z / norm
   return v
end

-- wheather table2 elements are in table1
function Utils:IsTablesNearlyEqual(big_table, small_table)
   for key, value in pairs(small_table) do
      if value ~= big_table[key] then
         return false
      end
   end
   return true
end

---@param fill_path string
---@return table | nil
function Utils:ReadJson(fill_path)
   READ_COUNT = READ_COUNT + 1
   local success, result = pcall(function()
      local file = io.open(fill_path, "r")
      if file then
         local contents = file:read("*a")
         local data = json.decode(contents)
         file:close()
         return data
      else
         self.log_obj:Record(LogLevel.Error, "Failed to open file for reading")
         return nil
      end
   end)
   if not success then
      self.log_obj:Record(LogLevel.Critical, result)
      return nil
   end
   return result
end

---@param fill_path string
---@param write_data table
---@return boolean
function Utils:WriteJson(fill_path, write_data)
   WRITE_COUNT = WRITE_COUNT + 1
   local success, result = pcall(function()
      local file = io.open(fill_path, "w")
      if file then
         local contents = json.encode(write_data)
         file:write(contents)
         file:close()
         return true
      else
         self.log_obj:Record(LogLevel.Error, "Failed to open file for writing")
         return false
      end
   end)
   if not success then
      self.log_obj:Record(LogLevel.Critical, result)
      return false
   end
   return result
end

return Utils