class ImmersiveRippersConditionHandler extends ScriptableService {
    private cb func OnLoad() {
        GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"rippers_default_processing")
            .AddTarget(ResourceTarget.Path(r"base\\quest\\default_dialogs.questphase"));
        GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"rippers_watkab_processing")
            .AddTarget(ResourceTarget.Path(r"base\\open_world\\vendors\\watson\\kabuki\\kabuki_vendors.questphase"));
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"interior_1")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\interior_-33_45_0_0.streamingsector"));
	}	
	private cb func rippers_default_processing(event: ref<ResourceEvent>) {
        let qPhase = event.GetResource() as questQuestPhaseResource;
		let qGraph = qPhase.graph;
		
		for node_0 in qGraph.nodes {
			if node_0 as questNodeDefinition.id == Cast<Uint16>(7) {
				let phase_7 = node_0 as questPhaseNodeDefinition;
				let graph_7 = phase_7.phaseGraph;
				for node_7 in graph_7.nodes {
					if node_7 as questNodeDefinition.id == Cast<Uint16>(37) {
						let phase_7_37 = node_7 as questPhaseNodeDefinition;
						let graph_7_37 = phase_7_37.phaseGraph;
						for node_7_37 in graph_7_37.nodes {
							if node_7_37 as questNodeDefinition.id == Cast<Uint16>(14) {
								let phase_7_37_14 = node_7_37 as questPhaseNodeDefinition;		
								let graph_7_37_14 = phase_7_37_14.phaseGraph;
								for node_7_37_14 in graph_7_37_14.nodes {
									if node_7_37_14 as questNodeDefinition.id == Cast<Uint16>(17) {
										let node_17 = node_7_37_14 as questPauseConditionNodeDefinition;
										let node_17_cond = node_17.condition as questDistanceCondition;
										if IsDefined(node_17_cond){
											let this_cond_type = node_17_cond.type as questDistanceComparison_ConditionType;
											if IsDefined(this_cond_type) {
												this_cond_type.distanceDefinition2.distanceValue = 45;
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
				break;
			}
		}			
    }
	
	private cb func interior_1(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==440)
		{	
			sector.GetNodeSetup(167).SetNodeIndex(Cast<Uint16>(150u)); //medical_container_e_tray_001 -1039.3687 1446.8713
		}
    }	
	
	private cb func rippers_watkab_processing(event: ref<ResourceEvent>) {
        let qPhase = event.GetResource() as questQuestPhaseResource;
		let qGraph = qPhase.graph;
		
		for node_0 in qGraph.nodes {
			if node_0 as questNodeDefinition.id == Cast<Uint16>(3) {
				let phase_3 = node_0 as questPhaseNodeDefinition;
				let graph_3 = phase_3.phaseGraph;
				for node_3 in graph_3.nodes {
					if node_3 as questNodeDefinition.id == Cast<Uint16>(19) {
						let phase_3_19 = node_3 as questPhaseNodeDefinition;
						let graph_3_19 = phase_3_19.phaseGraph;
						for node_3_19_4 in graph_3_19.nodes {
							if node_3_19_4 as questNodeDefinition.id == Cast<Uint16>(4) {
								let node_4 = node_3_19_4 as questPauseConditionNodeDefinition;
								let node_4_cond = node_4.condition as questDistanceCondition;
								if IsDefined(node_4_cond){
									let this_cond_type = node_4_cond.type as questDistanceComparison_ConditionType;
									if IsDefined(this_cond_type) {
										this_cond_type.distanceDefinition2.distanceValue = 45;
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