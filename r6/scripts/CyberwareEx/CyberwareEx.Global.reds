// CyberwareEx 1.5.6
import CyberwareEx.{CompatibilityManager, ConflictsPopup, RequirementsPopup}
import CyberwareEx.*

public abstract class CyberwareEx {
    public static func Version() -> String = "1.5.6"

    public static func ResetSlot(game: GameInstance, areaType: gamedataEquipmentArea) {
        let player = GetPlayer(game);
        let overrideManager = new OverrideManager();
        overrideManager.Initialize(EquipmentSystem.GetData(player));
        overrideManager.ResetSlot(areaType, true);
    }

    public static func ResetAllSlots(game: GameInstance) {
        let player = GetPlayer(game);
        let overrideManager = new OverrideManager();
        overrideManager.Initialize(EquipmentSystem.GetData(player));
        for override in OverrideConfig.SlotOverrides() {
            overrideManager.ResetSlot(override.areaType, true);
        }
    }

    public static func UpgradeSlot(game: GameInstance, areaType: gamedataEquipmentArea, opt count: Int32) {
        if IsOverrideMode() {
            let player = GetPlayer(game);
            let overrideManager = new OverrideManager();
            overrideManager.Initialize(EquipmentSystem.GetData(player));
            if count == 0 {
                count = 1;
            }
            while (count > 0) {
                overrideManager.UpgradeSlot(areaType, true);
                count -= 1;
            }
        }
    }

    public static func UpgradeAllSlotsToMax(game: GameInstance) {
        if IsOverrideMode() {
            let player = GetPlayer(game);
            let overrideManager = new OverrideManager();
            overrideManager.Initialize(EquipmentSystem.GetData(player));
            for override in OverrideConfig.SlotOverrides() {
                while (overrideManager.UpgradeSlot(override.areaType, true)) {}
            }
        }
    }
}

@replaceMethod(Device)
protected final const func IsCyberdeckEquippedOnPlayer() -> Bool {
    return CyberwareHelper.IsCyberdeckEquipped(GetPlayer(this.GetGame()));
}

@replaceMethod(EquipmentSystem)
public final static func IsCyberdeckEquipped(owner: ref<GameObject>) -> Bool {
    return GameInstance.GetStatsSystem(owner.GetGame()).GetStatBoolValue(Cast(owner.GetEntityID()), gamedataStatType.HasCyberdeck);
}

@addMethod(EquipmentSystemPlayerData)
public func HasTaggedItem(equipArea: gamedataEquipmentArea, requiredTag: CName) -> Bool {
    return ItemID.IsValid(this.GetTaggedItem(equipArea, [requiredTag]));
}

@addMethod(EquipmentSystemPlayerData)
public func GetTaggedItem(equipArea: gamedataEquipmentArea, requiredTag: CName) -> ItemID {
    return this.GetTaggedItem(equipArea, [requiredTag]);
}

@addMethod(EquipmentSystemPlayerData)
public func GetTaggedItem(equipArea: gamedataEquipmentArea, requiredTags: array<CName>) -> ItemID {
    let equipAreaIndex = this.GetEquipAreaIndex(equipArea);
    let numSlots = ArraySize(this.m_equipment.equipAreas[equipAreaIndex].equipSlots);
    let slotIndex = 0;

    while slotIndex < numSlots {
        let itemID = this.m_equipment.equipAreas[equipAreaIndex].equipSlots[slotIndex].itemID;

        if ItemID.IsValid(itemID) && this.CheckTagsInItem(itemID, requiredTags) {
            return itemID;
        }

        slotIndex += 1;
    }

    return ItemID.None();
}

@addMethod(EquipmentSystemPlayerData)
public func ApplyAreaPowerUps(equipArea: gamedataEquipmentArea) {
    let equipAreaIndex = this.GetEquipAreaIndex(equipArea);
    let numSlots = ArraySize(this.m_equipment.equipAreas[equipAreaIndex].equipSlots);
    let slotIndex = 0;

    while slotIndex < numSlots {
        PowerUpCyberwareEffector.PowerUpCyberwareInSlot(this.m_owner, equipArea, slotIndex);
        slotIndex += 1;
    }
}

@wrapMethod(EquipmentSystemPlayerData)
public final const func GetActiveItem(equipArea: gamedataEquipmentArea) -> ItemID {
    if Equals(equipArea, gamedataEquipmentArea.SystemReplacementCW) {
        return this.GetTaggedItem(equipArea, n"Cyberdeck");
    }

    return wrappedMethod(equipArea);
}

@wrapMethod(EquipmentSystemPlayerData)
private final func UnequipItem(equipAreaIndex: Int32, slotIndex: Int32, opt forceRemove: Bool) {
    wrappedMethod(equipAreaIndex, slotIndex, forceRemove);

    switch this.m_equipment.equipAreas[equipAreaIndex].areaType {
        case gamedataEquipmentArea.EyesCW:
        case gamedataEquipmentArea.LegsCW:
        case gamedataEquipmentArea.SystemReplacementCW:
            let slotIndex = 0;
            let numberOfSlots = ArraySize(this.m_equipment.equipAreas[equipAreaIndex].equipSlots);
            while slotIndex < numberOfSlots {
                let itemID = this.m_equipment.equipAreas[equipAreaIndex].equipSlots[slotIndex].itemID;
                if ItemID.IsValid(itemID) {
                    this.RemoveEquipGLPs(itemID);
                    this.ApplyEquipGLPs(itemID);
                }
                slotIndex += 1;
            }
            break;
    }
}

@replaceMethod(EquipmentSystemPlayerData)
public final func AssignItemToHotkey(newID: ItemID, hotkey: EHotkey) {
    if Equals(hotkey, EHotkey.INVALID) {
        return;
    }

    let oldID = this.m_hotkeys[EnumInt(hotkey)].GetItemID();
    if newID == oldID {
        if Equals(hotkey, EHotkey.LBRB) {
            this.SyncHotkeyData(hotkey);
        }
        return;
    }

    let transactionSystem = GameInstance.GetTransactionSystem(this.m_owner.GetGame());

    let oldCategory = RPGManager.GetItemCategory(oldID);
    if NotEquals(oldCategory, gamedataItemCategory.Cyberware) {
        transactionSystem.OnItemRemovedFromEquipmentSlot(this.m_owner, oldID);
    }
    if Equals(oldCategory, gamedataItemCategory.Consumable) {
        this.RemoveEquipGLPs(oldID);
    }

    this.m_hotkeys[EnumInt(hotkey)].StoreItem(newID);

    let newCategory = RPGManager.GetItemCategory(newID);
    if NotEquals(newCategory, gamedataItemCategory.Cyberware) {
        transactionSystem.OnItemAddedToEquipmentSlot(this.m_owner, newID);
    }
    if Equals(newCategory, gamedataItemCategory.Consumable) {
        this.ApplyEquipGLPs(newID);
    }

    this.SyncHotkeyData(hotkey);
}

