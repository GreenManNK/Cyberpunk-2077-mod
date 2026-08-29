-- ============================================================================
-- MOD: NPC Outfit Manager (CET Overlay Edition) - EVOLVING WARDROBE
-- ============================================================================

local Cron = require("External/Cron.lua")

local modName = "NPC Outfit Manager"
local jsonFileName = "npc_outfits.json"
local looksJsonFileName = "npc_saved_looks.json"

local refitsJsonFileName = "archive_contents_database.json"
local refitsDatabase = {}

-- === NOVAS VARIÁVEIS PARA O SISTEMA DE SAVE DE REFITS ===
local savedRefitsFileName = "npc_saved_refits.json"
local savedRefits = {} -- Estrutura: savedRefits[NPC_Hash][ItemName] = MeshPath
local isRefitViewerWindowOpen = false
local hasMouseEnteredRefitViewer = false
-- ========================================================

-- === NOVAS VARIÁVEIS PARA O SISTEMA DE CHANGE BODY TYPE ===
local baseGamePathsFileName = "base_game_paths.json"
local favoriteBodyTypesFileName = "npc_favorite_body_types.json"
local isBodyTypeWindowOpen = false
local hasMouseEnteredBodyType = false

local bodyTypeMeshesList = {}        -- Guarda os .mesh que começam/contêm "t0_"
local savedFavoriteBodyTypes = {}    -- Guarda as meshes favoritas
local activeBodyTypes = {}           -- Guarda o corpo ativo por NPC: activeBodyTypes[targetHash] = meshPath
isModdedMap = {}
-- ==========================================================

-- === NOVAS VARIÁVEIS PARA O SISTEMA DE HAIRS ===
local isHairSpawnerWindowOpen = false
local hasMouseEnteredHairSpawner = false
local favoriteHairsFileName = "npc_favorite_hairs.json"
local savedFavoriteHairs = {}
local hairMeshesList = {} -- Vai guardar apenas os .mesh com "hair"
-- ===============================================

local hiddenRefits = {}       -- NEW: Stores the visual state of the Refit Hide/Show button

-- State control for the new Refits system
local refitDropdownOpen = {}  -- Stores if the expanded dropdown is open per slot
local currentRefitIndex = {}  -- Stores the current rotation index for left click
local activeRefits = {}       -- NEW: Stores the currently applied refit mesh path per slot
local assignedMeshes = {}     -- FIXED: Tracks component assignments to prevent slot overlapping/hijacking

-- Global Wardrobe: { ["Head"] = {"Item1", "Item2"}, ["Torso"] = {"Item3"}, ["_FAVORITES_"] = {["Items.X"] = true} }
local savedOutfits = {}

-- UI Window State
local isMainWindowOpen = false 
local isCustomizeWindowOpen = false
local isResetConfirmWindowOpen = false

-- State Variables for New Features (Audio & Anims)
local isSoundEnabled = true     -- Controls if audio is active
local isAnimPlaying = false     -- Controls if the animation loop is active
local animTimer = 0.0           -- 30-second timer

-- State Variables for New Features
local filterFavoritesOnly = false
local globalSearchOpen = false        -- Controls if the global search bar is open
local globalSearchQuery = ""          -- Stores the globally searched text
local justToggledGlobalSearch = false -- Prevents the bar from closing immediately when clicking the button
local hiddenSlots = {}   -- Remembers hidden slots (Eye icon)
local lockedSlots = {}   -- Remembers locked slots (Lock icon)
local isSearching = {}   -- Remembers slots with search bar open
local searchQueries = {} -- Stores the text typed in each slot's search bar

-- State Variables for Body Hide Window
local isBodyHideWindowOpen = false
local hasMouseEnteredBodyHide = false
local customizeWindowPos = { x = 0, y = 0 }
local customizeWindowSize = { x = 0, y = 0 }

-- Current rotation string mapping per NPC and per Slot
local currentSelections = {}

-- Table to store the 5 temporary Looks per NPC Hash
local savedLooks = {}

-- State variable for the function to copy V's clothes to the NPC
local savedVOutfitForNPC = nil

-- Utility function to copy slot configurations without creating memory references
local function CopySelections(orig)
    local copy = {}
    if type(orig) == 'table' then
        for k, v in pairs(orig) do
            copy[k] = v
        end
    end
    return copy
end

-- State Variables for Body Hide Window
local bodyPartStates = {} -- Remembers the state (hidden = true/false) per NPC and body part
local bodyPartPrefixes = {
    Head = {"h0_", "h1_", "hx_", "he_", "ht_"},
    Hair = {"hh_"},
    Torso = {"t0_", "t1_", "t2_"},
    Arms = {"a0_", "a1_"},
    Hands = {"g0_", "g1_", "g2_"},
    Legs = {"l0_", "l1_", "l2_", "p0_", "p1_"},
    Feet = {"s0_", "s1_", "f0_", "f1_"}
}

-- List of all organized slots (Complete: Base Game + Equipment EX)
local allSlots = {
    -- Base Game Slots
    { id = "AttachmentSlots.Head", name = "Head", isBase = true },
    { id = "AttachmentSlots.Eyes", name = "Eyes", isBase = true },
    { id = "AttachmentSlots.Chest", name = "Chest", isBase = true },
    { id = "AttachmentSlots.Torso", name = "Torso", isBase = true },
    { id = "AttachmentSlots.Legs", name = "Legs", isBase = true },
    { id = "AttachmentSlots.Feet", name = "Feet", isBase = true },
    { id = "AttachmentSlots.UnderwearTop", name = "UnderwearTop", isBase = true },
    { id = "AttachmentSlots.UnderwearBottom", name = "UnderwearBottom", isBase = true },
    
    -- Equipment EX Slots
    { id = "OutfitSlots.Head", name = "OutfitSlots.Head", isBase = false },
    { id = "OutfitSlots.Balaclava", name = "OutfitSlots.Balaclava", isBase = false },
    { id = "OutfitSlots.Mask", name = "OutfitSlots.Mask", isBase = false },
    { id = "OutfitSlots.Glasses", name = "OutfitSlots.Glasses", isBase = false },
    { id = "OutfitSlots.Eyes", name = "OutfitSlots.Eyes", isBase = false },
    { id = "OutfitSlots.EyeLeft", name = "OutfitSlots.EyeLeft", isBase = false },
    { id = "OutfitSlots.EyeRight", name = "OutfitSlots.EyeRight", isBase = false },
    { id = "OutfitSlots.Wreath", name = "OutfitSlots.Wreath", isBase = false },
    { id = "OutfitSlots.EarLeft", name = "OutfitSlots.EarLeft", isBase = false },
    { id = "OutfitSlots.EarRight", name = "OutfitSlots.EarRight", isBase = false },
    { id = "OutfitSlots.Neckwear", name = "OutfitSlots.Neckwear", isBase = false },
    { id = "OutfitSlots.NecklaceTight", name = "OutfitSlots.NecklaceTight", isBase = false },
    { id = "OutfitSlots.NecklaceShort", name = "OutfitSlots.NecklaceShort", isBase = false },
    { id = "OutfitSlots.NecklaceLong", name = "OutfitSlots.NecklaceLong", isBase = false },
    { id = "OutfitSlots.TorsoUnder", name = "OutfitSlots.TorsoUnder", isBase = false },
    { id = "OutfitSlots.TorsoInner", name = "OutfitSlots.TorsoInner", isBase = false },
    { id = "OutfitSlots.TorsoMiddle", name = "OutfitSlots.TorsoMiddle", isBase = false },
    { id = "OutfitSlots.TorsoOuter", name = "OutfitSlots.TorsoOuter", isBase = false },
    { id = "OutfitSlots.TorsoAux", name = "OutfitSlots.TorsoAux", isBase = false },
    { id = "OutfitSlots.Back", name = "OutfitSlots.Back", isBase = false },
    { id = "OutfitSlots.Waist", name = "OutfitSlots.Waist", isBase = false },
    { id = "OutfitSlots.ShoulderLeft", name = "OutfitSlots.ShoulderLeft", isBase = false },
    { id = "OutfitSlots.ShoulderRight", name = "OutfitSlots.ShoulderRight", isBase = false },
    { id = "OutfitSlots.ElbowLeft", name = "OutfitSlots.ElbowLeft", isBase = false },
    { id = "OutfitSlots.ElbowRight", name = "OutfitSlots.ElbowRight", isBase = false },
    { id = "OutfitSlots.WristLeft", name = "OutfitSlots.WristLeft", isBase = false },
    { id = "OutfitSlots.WristRight", name = "OutfitSlots.WristRight", isBase = false },
    { id = "OutfitSlots.Hands", name = "OutfitSlots.Hands", isBase = false },
    { id = "OutfitSlots.HandLeft", name = "OutfitSlots.HandLeft", isBase = false },
    { id = "OutfitSlots.HandRight", name = "OutfitSlots.HandRight", isBase = false },
    { id = "OutfitSlots.HandPropLeft", name = "OutfitSlots.HandPropLeft", isBase = false },
    { id = "OutfitSlots.HandPropRight", name = "OutfitSlots.HandPropRight", isBase = false },
    { id = "OutfitSlots.FingersLeft", name = "OutfitSlots.FingersLeft", isBase = false },
    { id = "OutfitSlots.FingersRight", name = "OutfitSlots.FingersRight", isBase = false },
    { id = "OutfitSlots.FingernailsLeft", name = "OutfitSlots.FingernailsLeft", isBase = false },
    { id = "OutfitSlots.FingernailsRight", name = "OutfitSlots.FingernailsRight", isBase = false },
    { id = "OutfitSlots.LegsInner", name = "OutfitSlots.LegsInner", isBase = false },
    { id = "OutfitSlots.LegsMiddle", name = "OutfitSlots.LegsMiddle", isBase = false },
    { id = "OutfitSlots.LegsOuter", name = "OutfitSlots.LegsOuter", isBase = false },
    { id = "OutfitSlots.ThighLeft", name = "OutfitSlots.ThighLeft", isBase = false },
    { id = "OutfitSlots.ThighRight", name = "OutfitSlots.ThighRight", isBase = false },
    { id = "OutfitSlots.KneeLeft", name = "OutfitSlots.KneeLeft", isBase = false },
    { id = "OutfitSlots.KneeRight", name = "OutfitSlots.KneeRight", isBase = false },
    { id = "OutfitSlots.AnkleLeft", name = "OutfitSlots.AnkleLeft", isBase = false },
    { id = "OutfitSlots.AnkleRight", name = "OutfitSlots.AnkleRight", isBase = false },
    { id = "OutfitSlots.Feet", name = "OutfitSlots.Feet", isBase = false },
    { id = "OutfitSlots.ToesLeft", name = "OutfitSlots.ToesLeft", isBase = false },
    { id = "OutfitSlots.ToesRight", name = "OutfitSlots.ToesRight", isBase = false },
    { id = "OutfitSlots.ToenailsLeft", name = "OutfitSlots.ToenailsLeft", isBase = false },
    { id = "OutfitSlots.ToenailsRight", name = "OutfitSlots.ToenailsRight", isBase = false },
    { id = "OutfitSlots.BodyUnder", name = "OutfitSlots.BodyUnder", isBase = false },
    { id = "OutfitSlots.BodyInner", name = "OutfitSlots.BodyInner", isBase = false },
    { id = "OutfitSlots.BodyMiddle", name = "OutfitSlots.BodyMiddle", isBase = false },
    { id = "OutfitSlots.BodyOuter", name = "OutfitSlots.BodyOuter", isBase = false }
}

-- ============================================================================
-- JSON Database Persistence Functions
-- ============================================================================

local function LoadSavedRefits()
    local file = io.open(savedRefitsFileName, "r")
    if file then
        local content = file:read("*a")
        savedRefits = json.decode(content) or {}
        file:close()
    else
        savedRefits = {}
    end
end

local function SaveSavedRefits()
    local file = io.open(savedRefitsFileName, "w")
    if file then
        file:write(json.encode(savedRefits))
        file:close()
    end
end

local function LoadFavoriteHairs()
    local file = io.open(favoriteHairsFileName, "r")
    if file then
        local content = file:read("*a")
        savedFavoriteHairs = json.decode(content) or {}
        file:close()
    else
        savedFavoriteHairs = {}
    end
end

local function SaveFavoriteHairs()
    local file = io.open(favoriteHairsFileName, "w")
    if file then
        file:write(json.encode(savedFavoriteHairs))
        file:close()
    end
end

local function LoadOutfits()
    local file = io.open(jsonFileName, "r")
    if file then
        local content = file:read("*a")
        savedOutfits = json.decode(content) or {}
        file:close()
        
        local needsMigration = false
        for k, v in pairs(savedOutfits) do
            if tonumber(k) ~= nil then 
                needsMigration = true 
                break 
            end
        end
        
        if needsMigration then
            local newDB = {}
            for hash, outfit in pairs(savedOutfits) do
                if hash ~= "_FAVORITES_" and hash ~= "_SAVED_LOOKS_" then
                    for slotName, itemName in pairs(outfit) do
                        if not newDB[slotName] then newDB[slotName] = {} end
                        local exists = false
                        for _, existingItem in ipairs(newDB[slotName]) do
                            if existingItem == itemName then exists = true break end
                        end
                        if not exists then table.insert(newDB[slotName], itemName) end
                    end
                end
            end
            if savedOutfits["_FAVORITES_"] then newDB["_FAVORITES_"] = savedOutfits["_FAVORITES_"] end
            savedOutfits = newDB
            print("[" .. modName .. "] Database migrated to Evolving format!")
        end
    else
        savedOutfits = {}
    end
    
    if savedOutfits["_SAVED_LOOKS_"] then savedOutfits["_SAVED_LOOKS_"] = nil end
    if not savedOutfits["_FAVORITES_"] then savedOutfits["_FAVORITES_"] = {} end
end

local function SaveOutfits()
    for slotName, itemsList in pairs(savedOutfits) do
        if slotName ~= "_FAVORITES_" and type(itemsList) == "table" then
            table.sort(itemsList, function(a, b)
                return string.lower(a) < string.lower(b)
            end)
        end
    end
    local file = io.open(jsonFileName, "w")
    if file then
        file:write(json.encode(savedOutfits))
        file:close()
    end
end

local function ResetJSON()
    savedOutfits = { ["_FAVORITES_"] = {} }
    local file = io.open(jsonFileName, "w")
    if file then
        file:write(json.encode(savedOutfits))
        file:close()
    end
    print("[" .. modName .. "] JSON database cleared successfully.")
end

local function SanitizeMeshPath(path)
    if not path then return "" end
    local clean = path:gsub("\\\\", "\\")
    return clean
end

