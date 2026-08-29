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

module LizziesBDs.Classes

import LizziesBDs.Main.*
import LizziesBDs.Data.*
import LizziesBDs.UI.*

@if(ModuleExists("NGPlus"))
import NGPlus.*

@if(ModuleExists("NumeralsGetCommas.Functions"))
import NumeralsGetCommas.Functions.*

@if(ModuleExists("EquipmentEx"))
import EquipmentEx.OutfitSystem

public enum MenuUITyp {
	Zadne = 0,
	Normalni = 1,
	Pevecka = 2,
	Recepce = 3,
	Nastaveni = 4,
	NastaveniRuzne = 5,
	BarVyberLokace = 6,
	PVKdekoliv = 7,
	Streamovani = 8,
	PostavaMoznosti = 9,
	KoupeniPV = 10,
	VyberHudby = 11,
	GFH = 12,
	Debug = 100
}

public enum MenuStrankaTyp {
	Prazdne = 0,
	ZpetStranka = 141,
	Soucasne = 142,

	Menu_Hlavni = 100,
	Menu_Zeny = 101,
	Menu_Muzi = 102,
	Menu_Pohlavi = 104,
	Menu_HlavniRecepce = 105,
	Menu_HlavniRecepceSoukromePV = 103,
	Menu_NastaveniPostavy = 106,
	Menu_NastaveniRuzne = 107,
	Menu_PostavaVzhledy = 108,
	Menu_ZenyPouzeMox = 109,
	Menu_MuziPouzeMox = 110,
	Menu_Oblibene = 111,
	Menu_BarLokace = 112,
	Menu_MenuLokace = 113,
	Menu_MenuLokace_NastaveniPostav = 118,
	Menu_MenuLokace_NastaveniPostav_Postava = 140,
	Menu_MenuLokace_Nastaveni = 144,
	Menu_VybratHudbu = 114,
	Menu_KoupenePVSeznam = 137,
	Menu_PostavaMoznosti = 115,
	Menu_PostavaMoznostiPostava = 136,
	Menu_PostavaMoznostiPostavaOblicejKlid = 116,
	Menu_PostavaMoznostiPostavaOblicejPoza = 117,
	//Menu_ZmenaVzhledu = 118,
	Menu_LokaceKontejner = 119,
	Menu_Debug = 120,
	Menu_KatalogNastaveni = 143,
	Menu_GFH = 145,
	Menu_GFH_NastaveniPostavy = 146,
	
	Kateg_Hracky = 121,
	Kateg_Prcinky = 122,
	Kateg_Mox = 123,
	Kateg_Valentinos = 124,
	Kateg_Sesta_ulice = 125,
	Kateg_Maelstrom = 126,
	Kateg_Tygri_spary = 127,
	Kateg_Aldecaldos = 128,
	Kateg_Dogtown = 129,
	Kateg_Zvirata = 130,
	Kateg_Specialni = 131,
	Kateg_Barghest = 132,
	Kateg_Mrchozrouti = 133,
	Kateg_Prizraky = 134,
	Kateg_Vlastni = 135,
	Kateg_Voodoo = 138,
	Kateg_Roboti = 139
}

public enum MenuAkceTyp {
	Prazdne = 0,

	Globalni_KategorieNahoru = 200,
	Globalni_Zpet = 201,
	Globalni_Ukonceni = 202,
	Globalni_ZpetDoMenu = 203,
	Globalni_DalsiStranka = 204,
	Globalni_PredchoziStranka = 205,
	Globalni_MenuLokace = 206,
	Globalni_MenuGFH = 250,
	__Postava = 207,
	__Lokace = 208,
	__Ulozeno = 209,

	Hlavni_Lokace = 210,
	Hlavni_Oblibene = 211,
	Hlavni_Nastaveni = 249,

	LokaceKontejner_Lokace = 213,

	Pohlavi_Zeny = 214,
	Pohlavi_Muzi = 215,

	MenuLokace_VybratEpizodu = 216,
	MenuLokace_Spustit = 217,
	MenuLokace_Koupit = 218,
	MenuLokace_Oblibene = 219,
	MenuLokace_OblibeneOd = 220,
	MenuLokace_VybratPostavu = 221,
	MenuLokace_Pohlavi = 236,
	MenuLokace_OpakovaniSceny = 212,
	MenuLokace_VybratHudbu = 237,
	MenuLokace_ZahoditPV = 244,
	MenuLokace_NastaveniPostav = 247,
	MenuLokace_Nastaveni = 223,
	
	MenuLokace_NastaveniPostav_Postava = 248,

	MenuGFH_VybratPostavu = 251,
	MenuGFH_NastaveniPostavy = 252,
	MenuGFH_Spustit = 253,

	HlavniRecepce_Sluzba = 222,
	//HlavniRecepce_SluzbaKoupit = 223,
	HlavniRecepce_OnlineStat = 224,
	HlavniRecepce_SoukromePV = 245,
	HlavniRecepceSoukromePV_Lokace = 246,
	HlavniRecepce_ER = 254,

	NastaveniPostavy_Zeny = 225,
	NastaveniPostavy_Muzi = 226,

	NastaveniRuzne_Nastaveni = 227,
	NastaveniRuzne_Nastaveni_Zpetne = 241,

	PostavaMoznosti_Postava = 242,
	PostavaMoznosti_Zkop = 243,
	PostavaMoznostiPostava_Vzhled = 234,
	PostavaMoznostiPostava_Oblicej_Klid = 228,
	PostavaMoznostiPostava_Oblicej_Poza = 229,

	PostavaMoznostiPostavaOblicejKlid_Klid = 230,

	PostavaMoznostiPostavaOblicejPoza_Poza = 231,

	VybratHudbu_Vybrat = 240,

	BarLokace_Lokace = 232,

	Debug_Debug = 233,

	PostavaVzhledy_Vzhled = 235,

	Postava_Kateg = 238,
	Postava_Vzhledy = 239,
}

public class InjectLizziesBDsMenuUIToHudEvent extends Event {}
public class RemoveLizziesBDsMenuUIFromHudEvent extends Event {}
public class RemoveAnimLizziesBDsMenuUIFromHudEvent extends Event {}
public class InjectLizziesBDsCreditsUIToHudEvent extends Event {}
public class RemoveLizziesBDsCreditsUIFromHudEvent extends Event {}

public class Konstanty {
	public static func FaktVybranaPostava() -> String = "lizzies_bds_sel_";
	public static func FaktVybranaPostavaVlastni() -> String = "lizzies_bds_sel_custom_";
	public static func FaktVybranyVzhled() -> String = "lizzies_bds_sel_app_";
	public static func FaktVybranyPohlavi() -> String = "lizzies_bds_sel_gender_";
	public static func FaktVybranySpecialni() -> String = "lizzies_bds_sel_special_";
	public static func FaktVybranyVelke() -> String = "lizzies_bds_sel_big_";
	public static func FaktVybranyOblicejKlid() -> String = "lizzies_bds_sel_facial_idle_";
	public static func FaktVybranyOblicejPoza() -> String = "lizzies_bds_sel_facial_pose_";
	public static func FaktVybranyOblicejKlidVaha() -> String = "lizzies_bds_sel_facial_idle_wt_";
	public static func FaktVybranyOblicejPozaVaha() -> String = "lizzies_bds_sel_facial_pose_wt_";
	public static func FaktVybranyRobot() -> String = "lizzies_bds_sel_robot_";
	public static func FaktVybranyBODSize() -> String = "lizzies_bds_sel_bodsize";
	public static func FaktVybranyBODVariant() -> String = "lizzies_bds_sel_bodvariant";
	public static func FaktVybranyBODFem() -> String = "lizzies_bds_sel_bodfem";
	public static func FaktVybranyStrapon() -> String = "lizzies_bds_sel_strapon";
	public static func FaktVybranyFishnet() -> String = "lizzies_bds_sel_fishnet";
	public static func FaktVybranyChoker() -> String = "lizzies_bds_sel_choker";
	public static func FaktVybranyMoaning() -> String = "lizzies_bds_sel_moaning";

