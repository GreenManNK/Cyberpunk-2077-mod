@wrapMethod(ReactionManagerComponent)
  private final func ProcessReactionOutput(stimData: ref<StimEventTaskData>, stimParams: StimParams) -> Void {
    let driverInstigator: ref<GameObject>;
    let grenade: ref<BaseGrenade>;
    let isDuplicateReaction: Bool;
    let vehicle: ref<VehicleObject>;
    let owner: ref<GameObject> = this.GetOwner();
    let ownerPuppet: ref<ScriptedPuppet> = this.GetOwnerPuppet();
    let stimEvent: ref<StimuliEvent> = stimData.cachedEvt;
	let instigatorPuppet: ref<ScriptedPuppet> = stimEvent.sourceObject as ScriptedPuppet;
    let reactionData: ref<AIReactionData> = this.m_desiredReaction;
	if ownerPuppet.IsPrevention()  && instigatorPuppet.IsPlayer() {
      stimParams.reactionOutput.reactionBehavior = gamedataOutput.Ignore;
      };
	  wrappedMethod(stimData, stimParams);
	}

@replaceMethod(AIActionHelper)
  public final static func TryChangingAttitudeToHostile(owner: ref<ScriptedPuppet>, target: ref<GameObject>) -> Bool {
    let currentAttitude: EAIAttitude;
    let attitudeOwner: ref<AttitudeAgent> = owner.GetAttitudeAgent();
    let attitudeTarget: ref<AttitudeAgent> = target.GetAttitudeAgent();
    if !target.IsPuppet() && !target.IsSensor() {
      return false;
    };
    if !target.IsActive() {
      return false;
    };
	if IsDefined(attitudeOwner) && IsDefined(attitudeTarget) {
      currentAttitude = attitudeOwner.GetAttitudeTowards(attitudeTarget);
      switch currentAttitude {
        case EAIAttitude.AIA_Friendly:
          return false;
        case EAIAttitude.AIA_Hostile:
          return true;
		default:
		  if owner.IsAggressive() && !target.IsPlayer(){
            attitudeOwner.SetAttitudeTowardsAgentGroup(attitudeTarget, attitudeOwner, EAIAttitude.AIA_Hostile);
            return true;
          };
		  if owner.IsPrevention() && target.IsPlayer(){return false; };
		  if owner.IsAggressive() {
            attitudeOwner.SetAttitudeTowardsAgentGroup(attitudeTarget, attitudeOwner, EAIAttitude.AIA_Hostile);
            return true;
          };		  
      };
      return false;
    };
    return false;
  }