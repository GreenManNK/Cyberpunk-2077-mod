--Author: yakuzadeso

--------------------------------------------------------------------------------
--Settings

MultiTargetRange = 75.00
ShowOnScreenEffects = true
instantCastingSingle = false
instantCastingMulti = false
useAnimations = true
drainMemorySingle = false
memoryToDrainSingle = 1.0
drainMemoryMulti = false
memoryToDrainMulti = 1.0

------------------------------------------------------------------------------

Cron = require("Cron.lua")
local Ref = require("Ref")
local myCapturedNpcs = {}
local isPreGameState = true

did = 0
forcedCarryingWounded = false
vfxTriggered = false


function SaveSettings()
    local settings = {
        ShowOnScreenEffects = ShowOnScreenEffects,
        MultiTargetRange = MultiTargetRange,
        instantCastingSingle = instantCastingSingle,
        useAnimations = useAnimations,
        instantCastingMulti = instantCastingMulti,
        drainMemorySingle = drainMemorySingle,
        memoryToDrainSingle = memoryToDrainSingle,
        drainMemoryMulti = drainMemoryMulti,
        memoryToDrainMulti = memoryToDrainMulti,
    }
    local jsonString = json.encode(settings)

    local file = io.open("settings.json", "w")

    if file then
        file:write(jsonString)
        file:close()
    end
end

function LoadSettings()
    local file = io.open("settings.json", "r")

    if file then
        local jsonString = file:read("*a")
        file:close()

        local settings = json.decode(jsonString)
        if settings then
            ShowOnScreenEffects = settings.ShowOnScreenEffects
            MultiTargetRange = settings.MultiTargetRange
            instantCastingSingle = settings.instantCastingSingle
            useAnimations = settings.useAnimations
            instantCastingMulti = settings.instantCastingMulti
            drainMemorySingle = settings.drainMemorySingle
            memoryToDrainSingle = settings.memoryToDrainSingle
            drainMemoryMulti = settings.drainMemoryMulti
            memoryToDrainMulti = settings.memoryToDrainMulti
            drainHealthSingle = settings.drainHealthSingle
            healthToDrainSingle = settings.healthToDrainSingle
            drainHealthMulti = settings.drainHealthMulti
            healthToDrainMulti = settings.healthToDrainMulti
        end
    end
end

LoadSettings()

function AddActions()
    for _, character in pairs(TweakDB:GetRecords("gamedataCharacter_Record")) do
        local objectActionsRecord = character:GetID() .. ".objectActions"
        if objectActionsRecord ~= nil then
            newArray = TweakDB:GetFlat(objectActionsRecord)

            local containsBaseBlackWallHack = false
            for _, entry in ipairs(newArray) do
                if entry.value == "QuickHack.BaseBlackWallHack" then
                    containsBaseBlackWallHack = true
                    break
                end
            end

            local containsActualBlackWallHack = false
            for _, entry in ipairs(newArray) do
                if entry.value == "QuickHack.BlackWallHack_modified_Single" or entry.value == "QuickHack.BlackWallHack_modified_Multi" then
                    containsActualBlackWallHack = true
                    break
                end
            end

            if containsBaseBlackWallHack and not containsActualBlackWallHack then
                table.insert(newArray, "QuickHack.BlackWallHack_modified_Single")
                table.insert(newArray, "QuickHack.BlackWallHack_modified_Multi")
                TweakDB:SetFlat(objectActionsRecord, newArray)
            end
        end
    end
end

