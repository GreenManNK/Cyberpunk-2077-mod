module NightCityAllies.Util

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.Localization.*
import NightCityAllies.Npc.*
import NightCityAllies.Npc.Behavior.*
import NightCityAllies.Animation.*

public class NCAUtil extends ScriptableSystem {
    public func StartPreview(npc: ref<NpcHandle>) -> Void {
        if !IsDefined(npc) {
            return;
        }
        npc.AttachBehavior(NCAPreviewBehavior.Create());
    }

    public func StopPreview(npc: ref<NpcHandle>) -> Void {
        if !IsDefined(npc) {
            return;
        }
        npc.DetachBehavior();
    }

    public func PreviewInteractionAt(npc: ref<NpcHandle>, type: CName, position: Vector4, rotation: Quaternion) -> Bool {
        if !IsDefined(npc) {
            return false;
        }

        let routine: ref<NCARoutine>;
        if !NCA.Animation().GetSoloRoutine(type, npc.GetRig(), routine) {
            return false;
        }

        npc.AttachBehavior(NCAPreviewRoutineBehavior.Create(routine, position, rotation, null));
        return true;
    }

    public func PreviewRoutineAt(npc: ref<NpcHandle>, type: String, tag: String, position: Vector4, rotation: Quaternion) -> Bool {
        if !IsDefined(npc) || !IsStringValid(type) || !IsStringValid(tag) {
            return false;
        }

        let routine = NCA.Animation().GetRoutine(StringToName(type), StringToName(tag));
        if !IsDefined(routine) {
            return false;
        }

        let partner: wref<ScriptedPuppet>;
        if IsStringValid(routine.partnerRig) {
            partner = NCA.Player();
        }

        npc.AttachBehavior(NCAPreviewRoutineBehavior.Create(routine, position, rotation, partner));
        return true;
    }

    public func PreviewAnimationAt(npc: ref<NpcHandle>, animName: String, workspot: String, actorComp: String, deviceComp: String, syncSlot: String, partnerAnimation: String,
                                   partnerForward: Float, partnerRight: Float, partnerUp: Float, partnerYaw: Float,
                                   position: Vector4, rotation: Quaternion) -> Bool {
        if !IsDefined(npc) || !IsStringValid(animName) {
            return false;
        }

        let animation: NCAAnimation;
        animation.animation = animName;
        animation.partnerAnimation = partnerAnimation;

        let binding: NCAWorkspotBinding;
        binding.workspot = workspot;
        binding.actorComp = actorComp;
        binding.deviceComp = deviceComp;
        binding.syncSlot = syncSlot;

        let partner: wref<ScriptedPuppet>;
        if IsStringValid(partnerAnimation) {
            partner = NCA.Player();
        }

        npc.AttachBehavior(NCAPreviewAnimationBehavior.Create(animation, binding, binding,
            position, rotation, partner,
            partnerForward, partnerRight, partnerUp, partnerYaw));
        return true;
    }

    public func GetRig(puppet: wref<ScriptedPuppet>) -> String {
        if !IsDefined(puppet) {
            return "";
        }

        let components: array<ref<IComponent>> = puppet.GetComponents();
        let fallback: String = "";

        let i: Int32 = 0;
        while i < ArraySize(components) {
            let animComp = components[i] as AnimatedComponent;
            if IsDefined(animComp) {
                // base\characters\base_entities\man_base\man_base.rig
                let path: String = ResRef.ToString(ResourceRef.GetPath(animComp.rig));

                if Equals(components[i].GetName(), n"root") && IsStringValid(path) {
                    return path;
                }

                if !IsStringValid(fallback) {
                    fallback = path;
                }
            }
            i += 1;
        }

        return fallback;
    }

    public func GetPlayerRig() -> String {
        return this.GetRig(NCA.Player());
    }

    public func GetPlayerMoney() -> Int32 {
        return GameInstance.GetTransactionSystem(GetGameInstance())
            .GetItemQuantity(GetPlayer(GetGameInstance()), ItemID.FromTDBID(t"Items.money"));
    }

    public func TakePlayerMoney(amount: Int32) -> Void {
        if amount <= 0 {
            return;
        }

        GameInstance.GetTransactionSystem(GetGameInstance())
            .RemoveItem(GetPlayer(GetGameInstance()), ItemID.FromTDBID(t"Items.money"), amount);
    }

    public func IsQuestDone(name: CName) -> Bool {
        let questSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(GetGameInstance());
        let isQuestFinished: Int32 = questSystem.GetFact(name);
        //NCA.CETLog(NameToString(name) + " -> " + ToString(isQuestFinished));
        return isQuestFinished > 0;
    }

