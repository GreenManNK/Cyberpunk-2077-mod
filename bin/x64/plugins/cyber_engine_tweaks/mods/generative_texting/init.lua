local hooked = false

-- Simple manual JSON formatter that actually works
local function prettyPrintJSON(content)
    if not content or content == "" then
        return content
    end
    
    if not (content:match("^%s*{") or content:match("^%s*%[")) then
        return content
    end
    
    local level = 0
    local result = {}
    local in_string = false
    local escape_next = false
    
    for i = 1, #content do
        local char = content:sub(i, i)
        
        if escape_next then
            table.insert(result, char)
            escape_next = false
        elseif char == '"' and not escape_next then
            in_string = not in_string
            table.insert(result, char)
        elseif char == '\\' and in_string then
            table.insert(result, char)
            escape_next = true
        elseif not in_string then
            if char == '{' or char == '[' then
                table.insert(result, char)
                level = level + 1
                table.insert(result, "\n" .. string.rep("  ", level))
            elseif char == '}' or char == ']' then
                level = level - 1
                table.insert(result, "\n" .. string.rep("  ", level))
                table.insert(result, char)
            elseif char == ',' then
                table.insert(result, char)
                table.insert(result, "\n" .. string.rep("  ", level))
            elseif char == ':' then
                table.insert(result, char)
                table.insert(result, " ")
            elseif char:match("%s") then
            else
                table.insert(result, char)
            end
        else
            table.insert(result, char)
        end
    end
    
    return table.concat(result)
end

-- Register hooks immediately on init
registerForEvent("onInit", function()
    print("[GT] Installing file save/load hooks...")
    
    -- ==================== CHAT STORAGE ====================
    
    -- CHAT STORAGE - SAVE
    Observe("PersistentChatStorage", "WriteJsonFile", function(self, filePath, content)
        local file = io.open("chats\\" .. filePath, "w")
        if file then
            local prettyContent = prettyPrintJSON(content)
            file:write(prettyContent)
            file:close()
            print("[GT-Chat] ✓ Saved (formatted): chats\\" .. filePath)
            return true
        else
            print("[GT-Chat] ✗ Failed to save: chats\\" .. filePath)
            return false
        end
    end)
    
    -- CHAT STORAGE - LOAD
    Override("PersistentChatStorage", "ReadJsonFile", function(self, filePath)
        local file = io.open("chats\\" .. filePath, "r")
        if file then
            local content = file:read("*all")
            file:close()
            
            local compacted = content:gsub("%s+", " "):gsub(" *([{}%[%],:]) *", "%1")
            
            print("[GT-Chat] ✓ Loaded: chats\\" .. filePath .. " (" .. #content .. " bytes)")
            
            return compacted
        else
            print("[GT-Chat] ✗ File not found: chats\\" .. filePath)
            return ""
        end
    end)

    -- ==================== MEMORY STORAGE ====================
    
    -- MEMORY STORAGE - SAVE
    Observe("MemoryStorage", "WriteJsonFile", function(self, filePath, content)
        local fullPath = "chats\\" .. filePath
        
        print("[GT-Memory] Writing to: " .. fullPath)
        print("[GT-Memory] Content length: " .. #content)
        
        local file = io.open(fullPath, "w")
        if file then
            local prettyContent = prettyPrintJSON(content)
            file:write(prettyContent)
            file:close()
            print("[GT-Memory] ✓ Saved: " .. fullPath)
            return true
        else
            print("[GT-Memory] ✗ Failed to save: " .. fullPath)
            return false
        end
    end)
    
    -- MEMORY STORAGE - LOAD
   Override("MemoryStorage", "ReadJsonFile", function(self, filePath)
        local fullPath = "chats\\" .. filePath
        local file = io.open(fullPath, "r")
        
        if file then
            local content = file:read("*all")
            file:close()

            local compacted = content:gsub("%s+", " "):gsub(" *([{}%[%],:]) *", "%1")
            
            print("[GT-Memory] ✓ Loaded: " .. fullPath)
            return compacted
        else
            print("[GT-Memory] ✗ File not found: " .. fullPath)
            return ""
        end
    end)

    -- ==================== LONG TERM MEMORY STORAGE ====================

    -- LONG TERM MEMORY - SAVE
    Observe("LongTermMemoryStorage", "WriteJsonFile", function(self, filePath, content)
        local file = io.open("chats\\" .. filePath, "w")
        if file then
            local prettyContent = prettyPrintJSON(content)
            file:write(prettyContent)
            file:close()
            print("[GT-LongTerm] ✓ Saved: chats\\" .. filePath)
            return true
        else
            print("[GT-LongTerm] ✗ Failed to save: chats\\" .. filePath)
            return false
        end
    end)

    -- LONG TERM MEMORY - LOAD
    Override("LongTermMemoryStorage", "ReadJsonFile", function(self, filePath)
        local file = io.open("chats\\" .. filePath, "r")
        if file then
            local content = file:read("*all")
            file:close()
            local compacted = content:gsub("%s+", " "):gsub(" *([{}%[%],:]) *", "%1")
            print("[GT-LongTerm] ✓ Loaded: chats\\" .. filePath)
            return compacted
        else
            print("[GT-LongTerm] File not found (normal if first run): chats\\" .. filePath)
            return ""
        end
    end)
    


    -- ==================== USER INI SYNC ====================

    Observe("GenerativeTextingSystem", "OnCharacterSelected", function(self, characterName)
        print("[GT-INI] OnCharacterSelected fired: " .. tostring(characterName))
    end)

    Observe("GenerativeTextingSystem", "OnCharacterSelected", function(self, characterName)
    print("[GT-INI] Trying to open: D:\\GOG Galaxy\\Games\\Cyberpunk 2077\\red4ext\\plugins\\mod_settings\\user.ini")
    local iniPath = "D:/GOG Galaxy/Games/Cyberpunk 2077/red4ext/plugins/mod_settings/test.ini"
    local file = io.open(iniPath, "r")
    if file then
        print("[GT-INI] ✓ Found test.ini")
        file:close()
    else
        print("[GT-INI] ✗ Could not find test.ini")
    end
end)


    -- Update user.ini character when NPC is selected from phone UI
--[[      Observe("GenerativeTextingSystem", "OnCharacterSelected", function(self, characterName)
        print("[GT-INI] OnCharacterSelected fired: " .. tostring(characterName))
        local iniPath = "D:\\GOG Galaxy\\Games\\Cyberpunk 2077\\red4ext\\plugins\\mod_settings\\user.ini"
        local file = io.open(iniPath, "r")
        if file then
            local content = file:read("*all")
            file:close()
            content = content:gsub("(character = )(%S+)", "%1" .. characterName)
            local writeFile = io.open(iniPath, "w")
            if writeFile then
                writeFile:write(content)
                writeFile:close()
                print("[GT-INI] ✓ Updated character to: " .. characterName)
            end
        else
            print("[GT-INI] ✗ Could not find user.ini")
        end
    end)
]]


    -- V BACKGROUND - LOAD
    Override("VBackgroundStorage", "ReadVBackground", function(self)
        local file = io.open("chats\\v_background.json", "r")
        if file then
            local content = file:read("*all")
            file:close()
            print("[GT-VBackground] ✓ Loaded v_background.json")
            return content
        else
            print("[GT-VBackground] v_background.json not found")
            return ""
        end
    end)

    print("[GT] ✓ All hooks installed")
end)