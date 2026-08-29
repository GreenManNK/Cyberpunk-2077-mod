NCA = {
    name = "Night City Allies",
    author = "Dray",
    version = "1.5.4",
    ready = false,
}

debug = require("Application/Lib/debug.lua")
local Application = require('Application/app.lua')
local CharacterLoader = require('Application/IO/characterLoader.lua')
local ModuleLoader = require('Application/IO/moduleLoader.lua')

local characterLoader = CharacterLoader:new();
local moduleLoader = ModuleLoader:new();
local app = Application:new(characterLoader, moduleLoader)

registerForEvent("onInit", function()
    Observe("NightCityAllies.Settings.NCASettings", "ApplySettings", function(self, redscriptSettings)
        app:LoadModules()
    end)
    
    Observe('PlayerPuppet', 'OnGameAttached', function()
        app:OnSessionStart()
    end)
        
    Observe("NightCityAllies.Event.EventBus", "OnQuestComplete", function(self)
        NCA:ExecuteCallbacks("QuestComplete")
    end)

    Observe("NightCityAllies.Event.EventBus", "OnEnterVehicle", function(self)
        NCA:ExecuteCallbacks("EnterVehicle")
    end)

    Observe('NightCityAllies.Event.EventBus', 'OnContextChange', function(self, context)
        NCA:ExecuteCallbacks("ContextChange", context)
    end)
    
    Observe("NightCityAllies.Event.EventBus", "OnConversationFinished", function(self, id)
        NCA:ExecuteCallbacks("ConversationFinished", id)
    end)

    Observe("NightCityAllies.Event.EventBus", "OnCompanionJoinSquad", function(self, npc)
        NCA:ExecuteCallbacks("CompanionJoinSquad", npc)
    end)

    Observe("NightCityAllies.Event.EventBus", "OnSessionStart", function(self)
        NCA:ExecuteCallbacks("SessionStart")
    end)

    -- Lua effect cb --
    Observe('NightCityAllies.Effect.NCAEffectSystem', 'OnLuaCallback', function(self, id, subject, param)
        local effect = NCA.effectCallbacks[id + 1]
        effect(subject, param)
    end)

    Observe("NightCityAllies.Event.EventBus", "OnBuildInteractionMenu", function(self, npc, token)
        NCA.luaInteractionRows = NCA.app:CollectInteractions(npc)

        local defaultIcon = TweakDBInterface.GetChoiceCaptionIconPartRecord("ChoiceCaptionParts.None")

        for i, entry in ipairs(NCA.luaInteractionRows) do
            local icon = entry.icon or defaultIcon

            NCA:InteractionMenu():AddLuaEntry(
                token,
                i - 1,
                tostring(entry.label or ""),
                icon:GetID(),
                entry.type or gameinteractionsChoiceType.QuestImportant
            )
        end
    end)

    Observe("NightCityAllies.Event.EventBus", "OnLuaInteractionSelected", function(self, npc, id)
        local entry = NCA.luaInteractionRows[id + 1]
        if entry and entry.callback then
            entry.callback(npc)
        end
    end)
    
    -- Debug --
    Observe("NightCityAllies.Phone.NCAPhoneSystem", "CETLog", function(self, message)
        print("[NCA] " .. tostring(message))
    end)

    --Observe('NightCityAllies.Persistence.PersistenceSystem', 'PushCompanionData', function(self, data)
    --    debug.print(data)
    --end)

    Observe('NightCityAllies.Persistence.PersistenceSystem', 'CETDump', function(self, data)
        debug.print(data)
    end)
    
    Observe('NightCityAllies.Loader.TweakDBScanner', 'DumpMetadata', function(self, data)
        --print('NCA:ForceSpawnCharacter("' .. data.recordID.value .. '")');
        file = io.open("./Modules/nca_test.lua", "a")
        io.output(file)
        io.write('NCA:RegisterCharacter({name = "' .. (GetLocalizedTextByKey(data.name) or NameToString(data.name)) .. '", record = "' .. data.recordID.value ..'", type="generic"})\n')
        io.close(file)
        debug.print(data)
    end)

    print("----------------------------------------------------------------------------")
    print(NCA.name .. " " .. NCA.version)
    print("For more info run:        NCA = GetMod(\"NightCityAllies\"); NCA:Help()")
    print("----------------------------------------------------------------------------")

    --Observe("ScriptedPuppet", "OnRequestComponents", function(this)
    --    if this:IsNPC() and not this:IsPlayer() then
    --        local position = this:GetWorldPosition()
    --        print(string.format("Active Node Found -> X: %f, Y: %f, Z: %f", position.x, position.y, position.z))
    --    end
    --end)
end)