@if(ModuleExists("CyberwareEx.OverrideMode"))
@wrapMethod(EquipmentSystemPlayerData)
private final const func IsSlotLocked(slot: SEquipSlot, out visibleWhenLocked: Bool) -> Bool {
    if !slot.visibleWhenLocked {
        return wrappedMethod(slot, visibleWhenLocked);
    }
    visibleWhenLocked = true;
    return false;
}

@if(ModuleExists("CyberwareEx.OverrideMode"))
@replaceMethod(EquipmentSystemPlayerData)
private final func InitializeEquipmentArea(equipAreaRecord: ref<EquipmentArea_Record>, out equipArea: SEquipArea) {
    let equipSlotRecords: array<wref<EquipSlot_Record>>;
    equipAreaRecord.EquipSlots(equipSlotRecords);

    if CyberwareHelper.IsCyberwareArea(equipArea.areaType) {
        let numberOfRecords = ArraySize(equipSlotRecords);
        let numberOfSlots = ArraySize(equipArea.equipSlots);
        if numberOfSlots > numberOfRecords {
            let slotIndex = numberOfRecords;
            while slotIndex < numberOfSlots {
                let equipSlotID = CyberwareHelper.CreateEquipSlotRecord(equipArea.areaType, slotIndex);
                ArrayPush(equipSlotRecords, TweakDBInterface.GetEquipSlotRecord(equipSlotID));
                slotIndex += 1;
            }
        }
    }

    this.InitializeEquipSlotsFromRecords(equipSlotRecords, equipArea.equipSlots);
}

@if(ModuleExists("CyberwareEx.OverrideMode"))
@replaceMethod(EquipmentSystemPlayerData)
private final func InitializeEquipSlotsFromRecords(slotRecords: array<wref<EquipSlot_Record>>, out equipSlots: array<SEquipSlot>) {
    let numberOfRecords = ArraySize(slotRecords);
    let numberOfSlots = ArraySize(equipSlots);
    let finalSize = Max(numberOfRecords, numberOfSlots);
    let i = 0;
    while i < finalSize {
        if i < numberOfRecords {
            let equipSlot: SEquipSlot;
            this.InitializeEquipSlotFromRecord(slotRecords[i], equipSlot);
            if i < numberOfSlots {
                if !IsDefined(equipSlot.unlockPrereq) || equipSlot.visibleWhenLocked || equipSlot.unlockPrereq.IsFulfilled(this.m_owner.GetGame(), this.m_owner) {
                    equipSlot.itemID = equipSlots[i].itemID;
                }
                equipSlots[i] = equipSlot;
            } else {
                ArrayPush(equipSlots, equipSlot);
            }
        } else {
            this.InitializeEquipSlotFromRecord(TweakDBInterface.GetEquipSlotRecord(t"EquipmentArea.SimpleEquipSlot"), equipSlots[i]);
        }
        i += 1;
    }
}

@if(!ModuleExists("CyberwareEx.OverrideMode"))
@wrapMethod(EquipmentSystemPlayerData)
private final func InitializeEquipSlotsFromRecords(slotRecords: array<wref<EquipSlot_Record>>, out equipSlots: array<SEquipSlot>) {
    wrappedMethod(slotRecords, equipSlots);
    ArrayResize(equipSlots, ArraySize(slotRecords));
}

@if(!ModuleExists("CyberarmOverhaul"))
@wrapMethod(EquipmentSystemPlayerData)
private final const func UpdateQuickWheel() {
    wrappedMethod();

    let i = 0;
    while i < ArraySize(this.m_hotkeys) {
        let itemID = this.m_hotkeys[i].GetItemID();
        if ItemID.IsValid(itemID) {
            if this.CheckTagsInItem(itemID, [n"ProjectileLauncher"]) {
                if !this.IsEquipped(itemID) {
                    this.AssignNextValidItemToHotkey(itemID);
                }
                break;
            }
        }
        i += 1;
    }
}

@if(!ModuleExists("CyberarmOverhaul"))
@replaceMethod(EquipmentSystemPlayerData)
public final static func UpdateArmSlot(owner: ref<PlayerPuppet>, itemToDraw: ItemID, equipHolsteredItem: Bool) {
    if !IsDefined(owner) || !ItemID.IsValid(itemToDraw) || owner.IsJohnnyReplacer() {
      return;
    }

    let equipmentData = EquipmentSystem.GetData(owner);

    if !IsDefined(equipmentData) {
      return;
    }

    let transactionSystem = GameInstance.GetTransactionSystem(owner.GetGame());
    let rightWeaponID = transactionSystem.GetItemInSlot(owner, t"AttachmentSlots.WeaponRight").GetItemID();
    let leftWeaponID = transactionSystem.GetItemInSlot(owner, t"AttachmentSlots.WeaponLeft").GetItemID();

    let cyberArmsInUse = ItemID.IsValid(rightWeaponID) && TweakDBInterface.GetItemRecord(ItemID.GetTDBID(rightWeaponID)).TagsContains(n"Meleeware");
    let launcherInUse = ItemID.IsValid(leftWeaponID) && TweakDBInterface.GetItemRecord(ItemID.GetTDBID(leftWeaponID)).TagsContains(n"ProjectileLauncher");

    let meleeWareID = ItemID.None();
    let slotIndex = 0;
    let equipAreaIndex = equipmentData.GetEquipAreaIndex(gamedataEquipmentArea.ArmsCW);
    let numberOfSlots = ArraySize(equipmentData.m_equipment.equipAreas[equipAreaIndex].equipSlots);
    while slotIndex < numberOfSlots {
        let itemID = equipmentData.m_equipment.equipAreas[equipAreaIndex].equipSlots[slotIndex].itemID;
        if ItemID.IsValid(itemID) {
            meleeWareID = itemID;
            let itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(itemID));
            if !itemRecord.TagsContains(n"ProjectileLauncher") {
                break;
            }
        }
        slotIndex += 1;
    }

    if !ItemID.IsValid(meleeWareID) {
        meleeWareID = equipmentData.GetBaseFistsItemID();
    }

    if !launcherInUse && !cyberArmsInUse {
        let holsteredArmsID = ItemID.CreateQuery(TweakDBInterface.GetWeaponItemRecord(ItemID.GetTDBID(meleeWareID)).HolsteredItem().GetID());

        if !transactionSystem.HasItem(owner, holsteredArmsID) {
            transactionSystem.GiveItem(owner, holsteredArmsID, 1);
        }

        EquipmentSystemPlayerData.ForceQualityAndDuplicateStatsShard(owner, meleeWareID, holsteredArmsID);

        if !equipmentData.IsEquipped(holsteredArmsID) {
            equipmentData.EquipItem(holsteredArmsID, false, false);
        }
    } else {
        equipmentData.UnequipItem(equipmentData.GetEquipAreaIndex(gamedataEquipmentArea.RightArm), 0, true);
    }
}

