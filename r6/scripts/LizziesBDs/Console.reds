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

import LizziesBDs.Classes.*
import LizziesBDs.Data.*
import LizziesBDs.Main.*
import LizziesBDs.Storage.*

public static exec func LizziesBDsReset(gi: GameInstance) -> Void {
	let questsSystem: wref<QuestsSystem> = gi.GetQuestsSystem();
	questsSystem.SetFact(n"lizzies_bds_reset", 1);
}

public static exec func LizziesBDsHardReset(gi: GameInstance) -> Void {
	let questsSystem: wref<QuestsSystem> = gi.GetQuestsSystem();
	questsSystem.SetFact(n"lizzies_bds_reset", 10);
}

public static exec func LizziesBDsAllowNSFW(gi: GameInstance) -> Void {
	let questsSystem: wref<QuestsSystem> = gi.GetQuestsSystem();
	questsSystem.SetFact(Konstanty.FaktNudity(), 1);

	FTLog("[LizziesBDs] Explicit content was enabled.");
}

public static exec func LizziesBDsDisableNSFW(gi: GameInstance) -> Void {
	let questsSystem: wref<QuestsSystem> = gi.GetQuestsSystem();
	questsSystem.SetFact(Konstanty.FaktNudity(), 2);

	FTLog("[LizziesBDs] Explicit content was disabled.");
}

public static exec func LizziesBDsChar(gi: GameInstance, name: String, hide: Bool) -> Void {
	let polePostavData: array<ref<DataPostavy>> = DataPolePostav();

	let i = 0;
	while i < ArraySize(polePostavData) {
		if Equals(polePostavData[i].Fakt, name) {
			let questsSystem: wref<QuestsSystem> = gi.GetQuestsSystem();
			questsSystem.SetFact(polePostavData[i].FaktPostavy(), hide ? 1 : 0);

			FTLog("[LizziesBDs] Character \"" + polePostavData[i].ZiskatNazevPostavy(0) + "\" was " + (hide ? "hidden" : "shown") + ".");
			return;
		}
		i += 1;
	}
	
	FTLog("[LizziesBDs] Character with name \"" + name + "\" was not found.");
}

public static exec func LizziesBDsSett(gi: GameInstance, name: String, optSett: Int32) -> Void {
	let poleNastaveniData: array<DataNastaveni> = DataPoleNastaveni(true);

	let i = 0;
	while i < ArraySize(poleNastaveniData) {
		if Equals(poleNastaveniData[i].NazevProKonzoli, name) {
			let questsSystem: wref<QuestsSystem> = gi.GetQuestsSystem();
			questsSystem.SetFact(poleNastaveniData[i].FaktKeZmene, optSett);

			FTLog("[LizziesBDs] Setting \"" + poleNastaveniData[i].Nazev + "\" was set to " + optSett + ".");
			return;
		}
		i += 1;
	}
	
	FTLog("[LizziesBDs] Setting with name \"" + name + "\" was not found.");
}

public static cb func LizziesBDsStorageClear(gi: GameInstance) -> Void {
	let uloziste: wref<LizziesBDsUloziste> = LizziesBDsUloziste.ZiskatInstanci(gi);
	
	uloziste.Nacist(false);
	
	let ulozeno: array<ref<LizziesBDsUlozistePolozkaV5>> = uloziste.VratitPoleDat(UlozisteTyp.Oblibene);
	let i = 0;
	while i < ArraySize(ulozeno) {
		uloziste.SmazatID(UlozisteTyp.Oblibene, ulozeno[i].ID);
		i += 1;
	}

	ulozeno = uloziste.VratitPoleDat(UlozisteTyp.Koupeno);
	i = 0;
	while i < ArraySize(ulozeno) {
		uloziste.SmazatID(UlozisteTyp.Koupeno, ulozeno[i].ID);
		i += 1;
	}

	ulozeno = uloziste.VratitPoleDat(UlozisteTyp.SledovatZnovu);
	uloziste.SmazatID(UlozisteTyp.SledovatZnovu, 0);

	uloziste.Nacist(true);
	ulozeno = uloziste.VratitPoleDat(UlozisteTyp.Oblibene);
	i = 0;
	while i < ArraySize(ulozeno) {
		uloziste.SmazatID(UlozisteTyp.Oblibene, ulozeno[i].ID);
		i += 1;
	}

	FTLog("[LizziesBDs] Storage was cleared.");
}

public static cb func LizziesBDsStorageShow(gi: GameInstance) -> Void {
	let uloziste: wref<LizziesBDsUloziste> = LizziesBDsUloziste.ZiskatInstanci(gi);
	uloziste.Vypsat();
}

public static cb func LizziesBDsStorageAdd(gi: GameInstance, virtus: Bool, type: Int32, loc: Int32, char: Int32, app: Int32, cust: Int32) -> Void {
	let uloziste: wref<LizziesBDsUloziste> = LizziesBDsUloziste.ZiskatInstanci(gi);
	let typUloziste: UlozisteTyp = IntEnum(type);
	
	uloziste.Nacist(virtus);

	let postava: ref<VybranaPostava> = new VybranaPostava();
	postava.PostavaGID = IntEnum(char);
	postava.Vzhled = app;
	postava.Vlastni = cust;
	
	uloziste.Pridat(typUloziste, loc, [], [postava], 0);
}

