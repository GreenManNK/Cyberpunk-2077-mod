class PanamRomancedEnhancedConditionHandler extends ScriptableService {
    private cb func OnLoad() {
        GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"panam_default_processing")
            .AddTarget(ResourceTarget.Path(r"base\\quest\\default_dialogs.questphase"));
	}
	
	
	
	private cb func panam_default_processing(event: ref<ResourceEvent>) {
        let qPhase = event.GetResource() as questQuestPhaseResource;
		let qGraph = qPhase.graph;
		
		for node_0 in qGraph.nodes {
			if node_0 as questNodeDefinition.id == Cast<Uint16>(2) {
				let phase_2 = node_0 as questPhaseNodeDefinition;
				let graph_2 = phase_2.phaseGraph;
				for node_2 in graph_2.nodes {
					if node_2 as questNodeDefinition.id == Cast<Uint16>(5) {
						let phase_2_5 = node_2 as questPhaseNodeDefinition;
						let graph_2_5 = phase_2_5.phaseGraph;
						for node_2_5 in graph_2_5.nodes {
							if node_2_5 as questNodeDefinition.id == Cast<Uint16>(5) {
								let phase_2_5_5 = node_2_5 as questPhaseNodeDefinition;	
								let graph_2_5_5 = phase_2_5_5.phaseGraph;		
								for node_2_5_5 in graph_2_5_5.nodes {
									if node_2_5_5 as questNodeDefinition.id == Cast<Uint16>(6) {
										let node_6 = node_2_5_5 as questPauseConditionNodeDefinition;
										let node_6_cond = node_6.condition as questLogicalCondition;
										if IsDefined(node_6_cond){
											for cond in node_6_cond.conditions {
												let this_cond = cond as questDistanceCondition;
												if IsDefined(this_cond) {
													let this_cond_type = this_cond.type as questDistanceComparison_ConditionType;
													if IsDefined(this_cond_type) {
														this_cond_type.distanceDefinition2.distanceValue = 250;
													}
												}
											}
										}	
									}
									if node_2_5_5 as questNodeDefinition.id == Cast<Uint16>(17) {
										let node_17 = node_2_5_5 as questPauseConditionNodeDefinition;
										let node_17_cond = node_17.condition as questLogicalCondition;
										if IsDefined(node_17_cond){
											for cond in node_17_cond.conditions {
												let this_cond = cond as questDistanceCondition;
												if IsDefined(this_cond) {
													let this_cond_type = this_cond.type as questDistanceComparison_ConditionType;
													if IsDefined(this_cond_type) {
														this_cond_type.distanceDefinition2.distanceValue = 250;
													}
												}
											}
										}	
									}
									if node_2_5_5 as questNodeDefinition.id == Cast<Uint16>(18) {
										let node_18 = node_2_5_5 as questPauseConditionNodeDefinition;
										let node_18_cond = node_18.condition as questLogicalCondition;
										if IsDefined(node_18_cond){
											for cond in node_18_cond.conditions {
												let this_cond = cond as questDistanceCondition;
												if IsDefined(this_cond) {
													let this_cond_type = this_cond.type as questDistanceComparison_ConditionType;
													if IsDefined(this_cond_type) {
														this_cond_type.distanceDefinition2.distanceValue = 250;
													}
												}
											}
										}
									}
								}							
							}
							if node_2_5 as questNodeDefinition.id == Cast<Uint16>(21) {
								let phase_2_5_21 = node_2_5 as questPhaseNodeDefinition;	
								let graph_2_5_21 = phase_2_5_21.phaseGraph;		
								for node_2_5_21 in graph_2_5_21.nodes {
									if node_2_5_21 as questNodeDefinition.id == Cast<Uint16>(2) {
										let node_2 = node_2_5_21 as questPauseConditionNodeDefinition;
										let node_2_cond = node_2.condition as questLogicalCondition;
										if IsDefined(node_2_cond){
											for cond in node_2_cond.conditions {
												let this_cond = cond as questDistanceCondition;
												if IsDefined(this_cond) {
													let this_cond_type = this_cond.type as questDistanceComparison_ConditionType;
													if IsDefined(this_cond_type) {
														this_cond_type.distanceDefinition2.distanceValue = 250;
													}
												}
											}
										}
									}
									if node_2_5_21 as questNodeDefinition.id == Cast<Uint16>(10) {
										let node_10 = node_2_5_21 as questPauseConditionNodeDefinition;
									}
									if node_2_5_21 as questNodeDefinition.id == Cast<Uint16>(14) {
										let node_14 = node_2_5_21 as questPauseConditionNodeDefinition;
										let node_14_cond = node_14.condition as questDistanceCondition;
										if IsDefined(node_14_cond) {
											let this_cond_type = node_14_cond.type as questDistanceComparison_ConditionType;
											if IsDefined(this_cond_type) {
												this_cond_type.distanceDefinition2.distanceValue = 250;
											}
										}
									}
								}								
							}
						}
						break;
					}
				}
				break;
			}
		}
    }
}