local function LoadRefitsDatabase()
    local file = io.open(refitsJsonFileName, "r")
    if not file then
        print("[NPC Outfit Manager] WARNING: " .. refitsJsonFileName .. " não encontrado.")
        return
    end

    refitsDatabase = {}
    hairMeshesList = {} -- Limpa a lista de cabelos
    
    for line in file:lines() do
        for path in line:gmatch('"([%w\\_%.%-]+%.[mesh|bin]+)"') do
            local cleanPath = SanitizeMeshPath(path)
            
            -- VERIFICAÇÃO NOVA: Ignorar ficheiros terminados em .mi
            if not string.find(string.lower(cleanPath), "%.mi$") then
                
                table.insert(refitsDatabase, cleanPath)
                
                local lowerPath = string.lower(cleanPath)
                
                -- Filtra apenas os que contêm "hair" e ignora os que contêm "shadow"
                if string.find(lowerPath, "hair") and not string.find(lowerPath, "shadow") then
                    table.insert(hairMeshesList, cleanPath)
                end
                
                -- === BUSCAR CORPOS MODDADOS (t0_ e p0_) ===
				if string.find(lowerPath, "%.mesh$") then
					local filename = cleanPath:match("[^/\\]+$") or cleanPath
					local lowerFilename = string.lower(filename)
					
					if string.sub(lowerFilename, 1, 3) == "t0_" or string.find(lowerFilename, "t0_") or
					   string.sub(lowerFilename, 1, 3) == "p0_" or string.find(lowerFilename, "p0_") then
					   
						-- NOVO: Verifica se a mesh já existe na lista antes de a adicionar
						local exists = false
						for _, existingMesh in ipairs(bodyTypeMeshesList) do
							if existingMesh == cleanPath then
								exists = true
								break
							end
						end
						
						if not exists then
							table.insert(bodyTypeMeshesList, cleanPath)
						end
						
						isModdedMap[cleanPath] = true -- <--- NOVO: Marca este caminho como mod!
						
					end
				end
				-- =================================================
                
            end
        end
    end
    file:close()
    
    print("[NPC Outfit Manager] Database carregada: " .. #refitsDatabase .. " itens encontrados.")
    print("[NPC Outfit Manager] Hairs carregados: " .. #hairMeshesList)
end

local function LoadFavoriteBodyTypes()
    local file = io.open(favoriteBodyTypesFileName, "r")
    if file then
        local content = file:read("*a")
        savedFavoriteBodyTypes = json.decode(content) or {}
        file:close()
    else
        savedFavoriteBodyTypes = {}
    end
end

local function SaveFavoriteBodyTypes()
    local file = io.open(favoriteBodyTypesFileName, "w")
    if file then
        file:write(json.encode(savedFavoriteBodyTypes))
        file:close()
    end
end

local function LoadBaseGameBodyTypes()
    local file = io.open(baseGamePathsFileName, "r")
    if not file then
        print("[" .. modName .. "] WARNING: " .. baseGamePathsFileName .. " não encontrado.")
        return
    end

    bodyTypeMeshesList = {}
    local content = file:read("*a")
    file:close()

    local decoded = json.decode(content)
    if type(decoded) == "table" then
        for _, item in ipairs(decoded) do
            -- CORREÇÃO 1: Vai buscar a string dependendo se é objeto JSON ou string direta
            local rawPath = type(item) == "table" and item.mesh_path or item
            
            if rawPath and type(rawPath) == "string" then
                local cleanPath = SanitizeMeshPath(rawPath)
                local filename = cleanPath:match("[^/\\]+$") or cleanPath
                
                -- Filtra ficheiros .mesh
                if string.find(string.lower(cleanPath), "%.mesh$") then
                    local lowerFilename = string.lower(filename)
                    
                    -- CORREÇÃO 2: Aceita ficheiros que comecem ou contenham "t0_" OU "p0_"
					if string.sub(lowerFilename, 1, 3) == "t0_" or string.find(lowerFilename, "t0_") or
					   string.sub(lowerFilename, 1, 3) == "p0_" or string.find(lowerFilename, "p0_") then
						
						-- NOVO: Verificação de duplicados
						local exists = false
						for _, existingMesh in ipairs(bodyTypeMeshesList) do
							if existingMesh == cleanPath then
								exists = true
								break
							end
						end
						
						if not exists then
							table.insert(bodyTypeMeshesList, cleanPath)
						end
					end
				end	
            end
        end
    else
        -- Fallback de leitura por Regex caso o JSON esteja quebrado/formato diferente
        for path in content:gmatch('"([%w\\_%.%-]+%.mesh)"') do
            local cleanPath = SanitizeMeshPath(path)
            local filename = cleanPath:match("[^/\\]+$") or cleanPath
            local lowerFilename = string.lower(filename)
            
            -- CORREÇÃO 2 no fallback também ("t0_" ou "p0_")
			if string.sub(lowerFilename, 1, 3) == "t0_" or string.find(lowerFilename, "t0_") or
			   string.sub(lowerFilename, 1, 3) == "p0_" or string.find(lowerFilename, "p0_") then
				
				-- NOVO: Verificação de duplicados
				local exists = false
				for _, existingMesh in ipairs(bodyTypeMeshesList) do
					if existingMesh == cleanPath then
						exists = true
						break
					end
				end
				
				if not exists then
					table.insert(bodyTypeMeshesList, cleanPath)
				end
			end
		end		
    end

    print("[" .. modName .. "] Body Types carregados (t0_ e p0_): " .. #bodyTypeMeshesList)
end

-- ============================================================================
-- ALGORITHM: Focuses on filename and dynamically calculates required match
-- ============================================================================
local function GetMatchingMeshes(itemName)
    if not itemName or itemName == "Empty/Remove" then return {} end
    
    local words = {}
    local cleanStr = itemName:gsub("Items%.", ""):lower()
    
    for word in cleanStr:gmatch("%w+") do
        -- Ignores "mesh" and ensures it only accepts words with 3+ letters
        if word ~= "mesh" and #word >= 3 then 
            table.insert(words, word)
        end
    end
    
    if #words == 0 then return {} end
    
    local matches = {}
    
    for _, path in ipairs(refitsDatabase) do
        -- Extracts only the filename (after the last slash / or \)
        local filename = path:match("[^/\\]+$") or path
        local filenameLower = filename:lower()
        local score = 0
        
        for _, word in ipairs(words) do
            -- Looks for the word only inside the filename
            if string.find(filenameLower, word, 1, true) then
                score = score + 1
            end
        end
        
        -- FIX: Changed from hardcoded '3' to '2'. 
        -- This allows items with color suffixes (like "_yellow") that don't exist 
        -- in the pure .mesh filename to still pass the validation test.
        if score >= 2 then
            table.insert(matches, { path = path, score = score })
        end
    end
    
    -- Sorts to show the best matches first
    table.sort(matches, function(a, b)
        if a.score ~= b.score then
            return a.score > b.score
        end
        return a.path < b.path
    end)
    
    return matches
end

-- ============================================================================
-- FIXED: Smart calculation function to lock slots to unique mesh components
-- ============================================================================
local function GetTargetMeshForSlot(target, slotInfo, currentItemName)
    if not target then return nil end
    local targetHash = tostring(target:GetRecordID())
    if not assignedMeshes[targetHash] then assignedMeshes[targetHash] = {} end
    
    -- Clear previous tracking data for this specific slot
    for compName, slotId in pairs(assignedMeshes[targetHash]) do
        if slotId == slotInfo.id then
            assignedMeshes[targetHash][compName] = nil
        end
    end
    
    local components = target:GetComponents()
    local bestComp = nil
    local maxScore = -999
    
    local function GetWords(str)
        local words = {}
        for w in string.gmatch(string.lower(str or ""), "%w+") do
            if #w >= 3 and w ~= "items" and w ~= "mesh" and w ~= "outfitslots" and w ~= "attachmentslots" then
                words[w] = true
            end
        end
        return words
    end
    
    local itemWords = GetWords(currentItemName)
    local slotWords = GetWords(slotInfo.name)
    
    for _, comp in ipairs(components) do
        local compClassName = NameToString(comp:GetClassName())
        local compName = string.lower(NameToString(comp.name))
        
        -- =========================================================
        -- NOVA LÓGICA: Verifica se é cabelo vs roupa
        -- =========================================================
        local isHair = string.find(string.lower(slotInfo.name or ""), "hair") or string.find(string.lower(currentItemName or ""), "hair")
        local isValidClass = false
        
        if isHair then
            -- REGRA DO CABELO: Apenas malhas estáticas, sem físicas
            isValidClass = string.find(compClassName, "Mesh") and not string.find(compClassName, "SkinnedCloth") and not string.find(compClassName, "Physical")
        else
            -- REGRA DA ROUPA: Aceita Mesh, SkinnedCloth e Physical livremente
            isValidClass = string.find(compClassName, "Mesh") or string.find(compClassName, "SkinnedCloth") or string.find(compClassName, "Physical")
        end
        
        if isValidClass then
        -- =========================================================
            local isNaked = string.match(compName, "^[tahlswi]0_") or compName == "body" or compName == "base" or string.find(compName, "eyes") or string.find(compName, "teeth")
            
            if not isNaked then
                local score = 0
                for w in pairs(itemWords) do if string.find(compName, w, 1, true) then score = score + 10 end end
                for w in pairs(slotWords) do if string.find(compName, w, 1, true) then score = score + 2 end end
                
                -- CRITICAL CONFLICT RESOLUTION: Heavily penalize if already claimed by another slot
                local claimedBy = assignedMeshes[targetHash][compName]
                if claimedBy and claimedBy ~= slotInfo.id then
                    score = score - 100
                end
                
                if score > maxScore then
                    maxScore = score
                    bestComp = comp
                end
            end
        end
    end
    
    -- Fallback: Pick first available unassigned non-naked component safely
    if maxScore <= -50 or not bestComp then
        for _, comp in ipairs(components) do
            local compClassName = NameToString(comp:GetClassName())
            local compName = string.lower(NameToString(comp.name))
            
            -- =========================================================
            -- A mesma lógica aplicada ao sistema de segurança (fallback)
            -- =========================================================
            local isHair = string.find(string.lower(slotInfo.name or ""), "hair") or string.find(string.lower(currentItemName or ""), "hair")
            local isValidClass = false
            
            if isHair then
                isValidClass = string.find(compClassName, "Mesh") and not string.find(compClassName, "SkinnedCloth") and not string.find(compClassName, "Physical")
            else
                isValidClass = string.find(compClassName, "Mesh") or string.find(compClassName, "SkinnedCloth") or string.find(compClassName, "Physical")
            end
            
            if isValidClass then
            -- =========================================================
                local isNaked = string.match(compName, "^[tahlswi]0_") or compName == "body" or compName == "base" or string.find(compName, "eyes") or string.find(compName, "teeth")
                if not isNaked then
                    local claimedBy = assignedMeshes[targetHash][compName]
                    if not claimedBy or claimedBy == slotInfo.id then
                        bestComp = comp
                        break
                    end
                end
            end
        end
    end
    
    -- Claim ownership of this component
    if bestComp then
        assignedMeshes[targetHash][string.lower(NameToString(bestComp.name))] = slotInfo.id
    end
    
    return bestComp
end

local function ApplyMeshNatively(target, slotInfo, meshPath, currentItemName)
    if not target or not meshPath then return end
    
    local cleanPath = SanitizeMeshPath(meshPath)
    local bestComp = GetTargetMeshForSlot(target, slotInfo, currentItemName)
    
    if bestComp then
        pcall(function()
            bestComp:ChangeResource(cleanPath)
            Cron.After(0.2, function()
                bestComp:Toggle(false)
                bestComp:Toggle(true)
            end)
        end)
    end
end

local function LoadLooks()
    local file = io.open(looksJsonFileName, "r")
    if file then
        local content = file:read("*a")
        savedLooks = json.decode(content) or {}
        file:close()
    else
        savedLooks = {}
    end
end

local function SaveLooks()
    local file = io.open(looksJsonFileName, "w")
    if file then
        file:write(json.encode(savedLooks))
        file:close()
    end
end

-- ============================================================================
-- Audio & Animation Logic
-- ============================================================================
local function PlayModSound(soundName)
    if isSoundEnabled then
        pcall(function()
            Game.GetAudioSystem():Play(CName.new(soundName))
        end)
    end
end

local function PlayRandomNPCAnimation(target)
    if not target then return end
    
    local npcAnimations = {
        "dirt  stand  2h on hip  01",
        "dirt  stand  2h on hip  bd  01",
        "dirt  stand  2h on hip  01  long  01",
        "dirt  stand  2h on hip  ow  01",
        "dirt  stand  2h on lap  01",
        "dirt  stand  rh cigarette  ow  01",
        "stand  rh knife  01  lookat knife  01",
        "dirt  stand  2h on hip  01  sexy shuffle  02",
        "stand  2h on hip  03  sexy dance  07"
    }
    
    local randomAnim = npcAnimations[math.random(1, #npcAnimations)]
end

local function GetCategoryPrefix(itemName)
    if not itemName or itemName == "Empty/Remove" or itemName == "No_Match" or itemName == "No_Records_In_JSON" then return "" end
    local clean = itemName:gsub("Items%.", "")
    -- Tries to catch the first two words separated by _ or space
    local w1, w2 = clean:match("^([A-Za-z0-9]+)[_%s]+([A-Za-z0-9]+)")
    if w1 and w2 then return w1 .. "_" .. w2 end
    -- If it only has one, returns that one
    local w1_only = clean:match("^([A-Za-z0-9]+)")
    return w1_only or clean
end

-- ============================================================================
-- Equipment and Target Manipulation Logic
-- ============================================================================

local function GetFilteredPool(slotName, targetHash, slotId)
    local items = { "Empty/Remove" }
    local hasRecords = false
    
    local searchStr = searchQueries[targetHash] and searchQueries[targetHash][slotId] and string.lower(searchQueries[targetHash][slotId]) or ""
    local globalStr = (globalSearchOpen and globalSearchQuery ~= "") and string.lower(globalSearchQuery) or ""
    
    if savedOutfits[slotName] then
        for _, itemName in ipairs(savedOutfits[slotName]) do
            hasRecords = true
            local isFav = savedOutfits["_FAVORITES_"][itemName]
            
            local matchesFav = (not filterFavoritesOnly) or isFav
            local matchesLocalSearch = searchStr == "" or string.find(string.lower(itemName), searchStr, 1, true)
            local matchesGlobalSearch = globalStr == "" or string.find(string.lower(itemName), globalStr, 1, true)
            
            if matchesFav and matchesLocalSearch and matchesGlobalSearch then
                table.insert(items, itemName)
            end
        end
    end
    
    if not hasRecords then
        table.insert(items, "No_Records_In_JSON")
    elseif #items == 1 then
        table.insert(items, "No_Match")
    end
    
    return items
end

local function GetPlayerOutfit()
    local player = Game.GetPlayer()
    local ts = Game.GetTransactionSystem()
    local outfit = {}

    for _, slotInfo in ipairs(allSlots) do
        local slotTDBID = TweakDBID.new(slotInfo.id)
        local itemObject = ts:GetItemInSlot(player, slotTDBID)

        if itemObject then
            local itemID = itemObject:GetItemID()
            if itemID and itemID.id then
                local tdbid = ItemID.GetTDBID(itemID)
                local cleanItemName = tostring(tdbid):match("(Items%.[%w_]+)")
                if cleanItemName then
                    outfit[slotInfo.name] = cleanItemName
                end
            end
        end
    end
    return outfit
end

local function GetLookAtNPC()
    local player = Game.GetPlayer()
    if not player then return nil end
    local target = Game.GetTargetingSystem():GetLookAtObject(player)
    if target and target:IsNPC() then
        return target
    end
    return nil
end

local function GetNPCAppearancesNative(target)
    if not target then return nil end
    local recordID = target:GetRecordID()
    if not recordID then return nil end
    
    local charRecord = TweakDBInterface.GetCharacterRecord(recordID)
    if not charRecord then return nil end
    
    local path = charRecord:EntityTemplatePath()
    local token = Game.GetResourceDepot():LoadResource(path)
    
    if not token or not token:IsLoaded() then 
        return nil, "loading"
    end
    
    local template = token:GetResource()
    if not template or not template.appearances or #template.appearances == 0 then 
        return nil 
    end
    
    return template.appearances
end

local autoRetryNakedTarget = nil

local function ForceNakedState(target)
    if not target then return end
    
    local appearances, status = GetNPCAppearancesNative(target)
    
    if status == "loading" then
        autoRetryNakedTarget = target
        return
    end
    
    autoRetryNakedTarget = nil
    
    if not appearances then
        Game.GetPlayer():SetWarningMessage("Could not read native appearances for this NPC.")
        return
    end
    
    local nakedKeywords = {"naked", "nude", "underwear", "no_clothes", "body", "stripper"}
    local nakedAppName = nil
    
    for i = 1, #appearances do
        local appName = NameToString(appearances[i].name)
        local lowerApp = string.lower(appName)
        
        for _, kw in ipairs(nakedKeywords) do
            if string.find(lowerApp, kw) then
                nakedAppName = appName
                break
            end
        end
        if nakedAppName then break end
    end
    
    if nakedAppName then
        local appearanceCName = CName.new(nakedAppName)
        target:PrefetchAppearanceChange(appearanceCName)
        target:ScheduleAppearanceChange(appearanceCName)
        
        local ts = Game.GetTransactionSystem()
        for _, slotInfo in ipairs(allSlots) do
            local slotTDBID = TweakDBID.new(slotInfo.id)
            ts:RemoveItemFromSlot(target, slotTDBID)
        end
        
        Game.GetPlayer():SetWarningMessage("Naked Appearance Applied: " .. nakedAppName)
    else
        Game.GetPlayer():SetWarningMessage("This NPC has no 'naked' appearance in the original file.")
    end
end

local function CycleNPCAppearanceNative(target)
    if not target then return end
    
    local appearances, status = GetNPCAppearancesNative(target)
    if status == "loading" then
        Game.GetPlayer():SetWarningMessage("Template loading... Click again!")
        return 
    end
    
    if not appearances or #appearances == 0 then
        Game.GetPlayer():SetWarningMessage("Could not read native appearances for this NPC.")
        return 
    end
    
    local currentAppCName = target:GetCurrentAppearanceName()
    local currentAppearance = currentAppCName and NameToString(currentAppCName) or ""
    local nextIndex = 1
    
    for i = 1, #appearances do
        local appName = NameToString(appearances[i].name)
        if appName == currentAppearance then
            nextIndex = i + 1
            break
        end
    end
    
    if nextIndex > #appearances then nextIndex = 1 end
    local nextAppearanceStr = NameToString(appearances[nextIndex].name)
    local appearanceCName = CName.new(nextAppearanceStr)
    
    target:PrefetchAppearanceChange(appearanceCName)
    target:ScheduleAppearanceChange(appearanceCName)
    Game.GetPlayer():SetWarningMessage("Appearance changed to: " .. nextAppearanceStr)
end

local function ApplyItemFromPool(target, slotId, itemString)
    if not target or not itemString then return end
    
    local ts = Game.GetTransactionSystem()
    local slotTDBID = TweakDBID.new(slotId)
    
    if itemString == "Empty/Remove" or itemString == "No_Match" then
        ts:RemoveItemFromSlot(target, slotTDBID)
    elseif itemString ~= "No_Records_In_JSON" then
        local itemTDBID = TweakDBID.new(itemString)
        local newItemID = ItemID.new(itemTDBID)
        ts:RemoveItemFromSlot(target, slotTDBID)
        ts:GiveItem(target, newItemID, 1)
        ts:AddItemToSlot(target, slotTDBID, newItemID)
    end
end

local function ClearAllNPCSlots(target)
    if not target then return end
    local ts = Game.GetTransactionSystem()
    for _, slotInfo in ipairs(allSlots) do
        local slotTDBID = TweakDBID.new(slotInfo.id)
        ts:RemoveItemFromSlot(target, slotTDBID)
    end
    print("[" .. modName .. "] Total NPC slot clearance executed.")
end

local function ToggleBodyPart(target, targetHash, partName)
    if not target then return end
    
    -- Initializes the state for this NPC if it does not exist
    if not bodyPartStates[targetHash] then bodyPartStates[targetHash] = {} end
    
    -- Inverts the current state
    local isCurrentlyHidden = bodyPartStates[targetHash][partName] or false
    local nextHiddenState = not isCurrentlyHidden
    bodyPartStates[targetHash][partName] = nextHiddenState
    
    local prefixes = bodyPartPrefixes[partName]
    local components = target:GetComponents()
    
    for _, comp in ipairs(components) do
        local compClassName = NameToString(comp:GetClassName())
        if string.find(compClassName, "Mesh") or string.find(compClassName, "SkinnedCloth") then
            local compName = string.lower(NameToString(comp.name))
            
            -- Checks if the mesh name starts with any of the prefixes for this body part
            local isMatch = false
            for _, prefix in ipairs(prefixes) do
                if string.sub(compName, 1, string.len(prefix)) == prefix then
                    isMatch = true
                    break
                end
            end
            
            -- Outputs all names to the CET console for debugging
            print("---- COMPONENT DEBUG ----")
            print("Real mesh name: " .. NameToString(comp.name))
            print("Mesh class: " .. NameToString(comp:GetClassName()))
            if isMatch then
                -- Bitmask failsafe (restores full visibility if it was zero)
                if not nextHiddenState and comp.chunkMask == 0 then
                    comp.chunkMask = 18446744073709551615ULL
                end
                
                -- If nextHiddenState is true, we want to turn it off (Toggle = false, Hide = true)
                comp:Toggle(not nextHiddenState)
                comp:TemporaryHide(nextHiddenState)
            end
        end
    end
end

local function SetBodyPartState(target, targetHash, partName, hideState)
    if not target then return end
    
    -- Inicializa o estado se não existir
    if not bodyPartStates[targetHash] then bodyPartStates[targetHash] = {} end
    bodyPartStates[targetHash][partName] = hideState
    
    local prefixes = bodyPartPrefixes[partName]
    local components = target:GetComponents()
    
    for _, comp in ipairs(components) do
        local compClassName = NameToString(comp:GetClassName())
        if string.find(compClassName, "Mesh") or string.find(compClassName, "SkinnedCloth") then
            local compName = string.lower(NameToString(comp.name))
            
            -- Verifica se o nome da mesh bate certo com o prefixo
            local isMatch = false
            for _, prefix in ipairs(prefixes) do
                if string.sub(compName, 1, string.len(prefix)) == prefix then
                    isMatch = true
                    break
                end
            end
            
            if isMatch then
                if not hideState and comp.chunkMask == 0 then
                    comp.chunkMask = 18446744073709551615ULL
                end
                comp:Toggle(not hideState)
                comp:TemporaryHide(hideState)
            end
        end
    end
end

local function IsVanillaItem(itemName)
    local vanillaPrefixes = {
        "Items.TShirt_", "Items.Shirt_", "Items.Jacket_", "Items.Coat_", 
        "Items.Vest_", "Items.Pants_", "Items.Shorts_", "Items.Skirt_", 
        "Items.Dress_", "Items.Jumpsuit_", "Items.Boots_", "Items.CasualShoes_", 
        "Items.FormalShoes_", "Items.Helmet_", "Items.Hat_", "Items.Cap_", 
        "Items.Mask_", "Items.Visor_", "Items.Tech_", "Items.Glasses_", 
        "Items.Goggles_", "Items.Balaclava_", "Items.Scarf_", "Items.Underwear_",
        "Items.Q", "Items.SQ", "Items.MQ", "Items.Player_Default", 
        "Items.Nomad_", "Items.Corpo_", "Items.StreetKid_"
    }

    for _, prefix in ipairs(vanillaPrefixes) do
        if string.sub(itemName, 1, string.len(prefix)) == prefix then 
            return true 
        end
    end
    
    local vanillaKeywords = { "_basic", "_poor", "_rich", "_old" }
    local lowerItemName = string.lower(itemName)
    for _, keyword in ipairs(vanillaKeywords) do
        if string.find(lowerItemName, keyword) then 
            return true 
        end
    end

    if string.find(itemName, "%d%d.*%d%d") then 
        return true 
    end
    
    return false 
end

local function ScanAndUnlockAllClothes()
    local addedCount = 0
    local records = TweakDBInterface.GetRecords("gamedataClothing_Record")
    
    for _, record in ipairs(records) do
        local itemID = record:GetID()
        local itemStr = tostring(itemID):match("(Items%.[%w_]+)")
        
        if itemStr then
            if not IsVanillaItem(itemStr) then
                local pSlots = record:PlacementSlots()
                if pSlots then
                    for _, slotRec in ipairs(pSlots) do
                        local slotStrRaw = tostring(slotRec:GetID())
                        for _, slotInfo in ipairs(allSlots) do
                            if string.find(slotStrRaw, slotInfo.id, 1, true) then
                                if not savedOutfits[slotInfo.name] then savedOutfits[slotInfo.name] = {} end
                                local exists = false
                                for _, existingItem in ipairs(savedOutfits[slotInfo.name]) do
                                    if existingItem == itemStr then exists = true break end
                                end
                                if not exists then
                                    table.insert(savedOutfits[slotInfo.name], itemStr)
                                    addedCount = addedCount + 1
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    if addedCount > 0 then SaveOutfits() end
    return addedCount
end

-- ============================================================================
-- Graphical Interface (ImGui / CET Setup)
-- ============================================================================

registerForEvent("onInit", function()
    LoadOutfits()
    LoadLooks()
    LoadBaseGameBodyTypes()
    LoadRefitsDatabase()
    LoadSavedRefits()
    LoadFavoriteHairs()
    LoadFavoriteBodyTypes()  
end)

registerForEvent("onDraw", function()
    if not isMainWindowOpen then return end

    -- Base Window Colors
    ImGui.PushStyleColor(ImGuiCol.TitleBg, 1.0, 0.41, 0.70, 1.0)       
    ImGui.PushStyleColor(ImGuiCol.TitleBgActive, 1.0, 0.55, 0.75, 1.0) 
    ImGui.PushStyleColor(ImGuiCol.WindowBg, 0.0, 0.0, 0.0, 0.0)    
    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)            
    ImGui.PushStyleColor(ImGuiCol.Button, 0.60, 0.80, 0.96, 0.75)       
    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1.0, 0.55, 0.75, 0.75) 
    ImGui.PushStyleColor(ImGuiCol.ButtonActive, 1.0, 0.41, 0.70, 0.75)  

    local targetWidth = 450 

    ImGui.SetNextWindowSize(targetWidth, 350, ImGuiCond.Appearing)
    if ImGui.Begin("NPC Outfit Manager", true) then
        ImGui.Spacing()
        
        ImGui.SetWindowFontScale(3.5)
        local iconText = "\u{f0f4a}"
        local iconWidth = ImGui.CalcTextSize(iconText)
        ImGui.SetCursorPosX((ImGui.GetWindowWidth() - iconWidth) * 0.5)
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)
        ImGui.Text(iconText)
        ImGui.PopStyleColor()
        
        ImGui.SetWindowFontScale(1.5)
        local titleText = "NPC OUTFIT MANAGER"
        local titleWidth = ImGui.CalcTextSize(titleText)
        ImGui.SetCursorPosX((ImGui.GetWindowWidth() - titleWidth) * 0.5)
        ImGui.Text(titleText)
        
        ImGui.SetWindowFontScale(1.0)
        ImGui.Separator()
        ImGui.Spacing()

        if ImGui.Button("Save Player Clothes to Wardrobe DB", ImGui.GetWindowWidth() - 20, 30) then
            local currentOutfit = GetPlayerOutfit()
            local addedCount = 0
            for slotName, itemString in pairs(currentOutfit) do
                if not savedOutfits[slotName] then savedOutfits[slotName] = {} end
                local exists = false
                for _, existingItem in ipairs(savedOutfits[slotName]) do
                    if existingItem == itemString then exists = true break end
                end
                if not exists then
                    table.insert(savedOutfits[slotName], itemString)
                    addedCount = addedCount + 1
                end
            end
            SaveOutfits()
            print("[" .. modName .. "] Outfit registered! " .. addedCount .. " new items added to the Wardrobe.")
            Game.GetPlayer():SetWarningMessage("Saved! " .. addedCount .. " items added.")
        end

        ImGui.Spacing()
		
        ImGui.PushStyleColor(ImGuiCol.Button, 0.85, 0.65, 0.13, 0.75)       
        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1.0, 0.84, 0.0, 0.75) 
        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.72, 0.53, 0.04, 0.75) 
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)
        
        if ImGui.Button("Unlock All Custom Clothes (NEW)", ImGui.GetWindowWidth() - 20, 30) then
            local totalAdded = ScanAndUnlockAllClothes()
            if totalAdded > 0 then
                Game.GetPlayer():SetWarningMessage("Success! Added " .. totalAdded .. " items to Wardrobe.")
            else
                Game.GetPlayer():SetWarningMessage("Scan complete. No new items found.")
            end
        end
        
        if ImGui.IsItemHovered() then
            ImGui.SetTooltip("Scans the game's database for ALL clothing items (including mods)\nand registers them directly into their proper slots.")
        end
        
        ImGui.PopStyleColor(4) 
        ImGui.Spacing()
		
        if ImGui.Button("Reset JSON Database", ImGui.GetWindowWidth() - 20, 30) then
            isResetConfirmWindowOpen = true 
        end
        ImGui.Spacing()

        local cx = ImGui.GetCursorPosX()
        local cy = ImGui.GetCursorPosY()
        local custBtnWidth = ImGui.GetWindowWidth() - 20
        local custBtnHeight = 35
        
        if ImGui.Button("##CustomizeNPC", custBtnWidth, custBtnHeight) then
            isCustomizeWindowOpen = not isCustomizeWindowOpen
        end
        
        local cIcon = "\u{f1a61}"
        local cText = " Customize your NPC "
        local iW = ImGui.CalcTextSize(cIcon)
        local tW = ImGui.CalcTextSize(cText)
        local totalW = iW + tW + iW
        local startX = cx + (custBtnWidth - totalW) * 0.5
        local startY = cy + (custBtnHeight - ImGui.GetTextLineHeight()) * 0.5
        
        ImGui.SetCursorPosX(startX); ImGui.SetCursorPosY(startY)
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.41, 0.70, 1.0)
        ImGui.Text(cIcon)
        ImGui.SetCursorPosX(startX + iW); ImGui.SetCursorPosY(startY)
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)
        ImGui.Text(cText)
        ImGui.SetCursorPosX(startX + iW + tW); ImGui.SetCursorPosY(startY)
        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.41, 0.70, 1.0)
        ImGui.Text(cIcon)
        ImGui.PopStyleColor(3)
        ImGui.SetCursorPosY(cy + custBtnHeight + 5)
    end
    ImGui.End()

    -- SECONDARY WINDOW
    if isCustomizeWindowOpen then
        ImGui.SetNextWindowSize(targetWidth * 2.2, 1300, ImGuiCond.Appearing) 
        if ImGui.Begin("Customize your NPC Slots", true, ImGuiWindowFlags.NoScrollbar) then
            
            -- ADD THIS HERE: Stores the position for the side window
            customizeWindowPos.x, customizeWindowPos.y = ImGui.GetWindowPos()
            customizeWindowSize.x, customizeWindowSize.y = ImGui.GetWindowSize()
            
            local target = GetLookAtNPC()
            if not target then
                ImGui.TextColored(1.0, 0.2, 0.2, 1.0, "WARNING: No Valid NPC Targeted!")
            else
                local targetHash = tostring(target:GetRecordID())
                
                if not hiddenSlots[targetHash] then hiddenSlots[targetHash] = {} end
                if not lockedSlots[targetHash] then lockedSlots[targetHash] = {} end
                if not isSearching[targetHash] then isSearching[targetHash] = {} end
                if not searchQueries[targetHash] then searchQueries[targetHash] = {} end
                if not currentSelections[targetHash] then currentSelections[targetHash] = {} end
                if not activeRefits[targetHash] then activeRefits[targetHash] = {} end
                if not hiddenRefits[targetHash] then hiddenRefits[targetHash] = {} end
				
                ImGui.Spacing()
                
                -- Guardamos a posição Y inicial para alinhar tudo
                local headerY = ImGui.GetCursorPosY()
                
                local btnH = 30
                -- Aumentado em 30% (de 100 para 130)
                local topBtnW = 130 
                
                -- Função de desenho modificada com as novas cores exclusivas (Branco Nacre / Preto Grafite / Rosa Hover)
                -- Função de desenho modificada: agora recebe as cores específicas dos ÍCONES (iR, iG, iB)
                local function DrawIconButtonVertical(id, icon, text, iR, iG, iB, btnWidth, onClick)
                    local cx1 = ImGui.GetCursorPosX()
                    local cy1 = ImGui.GetCursorPosY()
                    
                    local iw1 = ImGui.CalcTextSize(icon)
                    local tw1 = ImGui.CalcTextSize(text)
                    
                    -- Cores do Botão (Fundo Branco Nacre / Hover Rosa)
                    ImGui.PushStyleColor(ImGuiCol.Button, 0.96, 0.96, 0.93, 1.0)
                    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1.0, 0.41, 0.70, 1.0)
                    ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.85, 0.85, 0.82, 1.0)
                    
                    if ImGui.Button(id, btnWidth, btnH) then onClick() end
                    ImGui.PopStyleColor(3)
                    
                    local sX1 = cx1 + (btnWidth - (iw1 + tw1 + iw1)) * 0.5
                    local sY1 = cy1 + (btnH - ImGui.GetTextLineHeight()) * 0.5

                    ImGui.SetCursorPosX(sX1); ImGui.SetCursorPosY(sY1)
                    
                    -- Pinta o primeiro ícone com a cor escolhida
                    ImGui.PushStyleColor(ImGuiCol.Text, iR, iG, iB, 1.0)
                    ImGui.Text(icon)
                    
                    -- Pinta o texto do meio de Preto Grafite
                    ImGui.SetCursorPosX(sX1 + iw1); ImGui.SetCursorPosY(sY1)
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.12, 0.12, 0.15, 1.0)
                    ImGui.Text(text)
                    ImGui.PopStyleColor() -- Tira o Preto Grafite
                    
                    -- Desenha o segundo ícone (herda a cor do primeiro ícone)
                    ImGui.SetCursorPosX(sX1 + iw1 + tw1); ImGui.SetCursorPosY(sY1)
                    ImGui.Text(icon)
                    ImGui.PopStyleColor() -- Tira a cor do ícone
                end

                -- =========================================================
                -- 1. OS 4 BOTÕES ALINHADOS NA VERTICAL (LADO ESQUERDO)
                -- =========================================================
                
                -- Botão 1 (Naked) - Ícones Roxo Aubergine
                ImGui.SetCursorPos(10, headerY)
                DrawIconButtonVertical("##ForceNaked", "\u{f01f4}", " Naked ", 0.40, 0.15, 0.45, topBtnW, function() ForceNakedState(target) end)
                
                -- Botão 2 (Rotate) - Ícones Verdes
                ImGui.SetCursorPos(10, headerY + 35)
                DrawIconButtonVertical("##RotateOutfit", "\u{f0464}", " Rotate ", 0.15, 0.75, 0.20, topBtnW, function() CycleNPCAppearanceNative(target) end)
                
                -- Botão 3 (Copy V / Apply V) - Ícones Pretos (depois Amarelos)
                ImGui.SetCursorPos(10, headerY + 70)
                
                local i3, t3 = "\u{f1222}", " Copy V "
                local iR, iG, iB = 0.12, 0.12, 0.15 -- Preto Grafite padrão
                
                if savedVOutfitForNPC then
                    i3, t3 = "\u{f1a7a}", " Apply V "
                    iR, iG, iB = 0.95, 0.85, 0.10 -- Amarelo Vivo quando clicado
                end
                
                DrawIconButtonVertical("##CopyApplyV", i3, t3, iR, iG, iB, topBtnW, function()
                    if not savedVOutfitForNPC then
                        savedVOutfitForNPC = GetPlayerOutfit()
                        Game.GetPlayer():SetWarningMessage("Clothes saved! Click again to apply onto the NPC.")
                    else
                        for _, slotInfo in ipairs(allSlots) do
                            local itemString = savedVOutfitForNPC[slotInfo.name]
                            if not lockedSlots[targetHash][slotInfo.id] then
                                ApplyItemFromPool(target, slotInfo.id, itemString or "Empty/Remove")
                                currentSelections[targetHash][slotInfo.id] = itemString or "Empty/Remove"
                                activeRefits[targetHash][slotInfo.id] = nil
                            end
                        end
                        savedVOutfitForNPC = nil 
                        Game.GetPlayer():SetWarningMessage("V's clothes applied onto the NPC!")
                    end
                end)

                -- Botão 4 (Delete) - Ícones Vermelhos
                ImGui.SetCursorPos(10, headerY + 105)
                DrawIconButtonVertical("##DeleteData", "\u{f06c9}", " Delete ", 0.85, 0.15, 0.15, topBtnW, function()
                    ClearAllNPCSlots(target)
                    currentSelections[targetHash] = {}
                    hiddenSlots[targetHash] = {}
                    lockedSlots[targetHash] = {}
                    searchQueries[targetHash] = {}
                    activeRefits[targetHash] = {}
                end)

                -- =========================================================
                -- 2. ÍCONE GRANDE CENTRALIZADO
                -- =========================================================
                ImGui.SetWindowFontScale(3.5)
                local npcHeaderIcon = "\u{f1a62}"
                local npcHeaderIconW = ImGui.CalcTextSize(npcHeaderIcon)
                
                ImGui.SetCursorPos((ImGui.GetWindowWidth() - npcHeaderIconW) * 0.5, headerY + 30)
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)
                ImGui.Text(npcHeaderIcon)
                ImGui.PopStyleColor()
                ImGui.SetWindowFontScale(1.0)

                -- =========================================================
                -- 3. BOTÃO HIDE ALINHADO À DIREITA (Laranja Clarinho / Ícone Branco)
                -- =========================================================
                local hideBtnW = 40
                ImGui.SetCursorPos(ImGui.GetWindowWidth() - hideBtnW - 10, headerY)

                ImGui.PushStyleColor(ImGuiCol.Button, 1.0, 0.65, 0.30, 0.85)
                ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1.0, 0.75, 0.45, 1.0)
                ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.85, 0.55, 0.20, 1.0)
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)

                if ImGui.Button("\u{f02e6}##HideBtnTop", hideBtnW, btnH) then
                    isBodyHideWindowOpen = not isBodyHideWindowOpen
                    hasMouseEnteredBodyHide = false
                    isRefitViewerWindowOpen = false 
                    isHairSpawnerWindowOpen = false 
                    isBodyTypeWindowOpen = false -- Fecha o Body Types
                end
                ImGui.PopStyleColor(4)
                if ImGui.IsItemHovered() then ImGui.SetTooltip("NPC Body Parts Hide/Show") end

                -- =========================================================
                -- NOVO: BOTÃO BODY TYPE SPAWNER (Vermelho / Ícone Branco)
                -- =========================================================
                ImGui.SetCursorPos(ImGui.GetWindowWidth() - hideBtnW - 10, headerY + 35)
                
                if isBodyTypeWindowOpen then
                    ImGui.PushStyleColor(ImGuiCol.Button, 1.0, 0.25, 0.25, 0.95) -- Fica Vermelho Vivo
                else
                    ImGui.PushStyleColor(ImGuiCol.Button, 0.75, 0.15, 0.15, 0.85) -- Vermelho Normal Escuro
                end
                ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1.0, 0.35, 0.35, 1.0)
                ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.60, 0.10, 0.10, 1.0)
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0) -- Ícone Branco
                
                if ImGui.Button("\u{f115d}##BodyTypeTop", hideBtnW, btnH) then
                    isBodyTypeWindowOpen = not isBodyTypeWindowOpen
                    hasMouseEnteredBodyType = false
                    isBodyHideWindowOpen = false
                    isRefitViewerWindowOpen = false
                    isHairSpawnerWindowOpen = false
                end
                ImGui.PopStyleColor(4)
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Change Body Type") end

                -- VIEWER DE REFITS (Verde Lima)
                ImGui.SetCursorPos(ImGui.GetWindowWidth() - hideBtnW - 10, headerY + 70)
                ImGui.PushStyleColor(ImGuiCol.Button, 0.60, 0.90, 0.20, 0.85)
                ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.70, 1.0, 0.30, 1.0)
                ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.50, 0.80, 0.10, 1.0)
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)
                
                if ImGui.Button("\u{f14e8}##RefitViewerTop", hideBtnW, btnH) then
                    isRefitViewerWindowOpen = not isRefitViewerWindowOpen
                    hasMouseEnteredRefitViewer = false
                    isBodyHideWindowOpen = false 
                    isHairSpawnerWindowOpen = false 
                    isBodyTypeWindowOpen = false -- Fecha o Body Types
                end
                ImGui.PopStyleColor(4)
                if ImGui.IsItemHovered() then ImGui.SetTooltip("View Saved Refits for this NPC") end

                -- BOTÃO HAIR SPAWNER (Dourado/Preto -> Verde)
                ImGui.SetCursorPos(ImGui.GetWindowWidth() - hideBtnW - 10, headerY + 105)
                
                if isHairSpawnerWindowOpen then
                    ImGui.PushStyleColor(ImGuiCol.Button, 0.20, 0.85, 0.20, 0.85)
                else
                    ImGui.PushStyleColor(ImGuiCol.Button, 0.85, 0.65, 0.13, 0.85)
                end
                ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1.0, 0.84, 0.0, 1.0)
                ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.72, 0.53, 0.04, 1.0)
                ImGui.PushStyleColor(ImGuiCol.Text, 0.1, 0.1, 0.1, 1.0)
                
                if ImGui.Button("\u{f10f0}##HairSpawnerTop", hideBtnW, btnH) then
                    isHairSpawnerWindowOpen = not isHairSpawnerWindowOpen
                    hasMouseEnteredHairSpawner = false
                    isBodyHideWindowOpen = false
                    isRefitViewerWindowOpen = false
                    isBodyTypeWindowOpen = false -- Fecha o Body Types
                end
                ImGui.PopStyleColor(4)
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Spawn Hair Meshes") end
                
                -- Empurramos o Cursor para debaixo do 4º botão
                ImGui.SetCursorPosY(headerY + 145)
                ImGui.Separator()
                ImGui.Spacing()
                
                if not savedLooks[targetHash] then savedLooks[targetHash] = {} end
                local btnWidth = (ImGui.GetWindowWidth() - 110) / 10
                for i = 1, 10 do
                    local str_i = tostring(i) 
                    local iconStr = string.format("\u{f02c8} %d", i)
                    local isLookSaved = (savedLooks[targetHash][str_i] ~= nil) or (savedLooks[targetHash][i] ~= nil)
                    
                    if isLookSaved then
                        iconStr = "[ " .. iconStr .. " ]"
                        -- Fundo Cor de Rosa (ativo/salvo)
                        ImGui.PushStyleColor(ImGuiCol.Button, 1.0, 0.41, 0.70, 0.90)
                        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1.0, 0.50, 0.75, 0.90)
                        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.90, 0.35, 0.60, 0.90)
                        -- Letras e Ícone Verde Vivo
                        ImGui.PushStyleColor(ImGuiCol.Text, 0.1, 0.9, 0.1, 1.0)
                    else
                        -- Cinzento médio para o slot vazio
                        ImGui.PushStyleColor(ImGuiCol.Button, 0.45, 0.45, 0.45, 0.90)
                        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.55, 0.55, 0.55, 0.90)
                        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.35, 0.35, 0.35, 0.90)
                        -- Letras brancas escuro (light gray)
                        ImGui.PushStyleColor(ImGuiCol.Text, 0.85, 0.85, 0.85, 1.0)
                    end
                    -- Letras brancas escuro (light gray elegante)
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.85, 0.85, 0.85, 1.0)

                    if ImGui.Button(iconStr .. "##Look" .. i, btnWidth, 30) then
                        if not isLookSaved then
							PlayModSound("save_outfit")
                            local currentAppCName = target:GetCurrentAppearanceName()
                            local baseAppearance = currentAppCName and NameToString(currentAppCName) or ""
                            
                            -- MUDANÇA: Guarda a roupa, estado do Body Hide e o Cabelo Ativo
                            savedLooks[targetHash][str_i] = {
								_base_appearance = baseAppearance,
								items = CopySelections(currentSelections[targetHash]),
								body_states = CopySelections(bodyPartStates[targetHash] or {}),
								hair = activeRefits[targetHash] and activeRefits[targetHash]["AttachmentSlots.Head"] or nil,
								body_type = activeBodyTypes[targetHash] or nil -- NOVO: Guarda o corpo selecionado
							}
                            SaveLooks()
                        else
                            local savedData = savedLooks[targetHash][str_i] or savedLooks[targetHash][i]
                            local loadedOutfit = {}
                            
                            if savedData.items then
                                loadedOutfit = CopySelections(savedData.items)
                                if savedData._base_appearance and savedData._base_appearance ~= "" then
                                    local appearanceCName = CName.new(savedData._base_appearance)
                                    target:PrefetchAppearanceChange(appearanceCName)
                                    target:ScheduleAppearanceChange(appearanceCName)
                                end
                                
                                -- 1º PASSO: Dar Load aos Hides do Body PRIMEIRO
                                if savedData.body_states then
                                    for partName, isHidden in pairs(savedData.body_states) do
                                        SetBodyPartState(target, targetHash, partName, isHidden)
                                    end
                                else
                                    -- Restaura tudo caso o save seja antigo e não tenha dados do body
                                    local allParts = {"Head", "Hair", "Torso", "Arms", "Hands", "Legs", "Feet"}
                                    for _, partName in ipairs(allParts) do
                                        SetBodyPartState(target, targetHash, partName, false)
                                    end
                                end
                            else
                                loadedOutfit = CopySelections(savedData)
                            end
                            
                            -- 2º PASSO: Aplicar a roupa
                            for _, slotInfo in ipairs(allSlots) do
                                local itemName = loadedOutfit[slotInfo.id]
                                if type(itemName) == "number" then itemName = "Empty/Remove" end 
                                
                                if itemName and not lockedSlots[targetHash][slotInfo.id] then
                                    currentSelections[targetHash][slotInfo.id] = itemName
                                    activeRefits[targetHash][slotInfo.id] = nil
                                    if not hiddenSlots[targetHash][slotInfo.id] then
                                        ApplyItemFromPool(target, slotInfo.id, itemName)
                                    end
                                end
                            end
                            
                            -- 3º PASSO: Dar Load ao Cabelo no FIM (com Cron para a roupa não o apagar)
                            if savedData.hair then
                                Cron.After(0.4, function() 
                                    local dummySlot = { id = "AttachmentSlots.Head", name = "Hair" }
                                    ApplyMeshNatively(target, dummySlot, savedData.hair, "Hair_Mesh")
                                    if not activeRefits[targetHash] then activeRefits[targetHash] = {} end
                                    activeRefits[targetHash]["AttachmentSlots.Head"] = savedData.hair
                                end)
                            end
							
							if savedData.body_type then
								Cron.After(0.35, function()
									local dummyTorsoSlot = { id = "AttachmentSlots.Torso", name = "Torso" }
									ApplyMeshNatively(target, dummyTorsoSlot, savedData.body_type, "Body_Mesh")
									activeBodyTypes[targetHash] = savedData.body_type
								end)
							end
							
                            Game.GetPlayer():SetWarningMessage("Appearance " .. i .. " Loaded!")
                        end
                    end
                    ImGui.PopStyleColor(4)
                    
                    if ImGui.IsItemHovered() then
                        if isLookSaved then 
                            ImGui.SetTooltip("Left-Click: Load Appearance " .. i .. "\nRight-Click: Delete Appearance " .. i)
                        else 
                            ImGui.SetTooltip("Left-Click: Save clothing configuration to Slot " .. i) 
                        end
                    end
                    
                    if ImGui.IsItemClicked(1) and isLookSaved then
                        savedLooks[targetHash][str_i] = nil
                        savedLooks[targetHash][i] = nil 
                        SaveLooks() 
                        Game.GetPlayer():SetWarningMessage("Appearance " .. i .. " Deleted!")
                    end
                    
                    if i < 10 then ImGui.SameLine() end
                end

                ImGui.Spacing()
                ImGui.Separator()
                
                local favGlobalW = 280
                ImGui.SetCursorPosX((ImGui.GetWindowWidth() - favGlobalW) * 0.5)
                
                if filterFavoritesOnly then
                    ImGui.PushStyleColor(ImGuiCol.Button, 1.0, 0.84, 0.0, 0.25)
                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.84, 0.0, 1.0)
                else
                    ImGui.PushStyleColor(ImGuiCol.Button, 0.3, 0.3, 0.3, 0.5)
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.7, 0.7, 0.7, 1.0)
                end
                
                if ImGui.Button("\u{f04ce} Favorites Filter: " .. (filterFavoritesOnly and "ON" or "OFF"), favGlobalW, 30) then
                    filterFavoritesOnly = not filterFavoritesOnly
                end
                ImGui.PopStyleColor(2)
                
                ImGui.Spacing()
				
                ImGui.SetCursorPosX((ImGui.GetWindowWidth() - favGlobalW) * 0.5)
                
                -- Split size: 240 for the bar, 5 space, 35 for the new button
                local searchBtnW = 240
                local hideBtnW = 35

                -- GLOBAL SEARCH COLORS
                if globalSearchOpen then
                    ImGui.PushStyleColor(ImGuiCol.Button, 1.0, 0.41, 0.70, 0.75) 
                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)
                else
                    ImGui.PushStyleColor(ImGuiCol.Button, 0.3, 0.3, 0.3, 0.5)
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.7, 0.7, 0.7, 1.0)
                end

                if ImGui.Button("\u{f0349} Global Search", searchBtnW, 30) then
                    globalSearchOpen = not globalSearchOpen
                    justToggledGlobalSearch = true 
                end
                ImGui.PopStyleColor(2)
                
                ImGui.Spacing()

                if globalSearchOpen then
                    ImGui.SetCursorPosX((ImGui.GetWindowWidth() - favGlobalW) * 0.5)
                    ImGui.PushItemWidth(favGlobalW)
                    globalSearchQuery = ImGui.InputText("##GlobalSearchField", globalSearchQuery, 100)
                    ImGui.PopItemWidth()
                    ImGui.Spacing()
                end
                justToggledGlobalSearch = false 

				ImGui.Separator()
				ImGui.Spacing()

				ImGui.BeginChild("SlotsScrollArea", 0, -130, false)

                for _, slotInfo in ipairs(allSlots) do
                    local pool = GetFilteredPool(slotInfo.name, targetHash, slotInfo.id)
                    
                    local isActivelySearching = isSearching[targetHash] and isSearching[targetHash][slotInfo.id]
                    local hasItems = (pool[2] ~= "No_Records_In_JSON" and pool[2] ~= "No_Match") or isActivelySearching
                    
                    local matchesGlobalSearch = true
                    if globalSearchOpen and globalSearchQuery ~= "" then
                        matchesGlobalSearch = false
                        local gQueryLower = string.lower(globalSearchQuery)
                        if savedOutfits[slotInfo.name] then
                            for _, itemName in ipairs(savedOutfits[slotInfo.name]) do
                                if string.find(string.lower(itemName), gQueryLower, 1, true) then
                                    matchesGlobalSearch = true
                                    break
                                end
                            end
                        end
                    end

                    if hasItems and matchesGlobalSearch then
                        ImGui.PushID(slotInfo.id)
                        
                        local currentItemName = currentSelections[targetHash][slotInfo.id] or "Empty/Remove"
                        local currentIdx = 1
                        for i, v in ipairs(pool) do
                            if v == currentItemName then currentIdx = i; break end
                        end
                        if pool[currentIdx] ~= currentItemName then
                            currentIdx = 1
                            currentItemName = pool[1]
                        end
                        
                        local windowW = ImGui.GetWindowWidth()
                        local cyLine = ImGui.GetCursorPosY()
                        local isLocked = lockedSlots[targetHash][slotInfo.id]
                        local isHidden = hiddenSlots[targetHash][slotInfo.id]
                        
                        -- LEFT ICON (Normal)
                        ImGui.SetCursorPosX(10)
                        local leftIcon = "\u{f004f}"
                        local lW = ImGui.CalcTextSize(leftIcon)
                        ImGui.InvisibleButton("L_"..slotInfo.id, lW + 5, ImGui.GetTextLineHeight() + 4)
                        local leftHovered = ImGui.IsItemHovered()
                        local leftClicked = ImGui.IsItemClicked()
                        
                        ImGui.SetCursorPosX(10); ImGui.SetCursorPosY(cyLine + 2)
                        if isLocked then ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 0.3, 0.3, 1.0)
                        elseif leftHovered then ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.41, 0.70, 1.0)
                        else ImGui.PushStyleColor(ImGuiCol.Text, 0.53, 0.81, 0.98, 1.0) end
                        ImGui.Text(leftIcon)
                        ImGui.PopStyleColor()
                        
                        if leftClicked and not isLocked then
                            PlayModSound("click_menu")
                            currentIdx = currentIdx - 1
                            if currentIdx < 1 then currentIdx = #pool end
                            currentItemName = pool[currentIdx]
                            currentSelections[targetHash][slotInfo.id] = currentItemName
                            activeRefits[targetHash][slotInfo.id] = nil
                            if not isHidden then ApplyItemFromPool(target, slotInfo.id, currentItemName) end
                        end

                        -- FAST LEFT ICON (Skip Category Backward)
                        local fastLeftIcon = "\u{f17b4}"
                        local flW = ImGui.CalcTextSize(fastLeftIcon)
                        local fastLeftX = 10 + lW + 10
                        
                        ImGui.SetCursorPosX(fastLeftX); ImGui.SetCursorPosY(cyLine)
                        ImGui.InvisibleButton("FL_"..slotInfo.id, flW + 5, ImGui.GetTextLineHeight() + 4)
                        local fastLeftHovered = ImGui.IsItemHovered()
                        local fastLeftClicked = ImGui.IsItemClicked()

                        ImGui.SetCursorPosX(fastLeftX); ImGui.SetCursorPosY(cyLine + 2)
                        if isLocked then ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 0.3, 0.3, 1.0)
                        elseif fastLeftHovered then ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.41, 0.70, 1.0)
                        else ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0) end -- White
                        ImGui.Text(fastLeftIcon)
                        ImGui.PopStyleColor()

                        if fastLeftClicked and not isLocked then
                            PlayModSound("click_menu")
                            local startCat = GetCategoryPrefix(currentItemName)
                            local found = false
                            for i = currentIdx - 1, 1, -1 do
                                if GetCategoryPrefix(pool[i]) ~= startCat then
                                    currentIdx = i; found = true; break
                                end
                            end
                            if not found then -- Wraps around the list if not found
                                for i = #pool, currentIdx + 1, -1 do
                                    if GetCategoryPrefix(pool[i]) ~= startCat then
                                        currentIdx = i; break
                                    end
                                end
                            end
                            currentItemName = pool[currentIdx]
                            currentSelections[targetHash][slotInfo.id] = currentItemName
                            activeRefits[targetHash][slotInfo.id] = nil
                            if not isHidden then ApplyItemFromPool(target, slotInfo.id, currentItemName) end
                        end

                        -- RIGHT ICON (Normal)
                        local rightIcon = "\u{f0056}"
                        local rW = ImGui.CalcTextSize(rightIcon)
                        local rightX = windowW - rW - 40
                        
                        -- FAST RIGHT ICON (Skip Category Forward)
                        local fastRightIcon = "\u{f17b0}"
                        local frW = ImGui.CalcTextSize(fastRightIcon)
                        local fastRightX = rightX - frW - 15

                        -- Fast Right Button
                        ImGui.SetCursorPosX(fastRightX); ImGui.SetCursorPosY(cyLine)
                        ImGui.InvisibleButton("FR_"..slotInfo.id, frW + 10, ImGui.GetTextLineHeight() + 4)
                        local fastRightHovered = ImGui.IsItemHovered()
                        local fastRightClicked = ImGui.IsItemClicked()

                        ImGui.SetCursorPosX(fastRightX + 5); ImGui.SetCursorPosY(cyLine + 2)
                        if isLocked then ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 0.3, 0.3, 1.0)
                        elseif fastRightHovered then ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.41, 0.70, 1.0)
                        else ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0) end -- White
                        ImGui.Text(fastRightIcon)
                        ImGui.PopStyleColor()

                        if fastRightClicked and not isLocked then
                            PlayModSound("click_menu")
                            local startCat = GetCategoryPrefix(currentItemName)
                            local found = false
                            for i = currentIdx + 1, #pool do
                                if GetCategoryPrefix(pool[i]) ~= startCat then
                                    currentIdx = i; found = true; break
                                end
                            end
                            if not found then -- Wraps around
                                for i = 1, currentIdx - 1 do
                                    if GetCategoryPrefix(pool[i]) ~= startCat then
                                        currentIdx = i; break
                                    end
                                end
                            end
                            currentItemName = pool[currentIdx]
                            currentSelections[targetHash][slotInfo.id] = currentItemName
                            activeRefits[targetHash][slotInfo.id] = nil
                            if not isHidden then ApplyItemFromPool(target, slotInfo.id, currentItemName) end
                        end
                        
                        -- Right Button
                        ImGui.SetCursorPosX(rightX); ImGui.SetCursorPosY(cyLine)
                        ImGui.InvisibleButton("R_"..slotInfo.id, rW + 10, ImGui.GetTextLineHeight() + 4)
                        local rightHovered = ImGui.IsItemHovered()
                        local rightClicked = ImGui.IsItemClicked()
                        
                        ImGui.SetCursorPosX(rightX + 5); ImGui.SetCursorPosY(cyLine + 2)
                        if isLocked then ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 0.3, 0.3, 1.0)
                        elseif rightHovered then ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.41, 0.70, 1.0)
                        else ImGui.PushStyleColor(ImGuiCol.Text, 0.53, 0.81, 0.98, 1.0) end
                        ImGui.Text(rightIcon)
                        ImGui.PopStyleColor()
                        
                        if rightClicked and not isLocked then
                            PlayModSound("click_menu")
                            currentIdx = currentIdx + 1
                            if currentIdx > #pool then currentIdx = 1 end
                            currentItemName = pool[currentIdx]
                            currentSelections[targetHash][slotInfo.id] = currentItemName
                            activeRefits[targetHash][slotInfo.id] = nil
                            if not isHidden then ApplyItemFromPool(target, slotInfo.id, currentItemName) end
                        end
                        
                        -- MIDDLE SECTION COMPONENTS
                        local displayName = currentItemName:gsub("Items%.", "")
                        local displaySlotName = slotInfo.name:gsub("OutfitSlots%.", "")
                        local slotPart = string.format("[%s]: ", displaySlotName)
                        local itemPart = displayName

                        local hasValidItem = (currentItemName ~= "Empty/Remove" and currentItemName ~= "No_Records_In_JSON" and currentItemName ~= "No_Match")
                        local isFav = savedOutfits["_FAVORITES_"][currentItemName]
                        
                        local delIcon    = "\u{f015c}"
                        local searchIcon = "\u{f0349}"
                        local lockIcon   = isLocked and "\u{f033e}" or "\u{f0340}"
                        local eyeIcon    = isHidden and "\u{f0209}" or "\u{f0208}"
                        local refitIcon  = "\u{f14e8}" 
                        local favIcon    = isFav and "\u{f04ce}" or "\u{f04d2}"

                        local shouldZoom = (leftHovered or rightHovered) and not isLocked
                        if shouldZoom then ImGui.SetWindowFontScale(1.10)
                        else ImGui.SetWindowFontScale(1.0) end

                        local delW    = ImGui.CalcTextSize(delIcon)
                        local searchW = ImGui.CalcTextSize(searchIcon)
                        local lockW   = ImGui.CalcTextSize(lockIcon)
                        local eyeW    = ImGui.CalcTextSize(eyeIcon)
                        local refitW  = ImGui.CalcTextSize(refitIcon)
                        local favW    = ImGui.CalcTextSize(favIcon)
                        local slotW   = ImGui.CalcTextSize(slotPart)
                        local itemW   = ImGui.CalcTextSize(itemPart)
                        local spaceW  = ImGui.CalcTextSize(" ")
                        
                        local totalW = slotW + itemW
                        if hasValidItem then
                            totalW = delW + spaceW + slotW + itemW + spaceW + searchW + spaceW + lockW + spaceW + eyeW + spaceW + refitW + spaceW + favW
                        end

                        local startX = (windowW - totalW) * 0.5
                        local yOffset = cyLine + 2
                        if shouldZoom then yOffset = yOffset - 1 end
                        local currentDrawX = startX

                        local delHovered, delClicked = false, false
                        local searchHovered, searchClicked = false, false
                        local lockHovered, lockClicked = false, false
                        local eyeHovered, eyeClicked = false, false
                        local refitHovered, refitClickedL, refitClickedR = false, false, false
                        local favHovered, favClickedL, favClickedR = false, false, false
                        
                        if hasValidItem then
                            ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(cyLine)
                            ImGui.InvisibleButton("DEL_"..slotInfo.id, delW, ImGui.GetTextLineHeight())
                            delHovered, delClicked = ImGui.IsItemHovered(), ImGui.IsItemClicked(0)
                            
                            local cxSearch = currentDrawX + delW + spaceW + slotW + itemW + spaceW
                            ImGui.SetCursorPosX(cxSearch); ImGui.SetCursorPosY(cyLine)
                            ImGui.InvisibleButton("SRC_"..slotInfo.id, searchW, ImGui.GetTextLineHeight())
                            searchHovered, searchClicked = ImGui.IsItemHovered(), ImGui.IsItemClicked(0)
                            
                            local cxLock = cxSearch + searchW + spaceW
                            ImGui.SetCursorPosX(cxLock); ImGui.SetCursorPosY(cyLine)
                            ImGui.InvisibleButton("LCK_"..slotInfo.id, lockW, ImGui.GetTextLineHeight())
                            lockHovered, lockClicked = ImGui.IsItemHovered(), ImGui.IsItemClicked(0)
                            
                            local cxEye = cxLock + lockW + spaceW
                            ImGui.SetCursorPosX(cxEye); ImGui.SetCursorPosY(cyLine)
                            ImGui.InvisibleButton("EYE_"..slotInfo.id, eyeW, ImGui.GetTextLineHeight())
                            eyeHovered, eyeClicked = ImGui.IsItemHovered(), ImGui.IsItemClicked(0)

                            local cxRefit = cxEye + eyeW + spaceW
                            ImGui.SetCursorPosX(cxRefit); ImGui.SetCursorPosY(cyLine)
                            ImGui.InvisibleButton("RFT_"..slotInfo.id, refitW, ImGui.GetTextLineHeight())
                            refitHovered = ImGui.IsItemHovered()
                            refitClickedL = ImGui.IsItemClicked(0)
                            refitClickedR = ImGui.IsItemClicked(1)

                            local cxFav = cxRefit + refitW + spaceW
                            ImGui.SetCursorPosX(cxFav); ImGui.SetCursorPosY(cyLine)
                            ImGui.InvisibleButton("FAV_"..slotInfo.id, favW, ImGui.GetTextLineHeight())
                            favHovered, favClickedL, favClickedR = ImGui.IsItemHovered(), ImGui.IsItemClicked(0), ImGui.IsItemClicked(1)
                        end

                        if delClicked then
                            for i, v in ipairs(savedOutfits[slotInfo.name]) do
                                if v == currentItemName then table.remove(savedOutfits[slotInfo.name], i); break end
                            end
                            SaveOutfits()
                            currentSelections[targetHash][slotInfo.id] = "Empty/Remove"
                            activeRefits[targetHash][slotInfo.id] = nil
                            if not isHidden then ApplyItemFromPool(target, slotInfo.id, "Empty/Remove") end
                            hasValidItem = false
                        end
                        if searchClicked then isSearching[targetHash][slotInfo.id] = not isSearching[targetHash][slotInfo.id] end
                        if lockClicked then lockedSlots[targetHash][slotInfo.id] = not isLocked end
                        if eyeClicked then
                            hiddenSlots[targetHash][slotInfo.id] = not isHidden
                            if hiddenSlots[targetHash][slotInfo.id] then
                                ApplyItemFromPool(target, slotInfo.id, "Empty/Remove")
                            else
                                ApplyItemFromPool(target, slotInfo.id, currentItemName)
                            end
                            isHidden = hiddenSlots[targetHash][slotInfo.id]
                            eyeIcon = isHidden and "\u{f0209}" or "\u{f0208}"
                        end
                        if refitClickedL and hasValidItem then
                            local matches = GetMatchingMeshes(currentItemName)
                            if #matches > 0 then
                                if not currentRefitIndex[slotInfo.id] then currentRefitIndex[slotInfo.id] = 1 
                                else currentRefitIndex[slotInfo.id] = (currentRefitIndex[slotInfo.id] % #matches) + 1 end
                                
                                local selectedMesh = matches[currentRefitIndex[slotInfo.id]].path
                                -- FIX: Added currentItemName tracking to resolve slot hijacking loops
                                ApplyMeshNatively(target, slotInfo, selectedMesh, currentItemName)
                                activeRefits[targetHash][slotInfo.id] = selectedMesh -- Saves the active mesh
                                Game.GetPlayer():SetWarningMessage("Refit Applied: " .. selectedMesh:match("[^\\]+$"))
                            else
                                Game.GetPlayer():SetWarningMessage("No compatible mesh found (min. 2 words).")
                            end
                        end
                        if refitClickedR and hasValidItem then
                            if not refitDropdownOpen[targetHash] then refitDropdownOpen[targetHash] = {} end
                            refitDropdownOpen[targetHash][slotInfo.id] = not refitDropdownOpen[targetHash][slotInfo.id]
                        end
                        if favClickedL and hasValidItem then
                            savedOutfits["_FAVORITES_"][currentItemName] = true
                            SaveOutfits(); isFav = true; favIcon = "\u{f04ce}"
                        elseif favClickedR and hasValidItem then
                            savedOutfits["_FAVORITES_"][currentItemName] = nil
                            SaveOutfits(); isFav = false; favIcon = "\u{f04d2}"
                        end

                        if hasValidItem then
                            ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(yOffset)
                            ImGui.PushStyleColor(ImGuiCol.Text, 0.90, 0.20, 0.20, 1.0) 
                            ImGui.Text(delIcon)
                            ImGui.PopStyleColor()
                            if delHovered then ImGui.SetTooltip("Delete record from DB") end
                            currentDrawX = currentDrawX + delW + spaceW
                        end

                        ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(yOffset)
                        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.84, 0.0, 1.0)
                        ImGui.Text(slotPart)
                        ImGui.PopStyleColor()
                        currentDrawX = currentDrawX + slotW

                        ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(yOffset)
                        if isHidden then ImGui.PushStyleColor(ImGuiCol.Text, 0.4, 0.4, 0.4, 1.0)
                        elseif hasValidItem then ImGui.PushStyleColor(ImGuiCol.Text, 0.0, 0.85, 1.0, 1.0)
                        else ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0) end
                        
                        ImGui.Text(itemPart)
                        if ImGui.IsItemHovered() and not isLocked then ImGui.SetTooltip("Right-Click to Reset") end
                        if ImGui.IsItemClicked(1) and not isLocked then
                            currentSelections[targetHash][slotInfo.id] = "Empty/Remove"
                            activeRefits[targetHash][slotInfo.id] = nil
                            if not isHidden then ApplyItemFromPool(target, slotInfo.id, "Empty/Remove") end
                        end
                        ImGui.PopStyleColor()
                        currentDrawX = currentDrawX + itemW + spaceW

                        if hasValidItem then
                            ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(yOffset)
                            ImGui.PushStyleColor(ImGuiCol.Text, isSearching[targetHash][slotInfo.id] and 1.0 or 0.8, isSearching[targetHash][slotInfo.id] and 0.84 or 0.8, isSearching[targetHash][slotInfo.id] and 0.0 or 0.8, 1.0)
                            ImGui.Text(searchIcon)
                            ImGui.PopStyleColor()
                            if searchHovered then ImGui.SetTooltip("Search Item by Name") end
                            currentDrawX = currentDrawX + searchW + spaceW

                            ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(yOffset)
                            ImGui.PushStyleColor(ImGuiCol.Text, isLocked and 1.0 or 1.0, isLocked and 0.65 or 1.0, isLocked and 0.0 or 1.0, 1.0)
                            ImGui.Text(lockIcon)
                            ImGui.PopStyleColor()
                            if lockHovered then ImGui.SetTooltip(isLocked and "Unlock Selection" or "Lock Selection") end
                            currentDrawX = currentDrawX + lockW + spaceW

                            ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(yOffset)
                            ImGui.PushStyleColor(ImGuiCol.Text, isHidden and 1.0 or 1.0, isHidden and 0.65 or 1.0, isHidden and 0.0 or 1.0, 1.0)
                            ImGui.Text(eyeIcon)
                            ImGui.PopStyleColor()
                            if eyeHovered then ImGui.SetTooltip(isHidden and "Show Item" or "Hide Item") end
                            currentDrawX = currentDrawX + eyeW + spaceW

                            ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(yOffset)
                            local isDropped = refitDropdownOpen[targetHash] and refitDropdownOpen[targetHash][slotInfo.id]
                            local currentActiveRefitCheck = activeRefits[targetHash] and activeRefits[targetHash][slotInfo.id]
                            
                            if currentActiveRefitCheck then
                                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.45, 0.0, 1.0) -- Orange if applied
                            elseif isDropped then
                                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.5, 0.0, 1.0) -- Dropdown Orange
                            else
                                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0) -- Default White
                            end
                            ImGui.Text(refitIcon)
                            ImGui.PopStyleColor()
                            if refitHovered then 
                                ImGui.SetTooltip("Left Click: Rotate Compatible Meshes (min. 2 words)\nRight Click: Open Gloss Selection List") 
                            end
                            currentDrawX = currentDrawX + refitW + spaceW

                            ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(yOffset)
                            ImGui.PushStyleColor(ImGuiCol.Text, isFav and 1.0 or 1.0, isFav and 0.84 or 1.0, isFav and 0.0 or 1.0, 1.0)
                            ImGui.Text(favIcon)
                            ImGui.PopStyleColor()
                            if favHovered then ImGui.SetTooltip("Left click: Favorite\nRight click: Unfavorite") end
                        end

                        ImGui.SetWindowFontScale(1.0)

                        -- END OF MAIN LINE:
                        ImGui.SetCursorPosY(cyLine + ImGui.GetTextLineHeight() + 4)

                        -- =========================================================
                        -- NEW: CURRENT REFIT MESH DISPLAY AND REMOVAL (RIGHT-CLICK)
                        -- =========================================================
                        local currentActiveRefit = activeRefits[targetHash] and activeRefits[targetHash][slotInfo.id]
                        if currentActiveRefit and hasValidItem then
                            local refitName = currentActiveRefit:match("[^\\]+$") or currentActiveRefit
                            local isRefitHidden = hiddenRefits[targetHash] and hiddenRefits[targetHash][slotInfo.id]
                            local refitEyeIcon = isRefitHidden and "\u{f0209}" or "\u{f0208}"
                            
                            -- LÓGICA DE SAVE DO REFIT NO JSON
                            local isRefitSaved = savedRefits[targetHash] and savedRefits[targetHash][currentItemName] == currentActiveRefit
                            local saveIcon = isRefitSaved and "\u{f0193}" or "\u{f1b42}"

                            ImGui.SetCursorPosX(startX + delW + spaceW)

                            -- Botão de Guardar (Azul Bebé -> Verde Lima)
                            if isRefitSaved then
                                ImGui.PushStyleColor(ImGuiCol.Text, 0.60, 0.90, 0.20, 1.0) -- Verde Lima
                            else
                                ImGui.PushStyleColor(ImGuiCol.Text, 0.53, 0.81, 0.98, 1.0) -- Azul Bebé Claro
                            end
                            
                            ImGui.Text(saveIcon)
                            if ImGui.IsItemClicked() then
                                PlayModSound("click_menu")
                                if not savedRefits[targetHash] then savedRefits[targetHash] = {} end
                                
                                if isRefitSaved then
                                    savedRefits[targetHash][currentItemName] = nil -- Remove do JSON
                                else
                                    savedRefits[targetHash][currentItemName] = currentActiveRefit -- Guarda no JSON
                                end
                                SaveSavedRefits()
                            end
                            if ImGui.IsItemHovered() then ImGui.SetTooltip(isRefitSaved and "Refit Saved! Click to Unsave." or "Save this Refit to this Item") end
                            ImGui.PopStyleColor()

                            ImGui.SameLine()

                            -- Refit Hide/Show Button
                            if isRefitHidden then ImGui.PushStyleColor(ImGuiCol.Text, 0.4, 0.4, 0.4, 1.0)
                            else ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.45, 0.0, 1.0) end
                            ImGui.Text(refitEyeIcon)

                            if ImGui.IsItemClicked() then
                                PlayModSound("click_menu")
                                local nextHideState = not isRefitHidden
                                hiddenRefits[targetHash][slotInfo.id] = nextHideState
                                
                                local bestComp = GetTargetMeshForSlot(target, slotInfo, currentItemName)
                                if bestComp then
                                    bestComp:Toggle(not nextHideState)
                                    bestComp:TemporaryHide(nextHideState)
                                end
                            end
                            if ImGui.IsItemHovered() then ImGui.SetTooltip(isRefitHidden and "Show Refit Mesh" or "Hide Refit Mesh") end
                            ImGui.PopStyleColor()
                            
                            ImGui.SameLine()
                            
                            ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.45, 0.0, 1.0) -- Bright Orange
                            ImGui.Text("\u{f14e8} Active Refit: ")
                            ImGui.PopStyleColor()
                            
                            ImGui.SameLine()
                            if isRefitHidden then ImGui.PushStyleColor(ImGuiCol.Text, 0.4, 0.4, 0.4, 1.0)
                            else ImGui.PushStyleColor(ImGuiCol.Text, 0.85, 0.85, 0.85, 1.0) end
                            ImGui.Text(refitName)
                            ImGui.PopStyleColor()
                            
                            if ImGui.IsItemHovered() then
                                ImGui.SetTooltip("RIGHT-CLICK here to remove this refit and restore the original mesh!")
                            end
                            
                            if ImGui.IsItemClicked(1) or (ImGui.IsItemHovered() and ImGui.IsMouseClicked(1)) then
                                PlayModSound("click_menu")
                                activeRefits[targetHash][slotInfo.id] = nil
                                hiddenRefits[targetHash][slotInfo.id] = nil
                                ApplyItemFromPool(target, slotInfo.id, currentItemName)
                                Game.GetPlayer():SetWarningMessage("Refit removed! Original mesh restored.")
                            end
                            
                            ImGui.SetCursorPosY(ImGui.GetCursorPosY() + 2)
                        end

                        -- =========================================================
                        -- NEW: GLOSS REFIT WINDOW (WHITE / BLACK TEXT / ORANGE .MESH)
                        -- =========================================================
                        if refitDropdownOpen[targetHash] and refitDropdownOpen[targetHash][slotInfo.id] then
                            local matches = GetMatchingMeshes(currentItemName)
                            
                            ImGui.SetCursorPosX(startX + delW + spaceW)
                            
                            -- Premium colors for the Gloss Window
                            ImGui.PushStyleColor(ImGuiCol.ChildBg, 0.98, 0.98, 0.98, 0.98) -- Pure opaque white
                            ImGui.PushStyleColor(ImGuiCol.Border, 1.0, 0.45, 0.0, 0.8)     -- Orange border
                            ImGui.PushStyleColor(ImGuiCol.Header, 0.85, 0.85, 0.85, 0.8)   -- Elegant gray line hover
                            ImGui.PushStyleColor(ImGuiCol.HeaderHovered, 0.80, 0.80, 0.80, 1.0)
                            ImGui.PushStyleColor(ImGuiCol.HeaderActive, 0.75, 0.75, 0.75, 1.0)
                            ImGui.PushStyleVar(ImGuiStyleVar.ChildRounding, 6.0)
                            ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, 8.0, 6.0)

                            local childHeight = #matches == 0 and 40 or math.min(#matches * 26 + 16, 160)
                            ImGui.ChildFrame("RefitDrop_" .. slotInfo.id, 840, childHeight, true)
                            
                            if #matches == 0 then
                                ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 0.3, 0.3, 1.0)
                                ImGui.Text("No compatible meshes found (min. 2 matching words).")
                                ImGui.PopStyleColor()
                            else
                                for idx, match in ipairs(matches) do
                                    local shortName = match.path:match("[^\\]+$") or match.path
                                    local baseName = shortName:gsub("%.mesh$", "")
                                    local isSelected = (currentRefitIndex[slotInfo.id] == idx)
                                    
                                    -- Invisible button across the entire row width
                                    local clicked = ImGui.Selectable("##refit_sel_" .. idx, isSelected, ImGuiSelectableFlags.SpanAllColumns, 0, 20)
                                    
                                    ImGui.SameLine(8)
                                    -- Graphite Black text!
                                    ImGui.PushStyleColor(ImGuiCol.Text, 0.12, 0.12, 0.14, 1.0)
                                    ImGui.Text(string.format("[%d] %s", match.score, baseName))
                                    ImGui.PopStyleColor()
                                    
                                    ImGui.SameLine(0, 0)
                                    -- .mesh extension in Vibrant Orange!
                                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.45, 0.0, 1.0)
                                    ImGui.Text(".mesh")
                                    ImGui.PopStyleColor()
                                    
                                    if clicked then
                                        currentRefitIndex[slotInfo.id] = idx
                                        -- FIX: Added currentItemName reference mapping to solve mesh conflicts
                                        ApplyMeshNatively(target, slotInfo, match.path, currentItemName)
                                        activeRefits[targetHash][slotInfo.id] = match.path -- Saves on the row
                                        Game.GetPlayer():SetWarningMessage("Refit Applied: " .. shortName)
                                    end
                                    if ImGui.IsItemHovered() then
                                        ImGui.SetTooltip("Full Path: " .. match.path)
                                    end
                                end
                            end
                            
                            ImGui.EndChild()
                            ImGui.PopStyleVar(2)
                            ImGui.PopStyleColor(5)
                            
                            ImGui.SetCursorPosY(ImGui.GetCursorPosY() + 4)
                        end
                        
                        -- SEARCH BOX
                        if isSearching[targetHash][slotInfo.id] then
                            ImGui.SetCursorPosX(startX + delW + spaceW)
                            ImGui.PushItemWidth(200)
                            
                            local oldQuery = searchQueries[targetHash][slotInfo.id] or ""
                            local newQuery = ImGui.InputText("##SearchInput" .. slotInfo.id, oldQuery, 50)
                            
                            if newQuery ~= oldQuery then
                                searchQueries[targetHash][slotInfo.id] = newQuery
                                local newPool = GetFilteredPool(slotInfo.name, targetHash, slotInfo.id)
                                
                                if #newPool > 1 and newPool[2] ~= "No_Records_In_JSON" and newPool[2] ~= "No_Match" then
                                    currentSelections[targetHash][slotInfo.id] = newPool[2]
                                    activeRefits[targetHash][slotInfo.id] = nil
                                    if not isHidden and not isLocked then
                                        ApplyItemFromPool(target, slotInfo.id, newPool[2])
                                    end
                                else
                                    currentSelections[targetHash][slotInfo.id] = "Empty/Remove"
                                    activeRefits[targetHash][slotInfo.id] = nil
                                    if not isHidden and not isLocked then
                                        ApplyItemFromPool(target, slotInfo.id, "Empty/Remove")
                                    end
                                end
                            end
                            
                            ImGui.PopItemWidth()
                            ImGui.SetCursorPosY(ImGui.GetCursorPosY() + 4)
                        end
                        
                        ImGui.SetCursorPosY(ImGui.GetCursorPosY() + 4)
                        ImGui.PopID()
                    end
                end
                
                ImGui.EndChild()
                
                ImGui.Separator()
                ImGui.Spacing()

                -- NOVO: BOTÃO REFIT ALL CLOTHES
                local refitAllW = 220
                ImGui.SetCursorPosX((ImGui.GetWindowWidth() - refitAllW) * 0.5)
                ImGui.PushStyleColor(ImGuiCol.Button, 0.60, 0.90, 0.20, 0.85) -- Verde Limão
                ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.70, 1.0, 0.30, 1.0)
                ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.50, 0.80, 0.10, 1.0)
                ImGui.PushStyleColor(ImGuiCol.Text, 0.1, 0.1, 0.1, 1.0) -- Letras Escuras para contrastar

                if ImGui.Button("\u{f14e8} Refit All Clothes", refitAllW, 30) then
                    PlayModSound("click_menu")
                    local appliedCount = 0
                    if savedRefits[targetHash] then
                        for _, slotInfo in ipairs(allSlots) do
                            local equippedItem = currentSelections[targetHash][slotInfo.id]
                            -- Verifica se o item está equipado e tem um refit guardado
                            if equippedItem and equippedItem ~= "Empty/Remove" and not lockedSlots[targetHash][slotInfo.id] then
                                local savedMesh = savedRefits[targetHash][equippedItem]
                                if savedMesh then
                                    ApplyMeshNatively(target, slotInfo, savedMesh, equippedItem)
                                    if not activeRefits[targetHash] then activeRefits[targetHash] = {} end
                                    activeRefits[targetHash][slotInfo.id] = savedMesh
                                    appliedCount = appliedCount + 1
                                end
                            end
                        end
                        Game.GetPlayer():SetWarningMessage("Success! Applied " .. appliedCount .. " saved refits.")
                    else
                        Game.GetPlayer():SetWarningMessage("No refits saved for this NPC.")
                    end
                end
                ImGui.PopStyleColor(4)
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Applies all registered refits to currently equipped items.") end

                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()
                
                local bottomBtnW = 50
                local bottomBtnH = 30
                local totalBottomW = (bottomBtnW * 4) + 60 
                ImGui.SetCursorPosX((ImGui.GetWindowWidth() - totalBottomW) * 0.5)
                
                -- Cores do fundo para todos os botões de baixo (Branco Escuro / Prateado)
                ImGui.PushStyleColor(ImGuiCol.Button, 0.82, 0.82, 0.82, 0.95)         -- Branco Escuro
                ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.92, 0.92, 0.92, 1.0)  -- Branco mais brilhante no hover
                ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.72, 0.72, 0.72, 1.0)   -- Cinzento claro ao clicar
                
                -- Button 1: Donations (Ko-Fi)
                -- Cor do ícone: Vermelho
                ImGui.PushStyleColor(ImGuiCol.Text, 0.85, 0.15, 0.15, 1.0) 
                if ImGui.Button("\u{f10f1}##Kofi", bottomBtnW, bottomBtnH) then 
                    ImGui.SetClipboardText("https://buymeacoffee.com/vfromnightcity")
                    Game.GetPlayer():SetWarningMessage("Thank you for the support! Ko-Fi link copied.")
                end
                ImGui.PopStyleColor()
                if ImGui.IsItemHovered() then
                    ImGui.SetTooltip("Copy donation link:\nVfromNightCity is Cyberpunk MODS")
                end
                
                ImGui.SameLine()
                ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 20)
                
                -- Button 2: Endorse (Nexus)
                -- Cor do ícone: Azul Facebook (#1877F2 -> RGB aproximado: 0.09, 0.46, 0.95)
                ImGui.PushStyleColor(ImGuiCol.Text, 0.09, 0.46, 0.95, 1.0)
                if ImGui.Button("\u{f0513}##Nexus", bottomBtnW, bottomBtnH) then
                    ImGui.SetClipboardText("https://www.nexusmods.com/cyberpunk2077/mods/31327") 
                    Game.GetPlayer():SetWarningMessage("Nexus link copied! Endorse if you liked it!")
                end
                ImGui.PopStyleColor()
                if ImGui.IsItemHovered() then
                    ImGui.SetTooltip("Support on Nexus:\nNPC Outfit Manager at Cyberpunk 2077 Nexus - Mods and community")
                end
                
                ImGui.SameLine()
                ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 20)
                
                -- Button 3: Toggle Sound
                if isSoundEnabled then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.1, 0.6, 0.1, 1.0) -- Verde ligeiramente mais escuro para contraste
                    if ImGui.Button("\u{f075a}##ToggleSound", bottomBtnW, bottomBtnH) then 
                        isSoundEnabled = false 
                    end
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.8, 0.1, 0.1, 1.0) -- Vermelho ajustado para contraste
                    if ImGui.Button("\u{f075b}##ToggleSound", bottomBtnW, bottomBtnH) then 
                        isSoundEnabled = true 
                    end
                end
                ImGui.PopStyleColor()
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Enable/Disable UI Sounds") end
                
                ImGui.SameLine()
                ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 20)
                
                -- Button 4: Toggle Anim
                if isAnimPlaying then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.1, 0.6, 0.1, 1.0) 
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.2, 0.2, 0.2, 1.0) -- Cor escura caso esteja desligado para realçar no fundo branco
                end
                if ImGui.Button("\u{f15c9}##ToggleAnim", bottomBtnW, bottomBtnH) then 
                    isAnimPlaying = not isAnimPlaying
                    if isAnimPlaying then animTimer = 0 
                    else
                        if target then Game.GetStatusEffectSystem():RemoveAllStatusEffects(target:GetEntityID()) end
                    end
                end
                ImGui.PopStyleColor()
                if ImGui.IsItemHovered() then ImGui.SetTooltip("Automatic Animations... (Coming Soon)") end

                -- Remove os estilos de fundo dos botões inferiores
                ImGui.PopStyleColor(3)
                
                ImGui.Spacing()
                ImGui.Spacing()
                
                -- NOME DO DEVELOPER CENTRADO
                local devName = " VfromNightCity "
                local devW = ImGui.CalcTextSize(devName)
                ImGui.SetCursorPosX((ImGui.GetWindowWidth() - devW) * 0.5)
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.41, 0.70, 1.0) 
                ImGui.Text(devName)
                ImGui.PopStyleColor()
                ImGui.Spacing()

            end
        end 
        ImGui.End() 
    end
	
    -- THIRD WINDOW: JSON Reset Confirmation
    if isResetConfirmWindowOpen then
        ImGui.SetNextWindowSize(800, 200, ImGuiCond.Appearing)
        if ImGui.Begin("WARNING: Reset Database", true, ImGuiWindowFlags.NoSavedSettings) then
            ImGui.Spacing()
            ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.4, 0.4, 1.0)
            ImGui.TextWrapped("WARNING: You are about to delete all saved outfit records! This action cannot be undone.")
            ImGui.PopStyleColor()
            ImGui.Spacing()
            ImGui.Separator()
            ImGui.Spacing()

            local btnWidth = (ImGui.GetWindowWidth() - 30) / 2
            local btnHeight = 35
            
            ImGui.PushStyleColor(ImGuiCol.Button, 0.20, 0.85, 0.20, 0.75)
            ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.30, 0.95, 0.30, 0.75)
            ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.10, 0.75, 0.10, 0.75)
            ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)
            if ImGui.Button("YES, Delete Everything", btnWidth, btnHeight) then
                ResetJSON(); isResetConfirmWindowOpen = false 
            end
            ImGui.PopStyleColor(4)
            ImGui.SameLine()
            ImGui.PushStyleColor(ImGuiCol.Button, 0.90, 0.20, 0.20, 0.75)
            ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1.0, 0.30, 0.30, 0.75)
            ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.80, 0.10, 0.10, 0.75)
            ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)
            if ImGui.Button("NO, Cancel", btnWidth, btnHeight) then
                isResetConfirmWindowOpen = false 
            end
            ImGui.PopStyleColor(4)
        end
        ImGui.End()
    end
	
	-- FOURTH WINDOW: Body Parts Hide (Drawer Side Panel)
    if isBodyHideWindowOpen then
        -- Forces the window to snap to the right edge of the main panel layout
        ImGui.SetNextWindowPos(customizeWindowPos.x + customizeWindowSize.x, customizeWindowPos.y, ImGuiCond.Always)
        ImGui.SetNextWindowSize(300, customizeWindowSize.y, ImGuiCond.Appearing) -- Matches primary height
        
        if ImGui.Begin("Hide Body Parts", true, ImGuiWindowFlags.NoSavedSettings) then
            
            ImGui.Spacing()
            ImGui.SetWindowFontScale(1.5)
            ImGui.TextColored(1.0, 0.41, 0.70, 1.0, "\u{f02e6} Body Control")
            ImGui.SetWindowFontScale(1.0)
            ImGui.Separator()
            ImGui.Spacing()

            local target = GetLookAtNPC()
            
            if not target then
                ImGui.TextColored(1.0, 0.2, 0.2, 1.0, "WARNING: No Valid NPC Targeted!")
            else
                local targetHash = tostring(target:GetRecordID())
                if not bodyPartStates[targetHash] then bodyPartStates[targetHash] = {} end
                
                -- Interface panel rendering order
                local partsToToggle = {"Head", "Hair", "Torso", "Arms", "Hands", "Legs", "Feet"}
                local btnWidth = ImGui.GetWindowWidth() - 20
                
                for _, part in ipairs(partsToToggle) do
                    local isHidden = bodyPartStates[targetHash][part] or false
                    
                    -- Color logic: Gray (Visible) / Orange-Red (Hidden)
                    if isHidden then
                        ImGui.PushStyleColor(ImGuiCol.Button, 0.90, 0.20, 0.20, 0.75)
                        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1.0, 0.30, 0.30, 0.75)
                        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.80, 0.10, 0.10, 0.75)
                        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)
                    else
                        ImGui.PushStyleColor(ImGuiCol.Button, 0.3, 0.3, 0.3, 0.5)
                        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.4, 0.4, 0.4, 0.6)
                        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.5, 0.5, 0.5, 0.7)
                        ImGui.PushStyleColor(ImGuiCol.Text, 0.8, 0.8, 0.8, 1.0)
                    end
                    
                    local icon = isHidden and "\u{f0209}" or "\u{f0208}" -- Eye closed/open icon
                    local label = string.format("%s %s", icon, part)
                    
                    if ImGui.Button(label, btnWidth, 30) then
                        PlayModSound("click_menu")
                        ToggleBodyPart(target, targetHash, part)
                    end
                    
                    ImGui.PopStyleColor(4)
                    ImGui.Spacing()
                end
            end

            -- Check default hover on the window and its child elements
            local isHoveringWindow = ImGui.IsWindowHovered(ImGuiHoveredFlags.RootAndChildWindows)
            local isWindowFocused = ImGui.IsWindowFocused(ImGuiFocusedFlags.RootAndChildWindows)
            local isItemActive = ImGui.IsAnyItemActive() 

            local isInteracting = isHoveringWindow or isWindowFocused or isItemActive

            if isInteracting then
                hasMouseEnteredBodyHide = true
            end

            if hasMouseEnteredBodyHide and not isInteracting then
                isBodyHideWindowOpen = false
                hasMouseEnteredBodyHide = false
            end
        end 
        ImGui.End()
    end
	
	-- FIFTH WINDOW: Saved Refits Viewer (Drawer Side Panel)
    if isRefitViewerWindowOpen then
        ImGui.SetNextWindowPos(customizeWindowPos.x + customizeWindowSize.x, customizeWindowPos.y, ImGuiCond.Always)
        ImGui.SetNextWindowSize(300, customizeWindowSize.y, ImGuiCond.Appearing)
        
        if ImGui.Begin("Saved Refits List", true, ImGuiWindowFlags.NoSavedSettings) then
            
            ImGui.Spacing()
            ImGui.SetWindowFontScale(1.5)
            ImGui.TextColored(0.60, 0.90, 0.20, 1.0, "\u{f14e8} Saved Refits")
            ImGui.SetWindowFontScale(1.0)
            ImGui.Separator()
            ImGui.Spacing()

            local target = GetLookAtNPC()
            
            if not target then
                ImGui.TextColored(1.0, 0.2, 0.2, 1.0, "WARNING: No Valid NPC Targeted!")
            else
                local targetHash = tostring(target:GetRecordID())
                
                if not savedRefits[targetHash] or next(savedRefits[targetHash]) == nil then
                    ImGui.TextColored(0.7, 0.7, 0.7, 1.0, "No Refits saved for this NPC.")
                else
                    local btnWidth = ImGui.GetWindowWidth() - 20
                    for itemName, meshPath in pairs(savedRefits[targetHash]) do
                        local shortItem = itemName:gsub("Items%.", "")
                        local shortMesh = meshPath:match("[^\\]+$") or meshPath
                        
                        ImGui.PushStyleColor(ImGuiCol.Button, 0.2, 0.2, 0.2, 0.5)
                        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.3, 0.3, 0.3, 0.8)
                        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.4, 0.4, 0.4, 1.0)
                        ImGui.PushStyleColor(ImGuiCol.Text, 0.85, 0.85, 0.85, 1.0)
                        
                        -- Clicar num nome não o aplica automaticamente pois pode não estar no slot certo, 
                        -- mas mostra os detalhes para feedback do user.
                        if ImGui.Button(shortItem, btnWidth, 30) then
                            PlayModSound("click_menu")
                            Game.GetPlayer():SetWarningMessage("Linked Mesh: " .. shortMesh)
                        end
                        ImGui.PopStyleColor(4)
                        
                        if ImGui.IsItemHovered() then
                            ImGui.SetTooltip("Linked Mesh:\n" .. meshPath)
                        end
                        ImGui.Spacing()
                    end
                end
            end

            -- Lógica de Auto-Hide idêntica à do Body Control
            local isHoveringWindow = ImGui.IsWindowHovered(ImGuiHoveredFlags.RootAndChildWindows)
            local isWindowFocused = ImGui.IsWindowFocused(ImGuiFocusedFlags.RootAndChildWindows)
            local isItemActive = ImGui.IsAnyItemActive() 

            local isInteracting = isHoveringWindow or isWindowFocused or isItemActive

            if isInteracting then
                hasMouseEnteredRefitViewer = true
            end

            if hasMouseEnteredRefitViewer and not isInteracting then
                isRefitViewerWindowOpen = false
                hasMouseEnteredRefitViewer = false
            end

        end 
        ImGui.End()
    end
	
	-- SIXTH WINDOW: Hair Spawner (Drawer Side Panel)
    if isHairSpawnerWindowOpen then
        ImGui.SetNextWindowPos(customizeWindowPos.x + customizeWindowSize.x, customizeWindowPos.y, ImGuiCond.Always)
        ImGui.SetNextWindowSize(300, customizeWindowSize.y, ImGuiCond.Appearing)
        
        if ImGui.Begin("Hair Spawner", true, ImGuiWindowFlags.NoSavedSettings) then
            ImGui.Spacing()
            ImGui.SetWindowFontScale(1.5)
            ImGui.TextColored(0.85, 0.65, 0.13, 1.0, "\u{f10f0} Hair Meshes")
            ImGui.SetWindowFontScale(1.0)
            ImGui.Separator()
            ImGui.Spacing()

            local target = GetLookAtNPC()
            
            if not target then
                ImGui.TextColored(1.0, 0.2, 0.2, 1.0, "WARNING: No Valid NPC Targeted!")
            else
                local targetHash = tostring(target:GetRecordID())
                
                -- Organiza a lista: Favoritos aparecem no topo
                local sortedHairs = {}
                for _, p in ipairs(hairMeshesList) do table.insert(sortedHairs, p) end
                table.sort(sortedHairs, function(a, b)
                    local aFav = savedFavoriteHairs[a] and 1 or 0
                    local bFav = savedFavoriteHairs[b] and 1 or 0
                    if aFav ~= bFav then return aFav > bFav end
                    return a < b
                end)

                ImGui.BeginChild("HairListScroll", 0, 0, false)
                local btnWidth = ImGui.GetWindowWidth() - 50 -- Ajuste para caber a estrela
                
                for i, meshPath in ipairs(sortedHairs) do
                    local shortMesh = meshPath:match("[^\\]+$") or meshPath
                    local isFav = savedFavoriteHairs[meshPath]
                    
                    -- Botão da Estrela de Favorito
                    local favIcon = isFav and "\u{f04ce}" or "\u{f04d2}"
                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.84, 0.0, 1.0) -- Dourado
                    ImGui.PushStyleColor(ImGuiCol.Button, 0, 0, 0, 0) -- Fundo Invisível
                    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.2, 0.2, 0.2, 0.5)
                    ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.3, 0.3, 0.3, 0.5)
                    
                    if ImGui.Button(favIcon .. "##fav_hair_" .. i, 30, 30) then
                        PlayModSound("click_menu")
                        if isFav then savedFavoriteHairs[meshPath] = nil else savedFavoriteHairs[meshPath] = true end
                        SaveFavoriteHairs()
                    end
                    ImGui.PopStyleColor(4)
                    
                    ImGui.SameLine()
                    
                    -- VERIFICAÇÃO: O cabelo atual está equipado no NPC?
                    local isHairActive = (activeRefits[targetHash] and activeRefits[targetHash]["AttachmentSlots.Head"] == meshPath)
                    
                    -- Botão da Mesh com cores dinâmicas
                    if isHairActive then
                        -- Amarelo Dourado com texto Preto Fosco (Grafite)
                        ImGui.PushStyleColor(ImGuiCol.Button, 0.85, 0.65, 0.13, 0.85)
                        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1.0, 0.84, 0.0, 1.0)
                        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.72, 0.53, 0.04, 1.0)
                        ImGui.PushStyleColor(ImGuiCol.Text, 0.12, 0.12, 0.12, 1.0)
                    else
                        -- Estilo padrão (Cinzento / Texto Claro)
                        ImGui.PushStyleColor(ImGuiCol.Button, 0.2, 0.2, 0.2, 0.5)
                        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.3, 0.3, 0.3, 0.8)
                        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.4, 0.4, 0.4, 1.0)
                        ImGui.PushStyleColor(ImGuiCol.Text, 0.85, 0.85, 0.85, 1.0)
                    end
                    
                    if ImGui.Button(shortMesh .. "##hair_btn_" .. i, btnWidth, 30) then
                        PlayModSound("click_menu")
                        -- Dá Spawn à mesh utilizando as tuas funções de Refits
                        local dummySlot = { id = "AttachmentSlots.Head", name = "Hair" }
                        ApplyMeshNatively(target, dummySlot, meshPath, "Hair_Mesh")
                        
                        -- Regista como active refit para se poder remover mais tarde
                        if not activeRefits[targetHash] then activeRefits[targetHash] = {} end
                        activeRefits[targetHash][dummySlot.id] = meshPath
                        
                        Game.GetPlayer():SetWarningMessage("Spawned Hair: " .. shortMesh)
                    end
                    ImGui.PopStyleColor(4)
                    
                    if ImGui.IsItemHovered() then ImGui.SetTooltip("Path: " .. meshPath) end
                end
                ImGui.EndChild()
            end

            -- Lógica de Auto-Hide da janela
            local isHoveringWindow = ImGui.IsWindowHovered(ImGuiHoveredFlags.RootAndChildWindows)
            local isWindowFocused = ImGui.IsWindowFocused(ImGuiFocusedFlags.RootAndChildWindows)
            local isItemActive = ImGui.IsAnyItemActive() 

            local isInteracting = isHoveringWindow or isWindowFocused or isItemActive

            if isInteracting then hasMouseEnteredHairSpawner = true end
            if hasMouseEnteredHairSpawner and not isInteracting then
                isHairSpawnerWindowOpen = false
                hasMouseEnteredHairSpawner = false
            end

        end 
        ImGui.End()
    end
	
	-- ============================================================================
    -- SEVENTH WINDOW: Body Type Changer (Drawer Side Panel)
    -- ============================================================================
    if isBodyTypeWindowOpen then
        ImGui.SetNextWindowPos(customizeWindowPos.x + customizeWindowSize.x, customizeWindowPos.y, ImGuiCond.Always)
        ImGui.SetNextWindowSize(300, customizeWindowSize.y, ImGuiCond.Appearing)
        
        if ImGui.Begin("Body Type Changer", true, ImGuiWindowFlags.NoSavedSettings) then
            ImGui.Spacing()
            ImGui.SetWindowFontScale(1.5)
            ImGui.TextColored(1.0, 0.25, 0.25, 1.0, "\u{f115d} Body Types")
            ImGui.SetWindowFontScale(1.0)
            ImGui.Separator()
            ImGui.Spacing()

            local target = GetLookAtNPC()
            
            if not target then
                ImGui.TextColored(1.0, 0.2, 0.2, 1.0, "WARNING: No Valid NPC Targeted!")
            else
                local targetHash = tostring(target:GetRecordID())
                
                -- Organiza a lista: Favoritos no topo, seguidos de ordem alfabética
                local sortedBodies = {}
                for _, p in ipairs(bodyTypeMeshesList) do 
                    table.insert(sortedBodies, p) 
                end
                
                table.sort(sortedBodies, function(a, b)
                    local aFav = savedFavoriteBodyTypes[a] and 1 or 0
                    local bFav = savedFavoriteBodyTypes[b] and 1 or 0
                    if aFav ~= bFav then return aFav > bFav end
                    return a < b
                end)

                ImGui.BeginChild("BodyListScroll", 0, 0, false)
                
                for i, meshPath in ipairs(sortedBodies) do
                    -- Extrai o nome do ficheiro (suporta barras / e \)
                    local shortMesh = meshPath:match("[^/\\]+$") or meshPath
                    local isFav = savedFavoriteBodyTypes[meshPath]
                    
                    -- --------------------------------------------------------
                    -- 1. BOTÃO DE FAVORITO (Estrela)
                    -- --------------------------------------------------------
                    local favIcon = isFav and "\u{f04ce}" or "\u{f04d2}"
                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.84, 0.0, 1.0)          -- Dourado
                    ImGui.PushStyleColor(ImGuiCol.Button, 0, 0, 0, 0)               -- Fundo Invisível
                    ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.2, 0.2, 0.2, 0.5)
                    ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.3, 0.3, 0.3, 0.5)
                    
                    if ImGui.Button(favIcon .. "##fav_body_" .. i, 28, 28) then
                        PlayModSound("click_menu")
                        if isFav then 
                            savedFavoriteBodyTypes[meshPath] = nil 
                        else 
                            savedFavoriteBodyTypes[meshPath] = true 
                        end
                        SaveFavoriteBodyTypes()
                    end
                    ImGui.PopStyleColor(4)
                    
                    ImGui.SameLine()

                    -- --------------------------------------------------------
                    -- 2. ETIQUETA "MOD" (Se for um mod externo)
                    -- --------------------------------------------------------
                    if isModdedMap and isModdedMap[meshPath] then
                        ImGui.PushStyleColor(ImGuiCol.Button, 0.8, 0.1, 0.1, 0.9)        -- Vermelho
                        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.8, 0.1, 0.1, 0.9)
                        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.8, 0.1, 0.1, 0.9)
                        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)             -- Texto Branco
                        
                        ImGui.Button(" MOD ##tag_" .. i, 0, 28)
                        ImGui.PopStyleColor(4)
                        
                        ImGui.SameLine()
                    end
                    
                    -- --------------------------------------------------------
                    -- 3. BOTÃO PRINCIPAL DA MESH
                    -- --------------------------------------------------------
                    local isBodyActive = (activeBodyTypes[targetHash] == meshPath)
                    local availWidth = ImGui.GetContentRegionAvail() -- Preenche dinamicamente o espaço restante
                    
                    if isBodyActive then
                        ImGui.PushStyleColor(ImGuiCol.Button, 1.0, 0.25, 0.25, 0.85)        -- Vermelho Ativo
                        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1.0, 0.35, 0.35, 1.0)
                        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.80, 0.15, 0.15, 1.0)
                        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)             -- Texto Branco
                    else
                        ImGui.PushStyleColor(ImGuiCol.Button, 0.2, 0.2, 0.2, 0.5)
                        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.3, 0.3, 0.3, 0.8)
                        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.4, 0.4, 0.4, 1.0)
                        ImGui.PushStyleColor(ImGuiCol.Text, 0.85, 0.85, 0.85, 1.0)
                    end
                    
                    if ImGui.Button(shortMesh .. "##body_btn_" .. i, availWidth, 28) then
                        PlayModSound("click_menu")
                        local dummyTorsoSlot = { id = "AttachmentSlots.Torso", name = "Torso" }
                        ApplyMeshNatively(target, dummyTorsoSlot, meshPath, "Body_Mesh")
                        activeBodyTypes[targetHash] = meshPath
                        Game.GetPlayer():SetWarningMessage("Body Type Applied!")
                    end
                    ImGui.PopStyleColor(4)
                    
                    if ImGui.IsItemHovered() then
                        ImGui.SetTooltip("Path: " .. meshPath)
                    end
                    
                    ImGui.Spacing()
                end
                
                ImGui.EndChild()
            end

            -- --------------------------------------------------------
            -- LÓGICA DE AUTO-HIDE DO PAINEL
            -- --------------------------------------------------------
            local isHoveringWindow = ImGui.IsWindowHovered(ImGuiHoveredFlags.RootAndChildWindows)
            local isWindowFocused = ImGui.IsWindowFocused(ImGuiFocusedFlags.RootAndChildWindows)
            local isItemActive = ImGui.IsAnyItemActive() 

            local isInteracting = isHoveringWindow or isWindowFocused or isItemActive

            if isInteracting then
                hasMouseEnteredBodyType = true
            end

            if hasMouseEnteredBodyType and not isInteracting then
                isBodyTypeWindowOpen = false
                hasMouseEnteredBodyType = false
            end
        end 
        ImGui.End()
    end
	
    ImGui.PopStyleColor(7)	
end)

-- ============================================================================
-- Hotkey Registration
-- ============================================================================
registerHotkey("NPCOutfitManagerToggle", "Toggle NPC Outfit Manager Menu", function()
    isMainWindowOpen = not isMainWindowOpen
end)

registerForEvent("onUpdate", function(delta)
	Cron.Update(delta)
    if autoRetryNakedTarget then
        ForceNakedState(autoRetryNakedTarget)
    end
    
    if isAnimPlaying then
        animTimer = animTimer - delta
        if animTimer <= 0 then
            local currentTarget = GetLookAtNPC()
            if currentTarget then
                PlayRandomNPCAnimation(currentTarget)
            end
            animTimer = 30.0
        end
    end
end)