public static cb func LizziesBDsStorageRemove(gi: GameInstance, virtus: Bool, type: Int32, id: Int32) -> Void {
	let uloziste: wref<LizziesBDsUloziste> = LizziesBDsUloziste.ZiskatInstanci(gi);
	let typUloziste: UlozisteTyp = IntEnum(type);
	
	uloziste.Nacist(virtus);

	uloziste.SmazatID(typUloziste, id);
}

public static exec func LizziesBDsDebug(gi: GameInstance) -> Void {
	let questsSystem: wref<QuestsSystem> = gi.GetQuestsSystem();
	questsSystem.SetFact(Konstanty.FaktMenuUI(), 100);
}

// ====

public static exec func LizziesBDsTeleport(gi: GameInstance, x: Float, y: Float, z: Float) -> Void {
	let rotation: EulerAngles;

	let position: Vector4;
	position.X = x;
	position.Y = y;
	position.Z = z;
	
	let player: ref<PlayerPuppet> = GetPlayer(gi);
	GameInstance.GetTeleportationFacility(gi).Teleport(player, position, rotation);
}

public static exec func LizziesBDsTeleportToNode(gi: GameInstance, nodeName: String) -> Void {
	let ref: NodeRef = CreateNodeRef(nodeName);
	let root: GlobalNodeID = GlobalNodeID.GetRoot();
	let globalRef: GlobalNodeRef = ResolveNodeRef(ref, Cast<GlobalNodeRef>(root));

	if !GlobalNodeRef.IsDefined(globalRef) {
		FTLog("[LizziesBDs] Node " + nodeName + " doesn't exist.");
		return;
	}
	
	let tr: Transform;
	GameInstance.GetNodeTransform(gi, globalRef, tr);

	let trPos: Vector4 = tr.GetPosition();
	let trRotYaw: Float = tr.GetYaw();

	let rotation: EulerAngles;
	rotation.Yaw = trRotYaw;

	let position: Vector4;
	position.X = trPos.X;
	position.Y = trPos.Y;
	position.Z = trPos.Z + 1.0;
	
	let player: ref<PlayerPuppet> = GetPlayer(gi);
	GameInstance.GetTeleportationFacility(gi).Teleport(player, position, rotation);
}

public static exec func LizziesBDsMoveBy(gi: GameInstance, x: Float, y: Float, z: Float, yaw: Float) -> Void {
	let player: ref<PlayerPuppet> = GetPlayer(gi);

	let rotation: EulerAngles;
	rotation.Yaw = player.GetWorldYaw() + yaw;

	let newPosition: Vector4 = player.GetWorldPosition();
	newPosition.X += x;
	newPosition.Y += y;
	newPosition.Z += z;
	
	GameInstance.GetTeleportationFacility(gi).Teleport(player, newPosition, rotation);
}

public static exec func LizziesBDsMoveFwd(gi: GameInstance, amount: Float) -> Void {
	let player: ref<PlayerPuppet> = GetPlayer(gi);

	let position: Vector4 = player.GetWorldPosition();
	let wf: Vector4 = player.GetWorldForward();

	let newPosition: Vector4;
	newPosition.X = position.X + (wf.X * amount);
	newPosition.Y = position.Y + (wf.Y * amount);
	newPosition.Z = position.Z;
	
	let newRotation: EulerAngles;
	newRotation.Yaw = player.GetWorldYaw();
	
	GameInstance.GetTeleportationFacility(gi).Teleport(player, newPosition, newRotation);
}

public static cb func LizziesBDsGetPos(gi: GameInstance) -> Void {
	let player: ref<PlayerPuppet> = GetPlayer(gi);
	
	let pos: Vector4 = player.GetWorldPosition();

	let mainInst: ref<LizziesBDsMain> = LizziesBDsMain.ZiskatInstanci(gi);
	mainInst.testPosOffset = pos;

	FTLog("[LizziesBDs] Position: " + pos.X + ", " + pos.Y + ", " + pos.Z);
}

public static cb func LizziesBDsGetPosOffset(gi: GameInstance) -> Void {
	let player: ref<PlayerPuppet> = GetPlayer(gi);
	
	let posPlr: Vector4 = player.GetWorldPosition();

	let mainInst: ref<LizziesBDsMain> = LizziesBDsMain.ZiskatInstanci(gi);
	let posLast: Vector4 = mainInst.testPosOffset;

	let pos: Vector4 = posPlr - posLast;

	FTLog("[LizziesBDs] Offset position: " + pos.X + ", " + pos.Y + ", " + pos.Z);
}

public static cb func LizziesBDsSetRefOffset(gi: GameInstance, x: Float, y: Float, z: Float) -> Void {
	let newPosition: Vector4;
	newPosition.X = x;
	newPosition.Y = y;
	newPosition.Z = z;

	let mainInst: ref<LizziesBDsMain> = LizziesBDsMain.ZiskatInstanci(gi);
	mainInst.testPosOffset = newPosition;

	FTLog("[LizziesBDs] Reference pos for offset was set to: " + newPosition.X + ", " + newPosition.Y + ", " + newPosition.Z);
}

public static cb func LizziesBDsTogglePrefabVariant(gi: GameInstance, nodeRef: String, variant: String, state: Bool) -> Void {
	let worldStateSystem: ref<WorldStateSystem> = GameInstance.GetWorldStateSystem();
	worldStateSystem.TogglePrefabVariant(CreateNodeRef(nodeRef), StringToName(variant), state);

	FTLog("[LizziesBDs] Toggled prefab: " + nodeRef + ", variant: " + variant + " to " + ToString(state));
}