@wrapMethod(PlayerDevelopmentData)
private final func HandleAddingPerkLevel(i: Int32, j: Int32) {
    if Equals(this.m_attributesData[i].unlockedPerks[j].type, gamedataNewPerkType.Tech_Central_Milestone_3) && this.m_attributesData[i].unlockedPerks[j].currLevel == 3 {
        EquipmentSystem.GetData(this.m_owner).ApplyAreaPowerUps(gamedataEquipmentArea.MusculoskeletalSystemCW);
    }
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    wrappedMethod();

    if this.IsControlledByLocalPeer() || IsHost() {
        this.RegisterInputListener(this, n"ToggleSprint");
    }
}

@wrapMethod(PlayerPuppet)
protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if this.PlayerLastUsedPad() && Equals(ListenerAction.GetName(action), n"ToggleSprint")
        && Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_RELEASED) {
        let psmBlackboard = this.GetPlayerStateMachineBlackboard();
        let isFocusMode = Equals(IntEnum<gamePSMVision>(psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision)), gamePSMVision.Focus);
        if isFocusMode {
            if QuickHackableHelper.TryToCycleOverclockedState(this) {
                let dpadAction = new DPADActionPerformed();
                dpadAction.action = EHotkey.LBRB;
                dpadAction.state = EUIActionState.COMPLETED;
                dpadAction.successful = true;

                GameInstance.GetUISystem(this.GetGame()).QueueEvent(dpadAction);
            }
        }
    } else {
        wrappedMethod(action, consumer);
    }
}

@replaceMethod(PlayerPuppet)
private final func ActivateIconicCyberware() {
    let equipmentData = EquipmentSystem.GetData(this);
    let characterData = PlayerDevelopmentSystem.GetData(this);

    let hasBerserk = equipmentData.HasTaggedItem(gamedataEquipmentArea.SystemReplacementCW, n"Berserk");
    let hasSandevistan = equipmentData.HasTaggedItem(gamedataEquipmentArea.SystemReplacementCW, n"Sandevistan");
    let hasOverclock = equipmentData.HasTaggedItem(gamedataEquipmentArea.SystemReplacementCW, n"Cyberdeck")
        && characterData.IsNewPerkBought(gamedataNewPerkType.Intelligence_Central_Milestone_3) == 3;

    let numberOfAbilities = (hasBerserk ? 1 : 0) + (hasSandevistan ? 1 : 0) + (hasOverclock ? 1 : 0);
    if numberOfAbilities == 0 {
        return;
    }

    let isOnlyOneAbility = numberOfAbilities == 1;
    let isCombinedAbilityMode = IsCombinedAbilityMode();

    let statsSystem = GameInstance.GetStatsSystem(this.GetGame());
    let playerStatsId = Cast<StatsObjectID>(this.GetEntityID());
    let canUseBerserk = statsSystem.GetStatBoolValue(playerStatsId, gamedataStatType.HasBerserk);
    let canUseSandevistan = statsSystem.GetStatBoolValue(playerStatsId, gamedataStatType.HasSandevistan);

    let psmBlackboard = this.GetPlayerStateMachineBlackboard();
    let meleeWeaponState = IntEnum<gamePSMMeleeWeapon>(psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.MeleeWeapon));

    let isFocusMode = Equals(IntEnum<gamePSMVision>(psmBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.Vision)), gamePSMVision.Focus);
    let isBlocking = Equals(meleeWeaponState, gamePSMMeleeWeapon.Block) || Equals(meleeWeaponState, gamePSMMeleeWeapon.BlockAttack)
        || Equals(meleeWeaponState, gamePSMMeleeWeapon.Deflect) || Equals(meleeWeaponState, gamePSMMeleeWeapon.DeflectAttack);
    let isInVehicle = psmBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.MountedToVehicle);

    let attempted = false;
    let activated = false;

    if hasOverclock && (isOnlyOneAbility || isFocusMode || isCombinedAbilityMode) {
        attempted = true;
        if QuickHackableHelper.TryToCycleOverclockedState(this) {
            activated = true;
        }
    }

    if hasBerserk && !isFocusMode && (isOnlyOneAbility || ((isBlocking || !hasSandevistan)) || isCombinedAbilityMode) {
        if canUseBerserk && !isInVehicle {
            let berserkItem = equipmentData.GetTaggedItem(gamedataEquipmentArea.SystemReplacementCW, n"Berserk");

            attempted = true;
            if ItemActionsHelper.UseItem(this, berserkItem) {
                activated = true;
            }
        }
    }

    if hasSandevistan && !isFocusMode && (isOnlyOneAbility || ((!isBlocking || !hasBerserk)) || isCombinedAbilityMode) {
        if canUseSandevistan && TimeDilationHelper.CanUseTimeDilation(this) {
            let sandevistanItem = equipmentData.GetTaggedItem(gamedataEquipmentArea.SystemReplacementCW, n"Sandevistan");

            attempted = true;
            if ItemActionsHelper.UseItem(this, sandevistanItem) {
                activated = true;
            }
        }
    }

    if attempted {
        if activated {
            this.IconicCyberwareActivated();
        } else {
            let audioEvent = new SoundPlayEvent();
            audioEvent.soundName = n"ui_grenade_empty";

            this.QueueEvent(audioEvent);
        }

        let dpadAction = new DPADActionPerformed();
        dpadAction.action = EHotkey.LBRB;
        dpadAction.state = EUIActionState.COMPLETED;
        dpadAction.successful = activated;

        GameInstance.GetUISystem(this.GetGame()).QueueEvent(dpadAction);
    }
}

@wrapMethod(PlayerPuppet)
protected cb func OnCleanUpTimeDilationEvent(evt: ref<CleanUpTimeDilationEvent>) -> Bool {
    let timeSystem = GameInstance.GetTimeSystem(this.GetGame());
    if !timeSystem.IsTimeDilationActive() {
        wrappedMethod(evt);
    }
}

@addField(QuestTrackerGameController)
private let m_cyberwareExPopup: ref<inkGameNotificationToken>;

