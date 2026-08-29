---@enum LogLevel
LogLevel = {
    Critical = 0,
    Error = 1,
    Warning = 2,
    Info = 3,
    Trace = 4,
    Debug = 5,
    Nothing = 6
}

-- Force the log level to be the same for all instances
MasterLogLevel = LogLevel.Error
-- Print debug messages to the console
PrintDebugMode = false

local Log = {}
Log.__index = Log

function Log:New()
    local obj = {}
    obj.setting_level = LogLevel.INFO
    obj.setting_file_name = "No Setting"
    return setmetatable(obj, self)
end

---@param level LogLevel
---@param file_name string
---@return boolean
function Log:SetLevel(level, file_name)

    if level < 0 or level > 5 or MasterLogLevel ~= LogLevel.Nothing then
        self.setting_level = MasterLogLevel
        self.setting_file_name = "[" .. file_name .. "]"
        return false
    else
        self.setting_level = level
        self.setting_file_name = "[" .. file_name .. "]"
        return true
    end

end

---@param level LogLevel
---@param message string
function Log:Record(level, message)

    local setting_level = self.setting_level
    if MasterLogLevel > setting_level then
        setting_level = MasterLogLevel
    end

    if level > setting_level then
        return
    end
    local level_name = "UNKNOWN"
    if level <= LogLevel.Debug then
        level_name = "DEBUG"
        if level <= LogLevel.Trace then
            level_name = "TRACE"
            if level <= LogLevel.Info then
                level_name = "INFO"
                if level <= LogLevel.Warning then
                    level_name = "WARNING"
                    if level <= LogLevel.Error then
                        level_name = "ERROR"
                        if level <= LogLevel.Critical then
                            level_name = "CRITICAL"
                        end
                    end
                end
            end
        end
        spdlog.info(self.setting_file_name .. "[" .. level_name .."]" .. message)
        if PrintDebugMode then
            print(self.setting_file_name .. "[" .. level_name .."]" .. message)
        end
    end

end

return Log