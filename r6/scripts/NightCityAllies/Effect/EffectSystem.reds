module NightCityAllies.Effect

import NightCityAllies.*
import NightCityAllies.Persistence.*
import NightCityAllies.Npc.*

// `param` is a free-form argument the caller passes along with the subject - the outfit tag for the
// outfit effect, empty for everything else. It is deliberately NOT stored on NCATimer: the timer
// registry is persistent, so a field there would need a save migration, whereas Trigger and Run are
// runtime only and cost nothing.
public abstract class NCAEffect {
    public let id: CName;
    public func Run(opt subject: TweakDBID, opt param: String) -> Void;
}

public class NCAUnlockCharacterEffect extends NCAEffect {
    public static func Create(id: CName) -> ref<NCAUnlockCharacterEffect> {
        let effect = new NCAUnlockCharacterEffect();
        effect.id = id;
        return effect;
    }

    public func Run(opt subject: TweakDBID, opt param: String) -> Void {
        NCA.Persistence().UnlockCharacter(subject);
    }
}

public class NCALockCharacterEffect extends NCAEffect {
    public static func Create(id: CName) -> ref<NCALockCharacterEffect> {
        let effect = new NCALockCharacterEffect();
        effect.id = id;
        return effect;
    }

    public func Run(opt subject: TweakDBID, opt param: String) -> Void {
        NCA.Persistence().LockCharacter(subject);
    }
}

public class NCAReviveEffect extends NCAEffect {
    public static func Create(id: CName) -> ref<NCAReviveEffect> {
        let effect = new NCAReviveEffect();
        effect.id = id;
        return effect;
    }

    public func Run(opt subject: TweakDBID, opt param: String) -> Void {
        NCA.Persistence().SetState(subject, CompanionSpawnState.Standby);
    }
}

public class NCACommuteCompleteEffect extends NCAEffect {
    public static func Create(id: CName) -> ref<NCACommuteCompleteEffect> {
        let effect = new NCACommuteCompleteEffect();
        effect.id = id;
        return effect;
    }

    public func Run(opt subject: TweakDBID, opt param: String) -> Void {
        NCA.NPC().OnFinishCommute(subject);
    }
}


public class NCASpawnEffect extends NCAEffect {
    public static func Create(id: CName) -> ref<NCASpawnEffect> {
        let effect = new NCASpawnEffect();
        effect.id = id;
        return effect;
    }

    public func Run(opt subject: TweakDBID, opt param: String) -> Void {
        NCA.NPC().Spawn(subject);
    }
}

public class NCACommuteEffect extends NCAEffect {
    public static func Create(id: CName) -> ref<NCACommuteEffect> {
        let effect = new NCACommuteEffect();
        effect.id = id;
        return effect;
    }

    public func Run(opt subject: TweakDBID, opt param: String) -> Void {
        NCA.NPC().Commute(subject, 0); // 0 lets the commute work out its own duration
    }
}

// "unlock_merc" in the Lua, which went through NCA:MakeHireable to reach this.
public class NCAMakeHireableEffect extends NCAEffect {
    public static func Create(id: CName) -> ref<NCAMakeHireableEffect> {
        let effect = new NCAMakeHireableEffect();
        effect.id = id;
        return effect;
    }

    public func Run(opt subject: TweakDBID, opt param: String) -> Void {
        NCA.Persistence().SetUnacquired(subject);
    }
}

public class NCAAddFriendshipEffect extends NCAEffect {
    public let amount: Int32;

    public static func Create(id: CName, amount: Int32) -> ref<NCAAddFriendshipEffect> {
        let effect = new NCAAddFriendshipEffect();
        effect.id = id;
        effect.amount = amount;
        return effect;
    }

    public func Run(opt subject: TweakDBID, opt param: String) -> Void {
        NCA.Persistence().AddFriendship(subject, this.amount);
    }
}

public class NCAAddLoveEffect extends NCAEffect {
    public let amount: Int32;

    public static func Create(id: CName, amount: Int32) -> ref<NCAAddLoveEffect> {
        let effect = new NCAAddLoveEffect();
        effect.id = id;
        effect.amount = amount;
        return effect;
    }

    public func Run(opt subject: TweakDBID, opt param: String) -> Void {
        NCA.Persistence().AddLove(subject, this.amount);
    }
}

public class NCALuaEffect extends NCAEffect {
    public let m_index: Int32;

    public static func Create(id: CName, index: Int32) -> ref<NCALuaEffect> {
        let effect = new NCALuaEffect();
        effect.id = id;
        effect.m_index = index;
        return effect;
    }

    public func Run(opt subject: TweakDBID, opt param: String) -> Void {
        NCA.Effect().OnLuaCallback(this.m_index, subject, param);
    }
}

public class NCAChangeOutfitEffect extends NCAEffect {
    public static func Create(id: CName) -> ref<NCAChangeOutfitEffect> {
        let effect = new NCAChangeOutfitEffect();
        effect.id = id;
        return effect;
    }

    public func Run(opt subject: TweakDBID, opt param: String) -> Void {
        if !IsStringValid(param) {
            return;
        }

        let npc: ref<NpcHandle> = NCA.NPC().FindHandle(subject);
        if !IsDefined(npc) || !npc.IsSpawned() || !npc.IsValid() {
            return;
        }

        let outfit: Int32 = npc.GetOutfitForTag(StringToName(param));
        let appearances: array<entTemplateAppearance> = npc.GetAppearances();
        if outfit < 0 || outfit >= ArraySize(appearances) {
            return;
        }

        npc.ChangeAppearance(outfit);
    }
}

public class NCAEffectSystem extends ScriptableSystem {
    private let m_effects: array<ref<NCAEffect>>;
    private let m_luaEffectCounter: Int32;

    public func OnLuaCallback(id: Int32, opt subject: TweakDBID, opt param: String) {} // trigger lua observer

    public func RegisterLuaEffect(id: String) -> Void {
        ArrayPush(this.m_effects, NCALuaEffect.Create(StringToName(id), this.m_luaEffectCounter));
        this.m_luaEffectCounter += 1;
    }

    public func RegisterEffect(effect: ref<NCAEffect>) -> Void {
        ArrayPush(this.m_effects, effect);
    }

    public func GetEffectIds() -> array<String> {
        let result: array<String>;
        let i: Int32 = 0;
        while i < ArraySize(this.m_effects) {
            ArrayPush(result, NameToString(this.m_effects[i].id));
            i += 1;
        };
        return result;
    }

    public func TriggerString(id: String, subject: String, opt param: String) -> Void {
        this.Trigger(StringToName(id), TDBID.Create(subject), param);
    }

    public func Trigger(id: CName, opt subject: TweakDBID, opt param: String) -> Void {
        let i: Int32 = 0;
        while i < ArraySize(this.m_effects) {
            if Equals(this.m_effects[i].id, id) {
                this.m_effects[i].Run(subject, param);
                return;
            };
            i += 1;
        };
        NCA.CETLog("ERROR Effect not found: " + NameToString(id));
    }
}