	public static func FaktVybranaLokace() -> CName = n"lizzies_bds_sel_loc";
	public static func FaktMenuUI() -> CName = n"lizzies_bds_menu_ui";
	public static func FaktZobrazitPohlavi() -> CName = n"lizzies_bds_sett_show_gender";
	public static func FaktPouzeMox() -> CName = n"lizzies_bds_sett_all";
	public static func FaktZakladniNavigace() -> CName = n"lizzies_bds_sett_base_nav";
	public static func FaktMenuUIAktivni() -> CName = n"lizzies_bds_menu_ui_active";
	public static func FaktAudioHlasitost() -> CName = n"lizzies_bds_sett_moans";
	public static func FaktAudioHlasitost2() -> CName = n"lizzies_bds_sett_moans2";
	public static func FaktEventy() -> CName = n"lizzies_bds_sett_events";
	public static func FaktNudity() -> CName = n"lizzies_bds_censorship_nudity_ask";
	public static func FaktVybratHudbu() -> CName = n"lizzies_bds_sel_music";
	public static func FaktSoukromePV() -> CName = n"lizzies_bds_private_bd";
	public static func FaktSoukromePVMegabuilding() -> CName = n"lizzies_bds_private_bd_megabuilding";
	public static func FaktSoukromePVDowntown() -> CName = n"lizzies_bds_private_bd_downtown";
	public static func FaktSoukromePVHeywood() -> CName = n"lizzies_bds_private_bd_heywood";
	public static func FaktSoukromePVJapantown() -> CName = n"lizzies_bds_private_bd_japantown";
	public static func FaktSoukromePVNorthside() -> CName = n"lizzies_bds_private_bd_northside";
	public static func FaktSoukromePVEdenPlaza() -> CName = n"lizzies_bds_private_bd_edenplaza";
	public static func FaktSoukromePVSantoSerenity() -> CName = n"lizzies_bds_private_bd_santoserenity";
	public static func FaktDynamickyNahled() -> CName = n"lizzies_bds_dynamic_preview";
	public static func FaktNastaveniDynNahled() -> CName = n"lizzies_bds_sett_dynamic_preview_cam";
	public static func FaktNastaveniDynNahledKvalita() -> CName = n"lizzies_bds_sett_dynamic_preview_quality";
	public static func FaktBezPodminek() -> CName = n"lizzies_bds_no_conds";
	public static func FaktNastaveniNPCObleceni() -> CName = n"lizzies_bds_sett_keep_npc_clothes";
	public static func FaktNastaveniSerazeni() -> CName = n"lizzies_bds_sett_sort";
	public static func FaktNastaveniSerazeniKateg() -> CName = n"lizzies_bds_sett_sort_categ";
	public static func FaktExtState() -> CName = n"lizzies_bds_ext_state";
	public static func FaktObleceniPlr() -> CName = n"lizzies_bds_sett_keep_clothes";
	public static func FaktStraponPlr() -> CName = n"lizzies_bds_sett_plr_strapon";
	public static func FaktEEXOutfit() -> CName = n"lizzies_bds_sett_eex_outfit";
	public static func FaktEEXOutfitNaked() -> CName = n"lizzies_bds_sett_eex_outfit_naked";
	public static func FaktUzivID() -> CName = n"lizzies_bds_cust_id";
	public static func FaktFeatPONC() -> CName = n"lizzies_bds_feat_ponc";
	public static func FaktNastaveniZachovatNst() -> CName = n"lizzies_bds_sett_keep_setts";
	public static func FaktNastaveniUINotif() -> CName = n"lizzies_bds_sett_ui_notifs";
	public static func FaktReplacer() -> CName = n"lizzies_bds_replacer";

	public static func MappinHashesBD() -> array<Uint32> {
		return [
			4211048258u, // Bar
			500816547u, // Megabuilding
			2832283867u, // Northside
			710107667u, // Japantown
			3126118537u, // Judy
			351583771u, // River
			1593226106u, // Heywood
			2050739277u, // Downtown
			2973339861u, // LagunaBend
			3000311513u, // KressHideout
			3879642665u, // NomadCamp
			311087777u // Kerry
		];
	}

	public static func MappinHashesER() -> array<Uint32> {
		return [
			2095880155u, // er_01
			1484266324u, // er_02
			2116285240u, // bar_01
			2380679497u, // bar_02
			1808981296u, // bar_03
			510836351u, // bar_04
			95996440u, // bar_05
			1806340814u, // bar_06
			895096127u, // bar_07
			138443877u, // bar_08
			1886328909u, // bar_09
			2774217218u // bar_11
		];
	}
}

@if(!ModuleExists("LizziesBDs.OnlineFeatures"))
public class LizziesBDsOnlineFunkce extends ScriptableSystem {
	public let celkovyPocet: Int32 = 0;
	public let zhaveDnesID: array<Int32>;
	public let zhaveDnesPocet: array<Int32>;
	public let zhaveDnesCelkemPostavy: array<Int32>;
	public let zhaveDnesCelkemPostavyPocet: array<Int32>;
	public let zhaveDnesCelkemLokace: array<Int32>;
	public let zhaveDnesCelkemLokacePocet: array<Int32>;
	public let dnesniDatum: String = "";
	
	public static func ZiskatInstanci(gameInstance: GameInstance) -> ref<LizziesBDsOnlineFunkce> {
		let system: ref<LizziesBDsOnlineFunkce> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"LizziesBDs.OnlineFeatures.LizziesBDsOnlineFunkce") as LizziesBDsOnlineFunkce;
		return system;
	}
	
	public func Instalovano() -> Bool = false;
	public func ZiskatData() -> Void {}
	public func OdeslatData(postava: Int32, lokace: Int32) -> Void {}
}

public class GlobalniFunkce {
	@if(ModuleExists("LizziesBDs.OnlyStaff"))
	public static func PouzeMox() -> Bool = true

	@if(!ModuleExists("LizziesBDs.OnlyStaff"))
	public static func PouzeMox() -> Bool = false

	/*@if(ModuleExists("LizziesBDs.AllowNSFWAddon"))
	public static func PovolitNSFWAddon() -> Bool = true

	@if(!ModuleExists("LizziesBDs.AllowNSFWAddon"))
	public static func PovolitNSFWAddon() -> Bool = false*/

	public static final func IsNGPlusPrologue() -> Bool {
		return false;
	}

	@if(ModuleExists("NGPlus"))
	public static final func IsNGPlusHeist() -> Bool {
		let ngPlusSystem = GameInstance.GetNewGamePlusSystem();
		let isNGPlus: Bool = ngPlusSystem.IsInNewGamePlusSave();
		return isNGPlus;
	}

	@if(!ModuleExists("NGPlus"))
	public static final func IsNGPlusHeist() -> Bool {
		return false;
	}
	
	public static final func TextLocKey(text: String) -> String {
		let str: String = "";
		if StrCmp(text, "LocKey#") != 0 { str = GetLocalizedText(text); } else { str = text; }
		return str;
	}
	
