
local Calendar = {}

Calendar.MAX_GAMEPLAY_YEAR = 2080
Calendar.MAX_GAMEPLAY_MONTH = 1
Calendar.MAX_GAMEPLAY_DAY = 1
Calendar.MAX_MAIN_STORY_ENGINE_DAY = 979
Calendar.PHANTOM_STANDALONE_STORY_DAY_OFFSET = 48

local function safeCall(fn)
    local ok, result = pcall(fn)
    if ok then return result end
    return nil
end

local function isLeapYear(year)
    return (year % 400 == 0) or ((year % 4 == 0) and (year % 100 ~= 0))
end

local function daysInMonth(year, month)
    if month == 2 then return isLeapYear(year) and 29 or 28 end
    if month == 4 or month == 6 or month == 9 or month == 11 then return 30 end
    return 31
end

local function isLaterThanMaximum(year, month, day)
    return year > Calendar.MAX_GAMEPLAY_YEAR
        or (year == Calendar.MAX_GAMEPLAY_YEAR and month > Calendar.MAX_GAMEPLAY_MONTH)
        or (year == Calendar.MAX_GAMEPLAY_YEAR
            and month == Calendar.MAX_GAMEPLAY_MONTH
            and day > Calendar.MAX_GAMEPLAY_DAY)
end

local function clampGameplayDate(year, month, day)
    local y = math.floor(tonumber(year) or 0)
    local m = math.floor(tonumber(month) or 0)
    local d = math.floor(tonumber(day) or 0)
    if isLaterThanMaximum(y, m, d) then
        return Calendar.MAX_GAMEPLAY_YEAR, Calendar.MAX_GAMEPLAY_MONTH, Calendar.MAX_GAMEPLAY_DAY, true
    end
    return y, m, d,
        y == Calendar.MAX_GAMEPLAY_YEAR
            and m == Calendar.MAX_GAMEPLAY_MONTH
            and d == Calendar.MAX_GAMEPLAY_DAY
end

local function addDays(year, month, day, amount)
    local y, m, d = clampGameplayDate(year, month, day)
    local remaining = math.floor(tonumber(amount) or 0)

    if remaining >= 0 then
        while remaining > 0 do
            if isLaterThanMaximum(y, m, d)
                or (y == Calendar.MAX_GAMEPLAY_YEAR
                    and m == Calendar.MAX_GAMEPLAY_MONTH
                    and d >= Calendar.MAX_GAMEPLAY_DAY) then
                return Calendar.MAX_GAMEPLAY_YEAR, Calendar.MAX_GAMEPLAY_MONTH, Calendar.MAX_GAMEPLAY_DAY
            end
            local leftInMonth = daysInMonth(y, m) - d
            if remaining <= leftInMonth then
                d = d + remaining
                remaining = 0
            else
                remaining = remaining - leftInMonth - 1
                d = 1
                m = m + 1
                if m > 12 then
                    m = 1
                    y = y + 1
                end
            end
        end
    else
        while remaining < 0 do
            if d + remaining >= 1 then
                d = d + remaining
                remaining = 0
            else
                remaining = remaining + d
                m = m - 1
                if m < 1 then
                    m = 12
                    y = y - 1
                end
                d = daysInMonth(y, m)
            end
        end
    end

    return clampGameplayDate(y, m, d)
end

local function getQuestFact(name)
    local value = safeCall(function()
        if not Game or type(Game.GetQuestsSystem) ~= "function" then return 0 end
        local quests = Game.GetQuestsSystem()
        if not quests then return 0 end
        return quests:GetFactStr(tostring(name))
    end)
    if value == nil then
        value = safeCall(function()
            if not Game or type(Game.GetQuestsSystem) ~= "function" then return 0 end
            local quests = Game.GetQuestsSystem()
            if not quests then return 0 end
            return quests:GetFact(CName.new(tostring(name)))
        end)
    end
    return math.floor(tonumber(value) or 0)
end

local function anyFact(names)
    for _, name in ipairs(names or {}) do
        if getQuestFact(name) > 0 then return true end
    end
    return false
end

