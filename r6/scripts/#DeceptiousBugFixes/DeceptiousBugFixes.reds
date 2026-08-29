class DeceptiousBugFixesProcessing extends ScriptableService {
    private cb func OnLoad() {
        GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"h10sectorProc")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-22_19_1_0.streamingsector"));
	}

    private cb func h10sectorProc(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;		
		if(sector.GetNodeSetupCount()==830 || sector.GetNodeSetupCount()==846 || sector.GetNodeSetupCount()==827 || sector.GetNodeSetupCount()==843)
		{
			let i = 1;
			while i < 57 {
				let newNodeRef = CreateNodeRef("$/03_night_city/#nightmare_fix/#nightmare_node_" + ((i<10)?("0"+ToString(i)):ToString(i)));
				sector.GetNodeSetup(41+i).SetNodeRef(newNodeRef);
				i += 1;
			}
		}	
    }
}