    public func RaycastFromPlayerView(out result: Vector3) -> Bool {
        let player = GetPlayer(GetGameInstance());
        let cameraSystem = GameInstance.GetCameraSystem(player.GetGame());
        let spatialQueries = GameInstance.GetSpatialQueriesSystem(player.GetGame());
        let camTransform: Transform;
        if cameraSystem.GetActiveCameraWorldTransform(camTransform) {
            let rayStart = camTransform.position; 
            let rayDir = cameraSystem.GetActiveCameraForward(); 
            let rayEnd = rayStart + (rayDir * 30.0);
            let raycastResult: TraceResult;
            if spatialQueries.SyncRaycastByCollisionGroup(rayStart, rayEnd, n"Static", raycastResult, true, false) {
                //out result: TraceResult
                result = raycastResult.position;
                return true;
            }
            return false;
        }
    }

    public func ArchetypeMultiplier(archetype: gamedataArchetypeType) -> Float {
        switch (archetype) {
            // T1
            case gamedataArchetypeType.AndroidMeleeT1: return 1.0;
            case gamedataArchetypeType.GenericMeleeT1: return 1.0;
            case gamedataArchetypeType.GenericRangedT1: return 1.0;
            case gamedataArchetypeType.NetrunnerT1: return 1.5;

            // T2
            case gamedataArchetypeType.AndroidMeleeT2: return 2.0;
            case gamedataArchetypeType.AndroidRangedT2: return 2.0;
            case gamedataArchetypeType.FastMeleeT2: return 2.0;
            case gamedataArchetypeType.FastRangedT2: return 2.0;
            case gamedataArchetypeType.FastShotgunnerT2: return 2.0;
            case gamedataArchetypeType.GenericMeleeT2: return 2.0;
            case gamedataArchetypeType.GenericRangedT2: return 2.0;
            case gamedataArchetypeType.ShotgunnerT2: return 2.0;
            case gamedataArchetypeType.TechieT2: return 2.0;
            case gamedataArchetypeType.HeavyMeleeT2: return 3.0;
            case gamedataArchetypeType.HeavyRangedT2: return 3.0;
            case gamedataArchetypeType.NetrunnerT2: return 3.0;
            case gamedataArchetypeType.SniperT2: return 3.0;

            // T3
            case gamedataArchetypeType.FastMeleeT3: return 4.0;
            case gamedataArchetypeType.FastRangedT3: return 4.0;
            case gamedataArchetypeType.FastShotgunnerT3: return 4.0;
            case gamedataArchetypeType.FriendlyGenericRangedT3: return 4.0;
            case gamedataArchetypeType.GenericRangedT3: return 4.0;
            case gamedataArchetypeType.ShotgunnerT3: return 4.0;
            case gamedataArchetypeType.TechieT3: return 4.0;
            case gamedataArchetypeType.FastSniperT3: return 5.0;
            case gamedataArchetypeType.HeavyMeleeT3: return 5.0;
            case gamedataArchetypeType.HeavyRangedT3: return 5.0;
            case gamedataArchetypeType.NetrunnerT3: return 5.0;

            default: return 1.0;
        }
    }

    public func ItemName(itemID: TweakDBID) -> String {
        let record = TweakDBInterface.GetItemRecord(itemID);
        if !IsDefined(record) {
            return TDBID.ToStringDEBUG(itemID);
        }

        let name: String = GetLocalizedTextByKey(record.DisplayName());
        if IsStringValid(name) {
            return name;
        }

        return TDBID.ToStringDEBUG(itemID);
    }

    public func GetPlayerLevel() -> Int32 {
        return RoundF(GameInstance.GetStatsSystem(GetGameInstance())
            .GetStatValue(Cast<StatsObjectID>(NCA.Player().GetEntityID()), gamedataStatType.Level));
    }

    public func StringToCompanionType(type: String) -> CompanionType {
        let lowerStr = StrLower(type);
        switch (lowerStr) {
            case "normal":
            case "regular":
                return CompanionType.Regular;
            case "merc":
            case "mercenary":
                return CompanionType.Mercenary;
            case "mech":
            case "android":
            case "robot":
                return CompanionType.Robot;
            case "undefined":
                return CompanionType.Undefined;
            default:
                NCA.CETLog("ERROR Invalid companion type: " + type);           
                return CompanionType.Undefined;
        }
    }

    public func StringToCompanionSpawnState(state: String) -> CompanionSpawnState {
        let lowerStr = StrLower(state);
        switch (lowerStr) {
            case "invalid":
                return CompanionSpawnState.Invalid;
            case "locked":
                return CompanionSpawnState.Locked;
            case "unacquired":
                return CompanionSpawnState.Unacquired;
            case "spawned":
                return CompanionSpawnState.Spawned;
            case "squad":
                return CompanionSpawnState.Squad;
            case "standby":
                return CompanionSpawnState.Standby;
            case "roaming":
                return CompanionSpawnState.Roaming;
            case "unavailable":
                return CompanionSpawnState.Unavailable;
            case "commuting":
                return CompanionSpawnState.Commuting;
            default:
                NCA.CETLog("ERROR Invalid companion spawn state: " + state);
                return CompanionSpawnState.Invalid;
        }
    }

