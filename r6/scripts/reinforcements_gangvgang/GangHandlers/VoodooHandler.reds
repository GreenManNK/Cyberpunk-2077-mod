module Gibbon.GR.GangHandlers

import Gibbon.GR.GangData.*
import Gibbon.GR.Settings.GRSettings


public class GRVoodooHandler extends GRGangHandler {
    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void { 
        let game = GetGameInstance();
        this.m_reinforcementData = new GRVoodooData();
        this.m_preventionSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
        this.m_delaySystem = GameInstance.GetDelaySystem(game);
        this.m_settings = GRSettings.GetInstance(game);
        this.m_affiliation = gamedataAffiliation.VoodooBoys;
        this.m_waveCounterUniqueId = 11000;
        this.m_attitudeGroup = n"voodooBoys_ow";
    }

    public static func GetInstance(gameInstance: GameInstance) -> ref<GRVoodooHandler> {
        let system: ref<GRVoodooHandler> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"Gibbon.GR.GangHandlers.GRVoodooHandler") as GRVoodooHandler;
        return system;
    }

    public func IsAuthorityFaction() -> Bool {
        return false;
    }


    public func OnCallSuccessCooldownStart() -> Void {
        this.m_delaySystem.DelayCallback(GRVoodooCallSuccessCooldownEndCallback.Create(this), this.GetCallSuccessCooldown(), true);
    }

    public func OnGraceStart() -> Void {
        this.m_delaySystem.DelayCallback(GRVoodooGraceEndCallback.Create(this), this.GetGraceTime(), true);
    }

    public func GetTurfList() -> array<String> {
        return [
            "WestWindEstate",
            "Coastview"
        ];
    }
}

public class GRVoodooGraceEndCallback extends DelayCallback {
    let handler: wref<GRVoodooHandler>;
    public static func Create(handler: ref<GRVoodooHandler>) -> ref<GRVoodooGraceEndCallback> {
        let self: ref<GRVoodooGraceEndCallback> = new GRVoodooGraceEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnGraceEnd();
  }
}


public class GRVoodooCallSuccessCooldownEndCallback extends DelayCallback {
    let handler: wref<GRVoodooHandler>;
    public static func Create(handler: ref<GRVoodooHandler>) -> ref<GRVoodooCallSuccessCooldownEndCallback> {
        let self: ref<GRVoodooCallSuccessCooldownEndCallback> = new GRVoodooCallSuccessCooldownEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnCallSuccessCooldownEnd();
  }
}