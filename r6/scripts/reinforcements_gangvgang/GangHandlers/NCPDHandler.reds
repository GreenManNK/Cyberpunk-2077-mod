module Gibbon.GR.GangHandlers

import Gibbon.GR.GangData.*
import Gibbon.GR.Settings.GRSettings
import Gibbon.GR.ReinforcementSystem.*


public class GRNCPDHandler extends GRGangHandler {
    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void { 
        let game = GetGameInstance();
        this.m_reinforcementData = new GRNCPDData();
        this.m_preventionSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
        this.m_delaySystem = GameInstance.GetDelaySystem(game);
        this.m_settings = GRSettings.GetInstance(game);
        this.m_affiliation = gamedataAffiliation.NCPD;
        this.m_waveCounterUniqueId = 7000;
        this.m_attitudeGroup = n"police";
    }

    public static func GetInstance(gameInstance: GameInstance) -> ref<GRNCPDHandler> {
        let system: ref<GRNCPDHandler> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"Gibbon.GR.GangHandlers.GRNCPDHandler") as GRNCPDHandler;
        return system;
    }

    public func IsAuthorityFaction() -> Bool {
        return true;
    }


    public func OnCallSuccessCooldownStart() -> Void {
        this.m_delaySystem.DelayCallback(GRNCPDCallSuccessCooldownEndCallback.Create(this), this.GetCallSuccessCooldown(), true);
    }

    public func OnGraceStart() -> Void {
        this.m_delaySystem.DelayCallback(GRNCPDGraceEndCallback.Create(this), this.GetGraceTime(), true);
    }

    public func GetTurfList() -> array<String> {
        return ["CityCenter", "Watson", "Westbrook", "Heywood", "SantoDomingo"];
    }
}

public class GRNCPDGraceEndCallback extends DelayCallback {
    let handler: wref<GRNCPDHandler>;
    public static func Create(handler: ref<GRNCPDHandler>) -> ref<GRNCPDGraceEndCallback> {
        let self: ref<GRNCPDGraceEndCallback> = new GRNCPDGraceEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnGraceEnd();
  }
}


public class GRNCPDCallSuccessCooldownEndCallback extends DelayCallback {
    let handler: wref<GRNCPDHandler>;
    public static func Create(handler: ref<GRNCPDHandler>) -> ref<GRNCPDCallSuccessCooldownEndCallback> {
        let self: ref<GRNCPDCallSuccessCooldownEndCallback> = new GRNCPDCallSuccessCooldownEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnCallSuccessCooldownEnd();
  }
}