    public func FriendshipLabel(value: Int32) -> String {
        if value < 20 { return NCA.Labels().Stranger(); }
        if value < 40 { return NCA.Labels().Acquaintance(); }
        if value < 60 { return NCA.Labels().Buddy(); }
        if value < 80 { return NCA.Labels().Friend(); }
        return NCA.Labels().Best_friend();
    }

    public func LoveLabel(value: Int32) -> String {
        if value < 20 { return NCA.Labels().Indifferent(); }
        if value < 40 { return NCA.Labels().Curious(); }
        if value < 60 { return NCA.Labels().Attracted(); }
        if value < 80 { return NCA.Labels().In_love(); }
        return NCA.Labels().Devoted();
    }

    public func RarityColor(rarity: gamedataNPCRarity) -> HDRColor {
        switch (rarity) {
            case gamedataNPCRarity.Trash: return new HDRColor(0.8392, 0.8157, 0.8157, 1.0);   // Common
            case gamedataNPCRarity.Weak: return new HDRColor(0.8392, 0.8157, 0.8157, 1.0);    // Common
            case gamedataNPCRarity.Normal: return new HDRColor(0.1137, 0.9294, 0.5137, 1.0);  // Uncommon
            case gamedataNPCRarity.Rare: return new HDRColor(0.1451, 0.4392, 0.8314, 1.0);    // Rare
            case gamedataNPCRarity.Officer: return new HDRColor(0.6157, 0.1686, 0.9608, 1.0); // Epic
            case gamedataNPCRarity.Elite: return new HDRColor(0.9843, 0.5765, 0.1804, 1.0);   // Legendary
            case gamedataNPCRarity.Boss: return new HDRColor(0.9412, 0.7098, 0.2157, 1.0);    // Iconic
            case gamedataNPCRarity.MaxTac: return new HDRColor(0.9412, 0.7098, 0.2157, 1.0);  // Iconic
            default: return new HDRColor(0.8392, 0.8157, 0.8157, 1.0);                        // Common
        }
    }

    public func FindNavmeshPointNear(npc: wref<GameObject>, target: Vector4, snapRadius: Float, out point: Vector4) -> Bool {
        let navigationSystem = GameInstance.GetAINavigationSystem(GetGameInstance());
        if !IsDefined(navigationSystem) || !IsDefined(npc) {
            return false;
        }

        let snapped = navigationSystem.FindPointInSphereForCharacter(target, snapRadius, npc);
        if !Equals(snapped.status, worldNavigationRequestStatus.OK) {
            return false;
        }

        point = snapped.point;
        return true;
    }

    public func Now() -> Float {
        return EngineTime.ToFloat(GameInstance.GetSimTime(GetGameInstance()));
    }

    public func CollectPlayerWeapons() -> array<ItemID> {
        let weapons: array<ItemID>;
        let transactions = GameInstance.GetTransactionSystem(GetGameInstance());

        let carried: array<wref<gameItemData>>;
        transactions.GetItemList(NCA.Player(), carried);

        let i: Int32 = 0;
        while i < ArraySize(carried) {
            let item: wref<gameItemData> = carried[i];
            if item.HasTag(n"Weapon") && !item.HasTag(n"Quest") && !item.HasTag(n"UnequipRestricted")
            && !WeaponObject.IsCyberwareWeapon(item.GetID())
            && !this.IsHeldByPlayer(item.GetID()) { // TODO <- check: does this respect duplicates?
                let id: String = TDBID.ToStringDEBUG(ItemID.GetTDBID(item.GetID()));
                if !StrContains(id, "fists") && !StrContains(id, "Cutscene") {
                    ArrayPush(weapons, item.GetID());
                }
            }
            i += 1;
        }

        return weapons;
    }

    private func IsHeldByPlayer(itemID: ItemID) -> Bool {
        let transactions = GameInstance.GetTransactionSystem(GetGameInstance());
        let player: ref<PlayerPuppet> = NCA.Player();

        let right: ref<ItemObject> = transactions.GetItemInSlot(player, t"AttachmentSlots.WeaponRight");
        let left: ref<ItemObject> = transactions.GetItemInSlot(player, t"AttachmentSlots.WeaponLeft");

        return (IsDefined(right) && right.GetItemID() == itemID)
            || (IsDefined(left) && left.GetItemID() == itemID);
    }
}
