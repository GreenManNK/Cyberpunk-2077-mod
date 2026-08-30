module Gibbon.GR.GangHandlers

import Gibbon.GR.GangData.*
import Gibbon.GR.Settings.GRSettings


public class GRBarghestHandler extends GRGangHandler {
    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void { 
        let game = GetGameInstance();
        this.m_reinforcementData = new GRBarghestData();
        this.m_preventionSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
        this.m_delaySystem = GameInstance.GetDelaySystem(game);
        this.m_settings = GRSettings.GetInstance(game);
        this.m_affiliation = gamedataAffiliation.Barghest;
        this.m_waveCounterUniqueId = 4000;
        this.m_attitudeGroup = n"kurtz_army_ow";
    }

    public static func GetInstance(gameInstance: GameInstance) -> ref<GRBarghestHandler> {
        let system: ref<GRBarghestHandler> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"Gibbon.GR.GangHandlers.GRBarghestHandler") as GRBarghestHandler;
        return system;
    }

    public func IsAuthorityFaction() -> Bool {
        return true;
    }


    public func OnCallSuccessCooldownStart() -> Void {
        this.m_delaySystem.DelayCallback(GRBarghestCallSuccessCooldownEndCallback.Create(this), this.GetCallSuccessCooldown(), true);
    }

    public func OnGraceStart() -> Void {
        this.m_delaySystem.DelayCallback(GRBarghestGraceEndCallback.Create(this), this.GetGraceTime(), true);
    }

    public func GetTurfList() -> array<String> {
        return [
            "Dogtown"
        ];
    }
}

public class GRBarghestGraceEndCallback extends DelayCallback {
    let handler: wref<GRBarghestHandler>;
    public static func Create(handler: ref<GRBarghestHandler>) -> ref<GRBarghestGraceEndCallback> {
        let self: ref<GRBarghestGraceEndCallback> = new GRBarghestGraceEndCallback();
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


public class GRBarghestCallSuccessCooldownEndCallback extends DelayCallback {
    let handler: wref<GRBarghestHandler>;
    public static func Create(handler: ref<GRBarghestHandler>) -> ref<GRBarghestCallSuccessCooldownEndCallback> {
        let self: ref<GRBarghestCallSuccessCooldownEndCallback> = new GRBarghestCallSuccessCooldownEndCallback();
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