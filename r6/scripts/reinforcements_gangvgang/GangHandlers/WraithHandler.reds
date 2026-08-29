module Gibbon.GR.GangHandlers

import Gibbon.GR.GangData.*
import Gibbon.GR.Settings.GRSettings


public class GRWraithsHandler extends GRGangHandler {
    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void { 
        let game = GetGameInstance();
        this.m_reinforcementData = new GRWraithsData();
        this.m_preventionSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
        this.m_delaySystem = GameInstance.GetDelaySystem(game);
        this.m_settings = GRSettings.GetInstance(game);
        this.m_affiliation = gamedataAffiliation.Wraiths;
        this.m_waveCounterUniqueId = 12000;
        this.m_attitudeGroup = n"wraiths_ow";
    }

    public static func GetInstance(gameInstance: GameInstance) -> ref<GRWraithsHandler> {
        let system: ref<GRWraithsHandler> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"Gibbon.GR.GangHandlers.GRWraithsHandler") as GRWraithsHandler;
        return system;
    }

    public func IsAuthorityFaction() -> Bool {
        return false;
    }


    public func OnCallSuccessCooldownStart() -> Void {
        this.m_delaySystem.DelayCallback(GRWraithsCallSuccessCooldownEndCallback.Create(this), this.GetCallSuccessCooldown(), true);
    }

    public func OnGraceStart() -> Void {
        this.m_delaySystem.DelayCallback(GRWraithsGraceEndCallback.Create(this), this.GetGraceTime(), true);
    }

    public func GetTurfList() -> array<String> {
        return [
            "Badlands"
        ];
    }
}

public class GRWraithsGraceEndCallback extends DelayCallback {
    let handler: wref<GRWraithsHandler>;
    public static func Create(handler: ref<GRWraithsHandler>) -> ref<GRWraithsGraceEndCallback> {
        let self: ref<GRWraithsGraceEndCallback> = new GRWraithsGraceEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnGraceEnd();
  }
}


public class GRWraithsCallSuccessCooldownEndCallback extends DelayCallback {
    let handler: wref<GRWraithsHandler>;
    public static func Create(handler: ref<GRWraithsHandler>) -> ref<GRWraithsCallSuccessCooldownEndCallback> {
        let self: ref<GRWraithsCallSuccessCooldownEndCallback> = new GRWraithsCallSuccessCooldownEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnCallSuccessCooldownEnd();
  }
}