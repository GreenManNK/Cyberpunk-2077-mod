class NightCityInteractionsProcessing extends ScriptableService {
    private cb func OnLoad() {
        GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_exterior_1")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-16_-19_0_0.streamingsector"));
        GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_exterior_2")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-2_-17_0_1.streamingsector"));
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_exterior_3")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-16_-25_0_0.streamingsector"));
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_exterior_4")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_9_-5_0_1.streamingsector"));
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_exterior_5")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-23_-1_0_0.streamingsector"));
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_exterior_6")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-12_-1_0_1.streamingsector"));
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_santo_int")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\interior_-2_-17_0_2.streamingsector"));
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_heywood_polo")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-12_-9_0_1.streamingsector"));
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_heywood_cojo")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-10_-8_0_1.streamingsector"));
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_city_hell")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-30_-1_0_0.streamingsector"));
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_city_park")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-25_-6_-1_0.streamingsector"));
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_city_subway")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-11_-1_0_1.streamingsector"));
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_city_solo_3")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-16_2_0_1.streamingsector"));
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_city_solo_2")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-27_-1_0_0.streamingsector"));
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_city_green_1")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-19_3_0_1.streamingsector"));
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_city_green_2")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-38_7_0_0.streamingsector"));
		GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"proc_badlands_solo_1")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_9_-5_0_1.streamingsector"));
	}
	
    private cb func proc_exterior_1(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;		
		let newNodeRef = CreateNodeRef("");
		if(sector.GetNodeSetupCount()==977)
		{
			sector.GetNodeSetup(20).SetNodeRef(newNodeRef); //16969418642593042283
			sector.GetNodeSetup(28).SetNodeRef(newNodeRef); //16969425239662811549
			sector.GetNodeSetup(29).SetNodeRef(newNodeRef); //16969424140151183338
			sector.GetNodeSetup(12).SetNodeRef(newNodeRef); //16969417543081414072
		}	
    }	
	
    private cb func proc_exterior_2(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==907)
		{		
			let nodes = sector.GetNodes();
			let node_1 = nodes[91] as worldAISpotNode;
			if IsDefined(node_1){
				//{std_rcr_piez_restaurant_ma}_057
				let new_spot_1 = new AIActionSpot();
				new_spot_1.resource *= r"base\\workspots\\common\\ground\\generic__stand_ground__look_at_products__01.workspot";
				new_spot_1.useClippingSpace = false;
			
				node_1.spot = new_spot_1;
				
			}
			let node_2 = nodes[99] as worldAISpotNode;
			if IsDefined(node_2){
				//{std_rcr_piez_restaurant_ma}_046
				let new_spot_2 = new AIActionSpot();
				new_spot_2.resource *= r"base\\workspots\\common\\ground\\generic__stand_ground__look_at_products__03.workspot";
				new_spot_2.useClippingSpace = false;
			
				node_2.spot = new_spot_2;
				
			}
		}	
    }
    private cb func proc_exterior_3(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==3159)
		{			
			let nodes = sector.GetNodes();
			let node_1 = nodes[79] as worldAISpotNode;
			if IsDefined(node_1){
				//{crowd_ws_table}
				let new_spot_1 = new AIActionSpot();
				new_spot_1.resource *= r"base\\workspots\\common\\ground\\generic__stand_ground__phone_use__01.workspot";
				new_spot_1.useClippingSpace = false;
			
				node_1.spot = new_spot_1;
				
			}
			let node_2 = nodes[105] as worldAISpotNode;
			if IsDefined(node_2){
				//{crowd_ws_table}_003
				let new_spot_2 = new AIActionSpot();
                new_spot_2.resource *= r"base\\workspots\\common\\ground\\generic__stand_ground_fries_cone__eat__01.workspot";
				new_spot_2.useClippingSpace = false;
			
				node_2.spot = new_spot_2;
				
			}
		}	
    }
    private cb func proc_exterior_4(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==665)
		{			
			let nodes = sector.GetNodes();
			let node_1 = nodes[75] as worldAISpotNode;
			if IsDefined(node_1){
				//{crowd_ws_barstool}_001
				let new_spot_1 = new AIActionSpot();
				new_spot_1.resource *= r"base\\workspots\\common\\chair\\generic__sit_chair__sit_around__03.workspot";                  
				new_spot_1.useClippingSpace = false;
			
				node_1.spot = new_spot_1;
				
			}
		}	
    }
    private cb func proc_exterior_5(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==1089)
		{			
			let nodes = sector.GetNodes();
			let node_1 = nodes[5] as worldAISpotNode;
			if IsDefined(node_1){
				//{crowd_ws_sit}_003
				let new_spot_1 = node_1.spot as AIActionSpot;
				
				new_spot_1.useClippingSpace = false;
			
				node_1.spot = new_spot_1;
				
			}
		}	
    }
    private cb func proc_exterior_6(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==1126)
		{	
			let nodes = sector.GetNodes();	
			let node_1 = nodes[53] as worldAISpotNode;	//{crowd_ws_sit}_002
			let new_pos_1 = new Vector4(-1426.9891, -20.302017, 7.894264, 0);
			let new_rot_1 = new Quaternion(0, 0, 0.051194467, 0.99868876);
						
			if IsDefined(node_1){
						
				let new_spot_1 = new AIActionSpot();
				new_spot_1.resource *= r"base\\workspots\\common\\ground\\generic__stand_ground__phone_use__01.workspott";                  
				new_spot_1.useClippingSpace = false;
			
				node_1.spot = new_spot_1;
				
				sector.GetNodeSetup(53).SetPosition(new_pos_1);
				sector.GetNodeSetup(53).SetOrientation(new_rot_1);
			}
		}	
    }
	
	
	private cb func proc_santo_int(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==58)
		{				
			let nodes = sector.GetNodes();	
			let node_1 = nodes[0] as worldAISpotNode;	//{crowd_ws_chair_}04
			let new_pos_1 = new Vector4(-207.280228, -2054.93555, 6.69784546, 0);
			let new_rot_1 = new Quaternion(0, 0, -0.432904571, -0.901439726);
			
			let node_2 = nodes[4] as worldAISpotNode;	//{crowd_ws_chair_}01
			let new_pos_2 = new Vector4(-206.155838, -2053.27319, 6.69793701, 0);
			let new_rot_2 = new Quaternion(0, 0, -0.432904571, -0.901439726);
			
			if IsDefined(node_1){
						
				let new_spot_1 = new AIActionSpot();
				new_spot_1.resource *= r"base\\workspots\\common\\ground\\generic__stand_ground__look_at_products__01.workspot";                  
				new_spot_1.useClippingSpace = false;
			
				node_1.spot = new_spot_1;
				
				sector.GetNodeSetup(7).SetPosition(new_pos_1);
				sector.GetNodeSetup(7).SetOrientation(new_rot_1);
			}
			if IsDefined(node_2){
			
				let new_spot_2 = new AIActionSpot();
				new_spot_2.resource *= r"base\\workspots\\common\\ground\\generic__stand_ground__look_at_products__03.workspot";                  
				new_spot_2.useClippingSpace = false;
			
				node_2.spot = new_spot_2;
				sector.GetNodeSetup(9).SetPosition(new_pos_2);
				sector.GetNodeSetup(9).SetOrientation(new_rot_2);	
				
			}
		}	
    }
	private cb func proc_heywood_polo(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==3479)
		{				
			let nodes = sector.GetNodes();	
			let node_1 = nodes[93] as worldAISpotNode;	
			let new_pos_1 = new Vector4(-1519.63806, -1106.45569, 9.14746094, 0);
			//{gle_04_ws_crowd_bar_night_}_003
			if IsDefined(node_1){
						
				let new_spot_1 = new AIActionSpot();
				new_spot_1.resource *= r"base\\workspots\\common\\wall\\dirt__stand_wall_lean_back_cigarette__smoke__01.workspot";                  
				new_spot_1.useClippingSpace = false;
			
				node_1.spot = new_spot_1;
				
				sector.GetNodeSetup(98).SetPosition(new_pos_1);
			}
		}	
    }
	private cb func proc_heywood_cojo(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==2049)
		{				
			let nodes = sector.GetNodes();	
			let node_1 = nodes[111] as worldAISpotNode;	
			let new_pos_1 = new Vector4(-1252.62952, -1000.4314, 12.417244, 0);
			let new_rot_1 = new Quaternion(0, 0, 0.707000017, 0.707000017);						
			//{bar_slacker_male}
			if IsDefined(node_1){
						
				let new_spot_1 = new AIActionSpot();
				new_spot_1.resource *= r"base\\workspots\\bar\\bar\\generic__stand_bar_whisky__drink__01.workspot";                  
				new_spot_1.useClippingSpace = false;
			
				node_1.spot = new_spot_1;
				
				sector.GetNodeSetup(111).SetPosition(new_pos_1);
				sector.GetNodeSetup(111).SetOrientation(new_rot_1);
			}
		}	
    }
	private cb func proc_city_hell(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==654)
		{				
			let nodes = sector.GetNodes();	
			let node_1 = nodes[10] as worldAISpotNode;	//{dtn_02_ws_crowd_client_parter_table_11__}_007
			let new_pos_1 = new Vector4(-1924.3259, -28.37085, -0.5353775, 0);
			let new_rot_1 = new Quaternion(0, 0, 0.9398345, 0.34163034);						
			
			if IsDefined(node_1){
						
				let new_spot_1 = new AIActionSpot();
				new_spot_1.resource *= r"base\\workspots\\common\\ground\\generic__stand_ground__phone_use__01.workspot";                  
				new_spot_1.useClippingSpace = false;
			
				node_1.spot = new_spot_1;
				
				sector.GetNodeSetup(10).SetPosition(new_pos_1);
				sector.GetNodeSetup(10).SetOrientation(new_rot_1);
			}
			
			let node_2 = nodes[11] as worldAISpotNode;	//{dtn_02_ws_crowd_client_parter_table_11__}_006
			let new_pos_2 = new Vector4(-1943.3253, -56.546425, -0.5343094, 0);
			let new_rot_2 = new Quaternion(0, 0, 0.53944665, -0.8420198);						
			
			if IsDefined(node_2){
						
				let new_spot_2 = new AIActionSpot();
				new_spot_2.resource *= r"base\\workspots\\common\\ground\\generic__stand_ground__phone_use__01.workspot";                  
				new_spot_2.useClippingSpace = false;
			
				node_2.spot = new_spot_2;
				
				sector.GetNodeSetup(11).SetPosition(new_pos_1);
				sector.GetNodeSetup(11).SetOrientation(new_rot_1);
			}
		}	
    }	
	private cb func proc_city_park(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==321)
		{				
			let nodes = sector.GetNodes();	
			let node_1 = nodes[2] as worldAISpotNode;	//{crowd_ws_barstool_}01
			let new_pos_1 = new Vector4(-1551.2231, -316.96628, -4.530365, 0);
			let new_rot_1 = new Quaternion(0, 0, -0.9695605, 0.24485223);						
			
			if IsDefined(node_1){
						
				let new_spot_1 = new AIActionSpot();
				new_spot_1.resource *= r"base\\workspots\\common\\ground\\generic__stand_ground__phone_use__01.workspot";                  
				new_spot_1.useClippingSpace = false;
			
				node_1.spot = new_spot_1;
				
				sector.GetNodeSetup(2).SetPosition(new_pos_1);
				sector.GetNodeSetup(2).SetOrientation(new_rot_1);
			}
			
			let node_2 = nodes[3] as worldAISpotNode;	//{crowd_ws_barstool_}02
			let new_pos_2 = new Vector4(-1551.6407, -318.99515, -4.530365, 0);
			let new_rot_2 = new Quaternion(0, 0, -0.30281714, 0.9530487);						
			
			if IsDefined(node_2){
						
				let new_spot_2 = new AIActionSpot();
				new_spot_2.resource *= r"base\\workspots\\common\\ground\\generic__stand_ground_cigarette__smoke__01.workspot";                  
				new_spot_2.useClippingSpace = false;
			
				node_2.spot = new_spot_2;
				
				sector.GetNodeSetup(3).SetPosition(new_pos_2);
				sector.GetNodeSetup(3).SetOrientation(new_rot_2);
			}
		}	
    }	
	private cb func proc_city_subway(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==2161)
		{				
			let nodes = sector.GetNodes();	
			let node_1 = nodes[47] as worldAISpotNode;	//generic__sit_barstool_bar_lean_front_asian_takeout__eat__01	
			let new_pos_1 = new Vector4(-1308.2676, -54.629402, 2.1500015, 0);
			let new_rot_1 = new Quaternion(0, 0, 0.9483304, 0.3172847);						
			
			if IsDefined(node_1){
						
				let new_spot_1 = new AIActionSpot();
				new_spot_1.resource *= r"base\\workspots\\common\\ground\\generic__stand_ground_asian_takeout__eat__01.workspot";                  
				new_spot_1.useClippingSpace = false;
			
				node_1.spot = new_spot_1;
				
				sector.GetNodeSetup(47).SetPosition(new_pos_1);
				sector.GetNodeSetup(47).SetOrientation(new_rot_1);
			}
		}	
    }
	private cb func proc_city_solo_3(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==1175)
		{				
			let nodes = sector.GetNodes();	
			let node_1 = nodes[84] as worldAISpotNode;	//master_generic__sit_barstool_bar__sit_around__007	
			let new_pos_1 = new Vector4( -1954.575, 325.3038, 8.146332, 0);
			let new_rot_1 = new Quaternion(0, 0, 0, 1);						
			
			if IsDefined(node_1){
						
				let new_spot_1 = new AIActionSpot();
				new_spot_1.resource *= r"base\\workspots\\common\\ground\\generic__stand_ground_asian_takeout__eat__01.workspot";                  
				new_spot_1.useClippingSpace = false;
			
				node_1.spot = new_spot_1;
				
				sector.GetNodeSetup(85).SetPosition(new_pos_1);
				sector.GetNodeSetup(85).SetOrientation(new_rot_1);
			}
		}	
    }
	private cb func proc_city_solo_2(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==271)
		{				
			let nodes = sector.GetNodes();	
			let node_1 = nodes[4] as worldAISpotNode;	//master_generic__sit_barstool_bar__sit_around__006
			let new_pos_1 = new Vector4(-1725.4113, -56.403915, 7.6036224, 0);
			let new_rot_1 = new Quaternion(0, 0, -0.6921941, 0.7217114);						
			
			if IsDefined(node_1){
						
				let new_spot_1 = new AIActionSpot();
				new_spot_1.resource *= r"base\\workspots\\common\\ground\\generic__stand_ground_asian_takeout__eat__01.workspot";                  
				new_spot_1.useClippingSpace = false;
			
				node_1.spot = new_spot_1;
				
				sector.GetNodeSetup(4).SetPosition(new_pos_1);
				sector.GetNodeSetup(4).SetOrientation(new_rot_1);
			}
		}	
    }	
	private cb func proc_city_green_1(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==1637)
		{
			let new_pos_1 = new Vector4(-2411.16846, 464.063629, 11.2399979, 0);
			let new_rot_1 = new Quaternion(0, 0, 0.45149529, 0.892273545);
			sector.GetNodeSetup(44).SetNodeIndex(Cast<Uint16>(15u));
			sector.GetNodeSetup(44).SetPosition(new_pos_1);
			sector.GetNodeSetup(44).SetOrientation(new_rot_1);
			//{crowd_ws_barstool_}02
			
			let new_pos_2 = new Vector4(-2404.77271, 468.106445, 11.2399979, 0);
			let new_rot_2 = new Quaternion(0, 0, 0.530072749, -0.847952247);	
			sector.GetNodeSetup(45).SetNodeIndex(Cast<Uint16>(15u));
			sector.GetNodeSetup(45).SetPosition(new_pos_2);
			sector.GetNodeSetup(45).SetOrientation(new_rot_2);
			//{crowd_ws_barstool_}04
		}
    }		
	private cb func proc_city_green_2(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==745)
		{
			let new_pos_1 = new Vector4(-2411.16846, 464.063629, 11.2399979, 0);
			let new_rot_1 = new Quaternion(0, 0, 0.45149529, 0.892273545);
			sector.GetNodeSetup(17).SetNodeIndex(Cast<Uint16>(21u));
			sector.GetNodeSetup(17).SetPosition(new_pos_1);
			sector.GetNodeSetup(17).SetOrientation(new_rot_1);
			//{crowd_ws_barstool_}03
			
			let new_pos_2 = new Vector4(-2404.77271, 468.106445, 11.2399979, 0);
			let new_rot_2 = new Quaternion(0, 0, 0.530072749, -0.847952247);	
			sector.GetNodeSetup(18).SetNodeIndex(Cast<Uint16>(21u));
			sector.GetNodeSetup(18).SetPosition(new_pos_2);
			sector.GetNodeSetup(18).SetOrientation(new_rot_2);
			//{crowd_ws_barstool_}01
		}
    }
	
	private cb func proc_badlands_solo_1(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		if(sector.GetNodeSetupCount()==665)
		{				
			let nodes = sector.GetNodes();	
			let node_1 = nodes[75] as worldAISpotNode;	//{crowd_ws_barstool}_001	
			let new_pos_1 = new Vector4(1202.5, -562.954102, 32.6339874, 0);
			let new_rot_1 = new Quaternion(0, 0, -0.706654549, -0.707558751);						
			
			if IsDefined(node_1){
						
				let new_spot_1 = new AIActionSpot();
				new_spot_1.resource *= r"base\\workspots\\common\\chair\\generic__sit_chair__sit_around__03.workspot";                  
				new_spot_1.useClippingSpace = false;
			
				node_1.spot = new_spot_1;
				
				sector.GetNodeSetup(81).SetPosition(new_pos_1);
				sector.GetNodeSetup(81).SetOrientation(new_rot_1);
			}
		}	
    }	
}