JsonData = {
    version = '1.0.2'
}
--===================
--CODE BY Boe6
--DO NOT DISTRIBUTE
--DO NOT COPY/REUSE WITHOUT EXPRESS PERMISSION
--DO NOT REUPLOAD TO OTHER SITES
--Feel free to ask via nexus/discord, I just dont want my stuff stolen :)
--=================== 

function JsonData.ReturnAllFromFolder(folder)
    local result = {}

    local files = dir(folder)
    for _, file in ipairs(files) do
        if file.name:match("%.json$") then
            local path = folder .. "/" .. file.name
            local f = io.open(path, "r")
            if f then
                local content = f:read("*a")
                f:close()
                local data = json.decode(content)
                if data then
                    for _, item in ipairs(data) do
                        local pos = item.position
                        local orient = item.orientation
                        local obj = {
                            id = item.id,
                            position = {x = pos.x, y = pos.y, z = pos.z},
                            orientation = {i = orient.i, j = orient.j, k = orient.k, r = orient.r}
                        }
                        table.insert(result, obj)
                    end
                end
            end
        end
    end

    return result
end


return JsonData