-- ======================================================== API ========================================================
function NCA:new(app)
    NCA.app = app
    NCA.effectCallbacks = {}
    NCA.luaInteractionRows = {}
    NCA.eventCallbacks = {
        QuestComplete = {},
        EnterVehicle = {},
        ContextChange = {},
        ConversationFinished = {},
        CompanionJoinSquad = {},
        SessionStart = {}
    }
    NCA.eventOnceCallbacks = {
        QuestComplete = {},
        EnterVehicle = {},
        ContextChange = {},
        ConversationFinished = {},
        CompanionJoinSquad = {},
        SessionStart = {}
    }
    return NCA
end

function NCA:On(eventName, cb)
    table.insert(self.eventCallbacks[eventName], cb)
end

function NCA:OnceOn(eventName, cb)
    table.insert(self.eventOnceCallbacks[eventName], cb)
end

function NCA:ExecuteCallbacks(eventName, param)
    local callbacks = self.eventCallbacks[eventName]
    for i = #callbacks, 1, -1 do
        local cb = callbacks[i]
        if cb(param) == true then
            table.remove(callbacks, i)
        end
    end
    
    local onceCallbacks = self.eventOnceCallbacks[eventName]
    self.eventOnceCallbacks[eventName] = {}
    for _, cb in pairs(onceCallbacks) do
        cb(param)
    end
end

function NCA:Settings()
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.Settings.NCASettings")
end

function NCA:UI()
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.UI.UISystem")
end

function NCA:Context()
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.Persistence.ContextSystem")
end

function NCA:Persistence()
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.Persistence.PersistenceSystem")
end

function NCA:Events()
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.Events.EventBus")
end

function NCA:Phone()
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.Phone.NCAPhoneSystem")
end

function NCA:NPC()
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.Npc.NpcManager")
end

function NCA:Labels()
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.Localization.NCALabels")
end

function NCA:Spawn()
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.Spawn.SpawnSystem")
end

function NCA:Damage()
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.Npc.DamageTrackerSystem")
end

function NCA:Effect()
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.Effect.NCAEffectSystem")
end

function NCA:Util()
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.Util.NCAUtil")
end

function NCA:Location()
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.Location.LocationSystem")
end

function NCA:Animation()
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.Animation.NCAAnimationSystem")
end

function NCA:InteractionMenu()
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.UI.NCAInteractionMenu")
end

function NCA:Timer()
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.Timer.NCATimerSystem")
end

function NCA:T(text)
    return Game.GetScriptableSystemsContainer():Get("NightCityAllies.Localization.NCALabels"):TranslateFromString(text)
end

