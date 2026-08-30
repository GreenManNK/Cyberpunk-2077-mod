module Gibbon.GR.GangHandlers

import Gibbon.GR.GangData.*
import Gibbon.GR.Settings.*
import Gibbon.GR.Logging.*
import Gibbon.GR.ReinforcementSystem.*

public abstract class GRGangHandler extends ScriptableSystem {
  protected let m_preventionSystem: ref<PreventionSystem>;
  protected let m_delaySystem: ref<DelaySystem>;
  protected let m_settings: ref<GRSettings>;
  protected let m_reinforcementData: ref<GRGangData>;
  protected let m_heatLevel: Int32 = 0;
  protected let m_callsPerformed: Int32 = 0;
  protected let m_waveCounter: Int32 = 0;
  protected let m_waveCounterUniqueId: Int32 = 0;
  protected let m_callSuccessCooldownActive: Bool = false;
  protected let m_gracePeriodStarted: Bool = false;
  protected let m_gracePeriodEnded: Bool = false;

  protected let m_lastCaller: wref<NPCPuppet>;
  protected let m_lastTarget: wref<NPCPuppet>;
  protected let m_lastSecondaryTarget: wref<NPCPuppet>;
  protected let m_lastCallerPosition: Vector4;

  protected let m_isDisabled: Bool = false;
  public let m_affiliation: gamedataAffiliation;
  public let m_attitudeGroup: CName;
  public let m_lastCallAnswered: Bool = true;

  public func GetCallSuccessCooldown() -> Float {
	if (this.m_callsPerformed > this.m_settings.callsLimit) {
		return this.m_settings.callSuccessCooldownMax * 2.0;
	}
    return RandRangeF(this.m_settings.callSuccessCooldownMin, this.m_settings.callSuccessCooldownMax);
  }

  // ABSTRACT METHODS
  public func OnCallSuccessCooldownStart() -> Void;

  public func OnGraceStart() -> Void;

  public func GetTurfList() -> array<String>;

  public func IsAuthorityFaction() -> Bool;

  //promote wref to ref, caller must validate ref when retrieving
  public func GetLastCaller() -> ref<NPCPuppet> {
    return this.m_lastCaller;
  }

  public func GetLastCallerPosition() -> Vector4 {
    return this.m_lastCallerPosition;
  }

  //promote wref to ref, caller must validate ref when retrieving
  public func GetLastTarget() -> ref<NPCPuppet> {
    return  this.m_lastTarget;
  }

  //promote wref to ref, caller must validate ref when retrieving
  public func GetLastSecondaryTarget() -> ref<NPCPuppet> {
    return this.m_lastSecondaryTarget;
  }

  public func GetAttitudeGroup() -> CName {
    return this.m_attitudeGroup;
  }

  public func SetLastCallAnswered(lastCallAnswered: Bool) -> Void {
    this.m_lastCallAnswered = lastCallAnswered;
  }

  public func SetIsDisabled(isDisabled: Bool) -> Void {
    this.m_isDisabled = isDisabled;
  }

  public func ResetGang() -> Void {
    this.m_heatLevel = 0;
    this.m_callsPerformed = 0;
    this.m_waveCounter = 0;
    this.m_gracePeriodEnded = false;
    this.m_gracePeriodStarted = false;
    this.m_callSuccessCooldownActive = false;
    this.m_gracePeriodEnded = false;
    this.m_gracePeriodStarted = false;
	this.m_lastCallAnswered = true;
  }

  public func OnCallSuccessCooldownEnd() -> Void {
    this.m_callSuccessCooldownActive = false;
  }

  public func OnGraceEnd() -> Void {
    this.m_gracePeriodEnded = true;
    this.m_gracePeriodStarted = false;
  }

  public func GetGraceTime() -> Float {
    return RandRangeF(this.m_settings.gracePeriodMin, this.m_settings.gracePeriodMax);
  }

  public func IsConsideredTurf(district: ref<District>) -> Bool {
    return IsDistrictWithinZones(district, this.GetTurfList());
  }

  public func IsAvailableForIntervention() -> Bool {
    return !this.m_isDisabled && !this.m_callSuccessCooldownActive;
  }

