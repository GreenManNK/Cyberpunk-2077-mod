module Gibbon.GR.GangHandlers

import Gibbon.GR.GangData.*
import Gibbon.GR.Settings.GRSettings


public class GRKangTaoHandler extends GRGangHandler {
    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void {
        let game = GetGameInstance();
        this.m_reinforcementData = new GRKangTaoData();
        this.m_preventionSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
        this.m_delaySystem = GameInstance.GetDelaySystem(game);
        this.m_settings = GRSettings.GetInstance(game);
        this.m_affiliation = gamedataAffiliation.KangTao;
        this.m_waveCounterUniqueId = 14000;
        this.m_attitudeGroup = n"kangtao_ow";
    }

    public static func GetInstance(gameInstance: GameInstance) -> ref<GRKangTaoHandler> {
        let system: ref<GRKangTaoHandler> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"Gibbon.GR.GangHandlers.GRKangTaoHandler") as GRKangTaoHandler;
        return system;
    }

    public func IsAuthorityFaction() -> Bool {
        return true;
    }


    public func OnCallSuccessCooldownStart() -> Void {
        this.m_delaySystem.DelayCallback(GRKangTaoCallSuccessCooldownEndCallback.Create(this), this.GetCallSuccessCooldown(), true);
    }

    public func OnGraceStart() -> Void {
        this.m_delaySystem.DelayCallback(GRKangTaoGraceEndCallback.Create(this), this.GetGraceTime(), true);
    }

    public func GetTurfList() -> array<String> {
        return ["CityCenter", "Wellsprings"];
    }
}

public class GRKangTaoGraceEndCallback extends DelayCallback {
    let handler: wref<GRKangTaoHandler>;
    public static func Create(handler: ref<GRKangTaoHandler>) -> ref<GRKangTaoGraceEndCallback> {
        let self: ref<GRKangTaoGraceEndCallback> = new GRKangTaoGraceEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnGraceEnd();
  }
}


public class GRKangTaoCallSuccessCooldownEndCallback extends DelayCallback {
    let handler: wref<GRKangTaoHandler>;
    public static func Create(handler: ref<GRKangTaoHandler>) -> ref<GRKangTaoCallSuccessCooldownEndCallback> {
        let self: ref<GRKangTaoCallSuccessCooldownEndCallback> = new GRKangTaoCallSuccessCooldownEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnCallSuccessCooldownEnd();
  }
}