-- =====================================================================================================================
function NCA:RegisterCharacter(data)
    if data.record == nil then
        print("ERROR: Character is missing field 'record'")
        return
    end

    local isLocked = (data.unlock ~= nil) or (data.locked == true)
    local autoRarity = "common"
    local autoType = "undefined"
    
    if isLocked then
        autoRarity = "special"
        autoType = "regular"
    end

    self:Persistence():RegisterCharacterFromString(
        data.record,
        data.name or "",
        isLocked,
        data.appearance or -1,
        data.rarity or autoRarity,
        data.type or autoType
    )

    if data.unlock ~= nil or data.lock ~= nil then
        NCA:On("QuestComplete", function()
            if data.lock ~= nil and self:CheckQuest(data.lock) then
                NCA:LockCharacter(data.record)
            elseif data.unlock ~= nil and self:CheckQuest(data.unlock) then
                if (data.unlockConversation ~= nil) then
                    NCA:UnlockConversation(data.unlockConversation)
                    NCA:SetConversationImportant(data.unlockConversation)
                end
            end
        end)
    elseif (data.unlockConversation ~= nil) then
        NCA:OnceOn("QuestComplete", function()      -- fallback in case someone specifies the convo with no locks.
            NCA:UnlockConversation(data.unlockConversation)         -- cant trigger here directly because the convo might not be created yet so on quest complete   
            NCA:SetConversationImportant(data.unlockConversation)   -- quest complete is executed on every game launch in case new chars are installed
        end)
    end
    
    if (data.unlockConversation ~= nil) then
        NCA:On("ConversationFinished", function(id)
            if NameToString(id) == data.unlockConversation then
                --print("Conversation finished: " .. NameToString(id) .. " vs " .. data.unlockConversation)
                NCA:UnlockCharacter(data.record)
                return true -- resolve
            end
        end)
    end

    --print(data.name .. " " .. tostring(isLocked) .. " " .. tostring(data.mercenary) .. " " .. tostring(not data.mercenary == true) .. " -> " .. tostring((not isLocked) and (not data.mercenary == true)))
    if (not isLocked) and (not data.type == "mercenary") then
        --print("insta unlocking " .. data.name)
        NCA:UnlockCharacter(data.record)
    end
    
    if data.outfits ~= nil then
        for outfitName, appearance in pairs(data.outfits) do
            self:Persistence():RegisterCompanionOutfitString(data.record, outfitName, appearance)
        end
    end
end

function NCA:StartTimer(name, data)
    if data.hours == nil and data.minutes == nil and data.seconds == nil then
        print("ERROR: Timer is missing duration fields (hours, minutes, seconds)")
        return
    end
    
    if data.effect == nil then
        print("ERROR: Timer is missing field 'effect'")
        return
    end

    self:Timer():StartTimerString(
        name,
        data.d or data.days or 0,
        data.h or data.hours or 0,
        data.m or data.minutes or 0,
        data.effect,
        data.subject or ""
    )
end

function NCA:StopTimer(name)
    self:Timer():StopTimerString(name)
end

function NCA:RegisterEffect(name, cb)
    self:Effect():RegisterLuaEffect(name)
    table.insert(self.effectCallbacks, cb)
end

function NCA:RegisterConversation(id, character, luaNodes)
    local cb = NCA:Phone():CreateConversation(id, character);
    for _,luaNode in ipairs(luaNodes) do
        cb:AddNode(luaNode.id)

        for _,luaTextLine in ipairs(luaNode.textLines or {}) do
            cb:AddLine(luaTextLine)
        end

        for _,luaResponseNode in ipairs(luaNode.responses or {}) do
            cb:AddOption(luaResponseNode.text, luaResponseNode.next, luaResponseNode.effect or "")
        end
    end
end

function NCA:SetConversationTrigger(id, data)
    self:Phone():CreateConversationTrigger(id, data.probability or 1, data.friendship or 0, data.love or 0, data.repeatable or false, data.allowLocked or false)
end

function NCA:LockCharacter(character)
    self:Persistence():LockCharacter(character)
end

function NCA:UnlockCharacter(character)
    self:Persistence():UnlockCharacter(character)
end

function NCA:MakeHireable(character)
    self:Persistence():SetUnacquired(character)
end

function NCA:LockConversation(id)
    self:Persistence():LockConversation(id)
end

function NCA:UnlockConversation(id, instant)
    if instant == true then
        -- 1.3.4 : Old behavior; instantly unlock convo and play SMS notification
        self:Persistence():UnlockConversation(id)
        self:Phone():TriggerNotification(id)
    else
        -- 1.3.4 : Allows conversation to be shown (even for locked chars)
        self:Phone():CreateConversationTrigger(id, 1, 0, 0, false, true)
    end
end

function NCA:SetConversationImportant(id)
    self:Phone():SetConversationImportant(id, true)
end

function NCA:CheckQuest(questString)
    return self:Util():IsQuestDone(questString)
end

-- ======================================================================================================================================================================================================

function NCA:RegisterLocation(name)
    local tag = CName.new(name)
    self:Location():RegisterLocation(tag)
end

function NCA:RegisterSpawn(locationName, data)
    if data.name == nil then
        print("ERROR: Spawn is missing field 'name'")
        return
    end

    if data.pos == nil or data.rot == nil then
        print("ERROR: Spawn is missing 'pos' or 'rot'")
        return
    end

    self:Location():RegisterSpawnString(
        locationName,
        data.name,
        Vector4.new(data.pos[1], data.pos[2], data.pos[3], 1.0),
        Quaternion.new(data.rot[1], data.rot[2], data.rot[3], data.rot[4])
    )
