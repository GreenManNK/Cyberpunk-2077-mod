CharacterLoader = {}

function CharacterLoader:new()
	return CharacterLoader
end

function CharacterLoader:Load()
    local foundCharacters = {}
    
    local function getFilesRecursively(_dir, tbl, ending)
      tbl = tbl or {}
      local files = dir(_dir)
      if #files == 0 then return tbl end
      for _, file in ipairs(files) do
        if file.type == typeDirectory then
          getFilesRecursively(_dir .. '/' .. file.name, tbl)
        elseif string.find(file.name, ending) then
          table.insert(tbl, _dir .. '/' .. file.name)
        end
      end
      return tbl
    end
     
    -- 1. Scan Mercs Folder
    local entityFiles = getFilesRecursively("./Characters", {}, '.json$')
    for _, filePath in ipairs(entityFiles) do
      local f = io.open(filePath, 'r')
      local contents = f:read('*a')
      f:close()
      
      -- Remove BOM if present
      if string.sub(contents, 1, 1) == '\239' then
        contents = string.sub(contents, 4)
      end
      
      local success, mercData = pcall(json.decode, contents)
      if success then 
        table.insert(foundCharacters, mercData)
      else
        print("[NightCityAllies] ERROR " .. filePath)
      end
    end
        
    -- 2. Scan AMM Chars
    local AMM = GetMod("AppearanceMenuMod")
	local NCA = GetMod("NightCityAllies") -- am lazy
    if AMM and NCA:Settings().loadAMMCharacters then
		--print("[NightCityAllies] Loading Custom AMM Characters")  
		local ammCharacters = AMM.API.GetAMMCharacters()
		local excludeList = {
			"AMM_Character.E3_V_Female",
			"AMM_Character.E3_V_Male",
			"AMM_Character.Hanako",
			"AMM_Character.Silverhand",
			"AMM_Character.Rache_Bartmoss",
			"AMM_Character.Songbird",
			"Custom_MM_Character.juby"
		}
		local alwaysExcludeList = {
			"AMM_Character.Nibbles",
			"AMM_Character.Nibbles_Sleeping_Belly_Up",
			"AMM_Character.Nibbles_Get_Pet",
			"AMM_Character.Nibbles_Jump_Down",
			"AMM_Character.Nibbles_Lie",
			"AMM_Character.Nibbles_Scratch",
			"AMM_Character.Nibbles_Self_Clean",
			"AMM_Character.Nibbles_Sit",
			"AMM_Character.Nibbles_Sleeping",
			"AMM_Character.Nibbles_Sleeping_01",
			"AMM_Character.Nibbles_Sleeping_02",
			"AMM_Character.Nibbles_Test",
		}
		for _, ammCharacter in ipairs(ammCharacters) do
			local isDefaultCharacter = false
			local isAlwaysExcludeCharacter = false
			for _, exclude in ipairs(excludeList) do
				if ammCharacter.record == exclude then
					isDefaultCharacter = true
					break
				end
			end
			for _, exclude in ipairs(alwaysExcludeList) do
				if ammCharacter.record == exclude then
					isAlwaysExcludeCharacter = true
					break
				end
			end
			if ((not isDefaultCharacter) or NCA:Settings().loadAMMDefaultCharacters) and not isAlwaysExcludeCharacter then
				table.insert(foundCharacters, ammCharacter)
			end
		end
	end
	
	return foundCharacters;
end

return CharacterLoader