  public func HandleReinforcementCall(puppet: ref<NPCPuppet>, target: ref<NPCPuppet>) {
    if this.m_callSuccessCooldownActive {
      return;
    }
    let isTurf = this.IsConsideredTurf(this.m_preventionSystem.GetCurrentDistrict());

    if this.m_heatLevel == 0 {
      this.m_heatLevel = this.m_settings.initialHeat;
    } else if this.m_lastCallAnswered {
      this.m_heatLevel += this.m_settings.heatEscalation;
    }

    this.m_lastCaller = puppet;
    this.m_lastCallerPosition = puppet.GetWorldPosition();
    this.m_lastTarget = target;
    this.m_lastSecondaryTarget = null;

    if this.m_lastCallAnswered {
      this.m_callsPerformed += 1;
	}

    this.m_callSuccessCooldownActive = true;
    this.OnCallSuccessCooldownStart();

	let randomNumber = RandRange(0, 101);
    let reinforcementHeat = randomNumber <= this.m_settings.strongCallChance ? this.m_heatLevel + this.m_settings.strongCallHeatBonus : this.m_heatLevel;

    let isAuthorityFaction = this.IsAuthorityFaction();

    let authorityResponded = false;
    if !isAuthorityFaction && reinforcementHeat >= 2 {
      authorityResponded = GRReinforcementSystem
        .GetInstance(GetGameInstance())
        .TryDispatchAuthority(this.m_preventionSystem.GetCurrentDistrict(), puppet, target, reinforcementHeat);
    }

    let turfCallAnswered = isTurf ? RandRange(0, 101) <= 50 : RandRange(0, 101) <= 15;

    //GRLog(s"Reinforcements arrive: \(this.m_affiliation), \(reinforcementHeat)");
    if !authorityResponded && turfCallAnswered {
      let vehicleCount = RandRange(this.m_settings.minVehiclesPerCall, this.m_settings.maxVehiclesPerCall + 1);
      this
        .SpawnVehicles(
          this
            .m_reinforcementData
            .GetReinforcementsClamped(Min(reinforcementHeat, 20), vehicleCount)
        );
    }

    if this.m_callsPerformed > this.m_settings.callsLimit {
		//soft reset, retaining the call success cooldown
		this.m_heatLevel = 0;
		this.m_callsPerformed = 0;
		this.m_gracePeriodEnded = false;
		this.m_gracePeriodStarted = false;
		this.m_gracePeriodEnded = false;
		this.m_gracePeriodStarted = false;
		this.m_lastCallAnswered = true;
    }
  }

  public func TryCallingReinforcements(puppet: ref<ScriptedPuppet>) -> Bool {
    if this.m_isDisabled {
      return false;
    }

    if this.m_callSuccessCooldownActive {
      return false;
    }

    if !this.IsAuthorityFaction() && GRReinforcementSystem.GetInstance(GetGameInstance()).IsAuthorityInterventionCooldownActive() {
      return false;
    }

    // If grace period hasn't ended yet, start it
    if !this.m_gracePeriodEnded {
      if this.m_gracePeriodStarted {
		//grace period already started
        return false;
      } else {
        this.m_gracePeriodStarted = true;
        this.OnGraceStart();
        return false;
      }
    }

    // no call cooldown or grace period
    return true;
  }

  public func SpawnVehicles(arr: array<TweakDBID>) -> Void {
    let node = new questDynamicSpawnSystemNodeDefinition();
    let nodeType = new questDynamicVehicleSpawn_NodeType();

    nodeType.distanceRange = Vector2(100, 100);

    if RandF() >= 0.5 {
      nodeType.spawnDirectionPreference = questSpawnDirectionPreference.InFront;
    } else {
      nodeType.spawnDirectionPreference = questSpawnDirectionPreference.Behind;
    }

    let tagStr: String = s"GR_\(this.m_affiliation)_\(this.m_waveCounter)";
    nodeType.waveTag = StringToName(tagStr);
    nodeType.VehicleData = arr;
    
    this.m_waveCounter += 1;
    node.id = Cast<Uint16>(this.m_waveCounterUniqueId + this.m_waveCounter);
    node.type = nodeType;

    GameInstance.GetQuestsSystem(GetGameInstance()).ExecuteNode(node);

    this.m_lastCallAnswered = false;
  }

  // called by GRReinforcementSystem when this faction is chosen to bust up a fight between two other gangs
  public func HandleAuthorityIntervention(originalCaller: ref<NPCPuppet>, originalTarget: ref<NPCPuppet>, heat: Int32) -> Void {
    if this.m_callSuccessCooldownActive {
      return;
    }

    this.m_lastCaller = null;
    this.m_lastTarget = originalCaller;
    this.m_lastSecondaryTarget = originalTarget;
    this.m_lastCallerPosition = originalCaller.GetWorldPosition();
    this.m_heatLevel = heat;

    this.m_callSuccessCooldownActive = true;
    this.OnCallSuccessCooldownStart();

    this.SpawnVehicles(this.m_reinforcementData.GetReinforcementsClamped(heat, 4));
    this.m_lastCallAnswered = true;
  }
}