function processCapturedNpcs()
    for i = #myCapturedNpcs, 1, -1 do
        local npc = myCapturedNpcs[i]
        if not IsDefined(npc) then
            table.remove(myCapturedNpcs, i)
        else
            if StatusEffectSystem.ObjectHasStatusEffect(npc, "BaseStatusEffect.SoMi_Q306_BlackwallHackQuestForceKill") then
                StatusEffectHelper.RemoveStatusEffect(npc, "BaseStatusEffect.SoMi_Q306_BlackwallHackQuestForceKill")
                StatusEffectHelper.RemoveStatusEffect(npc, "BaseStatusEffect.BaseBlackWallHackEffect_Trigger_Single")
                StatusEffectHelper.RemoveStatusEffect(npc, "BaseStatusEffect.BaseBlackWallHackEffect_Trigger_Multi")
            end
        end
    end
end

function DoAnims()
    local player = Game.GetPlayer()
    if StatusEffectSystem.ObjectHasStatusEffect(player, "GameplayRestriction.BodyCarryingWoundedSoldier") then
        isCarryingWounded = true
    end
    if not isCarryingWounded then
        Game.SetAnimWrapperWeight(Game.GetPlayer(), 'carry_woundedSoldier', 1.0)
        forcedCarryingWounded = true
    end
    handAnim = player:GetBlackboard():GetInt(GetAllBlackboardDefs().BlackwallDeathAnim.handGestureAnimNumber)
    if handAnim < 0 or handAnim == 5 then
        handAnim = 0
    end
    adHocAnimEvent = AdHocAnimationEvent.new()
    adHocAnimEvent.animationIndex = handAnim
    adHocAnimEvent.useBothHands = true
    adHocAnimEvent.unequipWeapon = true
    player:QueueEvent(adHocAnimEvent)
    player:GetBlackboard():SetInt(GetAllBlackboardDefs().BlackwallDeathAnim.handGestureAnimNumber, handAnim + 1)
    Cron.After(1, { tick = 1 }, function()
        if forcedCarryingWounded then
            Game.SetAnimWrapperWeight(Game.GetPlayer(), 'carry_woundedSoldier', 0.0)
            forcedCarryingWounded = false
        end
    end)
end

