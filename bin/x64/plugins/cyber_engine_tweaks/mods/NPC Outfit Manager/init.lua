-- ============================================================================
-- MOD: NPC Outfit Manager (CET Overlay Edition) - EVOLVING WARDROBE
-- ============================================================================

local modName = "NPC Outfit Manager"
local jsonFileName = "npc_outfits.json"
local looksJsonFileName = "npc_saved_looks.json"

-- Global Wardrobe: { ["Head"] = {"Item1", "Item2"}, ["Torso"] = {"Item3"}, ["_FAVORITES_"] = {["Items.X"] = true} }
local savedOutfits = {}

-- UI Window State
local isMainWindowOpen = false 
local isCustomizeWindowOpen = false
local isResetConfirmWindowOpen = false

-- ============================================================================
-- State Variables for New Features (Audio & Anims)
-- ============================================================================
local isSoundEnabled = true     -- Controla se o áudio está ativo
local isAnimPlaying = false     -- Controla se o loop de animação está ativo
local animTimer = 0.0           -- Temporizador de 30 segundos

-- State Variables for New Features
local filterFavoritesOnly = false
local globalSearchOpen = false        -- NOVO: Controla se a barra global está aberta
local globalSearchQuery = ""          -- NOVO: Guarda o texto pesquisado globalmente
local justToggledGlobalSearch = false -- NOVO: Evita que a barra feche mal cliques no botão
local hiddenSlots = {}   -- Memoriza quais os slots ocultos (Eye icon)
local lockedSlots = {}   -- Memoriza quais os slots bloqueados (Lock icon)
local isSearching = {}   -- Memoriza quais os slots com a barra de pesquisa aberta
local searchQueries = {} -- Guarda o texto digitado na pesquisa de cada slot

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

local function LoadOutfits()
    local file = io.open(jsonFileName, "r")
    if file then
        local content = file:read("*a")
        savedOutfits = json.decode(content) or {}
        file:close()
        
        -- Automatic migration se necessário...
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
    
    -- Limpar legado se existir para não ocupar espaço
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

-- ADICIONA ESTAS DUAS FUNÇÕES NOVAS AQUI
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
        -- O pcall (protected call) impede que o mod crashe caso o som ou o Audioware não existam
        pcall(function()
            Game.GetAudioSystem():Play(CName.new(soundName))
        end)
    end
end