@wrapMethod(QuestTrackerGameController)
protected cb func OnInitialize() -> Bool {
    wrappedMethod();

    if !CompatibilityManager.IsUserNotified() {
        if !CompatibilityManager.CheckRequirements() {
            this.m_cyberwareExPopup = RequirementsPopup.Show(this);
            this.m_cyberwareExPopup.RegisterListener(this, n"OnCyberwareExPopupClose");
        } else {
            if !CompatibilityManager.CheckConflicts(this.m_player.GetGame()) {
                this.m_cyberwareExPopup = ConflictsPopup.Show(this);
                this.m_cyberwareExPopup.RegisterListener(this, n"OnCyberwareExPopupClose");
            }
        }
        CompatibilityManager.MarkAsNotified();
    }
}

@addMethod(QuestTrackerGameController)
protected cb func OnCyberwareExPopupClose(data: ref<inkGameNotificationData>) {
    this.m_cyberwareExPopup = null;
}

@replaceMethod(DoubleJumpDecisions)
protected const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    let jumpPressedFlag = stateContext.GetConditionBool(n"JumpPressed");
    if !jumpPressedFlag && !this.m_jumpPressed {
        this.EnableOnEnterCondition(false);
    }
    if !scriptInterface.HasStatFlag(gamedataStatType.HasDoubleJump) {
        return false;
    }
    if StatusEffectSystem.ObjectHasStatusEffect(scriptInterface.executionOwner, t"BaseStatusEffect.HealFood3") {
        return false;
    }
    if this.IsCurrentFallSpeedTooFastToEnter(stateContext, scriptInterface) {
        return false;
    }
    if scriptInterface.localBlackboard.GetBool(GetAllBlackboardDefs().PlayerStateMachine.IsPlayerInsideMovingElevator) {
        return false;
    }
    let currentNumberOfJumps = stateContext.GetIntParameter(n"currentNumberOfJumps", true);
    if currentNumberOfJumps >= this.GetStaticIntParameterDefault("numberOfMultiJumps", 1) {
        return false;
    }
    if jumpPressedFlag || scriptInterface.IsActionJustPressed(n"Jump") {
        return true;
    }
    return false;
}

@wrapMethod(EquippedDecisions)
protected final const func ToUnequipCycle(stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if this.IsLeftHandLogic(this.stateMachineInstanceData) {
        let minActiveState = EnumInt(gamePSMLeftHandCyberware.Equipped);
        let maxActiveState = EnumInt(gamePSMLeftHandCyberware.CatchAction);
        let leftHandCyberwareState = scriptInterface.localBlackboard.GetInt(GetAllBlackboardDefs().PlayerStateMachine.LeftHandCyberware);
        if leftHandCyberwareState >= minActiveState && leftHandCyberwareState <= maxActiveState {
            return false;
        }
    }

    return wrappedMethod(stateContext, scriptInterface);
}

@replaceMethod(TimeDilationFocusModeDecisions)
protected final const func EnterCondition(const stateContext: ref<StateContext>, const scriptInterface: ref<StateGameScriptInterface>) -> Bool {
    if !this.IsInVisionModeActiveState(stateContext, scriptInterface) {
        if this.IsTimeDilationActive(stateContext, scriptInterface, TimeDilationHelper.GetFocusModeKey()) {
            let timeSystem = scriptInterface.GetTimeSystem();
            let easeOutCurve = TweakDBInterface.GetCName(t"timeSystem.focusModeTimeDilation.easeOutCurve", n"");
            let applyTimeDilationToPlayer = TweakDBInterface.GetBool(t"timeSystem.focusModeTimeDilation.applyTimeDilationToPlayer", false);

            timeSystem.UnsetTimeDilation(TimeDilationHelper.GetFocusModeKey(), easeOutCurve);

            if applyTimeDilationToPlayer {
                timeSystem.UnsetTimeDilationOnLocalPlayerZero(TimeDilationHelper.GetFocusModeKey(), easeOutCurve);

                if this.IsTimeDilationActive(stateContext, scriptInterface, TimeDilationHelper.GetSandevistanKey()) {
                    timeSystem.SetTimeDilationOnLocalPlayerZero(TimeDilationHelper.GetSandevistanKey(), 1.0, 999.0, n"", n"");
                }
            }
        }
        return false;
    }

    if this.IsPlayerInBraindance(scriptInterface) {
        return false;
    }

    if !this.ShouldActivate(stateContext, scriptInterface) {
        return false;
    }

    if this.IsTimeDilationActive(stateContext, scriptInterface, TimeDilationHelper.GetSandevistanKey()) {
        if !this.IsTimeDilationActive(stateContext, scriptInterface, TimeDilationHelper.GetFocusModeKey()) {
            let timeSystem = scriptInterface.GetTimeSystem();
            let timeDilation = TweakDBInterface.GetFloat(t"timeSystem.focusModeTimeDilation.timeDilation", 0.0);
            let playerDilation = TweakDBInterface.GetFloat(t"timeSystem.focusModeTimeDilation.playerTimeDilation", 0.0);
            let easeInCurve = TweakDBInterface.GetCName(t"timeSystem.focusModeTimeDilation.easeInCurve", n"");
            let easeOutCurve = TweakDBInterface.GetCName(t"timeSystem.focusModeTimeDilation.easeOutCurve", n"");
            let applyTimeDilationToPlayer = TweakDBInterface.GetBool(t"timeSystem.focusModeTimeDilation.applyTimeDilationToPlayer", false);

            timeSystem.SetTimeDilation(TimeDilationHelper.GetFocusModeKey(), timeDilation, 999.0, easeInCurve, easeOutCurve);

            if applyTimeDilationToPlayer {
                timeSystem.SetTimeDilationOnLocalPlayerZero(TimeDilationHelper.GetFocusModeKey(), playerDilation, 999.0, easeInCurve, easeOutCurve);
            }
        }

        return false;
    }

    return this.GetBoolFromTimeSystemTweak("focusModeTimeDilation", "enableTimeDilation");
}