local function getEngineTimeParts()
    local day, hour, minute, second = 0, 0, 0, 0
    safeCall(function()
        local time = Game.GetTimeSystem():GetGameTime()
        day = math.max(math.floor(tonumber(time:Days()) or 0), 0)
        hour = math.max(math.min(math.floor(tonumber(time:Hours()) or 0), 23), 0)
        minute = math.max(math.min(math.floor(tonumber(time:Minutes()) or 0), 59), 0)
        second = math.max(math.min(math.floor(tonumber(time:Seconds()) or 0), 59), 0)
    end)
    return day, hour, minute, second
end

local function detectLifePath()
    local player = safeCall(function()
        if Game and type(Game.GetPlayer) == "function" then return Game.GetPlayer() end
        if type(GetPlayer) == "function" then return GetPlayer() end
        return nil
    end)
    local system = safeCall(function()
        if Game and type(Game.GetPlayerDevelopmentSystem) == "function" then
            return Game.GetPlayerDevelopmentSystem()
        end
        if Game and type(Game.GetScriptableSystemsContainer) == "function" then
            local container = Game.GetScriptableSystemsContainer()
            return container and container:Get("PlayerDevelopmentSystem") or nil
        end
        return nil
    end)
    local value = player and system and safeCall(function() return system:GetLifePath(player) end) or nil

    if type(value) == "number" then
        if value == 0 then return "corporate" end
        if value == 1 then return "nomad" end
        if value == 2 then return "streetkid" end
    end

    local text = string.lower(tostring(value or ""))
    if string.find(text, "corpor", 1, true) or string.find(text, "corpo", 1, true) then return "corporate" end
    if string.find(text, "nomad", 1, true) then return "nomad" end
    if string.find(text, "street", 1, true) then return "streetkid" end

    if getQuestFact("ngplus_is_corpo") > 0 then return "corporate" end
    if getQuestFact("ngplus_is_nomad") > 0 then return "nomad" end
    if getQuestFact("ngplus_is_streetkid") > 0 then return "streetkid" end
    return "unknown"
end

local function isPostMontage()
    return anyFact({
        "q000_done", "prologue_done", "prologue_completed",
        "lifepath_prologue_done", "lifepath_prologue_completed",
    })
end

local function isPhantomLibertyStandalone(engineDay)
    if engineDay > 1 or getQuestFact("q005_done") <= 0 then return false end
    return anyFact({ "q101_v_reached_pills", "q101_talking_to_johnny", "q101_done" })
end

local function normalizeDateFormat(value)
    local format = math.floor(tonumber(value) or 3)
    if format == 1 or format == 2 or format == 3 then return format end
    return 3
end

local function getChronologyStatus()
    if type(GetMod) ~= "function" then return nil end
    local api = safeCall(function() return GetMod("NightCityChronology") end)
    if not api or type(api.GetStatus) ~= "function" then return nil end

    local status = safeCall(function() return api.GetStatus() end)
    if type(status) ~= "table" then
        status = safeCall(function() return api:GetStatus() end)
    end
    if type(status) ~= "table" then return nil end

    local year = math.floor(tonumber(status.year) or 0)
    local month = math.floor(tonumber(status.month) or 0)
    local day = math.floor(tonumber(status.day) or 0)
    if year < 1 or month < 1 or month > 12 or day < 1 or day > daysInMonth(year, month) then
        return nil
    end
    return status
end

local function getChronologyStoryDate(storyDay)
    if type(GetMod) ~= "function" then return nil end
    local api = safeCall(function() return GetMod("NightCityChronology") end)
    if not api or type(api.GetDateForStoryDay) ~= "function" then return nil end

    local result = safeCall(function() return api.GetDateForStoryDay(storyDay) end)
    if type(result) ~= "table" then
        result = safeCall(function() return api:GetDateForStoryDay(storyDay) end)
    end
    if type(result) ~= "table" then return nil end

    local year = math.floor(tonumber(result.year) or 0)
    local month = math.floor(tonumber(result.month) or 0)
    local day = math.floor(tonumber(result.day) or 0)
    if year < 1 or month < 1 or month > 12 or day < 1 or day > daysInMonth(year, month) then
        return nil
    end
    year, month, day = clampGameplayDate(year, month, day)
    return { year = year, month = month, day = day }
end

local function standaloneDateForEngineDay(engineDay, phase, lifepath, source)
    if phase == "prologue" then
        local dates = {
            nomad = { 2076, 10, 24 },
            streetkid = { 2076, 10, 26 },
            corporate = { 2076, 10, 27 },
            unknown = { 2076, 10, 26 },
        }
        local start = dates[lifepath] or dates.unknown
        return addDays(start[1], start[2], start[3], engineDay)
    end

    if string.find(tostring(source or ""), "Phantom Liberty", 1, true) then
        return addDays(2077, 6, 16, engineDay)
    end

    return addDays(2077, 4, 29, engineDay - 2)
