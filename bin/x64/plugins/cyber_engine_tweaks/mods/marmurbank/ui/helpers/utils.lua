local utils = {}

function utils.isSameInstance(a, b)
    return Game['OperatorEqual;IScriptableIScriptable;Bool'](a, b)
end

function utils.removeItem(tab, val)
    if not tab then return end
    for i, v in ipairs(tab) do
        if v == val then
            table.remove(tab, i)
            return
        end
    end
end

function utils.playSound(name, mult)
    local count = mult or 1
    for _ = 1, count do
        pcall(function()
            local audioEvent = SoundPlayEvent.new()
            audioEvent.soundName = name
            GetPlayer():QueueEvent(audioEvent)
        end)
    end
end

function utils.formatNumber(num)
    local n = tonumber(num) or 0
    local sign = ""
    if n < 0 then sign = "-"; n = math.abs(n) end
    local s = tostring(math.floor(n + 0.5))
    local out = ""
    local len = #s
    for i = 1, len do
        if i > 1 and (len - i + 1) % 3 == 0 then out = out .. "," end
        out = out .. s:sub(i, i)
    end
    return sign .. out
end

return utils