@replaceMethod(ChargedHotkeyItemCyberwareController)
protected func UpdateCurrentItem() {
    let cyberwareType = this.GetRootWidget().GetName();

    let playerData = this.m_equipmentSystem.GetPlayerData(this.GetPlayerControlledObject());
    let activeItemID = playerData.GetTaggedItem(gamedataEquipmentArea.SystemReplacementCW, cyberwareType);
    
    if ItemID.IsValid(activeItemID) {
        let previousItem = this.m_currentItem;
        
        this.m_currentItem = this.m_inventoryManager.GetInventoryItemDataFromItemID(activeItemID);
        this.m_currentItem.Quantity = 0;

        this.m_hotkeyItemController.Setup(this.m_currentItem, ItemDisplayContext.DPAD_RADIAL);
        this.ResolveState();
        
        if previousItem.ID != this.m_currentItem.ID {
            this.UpdateStatListener();
            this.UpdateChargeValue(
                this.GetStatPoolCurrentValue(this.m_currentStatPoolType, true),
                this.GetStatPoolMaxPoints(this.m_currentStatPoolType) / 100.00,
                false
            );
        }

        switch this.GetItemType(this.m_currentItem.ID, n"None") {
            case this.c_cyberdeckKey:
                this.GetRootWidget().SetVisible(this.IsCyberdeckOverloadPerkPresent());
                break;
            case this.c_sandevistanKey:
                this.UpdateSandevistanVisibility();
                break;
            case this.c_berserkKey:
                this.GetRootWidget().SetVisible(Equals(PlayerPuppet.GetCurrentVehicleState(this.GetPlayer()), gamePSMVehicle.Default));
                break;
            case this.c_capacityBoosterKey:
                this.GetRootWidget().SetVisible(false);
                break;
            default:
                this.GetRootWidget().SetVisible(true);
        }
    } else {
        this.m_currentItem = this.m_inventoryManager.GetInventoryItemDataFromItemID(ItemID.None());
        this.m_hotkeyItemController.Setup(this.m_currentItem, ItemDisplayContext.DPAD_RADIAL);
        this.GetRootWidget().SetVisible(false);
    }
}

@replaceMethod(CyberwareInventoryMiniGrid)
public final func GetSlotToEquipe(itemID: ItemID) -> Int32 {
    let cyberwareType = TweakDBInterface.GetCName(ItemID.GetTDBID(itemID) + t".cyberwareType", n"None");
    let slotIndex = ArraySize(this.m_gridData) - 1;
    let emptyIndex = -1;
    while slotIndex >= 0 {
        if !this.m_gridData[slotIndex].IsLocked() {
            if !IsDefined(this.m_gridData[slotIndex].GetUIInventoryItem()) {
                emptyIndex = this.m_gridData[slotIndex].GetSlotIndex();
            } else {
                let equippedType = TweakDBInterface.GetCNameDefault(this.m_gridData[slotIndex].GetUIInventoryItem().GetTweakDBID() + t".cyberwareType");
                if Equals(cyberwareType, equippedType) {
                    emptyIndex = this.m_gridData[slotIndex].GetSlotIndex();
                    break;
                }
            }
        }
        slotIndex -= 1;
    }
    return emptyIndex != -1 ? emptyIndex : (this.m_selectedSlotIndex != -1 ? this.m_selectedSlotIndex : 0);
}

@replaceMethod(gameuiInventoryGameController)
private final func RefreshPlayerCyberware() {
    let player = this.GetPlayerControlledObject();
    let playerData = EquipmentSystem.GetData(player);

    let cyberwareAreas: array<gamedataEquipmentArea>;
    ArrayPush(cyberwareAreas, gamedataEquipmentArea.SystemReplacementCW);
    ArrayPush(cyberwareAreas, gamedataEquipmentArea.ArmsCW);
    ArrayPush(cyberwareAreas, gamedataEquipmentArea.HandsCW);

    let maxSlotWidgets = 3;
    let requiredSlotWidgets = 0;

    ArrayClear(this.m_cyberwareItems);
    let dummyItems: array<InventoryItemData>;

    let i = 0;
    while i < ArraySize(cyberwareAreas) {
        let areaIndex = playerData.GetEquipAreaIndex(cyberwareAreas[i]);
        let slotIndex = 0;
        let numberOfSlots = ArraySize(playerData.m_equipment.equipAreas[areaIndex].equipSlots);
        while slotIndex < numberOfSlots {
            let itemID = playerData.m_equipment.equipAreas[areaIndex].equipSlots[slotIndex].itemID;
            if ItemID.IsValid(itemID) {
                let itemData = this.m_InventoryManager.GetItemDataFromIDInLoadout(itemID);
                let abilities: array<InventoryItemAbility>;
                let attachments: array<ref<InventoryItemAttachments>>;
                this.m_InventoryManager.GetAttachements(player, itemID, itemData.GameItemData, attachments, abilities, false);
                if ArraySize(attachments) > 0 {
                    ArrayPush(this.m_cyberwareItems, itemData);
                    requiredSlotWidgets = ArraySize(this.m_cyberwareItems);
                    if requiredSlotWidgets == maxSlotWidgets {
                        break;
                    }
                } else {
                    ArrayPush(dummyItems, itemData);
                }
            }
            slotIndex += 1;
        }
        i += 1;
    }

    i = 0;
    while requiredSlotWidgets < maxSlotWidgets && i < ArraySize(dummyItems) {
        ArrayPush(this.m_cyberwareItems, dummyItems[i]);
        requiredSlotWidgets += 1;
        i += 1;
    }

    inkCompoundRef.RemoveAllChildren(this.m_cyberwareSlotRootRefs);
    inkWidgetRef.SetVisible(this.m_cyberwareHolder, requiredSlotWidgets > 0);

    if requiredSlotWidgets > 0 {
        i = 0;
        while i < requiredSlotWidgets {
            let slotSpawnData = new CyberwareSlotSpawnData();
            slotSpawnData.index = i;
            ItemDisplayUtils.SpawnCommonSlotAsync(this, this.m_cyberwareSlotRootRefs, n"itemDisplay", n"OnSlotSpawned", slotSpawnData);
            i += 1;
        }
    }
}

@replaceMethod(gameuiInventoryGameController)
protected cb func OnSlotSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    let controller = widget.GetController() as InventoryItemDisplayController;
    let data = userData as CyberwareSlotSpawnData;
    let itemData = this.m_cyberwareItems[data.index];
    controller.Setup(itemData, InventoryItemData.GetEquipmentArea(itemData), "", InventoryItemData.GetSlotIndex(itemData));
}

@replaceMethod(healthbarWidgetGameController)
protected final const func IsCyberdeckEquipped() -> Bool {
    return CyberwareHelper.IsCyberdeckEquipped(this.GetPlayerControlledObject());
}

@wrapMethod(HotkeyConsumableWidgetController)
protected cb func OnInitialize() -> Bool {
    wrappedMethod();

    let container = inkWidgetRef.Get(this.m_container) as inkCompoundWidget;
    container.GetWidgetByIndex(container.GetNumChildren() - 1).SetName(n"Sandevistan");
}

@wrapMethod(HotkeysWidgetController)
protected cb func OnInitialize() -> Bool {
    wrappedMethod();

    this.FixHudSlotSize();
    this.SpawnCyberwareExtraSlots();
}

