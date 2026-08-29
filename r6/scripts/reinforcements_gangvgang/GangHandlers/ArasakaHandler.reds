module Gibbon.GR.GangHandlers

import Gibbon.GR.GangData.*
import Gibbon.GR.Settings.GRSettings


public class GRArasakaHandler extends GRGangHandler {
    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void { 
        let game = GetGameInstance();
        this.m_reinforcementData = new GRArasakaData();
        this.m_preventionSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
        this.m_delaySystem = GameInstance.GetDelaySystem(game);
        this.m_settings = GRSettings.GetInstance(game);
        this.m_affiliation = gamedataAffiliation.Arasaka;
        this.m_waveCounterUniqueId = 3000;
        this.m_attitudeGroup = n"arasaka_ow";
    }

    public static func GetInstance(gameInstance: GameInstance) -> ref<GRArasakaHandler> {
        let system: ref<GRArasakaHandler> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"Gibbon.GR.GangHandlers.GRArasakaHandler") as GRArasakaHandler;
        return system;
    }

    public func IsAuthorityFaction() -> Bool {
        return true;
    }


    public func OnCallSuccessCooldownStart() -> Void {
        this.m_delaySystem.DelayCallback(GRArasakaCallSuccessCooldownEndCallback.Create(this), this.GetCallSuccessCooldown(), true);
    }

    public func OnGraceStart() -> Void {
        this.m_delaySystem.DelayCallback(GRArasakaGraceEndCallback.Create(this), this.GetGraceTime(), true);
    }

    public func GetTurfList() -> array<String> {
        return ["Northside","CityCenter", "Arroyo"];
    }
}

public class GRArasakaGraceEndCallback extends DelayCallback {
    let handler: wref<GRArasakaHandler>;
    public static func Create(handler: ref<GRArasakaHandler>) -> ref<GRArasakaGraceEndCallback> {
        let self: ref<GRArasakaGraceEndCallback> = new GRArasakaGraceEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnGraceEnd();
  }
}


public class GRArasakaCallSuccessCooldownEndCallback extends DelayCallback {
    let handler: wref<GRArasakaHandler>;
    public static func Create(handler: ref<GRArasakaHandler>) -> ref<GRArasakaCallSuccessCooldownEndCallback> {
        let self: ref<GRArasakaCallSuccessCooldownEndCallback> = new GRArasakaCallSuccessCooldownEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnCallSuccessCooldownEnd();
  }
}