registerForEvent("onInit", function()
    if drainMemorySingle then
        TweakDB:SetFlat("QuickHack.BlackWallHack_modified_Single.costs",
            { "QuickHack.BaseBlackWallHack_inline7_modified_Single" })
        TweakDB:SetFlat("QuickHack.BaseBlackWallHack_inline8_modified_Single.value", memoryToDrainSingle)
    else
        TweakDB:SetFlat("QuickHack.BlackWallHack_modified_Single.costs", {})
    end

    if drainMemoryMulti then
        TweakDB:SetFlat("QuickHack.BlackWallHack_modified_Multi.costs",
            { "QuickHack.BaseBlackWallHack_inline7_modified_Multi" })
        TweakDB:SetFlat("QuickHack.BaseBlackWallHack_inline8_modified_Multi.value", memoryToDrainMulti)
    else
        TweakDB:SetFlat("QuickHack.BlackWallHack_modified_Multi.costs", {})
    end

    AddActions()

    isPreGameState = Game.GetSystemRequestsHandler():IsPreGame()

    ObserveAfter('PlayerPuppet', 'OnGameAttached', function(this)
        if not this:IsA('PlayerPuppet') then return end
        if this:IsReplacer() then return end
        isPreGameState = Game.GetSystemRequestsHandler():IsPreGame()
        myCapturedNpcs = {} -- clear the table on a new game load
        collectgarbage()    -- and take the opportunity for a cleanup
    end)

    ObserveAfter('NPCPuppet', 'OnGameAttached', function(this)
        if isPreGameState then return end
        if not this:IsA('NPCPuppet') then return end
        if this:IsDrone() then return end
        table.insert(myCapturedNpcs, Ref.Weak(this))
    end)

    Observe("NPCPuppet", "OnQuickHackEffectApplied", function(puppet, event)
        local recordID = TDBID.ToStringDEBUG(event.staticData:GetRecordID())
        if recordID == "BaseStatusEffect.BaseBlackWallHackEffect_Trigger_Single" then
            local player = Game.GetPlayer()
            local target = puppet

            if GameObject.GetActiveWeapon(player) ~= nil then
                wasUnarmed = false
            else
                wasUnarmed = true
            end

            if instantCastingSingle then
                if useAnimations then
                    DoAnims()
                end

                if ShowOnScreenEffects then
                    GameObjectEffectHelper.StartEffectEvent(player, "blackwall_use_force")
                end
                StatusEffectHelper.ApplyStatusEffect(target, "BaseStatusEffect.SoMi_Q306_BlackwallHackUpload")
            else
                if useAnimations then
                    DoAnims()
                end

                Cron.After(1, { tick = 1 }, function()
                    if ShowOnScreenEffects then
                        GameObjectEffectHelper.StartEffectEvent(player, "blackwall_use_force")
                    end
                    StatusEffectHelper.ApplyStatusEffect(target, "BaseStatusEffect.SoMi_Q306_BlackwallHackUpload")
                end)
            end

            Cron.After(2, { tick = 1 }, function()
                if not wasUnarmed then
                    equipmentManipulationRequest = EquipmentSystemWeaponManipulationRequest.new()
                    eqSystem = Game.GetScriptableSystemsContainer():Get('EquipmentSystem')
                    equipmentManipulationRequest.requestType = EquipmentManipulationAction.RequestLastUsedWeapon
                    equipmentManipulationRequest.owner = player
                    eqSystem:QueueRequest(equipmentManipulationRequest)
                end
            end)

            Cron.After(5, { tick = 1 }, function()
                processCapturedNpcs()
            end)
        else
            if recordID == "BaseStatusEffect.BaseBlackWallHackEffect_Trigger_Multi" then
                local player = Game.GetPlayer()

                if GameObject.GetActiveWeapon(player) ~= nil then
                    wasUnarmed = false
                else
                    wasUnarmed = true
                end

                targetingSystem = Game.GetTargetingSystem()
                parts = {}
                searchQuery = TSQ_EnemyNPC()
                searchQuery.maxDistance = MultiTargetRange
                searchQuery.searchFilter = TSF_And(TSF_Not("Att_Friendly"), TSF_Any("Sp_Aggressive"), TSF_Any("St_Alive"))
                success, parts = targetingSystem:GetTargetParts(player, searchQuery)

                if parts ~= nil then
                    if instantCastingMulti then
                        for _, enemies in ipairs(parts) do
                            local targets = enemies:GetComponent():GetEntity()

                            if Game.GetGodModeSystem():HasGodMode(targets:GetEntityID(), gameGodModeType.Invulnerable) then
                                -- targets:Kill(player, false, false)
                                -- do nothing
                            else
                                if did == 0 then
                                    if useAnimations then
                                        DoAnims()
                                    end
                                end
                                if ShowOnScreenEffects then
                                    GameObjectEffectHelper.StartEffectEvent(player, "blackwall_use_force")
                                end
                                StatusEffectHelper.ApplyStatusEffect(targets,
                                    "BaseStatusEffect.SoMi_Q306_BlackwallHackUpload")
                            end
                            did = did + 1
                        end
                    else
                        for _, enemies in ipairs(parts) do
                            local targets = enemies:GetComponent():GetEntity()
                            if Game.GetGodModeSystem():HasGodMode(targets:GetEntityID(), gameGodModeType.Invulnerable) then
                                -- targets:Kill(player, false, false)
                                -- do nothing
                            else
                                if did == 0 then
                                    if useAnimations then
                                        DoAnims()
                                    end
                                end
                                Cron.After(1, { tick = 1 }, function()
                                    StatusEffectHelper.ApplyStatusEffect(targets,
                                        "BaseStatusEffect.SoMi_Q306_BlackwallHackUpload", 0.0)
                                    if ShowOnScreenEffects and not vfxTriggered then
                                        GameObjectEffectHelper.StartEffectEvent(player, "blackwall_use_force")
                                    end
                                    vfxTriggered = true
                                end)
                                did = did + 1
                            end
                        end
                    end

                    vfxTriggered = false
                    did = 0

                    Cron.After(2, { tick = 1 }, function()
                        if not wasUnarmed then
                            equipmentManipulationRequest = EquipmentSystemWeaponManipulationRequest.new()
                            eqSystem = Game.GetScriptableSystemsContainer():Get('EquipmentSystem')
                            equipmentManipulationRequest.requestType = EquipmentManipulationAction.RequestLastUsedWeapon
                            equipmentManipulationRequest.owner = player
                            eqSystem:QueueRequest(equipmentManipulationRequest)
                        end
                    end)

                    Cron.After(5, { tick = 1 }, function()
                        processCapturedNpcs()
                    end)
                end
            end
        end
    end)
end)