	public static final func ZiskatCenu(economy: String) -> Int32 {
		let hodnota: Int32 = 0;

		if StrCmp(economy, "") != 0 {
			hodnota = TweakDBInterface.GetInt(TDBID.Create("EconomicAssignment.LizziesBDs_" + economy + ".overrideValue"), 100);
		}

		return hodnota;
	}

	public static final func LokaceVelkyObrazek(atlas: InkAtlasSoubor) -> Bool {
		if
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Lokace_K_01) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Lokace_K_02) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Lokace_K_03) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Lokace_K_04) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Lokace_K_05) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Lokace_K_06) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Lokace_K_07)
		{
			return true;
		} else {
			return false;
		}
	}

	public static final func LokaceBarObrazekPuvodni(atlas: InkAtlasSoubor) -> Bool {
		if
			NotEquals(atlas, InkAtlasSoubor.LizziesBDs_Lokace_Bar) &&
			NotEquals(atlas, InkAtlasSoubor.LizziesBDs_Lokace_Bar_2) &&
			NotEquals(atlas, InkAtlasSoubor.LizziesBDs_Lokace_01) &&
			NotEquals(atlas, InkAtlasSoubor.LizziesBDs_Lokace_02) &&
			NotEquals(atlas, InkAtlasSoubor.LizziesBDs_Lokace_03) &&
			NotEquals(atlas, InkAtlasSoubor.LizziesBDs_Lokace_04) &&
			NotEquals(atlas, InkAtlasSoubor.LizziesBDs_Lokace_Psycho_01)
		{
			return true;
		} else {
			return false;
		}
	}

	public static final func PostavaModObrazek(picCtrl: ref<inkImage>, atlas: InkAtlasSoubor, st: Int32) -> Void {
		picCtrl.SetSize(new Vector2(666.0, 1000.0));
		if st != 0 {
			picCtrl.SetMargin(new inkMargin(645.0, 80.0, 0.0, 0.0));
		}

		if Equals(atlas, InkAtlasSoubor.DynamickyNahled) {
			picCtrl.SetContentHAlign(inkEHorizontalAlign.Fill);
			picCtrl.SetContentVAlign(inkEVerticalAlign.Fill);
			if st == 1 {
				picCtrl.SetSize(new Vector2(912.0, 950.0));
			} else {
				picCtrl.SetSize(new Vector2(1200.0, 1250.0));
				if st == 2 {
					picCtrl.SetMargin(new inkMargin(645.0, 50.0, 0.0, 0.0));
				}
			}
			if st == 0 {
				picCtrl.SetScale(new Vector2(0.95, 0.95));
			} else {
				picCtrl.SetScale(new Vector2(1.0, 1.0));
			}
		} else if
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_01) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_02) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_03) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_04) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_05) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_06) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_07) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_08) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_09) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_10) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_11) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_12) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_13) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_14) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_15) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_16) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_17) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_18) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_19) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_20) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_E3V) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_Staff_01) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_Staff_02) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_SongSoRi) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_Robots_01) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_Robots_02) ||
			Equals(atlas, InkAtlasSoubor.LizziesBDs_Postavy_Robots_03)
		{
			picCtrl.SetContentHAlign(inkEHorizontalAlign.Fill);
			picCtrl.SetContentVAlign(inkEVerticalAlign.Fill);
		} else {
			picCtrl.SetContentHAlign(inkEHorizontalAlign.Center);
			picCtrl.SetContentVAlign(inkEVerticalAlign.Top);
		}
	}

	@if(!ModuleExists("NumeralsGetCommas.Functions"))
	public static final func FormatovanaCena(cena: Int32) -> String {
		return IntToString(cena);
	}

	@if(ModuleExists("NumeralsGetCommas.Functions"))
	public static final func FormatovanaCena(cena: Int32) -> String {
		return CommaDelineateInt32(cena);
	}

	public static final func NastavitMoaning(gameInst: GameInstance, entID: EntityID, entGender: GenderType, postava: Int32, jeHrac: Bool, test: Int32) -> Void {
		let lokace: GlobalniID = IntEnum(GameInstance.GetQuestsSystem(gameInst).GetFact(Konstanty.FaktVybranaLokace()));
		
		let lokaceVarianta2: Bool = 
			Equals(lokace, GlobalniID.Lokace_Konpeki) ||
			Equals(lokace, GlobalniID.Lokace_DarkMatter) ||
			Equals(lokace, GlobalniID.Lokace_ArasakaEstate) ||
			Equals(lokace, GlobalniID.Lokace_Hangout_Konpeki) ||
			Equals(lokace, GlobalniID.Lokace_PONC_DarkMatter) ||
			Equals(lokace, GlobalniID.Lokace_DoubleAction_DarkMatter);

		let faktHodTyp: Int32 = 0;
		let jeRobot: Bool = false;
		if test >= 0 {
			faktHodTyp = test;
		} else {
			let faktPostavaRobot: CName = StringToName(Konstanty.FaktVybranyRobot() + ToString(postava));
			jeRobot = GameInstance.GetQuestsSystem(gameInst).GetFact(faktPostavaRobot) == 1;

			let fN: String = Konstanty.FaktVybranyMoaning();
			if !jeHrac {
				fN = fN + "_" + ToString(postava);
			}

			faktHodTyp = GameInstance.GetQuestsSystem(gameInst).GetFact(StringToName(fN));
		}

		let moaningTyp: CName = n"";
		if faktHodTyp == 5 {
			moaningTyp = n"lizzies_bds_sw_moaning_off";
		} else {
			if faktHodTyp == 1 { lokaceVarianta2 = false; }
			if faktHodTyp == 2 { lokaceVarianta2 = true; }

			if Equals(entGender, GenderType.Female) && faktHodTyp == 3 {
				moaningTyp = n"lizzies_bds_sw_moaning_female_jpn_01";
			}
			else if Equals(entGender, GenderType.Female) && faktHodTyp == 4 {
				moaningTyp = n"lizzies_bds_sw_moaning_female_stout_01";
			}
			else if Equals(entGender, GenderType.Female) {
				if jeRobot {
					if lokaceVarianta2 { moaningTyp = n"lizzies_bds_sw_moaning_female_02_robot"; }
					else { moaningTyp = n"lizzies_bds_sw_moaning_female_01_robot"; }
				} else {
					if lokaceVarianta2 { moaningTyp = n"lizzies_bds_sw_moaning_female_02"; }
					else { moaningTyp = n"lizzies_bds_sw_moaning_female_01"; }
				}
			}
			else if Equals(entGender, GenderType.Male) {
				if jeRobot {
					if lokaceVarianta2 { moaningTyp = n"lizzies_bds_sw_moaning_male_02_robot"; }
					else { moaningTyp = n"lizzies_bds_sw_moaning_male_01_robot"; }
				} else {
					if lokaceVarianta2 { moaningTyp = n"lizzies_bds_sw_moaning_male_02"; }
					else { moaningTyp = n"lizzies_bds_sw_moaning_male_01"; }
				}
			}
		}

		GameInstance.GetAudioSystem(gameInst).Switch(n"lizzies_bds_sg_moaning_type", moaningTyp, entID);
	}

	@if(ModuleExists("EquipmentEx"))
	public static final func EquipmentExSeznamOutfitu(game: GameInstance) -> array<CName> {
		let outfitSystem = OutfitSystem.GetInstance(game);
		let outfitNames = outfitSystem.GetOutfits();
		return outfitNames;
	}

	@if(!ModuleExists("EquipmentEx"))
	public static final func EquipmentExSeznamOutfitu(game: GameInstance) -> array<CName> = [];

	@if(ModuleExists("EquipmentEx"))
	public static final func EquipmentExPouzitOutfit(game: GameInstance, nazev: CName, plrStrapon: Int32, naked: Bool) -> Void {
		OutfitSystem.GetInstance(game).LoadOutfit(nazev);

		if plrStrapon == 1 {
			if naked {
				OutfitSystem.GetInstance(game).EquipItem(t"Items.lizzies_bds_item_strapon_legs", t"OutfitSlots.Waist");
			} else {
				OutfitSystem.GetInstance(game).UnequipItem(t"Items.lizzies_bds_item_strapon_legs");
			}
		}
		if plrStrapon == 2 {
			if naked {
				OutfitSystem.GetInstance(game).EquipItem(t"Items.lizzies_bds_item_strapon_dildo_legs", t"OutfitSlots.Waist");
			} else {
				OutfitSystem.GetInstance(game).UnequipItem(t"Items.lizzies_bds_item_strapon_dildo_legs");
			}
		}
	}

	@if(!ModuleExists("EquipmentEx"))
	public static final func EquipmentExPouzitOutfit(game: GameInstance, nazev: CName, plrStrapon: Int32, naked: Bool) -> Void {};
	
	public static final func ZiskatNastaveni(pole: script_ref<array<ref<VybranaPostavaNastaveni>>>, nastaveni: CName) -> Int32 {
		for n in Deref(pole) {
			if Equals(n.NastaveniName, nastaveni) {
				return n.Hodnota;
			}
		}

		return 0;
	}

	public static final func VlozitNastaveni(pole: script_ref<array<ref<VybranaPostavaNastaveni>>>, nastaveni: CName, hodnota: Int32) -> Void {
		let i = 0;
		while i < ArraySize(Deref(pole)) {
			if Equals(Deref(pole)[i].NastaveniName, nastaveni) {
				Deref(pole)[i].Hodnota = hodnota;
				return;
			}
			i += 1;
		}

		let n: ref<VybranaPostavaNastaveni> = new VybranaPostavaNastaveni();
		n.NastaveniName = nastaveni;
		n.Hodnota = hodnota;
		ArrayPush(Deref(pole), n);
	}

	public static final func ZkopirovatNastaveni(zPole: script_ref<array<ref<VybranaPostavaNastaveni>>>, doPole: script_ref<array<ref<VybranaPostavaNastaveni>>>) -> Void {
		Deref(doPole) = [];

		for n in Deref(zPole) {
			let nn: ref<VybranaPostavaNastaveni> = new VybranaPostavaNastaveni();
			nn.NastaveniName = n.NastaveniName;
			nn.Hodnota = n.Hodnota;
			ArrayPush(Deref(doPole), nn);
		}
	}
}