@addMethod(HotkeysWidgetController)
protected func SpawnCyberwareExtraSlots() {
    let container = inkWidgetRef.Get(this.m_dpadHintsPanel) as inkCompoundWidget;

    let cyberwarePos = 0;
    let cyberwareWidget: wref<inkWidget>;
    let numWidgets = container.GetNumChildren();
    while cyberwarePos < container.GetNumChildren() {
        cyberwareWidget = container.GetWidgetByIndex(cyberwarePos);
        if Equals(cyberwareWidget.GetName(), n"cyberware") {
            break;
        }

        cyberwarePos += 1;
    }

    if cyberwarePos >= numWidgets {
        return;
    }

    let cyberwares = [cyberwareWidget];
    ArrayPush(cyberwares, this.SpawnFromLocal(container, n"cyberware"));
    ArrayPush(cyberwares, this.SpawnFromLocal(container, n"cyberware"));

    let i = 0;
    let cyberwareTypes = [n"Cyberdeck", n"Sandevistan", n"Berserk"];
    while i < ArraySize(cyberwareTypes) {
        cyberwares[i].SetName(cyberwareTypes[i]);
        if i >= 1 {
            container.ReorderChild(cyberwares[i], cyberwarePos + i);
        }
        i += 1;
    }

}

@if(ModuleExists("CustomQuickslots"))
@addMethod(HotkeysWidgetController)
protected func FixHudSlotSize() {}

@if(!ModuleExists("CustomQuickslots"))
@addMethod(HotkeysWidgetController)
protected func FixHudSlotSize() {
    let hudEntryInfo = this.GetRootWidget().GetUserData(n"inkHudEntryInfo") as inkHudEntryInfo;
    hudEntryInfo.size = Vector2(2400, 300);
}

@wrapMethod(InventoryItemDisplayController)
public final func SetPerkRequiredCyberware(area: gamedataEquipmentArea) {
    wrappedMethod(area);

    let perkRecord = CyberwareHelper.GetRequiredPerkRecord(this.m_equipmentArea, this.m_slotIndex);
    if IsDefined(perkRecord) {
        inkImageRef.SetTexturePart(this.m_perkIcon, perkRecord.PerkIcon().AtlasPartName());
    }
}

@wrapMethod(InventoryItemDisplayController)
protected func UpdateLocked() {
    wrappedMethod();

    this.GetRootWidget().SetVisible(!this.m_isLocked || this.m_visibleWhenLocked);
}

@wrapMethod(ItemDisplayUtils)
public final static func SpawnCommonSlotAsync(logicController: ref<inkLogicController>, parent: inkWidgetRef,
                                              slotName: CName, opt callBack: CName, opt userData: ref<IScriptable>) {
    let slotUserData = userData as SlotUserData;
    if IsDefined(slotUserData) && slotUserData.isLocked {
        slotUserData.isPerkRequired = CyberwareHelper.IsPerkRequired(slotUserData.area, slotUserData.index);
    }
    wrappedMethod(logicController, parent, slotName, callBack, userData);
}

@wrapMethod(QuickhacksListGameController)
protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if !this.m_isUILocked && !this.GetPlayerControlledObject().GetHudManager().IsHackingMinigameActive() {
        if ListenerAction.IsButtonJustReleased(action) && ListenerAction.IsAction(action, n"context_help") {
            if QuickHackableHelper.TryToCycleOverclockedState(this.GetPlayerControlledObject()) {
                let dpadAction = new DPADActionPerformed();
                dpadAction.action = EHotkey.LBRB;
                dpadAction.state = EUIActionState.COMPLETED;
                dpadAction.successful = true;

                GameInstance.GetUISystem(this.GetPlayerControlledObject().GetGame()).QueueEvent(dpadAction);
            }

            return false;
        }
    }

    return wrappedMethod(action, consumer);
}

@replaceMethod(QuickhacksListGameController)
private final func ToggleTutorialOverlay() {
}

@if(!ModuleExists("CyberarmOverhaul"))
@replaceMethod(RadialWheelController)
private final func GetValidCombatCyberware() -> InventoryItemData {
    let player = this.GetPlayer();
    let itemID = EquipmentSystem.GetData(player).GetActiveMeleeWare();
    let itemData: InventoryItemData;

    if ItemID.IsValid(itemID) {
        itemData = this.inventoryManager.GetItemDataFromIDInLoadout(itemID);
    }

    return itemData;
}

@wrapMethod(RipperDocGameController)
private final func Init() {
    wrappedMethod();

    let text = new inkText();
    text.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
    text.SetFontStyle(n"Regular");
    text.SetFontSize(28);
    text.SetOpacity(0.1);
    text.SetAnchor(inkEAnchor.TopRight);
    text.SetAnchorPoint(Vector2(1.0, 0.0));
    text.SetMargin(inkMargin(0, 160, 100, 0));
    text.SetHorizontalAlignment(textHorizontalAlignment.Left);
    text.SetVerticalAlignment(textVerticalAlignment.Top);
    text.SetStyle(r"base\\gameplay\\gui\\common\\main_colors.inkstyle");
    text.BindProperty(n"tintColor", n"MainColors.Red");
    text.SetText(s"POWERED BY CYBERWARE-EX \(CyberwareEx.Version())");
    text.Reparent(this.GetRootCompoundWidget());
}

@wrapMethod(RipperDocGameController)
protected cb func OnSlotClick(evt: ref<ItemDisplayClickEvent>) -> Bool {
    if this.m_isActivePanel && IsDefined(evt.uiInventoryItem) && Equals(this.m_hoverArea, gamedataEquipmentArea.EyesCW) {
        if evt.actionName.IsAction(n"unequip_item") && evt.uiInventoryItem.IsEquipped() {
            this.m_isInEquipPopup = true;
            this.UnequipCyberware(evt.uiInventoryItem.GetItemData());
            return false;
        }
    }

    wrappedMethod(evt);
}

@if(!ModuleExists("CyberwareEx.OverrideMode"))
@replaceMethod(RipperDocGameController)
private final func IsEquipmentAreaRequiringPerk(equipmentArea: gamedataEquipmentArea) -> Bool {
    let playerData = EquipmentSystem.GetData(this.GetPlayerControlledObject());
    let visibleWhenLocked: Bool;
    return playerData.IsSlotLocked(
        this.m_hoveredItemDisplay.GetEquipmentArea(),
        this.m_hoveredItemDisplay.GetSlotIndex(),
        visibleWhenLocked
    );
}

