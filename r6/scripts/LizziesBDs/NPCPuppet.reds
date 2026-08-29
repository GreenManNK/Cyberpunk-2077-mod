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

// https://codeberg.org/adamsmasher/cyberpunk/src/branch/master/cyberpunk/NPC/NPCPuppet.swift

module LizziesBDs.NPCPuppet

import LizziesBDs.Classes.*
import LizziesBDs.Data.*
import LizziesBDs.Main.*
import LizziesBDs.Resources.*

@wrapMethod(NPCPuppet)
protected cb func OnGameAttached() -> Bool {
	wrappedMethod();
	if !this.IsCrowd() {
		let questsSystem: wref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGame());
		if questsSystem.GetFact(n"lizzies_bds_active") == 1 || questsSystem.GetFact(n"lizzies_bds_er_active") == 1 || questsSystem.GetFact(n"lizzies_bds_menu_ui") > 0 {
			if this.GetRecordID() == TDBID.Create("Character.LizziesBDs_Performer") {
				this.LizziesBDsChangeClothes(questsSystem, 1, 0);
				this.LizziesBDsSetMoaningVariant(questsSystem, 0);
			}
			else if this.GetRecordID() == TDBID.Create("Character.LizziesBDs_Performer_2") {
				this.LizziesBDsChangeClothes(questsSystem, 1, 1);
				this.LizziesBDsSetMoaningVariant(questsSystem, 1);
			}
			else if this.GetRecordID() == TDBID.Create("Character.LizziesBDs_Performer_3") {
				this.LizziesBDsChangeClothes(questsSystem, 1, 2);
				this.LizziesBDsSetMoaningVariant(questsSystem, 2);
			}
			else if this.GetRecordID() == TDBID.Create("Character.LizziesBDs_Performer_4") {
				this.LizziesBDsChangeClothes(questsSystem, 1, 3);
				this.LizziesBDsSetMoaningVariant(questsSystem, 3);
			}
			else if this.GetRecordID() == TDBID.Create("Character.LizziesBDs_Performer_5") {
				this.LizziesBDsChangeClothes(questsSystem, 1, 4);
				this.LizziesBDsSetMoaningVariant(questsSystem, 4);
			}
			else if this.GetRecordID() == TDBID.Create("Character.LizziesBDs_Performer_6") {
				this.LizziesBDsChangeClothes(questsSystem, 1, 5);
				this.LizziesBDsSetMoaningVariant(questsSystem, 5);
			}
			else if this.GetRecordID() == TDBID.Create("Character.LizziesBDs_Performer_Preview") {
				this.LizziesBDsChangeClothes(questsSystem, 1, 100);
			}
		}
	}
}

@addMethod(NPCPuppet)
protected cb func OnLizziesBDsChangeClothesEvent(event: ref<ActionEvent>) {
	let questsSystem: wref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGame());
	switch (event.eventAction) {
		case n"Normalni_P1":
			this.LizziesBDsChangeClothes(questsSystem, 1, 0);
			break;
		case n"Normalni_P2":
			this.LizziesBDsChangeClothes(questsSystem, 1, 1);
			break;
		case n"Normalni_P3":
			this.LizziesBDsChangeClothes(questsSystem, 1, 2);
			break;
		case n"Normalni_P4":
			this.LizziesBDsChangeClothes(questsSystem, 1, 3);
			break;
		case n"Normalni_P5":
			this.LizziesBDsChangeClothes(questsSystem, 1, 4);
			break;
		case n"Normalni_P6":
			this.LizziesBDsChangeClothes(questsSystem, 1, 5);
			break;
		case n"BezObleceni_P1":
			this.LizziesBDsChangeClothes(questsSystem, 2, 0);
			break;
		case n"BezObleceni_P2":
			this.LizziesBDsChangeClothes(questsSystem, 2, 1);
			break;
		case n"BezObleceni_P3":
			this.LizziesBDsChangeClothes(questsSystem, 2, 2);
			break;
		case n"BezObleceni_P4":
			this.LizziesBDsChangeClothes(questsSystem, 2, 3);
			break;
		case n"BezObleceni_P5":
			this.LizziesBDsChangeClothes(questsSystem, 2, 4);
			break;
		case n"BezObleceni_P6":
			this.LizziesBDsChangeClothes(questsSystem, 2, 5);
			break;
		case n"Normalni_Nahled":
			this.LizziesBDsChangeClothes(questsSystem, 1, 100);
			break;
		case n"BezObleceni_Nahled":
			this.LizziesBDsChangeClothes(questsSystem, 2, 100);
			break;
		default:
			break;
	}
}

