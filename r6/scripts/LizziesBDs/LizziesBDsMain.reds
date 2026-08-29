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

module LizziesBDs.Main

import LizziesBDs.Classes.*
import LizziesBDs.Storage.*
import LizziesBDs.Data.*

public class LizziesBDsMain extends ScriptableSystem {
	private let questsSystem: wref<QuestsSystem>;

	private let baseFact: CName = n"lizzies_bds_base";
	private let looseBDsFact: CName = n"lizzies_bds_loose_bd";
	private let activeFact: CName = n"lizzies_bds_active";
	private let activeERFact: CName = n"lizzies_bds_er_active";
	private let creditsUIFact: CName = n"lizzies_bds_credits_ui";

	private let extMusicFact: CName = n"lizzies_bds_ext_music";
	private let ferrisWheelFact: CName = n"lizzies_bds_ferris_wheel_cabin";
	private let plrClothesFact: CName = n"lizzies_bds_toggle_player_clothes";

	private let menuUIListenerId: Uint32;
	private let creditsUIListenerId: Uint32;
	private let baseFactListenerId: Uint32;
	private let looseBDsFactListenerId: Uint32;
	private let activeFactListenerId: Uint32;
	private let activeERFactListenerId: Uint32;

	private let musicFactListenerId: Uint32;
	private let ferrisWheelFactListenerId: Uint32;
	private let plrClothesFactListenerId: Uint32;

	private let ferrisWheelCabinEntity: ref<Entity>;

	public let testPosOffset: Vector4;

	private let vlastniPostavyPole: array<ref<DataPostavy>>;
	private let vlastniHudbaPole: array<ref<DataHudby>>;

