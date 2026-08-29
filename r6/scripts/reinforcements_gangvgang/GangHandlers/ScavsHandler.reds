module Gibbon.GR.GangHandlers

import Gibbon.GR.GangData.*
import Gibbon.GR.Settings.GRSettings


public class GRScavsHandler extends GRGangHandler {
    private final func OnPlayerAttach(request: ref<PlayerAttachRequest>) -> Void { 
        let game = GetGameInstance();
        this.m_reinforcementData = new GRScavData();
        this.m_preventionSystem = GameInstance.GetScriptableSystemsContainer(game).Get(n"PreventionSystem") as PreventionSystem;
        this.m_delaySystem = GameInstance.GetDelaySystem(game);
        this.m_settings = GRSettings.GetInstance(game);
        this.m_affiliation = gamedataAffiliation.Scavengers;
        this.m_waveCounterUniqueId = 8000;
        this.m_attitudeGroup = n"scavenger_ow";
    }

    public static func GetInstance(gameInstance: GameInstance) -> ref<GRScavsHandler> {
        let system: ref<GRScavsHandler> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"Gibbon.GR.GangHandlers.GRScavsHandler") as GRScavsHandler;
        return system;
    }

    public func IsAuthorityFaction() -> Bool {
        return false;
    }

    public func OnCallSuccessCooldownStart() -> Void {
        this.m_delaySystem.DelayCallback(GRScavCallSuccessCooldownEndCallback.Create(this), this.GetCallSuccessCooldown(), true);
    }

    public func OnGraceStart() -> Void {
        this.m_delaySystem.DelayCallback(GRScavGraceEndCallback.Create(this), this.GetGraceTime(), true);
    }

    public func GetTurfList() -> array<String> {
        return [
            "JapanTown",
            "Northside",
            "Coastview",
            "Dogtown",
            "WestWindEstate"
        ];
    }
}

public class GRScavGraceEndCallback extends DelayCallback {
    let handler: wref<GRScavsHandler>;
    public static func Create(handler: ref<GRScavsHandler>) -> ref<GRScavGraceEndCallback> {
        let self: ref<GRScavGraceEndCallback> = new GRScavGraceEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnGraceEnd();
  }
}


public class GRScavCallSuccessCooldownEndCallback extends DelayCallback {
    let handler: wref<GRScavsHandler>;
    public static func Create(handler: ref<GRScavsHandler>) -> ref<GRScavCallSuccessCooldownEndCallback> {
        let self: ref<GRScavCallSuccessCooldownEndCallback> = new GRScavCallSuccessCooldownEndCallback();
        self.handler = handler;
        return self;
    }

  public func Call() -> Void {
    this.handler.OnCallSuccessCooldownEnd();
  }
}