public enum MenuStromPolozkaVybranaAkce {
	Pricist = 0,
	Odecist = 1,
	Ziskat = 2,
	Resetovat = 3
}

public class MenuStrom {
	private let menuStranky: array<ref<MenuStromPolozka>>;
	private let soucasneIDStromu: Int32 = 0;
	private let noveIDStromu: Int32 = 1000;

	public final func Vycistit() -> Void {
		this.menuStranky = [];
	}
	
	public final func ZpracovatMenu(stranka: MenuStrankaTyp, opt vlastniID: Int32) -> Void {
		if Equals(stranka, MenuStrankaTyp.ZpetStranka) {
			this.soucasneIDStromu = this.ZiskatNadrazenouMenuStromPolozku();
		} else if Equals(stranka, MenuStrankaTyp.Soucasne) {
			// nic
		} else {
			let pSID: Int32 = this.Existuje(stranka, vlastniID);
			if pSID > 0 {
				this.soucasneIDStromu = pSID;
			} else {
				let p: ref<MenuStromPolozka> = new MenuStromPolozka();
				p.StromID = this.noveIDStromu;
				p.Stranka = stranka;
				p.VlastniID = vlastniID;
				p.NadrazeneStromID = this.soucasneIDStromu;
				ArrayPush(this.menuStranky, p);

				this.soucasneIDStromu = this.noveIDStromu;
				this.noveIDStromu += 1;
			}
		}
	}

	public final func Soucasne(stranka: MenuStrankaTyp, opt vlastniID: Int32) -> Bool {
		let i = 0;
		while i < ArraySize(this.menuStranky) {
			if this.menuStranky[i].StromID == this.soucasneIDStromu && Equals(this.menuStranky[i].Stranka, stranka) {
				if this.menuStranky[i].VlastniID > 0 {
					if this.menuStranky[i].VlastniID == vlastniID {
						return true;
					} else {
						return false;
					}
				} else if this.menuStranky[i].VlastniID == 0 {
					return true;
				}
			}
			i += 1;
		}

		return false;
	}

	public final func VyberPolozkyVMenu(akce: MenuStromPolozkaVybranaAkce, opt hodnota: Int32, opt maxHodnota: Int32) -> Int32 {
		let i = 0;
		while i < ArraySize(this.menuStranky) {
			if this.menuStranky[i].StromID == this.soucasneIDStromu {
				if Equals(akce, MenuStromPolozkaVybranaAkce.Odecist) {
					this.menuStranky[i].SoucasneVybranaPolozka -= hodnota;
					if this.menuStranky[i].SoucasneVybranaPolozka < 0 { this.menuStranky[i].SoucasneVybranaPolozka = maxHodnota; }
				}
				if Equals(akce, MenuStromPolozkaVybranaAkce.Pricist) {
					this.menuStranky[i].SoucasneVybranaPolozka += hodnota;
					if this.menuStranky[i].SoucasneVybranaPolozka >= maxHodnota { this.menuStranky[i].SoucasneVybranaPolozka = 0; }
				}
				if Equals(akce, MenuStromPolozkaVybranaAkce.Resetovat) {
					this.menuStranky[i].SoucasneVybranaPolozka = 0;
				}
				if Equals(akce, MenuStromPolozkaVybranaAkce.Ziskat) {
					return this.menuStranky[i].SoucasneVybranaPolozka;
				}
				i = 999;
			}
			i += 1;
		}

		return -1;
	}

	public final func StrankovaniOp(op: Int32, opt stranka: Int32) -> Int32 {
		let i = 0;
		while i < ArraySize(this.menuStranky) {
			if this.menuStranky[i].StromID == this.soucasneIDStromu {
				if op == 1 {
					this.menuStranky[i].AktualniStranka = 0;
				}
				if op == 2 {
					this.menuStranky[i].AktualniStranka += 1;
				}
				if op == 3 {
					this.menuStranky[i].AktualniStranka -= 1;
				}
				if op == 4 {
					this.menuStranky[i].AktualniStranka = stranka;
				}

				return this.menuStranky[i].AktualniStranka;
			}
			i += 1;
		}

		return -1;
	}

	public final func SoucasnaStranka() -> ref<MenuStromPolozka> {
		let i = 0;
		while i < ArraySize(this.menuStranky) {
			if this.menuStranky[i].StromID == this.soucasneIDStromu {
				return this.menuStranky[i];
			}
			i += 1;
		}

		return null;
	}

