module Gibbon.GR.GangHandlers

import Gibbon.GR.GangData.*
import Gibbon.GR.Settings.GRSettings


public class GRAnimalsHandler extends GRGangHandler {
    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void { 
        let game = GetGameInstance();
        this.m_reinforcementData = new GRAnimalsData();
        this.m_preventionSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
        this.m_delaySystem = GameInstance.GetDelaySystem(game);
        this.m_settings = GRSettings.GetInstance(game);
        this.m_affiliation = gamedataAffiliation.Animals;
        this.m_waveCounterUniqueId = 2000;
        this.m_attitudeGroup = n"animals_ow";
    }

    public static func GetInstance(gameInstance: GameInstance) -> ref<GRAnimalsHandler> {
        let system: ref<GRAnimalsHandler> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"Gibbon.GR.GangHandlers.GRAnimalsHandler") as GRAnimalsHandler;
        return system;
    }

    public func IsAuthorityFaction() -> Bool {
        return false;
    }

 


    public func OnCallSuccessCooldownStart() -> Void {
        this.m_delaySystem.DelayCallback(GRAnimalsCallSuccessCooldownEndCallback.Create(this), this.GetCallSuccessCooldown(), true);
    }

    public func OnGraceStart() -> Void {
        this.m_delaySystem.DelayCallback(GRAnimalsGraceEndCallback.Create(this), this.GetGraceTime(), true);
    }

    public func GetTurfList() -> array<String> {
        return [
            "WestWindEstate",
            "Coastview"
        ];
    }
}

public class GRAnimalsGraceEndCallback extends DelayCallback {
    let handler: wref<GRAnimalsHandler>;
    public static func Create(handler: ref<GRAnimalsHandler>) -> ref<GRAnimalsGraceEndCallback> {
        let self: ref<GRAnimalsGraceEndCallback> = new GRAnimalsGraceEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnGraceEnd();
  }
}


public class GRAnimalsCallSuccessCooldownEndCallback extends DelayCallback {
    let handler: wref<GRAnimalsHandler>;
    public static func Create(handler: ref<GRAnimalsHandler>) -> ref<GRAnimalsCallSuccessCooldownEndCallback> {
        let self: ref<GRAnimalsCallSuccessCooldownEndCallback> = new GRAnimalsCallSuccessCooldownEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnCallSuccessCooldownEnd();
  }
}