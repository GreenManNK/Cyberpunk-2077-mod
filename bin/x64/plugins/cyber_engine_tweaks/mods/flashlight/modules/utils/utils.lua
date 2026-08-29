miscUtils = {}

function miscUtils.deepcopy(origin)
	local orig_type = type(origin)
    local copy
    if orig_type == 'table' then
        copy = {}
        for origin_key, origin_value in next, origin, nil do
            copy[miscUtils.deepcopy(origin_key)] = miscUtils.deepcopy(origin_value)
        end
        setmetatable(copy, miscUtils.deepcopy(getmetatable(origin)))
    else
        copy = origin
    end
    return copy
end

function miscUtils.distanceVector(from, to)
    return math.sqrt((to.x - from.x)^2 + (to.y - from.y)^2 + (to.z - from.z)^2)
end

function miscUtils.fromVector(vector) -- Returns table with x y z w from given Vector4
    return {x = vector.x, y = vector.y, z = vector.z, w = vector.w}
end

function miscUtils.fromQuaternion(quat) -- Returns table with i j k r from given Quaternion
    return {i = quat.i, j = quat.j, k = quat.k, r = quat.r}
end

function miscUtils.fromEuler(eul) -- Returns table with roll pitch yaw from given EulerAngles
    return {roll = eul.roll, pitch = eul.pitch, yaw = eul.yaw}
end

function miscUtils.getEuler(eul) -- Returns EulerAngles object from given table containing roll pitch yaw
    return(EulerAngles.new(eul.roll, eul.pitch, eul.yaw))
end

function miscUtils.getVector(tab) -- Returns Vector4 object from given table containing x y z w
    return(Vector4.new(tab.x, tab.y, tab.z, tab.w))
end

function miscUtils.getQuaternion(tab) -- Returns Quaternion object from given table containing i j k r
    return(Quaternion.new(tab.i, tab.j, tab.k, tab.r))
end

function miscUtils.indexValue(table, value)
    local index={}
    for k,v in pairs(table) do
        index[v]=k
    end
    return index[value]
end

function miscUtils.has_value(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function miscUtils.getIndex(tab, val)
    local index = nil
    for i, v in ipairs(tab) do
		if v == val then
			index = i
		end
    end
    return index
end

function miscUtils.removeItem(tab, val)
    table.remove(tab, miscUtils.getIndex(tab, val))
end

function miscUtils.addVector(v1, v2)
    return Vector4.new(v1.x + v2.x, v1.y + v2.y, v1.z + v2.z, v1.w + v2.w)
end

function miscUtils.subVector(v1, v2)
    return Vector4.new(v1.x - v2.x, v1.y - v2.y, v1.z - v2.z, v1.w - v2.w)
end

function miscUtils.multVector(v1, factor)
    return Vector4.new(v1.x * factor, v1.y * factor, v1.z * factor, v1.w * factor)
end

function miscUtils.addEuler(e1, e2)
    return EulerAngles.new(e1.roll + e2.roll, e1.pitch + e2.pitch, e1.yaw + e2.yaw)
end

function miscUtils.subEuler(e1, e2)
    return EulerAngles.new(e1.roll - e2.roll, e1.pitch - e2.pitch, e1.yaw - e2.yaw)
end

function miscUtils.multEuler(e1, factor)
    return EulerAngles.new(e1.roll * factor, e1.pitch * factor, e1.yaw * factor)
end

function miscUtils.isVector(v1, v2) -- Returns true if two vectors are the same
    return (v1.x == v2.x) and (v1.y == v2.y) and (v1.z == v2.z)
end

function miscUtils.spawnObject(path, pos, rot, appearance)
    local app = appearance or ""
    local transform = Game.GetPlayer():GetWorldTransform()
    transform:SetOrientation(rot)
    transform:SetPosition(pos)
    local entityID = exEntitySpawner.Spawn(path, transform, app)
    return entityID
end

return miscUtils