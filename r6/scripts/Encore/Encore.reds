class EncoreWorldEdits extends ScriptableService {
    private cb func OnLoad() {
        GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"ProcessEncoreA")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\interior_-14_-11_0_1.streamingsector"));
        GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"ProcessEncoreB")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\interior_-7_-6_0_2.streamingsector"));
    }

    private cb func ProcessEncoreA(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
        for node in sector.GetNodes() {
            let entityNode = node as worldGenericProxyMeshNode;
            if IsDefined(entityNode) {
                if entityNode.mesh == r"base\\worlds\\03_night_city\\sectors\\_external\\proxy\\512590508\\ad_digital_stand_frame_e_screen_d.mesh" {
					entityNode.nearAutoHideDistance = 2.0;
                }
            }
        }
    }
	private cb func ProcessEncoreB(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
		let count: Int32 = 0;
		let workspots: Int32 =0;
		for node in sector.GetNodes() {
            let entityNode = node as worldAISpotNode;
            if IsDefined(entityNode) {
				workspots += 1;
				let spot = entityNode.spot as AIActionSpot;
                if IsDefined(spot) {
					if spot.resource == r"base\\workspots\\master\\master_generic__sit_chair__sit_around__01.workspot" {
						count +=1;
						if count == 5 && workspots == 10{
							spot.resource *= r"base\\workspots\\common\\ground\\generic__stand_ground_asian_takeout__eat__01.workspot";
							}
					}
                }
            }
        }
    }
}