end

function NCA:RegisterRoamingSpawn(locationName, data)
    if data.name == nil then
        print("ERROR: Roaming Spawn is missing field 'name'")
        return
    end

    self:Location():RegisterRoamingSpawnString(
        locationName,
        data.name
    )
end

function NCA:RegisterRoutine(type, data)
    if data.tag == nil then
        print("ERROR: Routine is missing field 'tag'")
        return
    end

    if data.rig == nil then
        print("ERROR: Routine '" .. data.tag .. "' is missing field 'rig'")
        return
    end

    self:Animation():RegisterRoutineString(
        type,
        data.tag,
        data.rig,
        data.partnerRig or "",
        data.label or "",
        data.icon or "",
        data.freeCamera == true,
        data.blockReactions == true
    )

    -- "linear", "linear_randomized" or "infinite_randomized". todo check how many of the seperate calls are really needed
    self:Animation():RegisterRoutinePlaybackString(
        type,
        data.tag,
        data.playback or ""
    )

    self:Animation():RegisterRoutineOffsetString(
        type,
        data.tag,
        data.offsetForward or 0.0,
        data.offsetRight or 0.0,
        data.offsetUp or 0.0,
        data.offsetYaw or 0.0,
        data.partnerOffsetForward or 0.0,
        data.partnerOffsetRight or 0.0,
        data.partnerOffsetUp or 0.0,
        data.partnerOffsetYaw or 0.0
    )

    self:Animation():RegisterRoutineWorkspotString(
        type,
        data.tag,
        data.workspot or "",
        data.actorComp or "",
        data.deviceComp or "",
        data.syncSlot or "",
        data.partnerWorkspot or "",
        data.partnerActorComp or "",
        data.partnerDeviceComp or "",
        data.partnerSyncSlot or ""
    )

    for _, animation in ipairs(data.animations or {}) do
        if animation.animation == nil then
            print("ERROR: Routine '" .. data.tag .. "' has an animation missing field 'animation'")
        else
            self:Animation():RegisterRoutineAnimationString(
                type,
                data.tag,
                animation.animation,
                animation.duration or 0.0,
                animation.partnerAnimation or "",
                animation.group or "",
                animation.nextGroup or ""
            )
        end
    end

    -- effects = { entry = { { "change_outfit", "bed" } }, exit = { { "friendship+" } } }
    for _, effect in ipairs((data.effects or {}).entry or {}) do
        self:Animation():RegisterRoutineEffectString(type, data.tag, false, effect[1], effect[2] or "")
    end

    for _, effect in ipairs((data.effects or {}).exit or {}) do
        self:Animation():RegisterRoutineEffectString(type, data.tag, true, effect[1], effect[2] or "")
    end
end

