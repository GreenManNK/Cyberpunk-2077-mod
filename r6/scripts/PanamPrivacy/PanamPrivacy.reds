class PanamWorldEdit extends ScriptableService {
    private cb func OnLoad() {
        GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Ready", this, n"ProcessPanamSector")
            .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_28_34_2_0.streamingsector"));
	}

    private cb func ProcessPanamSector(event: ref<ResourceEvent>) {
        let sector = event.GetResource() as worldStreamingSector;
        for node in sector.GetNodes() {
            let entityNode = node as worldClothMeshNode;
            if IsDefined(entityNode) {
                if entityNode.mesh == r"base\\environment\\decoration\\textiles\\curtains\\industrial_curtain\\industrial_curtain_d_clh.mesh" {
					entityNode.mesh *= r"base\\environment\\decoration\\textiles\\curtains\\industrial_curtain\\industrial_curtain_dx_clh.mesh";
                }
            }
        }
    }
}