end

local function getStandaloneContext(engineDay, hour, minute, second)
    local lifepath = detectLifePath()
    local year, month, day
    local phase = "main_story"
    local source = "Marmur standalone story calendar"

    if not isPostMontage() then
        local dates = {
            nomad = { 2076, 10, 24 },
            streetkid = { 2076, 10, 26 },
            corporate = { 2076, 10, 27 },
            unknown = { 2076, 10, 26 },
        }
        local start = dates[lifepath] or dates.unknown
        year, month, day = addDays(start[1], start[2], start[3], engineDay)
        phase = "prologue"
        source = "Marmur standalone lifepath calendar"
    elseif isPhantomLibertyStandalone(engineDay) then
        year, month, day = addDays(2077, 6, 16, engineDay)
        source = "Marmur standalone Phantom Liberty calendar"
    else
        year, month, day = addDays(2077, 4, 29, engineDay - 2)
    end

    year, month, day = clampGameplayDate(year, month, day)

    return {
        synced = false,
        source = source,
        engineDay = engineDay,
        year = year,
        month = month,
        day = day,
        hour = hour,
        minute = minute,
        second = second,
        secondOfDay = (hour * 3600) + (minute * 60) + second,
        dateFormat = 3,
        use12Hour = true,
        calendarPhase = phase,
        lifepath = lifepath,
    }
end

function Calendar.getContext()
    local engineDay, engineHour, engineMinute, engineSecond = getEngineTimeParts()
    local status = getChronologyStatus()
    if status then
        local secondOfDay = math.max(math.floor(tonumber(status.secondOfDay) or ((engineHour * 3600) + (engineMinute * 60) + engineSecond)), 0) % 86400
        local hour = math.floor(secondOfDay / 3600)
        local minute = math.floor((secondOfDay % 3600) / 60)
        local second = secondOfDay % 60
        local year, month, day, atCalendarEnd = clampGameplayDate(status.year, status.month, status.day)
        return {
            synced = true,
            source = "Night City Chronology",
            engineDay = math.max(math.floor(tonumber(status.engineStoryDay) or engineDay), 0),
            canonicalDay = tonumber(status.canonicalDay),
            year = year,
            month = month,
            day = day,
            hour = hour,
            minute = minute,
            second = second,
            secondOfDay = secondOfDay,
            dateFormat = normalizeDateFormat(status.dateFormat),
            use12Hour = status.use12Hour ~= false,
            calendarPhase = tostring(status.calendarPhase or "main_story"),
            chronologyCalendarSource = tostring(status.calendarSource or ""),
            lifepath = tostring(status.lifepath or "unknown"),
            chronologyVersion = tostring(status.version or ""),
            atCalendarEnd = atCalendarEnd or status.atCalendarEnd == true,
        }
    end
    return getStandaloneContext(engineDay, engineHour, engineMinute, engineSecond)
end

function Calendar.dateForEngineDay(engineDay, context)
    local numericDay = tonumber(engineDay)
    if numericDay == nil or numericDay < 0 then return nil end
    local targetDay = math.floor(numericDay)
    local ctx = context or Calendar.getContext()
    local currentEngineDay = math.max(math.floor(tonumber(ctx.engineDay) or targetDay), 0)
    local year = math.floor(tonumber(ctx.year) or 2077)
    local month = math.floor(tonumber(ctx.month) or 4)
    local day = math.floor(tonumber(ctx.day) or 29)
    local y, m, d

    if ctx.synced == true
        and ctx.atCalendarEnd == true
        and tostring(ctx.calendarPhase or "") == "prologue" then
        y, m, d = standaloneDateForEngineDay(
            targetDay,
            "prologue",
            tostring(ctx.lifepath or "unknown"),
            ctx.chronologyCalendarSource
        )
    end

    if ctx.synced == true
        and tostring(ctx.calendarPhase or "") == "main_story"
        and tonumber(ctx.canonicalDay) ~= nil then
        local storyDay
        if ctx.atCalendarEnd == true then
            if string.find(tostring(ctx.chronologyCalendarSource or ""), "Phantom Liberty", 1, true) then
                storyDay = Calendar.PHANTOM_STANDALONE_STORY_DAY_OFFSET + targetDay
            else
                storyDay = targetDay - 2
            end
        else
            storyDay = math.floor(tonumber(ctx.canonicalDay) or 0) + targetDay - currentEngineDay
        end
        local authorityDate = getChronologyStoryDate(storyDay)
        if authorityDate then
            y, m, d = authorityDate.year, authorityDate.month, authorityDate.day
        end
    end

    if not y and ctx.synced ~= true then
        y, m, d = standaloneDateForEngineDay(
            targetDay,
            tostring(ctx.calendarPhase or "main_story"),
            tostring(ctx.lifepath or "unknown"),
            ctx.source
        )
    end

    if not y then
        y, m, d = addDays(year, month, day, targetDay - currentEngineDay)
    end
    y, m, d = clampGameplayDate(y, m, d)
    return {
        year = y,
        month = m,
        day = d,
        engineDay = targetDay,
        dateFormat = normalizeDateFormat(ctx.dateFormat),
        synced = ctx.synced == true,
        source = ctx.source,
    }
