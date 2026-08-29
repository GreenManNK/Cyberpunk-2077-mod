// ************************************************************************************************
// ***  Lizzie's Braindances
// ***    Author: ArmanIII
// ***
// *** Please, if you will have unconquerable lust to edit this file (which I don't recommend),
// *** then please do not report any bugs you will encounter in the mod, because I don't want
// *** then spend X hours of searching of a bug which doesn't exist and in the end we find that
// *** it's all your fault. Help me save my nerves. Thanks.
// ***
// ************************************************************************************************

module LizziesBDs.PlayerPuppet

@addField(PlayerPuppet)
private let lizziesBDsSavedPos: Vector4;

@addMethod(PlayerPuppet)
protected cb func OnLizziesBDsPlayerPosEvent(event: ref<ActionEvent>) {
	switch (event.eventAction) {
		case n"UlozitPoziciHrace":
			let pos: Vector4 = this.GetWorldPosition();
			this.lizziesBDsSavedPos = pos;
			break;
		case n"NacistPoziciHrace":
			let rotation: EulerAngles;
			GameInstance.GetTeleportationFacility(this.GetGame()).Teleport(this, this.lizziesBDsSavedPos, rotation);
			break;
		default:
			break;
	}
}
