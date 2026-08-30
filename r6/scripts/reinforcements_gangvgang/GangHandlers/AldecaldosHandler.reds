module Gibbon.GR.GangHandlers

import Gibbon.GR.GangData.*
import Gibbon.GR.Settings.GRSettings


public class GRAldecaldosHandler extends GRGangHandler {
    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
        let game = GetGameInstance();
        this.m_reinforcementData = new GRAldecaldosData();
        this.m_preventionSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
        this.m_delaySystem = GameInstance.GetDelaySystem(game);
        this.m_settings = GRSettings.GetInstance(game);
        this.m_affiliation = gamedataAffiliation.Aldecaldos;
        this.m_waveCounterUniqueId = 15000;
        this.m_attitudeGroup = n"aldecaldos_ow";
    }

    public static func GetInstance(gameInstance: GameInstance) -> ref<GRAldecaldosHandler> {
        let system: ref<GRAldecaldosHandler> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"Gibbon.GR.GangHandlers.GRAldecaldosHandler") as GRAldecaldosHandler;
        return system;
    }

    public func IsAuthorityFaction() -> Bool {
        return false;
    }


    public func OnCallSuccessCooldownStart() -> Void {
        this.m_delaySystem.DelayCallback(GRAldecaldosCallSuccessCooldownEndCallback.Create(this), this.GetCallSuccessCooldown(), true);
    }

    public func OnGraceStart() -> Void {
        this.m_delaySystem.DelayCallback(GRAldecaldosGraceEndCallback.Create(this), this.GetGraceTime(), true);
    }

    public func GetTurfList() -> array<String> {
        return [
            "Badlands",
            "RanchoCoronado"
        ];
    }
}

public class GRAldecaldosGraceEndCallback extends DelayCallback {
    let handler: wref<GRAldecaldosHandler>;
    public static func Create(handler: ref<GRAldecaldosHandler>) -> ref<GRAldecaldosGraceEndCallback> {
        let self: ref<GRAldecaldosGraceEndCallback> = new GRAldecaldosGraceEndCallback();
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


public class GRAldecaldosCallSuccessCooldownEndCallback extends DelayCallback {
    let handler: wref<GRAldecaldosHandler>;
    public static func Create(handler: ref<GRAldecaldosHandler>) -> ref<GRAldecaldosCallSuccessCooldownEndCallback> {
        let self: ref<GRAldecaldosCallSuccessCooldownEndCallback> = new GRAldecaldosCallSuccessCooldownEndCallback();
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
