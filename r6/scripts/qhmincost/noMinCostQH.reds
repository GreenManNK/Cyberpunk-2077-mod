@replaceMethod(ScriptableDeviceAction)
public func GetCost() -> Int32 {
    let availableMemory: Float;
    let cost: Float;
    let costMods: array<wref<StatModifier_Record>>;
    let currentlyUploadingAction: wref<ScriptableDeviceAction>;
    let device: ref<ScriptableDeviceComponentPS>;
    let deviceActionQueue: wref<DeviceActionQueue>;
    let distance: Float;
    let extraCost: Float;
    let hackCategory: gamedataHackCategory;
    let i: Int32;
    let instigatorPos: Vector4;
    let objectActionRecords: array<ref<ObjectAction_Record>>;
    let shouldReduceCost: Bool;
    let stacks: Uint32;
    let statPoolCost: ref<StatPoolCost_Record>;
    let statsDataSystem: ref<StatsDataSystem>;
    let targetID: EntityID;
    let targetPos: Vector4;
    let targetPuppet: ref<ScriptedPuppet>;
    let hackID: TweakDBID = this.GetObjectActionRecord().GetID();
    if IsDefined(this.GetExecutor()) && this.GetObjectActionRecord().GetCostsCount() > 0 {
        device = this.GetOwnerPS(this.GetExecutor().GetGame()) as ScriptableDeviceComponentPS;
        if IsDefined(device) && this.GetObjectActionID() == t"DeviceAction.TakeControlCameraClassHack" && device.WasActionPerformed(this.GetActionID(), EActionContext.QHack) {
        return 0;
        };
        if ArraySize(this.m_costComponents) == 0 {
        this.GetObjectActionRecord().Costs(this.m_costComponents);
        };
        if IsDefined(this.m_costComponents[0]) {
        BaseScriptableAction.GetCostMods(this.m_costComponents, costMods);
        if EntityID.IsDefined(this.GetRequesterID()) {
            targetID = this.GetRequesterID();
        } else {
            targetID = PersistentID.ExtractEntityID(this.GetPersistentID());
        };
        cost = RPGManager.CalculateStatModifiers(costMods, this.GetExecutor().GetGame(), this.GetExecutor(), Cast<StatsObjectID>(targetID), Cast<StatsObjectID>(this.GetExecutor().GetEntityID()));
        statPoolCost = this.m_costComponents[0] as StatPoolCost_Record;
        if Equals(statPoolCost.StatPool().StatPoolType(), gamedataStatPoolType.Memory) {
            hackCategory = this.GetObjectActionRecord().HackCategory().Type();
            if Equals(hackCategory, gamedataHackCategory.VehicleHack) {
            if this.GetObjectActionID() == t"DeviceAction.TakeControlVehicleClassHack" {
                cost *= GameInstance.GetStatsDataSystem(this.GetExecutor().GetGame()).GetValueFromCurve(n"puppet_dynamic_scaling", this.GetExecutorLevel(), n"vehicle_quickhack_remotecontrol_memory_cost_multiplier");
            } else {
                if this.GetObjectActionID() == t"DeviceAction.VehicleForceBrakesClassHack" {
                cost *= GameInstance.GetStatsDataSystem(this.GetExecutor().GetGame()).GetValueFromCurve(n"puppet_dynamic_scaling", this.GetExecutorLevel(), n"vehicle_quickhack_forcebrakes_memory_cost_multiplier");
                } else {
                if this.GetObjectActionID() == t"DeviceAction.VehicleExplodeClassHack" {
                    cost *= GameInstance.GetStatsDataSystem(this.GetExecutor().GetGame()).GetValueFromCurve(n"puppet_dynamic_scaling", this.GetExecutorLevel(), n"vehicle_quickhack_explode_memory_cost_multiplier");
                } else {
                    if this.GetObjectActionID() == t"DeviceAction.VehicleAccelerateClassHack" {
                    cost *= GameInstance.GetStatsDataSystem(this.GetExecutor().GetGame()).GetValueFromCurve(n"puppet_dynamic_scaling", this.GetExecutorLevel(), n"vehicle_quickhack_accelerate_memory_cost_multiplier");
                    };
                };
                };
            };
            } else {
            extraCost = GameInstance.GetStatsDataSystem(this.GetExecutor().GetGame()).GetValueFromCurve(n"puppet_dynamic_scaling", this.GetPowerLevelDiff(), n"pl_diff_to_memory_cost_modifier");
            cost += extraCost;
            if Equals(hackCategory, gamedataHackCategory.UltimateHack) {
                cost += extraCost;
            };
            };
            if Cast<Bool>(PlayerDevelopmentSystem.GetData(this.GetExecutor()).IsNewPerkBought(gamedataNewPerkType.Intelligence_Left_Perk_3_1)) && this.IsFirstUniqueCategoryInQueue(targetID, hackCategory) {
            cost -= GameInstance.GetStatsSystem(this.GetExecutor().GetGame()).GetStatValue(Cast<StatsObjectID>(this.GetExecutor().GetEntityID()), gamedataStatType.FirstHackOfTypeInQueueRAMDecrease);
            };
            if Equals(hackCategory, gamedataHackCategory.DamageHack) && Cast<Bool>(PlayerDevelopmentSystem.GetData(this.GetExecutor()).IsNewPerkBought(gamedataNewPerkType.Intelligence_Central_Perk_2_2)) {
            shouldReduceCost = false;
            if GameInstance.GetStatusEffectSystem(this.GetExecutor().GetGame()).HasStatusEffectWithTag(targetID, n"CovertQuickhacked") || GameInstance.GetStatusEffectSystem(this.GetExecutor().GetGame()).HasStatusEffectWithTag(targetID, n"ControlQuickhacked") || GameInstance.GetStatusEffectSystem(this.GetExecutor().GetGame()).HasStatusEffect(targetID, t"BaseStatusEffect.DistractionDuration") {
                shouldReduceCost = true;
            };
            if !shouldReduceCost {
                targetPuppet = GameInstance.FindEntityByID(this.GetExecutor().GetGame(), targetID) as ScriptedPuppet;
                if IsDefined(targetPuppet) {
                currentlyUploadingAction = targetPuppet.GetCurrentlyUploadingAction();
                if Equals(currentlyUploadingAction.GetObjectActionRecord().HackCategory().Type(), gamedataHackCategory.CovertHack) || Equals(currentlyUploadingAction.GetObjectActionRecord().HackCategory().Type(), gamedataHackCategory.ControlHack) {
                    shouldReduceCost = true;
                };
                deviceActionQueue = currentlyUploadingAction.GetDeviceActionQueue();
                deviceActionQueue.GetAllQueuedActionObjectRecords(objectActionRecords);
                i = 0;
                while i < ArraySize(objectActionRecords) {
                    if Equals(objectActionRecords[i].HackCategory().Type(), gamedataHackCategory.CovertHack) || Equals(objectActionRecords[i].HackCategory().Type(), gamedataHackCategory.ControlHack) {
                    shouldReduceCost = true;
                    break;
                    };
                    i += 1;
                };
                };
            };
            if shouldReduceCost {
                cost -= TweakDBInterface.GetFloat(t"NewPerks.Intelligence_Central_Perk_2_2.memoryCostReduction", 0.00);
            };
            };
            if this.IsEyesInTheSkyPerk() {
            cost -= TweakDBInterface.GetFloat(t"NewPerks.Intelligence_Left_Milestone_1.memoryCostReduction", 0.00);
            };
            if Cast<Bool>(PlayerDevelopmentSystem.GetData(this.GetExecutor()).IsNewPerkBought(gamedataNewPerkType.Intelligence_Master_Perk_1)) {
            targetPuppet = GameInstance.FindEntityByID(this.GetExecutor().GetGame(), targetID) as ScriptedPuppet;
            if IsDefined(targetPuppet) && targetPuppet.CanNewActionBeQueued() && targetPuppet.GetDeviceActionQueueSize() >= targetPuppet.GetDeviceActionMaxQueueSize() - 1 {
                cost *= 1.00 - TweakDBInterface.GetFloat(t"NewPerks.Intelligence_Master_Perk_1.memoryCostReduction", 0.00);
            };
            };
            if GameInstance.GetStatPoolsSystem(this.GetExecutor().GetGame()).GetStatPoolValue(Cast<StatsObjectID>(this.GetExecutor().GetEntityID()), gamedataStatPoolType.QuickHackUpload, true) > 0.00 && GameInstance.GetStatsSystem(this.GetExecutor().GetGame()).GetStatValue(Cast<StatsObjectID>(targetID), gamedataStatType.IsNetrunnerArchetype) > 0.00 {
            if GameInstance.GetStatsSystem(this.GetExecutor().GetGame()).GetStatValue(Cast<StatsObjectID>(targetID), gamedataStatType.RevealNetrunnerWhenHacked) > 0.00 {
                if Cast<Bool>(PlayerDevelopmentSystem.GetData(this.GetExecutor()).IsNewPerkBought(gamedataNewPerkType.Intelligence_Left_Perk_2_1)) {
                cost -= TweakDBInterface.GetFloat(t"NewPerks.Intelligence_Left_Perk_2_1.memoryCostReduction", 0.00);
                };
            };
            };
            if hackID == t"QuickHack.MadnessLvl3Hack" || hackID == t"QuickHack.MadnessLvl4Hack" || hackID == t"QuickHack.MadnessLvl4PlusPlusHack" || hackID == t"QuickHack.MadnessSetFriendlyHack" {
            cost -= this.GetMadnessLvl3ProgramCostReduction(targetID);
            };
            if hackID == t"QuickHack.BrainMeltLvl3Hack" || hackID == t"QuickHack.BrainMeltLvl4Hack" || hackID == t"QuickHack.BrainMeltLvl4PlusPlusHack" {
            stacks = StatusEffectHelper.GetStatusEffectByID(GetPlayer(this.GetExecutor().GetGame()), t"BaseStatusEffect.BrainMeltCostReductionSE").GetStackCount();
            cost -= Cast<Float>(stacks) * TweakDBInterface.GetFloat(t"EquipmentGLP.BrainMeltProgramLvl3Passive.memoryCostReductionPerStack", 0.00);
            };
            if hackID == t"QuickHack.SystemCollapseLvl3Hack" || hackID == t"QuickHack.SystemCollapseLvl4Hack" || hackID == t"QuickHack.SystemCollapseLvl4PlusPlusHack" {
            stacks = StatusEffectHelper.GetStatusEffectByID(GetPlayer(this.GetExecutor().GetGame()), t"BaseStatusEffect.SystemCollapseMemoryCostReduction").GetStackCount();
            cost -= Cast<Float>(stacks) * TweakDBInterface.GetFloat(t"EquipmentGLP.SystemCollapseLvl3Program.memoryCostReductionPerStack", 0.00);
            };
            if this.GetObjectActionRecord().GetID() == t"QuickHack.GrenadeLvl3Hack" || this.GetObjectActionRecord().GetID() == t"QuickHack.GrenadeLvl4Hack" {
            cost -= this.GetDetonateGranadeCostReduction(false);
            } else {
            if this.GetObjectActionRecord().GetID() == t"QuickHack.GrenadeLvl4PlusPlusHack" {
                cost -= this.GetDetonateGranadeCostReduction(true);
            };
            };
            if Equals(this.actionName, n"Suicide") {
            cost -= GameInstance.GetStatsSystem(this.GetExecutor().GetGame()).GetStatValue(Cast<StatsObjectID>(this.GetExecutor().GetEntityID()), gamedataStatType.SuicideHackMemoryCostReduction);
            };
            if Cast<Bool>(PlayerDevelopmentSystem.GetData(this.GetExecutor()).IsNewPerkBought(gamedataNewPerkType.Intelligence_Central_Perk_1_2)) {
            targetPos = GameInstance.FindEntityByID(this.GetExecutor().GetGame(), targetID).GetWorldPosition();
            instigatorPos = this.GetExecutor().GetWorldPosition();
            distance = Vector4.Distance(targetPos, instigatorPos);
            statsDataSystem = GameInstance.GetStatsDataSystem(this.GetExecutor().GetGame());
            cost *= 1.00 - statsDataSystem.GetValueFromCurve(n"hacking_passives", distance, n"distance_to_hacking_cost_reduction");
            };
            if QuickHackableHelper.IsOverclockedStateActive(this.GetExecutor()) {
            if StrEndsWith(NameToString(this.actionName), "BlackWall") {
                availableMemory = GameInstance.GetStatPoolsSystem(this.GetExecutor().GetGame()).GetStatPoolValue(Cast<StatsObjectID>(this.GetExecutor().GetEntityID()), gamedataStatPoolType.Memory, false);
                availableMemory = MinF(cost, Cast<Float>(FloorF(availableMemory)));
                cost = availableMemory + (cost - availableMemory) * TweakDBInterface.GetFloat(t"QuickHack.BaseBlackWallHack.memoryCostReductionInOverclock", 1.00);
            };
            };
        };
        if ArraySize(costMods) > 0 {
            return Max(0, CeilF(cost));
        };
        return Max(0, CeilF(cost));
        };
    };
    return 0;
}
