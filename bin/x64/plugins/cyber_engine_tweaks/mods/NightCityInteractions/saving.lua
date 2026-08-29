saving = {}

function saving.fileExists(filename)
    local f=io.open(filename,"r")
    if (f~=nil) then io.close(f) return true else return false end
end

function saving.tryMakeSave(filePath, settings)
	if not saving.fileExists(filePath) then
        local file = io.open(filePath, "w")
        local jconfig = json.encode(settings)
        file:write(jconfig)
        file:close()
    end
end

function saving.loadFile(filePath)
    local file = io.open(filePath, "r")
    local saving = {}

    pcall(function ()
        saving = json.decode(file:read("*a"))
    end)
    file:close()

    return saving
end

function saving.saveFile(filePath, settings)
    local file = io.open(filePath, "w")
    local jconfig = json.encode(settings)
    file:write(jconfig)
    file:close()
end

function saving.checkData(filePath, settings)
    local file = saving.loadFile(filePath)

    for i, j in pairs(settings) do
        if file[i] == nil then
            file[i] = j
        end
    end

    saving.saveFile(filePath, file)
end

return saving