	public static func ZiskatInstanci(gameInstance: GameInstance) -> ref<LizziesBDsMain> {
		let system: ref<LizziesBDsMain> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"LizziesBDs.Main.LizziesBDsMain") as LizziesBDsMain;
		return system;
	}

	private func OnAttach() -> Void {
		//FTLog("[LizziesBDs] Attach");
		if GameInstance.GetSystemRequestsHandler().IsPreGame() {
			return;
		}
		//FTLog("[LizziesBDs] AfterPreGame");

		this.questsSystem = GameInstance.GetQuestsSystem(this.GetGameInstance());

		this.menuUIListenerId = this.questsSystem.RegisterListener(Konstanty.FaktMenuUI(), this, n"OnFactMenuUIChange");
		this.creditsUIListenerId = this.questsSystem.RegisterListener(this.creditsUIFact, this, n"OnFactCreditsUIChange");
		this.baseFactListenerId = this.questsSystem.RegisterListener(this.baseFact, this, n"OnFactBaseChange");
		this.looseBDsFactListenerId = this.questsSystem.RegisterListener(this.looseBDsFact, this, n"OnFactLooseBDsChange");
		this.musicFactListenerId = this.questsSystem.RegisterListener(this.extMusicFact, this, n"OnFactMusicChange");
		this.activeFactListenerId = this.questsSystem.RegisterListener(this.activeFact, this, n"OnFactActiveChange");
		this.activeERFactListenerId = this.questsSystem.RegisterListener(this.activeERFact, this, n"OnFactActiveChange");
	}

	private func OnDetach() -> Void {
		//FTLog("[LizziesBDs] Detach");
		this.questsSystem.UnregisterListener(Konstanty.FaktMenuUI(), this.menuUIListenerId);
		this.questsSystem.UnregisterListener(this.creditsUIFact, this.creditsUIListenerId);
		this.questsSystem.UnregisterListener(this.baseFact, this.baseFactListenerId);
		this.questsSystem.UnregisterListener(this.looseBDsFact, this.looseBDsFactListenerId);
		this.questsSystem.UnregisterListener(this.extMusicFact, this.musicFactListenerId);
		this.questsSystem.UnregisterListener(this.activeFact, this.activeFactListenerId);
		this.questsSystem.UnregisterListener(this.activeERFact, this.activeERFactListenerId);
		this.Listeners(false);
	}

	protected cb func OnFactMenuUIChange(factValue: Int32) -> Bool {
		if factValue == 0 {
			GameInstance.GetUISystem(this.GetGameInstance()).QueueEvent(new RemoveAnimLizziesBDsMenuUIFromHudEvent());
		}
		if factValue >= 1 {
			GameInstance.GetUISystem(this.GetGameInstance()).QueueEvent(new InjectLizziesBDsMenuUIToHudEvent());
		}
	}
	
	protected cb func OnFactCreditsUIChange(factValue: Int32) -> Bool {
		if factValue == 0 {
			GameInstance.GetUISystem(this.GetGameInstance()).QueueEvent(new RemoveLizziesBDsCreditsUIFromHudEvent());
		}
		if factValue >= 1 {
			GameInstance.GetUISystem(this.GetGameInstance()).QueueEvent(new InjectLizziesBDsCreditsUIToHudEvent());
		}
	}
	
	protected cb func OnFactBaseChange(factValue: Int32) -> Bool {
		//if factValue == 1520 && factValue != 8953 {
		//	this.questsSystem.SetFact(this.baseFact, 8953);
		//}
		
		if factValue == 1520 {
			if GlobalniFunkce.IsNGPlusPrologue() {
				this.questsSystem.SetFact(this.baseFact, 4861);
			}
			else if GlobalniFunkce.IsNGPlusHeist() {
				this.questsSystem.SetFact(this.baseFact, 2946);
			}
			else {
				this.questsSystem.SetFact(this.baseFact, 8953);
			}

			this.questsSystem.SetFact(Konstanty.FaktUzivID(), RandRange(1000, 9999));
		}
	}
	
	protected cb func OnFactLooseBDsChange(factValue: Int32) -> Bool {
		if factValue == 10 {
			let lizziesBDsUloziste: wref<LizziesBDsUloziste> = LizziesBDsUloziste.ZiskatInstanci(this.GetGameInstance());

			lizziesBDsUloziste.Nacist(false);

			let postava: ref<VybranaPostava> = new VybranaPostava();
			postava.PostavaGID = GlobalniID.Postava_LokaceBezPostavy;
			postava.Vzhled = 0;
			postava.Vlastni = 0;

			let n1: ref<VybranaPostavaNastaveni> = new VybranaPostavaNastaveni();
			n1.NastaveniName = Konstanty.FaktVybratHudbu();
			n1.Hodnota = 7;

			lizziesBDsUloziste.Pridat(UlozisteTyp.Koupeno, 5008, [n1], [postava], 0);
		}
	}
	
	protected cb func OnFactActiveChange(factValue: Int32) -> Bool {
		if factValue == 0 {
			this.Listeners(false);
		}
		if factValue == 1 {
			this.Listeners(true);
		}
	}

	private final func Listeners(aktivovat: Bool) -> Void {
		if aktivovat {
			this.ferrisWheelFactListenerId = this.questsSystem.RegisterListener(this.ferrisWheelFact, this, n"OnFactFerrisWheelChange");
			this.plrClothesFactListenerId = this.questsSystem.RegisterListener(this.plrClothesFact, this, n"OnFactPlrClothesChange");
			
			GameInstance.GetCallbackSystem()
				.RegisterCallback(n"Entity/Attached", this, n"OnFerrisWheelCabinEntityAttached")
				.AddTarget(EntityTarget.RecordID(t"Vehicle.LizziesBDs_FerrisWheelCabin"));

			GameInstance.GetCallbackSystem().RegisterCallback(n"Resource/Loaded", this, n"OnLoaded_SceneRes")
				.AddTarget(ResourceTarget.Type(n"scnSceneResource"));
		} else {
			this.questsSystem.UnregisterListener(this.ferrisWheelFact, this.ferrisWheelFactListenerId);
			this.questsSystem.UnregisterListener(this.plrClothesFact, this.plrClothesFactListenerId);
		
			GameInstance.GetCallbackSystem()
				.UnregisterCallback(n"Entity/Attached", this, n"OnFerrisWheelCabinEntityAttached");
		
			GameInstance.GetCallbackSystem()
				.UnregisterCallback(n"Resource/Loaded", this, n"OnLoaded_SceneRes");
		}
	}

	protected cb func OnFactMusicChange(factValue: Int32) -> Bool {
		if factValue > 0 {
			if ArraySize(this.vlastniHudbaPole) > 0 {
				let vybranaHudba: Int32 = this.questsSystem.GetFact(Konstanty.FaktVybratHudbu());

				let i = 0;
				while i < ArraySize(this.vlastniHudbaPole) {
					if Equals(this.vlastniHudbaPole[i].ID, vybranaHudba) {
						let val1: CName = this.vlastniHudbaPole[i].Eventy[factValue - 1].Val1;
						let val2: CName = this.vlastniHudbaPole[i].Eventy[factValue - 1].Val2;

						let audioSystem: wref<AudioSystem> = GameInstance.GetAudioSystem(this.GetGameInstance());

						switch this.vlastniHudbaPole[i].Eventy[factValue - 1].Type {
							case MusicEventType.Event: audioSystem.Play(val1); break;
							case MusicEventType.Switch: audioSystem.Switch(val1, val2); break;
							//case MusicEventType.Mix: break;
							case MusicEventType.EventStop: audioSystem.Stop(val1); break;
							default: break;
						}

						i = 999;
					}
					i += 1;
				}
			}
		}
	}
	
	protected cb func OnFactPlrClothesChange(factValue: Int32) -> Bool {
		let obleceniPlr: Int32 = this.questsSystem.GetFact(Konstanty.FaktObleceniPlr());

		if obleceniPlr == 3 {
			let eexOutfity: array<CName> = GlobalniFunkce.EquipmentExSeznamOutfitu(this.GetGameInstance());
			let selOutfit: Int32 = this.questsSystem.GetFact(Konstanty.FaktEEXOutfit());
			let selOutfitNaked: Int32 = this.questsSystem.GetFact(Konstanty.FaktEEXOutfitNaked());
			let plrStrapon: Int32 = this.questsSystem.GetFact(Konstanty.FaktStraponPlr());

			if factValue == 1 {
				GlobalniFunkce.EquipmentExPouzitOutfit(this.GetGameInstance(), eexOutfity[selOutfitNaked], plrStrapon, true);
			}
			else if factValue == 2 {
				GlobalniFunkce.EquipmentExPouzitOutfit(this.GetGameInstance(), eexOutfity[selOutfit], plrStrapon, false);
			}
		}
	}
	
	private cb func OnFerrisWheelCabinEntityAttached(event: ref<EntityLifecycleEvent>) {
		this.ferrisWheelCabinEntity = event.GetEntity();
	}

	protected cb func OnFactFerrisWheelChange(factValue: Int32) -> Bool {
		if factValue == 0 || factValue == 1 {
			let components = this.ferrisWheelCabinEntity.GetComponents();
			for component in components {
				if Equals(component.GetName(), n"vehicle_rig") {
					let aa = component as AnimatedComponent;

					let rotation: EulerAngles;
					if factValue == 0 {
						rotation.Yaw = 0;
					}
					if factValue == 1 {
						rotation.Yaw = 180;
					}

					aa.SetLocalOrientation(rotation.ToQuat());

					break;
				}
			}
		}
	}

	private cb func OnLoaded_SceneRes(event: ref<ResourceEvent>) {
		let pohlaviReplacer: Int32 = this.questsSystem.GetFact(Konstanty.FaktReplacer());
		if pohlaviReplacer > 0 {
			let sceneResource: ref<scnSceneResource> = event.GetResource() as scnSceneResource;
			//let sceneResRef: ResRef = event.GetPath();
	
			//if Equals(sceneResRef, r"mod\\arman3_lizzies_bds\\quest\\scenes\\hangout\\lizzies_bds_hangout_mod_edenplaza.scene") {
			if ArraySize(sceneResource.actors) > 0 {
				if Equals(sceneResource.actors[0].actorName, "lizzies_bds_bd_performer") {
					let recordId: TweakDBID;
					if pohlaviReplacer == 1 {
						recordId = t"Character.LizziesBDs_Replacer_Male";
					}
					if pohlaviReplacer == 2 {
						recordId = t"Character.LizziesBDs_Replacer_Female";
					}
					sceneResource.playerActors[0].findActorInContextParams.specRecordId = recordId;
					sceneResource.playerActors[0].specCharacterRecordId = recordId;
				}
			}
		}
	}
	
	public final func NacistVlastniPostavyAHudbu() -> Void {
		FTLog("[LizziesBDs] Loaded data");

		ArrayClear(this.vlastniPostavyPole);

		let vlastniPostavyEvent: ref<CustomCharacterLoaderEvent> = new CustomCharacterLoaderEvent();
		vlastniPostavyEvent.NastavitSystemInstanci(this);
		GameInstance.GetUISystem(this.GetGameInstance()).QueueEvent(vlastniPostavyEvent);

		ArrayClear(this.vlastniHudbaPole);

		let vlastniHudbaEvent: ref<CustomMusicLoaderEvent> = new CustomMusicLoaderEvent();
		vlastniHudbaEvent.NastavitSystemInstanci(this);
		GameInstance.GetUISystem(this.GetGameInstance()).QueueEvent(vlastniHudbaEvent);
	}

	public func VlastniPostavy() -> array<ref<DataPostavy>> = this.vlastniPostavyPole;
	public func PridatVlastniPostavu(postava: ref<DataPostavy>) -> Void {
		ArrayPush(this.vlastniPostavyPole, postava);
	}
	
	public func VlastniHudba() -> array<ref<DataHudby>> = this.vlastniHudbaPole;
	public func PridatVlastniHudbu(hudba: ref<DataHudby>) -> Void {
		ArrayPush(this.vlastniHudbaPole, hudba);
	}
}

@wrapMethod(gameuiInGameMenuGameController)
protected cb func OnInitialize() -> Bool {
	wrappedMethod();
	LizziesBDsMain.ZiskatInstanci(this.GetPlayerControlledObject().GetGame()).NacistVlastniPostavyAHudbu();
}