@if(!ModuleExists("CyberwareEx.OverrideMode"))
@wrapMethod(RipperDocGameController)
private final func ShowCWPerkTooltip(widget: wref<inkWidget>) {
    if Equals(this.m_dollHoverArea, gamedataEquipmentArea.HandsCW) {
        wrappedMethod(widget);
        return;
    }

    this.m_ripperdocHoverState = RipperdocHoverState.SlotSkeleton;

    let tooltipData = new RipperdocPerkTooltipData();
    tooltipData.equipArea = this.m_hoveredItemDisplay.GetEquipmentArea();
    tooltipData.slotIndex = this.m_hoveredItemDisplay.GetSlotIndex();
    tooltipData.ripperdocHoverState = this.m_ripperdocHoverState;

    this.m_TooltipsManager.ShowTooltipAtWidget(n"RipperdocPerkTooltip", widget, tooltipData,
        gameuiETooltipPlacement.RightTop, false, new inkMargin(this.m_defaultTooltipGap, 0.00, 0.00, 0.00));
}

@if(!ModuleExists("CyberwareEx.OverrideMode"))
@wrapMethod(RipperDocGameController)
protected cb func OnSlotHover(evt: ref<ItemDisplayHoverOverEvent>) -> Bool {
    this.m_hoveredItemDisplay = evt.display;
    wrappedMethod(evt);
}

@if(!ModuleExists("CyberwareEx.OverrideMode"))
@replaceMethod(RipperDocGameController)
private final func GetRequiredPerk(hoverArea: RipperdocHoverState) -> gamedataNewPerkType {
    return CyberwareHelper.GetRequiredPerkType(
        this.m_hoveredItemDisplay.GetEquipmentArea(),
        this.m_hoveredItemDisplay.GetSlotIndex()
    );
}

@if(!ModuleExists("CyberwareEx.OverrideMode"))
@replaceMethod(RipperDocGameController)
private final func OpenPerkTree() {
    let userData = new PerkUserData();
    userData.cyberwareScreenType = this.m_screen;
    userData.statType = CyberwareHelper.GetRequiredPerkStatType(
        this.m_hoveredItemDisplay.GetEquipmentArea(),
        this.m_hoveredItemDisplay.GetSlotIndex()
    );
    userData.perkType = CyberwareHelper.GetRequiredPerkType(
        this.m_hoveredItemDisplay.GetEquipmentArea(),
        this.m_hoveredItemDisplay.GetSlotIndex()
    );

    if Equals(this.m_screen, CyberwareScreenType.Inventory) {
        let evt = new OpenMenuRequest();
        evt.m_menuName = n"new_perks";
        evt.m_isMainMenu = true;
        evt.m_jumpBack = true;
        evt.m_eventData.userData = userData;
        evt.m_eventData.m_overrideDefaultUserData = true;
        this.QueueBroadcastEvent(evt);
    } else {
        this.m_menuEventDispatcher.SpawnEvent(n"OnSwitchToCharacter", userData);
    }
}

@if(ModuleExists("CyberwareEx.OverrideMode"))
@addField(RipperDocGameController)
private let m_overrideManager: ref<OverrideManager>;

@if(ModuleExists("CyberwareEx.OverrideMode"))
@addField(RipperDocGameController)
private let m_overrideConfirmationToken: ref<inkGameNotificationToken>;

@if(ModuleExists("CyberwareEx.OverrideMode"))
@wrapMethod(RipperDocGameController)
private final func Init() {
    wrappedMethod();

    this.m_overrideManager = new OverrideManager();
    this.m_overrideManager.Initialize(EquipmentSystem.GetData(this.m_player));
}

@if(ModuleExists("CyberwareEx.OverrideMode"))
@wrapMethod(RipperDocGameController)
protected cb func OnSlotHover(evt: ref<ItemDisplayHoverOverEvent>) -> Bool {
    wrappedMethod(evt);

    if Equals(this.m_screen, CyberwareScreenType.Ripperdoc) {

        if Equals(this.m_filterMode, RipperdocModes.Default) {
            let overrideState = this.m_overrideManager.GetOverrideState(evt.display.GetEquipmentArea());
            if overrideState.isOverridable {

                if overrideState.currentSlots != overrideState.defaultSlots {
                    this.m_buttonHintsController.AddButtonHint(n"disassemble_item",
                        GetLocalizedText("LocKey#53485") + ": " +
                        GetLocalizedTextByKey(n"UI-ResourceExports-Reset"));
                }

                if overrideState.currentSlots < overrideState.maxSlots {
                    this.m_buttonHintsController.AddButtonHint(n"drop_item",
                        GetLocalizedText("LocKey#53485") + ": " +
                        GetLocalizedTextByKey(n"UI-ResourceExports-Buy"));
                }
            }
        }

    }
}

@if(ModuleExists("CyberwareEx.OverrideMode"))
@wrapMethod(RipperDocGameController)
private final func SetButtonHintsUnhover() {
    wrappedMethod();

    this.m_buttonHintsController.RemoveButtonHint(n"drop_item");
}

@if(ModuleExists("CyberwareEx.OverrideMode"))
@wrapMethod(RipperDocGameController)
protected cb func OnPreviewCyberwareClick(evt: ref<inkPointerEvent>) -> Bool {
    wrappedMethod(evt);

    if Equals(this.m_screen, CyberwareScreenType.Ripperdoc) && Equals(this.m_filterMode, RipperdocModes.Default) {
        let areaType = this.GetCyberwareSlotControllerFromTarget(evt).GetEquipmentArea();
        let overrideState = this.m_overrideManager.GetOverrideState(areaType);

        switch (true) {
            case evt.IsAction(n"drop_item"):
                if overrideState.currentSlots < overrideState.maxSlots {
                    if overrideState.canBuyOverride {
                        this.m_overrideConfirmationToken = OverrideConfirmationPopup.Show(this, OverrideAction.Upgrade, overrideState);
                        this.m_overrideConfirmationToken.RegisterListener(this, n"OnSlotUpgradeConfirmed");
                    } else {
                        this.ShowNotEnoughMoneyNotification();
                    }
                }
                break;
            case evt.IsAction(n"disassemble_item"):
                if overrideState.currentSlots != overrideState.defaultSlots {
                    if overrideState.canBuyReset {
                        this.m_overrideConfirmationToken = OverrideConfirmationPopup.Show(this, OverrideAction.Reset, overrideState);
                        this.m_overrideConfirmationToken.RegisterListener(this, n"OnSlotResetConfirmed");
                    } else {
                        this.ShowNotEnoughMoneyNotification();
                    }
                }
                break;
        }
    }
}

@if(ModuleExists("CyberwareEx.OverrideMode"))
@addMethod(RipperDocGameController)
protected func ShowNotEnoughMoneyNotification() {
    let notification = new UIMenuNotificationEvent();
    notification.m_notificationType = UIMenuNotificationType.VNotEnoughMoney;

    this.QueueEvent(notification);
}