local function PlayRandomNPCAnimation(target)
    if not target then return end
    
    -- A tua lista de animações personalizadas
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
    
    -- Escolhe uma animação aleatória da tabela
    local randomAnim = npcAnimations[math.random(1, #npcAnimations)]
    
    -- ========================================================================
    -- ATENÇÃO: Como estas strings são de Workspots/AMM, terás de chamar a tua 
    -- própria função ou a API do AMM aqui para forçar a animação. 
    -- Exemplo teórico:
    -- se o AMM estiver instalado: GetMod("AMM"):PlayAnimation(target, randomAnim)
    -- ========================================================================
    
    -- Mostra no ecrã qual foi a animação sorteada para testares se o loop funciona
    -----------------------------------------Game.GetPlayer():SetWarningMessage("Animação de 30s: " .. randomAnim)
end

-- ============================================================================
-- Equipment and Target Manipulation Logic
-- ============================================================================

local function GetFilteredPool(slotName, targetHash, slotId)
    local items = { "Empty/Remove" }
    local hasRecords = false
    
    local searchStr = searchQueries[targetHash] and searchQueries[targetHash][slotId] and string.lower(searchQueries[targetHash][slotId]) or ""
    -- NOVO: Captura o texto da pesquisa global também
    local globalStr = (globalSearchOpen and globalSearchQuery ~= "") and string.lower(globalSearchQuery) or ""
    
    if savedOutfits[slotName] then
        for _, itemName in ipairs(savedOutfits[slotName]) do
            hasRecords = true
            local isFav = savedOutfits["_FAVORITES_"][itemName]
            
            -- Lógica dos Filtros (Estrela Amarela Global, Lupa Local e Pesquisa Global)
            local matchesFav = (not filterFavoritesOnly) or isFav
            local matchesLocalSearch = searchStr == "" or string.find(string.lower(itemName), searchStr, 1, true)
            local matchesGlobalSearch = globalStr == "" or string.find(string.lower(itemName), globalStr, 1, true)
            
            -- O item só entra na lista se passar em TODOS os filtros
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

-- Captures all equipped items via TransactionSystem to include EquipmentEX
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
                -- Cleans the ID extracting only "Items.X"
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

-- Variável para guardar o NPC e tentar de forma invisível até carregar
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
        local aparenciaCName = CName.new(nakedAppName)
        target:PrefetchAppearanceChange(aparenciaCName)
        target:ScheduleAppearanceChange(aparenciaCName)
        
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
    local aparenciaCName = CName.new(nextAppearanceStr)
    
    target:PrefetchAppearanceChange(aparenciaCName)
    target:ScheduleAppearanceChange(aparenciaCName)
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

-- ============================================================================
-- Filtro de Nomenclatura Vanilla (Base Game)
-- ============================================================================
local function IsVanillaItem(itemName)
    -- 1. Verifica os prefixos originais
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
            return true -- Bloqueia: É um item do jogo base!
        end
    end
    
    -- 2. Verifica palavras-chave comuns de qualidade/estilo Vanilla
    local vanillaKeywords = { "_basic", "_poor", "_rich", "_old" }
    local lowerItemName = string.lower(itemName)
    for _, keyword in ipairs(vanillaKeywords) do
        if string.find(lowerItemName, keyword) then 
            return true -- Bloqueia: Contém uma das palavras-chave Vanilla!
        end
    end

    -- 3. Verifica o padrão de dois pares de números (ex: 01 e 02)
    -- O padrão "%d%d.*%d%d" deteta 2 números, qualquer texto, e mais 2 números.
    if string.find(itemName, "%d%d.*%d%d") then 
        return true -- Bloqueia: O nome tem duas sequências de 2 números!
    end
    
    return false -- Passou nos filtros todos, é garantidamente um Mod!
end

-- ============================================================================
-- Auto-Scanner: Search TweakDB for Custom Clothing ONLY (Mods)
-- ============================================================================
local function ScanAndUnlockAllClothes()
    local addedCount = 0
    -- Pede à base de dados do jogo todos os records de roupa
    local records = TweakDBInterface.GetRecords("gamedataClothing_Record")
    
    for _, record in ipairs(records) do
        local itemID = record:GetID()
        -- Extrai apenas a parte "Items.nome_do_item" do TweakDBID
        local itemStr = tostring(itemID):match("(Items%.[%w_]+)")
        
        if itemStr then
            -- Só avança se o item NÃO for do jogo base
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
    LoadLooks() -- ADICIONA ISTO
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

        -- UPDATED BUTTON: Stores items in an evolving and accumulative way!
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
            isResetConfirmWindowOpen = true -- Abre a janela de confirmação em vez de apagar logo
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
        
        -- Draws icon and text
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
            local target = GetLookAtNPC()
            if not target then
                ImGui.TextColored(1.0, 0.2, 0.2, 1.0, "WARNING: No Valid NPC Targeted!")
            else
                local targetHash = tostring(target:GetRecordID())
                
                -- Inicializar tabelas de estado para este NPC
                if not hiddenSlots[targetHash] then hiddenSlots[targetHash] = {} end
                if not lockedSlots[targetHash] then lockedSlots[targetHash] = {} end
                if not isSearching[targetHash] then isSearching[targetHash] = {} end
                if not searchQueries[targetHash] then searchQueries[targetHash] = {} end
                if not currentSelections[targetHash] then currentSelections[targetHash] = {} end
                
                ImGui.Spacing()
                ImGui.SetWindowFontScale(3.5)
                local npcHeaderIcon = "\u{f1a62}"
                local npcHeaderIconW = ImGui.CalcTextSize(npcHeaderIcon)
                ImGui.SetCursorPosX((ImGui.GetWindowWidth() - npcHeaderIconW) * 0.5)
                ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)
                ImGui.Text(npcHeaderIcon)
                ImGui.PopStyleColor()
                
                ImGui.SetWindowFontScale(1.0)
                ImGui.Spacing()
                ImGui.Separator()
                ImGui.Spacing()

                local btnW = ImGui.GetWindowWidth() - 20
                local btnH = 30

                -- =======================================
                -- BOTÕES GLOBAIS DO NPC (ALINHADOS E DINÂMICOS)
                -- =======================================
                -- Subtrai as margens e os espaços da largura da janela, e divide por 4
                local topBtnW = (ImGui.GetWindowWidth() - 44) / 4

                local function DrawIconButton(id, icon, text, textR, textG, textB, btnWidth, onClick)
                    local cx1 = ImGui.GetCursorPosX()
                    local cy1 = ImGui.GetCursorPosY()
                    
                    local iw1 = ImGui.CalcTextSize(icon)
                    local tw1 = ImGui.CalcTextSize(text)
                    
                    -- Agora o botão respeita a largura da janela
                    if ImGui.Button(id, btnWidth, btnH) then onClick() end
                    local sX1 = cx1 + (btnWidth - (iw1 + tw1 + iw1)) * 0.5
                    local sY1 = cy1 + (btnH - ImGui.GetTextLineHeight()) * 0.5

                    -- Removemos o PushClipRect e o PopClipRect daqui!

                    ImGui.SetCursorPosX(sX1); ImGui.SetCursorPosY(sY1)
                    ImGui.PushStyleColor(ImGuiCol.Text, textR, textG, textB, 1.0)
                    ImGui.Text(icon)
                    ImGui.SetCursorPosX(sX1 + iw1); ImGui.SetCursorPosY(sY1)
                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)
                    ImGui.Text(text)
                    ImGui.SetCursorPosX(sX1 + iw1 + tw1); ImGui.SetCursorPosY(sY1)
                    ImGui.PushStyleColor(ImGuiCol.Text, textR, textG, textB, 1.0)
                    ImGui.Text(icon)
                    ImGui.PopStyleColor(3)
                    
                    -- Coloca o cursor imediatamente à frente para o próximo botão
                    ImGui.SetCursorPosX(cx1 + btnWidth + 8)
                    ImGui.SetCursorPosY(cy1)
                end

                DrawIconButton("##ForceNaked", "\u{f01f4}", " Naked ", 0.60, 0.20, 0.65, topBtnW, function() ForceNakedState(target) end)
                DrawIconButton("##RotateOutfit", "\u{f0464}", " Rotate ", 0.20, 0.85, 0.20, topBtnW, function() CycleNPCAppearanceNative(target) end)
                
                local i3, t3, r3, g3, b3 = "\u{f1222}", " Copy V ", 1.0, 1.0, 1.0
                if savedVOutfitForNPC then
                    i3, t3, r3, g3, b3 = "\u{f1a7a}", " Apply V ", 0.90, 0.70, 0.10
                end
                DrawIconButton("##CopyApplyV", i3, t3, r3, g3, b3, topBtnW, function()
                    if not savedVOutfitForNPC then
                        savedVOutfitForNPC = GetPlayerOutfit()
                        Game.GetPlayer():SetWarningMessage("Clothes saved! Click again to apply onto the NPC.")
                    else
                        for _, slotInfo in ipairs(allSlots) do
                            local itemString = savedVOutfitForNPC[slotInfo.name]
                            if not lockedSlots[targetHash][slotInfo.id] then
                                ApplyItemFromPool(target, slotInfo.id, itemString or "Empty/Remove")
                                currentSelections[targetHash][slotInfo.id] = itemString or "Empty/Remove"
                            end
                        end
                        savedVOutfitForNPC = nil 
                        Game.GetPlayer():SetWarningMessage("V's clothes applied onto the NPC!")
                    end
                end)

                DrawIconButton("##DeleteData", "\u{f06c9}", " Delete ", 0.90, 0.20, 0.20, topBtnW, function()
                    ClearAllNPCSlots(target)
                    currentSelections[targetHash] = {}
                    hiddenSlots[targetHash] = {}
                    lockedSlots[targetHash] = {}
                    searchQueries[targetHash] = {}
                end)

                -- QUEBRA DE LINHA MANUAL PARA SAIR DO ALINHAMENTO LATERAL
                ImGui.SetCursorPosY(ImGui.GetCursorPosY() + btnH + 10)
                ImGui.SetCursorPosX(10)

                ImGui.Spacing()
                
                -- =======================================
                -- 5 APPEARANCE BUTTONS
                -- =======================================
                if not savedLooks[targetHash] then savedLooks[targetHash] = {} end
                local btnWidth = (ImGui.GetWindowWidth() - 50) / 5
                for i = 1, 5 do
                    -- FORÇA O NÚMERO A SER TEXTO PARA O JSON NÃO SE PERDER NO DIA A SEGUIR
                    local str_i = tostring(i) 
                    local iconStr = string.format("\u{f02c8} %d", i)
                    
                    -- Verifica se está guardado no formato novo (texto) ou no antigo (número)
                    local isLookSaved = (savedLooks[targetHash][str_i] ~= nil) or (savedLooks[targetHash][i] ~= nil)
                    
                    if isLookSaved then
                        iconStr = "[ " .. iconStr .. " ]"
                        -- COR VERDE
                        ImGui.PushStyleColor(ImGuiCol.Button, 0.56, 0.93, 0.56, 0.75)
                        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 0.46, 0.83, 0.46, 0.75)
                        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 0.36, 0.73, 0.36, 0.75)
                    else
                        -- COR ROSA ORIGINAL
                        ImGui.PushStyleColor(ImGuiCol.Button, 1.0, 0.41, 0.70, 0.75)
                        ImGui.PushStyleColor(ImGuiCol.ButtonHovered, 1.0, 0.55, 0.75, 0.75)
                        ImGui.PushStyleColor(ImGuiCol.ButtonActive, 1.0, 0.30, 0.60, 0.75)
                    end
                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)

                    if ImGui.Button(iconStr .. "##Look" .. i, btnWidth, 30) then
                        if not isLookSaved then
							PlayModSound("save_outfit")
                            
							-- CAPTURA A APPEARANCE NATIVA ATUAL
                            local currentAppCName = target:GetCurrentAppearanceName()
                            local baseAppearance = currentAppCName and NameToString(currentAppCName) or ""
                            
                            -- GUARDA TUDO NOVO FORMATO (Appearance + Slots)
                            savedLooks[targetHash][str_i] = {
                                _base_appearance = baseAppearance,
                                items = CopySelections(currentSelections[targetHash])
                            }
                            SaveLooks()
                            -------------------------------Game.GetPlayer():SetWarningMessage("Appearance " .. i .. " Saved!")
                        else
                            -- CARREGA OS DADOS GUARDADOS
                            local savedData = savedLooks[targetHash][str_i] or savedLooks[targetHash][i]
                            local loadedOutfit = {}
                            
                            -- Retrocompatibilidade: Identifica se é o Formato Novo ou Antigo
                            if savedData.items then
                                loadedOutfit = CopySelections(savedData.items)
                                
                                -- Aplica a base appearance primeiro se existir!
                                if savedData._base_appearance and savedData._base_appearance ~= "" then
                                    local aparenciaCName = CName.new(savedData._base_appearance)
                                    target:PrefetchAppearanceChange(aparenciaCName)
                                    target:ScheduleAppearanceChange(aparenciaCName)
                                end
                            else
                                -- Formato Antigo (Lê apenas itens diretamente)
                                loadedOutfit = CopySelections(savedData)
                            end
                            
                            -- EQUIPA OS ITEMS
                            for _, slotInfo in ipairs(allSlots) do
                                local itemName = loadedOutfit[slotInfo.id]
                                if type(itemName) == "number" then itemName = "Empty/Remove" end 
                                
                                if itemName and not lockedSlots[targetHash][slotInfo.id] then
                                    currentSelections[targetHash][slotInfo.id] = itemName
                                    if not hiddenSlots[targetHash][slotInfo.id] then
                                        ApplyItemFromPool(target, slotInfo.id, itemName)
                                    end
                                end
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
                    
                    -- Limpa os dados sem duplicações de código e usando o SaveLooks() correto
                    if ImGui.IsItemClicked(1) and isLookSaved then
                        savedLooks[targetHash][str_i] = nil
                        savedLooks[targetHash][i] = nil -- limpa o registo antigo também se existir
                        SaveLooks() 
                        Game.GetPlayer():SetWarningMessage("Appearance " .. i .. " Deleted!")
                    end
                    
                    if i < 5 then ImGui.SameLine() end
                end

                ImGui.Spacing()
                ImGui.Separator()
                
                -- =======================================
                -- BOTÃO FAVORITOS GLOBAL (NOVO)
                -- =======================================
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
				
				-- =======================================
                -- BOTÃO GLOBAL SEARCH (NOVO)
                -- =======================================
                ImGui.SetCursorPosX((ImGui.GetWindowWidth() - favGlobalW) * 0.5)
                if globalSearchOpen then
                    ImGui.PushStyleColor(ImGuiCol.Button, 1.0, 0.41, 0.70, 0.75) -- Rosa ativo
                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0)
                else
                    ImGui.PushStyleColor(ImGuiCol.Button, 0.3, 0.3, 0.3, 0.5)
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.7, 0.7, 0.7, 1.0)
                end

                if ImGui.Button("\u{f0349} Global Search", favGlobalW, 30) then
                    globalSearchOpen = not globalSearchOpen
                    justToggledGlobalSearch = true -- Impede fechar no frame do clique
                end
                ImGui.PopStyleColor(2)
                ImGui.Spacing()

                -- Caixa de texto do Global Search
                if globalSearchOpen then
                    ImGui.SetCursorPosX((ImGui.GetWindowWidth() - favGlobalW) * 0.5)
                    ImGui.PushItemWidth(favGlobalW)
                    
                    globalSearchQuery = ImGui.InputText("##GlobalSearchField", globalSearchQuery, 100)
                    
                    -- A REGRA DE FECHAR AO CLICAR FORA FOI REMOVIDA DAQUI
                    
                    ImGui.PopItemWidth()
                    ImGui.Spacing()
                end
                justToggledGlobalSearch = false -- Reseta a proteção de clique

				-- ADICIONA ESTAS DUAS LINHAS PARA CRIAR O SEPARADOR:
				ImGui.Separator()
				ImGui.Spacing()

				-- =======================================
				-- INÍCIO DA ÁREA DE SCROLL INDEPENDENTE
				-- =======================================
				ImGui.BeginChild("SlotsScrollArea", 0, -75, false)

                -- =======================================
                -- LISTA DE SLOTS
                -- =======================================
                for _, slotInfo in ipairs(allSlots) do
                    local pool = GetFilteredPool(slotInfo.name, targetHash, slotInfo.id)
                    
                    -- NOVA LÓGICA DE VISIBILIDADE
                    local isActivelySearching = isSearching[targetHash] and isSearching[targetHash][slotInfo.id]
                    local hasItems = (pool[2] ~= "No_Records_In_JSON" and pool[2] ~= "No_Match") or isActivelySearching
                    
                    -- FILTRAGEM GLOBAL (NOVO)
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

                    -- Só renderiza se tiver itens E corresponder à pesquisa global
                    if hasItems and matchesGlobalSearch then
                        ImGui.PushID(slotInfo.id)
                        
                        local currentItemName = currentSelections[targetHash][slotInfo.id] or "Empty/Remove"
                        local currentIdx = 1
                        for i, v in ipairs(pool) do
                            if v == currentItemName then currentIdx = i; break end
                        end
                        -- Se o item atual foi filtrado/removido, reverter para Empty sem forçar Update visual
                        if pool[currentIdx] ~= currentItemName then
                            currentIdx = 1
                            currentItemName = pool[1]
                        end
                        
                        local windowW = ImGui.GetWindowWidth()
                        local cyLine = ImGui.GetCursorPosY()
                        local isLocked = lockedSlots[targetHash][slotInfo.id]
                        local isHidden = hiddenSlots[targetHash][slotInfo.id]
                        
                        -- LEFT ICON
                        ImGui.SetCursorPosX(10)
                        local leftIcon = "\u{f004f}"
                        local lW = ImGui.CalcTextSize(leftIcon)
                        ImGui.InvisibleButton("L_"..slotInfo.id, lW + 10, ImGui.GetTextLineHeight() + 4)
                        local leftHovered = ImGui.IsItemHovered()
                        local leftClicked = ImGui.IsItemClicked()
                        
                        ImGui.SetCursorPosX(15); ImGui.SetCursorPosY(cyLine + 2)
                        if isLocked then
                            ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 0.3, 0.3, 1.0)
                        elseif leftHovered then
                            ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.41, 0.70, 1.0)
                        else
                            ImGui.PushStyleColor(ImGuiCol.Text, 0.53, 0.81, 0.98, 1.0)
                        end
                        ImGui.Text(leftIcon)
                        ImGui.PopStyleColor()
                        
                        if leftClicked and not isLocked then
							PlayModSound("click_menu")
                            currentIdx = currentIdx - 1
                            if currentIdx < 1 then currentIdx = #pool end
                            currentItemName = pool[currentIdx]
                            currentSelections[targetHash][slotInfo.id] = currentItemName
                            if not isHidden then ApplyItemFromPool(target, slotInfo.id, currentItemName) end
                        end

                        -- RIGHT ICON
                        local rightIcon = "\u{f0056}"
                        local rW = ImGui.CalcTextSize(rightIcon)
                        local rightX = windowW - rW - 40
                        
                        ImGui.SetCursorPosX(rightX); ImGui.SetCursorPosY(cyLine)
                        ImGui.InvisibleButton("R_"..slotInfo.id, rW + 10, ImGui.GetTextLineHeight() + 4)
                        local rightHovered = ImGui.IsItemHovered()
                        local rightClicked = ImGui.IsItemClicked()
                        
                        ImGui.SetCursorPosX(rightX + 5); ImGui.SetCursorPosY(cyLine + 2)
                        if isLocked then
                            ImGui.PushStyleColor(ImGuiCol.Text, 0.3, 0.3, 0.3, 1.0)
                        elseif rightHovered then
                            ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.41, 0.70, 1.0)
                        else
                            ImGui.PushStyleColor(ImGuiCol.Text, 0.53, 0.81, 0.98, 1.0)
                        end
                        ImGui.Text(rightIcon)
                        ImGui.PopStyleColor()
                        
                        if rightClicked and not isLocked then
							PlayModSound("click_menu")
                            currentIdx = currentIdx + 1
                            if currentIdx > #pool then currentIdx = 1 end
                            currentItemName = pool[currentIdx]
                            currentSelections[targetHash][slotInfo.id] = currentItemName
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
                        local favIcon    = isFav and "\u{f04ce}" or "\u{f04d2}"

                        -- Lógica de Zoom (Apenas se o slot NÃO estiver bloqueado)
                        local shouldZoom = (leftHovered or rightHovered) and not isLocked
                        if shouldZoom then ImGui.SetWindowFontScale(1.10)
                        else ImGui.SetWindowFontScale(1.0) end

                        local delW    = ImGui.CalcTextSize(delIcon)
                        local searchW = ImGui.CalcTextSize(searchIcon)
                        local lockW   = ImGui.CalcTextSize(lockIcon)
                        local eyeW    = ImGui.CalcTextSize(eyeIcon)
                        local favW    = ImGui.CalcTextSize(favIcon)
                        local slotW   = ImGui.CalcTextSize(slotPart)
                        local itemW   = ImGui.CalcTextSize(itemPart)
                        local spaceW  = ImGui.CalcTextSize(" ")
                        
                        local totalW = slotW + itemW
                        if hasValidItem then
                            totalW = delW + spaceW + slotW + itemW + spaceW + searchW + spaceW + lockW + spaceW + eyeW + spaceW + favW
                        end

                        local startX = (windowW - totalW) * 0.5
                        local yOffset = cyLine + 2
                        if shouldZoom then yOffset = yOffset - 1 end
                        local currentDrawX = startX

                        -- BOTÕES INVISÍVEIS PARA DETEÇÃO DE CLIQUE
                        local delHovered, delClicked = false, false
                        local searchHovered, searchClicked = false, false
                        local lockHovered, lockClicked = false, false
                        local eyeHovered, eyeClicked = false, false
                        local favHovered, favClickedL, favClickedR = false, false, false
                        
                        if hasValidItem then
                            -- Del
                            ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(cyLine)
                            ImGui.InvisibleButton("DEL_"..slotInfo.id, delW, ImGui.GetTextLineHeight())
                            delHovered, delClicked = ImGui.IsItemHovered(), ImGui.IsItemClicked(0)
                            
                            -- Search
                            local cxSearch = currentDrawX + delW + spaceW + slotW + itemW + spaceW
                            ImGui.SetCursorPosX(cxSearch); ImGui.SetCursorPosY(cyLine)
                            ImGui.InvisibleButton("SRC_"..slotInfo.id, searchW, ImGui.GetTextLineHeight())
                            searchHovered, searchClicked = ImGui.IsItemHovered(), ImGui.IsItemClicked(0)
                            
                            -- Lock
                            local cxLock = cxSearch + searchW + spaceW
                            ImGui.SetCursorPosX(cxLock); ImGui.SetCursorPosY(cyLine)
                            ImGui.InvisibleButton("LCK_"..slotInfo.id, lockW, ImGui.GetTextLineHeight())
                            lockHovered, lockClicked = ImGui.IsItemHovered(), ImGui.IsItemClicked(0)
                            
                            -- Eye
                            local cxEye = cxLock + lockW + spaceW
                            ImGui.SetCursorPosX(cxEye); ImGui.SetCursorPosY(cyLine)
                            ImGui.InvisibleButton("EYE_"..slotInfo.id, eyeW, ImGui.GetTextLineHeight())
                            eyeHovered, eyeClicked = ImGui.IsItemHovered(), ImGui.IsItemClicked(0)

                            -- Fav
                            local cxFav = cxEye + eyeW + spaceW
                            ImGui.SetCursorPosX(cxFav); ImGui.SetCursorPosY(cyLine)
                            ImGui.InvisibleButton("FAV_"..slotInfo.id, favW, ImGui.GetTextLineHeight())
                            favHovered, favClickedL, favClickedR = ImGui.IsItemHovered(), ImGui.IsItemClicked(0), ImGui.IsItemClicked(1)
                        end

                        -- TRATAMENTO DE CLIQUES
                        if delClicked then
                            for i, v in ipairs(savedOutfits[slotInfo.name]) do
                                if v == currentItemName then table.remove(savedOutfits[slotInfo.name], i); break end
                            end
                            SaveOutfits()
                            currentSelections[targetHash][slotInfo.id] = "Empty/Remove"
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
                        if favClickedL and hasValidItem then
                            savedOutfits["_FAVORITES_"][currentItemName] = true
                            SaveOutfits(); isFav = true; favIcon = "\u{f04ce}"
                        elseif favClickedR and hasValidItem then
                            savedOutfits["_FAVORITES_"][currentItemName] = nil
                            SaveOutfits(); isFav = false; favIcon = "\u{f04d2}"
                        end

                        -- RENDERIZAÇÃO VISUAL DO TEXTO E ÍCONES
                        -- 1. DELETE
                        if hasValidItem then
                            ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(yOffset)
                            ImGui.PushStyleColor(ImGuiCol.Text, 0.90, 0.20, 0.20, 1.0) 
                            ImGui.Text(delIcon)
                            ImGui.PopStyleColor()
                            if delHovered then ImGui.SetTooltip("Delete record from DB") end
                            currentDrawX = currentDrawX + delW + spaceW
                        end

                        -- 2. NOME DO SLOT
                        ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(yOffset)
                        ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 0.84, 0.0, 1.0)
                        ImGui.Text(slotPart)
                        ImGui.PopStyleColor()
                        currentDrawX = currentDrawX + slotW

                        -- 3. NOME DO ITEM (Ganha cor graylighted se oculto)
                        ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(yOffset)
                        if isHidden then ImGui.PushStyleColor(ImGuiCol.Text, 0.4, 0.4, 0.4, 1.0)
                        elseif hasValidItem then ImGui.PushStyleColor(ImGuiCol.Text, 0.0, 0.85, 1.0, 1.0)
                        else ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0) end
                        
                        ImGui.Text(itemPart)
                        if ImGui.IsItemHovered() and not isLocked then ImGui.SetTooltip("Right-Click to Reset") end
                        if ImGui.IsItemClicked(1) and not isLocked then
                            currentSelections[targetHash][slotInfo.id] = "Empty/Remove"
                            if not isHidden then ApplyItemFromPool(target, slotInfo.id, "Empty/Remove") end
                        end
                        ImGui.PopStyleColor()
                        currentDrawX = currentDrawX + itemW + spaceW

                        -- 4. SEARCH, LOCK, EYE, FAVORITE
                        if hasValidItem then
                            -- Search
                            ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(yOffset)
                            ImGui.PushStyleColor(ImGuiCol.Text, isSearching[targetHash][slotInfo.id] and 1.0 or 0.8, isSearching[targetHash][slotInfo.id] and 0.84 or 0.8, isSearching[targetHash][slotInfo.id] and 0.0 or 0.8, 1.0)
                            ImGui.Text(searchIcon)
                            ImGui.PopStyleColor()
                            if searchHovered then ImGui.SetTooltip("Search Item by Name") end
                            currentDrawX = currentDrawX + searchW + spaceW

                            -- Lock
                            ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(yOffset)
                            ImGui.PushStyleColor(ImGuiCol.Text, isLocked and 1.0 or 1.0, isLocked and 0.65 or 1.0, isLocked and 0.0 or 1.0, 1.0)
                            ImGui.Text(lockIcon)
                            ImGui.PopStyleColor()
                            if lockHovered then ImGui.SetTooltip(isLocked and "Unlock Selection" or "Lock Selection") end
                            currentDrawX = currentDrawX + lockW + spaceW

                            -- Eye
                            ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(yOffset)
                            ImGui.PushStyleColor(ImGuiCol.Text, isHidden and 1.0 or 1.0, isHidden and 0.65 or 1.0, isHidden and 0.0 or 1.0, 1.0)
                            ImGui.Text(eyeIcon)
                            ImGui.PopStyleColor()
                            if eyeHovered then ImGui.SetTooltip(isHidden and "Show Item" or "Hide Item") end
                            currentDrawX = currentDrawX + eyeW + spaceW

                            -- Fav
                            ImGui.SetCursorPosX(currentDrawX); ImGui.SetCursorPosY(yOffset)
                            ImGui.PushStyleColor(ImGuiCol.Text, isFav and 1.0 or 1.0, isFav and 0.84 or 1.0, isFav and 0.0 or 1.0, 1.0)
                            ImGui.Text(favIcon)
                            ImGui.PopStyleColor()
                            if favHovered then ImGui.SetTooltip("Left click: Favorite\nRight click: Unfavorite") end
                        end

                        ImGui.SetWindowFontScale(1.0)
                        
                        -- CAIXA DE PESQUISA (Aparece em baixo da linha se ativada)
                        if isSearching[targetHash][slotInfo.id] then
                            ImGui.SetCursorPosY(cyLine + ImGui.GetTextLineHeight() + 6)
                            ImGui.SetCursorPosX(startX + delW + slotW) -- Alinhado com o nome
                            ImGui.PushItemWidth(200)
                            
                            local oldQuery = searchQueries[targetHash][slotInfo.id] or ""
                            local newQuery = ImGui.InputText("##SearchInput" .. slotInfo.id, oldQuery, 50)
                            
                            -- Se o texto da pesquisa mudou, atualiza logo a roupa em tempo real!
                            if newQuery ~= oldQuery then
                                searchQueries[targetHash][slotInfo.id] = newQuery
                                
                                -- Pede a nova lista de itens já filtrada com o que acabaste de escrever
                                local newPool = GetFilteredPool(slotInfo.name, targetHash, slotInfo.id)
                                
                                -- Se houver itens válidos no filtro, equipa o primeiro automaticamente (Index 2, porque o 1 é o Empty)
                                if #newPool > 1 and newPool[2] ~= "No_Records_In_JSON" and newPool[2] ~= "No_Match" then
                                    currentSelections[targetHash][slotInfo.id] = newPool[2]
                                    if not isHidden and not isLocked then
                                        ApplyItemFromPool(target, slotInfo.id, newPool[2])
                                    end
                                else
                                    -- Se não houver nada que corresponda, limpa o slot
                                    currentSelections[targetHash][slotInfo.id] = "Empty/Remove"
                                    if not isHidden and not isLocked then
                                        ApplyItemFromPool(target, slotInfo.id, "Empty/Remove")
                                    end
                                end
                            end
                            
                            ImGui.PopItemWidth()
                            ImGui.SetCursorPosY(ImGui.GetCursorPosY() + 4)
                        else
                            ImGui.SetCursorPosY(cyLine + ImGui.GetTextLineHeight() + 8)
                        end
                        
                        ImGui.PopID()
                    end
                end
                
                -- =======================================
                -- FIM DA ÁREA DE SCROLL INDEPENDENTE
                -- =======================================
                ImGui.EndChild() -- <--- APENAS UM ENDCHILD AQUI PARA FECHAR O SCROLL!
                
                ImGui.Separator()
                ImGui.Spacing()
                
                -- =======================================
                -- BARRA DE FUNDO (ÁUDIO E ANIMAÇÃO)
                -- =======================================
                local bottomBtnW = 50
                local bottomBtnH = 30
                -- Calcula a largura total para centrar perfeitamente (2 botões + 20px de espaço)
                local totalBottomW = (bottomBtnW * 2) + 20 
                ImGui.SetCursorPosX((ImGui.GetWindowWidth() - totalBottomW) * 0.5)
                
                -- 1. Botão de Áudio
                if isSoundEnabled then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.2, 0.9, 0.2, 1.0) -- Verde (\u{f075a})
                    if ImGui.Button("\u{f075a}##ToggleSound", bottomBtnW, bottomBtnH) then 
                        isSoundEnabled = false 
                    end
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.9, 0.2, 0.2, 1.0) -- Vermelho (\u{f075b})
                    if ImGui.Button("\u{f075b}##ToggleSound", bottomBtnW, bottomBtnH) then 
                        isSoundEnabled = true 
                    end
                end
                ImGui.PopStyleColor()

                -- TOOLTIP DO SOM (Adicionado aqui)
                if ImGui.IsItemHovered() then
                    ImGui.SetTooltip("Enable/Disable UI sound")
                end
                
                -- CORREÇÃO DO ESPAÇAMENTO (Feita no passo anterior)
                ImGui.SameLine()
                ImGui.SetCursorPosX(ImGui.GetCursorPosX() + 20)
                
                -- 2. Botão de Animação
                if isAnimPlaying then
                    ImGui.PushStyleColor(ImGuiCol.Text, 0.2, 0.9, 0.2, 1.0) -- Verde (\u{f15c9})
                else
                    ImGui.PushStyleColor(ImGuiCol.Text, 1.0, 1.0, 1.0, 1.0) -- Branco (\u{f15c9})
                end
                if ImGui.Button("\u{f15c9}##ToggleAnim", bottomBtnW, bottomBtnH) then 
                    isAnimPlaying = not isAnimPlaying
                    if isAnimPlaying then
                        animTimer = 0 -- Ao ativar, dispara a 1ª animação imediatamente
                    else
                        -- Se desativar, limpa os status effects do NPC
                        if target then Game.GetStatusEffectSystem():RemoveAllStatusEffects(target:GetEntityID()) end
                    end
                end
                ImGui.PopStyleColor()

                -- TOOLTIP DA DANÇA (Adicionado aqui)
                if ImGui.IsItemHovered() then
                    ImGui.SetTooltip("Still not working... Soon...")
                end
                
            end -- FECHA O 'else' DO TARGET
        end -- FECHA O 'if ImGui.Begin'
        ImGui.End() -- <--- FECHA FINALMENTE A JANELA PRINCIPAL "Customize your NPC Slots"
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
    ImGui.PopStyleColor(7) 
end)

-- ============================================================================
-- Hotkey Registration
-- ============================================================================
registerHotkey("NPCOutfitManagerToggle", "Toggle NPC Outfit Manager Menu", function()
    isMainWindowOpen = not isMainWindowOpen
end)

registerForEvent("onUpdate", function(delta)
    if autoRetryNakedTarget then
        ForceNakedState(autoRetryNakedTarget)
    end
    
    -- Lógica Temporizada de Animações (30 segundos)
    if isAnimPlaying then
        animTimer = animTimer - delta
        if animTimer <= 0 then
            local currentTarget = GetLookAtNPC()
            if currentTarget then
                PlayRandomNPCAnimation(currentTarget)
            end
            animTimer = 30.0 -- Reinicia o relógio para os próximos 30s
        end
    end
end)