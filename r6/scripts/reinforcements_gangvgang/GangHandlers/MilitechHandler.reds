module Gibbon.GR.GangHandlers

import Gibbon.GR.GangData.*
import Gibbon.GR.Settings.GRSettings


public class GRMilitechHandler extends GRGangHandler {
    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void { 
        let game = GetGameInstance();
        this.m_reinforcementData = new GRMilitechData();
        this.m_preventionSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
        this.m_delaySystem = GameInstance.GetDelaySystem(game);
        this.m_settings = GRSettings.GetInstance(game);
        this.m_affiliation = gamedataAffiliation.Militech;
        this.m_waveCounterUniqueId = 6000;
        this.m_attitudeGroup = n"militech_ow";
    }

    public static func GetInstance(gameInstance: GameInstance) -> ref<GRMilitechHandler> {
        let system: ref<GRMilitechHandler> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"Gibbon.GR.GangHandlers.GRMilitechHandler") as GRMilitechHandler;
        return system;
    }

    public func IsAuthorityFaction() -> Bool {
        return true;
    }

    public func OnCallSuccessCooldownStart() -> Void {
        this.m_delaySystem.DelayCallback(GRMilitechCallSuccessCooldownEndCallback.Create(this), this.GetCallSuccessCooldown(), true);
    }

    public func OnGraceStart() -> Void {
        this.m_delaySystem.DelayCallback(GRMilitechGraceEndCallback.Create(this), this.GetGraceTime(), true);
    }

    public func GetTurfList() -> array<String> {
        return [
            "Badlands", "CityCenter", "NorthBadlands", "SouthBadlands"
        ];
    }
}

public class GRMilitechGraceEndCallback extends DelayCallback {
    let handler: wref<GRMilitechHandler>;
    public static func Create(handler: ref<GRMilitechHandler>) -> ref<GRMilitechGraceEndCallback> {
        let self: ref<GRMilitechGraceEndCallback> = new GRMilitechGraceEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnGraceEnd();
  }
}


public class GRMilitechCallSuccessCooldownEndCallback extends DelayCallback {
    let handler: wref<GRMilitechHandler>;
    public static func Create(handler: ref<GRMilitechHandler>) -> ref<GRMilitechCallSuccessCooldownEndCallback> {
        let self: ref<GRMilitechCallSuccessCooldownEndCallback> = new GRMilitechCallSuccessCooldownEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnCallSuccessCooldownEnd();
  }
}