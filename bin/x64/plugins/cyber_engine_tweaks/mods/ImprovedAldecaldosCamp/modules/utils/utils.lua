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

function miscUtils.split(s, delimiter) --https://www.codegrepper.com/code-examples/lua/lua+split+string+by+space
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function miscUtils.isSameInstance(a, b)
	return Game['OperatorEqual;IScriptableIScriptable;Bool'](a, b)
end

---@param name string Name of the sound to play
---@param target ? gameObject Target of the sound (default to PlayerPuppet)
---@param mult ? number Integer indicates number of time the sound will be played to increase intensity (default 1). If set to 0, the sound wont play
---@param seekTime ? number Starting time code. Negative number won't have effect (default 0)
function miscUtils.playSound(name, target, mult, seekTime)
    local m = mult or 1
    local t = target or GetPlayer()

    for _ = 1, m do
        local audioEvent = SoundPlayEvent.new ()
        audioEvent.soundName = CName.new(name)
        audioEvent.seekTime = seekTime or 0
        t:QueueEvent(audioEvent)
    end

    t = nil
end

function miscUtils.stopSound(name, target)
    local evt = SoundStopEvent.new()
    evt.soundName = name
    target:QueueEvent(evt)
end

function miscUtils.spendMoney(amount)
    local moneyId = gameItemID.FromTDBID(TweakDBID.new("Items.money"))
    Game.GetTransactionSystem():RemoveItem(Game.GetPlayer(), moneyId, math.floor(amount + 0.5))
end

function miscUtils.wrap(text, chars)
    local str = ""
    local shouldBreak = false
    local n = 1
    for i = 1, #text do
        local c = text:sub(i,i)
        if n > chars then
            shouldBreak = true
        end
        if shouldBreak and i ~= 0 and text:sub(i - 1,i - 1) == " " then
            n = 0
            shouldBreak = false
            str = tostring(str .. "\n")
        end
        str = tostring(str .. c)
        n = n + 1
    end

    return str
end

function miscUtils.removeOccluders(elevator)
    if not elevator then return end

    local front = elevator:FindComponentByName("FrontDoorOccluder")
    local back = elevator:FindComponentByName("BackDoorOccluder")
    if front then front:Toggle(false) end
    if back then back:Toggle(false) end
end

function miscUtils.toggleElevatorDoors(obj, state)
    if not obj then return end
    if state then
        obj:UpdateAnimState(true, true, true)
        miscUtils.playSound("dev_elevator_01_doors_open", obj)
    else
        obj:UpdateAnimState(false, false, false)
        miscUtils.playSound("dev_elevator_01_doors_close", obj)
    end
end

function miscUtils.applyStatus(effect)
    Game.GetStatusEffectSystem():ApplyStatusEffect(GetPlayer():GetEntityID(), effect, GetPlayer():GetRecordID(), GetPlayer():GetEntityID())
end

function miscUtils.removeStatus(effect)
    Game.GetStatusEffectSystem():RemoveStatusEffect(GetPlayer():GetEntityID(), effect)
end

return miscUtils