@if(ModuleExists("CyberwareEx.OverrideMode"))
@addMethod(RipperDocGameController)
protected cb func OnSlotUpgradeConfirmed(data: ref<inkGameNotificationData>) -> Bool {
    if OverrideConfirmationPopup.IsConfirmed(data) {
        let areaType = OverrideConfirmationPopup.GetAreaType(data);
        let vendor = NotEquals(this.m_VendorDataManager.GetVendorName(), "")
            ? this.m_VendorDataManager.GetVendorInstance()
            : null;

        this.m_overrideManager.UpgradeSlot(areaType, false, vendor);

        this.UpdateMinigrids();
        this.UpdateMoney();
    }

    this.m_overrideConfirmationToken = null;
}

@if(ModuleExists("CyberwareEx.OverrideMode"))
@addMethod(RipperDocGameController)
protected cb func OnSlotResetConfirmed(data: ref<inkGameNotificationData>) -> Bool {
    if OverrideConfirmationPopup.IsConfirmed(data) {
        let areaType = OverrideConfirmationPopup.GetAreaType(data);
        let vendor = NotEquals(this.m_VendorDataManager.GetVendorName(), "")
            ? this.m_VendorDataManager.GetVendorInstance()
            : null;

        this.m_overrideManager.ResetSlot(areaType, false, vendor);

        this.UpdateMinigrids();
        this.UpdateMoney();
    }

    this.m_overrideConfirmationToken = null;
}

@if(ModuleExists("CyberwareEx.OverrideMode"))
@replaceMethod(RipperDocGameController)
private final func IsEquipmentAreaRequiringPerk(equipmentArea: gamedataEquipmentArea) -> Bool {
    return false;
}

@if(ModuleExists("CyberwareEx.OverrideMode"))
@addMethod(RipperDocGameController)
private final func UpdateMoney() {
    let blackBoardDef = GetAllBlackboardDefs().UI_Vendor;
    let blackBoard = GameInstance.GetBlackboardSystem(this.GetPlayerControlledObject().GetGame()).Get(blackBoardDef);
    blackBoard.SignalVariant(blackBoardDef.VendorData);
}

@wrapMethod(RipperdocMetersArmor)
protected cb func OnInitialize() -> Bool {
    wrappedMethod();

    if IsExtendedMode() || IsOverrideMode() || IsCustomMode() {
        let root = this.GetRootWidget();

        let margin = root.GetMargin();
        margin.right = 370;
        root.SetMargin(margin);
    }
}

@wrapMethod(RipperdocMetersArmor)
protected cb func OnIntroAnimationFinished_METER(proxy: ref<inkAnimProxy>) -> Bool {
    wrappedMethod(proxy);

    if IsExtendedMode() || IsOverrideMode() || IsCustomMode() {
        let root = this.GetRootWidget();
        let parent = root.parentWidget as inkCompoundWidget;
        let wrapper = parent.GetWidget(n"wrapper") as inkCompoundWidget;

        let oldIndex = ArrayFindFirst(parent.children.children, root);
        let newIndex = ArrayFindFirst(wrapper.children.children, wrapper.GetWidget(n"paperDollWrapper")) + 1;
        root.Reparent(wrapper, newIndex);

        let dummy = new inkCanvas();
        parent.AddChildWidget(dummy);
        parent.ReorderChild(dummy, oldIndex);
    }
}

@wrapMethod(RipperdocMetersCapacity)
protected cb func OnInitialize() -> Bool {
    wrappedMethod();

    if IsExtendedMode() || IsOverrideMode() || IsCustomMode() {
        let root = this.GetRootWidget();

        let margin = root.GetMargin();
        margin.left = 240;
        root.SetMargin(margin);
    }
}

@wrapMethod(RipperdocMetersCapacity)
protected cb func OnIntroAnimationFinished_METER(proxy: ref<inkAnimProxy>) -> Bool {
    wrappedMethod(proxy);

    if IsExtendedMode() || IsOverrideMode() || IsCustomMode() {
        let root = this.GetRootWidget();
        let parent = root.parentWidget as inkCompoundWidget;
        let wrapper = parent.GetWidget(n"wrapper") as inkCompoundWidget;

        let oldIndex = ArrayFindFirst(parent.children.children, root);
        let newIndex = ArrayFindFirst(wrapper.children.children, wrapper.GetWidget(n"paperDollWrapper")) + 1;
        root.Reparent(wrapper, newIndex);

        let dummy = new inkCanvas();
        parent.AddChildWidget(dummy);
        parent.ReorderChild(dummy, oldIndex);
    }
}

@wrapMethod(RipperdocMetersCapacity)
private final func ConfigureBar(currentCapacity: Int32, addedCapacity: Int32, maxCapacity: Int32, overclockCapacity: Int32, isChange: Bool) {
    let finalCapacity = currentCapacity + addedCapacity;
    if (finalCapacity > Cast<Int32>(this.m_maxCapacityPossible)) {
        this.m_maxCapacityPossible = Cast<Float>(finalCapacity);
    }

    wrappedMethod(currentCapacity, addedCapacity, maxCapacity, overclockCapacity, isChange);
}

@addField(RipperdocPerkTooltipData)
public let equipArea: gamedataEquipmentArea;

@addField(RipperdocPerkTooltipData)
public let slotIndex: Int32;

@wrapMethod(RipperdocPerkTooltip)
public func SetData(tooltipData: ref<ATooltipData>) {
    let perkTooltipData = tooltipData as RipperdocPerkTooltipData;
    let perkRecord = CyberwareHelper.GetRequiredPerkRecord(perkTooltipData.equipArea, perkTooltipData.slotIndex);
    if IsDefined(perkRecord) {
        let requiredLevel = CyberwareHelper.GetRequiredPerkLevel(perkTooltipData.equipArea, perkTooltipData.slotIndex);
        let maxLevel = CyberwareHelper.GetRequiredPerkMaxLevel(perkTooltipData.equipArea, perkTooltipData.slotIndex);
        let requirementLabel = GetLocalizedText(perkRecord.Loc_name_key());
        if maxLevel > 1 {
            requirementLabel += s"\n(\(GetLocalizedItemNameByCName(n"Gameplay-RPG-Skills-LevelName")) \(requiredLevel))";
        }
        inkTextRef.SetText(this.m_perkName, requirementLabel);
        inkImageRef.SetTexturePart(this.m_perkIcon, perkRecord.PerkIcon().AtlasPartName());
    } else {
        wrappedMethod(tooltipData);
    }
}
