local Cron = { version = '1.0.3-zero-engine-local' }


local localTimers = {}
local localCounter = 0
local localPrune = false

local function normalizeTimerId(timerId)
    if type(timerId) == 'table' then
        return timerId.id
    end
    return timerId
end

local function localAddTimer(timeout, recurring, callback, args)
    if type(timeout) ~= 'number' then return nil end
    if timeout < 0 then return nil end
    if type(recurring) ~= 'boolean' then return nil end

    if type(callback) ~= 'function' then
        if type(args) == 'function' then
            callback, args = args, callback
        else
            return nil
        end
    end

    if type(args) ~= 'table' then
        args = { arg = args }
    end

    localCounter = localCounter + 1

    local timer = {
        id = localCounter,
        callback = callback,
        recurring = recurring,
        timeout = timeout,
        active = true,
        halted = false,
        delay = timeout,
        args = args,
    }

    if args.id == nil then args.id = timer.id end
    if args.interval == nil then args.interval = timer.timeout end
    if args.Halt == nil then args.Halt = Cron.Halt end
    if args.Pause == nil then args.Pause = Cron.Pause end
    if args.Resume == nil then args.Resume = Cron.Resume end

    table.insert(localTimers, timer)
    return timer.id
end

local function addTimer(timeout, recurring, callback, data)
    return localAddTimer(timeout, recurring, callback, data)
end

function Cron.After(timeout, callback, data)
    return addTimer(timeout, false, callback, data)
end

function Cron.Every(timeout, callback, data)
    return addTimer(timeout, true, callback, data)
end

function Cron.NextTick(callback, data)
    return localAddTimer(0, false, callback, data)
end

function Cron.Halt(timerId)
    local id = normalizeTimerId(timerId)

    for _, timer in ipairs(localTimers) do
        if timer.id == id then
            timer.active = false
            timer.halted = true
            localPrune = true
            break
        end
    end
end

function Cron.Pause(timerId)
    local id = normalizeTimerId(timerId)

    for _, timer in ipairs(localTimers) do
        if timer.id == id then
            if not timer.halted then timer.active = false end
            break
        end
    end
end

function Cron.Resume(timerId)
    local id = normalizeTimerId(timerId)

    for _, timer in ipairs(localTimers) do
        if timer.id == id then
            if not timer.halted then timer.active = true end
            break
        end
    end
end

function Cron.Update(delta)
    delta = tonumber(delta) or 0.0
    if delta < 0.0 then delta = 0.0 end
    if delta > 1.0 then delta = 1.0 end
    if #localTimers == 0 then return end

    for _, timer in ipairs(localTimers) do
        if timer.active then
            timer.delay = timer.delay - delta
            if timer.delay <= 0 then
                if timer.recurring then
                    timer.delay = timer.delay + timer.timeout
                else
                    timer.active = false
                    timer.halted = true
                    localPrune = true
                end
                timer.callback(timer.args)
            end
        end
    end

    if localPrune then
        localPrune = false
        for i = #localTimers, 1, -1 do
            if localTimers[i].halted then
                table.remove(localTimers, i)
            end
        end
    end
end

function Cron.IsZeroEngineBacked()
    return false
end

return Cron
