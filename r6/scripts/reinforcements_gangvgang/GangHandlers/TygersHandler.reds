module Gibbon.GR.GangHandlers

import Gibbon.GR.GangData.*
import Gibbon.GR.Settings.GRSettings


public class GRTygersHandler extends GRGangHandler {
    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void { 
        let game = GetGameInstance();
        this.m_reinforcementData = new GRTygerData();
        this.m_preventionSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
        this.m_delaySystem = GameInstance.GetDelaySystem(game);
        this.m_settings = GRSettings.GetInstance(game);
        this.m_affiliation = gamedataAffiliation.TygerClaws;
        this.m_waveCounterUniqueId = 9000;
        this.m_attitudeGroup = n"tygerClaws_ow";
    }

    public static func GetInstance(gameInstance: GameInstance) -> ref<GRTygersHandler> {
        let system: ref<GRTygersHandler> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"Gibbon.GR.GangHandlers.GRTygersHandler") as GRTygersHandler;
        return system;
    }

    public func IsAuthorityFaction() -> Bool {
        return false;
    }

    public func OnCallSuccessCooldownStart() -> Void {
        this.m_delaySystem.DelayCallback(GRTygerCallSuccessCooldownEndCallback.Create(this), this.GetCallSuccessCooldown(), true);
    }

    public func OnGraceStart() -> Void {
        this.m_delaySystem.DelayCallback(GRTygerEndCallback.Create(this), this.GetGraceTime(), true);
    }

    public func GetTurfList() -> array<String> {
        return ["Westbrook", "Kabuki"];
    }
}

public class GRTygerEndCallback extends DelayCallback {
    let handler: wref<GRTygersHandler>;
    public static func Create(handler: ref<GRTygersHandler>) -> ref<GRTygerEndCallback> {
        let self: ref<GRTygerEndCallback> = new GRTygerEndCallback();
        
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


public class GRTygerCallSuccessCooldownEndCallback extends DelayCallback {
    let handler: wref<GRTygersHandler>;
    public static func Create(handler: ref<GRTygersHandler>) -> ref<GRTygerCallSuccessCooldownEndCallback> {
        let self: ref<GRTygerCallSuccessCooldownEndCallback> = new GRTygerCallSuccessCooldownEndCallback();
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