registerForEvent("onUpdate", function(dt)
    Cron.Update(dt)
end)

registerInput('BlackwallSoundBugFix', 'BlackwallSoundBugFix', function(isKeyDown)
    if not isKeyDown then
        return
    end
    processCapturedNpcs()
end)

registerForEvent("onOverlayOpen", function()
    isOverlayOpen = true
end)

registerForEvent("onOverlayClose", function()
    isOverlayOpen = false
end)

registerForEvent("onDraw", function()
    if isOverlayOpen then
        ImGui.SetNextWindowPos(100, 100, ImGuiCond.FirstUseEver)
        ImGui.SetNextWindowSize(550, 550, ImGuiCond.FirstUseEver)
        ImGui.Begin("Actual Blackwall Quickhacks")

        width = ImGui.GetWindowContentRegionWidth()

        ImGui.Text("Settings")
        ImGui.Spacing()
        ImGui.Separator()
        ImGui.Spacing()

        ShowOnScreenEffects, toggled = ImGui.Checkbox("Show On Screen Effects", ShowOnScreenEffects)
        if toggled then
            SaveSettings()
        end

        useAnimations, toggled = ImGui.Checkbox("Use Animations", useAnimations)
        if toggled then
            SaveSettings()
        end

        if ImGui.IsItemHovered()
        then
            ImGui.BeginTooltip()
            ImGui.SetTooltip("Whether to use the hand animations or not.")
            ImGui.EndTooltip()
        end

        instantCastingSingle, toggled = ImGui.Checkbox("Instant casting (Single Target)", instantCastingSingle)
        if toggled then
            SaveSettings()
        end

        if ImGui.IsItemHovered()
        then
            ImGui.BeginTooltip()
            ImGui.SetTooltip("Whether to cast the ability on key pressed or " .. "charge it up along with the animation.")
            ImGui.EndTooltip()
        end

        instantCastingMulti, toggled = ImGui.Checkbox("Instant casting (Multi Target)", instantCastingMulti)
        if toggled then
            SaveSettings()
        end

        if ImGui.IsItemHovered()
        then
            ImGui.BeginTooltip()
            ImGui.SetTooltip("Whether to cast the ability on key pressed or " .. "charge it up along with the animation.")
            ImGui.EndTooltip()
        end

        drainMemorySingle, toggled = ImGui.Checkbox("Drain Memory (Single Target)", drainMemorySingle)
        if toggled then
            SaveSettings()
        end

        if ImGui.IsItemHovered()
        then
            ImGui.BeginTooltip()
            ImGui.SetTooltip("Whether to drain your memory on ability used.")
            ImGui.EndTooltip()
        end

        drainMemoryMulti, toggled = ImGui.Checkbox("Drain Memory (Multi Target)", drainMemoryMulti)
        if toggled then
            SaveSettings()
        end

        if ImGui.IsItemHovered()
        then
            ImGui.BeginTooltip()
            ImGui.SetTooltip("Whether to drain your memory on ability used.")
            ImGui.EndTooltip()
        end

        ImGui.Spacing()
        ImGui.Separator()
        ImGui.Spacing()

        Text_x1, Text_y1 = ImGui.CalcTextSize("                   ")
        SingleTargetCooldown_x, SingleTargetCooldown_y = ImGui.CalcTextSize("Single Target Cooldown")

        ImGui.PushItemWidth(width - SingleTargetCooldown_x - Text_x1)
        MultiTargetRange, toggled = ImGui.DragInt("Multi Target Range", MultiTargetRange, 1, 1, 500)
        if toggled then
            MultiTargetRange = MultiTargetRange
            SaveSettings()
        end
        if ImGui.IsItemHovered()
        then
            ImGui.BeginTooltip()
            ImGui.SetTooltip("Min: 1, Max: 500, Drag or double-click to type.")
            ImGui.EndTooltip()
        end
        ImGui.PopItemWidth()

        if drainMemorySingle then
            TweakDB:SetFlat("QuickHack.BlackWallHack_modified_Single.costs",
                { "QuickHack.BaseBlackWallHack_inline7_modified_Single" })
            TweakDB:SetFlat("QuickHack.BaseBlackWallHack_inline8_modified_Single.value", memoryToDrainSingle)

            maxMemory = Game.GetStatPoolsSystem():GetStatPoolMaxPointValue(Game.GetPlayer():GetEntityID(), "Memory")
            if maxMemory == nil or maxMemory == 0 then
                maxMemory = 2
            end
            ImGui.PushItemWidth(width - SingleTargetCooldown_x - Text_x1)
            memoryToDrainSingle, toggled = ImGui.DragFloat("Memory to drain (Single Target)", memoryToDrainSingle, 1, 1,
                maxMemory, "%.1f")
            if toggled then
                memoryToDrainSingle = memoryToDrainSingle
                TweakDB:SetFlat("QuickHack.BaseBlackWallHack_inline8_modified_Single.value", memoryToDrainSingle)
                SaveSettings()
            end
            if ImGui.IsItemHovered()
            then
                ImGui.BeginTooltip()
                ImGui.SetTooltip("Min: 1, Max: " .. maxMemory .. ", Drag or double-click to type.")
                ImGui.EndTooltip()
            end
            ImGui.PopItemWidth()
        else
            TweakDB:SetFlat("QuickHack.BlackWallHack_modified_Single.costs", {})
        end

        if drainMemoryMulti then
            TweakDB:SetFlat("QuickHack.BlackWallHack_modified_Multi.costs",
                { "QuickHack.BaseBlackWallHack_inline7_modified_Multi" })
            TweakDB:SetFlat("QuickHack.BaseBlackWallHack_inline8_modified_Multi.value", memoryToDrainMulti)

            maxMemory = Game.GetStatPoolsSystem():GetStatPoolMaxPointValue(Game.GetPlayer():GetEntityID(), "Memory")
            if maxMemory == nil or maxMemory == 0 then
                maxMemory = 2
            end
            ImGui.PushItemWidth(width - SingleTargetCooldown_x - Text_x1)
            memoryToDrainMulti, toggled = ImGui.DragFloat("Memory to drain (Multi Target)", memoryToDrainMulti, 1, 1,
                maxMemory, "%.1f")
            if toggled then
                memoryToDrainMulti = memoryToDrainMulti
                TweakDB:SetFlat("QuickHack.BaseBlackWallHack_inline8_modified_Multi.value", memoryToDrainMulti)
                SaveSettings()
            end
            if ImGui.IsItemHovered()
            then
                ImGui.BeginTooltip()
                ImGui.SetTooltip("Min: 1, Max: " .. maxMemory .. ", Drag or double-click to type.")
                ImGui.EndTooltip()
            end
            ImGui.PopItemWidth()
        else
            TweakDB:SetFlat("QuickHack.BlackWallHack_modified_Multi.costs", {})
        end

        ImGui.End()
    end
end)