@addMethod(NPCPuppet)
protected final func LizziesBDsChangeClothes(questsSystem: wref<QuestsSystem>, akce: Int32, postava: Int32) -> Void {
	let faktPostava: CName = StringToName(Konstanty.FaktVybranaPostava() + ToString(postava));
	let faktPostavaVlastni: CName = StringToName(Konstanty.FaktVybranaPostavaVlastni() + ToString(postava));
	let faktPostavaVzhled: CName = StringToName(Konstanty.FaktVybranyVzhled() + ToString(postava));

	let vybranaPostava: Int32 = questsSystem.GetFact(faktPostava);
	
	if EnumInt(GlobalniID.Postava_Female_V) != vybranaPostava && EnumInt(GlobalniID.Postava_Male_V) != vybranaPostava {
		let vybranyVzhled: Int32 = questsSystem.GetFact(faktPostavaVzhled);
		let vybranaPostavaVlastni: Int32 = questsSystem.GetFact(faktPostavaVlastni);
			
		let vzhled: CName = n"";
		let vzhledBez: CName = n"";
		
		if EnumInt(GlobalniID.Postava_Vlastni_Zena) == vybranaPostava || EnumInt(GlobalniID.Postava_Vlastni_Muz) == vybranaPostava {
			let sys: wref<LizziesBDsMain> = LizziesBDsMain.ZiskatInstanci(this.GetGame());

			let poleVlastnichPostav: array<ref<DataPostavy>> = sys.VlastniPostavy();
			let i = 0;
			while i < ArraySize(poleVlastnichPostav) {
				if vybranaPostavaVlastni == poleVlastnichPostav[i].CustomID {
					vzhled = poleVlastnichPostav[i].Vzhledy[vybranyVzhled].VlastniVzhledNormalni;
					vzhledBez = poleVlastnichPostav[i].Vzhledy[vybranyVzhled].VlastniVzhledExplicitni;
				}
				i += 1;
			}
		} else {
			let vzhledData = DataVzhledu(IntEnum(vybranaPostava), vybranyVzhled);
			vzhled = vzhledData[0];
			vzhledBez = vzhledData[1];
		}

		if akce == 1 {
			this.ScheduleAppearanceChange(vzhled);
		}
		if akce == 2 {
			let nastNPCObleceni: Int32 = questsSystem.GetFact(Konstanty.FaktNastaveniNPCObleceni());
			this.ScheduleAppearanceChange(nastNPCObleceni == 0 ? vzhledBez : vzhled);
		}
	}
}

@addMethod(NPCPuppet)
protected final func LizziesBDsSetMoaningVariant(questsSystem: wref<QuestsSystem>, postava: Int32) -> Void {
	let faktPostavaPohlavi: CName = StringToName(Konstanty.FaktVybranyPohlavi() + ToString(postava));

	let vybranaPostavaPohlavi: GenderType = IntEnum(questsSystem.GetFact(faktPostavaPohlavi));

	let faktPostava: CName = StringToName(Konstanty.FaktVybranaPostava() + ToString(postava));
	let vybranaPostava: Int32 = questsSystem.GetFact(faktPostava);
	let jeHrac: Bool = EnumInt(GlobalniID.Postava_Female_V) == vybranaPostava || EnumInt(GlobalniID.Postava_Male_V) == vybranaPostava;

	GlobalniFunkce.NastavitMoaning(this.GetGame(), this.GetEntityID(), vybranaPostavaPohlavi, postava, jeHrac, -1);
}

@addMethod(NPCPuppet)
protected cb func OnLizziesBDsSetPosEvent(event: ref<ActionEvent>) {
	if Equals(event.eventAction, n"UmistnitPredHrace") {
		let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(this.GetGame()).GetLocalPlayerMainGameObject() as PlayerPuppet;
		let pos: Vector4 = player.GetWorldPosition();
		let heading: Vector4 = player.GetWorldForward();
		let rot: EulerAngles = player.GetWorldOrientation().ToEulerAngles();
		
		let posNew: Vector4 = new Vector4(pos.X + (heading.X * 1.5), pos.Y + (heading.Y * 1.5), pos.Z, pos.W);

		//GameInstance.GetTeleportationFacility(this.GetGame()).Teleport(this, pos, rot);

		let a: ref<AITeleportCommand> = new AITeleportCommand();
		a.position = posNew;
		a.rotation = rot.Yaw + 180.0;
		a.doNavTest = false;
		this.GetAIControllerComponent().SendCommand(a);
	}
}

