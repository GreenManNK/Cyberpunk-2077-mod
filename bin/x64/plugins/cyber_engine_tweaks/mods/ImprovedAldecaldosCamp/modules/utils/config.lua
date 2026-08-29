config = {}

function config.fileExists(filename)
    local f=io.open(filename,"r")
    if (f~=nil) then io.close(f) return true else return false end
end

function config.tryCreateConfig(path, data)
	if config.fileExists(path) then return end
    local file = io.open(path, "w")
    local jconfig = json.encode(data)
    file:write(jconfig)
    file:close()
end

function config.loadFile(path)
    local file = io.open(path, "r")
    local config = {}

    pcall(function ()
        config = json.decode(file:read("*a"))
    end)
    file:close()

    return config
end

function config.saveFile(path, data)
    local file = io.open(path, "w")
    local jconfig = json.encode(data)
    file:write(jconfig)
    file:close()
end

function config.backwardComp(path, data)
    local f = config.loadFile(path)

    -- Control: if the config JSON is in old format (1.3.1 and before) settings as properties, replace the whole file content with `data`.
    if type(f) == "table" and (f.v_tent__door ~= nil) then
        config.saveFile(path, data)
        return
    else
        for k, e in ipairs(data) do
            if f[k] == nil then
                f[k] = e
            end
        end
    end

    config.saveFile(path, f)
end

return config