end

function Calendar.formatDate(year, month, day, dateFormat, includeYear)
    year, month, day = clampGameplayDate(year, month, day)
    local format = normalizeDateFormat(dateFormat)
    if includeYear == false then
        if format == 1 then return string.format("%02d/%02d", month, day) end
        if format == 2 then return string.format("%02d/%02d", day, month) end
        return string.format("%02d/%02d", month, day)
    end
    if format == 1 then return string.format("%04d/%02d/%02d", year, month, day) end
    if format == 2 then return string.format("%02d/%02d/%04d", day, month, year) end
    return string.format("%02d/%02d/%04d", month, day, year)
end

function Calendar.formatTime(hour, minute, use12Hour, includeSeconds, second)
    local hour24 = math.floor(tonumber(hour) or 0) % 24
    if hour24 < 0 then hour24 = hour24 + 24 end
    local minuteValue = math.max(math.min(math.floor(tonumber(minute) or 0), 59), 0)
    local secondValue = math.max(math.min(math.floor(tonumber(second) or 0), 59), 0)
    if use12Hour ~= false then
        local suffix = hour24 >= 12 and "PM" or "AM"
        local hour12 = hour24 % 12
        if hour12 == 0 then hour12 = 12 end
        if includeSeconds == true then
            return string.format("%d:%02d:%02d %s", hour12, minuteValue, secondValue, suffix)
        end
        return string.format("%d:%02d %s", hour12, minuteValue, suffix)
    end
    if includeSeconds == true then
        return string.format("%02d:%02d:%02d", hour24, minuteValue, secondValue)
    end
    return string.format("%02d:%02d", hour24, minuteValue)
end

function Calendar.formatEngineDay(engineDay, context, includeYear)
    local date = Calendar.dateForEngineDay(engineDay, context)
    if not date then return "Date unavailable" end
    return Calendar.formatDate(date.year, date.month, date.day, date.dateFormat, includeYear)
end

function Calendar.formatEngineDateTime(engineDay, hour, minute, context, includeYear, separator)
    local ctx = context or Calendar.getContext()
    local dateText = Calendar.formatEngineDay(engineDay, ctx, includeYear)
    local timeText = Calendar.formatTime(hour, minute, ctx.use12Hour, false, 0)
    return dateText .. (separator or " • ") .. timeText
end

function Calendar.formatMinuteStamp(stamp, context, includeYear)
    local value = math.floor(tonumber(stamp) or -1)
    if value < 0 then return "Not scheduled" end
    local engineDay = math.floor(value / 1440)
    local minuteOfDay = value - (engineDay * 1440)
    local hour = math.floor(minuteOfDay / 60)
    local minute = minuteOfDay - (hour * 60)
    return Calendar.formatEngineDateTime(engineDay, hour, minute, context, includeYear)
end

function Calendar.formatCurrentDateTime(context, includeYear)
    local ctx = context or Calendar.getContext()
    local dateText = Calendar.formatDate(ctx.year, ctx.month, ctx.day, ctx.dateFormat, includeYear)
    local timeText = Calendar.formatTime(ctx.hour, ctx.minute, ctx.use12Hour, false, ctx.second)
    return dateText .. " • " .. timeText
end

return Calendar
