local Utils = {}
Utils.__index = Utils

Utils.log_obj = Log:New()
Utils.log_obj:SetLevel(LogLevel.Info, "Utils")

READ_COUNT = 0
WRITE_COUNT = 0

function Utils:IsTablesEqual(table1, table2)
    for key, value in pairs(table1) do
       if value ~= table2[key] then
          return false
       end
    end

    for key, value in pairs(table2) do
       if value ~= table1[key] then
          return false
       end
    end

    return true
end

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

function Utils:GenerateUniformVectorsOnSphere(sample_num, radius)
   local vectors = {}
   local golden_angle = Pi() * (3 - math.sqrt(5)) -- golden angle

   local n = sample_num * 2 -- even

   if n < 1 then
      self.log_obj:Record(LogLevel.Error, "sample_num should be larger than 0")
      return nil
   end

   for i = 1, n do
      local y_ = 1 - (i / n) * 2
      local r = math.sqrt(1 - y_*y_)

      local theta = golden_angle * i

      local x_ = math.cos(theta) * r
      local z_ = math.sin(theta) * r

      local Normalized_vector = self:Normalize({x = x_, y = y_, z = z_})
      local x = Normalized_vector.x * radius
      local y = Normalized_vector.y * radius
      local z = Normalized_vector.z * radius

      -- add vector and its opposite
      table.insert(vectors, Vector4.new(x, y, z, 1))
      table.insert(vectors, Vector4.new(-x, -y, -z, 1))
   end

   return vectors
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

-- y = k(x - a)^2 + b and cross point is (0, c). Calculate Slope.
function Utils:CalculationQuadraticFuncSlope(a, b, c, x)
   return 2*(c - b)*(x - a)/(a * a)
end

function Utils:GetSpecificLogarithmFunction(index)
   local ratio_list = {0.37, 1.0, 2.72, 7.39, 20.1} -- y=exp(x-1)
   if index < 1 or index > 5 then
      return nil
   end
   return ratio_list[index]
end

function Utils:ChangePolarCoordinates(x, y, z)
   local r = math.sqrt(x*x + y*y + z*z)
   local theta = math.atan2(y, x) * 180 / Pi()
   local phi = math.acos(z / r) * 180 / Pi()
   return r, theta, phi
end

function Utils:QuaternionMultiply(q1, q2)
   local r = q1.r*q2.r - q1.i*q2.i - q1.j*q2.j - q1.k*q2.k
   local i = q1.r*q2.i + q1.i*q2.r + q1.j*q2.k - q1.k*q2.j
   local j = q1.r*q2.j - q1.i*q2.k + q1.j*q2.r + q1.k*q2.i
   local k = q1.r*q2.k + q1.i*q2.j - q1.j*q2.i + q1.k*q2.r
   return {r = r, i = i, j = j, k = k}
end

function Utils:QuaternionConjugate(q)
   return {r = q.r, i = -q.i, j = -q.j, k = -q.k}
end

function Utils:RotateVectorByQuaternion(v, q)
   local q_conj = self:QuaternionConjugate(q)
   local temp = self:QuaternionMultiply({r = 0, i = v.x, j = v.y, k = v.z}, q_conj)
   local result = self:QuaternionMultiply(q, temp)
   return {x = result.i, y = result.j, z = result.k}
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