	private final func Existuje(stranka: MenuStrankaTyp, opt vlastniID: Int32) -> Int32 {
		let i = 0;
		while i < ArraySize(this.menuStranky) {
			if Equals(this.menuStranky[i].Stranka, stranka) {
				if this.menuStranky[i].VlastniID > 0 {
					if this.menuStranky[i].VlastniID == vlastniID {
						return this.menuStranky[i].StromID;
					} else {
						return -1;
					}
				} else if this.menuStranky[i].VlastniID == 0 {
					return this.menuStranky[i].StromID;
				}
			}
			i += 1;
		}

		return -1;
	}

	private final func ZiskatNadrazenouMenuStromPolozku() -> Int32 {
		let i = 0;
		while i < ArraySize(this.menuStranky) {
			if this.menuStranky[i].StromID == this.soucasneIDStromu {
				return this.menuStranky[i].NadrazeneStromID;
			}
			i += 1;
		}

		return -1;
	}
}

public class MenuStromPolozka {
	public let StromID: Int32;
	public let Stranka: MenuStrankaTyp;
	public let VlastniID: Int32;
	public let NadrazeneStromID: Int32;
	public let AktualniStranka: Int32 = 0;
	public let SoucasneVybranaPolozka: Int32 = 0;
}

public struct MenuPolozkaData {
	public let Akce: MenuAkceTyp;
	public let Hodnota: Int32;
	public let Data: array<Int32>;
	public let Zakazano: Bool;
	public let AnimaceVybrana: ref<inkAnimProxy>;
	public let AnimaceKonec: ref<inkAnimProxy>;
}

public class VybranaPostava {
	public let PostavaVybrana: Bool = false;

	public let DataPostavy: ref<DataPostavy>;
	public let Nazev: String = "";

	public persistent let PostavaGID: GlobalniID = GlobalniID.Prazdne;
	public persistent let Vzhled: Int32 = 0;
	public persistent let Vlastni: Int32 = 0;
	public persistent let Pohlavi: GenderType = GenderType.None;
	public persistent let Specialni: Bool = false;
	public persistent let VelkaPostava: Bool = false;
	public persistent let Robot: Bool = false;
	public persistent let Nastaveni: array<ref<VybranaPostavaNastaveni>>;

	public func NovaInstance() -> ref<VybranaPostava> {
		let i: ref<VybranaPostava> = new VybranaPostava();
		i.PostavaVybrana = this.PostavaVybrana;
		i.DataPostavy = this.DataPostavy;
		i.Nazev = this.Nazev;
		i.PostavaGID = this.PostavaGID;
		i.Vzhled = this.Vzhled;
		i.Vlastni = this.Vlastni;
		i.Pohlavi = this.Pohlavi;
		i.Specialni = this.Specialni;
		i.VelkaPostava = this.VelkaPostava;
		i.Robot = this.Robot;
		i.Nastaveni = this.Nastaveni;
		return i;
	}

	public func NastavitData(data: ref<DataPostavy>) -> Void {
		this.DataPostavy = data;
		this.Pohlavi = data.Pohlavi;
		this.Specialni = data.JeSpecialniPostava;
		this.VelkaPostava = data.VelkaPostava;
		this.Robot = data.JeRobot;
	}
}

public class VybranaPostavaNastaveni {
	public persistent let NastaveniName: CName;
	public persistent let Hodnota: Int32;
}

public class DataPostavy {
	public let GlobalniID: GlobalniID;
	public let CustomID: Int32;
	public let Cena: Int32;
	public let Fakt: String;
	public let JeEP1: Bool;
	public let Autor: String;
	public let JeKateg: Bool;
	public let NastaveniKateg: Bool;
	public let VelkaPostava: Bool;
	public let Vzhledy: array<ref<DataVzhled>>;
	public let VlozitDoMenu: array<MenuStrankaTyp>;
	public let VlozitDoMenuVlastni: array<Int32>;
	public let Pohlavi: GenderType;
	public let JeSpecialniPostava: Bool;
	public let VlastniPostavaEnt: ResRef;
	public let MaSlevu: Int32;
	public let PrirazenaStranka: MenuStrankaTyp;
	public let JeKoupena: array<Int32>;
	public let JeRobot: Bool;

	public final func NastavitSlevu(sleva: Int32) -> Void {
		if sleva > this.MaSlevu {
			this.MaSlevu = sleva;
			this.Cena = CeilF(Cast<Float>(this.Cena) - (Cast<Float>(this.Cena) * Cast<Float>(sleva) / 100.0));
		}
	}

	public final func ZiskatNazevPostavy(opt vzhled: Int32) -> String {
		if vzhled > 0 {
			let str: String = GlobalniFunkce.TextLocKey(this.Vzhledy[0].ZiskatNazev());
			str = str + " - " + this.Vzhledy[vzhled].ZiskatNazev();
			return str;
		} else if Equals(this.GlobalniID, GlobalniID.Postava_Vlastni_Zena) || Equals(this.GlobalniID, GlobalniID.Postava_Vlastni_Muz) {
			return this.Vzhledy[0].ZiskatNazev();
		}
		
		return GetLocalizedText(this.Vzhledy[0].ZiskatNazev());
	}
	
	public final func ZiskatPopis() -> String = GlobalniFunkce.TextLocKey(this.Vzhledy[0].ZiskatPopis());

	public final func FaktPostavy() -> CName {
		return StringToName("lizzies_bds_char_" + this.Fakt);
	}

	public static final func Postava(globalniID: GlobalniID, pohlavi: GenderType, nazev: String, economy: String, fakt: String, jeEP1: Bool, obrAtlasID: InkAtlasSoubor, obrAtlasNazev: CName, obrVelikost: Float,
			autor: String, velkaPostava: Bool, vlozitDoMenu: array<MenuStrankaTyp>) -> ref<DataPostavy> {
		
		let vzhledy: array<ref<DataVzhled>> = [
			DataVzhled.Vytvorit(nazev, "", obrAtlasID, obrAtlasNazev, obrVelikost)
		];
		
		let p: ref<DataPostavy> = new DataPostavy();
		p.GlobalniID = globalniID;
		p.CustomID = 0;
		p.Fakt = fakt;
		p.JeEP1 = jeEP1;
		p.Autor = autor;
		p.JeKateg = false;
		p.NastaveniKateg = false;
		p.VelkaPostava = velkaPostava;
		p.Vzhledy = vzhledy;
		p.VlozitDoMenu = vlozitDoMenu;
		p.Pohlavi = pohlavi;
		p.JeSpecialniPostava = false;
		p.Cena = GlobalniFunkce.ZiskatCenu(economy);
		p.JeRobot = false;
		return p;
	}

	public static final func Kateg(globalniID: GlobalniID, prirazenaStranka: MenuStrankaTyp, nazev: String, fakt: String, jeEP1: Bool, obrAtlasID: InkAtlasSoubor, obrAtlasNazev: CName, obrVelikost: Float,
			jeKateg: Bool, nastaveniKateg: Bool, jeSpecialni: Bool, vlozitDoMenu: array<MenuStrankaTyp>) -> ref<DataPostavy> {
		
		let vzhledy: array<ref<DataVzhled>> = [
			DataVzhled.Vytvorit(nazev, "", obrAtlasID, obrAtlasNazev, obrVelikost)
		];
		
		let p: ref<DataPostavy> = new DataPostavy();
		p.GlobalniID = globalniID;
		p.CustomID = 0;
		p.Cena = 0;
		p.Fakt = fakt;
		p.JeEP1 = jeEP1;
		p.Autor = "";
		p.JeKateg = jeKateg;
		p.NastaveniKateg = nastaveniKateg;
		p.VelkaPostava = false;
		p.Vzhledy = vzhledy;
		p.VlozitDoMenu = vlozitDoMenu;
		p.Pohlavi = GenderType.None;
		p.JeSpecialniPostava = jeSpecialni;
		p.PrirazenaStranka = prirazenaStranka;
		p.JeRobot = false;
		return p;
	}

