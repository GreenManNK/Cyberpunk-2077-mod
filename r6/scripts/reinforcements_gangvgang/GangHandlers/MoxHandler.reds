module Gibbon.GR.GangHandlers

import Gibbon.GR.GangData.*
import Gibbon.GR.Settings.GRSettings


public class GRMoxHandler extends GRGangHandler {
    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void { 
        let game = GetGameInstance();
        this.m_reinforcementData = new GRMoxData();
        this.m_preventionSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
        this.m_delaySystem = GameInstance.GetDelaySystem(game);
        this.m_settings = GRSettings.GetInstance(game);
        this.m_affiliation = gamedataAffiliation.TheMox;
        this.m_waveCounterUniqueId = 13000;
        this.m_attitudeGroup = n"friendly";
    }

    public static func GetInstance(gameInstance: GameInstance) -> ref<GRMoxHandler> {
        let system: ref<GRMoxHandler> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"Gibbon.GR.GangHandlers.GRMoxHandler") as GRMoxHandler;
        return system;
    }

    public func IsAuthorityFaction() -> Bool {
        return false;
    }

    public func OnCallSuccessCooldownStart() -> Void {
        this.m_delaySystem.DelayCallback(GRMoxCallSuccessCooldownEndCallback.Create(this), this.GetCallSuccessCooldown(), true);
    }

    public func OnGraceStart() -> Void {
        this.m_delaySystem.DelayCallback(GRMoxEndCallback.Create(this), this.GetGraceTime(), true);
    }

    public func GetTurfList() -> array<String> {
        return ["Kabuki", "CharterHill"];
    }
}

public class GRMoxEndCallback extends DelayCallback {
    let handler: wref<GRMoxHandler>;
    public static func Create(handler: ref<GRMoxHandler>) -> ref<GRMoxEndCallback> {
        let self: ref<GRMoxEndCallback> = new GRMoxEndCallback();
        
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnGraceEnd();
  }
}


public class GRMoxCallSuccessCooldownEndCallback extends DelayCallback {
    let handler: wref<GRMoxHandler>;
    public static func Create(handler: ref<GRMoxHandler>) -> ref<GRMoxCallSuccessCooldownEndCallback> {
        let self: ref<GRMoxCallSuccessCooldownEndCallback> = new GRMoxCallSuccessCooldownEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnCallSuccessCooldownEnd();
  }
}