--public func RegisterProp(locationTag: CName, tag: CName, pos: Vector4, rot: Quaternion, opt slots: array<NCAInteractionSlot>, opt interactions: array<NCAInteraction>)
function NCA:RegisterProp(locationName, data)
    if data.name == nil then
        print("ERROR: Prop is missing field 'name'")
        return
    end

    if data.pos == nil or data.rot == nil then
        print("ERROR: Prop is missing 'pos' or 'rot'")
        return
    end
    
    self:Location():RegisterPropString(
        locationName,
        data.name,
        Vector4.new(data.pos[1], data.pos[2], data.pos[3], 1.0),
        Quaternion.new(data.rot[1], data.rot[2], data.rot[3], data.rot[4])
    )
    
    if data.area ~= nil then
        self:Location():SetPropAreaString(locationName, data.name, data.area)
    end

    for _, slotName in pairs(data.slots or {}) do
        self:Location():RegisterPropSlotString(locationName, data.name, slotName)
    end

    for _, interaction in pairs(data.interactions or {}) do
        if interaction.type == nil then
            print("ERROR: Prop interaction is missing field 'type'")
            return
        end
        
        local finalPos = nil
        if interaction.offset ~= nil then
            local rot = Quaternion.new(interaction.rot[1], interaction.rot[2], interaction.rot[3], interaction.rot[4])
            
            if interaction.pos == nil then
                interaction.pos = data.pos
            end

            -- Extraktion der lokalen Achsen aus dem Quaternion
            -- 'right' (X-Achse), 'forward' (Y-Achse), 'up' (Z-Achse)
            local right = Vector4.new(
                1 - 2 * (rot.j * rot.j + rot.k * rot.k),
                2 * (rot.i * rot.j + rot.k * rot.r),
                2 * (rot.i * rot.k - rot.j * rot.r),
                0
            )

            local forward = Vector4.new(
                2 * (rot.i * rot.j - rot.k * rot.r),
                1 - 2 * (rot.i * rot.i + rot.k * rot.k),
                2 * (rot.j * rot.k + rot.i * rot.r),
                0
            )

            local up = Vector4.new(
                2 * (rot.i * rot.k + rot.j * rot.r),
                2 * (rot.j * rot.k - rot.i * rot.r),
                1 - 2 * (rot.i * rot.i + rot.j * rot.j),
                0
            )

            finalPos = Vector4.new(
                    interaction.pos[1] + (interaction.offset.x or 0) * right.x + (interaction.offset.y or 0) * forward.x + (interaction.offset.z or 0) * up.x,
                    interaction.pos[2] + (interaction.offset.x or 0) * right.y + (interaction.offset.y or 0) * forward.y + (interaction.offset.z or 0) * up.y,
                    interaction.pos[3] + (interaction.offset.x or 0) * right.z + (interaction.offset.y or 0) * forward.z + (interaction.offset.z or 0) * up.z,
                1.0
            )
        end

        self:Location():RegisterPropInteractionString(
            locationName,
            data.name,
            interaction.type or "none",
            interaction.slots or {},
            finalPos or Vector4.new(interaction.pos[1], interaction.pos[2], interaction.pos[3], 1.0),
            Quaternion.new(interaction.rot[1], interaction.rot[2], interaction.rot[3], interaction.rot[4])
        )
    end
end

function NCA:RegisterPath(locationName, data)
    if data.from == nil or data.to == nil then
        print("ERROR: Path is missing field 'from' or 'to'")
        return
    end

    if data.nodes == nil or #data.nodes < 1 then
        print("ERROR: Path " .. tostring(data.from) .. " -> " .. tostring(data.to) .. " has no nodes")
        return
    end

    local nodes = {}
    for _, node in ipairs(data.nodes) do
        table.insert(nodes, Vector4.new(node[1], node[2], node[3], 1.0))
    end

    self:Location():RegisterPathString(locationName, data.from, data.to, nodes)
end
-- =====================================================================================================================



function NCA:Cheat(cheat)
    if cheat == "UNLOCKALL" then
        NCA:Persistence():UnlockAll()
        print("Unlocked all characters!")
    elseif string.find(cheat, "UNLOCK ") then
        local charName = string.match(cheat, "UNLOCK%s+(.+)")
        if charName then
            if NCA:Persistence():UnlockCharacter(charName) then
                print("Unlocked character: " .. charName)
            else
                print("Couldn't find character: " .. charName)
            end
        end
    end
end

function NCA:ForceSpawnCharacter(record)
    NCA:NPC():SpawnFromRecordString(record)
end

function NCA:Help()
    local f = io.open("./help.txt", 'r')
    local contents = f:read('*a')
    f:close()

    -- Remove BOM if present
    if string.sub(contents, 1, 1) == '\239' then
        contents = string.sub(contents, 4)
    end
    print(
        '==================================================\n' ..
        NCA.name .. ' version ' .. NCA.version .. '\n' ..
        contents .. '\n' ..
        '=================================================='
    )
end

function NCA:Reset()
    Game.GetScriptableSystemsContainer():Get("NightCityAllies.Persistence.PersistenceSystem"):Reset()
end

function NCA:Dump(var)
    debug.print(var)
end

function NCA:PrintLookAtChar()
    local target = Game.GetTargetingSystem():GetLookAtObject(Game.GetPlayer(), true, false);
    if target ~= nil and target:IsNPC() then
        print(target:GetTDBID().value)
        return target:GetTDBID().value
    else
        print("not found aim harder")
        return nil
    end
end

return NCA:new(app)