	public static final func PostavaVzhledy(globalniID: GlobalniID, pohlavi: GenderType, nazev: String, economy: String, fakt: String, jeEP1: Bool, obrAtlasID: InkAtlasSoubor, obrAtlasNazev: CName, obrVelikost: Float,
			autor: String, velkaPostava: Bool, vlozitDoMenu: array<MenuStrankaTyp>, vzhledy: array<ref<DataVzhled>>) -> ref<DataPostavy> {
		let p: ref<DataPostavy> = DataPostavy.Postava(globalniID, pohlavi, nazev, economy, fakt, jeEP1, obrAtlasID, obrAtlasNazev, obrVelikost, autor, velkaPostava, vlozitDoMenu);
		for vzhled in vzhledy {
			ArrayPush(p.Vzhledy, vzhled);
		}
		return p;
	}

	public static final func Specialni(globalniID: GlobalniID, pohlavi: GenderType, nazev: String, economy: String, fakt: String, jeEP1: Bool, obrAtlasID: InkAtlasSoubor, obrAtlasNazev: CName, obrVelikost: Float,
			autor: String, velkaPostava: Bool, vlozitDoMenu: array<MenuStrankaTyp>, vzhledy: array<ref<DataVzhled>>) -> ref<DataPostavy> {
		let p: ref<DataPostavy> = DataPostavy.Postava(globalniID, pohlavi, nazev, economy, fakt, jeEP1, obrAtlasID, obrAtlasNazev, obrVelikost, autor, velkaPostava, vlozitDoMenu);
		for vzhled in vzhledy {
			ArrayPush(p.Vzhledy, vzhled);
		}
		p.JeSpecialniPostava = true;
		return p;
	}

	public static final func PostavaRobot(globalniID: GlobalniID, pohlavi: GenderType, nazev: String, economy: String, fakt: String, jeEP1: Bool, obrAtlasID: InkAtlasSoubor, obrAtlasNazev: CName, obrVelikost: Float,
			autor: String, velkaPostava: Bool, vlozitDoMenu: array<MenuStrankaTyp>, vzhledy: array<ref<DataVzhled>>) -> ref<DataPostavy> {
		let p: ref<DataPostavy> = DataPostavy.Postava(globalniID, pohlavi, nazev, economy, fakt, jeEP1, obrAtlasID, obrAtlasNazev, obrVelikost, autor, velkaPostava, vlozitDoMenu);
		p.JeRobot = true;
		for vzhled in vzhledy {
			ArrayPush(p.Vzhledy, vzhled);
		}
		return p;
	}
}

public enum NastaveniTyp {
	Globalni = 0,
	Postava = 1,
	Lokace = 2,
	PV = 3
}

public struct DataNastaveni {
	public let GlobalniID: GlobalniID;
	public let Nazev: String;
	public let Typ: NastaveniTyp;
	public let FaktZobrazeni: Bool;
	public let NazevProKonzoli: String;
	public let FaktKeZmene: CName;
	public let Popis: String;
	public let HodnotaZakazano: Int32;
	public let VlastniMoznosti: array<String>;
}

public class DataHudby {
	public let ID: Int32;
	public let Nazev: String;
	public let PouzeHangout: Bool;
	public let JeVlastni: Bool;
	public let Popis: String;
	public let Autor: String;

	public let Eventy: array<CustomMusicEvent>;

	public static final func Pridat(ID: Int32, Nazev: String, PouzeHangout: Bool) -> ref<DataHudby> {
		let a: ref<DataHudby> = new DataHudby();
		a.ID = ID;
		a.Nazev = Nazev;
		a.PouzeHangout = PouzeHangout;
		return a;
	}

	public static final func PridatVlastni(Nazev: String, Popis: String, Autor: String, Eventy: array<CustomMusicEvent>) -> ref<DataHudby> {
		let hash: Uint32 = Murmur3(Nazev + Popis + Autor);
		let id: Int32 = RoundF(Cast<Float>(hash) / 3.0);

		let a: ref<DataHudby> = new DataHudby();
		a.ID = id;
		a.Nazev = GlobalniFunkce.TextLocKey(Nazev);
		a.Popis = GlobalniFunkce.TextLocKey(Popis);
		a.Autor = Autor;
		a.Eventy = Eventy;
		return a;
	}
}

public class DataLokace {
	public let GlobalniID: GlobalniID;
	public let Nazev: String;
	public let NazevUplny: String;
	public let Popis: String;
	public let Fakt: Bool = true;
	public let ObrAtlasID: InkAtlasSoubor;
	public let ObrAtlasNazev: CName;
	public let PodporujeOpakovani: Bool = false;
	public let PodporujeVelkouPostavu: Bool = false;
	public let ExtData: Int32 = 0;
	public let PocetPostav: Int32 = 1;
	public let BezPostavy: Bool = false;
	public let Cena: Int32 = 0;
	public let PouzeProPohlavi: GenderType = GenderType.None;
	public let InteraktivniPV: Bool = false;
	public let PohlaviSpolecne: Bool = false;
	public let Kontejner: array<ref<DataLokace>>;
	public let JeKoupena: Bool = false;
	public let Nadrazene: ref<DataLokace>;
	public let VychoziHudba: Int32;
	public let VolnePV: Bool = false;
	public let PodporujeReplacer: Bool = false;
	public let PodporujeSpecialni: Bool = false;

	public static func Lk(globalniID: GlobalniID, nazev: String, popis: String, fakt: Bool, obrAtlasID: InkAtlasSoubor, obrAtlasNazev: CName, podporujeOpakovani: Bool, podporujeVelkouPostavu: Bool,
		faktJizBrzy: Bool, pocetPostav: Int32, interaktivniPV: Bool, pouzeProPohlavi: GenderType, pohlaviSpolecne: Bool, vychoziHudba: Int32, specialniPostavy: Bool) -> ref<DataLokace> {
		let p: ref<DataLokace> = new DataLokace();
		p.GlobalniID = globalniID;
		p.Nazev = nazev;
		p.Popis = popis;
		p.Fakt = fakt;
		p.ObrAtlasID = obrAtlasID;
		p.ObrAtlasNazev = obrAtlasNazev;
		p.PodporujeOpakovani = podporujeOpakovani;
		p.PodporujeVelkouPostavu = podporujeVelkouPostavu;
		p.ExtData = faktJizBrzy ? 1 : 0;
		p.PocetPostav = pocetPostav;
		p.PouzeProPohlavi = pouzeProPohlavi;
		p.InteraktivniPV = interaktivniPV;
		p.PohlaviSpolecne = pohlaviSpolecne;
		p.VychoziHudba = vychoziHudba;
		p.Kontejner = [];
		p.PodporujeReplacer = true;
		p.PodporujeSpecialni = specialniPostavy;
		return p;
	}

	public static func LS(globalniID: GlobalniID, nazev: String, popis: String, fakt: Bool, obrAtlasID: InkAtlasSoubor, obrAtlasNazev: CName, faktJizBrzy: Bool, faktChybiData: Bool, economy: String,
		interaktivniPV: Bool) -> ref<DataLokace> {
		let p: ref<DataLokace> = new DataLokace();
		p.GlobalniID = globalniID;
		p.Nazev = nazev;
		p.Popis = popis;
		p.Fakt = fakt;
		p.ObrAtlasID = obrAtlasID;
		p.ObrAtlasNazev = obrAtlasNazev;
		p.ExtData = faktChybiData ? 2 : (faktJizBrzy ? 1 : 0);
		p.BezPostavy = true;
		p.Cena = GlobalniFunkce.ZiskatCenu(economy);
		p.InteraktivniPV = interaktivniPV;
		p.Kontejner = [];
		p.VychoziHudba = 2;
		return p;
	}

