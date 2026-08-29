ModuleLoader = {}

function ModuleLoader:new()
  return ModuleLoader
end

local function getFilesRecursively(_dir, tbl, ending)
    tbl = tbl or {}

    local files = dir(_dir)
    if #files == 0 then return tbl end

    for _, file in ipairs(files) do
        if file.type == typeDirectory then
            getFilesRecursively(_dir .. '/' .. file.name, tbl, ending)

        elseif string.find(file.name, ending) then
            table.insert(tbl, _dir .. '/' .. file.name)
        end
    end

    return tbl
end

function ModuleLoader:LoadInteractions()
    local foundInteractions = {}
    local interactionFiles = getFilesRecursively("./Interactions", {}, '.lua$')
    for _, filePath in ipairs(interactionFiles) do
        local data = require(filePath)
        if type(data) == "function" then
            table.insert(foundInteractions, data)
        elseif data then
            for _, interactionData in ipairs(data) do
                -- foreach
                table.insert(foundInteractions, interactionData)
            end
        end
    end

    return foundInteractions
end

function ModuleLoader:LoadModules()
    local foundModules = {}
    local moduleFiles = getFilesRecursively("./Modules", {}, '.lua$')
    for _, filePath in ipairs(moduleFiles) do
        local module = require(filePath)
        table.insert(foundModules, module)
    end
    return foundModules
end

return ModuleLoader