@wrapMethod(NPCPuppet)
protected cb func OnRequestComponents(ri: EntityRequestComponentsInterface) -> Bool {
	if !this.IsCrowd() {
		let questsSystem: wref<QuestsSystem> = GameInstance.GetQuestsSystem(this.GetGame());
		if questsSystem.GetFact(n"lizzies_bds_active") == 1 || questsSystem.GetFact(n"lizzies_bds_er_active") == 1 || questsSystem.GetFact(n"lizzies_bds_menu_ui") > 0 {
			let postava: Int32 = -1;
			if this.GetRecordID() == TDBID.Create("Character.LizziesBDs_Performer") { postava = 0; }
			else if this.GetRecordID() == TDBID.Create("Character.LizziesBDs_Performer_2") { postava = 1; }
			else if this.GetRecordID() == TDBID.Create("Character.LizziesBDs_Performer_3") { postava = 2; }
			else if this.GetRecordID() == TDBID.Create("Character.LizziesBDs_Performer_4") { postava = 3; }
			else if this.GetRecordID() == TDBID.Create("Character.LizziesBDs_Performer_5") { postava = 4; }
			else if this.GetRecordID() == TDBID.Create("Character.LizziesBDs_Performer_6") { postava = 5; }
			else if this.GetRecordID() == TDBID.Create("Character.LizziesBDs_Performer_Preview") { postava = 100; }
			if postava > -1 {
				let jeZena: Bool = questsSystem.GetFact(StringToName(Konstanty.FaktVybranyPohlavi() + ToString(postava))) == 2;

				let bodSize: Int32 = questsSystem.GetFact(StringToName(Konstanty.FaktVybranyBODSize() + "_" + ToString(postava)));
				let bodVariant: Int32 = questsSystem.GetFact(StringToName(Konstanty.FaktVybranyBODVariant() + "_" + ToString(postava)));
				let bodFem: Bool = questsSystem.GetFact(StringToName(Konstanty.FaktVybranyBODFem() + "_" + ToString(postava))) == 1;

				let optStrapon: Int32 = questsSystem.GetFact(StringToName(Konstanty.FaktVybranyStrapon() + "_" + ToString(postava)));
				let optFishnet: Int32 = questsSystem.GetFact(StringToName(Konstanty.FaktVybranyFishnet() + "_" + ToString(postava)));
				let optChoker: Int32 = questsSystem.GetFact(StringToName(Konstanty.FaktVybranyChoker() + "_" + ToString(postava)));

				let lizziesBDsResources: wref<LizziesBDsResources> = GameInstance.GetScriptableServiceContainer().GetService(n"LizziesBDs.Resources.LizziesBDsResources") as LizziesBDsResources;
				
				let components = this.GetComponents();
				let i = 0;
				while i < ArraySize(components) {
					if bodSize != 3 && (!jeZena || (jeZena && bodFem)) {
						if lizziesBDsResources.bodInstalovan {
							let meshComp = components[i] as entSkinnedMeshComponent;
							if IsDefined(meshComp) {
								if Equals(meshComp.GetName(), n"i0_000_pma_base__penis") {
									meshComp.Toggle(false);
								}

								if Equals(meshComp.GetName(), n"lizzies_bds_component_penis") {
									meshComp.isEnabled = true;

									let res: ResourceAsyncRef;
									if !jeZena {
										if bodSize == 0 { ResourceAsyncRef.SetPath(res, r"mod\\arman3_lizzies_bds\\characters\\common\\dp77_x_dicks\\i1_penis_regular_ma.mesh"); }
										else if bodSize == 1 { ResourceAsyncRef.SetPath(res, r"mod\\arman3_lizzies_bds\\characters\\common\\dp77_x_dicks\\i1_penis_large_ma.mesh"); }
										else if bodSize == 2 { ResourceAsyncRef.SetPath(res, r"mod\\arman3_lizzies_bds\\characters\\common\\dp77_x_dicks\\i1_penis_extra_large_ma.mesh"); }
									}
									else if jeZena {
										if bodSize == 0 { ResourceAsyncRef.SetPath(res, r"mod\\arman3_lizzies_bds\\characters\\common\\dp77_x_dicks\\i1_penis_regular_wa.mesh"); }
										else if bodSize == 1 { ResourceAsyncRef.SetPath(res, r"mod\\arman3_lizzies_bds\\characters\\common\\dp77_x_dicks\\i1_penis_large_wa.mesh"); }
										else if bodSize == 2 { ResourceAsyncRef.SetPath(res, r"mod\\arman3_lizzies_bds\\characters\\common\\dp77_x_dicks\\i1_penis_extra_large_wa.mesh"); }
									}
									meshComp.mesh = res;

									if bodVariant == 0 { meshComp.chunkMask = 1ul; }
									else if bodVariant == 1 { meshComp.chunkMask = 2ul; }
									else if bodVariant == 2 { meshComp.chunkMask = 4ul; }
									else if bodVariant == 3 { meshComp.chunkMask = 8ul; }
								}
							}
						}
					}

					let meshGarComp = components[i] as entGarmentSkinnedMeshComponent;
					if IsDefined(meshGarComp) {
						//FTLog(NameToString(meshGarComp.GetName()));

						if optStrapon > 0 && jeZena {
							if Equals(meshGarComp.GetName(), n"lizzies_bds_component_strapon") {
								meshGarComp.isEnabled = true;
								let res: ResourceAsyncRef;
								ResourceAsyncRef.SetPath(res, r"mod\\arman3_lizzies_bds\\characters\\common\\l1_099_pants__strapon\\l1_099_wa_pants__strapon.mesh");
								meshGarComp.mesh = res;
								if optStrapon == 1 { meshGarComp.chunkMask = 1ul; }
							}
						}

						if optFishnet > 0 && jeZena {
							if Equals(meshGarComp.GetName(), n"lizzies_bds_component_fishnet") {
								meshGarComp.isEnabled = true;
								let res: ResourceAsyncRef;
								ResourceAsyncRef.SetPath(res, r"base\\characters\\garment\\citizen_casual\\legs\\l0_004_tights__fishnet\\l0_004_wa_tights__fishnet.mesh");
								meshGarComp.mesh = res;
								if optFishnet == 1 { meshGarComp.meshAppearance = n"black_large"; }
								if optFishnet == 2 { meshGarComp.meshAppearance = n"fish_net"; }
							}
						}

						if optChoker > 0 && (jeZena || (!jeZena && optChoker != 3)) {
							if Equals(meshGarComp.GetName(), n"lizzies_bds_component_choker") {
								meshGarComp.isEnabled = true;
								let res: ResourceAsyncRef;

								if jeZena {
									if optChoker == 1 { ResourceAsyncRef.SetPath(res, r"base\\characters\\garment\\citizen_casual\\item\\i1_044_neck__beaded_choker\\i1_044_wa_neck__beaded_choker.mesh"); }
									else if optChoker == 2 { ResourceAsyncRef.SetPath(res, r"base\\characters\\garment\\citizen_casual\\item\\i1_048_neck__choker_spikes\\i1_048_wa_neck__choker_spikes.mesh"); }
									else if optChoker == 3 {
										ResourceAsyncRef.SetPath(res, r"base\\characters\\garment\\citizen_casual\\item\\i1_076_neck__choker_rogue\\i1_076_wa_neck__choker_rogue.mesh");
										meshGarComp.meshAppearance = n"black";
									}
								} else {
									if optChoker == 1 { ResourceAsyncRef.SetPath(res, r"base\\characters\\garment\\citizen_casual\\item\\i1_044_neck__beaded_choker\\i1_044_ma_neck__beaded_choker.mesh"); }
									else if optChoker == 2 { ResourceAsyncRef.SetPath(res, r"base\\characters\\garment\\citizen_casual\\item\\i1_048_neck__choker_spikes\\i1_048_ma_neck__choker_spikes.mesh"); }
								}

								meshGarComp.mesh = res;
							}
						}
					}
					i += 1;
				}
			}
		}
	}

	wrappedMethod(ri);
}