	public static func Kt(globalniID: GlobalniID, nazev: String, popis: String, fakt: Bool, obrAtlasID: InkAtlasSoubor, obrAtlasNazev: CName, podporujeOpakovani: Bool, interaktivniPV: Bool,
		faktChybiData: Bool, kontejner: array<ref<DataLokace>>) -> ref<DataLokace> {
		let p: ref<DataLokace> = new DataLokace();
		p.GlobalniID = globalniID;
		p.Nazev = nazev;
		p.Popis = popis;
		p.Fakt = fakt;
		p.ObrAtlasID = obrAtlasID;
		p.ObrAtlasNazev = obrAtlasNazev;
		p.PodporujeOpakovani = podporujeOpakovani;
		p.InteraktivniPV = interaktivniPV;
		p.ExtData = faktChybiData ? 2 : 0;
		p.Kontejner = kontejner;
		return p;
	}
	
	public static func LB(globalniID: GlobalniID, nazev: String, obrAtlasID: InkAtlasSoubor, obrAtlasNazev: CName, fakt: Bool, faktJizBrzy: Bool) -> ref<DataLokace> {
		let p: ref<DataLokace> = new DataLokace();
		p.GlobalniID = globalniID;
		p.Nazev = nazev;
		p.Popis = "";
		p.ObrAtlasID = obrAtlasID;
		p.ObrAtlasNazev = obrAtlasNazev;
		p.PodporujeVelkouPostavu = true;
		p.Kontejner = [];
		p.Fakt = fakt;
		p.ExtData = faktJizBrzy ? 1 : 0;
		return p;
	}

	public static func LL(globalniID: GlobalniID, nazev: String, popis: String, vychoziHudba: Int32) -> ref<DataLokace> {
		let p: ref<DataLokace> = new DataLokace();
		p.GlobalniID = globalniID;
		p.Nazev = nazev;
		p.Popis = popis;
		p.ObrAtlasID = InkAtlasSoubor.Prazdne;
		p.ObrAtlasNazev = n"";
		p.BezPostavy = true;
		p.Kontejner = [];
		p.VychoziHudba = vychoziHudba;
		p.VolnePV = true;
		return p;
	}
}

public class DataVzhled {
	public let Nazev: String;
	public let Popis: String;
	public let ObrAtlasID: InkAtlasSoubor;
	public let ObrAtlasNazev: CName;
	public let ObrVelikost: Float;
	public let ObrAtlasCesta: ResRef;
	public let VlastniVzhledNormalni: CName;
	public let VlastniVzhledExplicitni: CName;
	public let VlastniStatickyObr: Bool;
	
	public static func Vytvorit(Nazev: String, Popis: String, ObrAtlasID: InkAtlasSoubor, ObrAtlasNazev: CName, ObrVelikost: Float) -> ref<DataVzhled> {
		let c: ref<DataVzhled> = new DataVzhled();
		c.Nazev = Nazev;
		c.Popis = Popis;
		c.ObrAtlasID = ObrAtlasID;
		c.ObrAtlasNazev = ObrAtlasNazev;
		c.ObrVelikost = ObrVelikost == 0.0 ? 1.15 : ObrVelikost;
		c.ObrAtlasCesta = r"";
		return c;
	}
	
	public static func VytvoritVlastniObr(Nazev: String, Popis: String, vzhledNormalni: CName, vzhledExplicitni: CName, ObrAtlasCesta: ResRef, ObrAtlasNazev: CName, ObrVelikost: Float, StatickyObr: Bool) -> ref<DataVzhled> {
		let c: ref<DataVzhled> = new DataVzhled();
		c.Nazev = Nazev;
		c.Popis = Popis;
		c.ObrAtlasID = InkAtlasSoubor.Prazdne;
		c.ObrAtlasNazev = ObrAtlasNazev;
		c.ObrVelikost = ObrVelikost + 1.2;
		c.ObrAtlasCesta = ObrAtlasCesta;
		c.VlastniVzhledNormalni = vzhledNormalni;
		c.VlastniVzhledExplicitni = vzhledExplicitni;
		c.VlastniStatickyObr = StatickyObr;
		return c;
	}

	public final func ZiskatNazev() -> String = GlobalniFunkce.TextLocKey(this.Nazev);
	public final func ZiskatPopis() -> String = GlobalniFunkce.TextLocKey(this.Popis);
}

public struct DataObliceje {
	public let KlidNazev: array<String>;
	public let PozaNazev: array<String>;
	public let KlidAnimace: array<CName>;
	public let PozaAnimace: array<CName>;
}

public enum GenderType {
	None = 0,
	Female = 2,
	Male = 1,
	Robot = 3,
	MentallyIll = 4
}

public struct DialogStack {
	public let Typ: Int32;
	public let Velikost: Float;
	public let Nadpis: String;
	public let Popis: String;
}

public class CustomCharacterLoaderEvent extends Event {
	private let lizziesBDsMain: wref<LizziesBDsMain>;

	public final func NastavitSystemInstanci(system: ref<LizziesBDsMain>) -> Void {
		this.lizziesBDsMain = system;
	}

	public final func AddCharacter(Gender: GenderType, Price: Int32, EntityPath: ResRef, Appearances: array<CustomCharacterApp>) -> Void {
		this.PridatPostavu(Gender, Price, EntityPath, "", Appearances, [], false);
	}

	public final func AddCharacterV2(Gender: GenderType, Price: Int32, EntityPath: ResRef, Author: String, Appearances: array<CustomCharacterApp>) -> Void {
		this.PridatPostavu(Gender, Price, EntityPath, Author, Appearances, [], false);
	}

	public final func AddCharacterV3(Gender: GenderType, Price: Int32, EntityPath: ResRef, Author: String, OnlySFW: Bool, Appearances: array<CustomCharacterApp>) -> Void {
		this.PridatPostavu(Gender, Price, EntityPath, Author, Appearances, [], OnlySFW);
	}

	public final func AddCharacterCateg(Gender: GenderType, Price: Int32, EntityPath: ResRef, Author: String, Appearances: array<CustomCharacterApp>, Categs: array<Int32>) -> Void {
		this.PridatPostavu(Gender, Price, EntityPath, Author, Appearances, Categs, false);
	}

	public final func AddCharacterCategV3(Gender: GenderType, Price: Int32, EntityPath: ResRef, Author: String, OnlySFW: Bool, Appearances: array<CustomCharacterApp>, Categs: array<Int32>) -> Void {
		this.PridatPostavu(Gender, Price, EntityPath, Author, Appearances, Categs, OnlySFW);
	}

