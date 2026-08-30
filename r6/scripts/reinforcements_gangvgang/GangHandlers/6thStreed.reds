module Gibbon.GR.GangHandlers

import Gibbon.GR.GangData.*
import Gibbon.GR.Settings.GRSettings


public class GRSixthStreetHandler extends GRGangHandler {
    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void { 
        let game = GetGameInstance();
        this.m_reinforcementData = new GRSixthStreetData();
        this.m_preventionSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
        this.m_delaySystem = GameInstance.GetDelaySystem(game);
        this.m_settings = GRSettings.GetInstance(game);
        this.m_affiliation = gamedataAffiliation.SixthStreet;
        this.m_waveCounterUniqueId = 1000;
		this.m_attitudeGroup = n"6thStreet_ow";
    }

    public static func GetInstance(gameInstance: GameInstance) -> ref<GRSixthStreetHandler> {
        let system: ref<GRSixthStreetHandler> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"Gibbon.GR.GangHandlers.GRSixthStreetHandler") as GRSixthStreetHandler;
        return system;
    }

    public func IsAuthorityFaction() -> Bool {
        return false;
    }


    public func OnCallSuccessCooldownStart() -> Void {
        this.m_delaySystem.DelayCallback(GRSixthCallSuccessCooldownEndCallback.Create(this), this.GetCallSuccessCooldown(), true);
    }

    public func OnGraceStart() -> Void {
        this.m_delaySystem.DelayCallback(GRSixthGraceEndCallback.Create(this), this.GetGraceTime(), true);
    }

    public func GetTurfList() -> array<String> {
        return [
            "SantoDomingo"
        ];
    }
}

public class GRSixthGraceEndCallback extends DelayCallback {
    let handler: wref<GRSixthStreetHandler>;
    public static func Create(handler: ref<GRSixthStreetHandler>) -> ref<GRSixthGraceEndCallback> {
        let self: ref<GRSixthGraceEndCallback> = new GRSixthGraceEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    if !IsDefined(this.handler) {
      return;
    }
    this.handler.OnGraceEnd();
  }
}


public class GRSixthCallSuccessCooldownEndCallback extends DelayCallback {
    let handler: wref<GRSixthStreetHandler>;
    public static func Create(handler: ref<GRSixthStreetHandler>) -> ref<GRSixthCallSuccessCooldownEndCallback> {
        let self: ref<GRSixthCallSuccessCooldownEndCallback> = new GRSixthCallSuccessCooldownEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    if !IsDefined(this.handler) {
      return;
    }
    this.handler.OnCallSuccessCooldownEnd();
  }
}