	private final func PridatPostavu(Pohlavi: GenderType, Cena: Int32, VlastniPostavaEnt: ResRef, Autor: String, Vzhledy: array<CustomCharacterApp>, KategVlastni: array<Int32>, specialni: Bool) -> Void {
		let velikost: Int32 = ArraySize(Vzhledy);
		let vzhledyInt: array<ref<DataVzhled>>;
		
		let j = 0;
		while j < velikost {
			ArrayPush(vzhledyInt, DataVzhled.VytvoritVlastniObr(Vzhledy[j].Nazev, Vzhledy[j].Popis, Vzhledy[j].VzhledNormalni, Vzhledy[j].VzhledExplicitni, Vzhledy[j].AtlasCesta, Vzhledy[j].AtlasKlic, Vzhledy[j].ObrVelikost, Vzhledy[j].StatickyObr));
			j += 1;
		}

		let hash: Uint32 = Murmur3(ToString(Cena) + VlastniPostavaEnt.ToString() + Vzhledy[0].Nazev + NameToString(Vzhledy[0].VzhledNormalni));
		let id: Int32 = RoundF(Cast<Float>(hash) / 3.0);

		let p: ref<DataPostavy> = new DataPostavy();
		p.GlobalniID = Equals(Pohlavi, GenderType.Female) ? GlobalniID.Postava_Vlastni_Zena : GlobalniID.Postava_Vlastni_Muz;
		p.CustomID = id;
		p.Cena = Cena;
		p.Fakt = "";
		p.JeEP1 = false;
		p.Autor = Autor;
		p.JeKateg = false;
		p.NastaveniKateg = false;
		p.VelkaPostava = false;
		p.Vzhledy = vzhledyInt;
		p.VlozitDoMenu = [MenuStrankaTyp.Kateg_Vlastni];
		p.VlozitDoMenuVlastni = KategVlastni;
		p.Pohlavi = Pohlavi;
		p.JeSpecialniPostava = specialni;
		p.VlastniPostavaEnt = VlastniPostavaEnt;

		this.lizziesBDsMain.PridatVlastniPostavu(p);
	}

	public final func AddCategory(Name: String, Description: String, Author: String) -> Int32 {
		return this.AddCategoryPic(Name, Description, Author, r"", n"", 0);
	}

	public final func AddCategoryPic(Name: String, Description: String, Author: String, AtlasPath: ResRef, AtlasPartName: CName, PictureZoom: Float) -> Int32 {
		let vzhledyInt: array<ref<DataVzhled>> = [
			DataVzhled.VytvoritVlastniObr(Name, Description, n"", n"", AtlasPath, AtlasPartName, PictureZoom, true)
		];
		
		let hash: Uint32 = Murmur3(Name + Description + Author);
		let id: Int32 = RoundF(Cast<Float>(hash) / 3.0);

		let p: ref<DataPostavy> = new DataPostavy();
		p.GlobalniID = GlobalniID.Kategorie16;
		p.CustomID = id;
		p.Fakt = "";
		p.JeEP1 = false;
		p.Autor = Author;
		p.JeKateg = true;
		p.NastaveniKateg = false;
		p.Vzhledy = vzhledyInt;
		p.VlozitDoMenu = [MenuStrankaTyp.Menu_Zeny, MenuStrankaTyp.Menu_Muzi];
		p.JeSpecialniPostava = false;
		p.PrirazenaStranka = MenuStrankaTyp.Kateg_Vlastni;

		this.lizziesBDsMain.PridatVlastniPostavu(p);

		return id;
	}
}

public struct CustomCharacterApp {
	public let Nazev: String;
	public let Popis: String;
	public let VzhledNormalni: CName;
	public let VzhledExplicitni: CName;
	public let AtlasCesta: ResRef;
	public let AtlasKlic: CName;
	public let ObrVelikost: Float;
	public let StatickyObr: Bool;

	public static func Create(Name: String, Description: String, ApperaranceDefault: CName, ApperaranceNaked: CName) -> CustomCharacterApp =
		new CustomCharacterApp(Name, Description, ApperaranceDefault, ApperaranceNaked, r"", n"", 0, true);

	public static func CreateV2(Name: String, Description: String, AllowDynamicPreview: Bool, ApperaranceDefault: CName, ApperaranceNaked: CName) -> CustomCharacterApp =
		new CustomCharacterApp(Name, Description, ApperaranceDefault, ApperaranceNaked, r"", n"", 0, !AllowDynamicPreview);

	public static func CreateV3(Name: String, Description: String, AllowDynamicPreview: Bool, ApperaranceDefault: CName, ApperaranceNaked: CName) -> CustomCharacterApp =
		new CustomCharacterApp(Name, Description, ApperaranceDefault, ApperaranceNaked, r"", n"", 0, !AllowDynamicPreview);

	public static func CreatePic(Name: String, Description: String, AtlasPath: ResRef, AtlasPartName: CName, PictureZoom: Float, ApperaranceDefault: CName, ApperaranceNaked: CName) -> CustomCharacterApp =
		new CustomCharacterApp(Name, Description, ApperaranceDefault, ApperaranceNaked, AtlasPath, AtlasPartName, PictureZoom, true);

	public static func CreatePicV2(Name: String, Description: String, AtlasPath: ResRef, AtlasPartName: CName, PictureZoom: Float, ForceStaticPic: Bool, ApperaranceDefault: CName, ApperaranceNaked: CName) -> CustomCharacterApp =
		new CustomCharacterApp(Name, Description, ApperaranceDefault, ApperaranceNaked, AtlasPath, AtlasPartName, PictureZoom, ForceStaticPic);

	public static func CreatePicV3(Name: String, Description: String, AtlasPath: ResRef, AtlasPartName: CName, PictureZoom: Float, ForceStaticPic: Bool, ApperaranceDefault: CName, ApperaranceNaked: CName) -> CustomCharacterApp =
		new CustomCharacterApp(Name, Description, ApperaranceDefault, ApperaranceNaked, AtlasPath, AtlasPartName, PictureZoom, ForceStaticPic);
}

public enum MusicEventType {
	Skip = 0,
	Event = 1,
	Switch = 2,
	//Mix = 3,
	EventStop = 4
}

public struct CustomMusicEvent {
	public let Type: MusicEventType;
	public let Val1: CName;
	public let Val2: CName;

	public static final func AudioSkip() -> CustomMusicEvent =
		new CustomMusicEvent(MusicEventType.Skip, n"", n"");

	public static final func AudioEvent(EventName: CName) -> CustomMusicEvent =
		new CustomMusicEvent(MusicEventType.Event, EventName, n"");

	public static final func AudioSwitch(SwitchGroupName: CName, SwitchName: CName) -> CustomMusicEvent =
		new CustomMusicEvent(MusicEventType.Switch, SwitchGroupName, SwitchName);

	//public static final func AudioMix(MixName: CName) -> CustomMusicEvent =
	//	new CustomMusicEvent(MusicEventType.Mix, MixName, n"");

	public static final func AudioEventStop(EventName: CName) -> CustomMusicEvent =
		new CustomMusicEvent(MusicEventType.EventStop, EventName, n"");
}

public class CustomMusicLoaderEvent extends Event {
	private let lizziesBDsMain: wref<LizziesBDsMain>;

	public final func NastavitSystemInstanci(system: ref<LizziesBDsMain>) -> Void {
		this.lizziesBDsMain = system;
	}

	public final func AddMusic(Name: String, Description: String, Author: String, Events: array<CustomMusicEvent>) -> Void {
		if ArraySize(Events) != 4 {
			return;
		}

		let a: ref<DataHudby> = DataHudby.PridatVlastni(Name, Description, Author, Events);
		this.lizziesBDsMain.PridatVlastniHudbu(a);
	}
}

public class LizziesBDsMenuUIPoInitu extends Event {
	public let MenuUIInstance: ref<MenuUIController>;
}

public class LizziesBDsMenuUIPoNacteniPostav extends Event {
	public let DataPostav: array<ref<DataPostavy>>;
}
