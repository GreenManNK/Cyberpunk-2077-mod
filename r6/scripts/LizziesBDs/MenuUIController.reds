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

module LizziesBDs.UI

import Codeware.UI.*
import LizziesBDs.Classes.*
import LizziesBDs.Data.*
import LizziesBDs.Main.*
import LizziesBDs.Storage.*
import LizziesBDs.Resources.*

@if(ModuleExists("LizziesBDs.OnlineFeatures"))
import LizziesBDs.OnlineFeatures.*

public class VVListenerCallback extends DelayCallback {
	public let controller: wref<MenuUIController>;
	public let typ: Int32;
	public func Call() -> Void {
		this.controller.ZobrazVelikonocniVajicko(this.typ);
	}
}

public class KlikListenerCallback extends DelayCallback {
	public let controller: wref<MenuUIController>;
	public func Call() -> Void {
		this.controller.dvojityKlik = true;
	}
}

public class DynPrewListenerCallback extends DelayCallback {
	public let questsSystem: wref<QuestsSystem>;
	public func Call() -> Void {
		this.questsSystem.SetFact(Konstanty.FaktDynamickyNahled(), 1);
	}
}

enum SpecTlacAkce {
	ZadnaAkce = 0,
	OblibenePridat = 1,
	OblibeneOdstranit = 2,
	NastaveniZpetne = 3,
	NahledHudby = 4
}

public class MenuUIController extends inkGameController {
	private let player: wref<PlayerPuppet>;
	private let game: GameInstance;
	private let questsSystem: wref<QuestsSystem>;
	private let uiSystem: wref<UISystem>;
	private let audioSystem: wref<AudioSystem>;
	private let lizziesBDsSystem: wref<LizziesBDsMain>;
	private let lizziesBDsUloziste: wref<LizziesBDsUloziste>;
	private let lizziesBDsOnline: wref<LizziesBDsOnlineFunkce>;
	private let lizziesBDsResources: wref<LizziesBDsResources>;

	private const let factClipCount: CName = n"lizzies_bds_joytoy_repeat_sel";
	private const let factPlayerGender: CName = n"lizzies_bds_gender";
	private const let factApartment: CName = n"lizzies_bds_apartment";
	private const let factStreaming: CName = n"lizzies_bds_stream";
	private const let factStreamingMsg: CName = n"lizzies_bds_stream_msg";
	private const let factBarLoc: CName = n"lizzies_bds_bar_loc";
	private const let factBoughtBD: CName = n"lizzies_bds_bought_bd";
	private const let factMusicToggle: CName = n"lizzies_bds_toggle_music";
	private const let factViews: CName = n"lizzies_bds_views";
	private const let factLover: CName = n"lizzies_bds_pozvani_do_bytu_lover";
	private const let factER: CName = n"lizzies_bds_er_bought";
	private const let factUISel: CName = n"lizzies_bds_menu_ui_sel";

	private let tlacitkaCtrl: ref<inkCompoundWidget>;
	private let tlacitkaTrvaleCtrl: ref<inkCompoundWidget>;
	private let menuTrvaleCtrl: ref<inkWidget>;

	private let m_startupAnimProxy: ref<inkAnimProxy>;
	private let m_closeAnimProxy: ref<inkAnimProxy>;
	private let animaceVybranaDef: ref<inkAnimDef>;
	private let animaceKonecDef: ref<inkAnimDef>;
	private let animaceDialogProxy: ref<inkAnimProxy>;

	//private let streamovaniAktivni: Bool = false;
	private let pouzeMox: Bool = false;
	private let menuAkceTyp: MenuAkceTyp = MenuAkceTyp.Prazdne;
	private let menuAkceData: Int32 = 0;
	private let menuVybranaPostavaDocasna: ref<VybranaPostava>;
	private let menuVybranaPostavaPole: array<ref<VybranaPostava>>;
	private let menuVybranaLokace: ref<DataLokace>;
	private let menuVybranaLokaceEpizoda: ref<DataLokace>;
	//private let menuVybranyPocetOpakovani: Int32;
	//private let menuVybranaHudba: Int32;
	private let menuVybraneNastaveni: array<ref<VybranaPostavaNastaveni>>;
	private let posledniIndexMoznosti: Int32 = 0;
	private let polePolozkyMenu: array<MenuPolozkaData>;
	private let soucasnyIndexPolozky: Int32 = 0;
	private let soucasnyIndexGenerovaniStranky: Int32 = 0;
	private let maximalniPocetStranek: Int32 = 0;
	private let pocetPolozekVKategorii: Int32 = 0;
	private let vlastniBarva: HDRColor;
	private let vlastniBarvaVyber: HDRColor;
	private let vlastniBarvaPozadi: HDRColor;
	private let nastaveniBinarniZobrazeni: String = "";
	private let polePostavData: array<ref<DataPostavy>>;
	private let poleNastaveniData: array<DataNastaveni>;
	private let poleLokaciData: array<ref<DataLokace>>;
	private let poleHudbyData: array<ref<DataHudby>>;
	private let ep1JeInstalovane: Bool;
	private let nahotaJePovolena: Bool;
	private let velikonocniVajickoZobrazeno: Bool = false;
	private let vlastniZeny: Bool = false;
	private let vlastniMuzi: Bool = false;
	private let akceMenuZpet: MenuAkceTyp = MenuAkceTyp.Prazdne;
	private let vybranePohlavi: GenderType = GenderType.Female;
	private let VVIDProdlevy: DelayID;
	private let VVIDProdlevy2: DelayID;
	private let dvojityKlikProdlevaID: DelayID;
	public let dvojityKlik: Bool = true;
	private let ovladaniStranky: Bool = false;
	private let zobrazitZakladniNavigaci: Bool = true;
	private let specialniTlacitkoAkce: SpecTlacAkce = SpecTlacAkce.ZadnaAkce;
	private let specialniTlacitko: Bool = false;
	private let menuLokaceAktivni: Bool = false;
	private let lokaceVyberPostavVybP: Int32 = 0;
	//private let lokaceVyberPostavVybPole: array<Bool>;
	private let oblibeneVybraneID: Int32 = 0;
	private let menuTrvale: Int32 = 0;
	private let hlavniNadpisText: String;
	private let hracPenize: Int32 = 0;
	private let poleOblicejuData: DataObliceje;
	private let menuStrom: ref<MenuStrom>;
	private let cybCeny: Bool;
	private let dialogAktivni: Int32 = 0;
	private let soucasnyEvent: Int32 = 4;
	private let aktivniTypMenu: MenuUITyp = MenuUITyp.Zadne;
	private let postavaMoznostiOblicejZkop: Bool = false;
	private let nahledHudbyAktivni: Bool = false;
	private let nahledHudbyAktivniCtrlPic: ref<inkImage>;
	private let dynamickyNahledProdleva: DelayID;
	private let pozvaniDoBytuAktivni: Bool = false;
	private let spatnaVerze: Bool = false;
	private let dialogRada: array<DialogStack>;
	private let dialogRadaVyb: Int32 = 0;
	private let mensiVerzeMenu: Bool = false;

	protected cb func OnInitialize() -> Bool {
		ArchiveXL.Version();

		this.player = this.GetPlayerControlledObject() as PlayerPuppet;
		this.game = this.player.GetGame();
		this.questsSystem = GameInstance.GetQuestsSystem(this.game);
		this.uiSystem = GameInstance.GetUISystem(this.game);
		this.audioSystem = GameInstance.GetAudioSystem(this.game);
		this.lizziesBDsSystem = LizziesBDsMain.ZiskatInstanci(this.game);
		this.lizziesBDsUloziste = LizziesBDsUloziste.ZiskatInstanci(this.game);
		this.lizziesBDsOnline = LizziesBDsOnlineFunkce.ZiskatInstanci(this.game);
		this.lizziesBDsResources = GameInstance.GetScriptableServiceContainer().GetService(n"LizziesBDs.Resources.LizziesBDsResources") as LizziesBDsResources;

		this.spatnaVerze = NotEquals(GameInstance.GetSystemRequestsHandler().GetGameVersion(), "2.31");
		if this.questsSystem.GetFact(n"lizzies_bds_spec_edition") == 1 {
			this.spatnaVerze = false;
		}
		
		this.ep1JeInstalovane = this.GetSystemRequestsHandler().IsAdditionalContentInstalled(n"EP1"); //this.questsSystem.GetFact(n"ep1_installed") == 1;
		this.zobrazitZakladniNavigaci = this.questsSystem.GetFact(Konstanty.FaktZakladniNavigace()) == 0;
		this.pouzeMox = this.questsSystem.GetFact(Konstanty.FaktPouzeMox()) == 1 || GlobalniFunkce.PouzeMox();
		//this.streamovaniAktivni = this.questsSystem.GetFact(this.factApartment) > 0;
		this.questsSystem.SetFact(Konstanty.FaktMenuUIAktivni(), 1);
		this.questsSystem.SetFact(this.factBoughtBD, 0);
		this.cybCeny = this.questsSystem.GetFact(n"lizzies_bds_cyb_prices") == 1;
		this.pozvaniDoBytuAktivni = this.questsSystem.GetFact(n"lizzies_bds_pozvani_do_bytu") == 1;

		this.questsSystem.SetFact(Konstanty.FaktFeatPONC(), this.lizziesBDsResources.poncInstalovan ? 1 : 0);

		this.NastavitExplicitniObsah();

		let menuFakt: Int32 = this.questsSystem.GetFact(Konstanty.FaktMenuUI());
		this.aktivniTypMenu = IntEnum(menuFakt);

		if
			Equals(this.aktivniTypMenu, MenuUITyp.Normalni) ||
			Equals(this.aktivniTypMenu, MenuUITyp.Streamovani) ||
			Equals(this.aktivniTypMenu, MenuUITyp.Pevecka) ||
			Equals(this.aktivniTypMenu, MenuUITyp.Recepce) ||
			Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) ||
			Equals(this.aktivniTypMenu, MenuUITyp.KoupeniPV)
		{
			this.ResetovatFakta();
			this.lizziesBDsOnline.ZiskatData();
		}

		if
			Equals(this.aktivniTypMenu, MenuUITyp.VyberHudby) ||
			Equals(this.aktivniTypMenu, MenuUITyp.PostavaMoznosti)
		{
			this.mensiVerzeMenu = true;
		}
		
		this.lizziesBDsUloziste.Nacist(Equals(this.aktivniTypMenu, MenuUITyp.Pevecka));

		if Equals(this.aktivniTypMenu, MenuUITyp.NastaveniRuzne) || Equals(this.aktivniTypMenu, MenuUITyp.Debug) {
			this.poleNastaveniData = DataPoleNastaveni(this.nahotaJePovolena);
		} else if Equals(this.aktivniTypMenu, MenuUITyp.BarVyberLokace) {
			this.poleLokaciData = DataPoleBarLokace(this.ep1JeInstalovane, this.questsSystem);
		} else {
			this.NacistDataPostav();
			this.NacistLokace();
			this.NacistHudbu();
		}

		if Equals(this.aktivniTypMenu, MenuUITyp.PostavaMoznosti) {
			this.poleOblicejuData = DataPoleOblicejeNazvy();

			this.NastavitVybranePostavyPole(6);

			let i = 0;
			while i < ArraySize(this.menuVybranaPostavaPole) {
				this.menuVybranaPostavaPole[i] = this.ZmenaVzhleduZiskatData(i);
				i += 1;
			}
		} else if Equals(this.aktivniTypMenu, MenuUITyp.GFH) {
			this.NastavitVybranePostavyPole(1);
		} else {
			this.NastavitVybranePostavyPole(0);
		}
		if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
			this.KoupenePVSeznam();
		}
		if Equals(this.aktivniTypMenu, MenuUITyp.VyberHudby) {
			this.NacistHudbu();
		}

		// ====

		this.GetRootCompoundWidget().SetOpacity(1);

		this.NastavitViditelnostPodleNazvu("location", false);
		this.NastavitViditelnostPodleNazvu("character", false);
		this.NastavitViditelnostPodleNazvu("text", false);
		this.NastavitViditelnostPodleNazvu("character_custom", false);

		this.vlastniBarva = new HDRColor(1.0, 0.4, 0.81, 1.0);
		this.vlastniBarvaVyber = new HDRColor(1.5, 0.4, 0.81, 1.0);
		this.vlastniBarvaPozadi = new HDRColor(0.196, 0.203, 0.643, 1);

		let streamingCtrl: ref<inkRichTextBox> = this.GetChildWidgetByPath(n"main_ui/main_container/streaming") as inkRichTextBox;
		//streamingCtrl.SetVisible(this.streamovaniAktivni);
		let streamingStr: String = GetLocalizedTextGanderDepened("LocKey#15142051", this.questsSystem.GetFact(this.factPlayerGender) == 2);
		streamingStr += " (#" + this.questsSystem.GetFact(Konstanty.FaktUzivID()) + ")";
		if Equals(this.aktivniTypMenu, MenuUITyp.Streamovani) { streamingStr += "\n" + GetLocalizedText("LocKey#15142046"); }
		streamingCtrl.SetText(streamingStr);

		let selRepTextCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/selected_repeat") as inkText;
		selRepTextCtrl.SetVisible(false);

		this.menuTrvaleCtrl = this.GetChildWidgetByPath(n"main_ui/main_container/border_menu_space") as inkWidget;
		this.tlacitkaCtrl = this.GetChildWidgetByPath(n"main_ui/main_container/buttons") as inkCompoundWidget;
		this.tlacitkaTrvaleCtrl = this.GetChildWidgetByPath(n"main_ui/main_container/buttons_persist") as inkCompoundWidget;

		let varovaniText: String = "";
		if this.questsSystem.GetFact(Konstanty.FaktBezPodminek()) == 1 {
			varovaniText += GetLocalizedText("LocKey#15142326");
		}
		if
			this.lizziesBDsResources.incfInstalovan ||
			this.lizziesBDsResources.superpopulationInstalovan
		{
			varovaniText += (StrCmp(varovaniText, "") != 0 ? ", " : "") + GetLocalizedText("LocKey#15142364");
		}
		if StrCmp(varovaniText, "") != 0 {
			varovaniText += ", " + GetLocalizedText("LocKey#15142365");
		}
		let condTextCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/varovani_text") as inkText;
		condTextCtrl.SetText(varovaniText);

		if
			NotEquals(this.aktivniTypMenu, MenuUITyp.Pevecka) &&
			NotEquals(this.aktivniTypMenu, MenuUITyp.Nastaveni) &&
			NotEquals(this.aktivniTypMenu, MenuUITyp.NastaveniRuzne) &&
			NotEquals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) &&
			NotEquals(this.aktivniTypMenu, MenuUITyp.BarVyberLokace) &&
			NotEquals(this.aktivniTypMenu, MenuUITyp.PostavaMoznosti) &&
			NotEquals(this.aktivniTypMenu, MenuUITyp.GFH)
		{
			let transSystem: wref<TransactionSystem> = GameInstance.GetTransactionSystem(this.game);
			this.hracPenize = transSystem.GetItemQuantity(this.player, MarketSystem.Money());
			//this.hracPenize = 500;

			let hracPenizeCtrl: ref<inkRichTextBox> = this.GetChildWidgetByPath(n"main_ui/main_container/player_money") as inkRichTextBox;
			hracPenizeCtrl.SetVisible(true);
			hracPenizeCtrl.SetText("<Rich style=\"Bold\">" + GetLocalizedText("LocKey#15142068") + "</>\n<Rich style=\"Bold\" color=\"#FFD700\">€$ " + GlobalniFunkce.FormatovanaCena(this.hracPenize) + "</>");
		}

		if Equals(this.aktivniTypMenu, MenuUITyp.Pevecka) || Equals(this.aktivniTypMenu, MenuUITyp.GFH) {
			this.NastveniBarev(new HDRColor(1.0, 0.843, 0.0, 1));
			this.vlastniBarvaVyber = this.vlastniBarva;
			this.vlastniBarvaPozadi = new HDRColor(0.428, 0.361, 0.0, 1);

			let ctrl: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/background/bg_color") as inkWidget;
			ctrl.SetTintColor(new HDRColor(0.095, 0.08, 0.0, 1));
			ctrl = this.GetChildWidgetByPath(n"main_ui/background/bg_texture") as inkWidget;
			ctrl.SetTintColor(this.vlastniBarvaPozadi);
			ctrl = this.GetChildWidgetByPath(n"main_ui/inside_container/dialog_container/dialog_bg_color") as inkWidget;
			ctrl.SetTintColor(new HDRColor(0.095, 0.08, 0.0, 1));
			ctrl = this.GetChildWidgetByPath(n"main_ui/inside_container/dialog_container/dialog_bg_texture") as inkWidget;
			ctrl.SetTintColor(this.vlastniBarvaPozadi);
		}

		let selLocCtrl: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/main_container/selected_location") as inkWidget;

		if Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) || Equals(this.aktivniTypMenu, MenuUITyp.NastaveniRuzne) {
			this.NastveniBarev(new HDRColor(0.874, 1.0, 0.368, 1));
			this.vlastniBarvaVyber = this.vlastniBarva;

			let margin: inkMargin = new inkMargin(0, 0, 0, 0);
			margin.left = -1030.0;
			margin.top = 330.0;
			selLocCtrl.SetMargin(margin);
			selLocCtrl.SetTintColor(this.vlastniBarva);

			let borderCtrl: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/main_container/border w") as inkWidget;
			borderCtrl.SetVisible(false);

			let bgVideo: ref<inkVideo> = this.GetChildWidgetByPath(n"main_ui/background/bg_video") as inkVideo;
			bgVideo.SetVideoPath(r"base\\movies\\fullscreen\\common\\minigame_loop.bk2");
			bgVideo.Play();
		} else {
			selLocCtrl.SetOpacity(0);
		}

		if NotEquals(this.aktivniTypMenu, MenuUITyp.Nastaveni) && NotEquals(this.aktivniTypMenu, MenuUITyp.NastaveniRuzne) {
			let eventNastaveni: Int32 = this.questsSystem.GetFact(Konstanty.FaktEventy());
			if eventNastaveni != 1 {
				if eventNastaveni == 2 || (eventNastaveni == 0 && this.soucasnyEvent == 1) {
					let picCtrl: ref<inkImage> = this.GetChildWidgetByPath(n"main_ui/top_container/event_01_pic_01") as inkImage;
					picCtrl.SetAtlasResource(r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_event_01.inkatlas");
					picCtrl.SetOpacity(1);
					picCtrl = this.GetChildWidgetByPath(n"main_ui/top_container/event_01_pic_02") as inkImage;
					picCtrl.SetAtlasResource(r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_bds_event_01.inkatlas");
					picCtrl.SetOpacity(1);
					picCtrl = this.GetChildWidgetByPath(n"main_ui/decors/dancer") as inkImage;
					picCtrl.SetAtlasResource(r"mod\\arman3_lizzies_bds\\gameplay\\gui\\assets\\lizzies_xmas.inkatlas");

					let opts: inkAnimOptions;
					opts.loopType = inkanimLoopType.Cycle;
					opts.loopInfinite = true;
					this.PlayLibraryAnimation(n"show_event_01", opts);
				}
				if eventNastaveni == 2 || eventNastaveni == 3 || (eventNastaveni == 0 && (this.soucasnyEvent == 1 || this.soucasnyEvent == 2)) {
					let bgVideo: ref<inkVideo> = this.GetChildWidgetByPath(n"main_ui/background/bg_video") as inkVideo;
					bgVideo.SetVideoPath(r"mod\\arman3_lizzies_bds\\movies\\event_01_edit_2024_10_27.bk2");
					//bgVideo.SetOpacity(1);
					bgVideo.Play();
				}
			}
		}

		if Equals(this.aktivniTypMenu, MenuUITyp.PostavaMoznosti) {
			this.hlavniNadpisText = GetLocalizedText("LocKey#15142077");
		} else if Equals(this.aktivniTypMenu, MenuUITyp.BarVyberLokace) {
			this.hlavniNadpisText = GetLocalizedText("LocKey#15142120");
		} else if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
			this.hlavniNadpisText = GetLocalizedText("LocKey#15142165");
		} else if Equals(this.aktivniTypMenu, MenuUITyp.VyberHudby) {
			this.hlavniNadpisText = GetLocalizedText("LocKey#15142285");
		} else if Equals(this.aktivniTypMenu, MenuUITyp.KoupeniPV) {
			this.hlavniNadpisText = GetLocalizedText("LocKey#15142271");
		} else if Equals(this.aktivniTypMenu, MenuUITyp.Recepce) {
			this.hlavniNadpisText = GetLocalizedText("LocKey#15142050");
		} else if Equals(this.aktivniTypMenu, MenuUITyp.Pevecka) {
			this.hlavniNadpisText = GetLocalizedText("LocKey#15142070");
		} else if Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) || Equals(this.aktivniTypMenu, MenuUITyp.NastaveniRuzne) {
			this.hlavniNadpisText = GetLocalizedText("LocKey#15144026");
		} else if Equals(this.aktivniTypMenu, MenuUITyp.GFH) {
			this.hlavniNadpisText = GetLocalizedText("LocKey#15142351");
		} else {
			this.hlavniNadpisText = GetLocalizedText("LocKey#15142056");
		}

		this.menuStrom = new MenuStrom();

		let menu: MenuStrankaTyp = MenuStrankaTyp.Prazdne;
		if Equals(this.aktivniTypMenu, MenuUITyp.Recepce) { menu = MenuStrankaTyp.Menu_HlavniRecepce; }
		else if Equals(this.aktivniTypMenu, MenuUITyp.NastaveniRuzne) { menu = MenuStrankaTyp.Menu_NastaveniRuzne; }
		else if Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) { menu = MenuStrankaTyp.Menu_NastaveniPostavy; }
		else if Equals(this.aktivniTypMenu, MenuUITyp.BarVyberLokace) { menu = MenuStrankaTyp.Menu_BarLokace; }
		else if Equals(this.aktivniTypMenu, MenuUITyp.PostavaMoznosti) { menu = MenuStrankaTyp.Menu_PostavaMoznosti; }
		else if Equals(this.aktivniTypMenu, MenuUITyp.VyberHudby) { menu = MenuStrankaTyp.Menu_VybratHudbu; }
		else if Equals(this.aktivniTypMenu, MenuUITyp.Debug) { menu = MenuStrankaTyp.Menu_Debug; }
		else if Equals(this.aktivniTypMenu, MenuUITyp.GFH) { menu = MenuStrankaTyp.Menu_GFH; }
		else { menu = MenuStrankaTyp.Menu_Hlavni; }
		this.VytvoritMenu(menu);

		if Equals(this.aktivniTypMenu, MenuUITyp.NastaveniRuzne) {
			this.aktivniTypMenu = MenuUITyp.Nastaveni;
		}
		
		/*if Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) {
			this.ZobrazitNastaveniBinarniData();
		}*/
		
		if Equals(this.aktivniTypMenu, MenuUITyp.Recepce) {
			this.OnlineFunkcePridatText();
		}

		this.NastavitMensiVerzi(0);

		this.ZvyraznitPolozkuMenu();

		// ====

		let startAnimace: CName = n"startup";
		if this.mensiVerzeMenu { startAnimace = n"startup_mensi"; }
		if Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) { startAnimace = n"startup_settings"; }
		if
			Equals(this.aktivniTypMenu, MenuUITyp.Debug) ||
			Equals(this.aktivniTypMenu, MenuUITyp.BarVyberLokace) ||
			Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) ||
			Equals(this.aktivniTypMenu, MenuUITyp.PostavaMoznosti) ||
			Equals(this.aktivniTypMenu, MenuUITyp.VyberHudby)
		{
			startAnimace = n"startup_bar";
		}
		this.m_startupAnimProxy = this.PlayLibraryAnimation(startAnimace);
		this.m_startupAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnStartupAnimationDone");

		let animTransp: ref<inkAnimTransparency> = new inkAnimTransparency();
		animTransp.SetStartTransparency(1.0);
		animTransp.SetEndTransparency(0.0);
		animTransp.SetDuration(0.2);
		this.animaceKonecDef = new inkAnimDef();
		this.animaceKonecDef.AddInterpolator(animTransp);

		let animTransp2: ref<inkAnimTransparency> = new inkAnimTransparency();
		animTransp2.SetStartTransparency(1.0);
		animTransp2.SetEndTransparency(0.1);
		animTransp2.SetType(inkanimInterpolationType.Sinusoidal);
		animTransp2.SetMode(inkanimInterpolationMode.EasyInOut);
		animTransp2.SetStartDelay(0);
		animTransp2.SetDuration(1);
		let animTransp3: ref<inkAnimTransparency> = new inkAnimTransparency();
		animTransp3.SetStartTransparency(0.1);
		animTransp3.SetEndTransparency(1.0);
		animTransp3.SetType(inkanimInterpolationType.Sinusoidal);
		animTransp3.SetMode(inkanimInterpolationMode.EasyInOut);
		animTransp3.SetStartDelay(1);
		animTransp3.SetDuration(1);
		this.animaceVybranaDef = new inkAnimDef();
		this.animaceVybranaDef.AddInterpolator(animTransp2);
		this.animaceVybranaDef.AddInterpolator(animTransp3);

		this.uiSystem.PushGameContext(UIGameContext.ModalPopup);
		if !this.mensiVerzeMenu {
			PopupStateUtils.SetBackgroundBlur(this, true);
			this.uiSystem.RequestNewVisualState(n"inkModalPopupState");
		}

		this.player.RegisterInputListener(this, n"OpenPauseMenu");

		let uiSystemBB: ref<IBlackboard> = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_System);
		this.m_isInMenuCallbackID = uiSystemBB.RegisterDelayedListenerBool(GetAllBlackboardDefs().UI_System.IsInMenu, this, n"OnIsInMenuChanged");
		
		this.Gamepad(1);
		this.PlayRumble(RumbleStrength.Medium, RumbleType.Fast, RumblePosition.Both);

		let ev: ref<LizziesBDsMenuUIPoInitu> = new LizziesBDsMenuUIPoInitu();
		ev.MenuUIInstance = this;
		this.uiSystem.QueueEvent(ev);
	}

	private final func NastavitMensiVerzi(typ: Int32) -> Void {
		if this.mensiVerzeMenu {
			let bgSize: Vector2 = new Vector2(900.0, 1300.0);
			let bgMargin: inkMargin = new inkMargin(0, 0, 900.0, 0);

			let tCtrlMainBorder: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/main_border") as inkWidget;
			tCtrlMainBorder.SetSize(bgSize);
			tCtrlMainBorder.SetMargin(bgMargin);

			let tCtrlBGTexture: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/background/bg_texture") as inkWidget;
			tCtrlBGTexture.SetSize(bgSize);
			tCtrlBGTexture.SetMargin(bgMargin);

			let tCtrlBGColor: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/background/bg_color") as inkWidget;
			tCtrlBGColor.SetSize(bgSize);
			tCtrlBGColor.SetMargin(bgMargin);

			let tCtrlInsideBorder: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/inside_border") as inkWidget;
			tCtrlInsideBorder.SetVisible(false);

			if typ == 0 {
				let tCtrlDecors: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/decors") as inkWidget;
				tCtrlDecors.SetVisible(false);

				let tCtrlStreaming: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/main_container/streaming") as inkWidget;
				tCtrlStreaming.SetVisible(false);

				let tCtrlPlrMoney: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/main_container/player_money") as inkWidget;
				tCtrlPlrMoney.SetVisible(false);

				let tCtrlButtons: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/main_container/buttons") as inkWidget;
				tCtrlButtons.SetMargin(-900.0, 80.0, 0, 0);

				let tCtrlButtonsHeader: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/main_container/buttons_header") as inkWidget;
				tCtrlButtonsHeader.SetMargin(-900.0, 15.0, 0, 0);

				let tCtrlPageCounter: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/main_container/page_counter") as inkWidget;
				tCtrlPageCounter.SetMargin(-780.0, 40.0, 0, 0);

				let tCtrlVersionInfo: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/main_container/version_info") as inkWidget;
				tCtrlVersionInfo.SetVisible(false);

				let tCtrlTopContainer: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/top_container") as inkWidget;
				tCtrlTopContainer.SetVisible(false);

				let tCtrlBorderW: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/main_container/border w") as inkWidget;
				tCtrlBorderW.SetSize(900.0, 500.0);
				tCtrlBorderW.SetMargin(-900.0, 800.0, 0, 0);

				let tCtrlTextHeader: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/main_container/text/nameTxt") as inkWidget;
				tCtrlTextHeader.SetMargin(-900.0, 820.0, 0, 0);

				let tCtrlTextDesc: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/main_container/text/descTxt") as inkWidget;
				tCtrlTextDesc.SetSize(860.0, 400.0);
				tCtrlTextDesc.SetMargin(-900.0, 880.0, 0, 0);
				
				let condTextCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/varovani_text") as inkText;
				condTextCtrl.SetVisible(false);
			}

			if typ == 1 {
				bgSize = new Vector2(2110.0, 1300.0);
				bgMargin = new inkMargin(0, 0, 295.0, 0);

				tCtrlMainBorder.SetSize(bgSize);
				tCtrlMainBorder.SetMargin(bgMargin);

				tCtrlBGTexture.SetSize(bgSize);
				tCtrlBGTexture.SetMargin(bgMargin);

				tCtrlBGColor.SetSize(bgSize);
				tCtrlBGColor.SetMargin(bgMargin);

				tCtrlInsideBorder.SetVisible(true);
				tCtrlInsideBorder.SetMargin(0, 0, 900.0, 0);

				let tCtrlCharacter: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/main_container/character") as inkWidget;
				tCtrlCharacter.SetMargin(0, 0, 492.0, 0);
			}
		}
	}

	private let m_isInMenuCallbackID: ref<CallbackHandle>;

	protected cb func OnIsInMenuChanged(param: Bool) -> Bool {
		if param {
			this.UkonceniMenu();
		};
	}

	protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
		let actionName: CName = ListenerAction.GetName(action);
		let actionType: gameinputActionType = ListenerAction.GetType(action);

		if Equals(actionType, gameinputActionType.BUTTON_PRESSED) && Equals(actionName, n"OpenPauseMenu") {
			ListenerActionConsumer.DontSendReleaseEvent(consumer);
		}
		if Equals(actionName, n"craft_item") && Equals(actionType, gameinputActionType.BUTTON_PRESSED) {
			if this.OsetreniDvojitehoKliku() {
				if this.dialogAktivni > 0 {
					if this.dialogAktivni == 2 {
						this.questsSystem.SetFact(Konstanty.FaktNudity(), 1);
						this.NastavitExplicitniObsah();
						this.NacistLokace();
						this.VytvoritMenu(MenuStrankaTyp.Soucasne);
						this.ZvyraznitPolozkuMenu();
					}

					this.DialogSkryt();
				} else {
					this.VybratPolozkuMenu();
				}
				this.PlayRumble(RumbleStrength.Heavy, RumbleType.Pulse, RumblePosition.Right);
			}
		}
		if Equals(actionName, n"ChoiceScrollUp") && Equals(actionType, gameinputActionType.BUTTON_PRESSED) {
			this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Odecist, 1, ArraySize(this.polePolozkyMenu) - 1);
			this.ZvyraznitPolozkuMenu();
			this.PlayRumble(RumbleStrength.SuperLight, RumbleType.Pulse, RumblePosition.Left);
		}
		if Equals(actionName, n"ChoiceScrollDown") && Equals(actionType, gameinputActionType.BUTTON_PRESSED) {
			this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Pricist, 1, ArraySize(this.polePolozkyMenu));
			this.ZvyraznitPolozkuMenu();
			this.PlayRumble(RumbleStrength.SuperLight, RumbleType.Pulse, RumblePosition.Left);
		}
		if Equals(actionName, n"UI_Exit") && Equals(actionType, gameinputActionType.BUTTON_PRESSED) {
			if this.OsetreniDvojitehoKliku() {
				if this.dialogAktivni > 0 {
					if this.dialogAktivni == 2 {
						this.questsSystem.SetFact(Konstanty.FaktNudity(), 2);
						this.NastavitExplicitniObsah();
					}

					this.DialogSkryt();
				} else {
					this.menuAkceTyp = this.akceMenuZpet;
					this.VybratPolozkuMenu();
				}
				this.PlayRumble(RumbleStrength.Heavy, RumbleType.Pulse, RumblePosition.Right);
			}
		}
		if NotEquals(this.specialniTlacitkoAkce, SpecTlacAkce.ZadnaAkce) {
			if Equals(actionName, n"Choice2") && Equals(actionType, gameinputActionType.BUTTON_RELEASED) {
				if this.OsetreniDvojitehoKliku() {
					if Equals(this.specialniTlacitkoAkce, SpecTlacAkce.NastaveniZpetne) {
						this.menuAkceTyp = MenuAkceTyp.NastaveniRuzne_Nastaveni_Zpetne;
						this.VybratPolozkuMenu();
						this.menuAkceTyp = MenuAkceTyp.NastaveniRuzne_Nastaveni;
					} else if Equals(this.specialniTlacitkoAkce, SpecTlacAkce.NahledHudby) {
						if !this.nahledHudbyAktivni {
							let polozkaData: array<Int32> = this.JeVMenuZiskatData();
							this.questsSystem.SetFact(Konstanty.FaktVybratHudbu(), polozkaData[0]);
							this.questsSystem.SetFact(this.factMusicToggle, 41);
							this.nahledHudbyAktivni = true;
							
							this.audioSystem.GlobalParameter(n"mix_MUTE_sfx_vo", 1.0);
							
							this.nahledHudbyAktivniCtrlPic = this.GetChildWidgetByPath(StringToName("main_ui/main_container/buttons" + (this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Ziskat) >= this.menuTrvale && this.menuTrvale > 0 ? "_persist" : "") + "/button_" + this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Ziskat) + "/sound_icon")) as inkImage;
							this.nahledHudbyAktivniCtrlPic.SetOpacity(1);
						}
					} else {
						this.OblibeneOp(2);

						if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
							this.KoupenePVSeznam();
						}

						this.VytvoritMenu(MenuStrankaTyp.Soucasne);
						
						if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_Oblibene) || Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
							this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Resetovat);
						}
						
						this.ZvyraznitPolozkuMenu();
					}

					this.PlayRumble(RumbleStrength.Light, RumbleType.Pulse, RumblePosition.Both);
				}
			}
		}
		if this.maximalniPocetStranek > 1 {
			if Equals(actionName, n"next_menu") && Equals(actionType, gameinputActionType.BUTTON_PRESSED) {
				//if this.OsetreniDvojitehoKliku() {
					this.menuAkceTyp = MenuAkceTyp.Globalni_DalsiStranka;
					this.VybratPolozkuMenu();
				//}
				this.PlayRumble(RumbleStrength.Light, RumbleType.Pulse, RumblePosition.Right);
			}
			if Equals(actionName, n"prior_menu") && Equals(actionType, gameinputActionType.BUTTON_PRESSED) {
				//if this.OsetreniDvojitehoKliku() {
					this.menuAkceTyp = MenuAkceTyp.Globalni_PredchoziStranka;
					this.VybratPolozkuMenu();
				//}
				this.PlayRumble(RumbleStrength.Light, RumbleType.Pulse, RumblePosition.Left);
			}
		}
	}

	protected cb func OnUninitialize() -> Bool {
		this.questsSystem.SetFact(Konstanty.FaktMenuUIAktivni(), 0);
		this.Gamepad(0);
	}

	protected cb func OnStartupAnimationDone(proxy: ref<inkAnimProxy>) -> Bool {
		this.m_startupAnimProxy.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);

		this.RegistrovatVstupy(true);

		if this.spatnaVerze {
			ArrayPush(this.dialogRada, new DialogStack(1, 300, GetLocalizedText("LocKey#15142324"), GetLocalizedText("LocKey#15142325")));
		}

		if
			NotEquals(this.aktivniTypMenu, MenuUITyp.Nastaveni) &&
			NotEquals(this.aktivniTypMenu, MenuUITyp.Pevecka) &&
			NotEquals(this.aktivniTypMenu, MenuUITyp.BarVyberLokace) &&
			NotEquals(this.aktivniTypMenu, MenuUITyp.PostavaMoznosti) &&
			NotEquals(this.aktivniTypMenu, MenuUITyp.VyberHudby) &&
			NotEquals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv)
		{
			if this.questsSystem.GetFact(n"censorship_nudity") == 0 && this.questsSystem.GetFact(Konstanty.FaktNudity()) == 0 {
				ArrayPush(this.dialogRada, new DialogStack(2, 300, GetLocalizedText("LocKey#15142125"), GetLocalizedText("LocKey#15142137")));
			}
			if this.soucasnyEvent == 1 {
				if this.questsSystem.GetFact(n"lizzies_bds_events_01") != 2 {
					ArrayPush(this.dialogRada, new DialogStack(1, 1000, GetLocalizedText("LocKey#15142217"), GetLocalizedText("LocKey#15142218")));
					this.questsSystem.SetFact(n"lizzies_bds_events_01", 2);
				}
			}
			if this.soucasnyEvent == 3 {
				if this.questsSystem.GetFact(n"lizzies_bds_events_02") != 2 {
					ArrayPush(this.dialogRada, new DialogStack(1, 500, GetLocalizedText("LocKey#15142239"), GetLocalizedText("LocKey#15142240")));
					this.questsSystem.SetFact(n"lizzies_bds_events_02", 2);
				}
			}
		}

		if ArraySize(this.dialogRada) > 0 {
			this.DialogZobrazit();
		}
	}

	protected cb func OnRemoveAnimLizziesBDsMenuUIFromHudEvent(evt: ref<RemoveAnimLizziesBDsMenuUIFromHudEvent>) -> Bool {
		let startAnimace: CName = n"close";
		if this.mensiVerzeMenu { startAnimace = n"close_mensi"; }
		if Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) { startAnimace = n"close_settings"; }
		if Equals(this.aktivniTypMenu, MenuUITyp.BarVyberLokace) || Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) || Equals(this.aktivniTypMenu, MenuUITyp.PostavaMoznosti) { startAnimace = n"close_bar"; }

		this.m_closeAnimProxy = this.PlayLibraryAnimation(startAnimace);
		this.m_closeAnimProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnCloseAnimationDone");

		this.RegistrovatVstupy(false);

		this.uiSystem.PopGameContext(UIGameContext.ModalPopup);
		if !this.mensiVerzeMenu {
			PopupStateUtils.SetBackgroundBlur(this, false);
			this.uiSystem.RestorePreviousVisualState(n"inkModalPopupState");
		}

		let uiSystemBB: ref<IBlackboard> = this.GetBlackboardSystem().Get(GetAllBlackboardDefs().UI_System);
		uiSystemBB.UnregisterDelayedListener(GetAllBlackboardDefs().UI_System.IsInMenu, this.m_isInMenuCallbackID);
		
		this.PlayRumble(RumbleStrength.Medium, RumbleType.Fast, RumblePosition.Both);
	}

	protected cb func OnCloseAnimationDone(proxy: ref<inkAnimProxy>) -> Bool {
		this.m_startupAnimProxy.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);

		this.uiSystem.QueueEvent(new RemoveLizziesBDsMenuUIFromHudEvent());
	}

	private final func RegistrovatVstupy(registrovat: Bool) -> Void {
		if registrovat {
			this.player.RegisterInputListener(this, n"ChoiceScrollUp");
			this.player.RegisterInputListener(this, n"ChoiceScrollDown");
			this.player.RegisterInputListener(this, n"next_menu");
			this.player.RegisterInputListener(this, n"prior_menu");
			this.player.RegisterInputListener(this, n"Choice2");

			if this.dialogAktivni == 0 {
				this.player.RegisterInputListener(this, n"UI_Exit");
				this.player.RegisterInputListener(this, n"craft_item");
			}
		} else {
			this.player.UnregisterInputListener(this, n"ChoiceScrollUp");
			this.player.UnregisterInputListener(this, n"ChoiceScrollDown");
			this.player.UnregisterInputListener(this, n"next_menu");
			this.player.UnregisterInputListener(this, n"prior_menu");
			this.player.UnregisterInputListener(this, n"Choice2");

			if this.dialogAktivni == 0 {
				this.player.UnregisterInputListener(this, n"UI_Exit");
				this.player.UnregisterInputListener(this, n"craft_item");
				this.player.UnregisterInputListener(this, n"OpenPauseMenu");
			}
		}
	}

	private final func Gamepad(akce: Int32) -> Void {
		let gamepadLightController: ref<GamepadLightController> = GameInstance.GetGamepadLightController(this.game);

		if akce == 0 {
			if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) { gamepadLightController.SetControllerColor(Cast<Uint8>(0), Cast<Uint8>(0), Cast<Uint8>(0)); }
			else { gamepadLightController.SetControllerColor(Cast<Uint8>(204), Cast<Uint8>(0), Cast<Uint8>(140)); }
		}

		if akce == 1 {
			if this.PolozkaZakazana() {
				gamepadLightController.SetControllerColor(Cast<Uint8>(50), Cast<Uint8>(50), Cast<Uint8>(50));
			}
			else if
				this.JeVMenu(MenuAkceTyp.Globalni_Zpet, [], true) ||
				this.JeVMenu(MenuAkceTyp.MenuLokace_ZahoditPV, [], true)
			{
				gamepadLightController.SetControllerColor(Cast<Uint8>(255), Cast<Uint8>(0), Cast<Uint8>(0));
			}
			else if
				this.JeVMenu(MenuAkceTyp.Globalni_DalsiStranka, [], true) ||
				this.JeVMenu(MenuAkceTyp.MenuLokace_Spustit, [], true) ||
				this.JeVMenu(MenuAkceTyp.MenuLokace_Koupit, [], true)
			{
				gamepadLightController.SetControllerColor(Cast<Uint8>(0), Cast<Uint8>(255), Cast<Uint8>(0));
			}
			else if
				this.JeVMenu(MenuAkceTyp.Hlavni_Oblibene, [], true) ||
				this.JeVMenu(MenuAkceTyp.MenuLokace_OblibeneOd, [], true) ||
				this.JeVMenu(MenuAkceTyp.MenuLokace_Oblibene, [], true) ||
				(this.oblibeneVybraneID != -1 && this.menuStrom.Soucasne(MenuStrankaTyp.Menu_Oblibene))
			{
				gamepadLightController.SetControllerColor(Cast<Uint8>(255), Cast<Uint8>(215), Cast<Uint8>(0));
			}
			else {
				if Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) { gamepadLightController.SetControllerColor(Cast<Uint8>(150), Cast<Uint8>(255), Cast<Uint8>(50)); }
				else if Equals(this.aktivniTypMenu, MenuUITyp.Pevecka) { gamepadLightController.SetControllerColor(Cast<Uint8>(255), Cast<Uint8>(214), Cast<Uint8>(0)); }
				else { gamepadLightController.SetControllerColor(Cast<Uint8>(10), Cast<Uint8>(0), Cast<Uint8>(255)); }
			}
		}
	}

	private final func OsetreniDvojitehoKliku() -> Bool {
		if this.dvojityKlik {
			this.dvojityKlik = false;

			GameInstance.GetDelaySystem(this.game).CancelDelay(this.dvojityKlikProdlevaID);
			let callback = new KlikListenerCallback();
			callback.controller = this;
			this.dvojityKlikProdlevaID = GameInstance.GetDelaySystem(this.game).DelayCallback(callback, 0.2, false);

			return true;
		} else {
			return false;
		}
	}

	public final func ZobrazVelikonocniVajicko(typ: Int32) -> Void {
		if typ == 1 {
			this.PlayLibraryAnimation(n"EE_anim");

			let callback = new VVListenerCallback();
			callback.typ = 2;
			callback.controller = this;
			this.VVIDProdlevy2 = GameInstance.GetDelaySystem(this.game).DelayCallback(callback, 30, false);

			GameInstance.GetAudioSystem(this.game).Play(n"mus_lizzies_bds_q50_play");
		}
		if typ == 2 {
			this.PlayLibraryAnimation(n"EE_anim");
			GameInstance.GetAudioSystem(this.game).Play(n"mus_lizzies_bds_q50_stop");
			this.questsSystem.SetFact(n"lizzies_bds_cyb_begin", 1);
			this.UkonceniMenu();
		}
	}

	private final func NastveniBarev(barva: HDRColor) -> Void {
		this.vlastniBarva = barva;

		this.menuTrvaleCtrl.SetTintColor(this.vlastniBarva);

		let borderCtrl: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/main_border") as inkWidget;
		borderCtrl.SetTintColor(barva);
		borderCtrl = this.GetChildWidgetByPath(n"main_ui/inside_border") as inkWidget;
		borderCtrl.SetTintColor(barva);
		borderCtrl = this.GetChildWidgetByPath(n"main_ui/main_container/border w") as inkWidget;
		borderCtrl.SetTintColor(barva);
		borderCtrl = this.GetChildWidgetByPath(n"main_ui/inside_container/dialog_container/dialog_border") as inkWidget;
		borderCtrl.SetTintColor(barva);
	}

	private final func DialogZobrazit() -> Void {
		let zobrazit: Int32 = this.dialogRada[this.dialogRadaVyb].Typ;
		let vyska: Float = this.dialogRada[this.dialogRadaVyb].Velikost;
		let nadpis: String = this.dialogRada[this.dialogRadaVyb].Nadpis;
		let text: String = this.dialogRada[this.dialogRadaVyb].Popis;

		if zobrazit > 0 {
			this.dialogAktivni = zobrazit;

			let ctrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/inside_container/dialog_container/header") as inkText;
			ctrl.SetText(nadpis);

			ctrl = this.GetChildWidgetByPath(n"main_ui/inside_container/dialog_container/description") as inkText;
			ctrl.SetText(text);
			ctrl.SetHeight(vyska);
			
			let ctrl2: ref<inkWidget> = this.GetChildWidgetByPath(n"main_ui/inside_container/dialog_container") as inkWidget;
			ctrl2.SetHeight(vyska);
			ctrl2 = this.GetChildWidgetByPath(n"main_ui/inside_container/dialog_container/dialog_bg_color") as inkWidget;
			ctrl2.SetHeight(vyska);
			ctrl2 = this.GetChildWidgetByPath(n"main_ui/inside_container/dialog_container/dialog_border") as inkWidget;
			ctrl2.SetHeight(vyska);
			ctrl2 = this.GetChildWidgetByPath(n"main_ui/inside_container/dialog_container/dialog_bg_texture") as inkWidget;
			ctrl2.SetHeight(vyska);
			ctrl2 = this.GetChildWidgetByPath(n"main_ui/inside_container/dialog_container/dialog_tooltip") as inkWidget;
			ctrl2.SetMargin(0, vyska + 20.0, 0, 0);

			if zobrazit == 2 {
				ctrl = this.GetChildWidgetByPath(n"main_ui/inside_container/dialog_container/dialog_tooltip/SelectTooltipIcon_Cancel") as inkText;
				ctrl.SetVisible(true);
				ctrl = this.GetChildWidgetByPath(n"main_ui/inside_container/dialog_container/dialog_tooltip/SelectTooltipText_Cancel") as inkText;
				ctrl.SetVisible(true);
				ctrl = this.GetChildWidgetByPath(n"main_ui/inside_container/dialog_container/dialog_tooltip/SelectTooltipText") as inkText;
				ctrl.SetText(GetLocalizedText("LocKey#51410"));
			} else {
				ctrl = this.GetChildWidgetByPath(n"main_ui/inside_container/dialog_container/dialog_tooltip/SelectTooltipIcon_Cancel") as inkText;
				ctrl.SetVisible(false);
				ctrl = this.GetChildWidgetByPath(n"main_ui/inside_container/dialog_container/dialog_tooltip/SelectTooltipText_Cancel") as inkText;
				ctrl.SetVisible(false);
				ctrl = this.GetChildWidgetByPath(n"main_ui/inside_container/dialog_container/dialog_tooltip/SelectTooltipText") as inkText;
				ctrl.SetText(GetLocalizedText("LocKey#6889"));
			}

			this.PlayLibraryAnimation(n"show_dialog");
			
			this.RegistrovatVstupy(false);
		}
	}

	private final func DialogSkryt() -> Void {
		this.animaceDialogProxy = this.PlayLibraryAnimation(n"hide_dialog");
		this.animaceDialogProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnDialogAnimationDone");
		this.dialogAktivni = 0;
	}
	
	protected cb func OnDialogAnimationDone(proxy: ref<inkAnimProxy>) -> Bool {
		this.animaceDialogProxy.UnregisterFromAllCallbacks(inkanimEventType.OnFinish);

		this.RegistrovatVstupy(true);

		this.dialogRadaVyb += 1;

		if this.dialogRadaVyb < ArraySize(this.dialogRada) {
			this.DialogZobrazit();
		} else {
			this.dialogRadaVyb = 0;
			ArrayClear(this.dialogRada);
		}
	}

	private final func NastavitExplicitniObsah() -> Void {
		if this.questsSystem.GetFact(n"censorship_nudity") == 0 {
			if this.questsSystem.GetFact(Konstanty.FaktNudity()) == 1 {
				this.nahotaJePovolena = true;
			} else {
				this.nahotaJePovolena = false;
			}
		} else {
			this.nahotaJePovolena = false;
			this.questsSystem.SetFact(Konstanty.FaktNudity(), 2);
		}

		this.questsSystem.SetFact(n"lizzies_bds_censorship_nudity", this.nahotaJePovolena ? 0 : 1);
	}

	private final func NacistLokace() -> Void {
		this.poleLokaciData = DataPoleLokaci(this.game, this.questsSystem, this.lizziesBDsResources, this.nahotaJePovolena, Equals(this.aktivniTypMenu, MenuUITyp.Pevecka), this.ep1JeInstalovane);
	
		if Equals(this.aktivniTypMenu, MenuUITyp.KoupeniPV) {
			let j = 0;
			while j < ArraySize(this.poleLokaciData) {
				this.poleLokaciData[j].Cena *= 2;

				if ArraySize(this.poleLokaciData[j].Kontejner) > 0 {
					let i = 0;
					while i < ArraySize(this.poleLokaciData[j].Kontejner) {
						this.poleLokaciData[j].Kontejner[i].Cena *= 2;
						i += 1;
					}
				}

				j += 1;
			}
		}
		if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
			let j = 0;
			while j < ArraySize(this.poleLokaciData) {
				this.poleLokaciData[j].Cena = 0;

				if ArraySize(this.poleLokaciData[j].Kontejner) > 0 {
					let i = 0;
					while i < ArraySize(this.poleLokaciData[j].Kontejner) {
						this.poleLokaciData[j].Kontejner[i].Cena = 0;
						i += 1;
					}
				}

				j += 1;
			}
		}
	}

	private final func NacistHudbu() -> Void {
		this.poleHudbyData = DataPoleHudba();
		
		let vlastniHudba: array<ref<DataHudby>> = this.lizziesBDsSystem.VlastniHudba();
		if ArraySize(vlastniHudba) > 0 {
			let i = 0;
			while i < ArraySize(vlastniHudba) {
				ArrayPush(this.poleHudbyData, vlastniHudba[i]);
				i += 1;
			}
		}
	}

	private final func NacistDataPostav() -> Void {
		let postavyData: array<ref<DataPostavy>> = DataPolePostav();
		ArrayClear(this.polePostavData);

		let seradit: Int32 = this.questsSystem.GetFact(Konstanty.FaktNastaveniSerazeni());
		if seradit > 0 {
			let seraditKateg: Int32 = this.questsSystem.GetFact(Konstanty.FaktNastaveniSerazeniKateg());

			if seraditKateg == 0 {
				let l = 0;
				while l < ArraySize(postavyData) {
					if postavyData[l].JeKateg {
						ArrayPush(this.polePostavData, postavyData[l]);
					}
					l += 1;
				}
			}

			let serazeneData: array<GlobalniID>;
			if seradit == 1 { serazeneData = PostavySerazeniJmenoAbc(); }
			if seradit == 2 { serazeneData = PostavySerazeniPrijmeniAbc(); }
			let j = 0;
			while j < ArraySize(serazeneData) {
				let k = 0;
				while k < ArraySize(postavyData) {
					if Equals(serazeneData[j], postavyData[k].GlobalniID) && (!postavyData[k].JeKateg || (seraditKateg == 1 && postavyData[k].JeKateg)) {
						ArrayPush(this.polePostavData, postavyData[k]);
						k = 9999;
					}
					k += 1;
				}
				j += 1;
			}
		}
		else
		{
			this.polePostavData = postavyData;
		}
		
		if this.cybCeny {
			let j = 0;
			while j < ArraySize(this.polePostavData) {
				this.polePostavData[j].Cena = CeilF(Cast<Float>(this.polePostavData[j].Cena) / 100.0);
				//this.polePostavData[j].NastavitSlevu(90);
				j += 1;
			}
		}
		else
		{
			let j = 0;

			if this.soucasnyEvent == 1 {
				while j < ArraySize(this.polePostavData) {
					this.polePostavData[j].NastavitSlevu(RandRange(40, 80));
					j += 1;
				}
			}

			if this.soucasnyEvent == 3 {
				while j < ArraySize(this.polePostavData) {
					let maBFGF: Bool =
						this.questsSystem.GetFact(n"sq030_judy_lover") > 0 ||
						this.questsSystem.GetFact(n"sq029_river_lover") > 0 ||
						this.questsSystem.GetFact(n"sq028_kerry_relationship") > 0 ||
						this.questsSystem.GetFact(n"sq027_panam_lover") > 0;

					if maBFGF {
						this.polePostavData[j].NastavitSlevu(40);
					} else {
						this.polePostavData[j].NastavitSlevu(80);
					}

					j += 1;
				}
			}
		}

		if Equals(this.aktivniTypMenu, MenuUITyp.KoupeniPV) {
			let j = 0;
			while j < ArraySize(this.polePostavData) {
				this.polePostavData[j].Cena *= 2;
				j += 1;
			}
		}
		
		if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) || Equals(this.aktivniTypMenu, MenuUITyp.Pevecka) || Equals(this.aktivniTypMenu, MenuUITyp.Streamovani) || Equals(this.aktivniTypMenu, MenuUITyp.GFH) {
			let j = 0;
			while j < ArraySize(this.polePostavData) {
				this.polePostavData[j].Cena = 0;
				j += 1;
			}
		}
		
		let vlastniPostavy: array<ref<DataPostavy>> = this.lizziesBDsSystem.VlastniPostavy();
		if ArraySize(vlastniPostavy) > 0 {
			let i = 0;
			while i < ArraySize(vlastniPostavy) {
				ArrayInsert(this.polePostavData, i, vlastniPostavy[i]);

				if Equals(vlastniPostavy[i].Pohlavi, GenderType.Female) { this.vlastniZeny = true; }
				if Equals(vlastniPostavy[i].Pohlavi, GenderType.Male) { this.vlastniMuzi = true; }

				i += 1;
			}
		}
		
		let dynNahledPovolen: Bool = this.questsSystem.GetFact(Konstanty.FaktNastaveniDynNahled()) != 2;
		if dynNahledPovolen {
			let k = 0;
			while k < ArraySize(this.polePostavData) {
				if !this.polePostavData[k].JeKateg && NotEquals(this.polePostavData[k].GlobalniID, GlobalniID.Postava_Adam_Smasher) {
					let j = 0;
					while j < ArraySize(this.polePostavData[k].Vzhledy) {
						if
							this.polePostavData[k].CustomID == 0 ||
							(this.polePostavData[k].CustomID > 0 && !this.polePostavData[k].Vzhledy[j].VlastniStatickyObr)
						{
							this.polePostavData[k].Vzhledy[j].ObrAtlasID = InkAtlasSoubor.DynamickyNahled;
							this.polePostavData[k].Vzhledy[j].ObrAtlasNazev = n"preview";
							//this.polePostavData[k].Vzhledy[j].Popis = "";
						}
						j += 1;
					}
				}
				k += 1;
			}
		}

		let ev: ref<LizziesBDsMenuUIPoNacteniPostav> = new LizziesBDsMenuUIPoNacteniPostav();
		ev.DataPostav = this.polePostavData;
		this.uiSystem.QueueEvent(ev);
	}

	private final func PostavaPrevestNaStrukt(postavaID: GlobalniID, vzhled: Int32, vlastni: Int32) -> ref<VybranaPostava> {
		let a: ref<VybranaPostava> = new VybranaPostava();
		a.PostavaVybrana = NotEquals(postavaID, GlobalniID.Prazdne);
		a.PostavaGID = postavaID;
		a.Vzhled = vzhled;
		a.Vlastni = vlastni;
		return a;
	}

	private final func ZiskatDataPostav(postavaStrukt: ref<VybranaPostava>) -> ref<DataPostavy> {
		return this.ZiskatDataPostav(postavaStrukt.PostavaGID, postavaStrukt.Vlastni);
	}

	private final func ZiskatDataPostav(postavaID: GlobalniID, vlastniPostava: Int32) -> ref<DataPostavy> {
		let i = 0;
		while i < ArraySize(this.polePostavData) {
			if Equals(this.polePostavData[i].GlobalniID, postavaID) && this.polePostavData[i].CustomID == vlastniPostava { return this.polePostavData[i]; }
			i += 1;
		}

		return null;
	}

	private final func ZiskatDataNastaveni(gID: GlobalniID) -> DataNastaveni {
		let i = 0;
		while i < ArraySize(this.poleNastaveniData) {
			if Equals(this.poleNastaveniData[i].GlobalniID, gID) { return this.poleNastaveniData[i]; }
			i += 1;
		}

		let d: DataNastaveni;
		return d;
	}

	private final func ZiskatDataHudby(ID: Int32) -> ref<DataHudby> {
		let i = 0;
		while i < ArraySize(this.poleHudbyData) {
			if Equals(this.poleHudbyData[i].ID, ID) { return this.poleHudbyData[i]; }
			i += 1;
		}

		return null;
	}

	private final func ZiskatDataLokace(lokaceID: Int32) -> ref<DataLokace> {
		let vybLover: Int32 = this.questsSystem.GetFact(this.factLover);

		let i = 0;
		while i < ArraySize(this.poleLokaciData) {
			if this.pozvaniDoBytuAktivni && ArraySize(this.poleLokaciData[i].Kontejner) == 0 {
				if vybLover == 4 && !this.poleLokaciData[i].PodporujeVelkouPostavu { this.poleLokaciData[i].Fakt = false; }
				if (vybLover == 2 || vybLover == 4) && Equals(this.poleLokaciData[i].PouzeProPohlavi, GenderType.Female) { this.poleLokaciData[i].Fakt = false; }
				if (vybLover == 1 || vybLover == 3) && Equals(this.poleLokaciData[i].PouzeProPohlavi, GenderType.Male) { this.poleLokaciData[i].Fakt = false; }
			}

			if EnumInt(this.poleLokaciData[i].GlobalniID) == lokaceID {
				this.poleLokaciData[i].NazevUplny = this.poleLokaciData[i].Nazev;
				return this.poleLokaciData[i];
			} else {
				if ArraySize(this.poleLokaciData[i].Kontejner) > 0 {
					let j = 0;
					while j < ArraySize(this.poleLokaciData[i].Kontejner) {
						if this.pozvaniDoBytuAktivni {
							if vybLover == 4 && !this.poleLokaciData[i].Kontejner[j].PodporujeVelkouPostavu { this.poleLokaciData[i].Kontejner[j].Fakt = false; }
							if (vybLover == 2 || vybLover == 4) && Equals(this.poleLokaciData[i].Kontejner[j].PouzeProPohlavi, GenderType.Female) { this.poleLokaciData[i].Kontejner[j].Fakt = false; }
							if (vybLover == 1 || vybLover == 3) && Equals(this.poleLokaciData[i].Kontejner[j].PouzeProPohlavi, GenderType.Male) { this.poleLokaciData[i].Kontejner[j].Fakt = false; }
						}

						if EnumInt(this.poleLokaciData[i].Kontejner[j].GlobalniID) == lokaceID {
							this.poleLokaciData[i].Kontejner[j].NazevUplny = this.poleLokaciData[i].Nazev + " - " + this.poleLokaciData[i].Kontejner[j].Nazev;
							this.poleLokaciData[i].Kontejner[j].Nadrazene = this.poleLokaciData[i];
							return this.poleLokaciData[i].Kontejner[j];
						}
						j += 1;
					}
				}
			}
			i += 1;
		}

		return null;
	}

	private final func ZiskatVybranouLokaci() -> ref<DataLokace> {
		return ArraySize(this.menuVybranaLokace.Kontejner) > 0 ? this.menuVybranaLokaceEpizoda : this.menuVybranaLokace;
	}

	private final func KoupenePVSeznam() -> Void {
		let ulozeno: array<ref<LizziesBDsUlozistePolozkaV5>> = this.lizziesBDsUloziste.VratitPoleDat(UlozisteTyp.Koupeno);

		let j = 0;
		while j < ArraySize(this.poleLokaciData) {
			this.poleLokaciData[j].JeKoupena = false;
			if ArraySize(this.poleLokaciData[j].Kontejner) > 0 {
				let k = 0;
				while k < ArraySize(this.poleLokaciData[j].Kontejner) {
					this.poleLokaciData[j].Kontejner[k].JeKoupena = false;
					k += 1;
				}
			}
			j += 1;
		}
		
		j = 0;
		while j < ArraySize(this.polePostavData) {
			this.polePostavData[j].JeKoupena = [];
			j += 1;
		}

		let i = 0;
		while i < ArraySize(ulozeno) {
			let kateg: array<Int32>;

			j = 0;
			while j < ArraySize(this.poleLokaciData) {
				if EnumInt(this.poleLokaciData[j].GlobalniID) == ulozeno[i].LokaceID {
					this.poleLokaciData[j].JeKoupena = true;
					j = 999;
				} else {
					if ArraySize(this.poleLokaciData[j].Kontejner) > 0 {
						let k = 0;
						while k < ArraySize(this.poleLokaciData[j].Kontejner) {
							if EnumInt(this.poleLokaciData[j].Kontejner[k].GlobalniID) == ulozeno[i].LokaceID {
								this.poleLokaciData[j].JeKoupena = true;
								this.poleLokaciData[j].Kontejner[k].JeKoupena = true;
								k = 999;
								j = 999;
							}
							k += 1;
						}
					}
				}
				j += 1;
			}

			j = 0;
			while j < ArraySize(this.polePostavData) {
				if ArraySize(ulozeno[i].Postavy) == 1 {
					if
						Equals(this.polePostavData[j].GlobalniID, ulozeno[i].Postavy[0].PostavaGID) &&
						this.polePostavData[j].CustomID == ulozeno[i].Postavy[0].Vlastni
					{
						ArrayPush(this.polePostavData[j].JeKoupena, ulozeno[i].LokaceID);

						for ktg in this.polePostavData[j].VlozitDoMenu {
							ArrayPush(kateg, EnumInt(ktg));
						}

						for ktg in this.polePostavData[j].VlozitDoMenuVlastni {
							ArrayPush(kateg, ktg);
						}
					}
				}
				j += 1;
			}

			j = 0;
			while j < ArraySize(this.polePostavData) {
				if this.polePostavData[j].JeKateg {
					if 
						ArrayContains(kateg, EnumInt(this.polePostavData[j].PrirazenaStranka)) && NotEquals(this.polePostavData[j].PrirazenaStranka, MenuStrankaTyp.Kateg_Vlastni) ||
						ArrayContains(kateg, this.polePostavData[j].CustomID)
					{
						ArrayPush(this.polePostavData[j].JeKoupena, ulozeno[i].LokaceID);
					}
				}
				j += 1;
			}

			i += 1;
		}
	}

	private final func KoupeneKazety() -> Void {
		let ids: array<Int32>;

		let ulozeno: array<ref<LizziesBDsUlozistePolozkaV5>> = this.lizziesBDsUloziste.VratitPoleDat(UlozisteTyp.Koupeno);

		let i = 0;
		while i < ArraySize(ulozeno) {
			if !ArrayContains(ids, ulozeno[i].LokaceID) {
				ArrayPush(ids, ulozeno[i].LokaceID);
			}
			i += 1;
		}

		let j = 0;
		while j < ArraySize(this.poleLokaciData) {
			if ArraySize(this.poleLokaciData[j].Kontejner) > 0 {
				let k = 0;
				while k < ArraySize(this.poleLokaciData[j].Kontejner) {
					if Equals(this.poleLokaciData[j].GlobalniID, GlobalniID.Lokace_Kont_Various) || Equals(this.poleLokaciData[j].GlobalniID, GlobalniID.Lokace_Kont_Cyberpsycho) {
						this.questsSystem.SetFact(StringToName("lizzies_bds_cartridges_bd_" + ToString(EnumInt(this.poleLokaciData[j].Kontejner[k].GlobalniID))), ArrayContains(ids, EnumInt(this.poleLokaciData[j].Kontejner[k].GlobalniID)) ? 1 : 0);
					} else {
						this.questsSystem.SetFact(StringToName("lizzies_bds_cartridges_bd_" + ToString(EnumInt(this.poleLokaciData[j].GlobalniID))), ArrayContains(ids, EnumInt(this.poleLokaciData[j].Kontejner[k].GlobalniID)) ? 1 : 0);
						k = 999;
					}
					k += 1;
				}
			} else {
				this.questsSystem.SetFact(StringToName("lizzies_bds_cartridges_bd_" + ToString(EnumInt(this.poleLokaciData[j].GlobalniID))), ArrayContains(ids, EnumInt(this.poleLokaciData[j].GlobalniID)) ? 1 : 0);
			}
			j += 1;
		}
	}

	private final func PrehraneKazety(lokace: GlobalniID) -> Void {
		if NotEquals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) { return; }

		let j = 0;
		while j < ArraySize(this.poleLokaciData) {
			if ArraySize(this.poleLokaciData[j].Kontejner) > 0 {
				let k = 0;
				while k < ArraySize(this.poleLokaciData[j].Kontejner) {
					if Equals(this.poleLokaciData[j].Kontejner[k].GlobalniID, lokace) {
						this.questsSystem.SetFact(n"lizzies_bds_cartridges_played", Equals(this.poleLokaciData[j].GlobalniID, GlobalniID.Lokace_Kont_Various) || Equals(this.poleLokaciData[j].GlobalniID, GlobalniID.Lokace_Kont_Cyberpsycho) ? EnumInt(lokace) : EnumInt(this.poleLokaciData[j].GlobalniID));
						k = 999;
					}
					k += 1;
				}
			} else {
				if Equals(this.poleLokaciData[j].GlobalniID, lokace) {
					this.questsSystem.SetFact(n"lizzies_bds_cartridges_played", EnumInt(lokace));
					j = 999;
				}
			}
			j += 1;
		}
	}

	private final func TextPovolenoZakazano(podminka: Bool) -> String {
		return podminka ? GetLocalizedText("LocKey#15142054") : GetLocalizedText("LocKey#15142055");
	}

	private final func PridatMoznostPostava(dataPostavy: ref<DataPostavy>) -> Void {
		let hodnotaFaktu: Int32 = this.questsSystem.GetFact(dataPostavy.FaktPostavy());
		if hodnotaFaktu == 1 && NotEquals(this.aktivniTypMenu, MenuUITyp.Nastaveni) { return; }
		let tmpLokace: ref<DataLokace> = this.ZiskatVybranouLokaci();

		if dataPostavy.JeEP1 {
			if !this.ep1JeInstalovane { return; }
		}

		if dataPostavy.VelkaPostava && NotEquals(this.aktivniTypMenu, MenuUITyp.GFH) {
			if !tmpLokace.PodporujeVelkouPostavu { return; }
		}
		if dataPostavy.JeSpecialniPostava {
			if !tmpLokace.PodporujeSpecialni { return; }
		}

		if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
			if !ArrayContains(dataPostavy.JeKoupena, EnumInt(tmpLokace.GlobalniID)) {
				return;
			}
		}

		if this.pozvaniDoBytuAktivni {
			let partner: GlobalniID = this.PozvaniDoBytuAktivniPostava();
			if Equals(dataPostavy.GlobalniID, partner) {
				return;
			}
		}

		if
			Equals(dataPostavy.GlobalniID, GlobalniID.Postava_Lucyna_Lucy_Kushinada) ||
			Equals(dataPostavy.GlobalniID, GlobalniID.Postava_Miranda_Lawson) ||
			Equals(dataPostavy.GlobalniID, GlobalniID.Postava_Song_So_Ri) ||
			Equals(dataPostavy.GlobalniID, GlobalniID.Postava_E3_Female_V) ||
			Equals(dataPostavy.GlobalniID, GlobalniID.Postava_E3_Male_V) ||
			Equals(dataPostavy.GlobalniID, GlobalniID.Postava_Canon_FemV)
		{
			let entSoubor: ResRef = DataEntit(dataPostavy.GlobalniID, 0, GenderType.None);
			if !GameInstance.GetResourceDepot().ResourceExists(entSoubor) { return; }
		}
		if Equals(dataPostavy.GlobalniID, GlobalniID.Postava_Female_V) && this.questsSystem.GetFact(this.factPlayerGender) != 2 { return; }
		if Equals(dataPostavy.GlobalniID, GlobalniID.Postava_Male_V) && this.questsSystem.GetFact(this.factPlayerGender) != 1 { return; }
		if Equals(dataPostavy.PrirazenaStranka, MenuStrankaTyp.Kateg_Vlastni) && Equals(this.vybranePohlavi, GenderType.Female) && !this.vlastniZeny { return; }
		if Equals(dataPostavy.PrirazenaStranka, MenuStrankaTyp.Kateg_Vlastni) && Equals(this.vybranePohlavi, GenderType.Male) && !this.vlastniMuzi { return; }

		if this.lizziesBDsOnline.Instalovano() {
			let slevaProcCelkem: Int32 = this.lizziesBDsOnline.celkovyPocet + 1;

			let k = 0;
			while k < ArraySize(this.lizziesBDsOnline.zhaveDnesID) {
				if Equals(this.lizziesBDsOnline.zhaveDnesID[k], EnumInt(dataPostavy.GlobalniID)) {
					dataPostavy.NastavitSlevu(Cast<Int32>((Cast<Float>(this.lizziesBDsOnline.zhaveDnesPocet[k]) / Cast<Float>(slevaProcCelkem)) * 100.0));
				}
				k += 1;
			}

			let nd: array<GlobalniID> = NarozeninyData(this.lizziesBDsOnline.dnesniDatum);
			if ArrayContains(nd, dataPostavy.GlobalniID) || ArrayContains(nd, GlobalniID.Prazdne) {
				dataPostavy.NastavitSlevu(90);
			}
		}

		let druhyNazev: String = "";
		let barvaTextu: Int32 = 0;
		let barvaDruhehoTextu: Int32 = 0;
		
		if dataPostavy.JeKateg {
			druhyNazev = GetLocalizedText("LocKey#15144002");
			barvaTextu = 3;
			barvaDruhehoTextu = 1;
		}

		if NotEquals(this.aktivniTypMenu, MenuUITyp.KoupeniPV) && ArraySize(dataPostavy.Vzhledy) > 1 {
			druhyNazev = GetLocalizedText("LocKey#15144059");
			barvaTextu = 3;
			barvaDruhehoTextu = 1;
		}

		if Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) && (!dataPostavy.JeKateg || (dataPostavy.JeKateg && !dataPostavy.NastaveniKateg)) {
			druhyNazev = hodnotaFaktu != 1 ? GetLocalizedText("LocKey#15144023") : GetLocalizedText("LocKey#15144024");
			barvaTextu = 0;
			barvaDruhehoTextu = hodnotaFaktu != 1 ? 1 : 2;
		}
		
		let cena: Int32 = 0;
		let sleva: Int32 = 0;

		if NotEquals(this.aktivniTypMenu, MenuUITyp.Pevecka) && NotEquals(this.aktivniTypMenu, MenuUITyp.PostavaMoznosti) && NotEquals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) && NotEquals(this.aktivniTypMenu, MenuUITyp.GFH) {
			cena = dataPostavy.Cena;
			sleva = dataPostavy.MaSlevu;
		}
		
		let ulozisteStrukt: ref<VybranaPostava> = this.PostavaPrevestNaStrukt(dataPostavy.GlobalniID, 0, dataPostavy.CustomID);
		let oblibene: Bool = false;
		if NotEquals(this.aktivniTypMenu, MenuUITyp.Nastaveni) && NotEquals(this.aktivniTypMenu, MenuUITyp.PostavaMoznosti) && !dataPostavy.JeKateg && ArraySize(dataPostavy.Vzhledy) == 1 && !this.menuLokaceAktivni {
			oblibene = this.lizziesBDsUloziste.JeVUlozisti(UlozisteTyp.Oblibene, EnumInt(tmpLokace.GlobalniID), [],
				[ulozisteStrukt]
			) != -1;
		}

		if Equals(this.aktivniTypMenu, MenuUITyp.KoupeniPV) {
			let jeKoupeno: Bool = this.lizziesBDsUloziste.JeVUlozisti(UlozisteTyp.Koupeno, EnumInt(tmpLokace.GlobalniID), [], [ulozisteStrukt]) != -1;
			if jeKoupeno {
				druhyNazev = GetLocalizedText("LocKey#15142272");
				cena = 0;
				barvaDruhehoTextu = 1;
			}
		}

		let pridano: Bool = this.PridatMoznostInterni(
			MenuAkceTyp.__Postava,
			[EnumInt(dataPostavy.GlobalniID), dataPostavy.CustomID],
			dataPostavy.ZiskatNazevPostavy(),
			druhyNazev,
			true,
			barvaTextu,
			Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) && hodnotaFaktu == 1,
			false,
			barvaDruhehoTextu,
			cena,
			oblibene,
			0,
			sleva
		);

		if pridano {
			if Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) {
				this.nastaveniBinarniZobrazeni = this.nastaveniBinarniZobrazeni + this.decimalToHex(EnumInt(dataPostavy.GlobalniID), true, true) + "0" + hodnotaFaktu + " ";
			}
		}
	}

	private final func PridatMoznostNastaveni(gID: GlobalniID, i: Int32) -> Void {
		let dataNastaveni: DataNastaveni = this.ZiskatDataNastaveni(gID);

		if !dataNastaveni.FaktZobrazeni { return; }
		
		let fakt: CName = dataNastaveni.FaktKeZmene;
		let hodnotaFaktu: Int32 = 0;

		if Equals(dataNastaveni.Typ, NastaveniTyp.Postava) {
			hodnotaFaktu = GlobalniFunkce.ZiskatNastaveni(this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].Nastaveni, fakt);
		} else if Equals(dataNastaveni.Typ, NastaveniTyp.Lokace) {
			hodnotaFaktu = GlobalniFunkce.ZiskatNastaveni(this.menuVybraneNastaveni, fakt);
			} else if Equals(dataNastaveni.Typ, NastaveniTyp.PV) {
				hodnotaFaktu = this.questsSystem.GetFact(StringToName(NameToString(fakt) + ToString(this.lokaceVyberPostavVybP)));
		} else {
			hodnotaFaktu = this.questsSystem.GetFact(fakt);
		}
		
		let druhyNazev: String = "";

		if ArraySize(dataNastaveni.VlastniMoznosti) > 0 {
			druhyNazev = dataNastaveni.VlastniMoznosti[hodnotaFaktu];
		} else {
			druhyNazev = this.TextPovolenoZakazano(hodnotaFaktu != dataNastaveni.HodnotaZakazano);
		}

		let pridano: Bool = this.PridatMoznostInterni(
			MenuAkceTyp.NastaveniRuzne_Nastaveni,
			[i],
			dataNastaveni.Nazev,
			druhyNazev,
			true,
			0,
			hodnotaFaktu == dataNastaveni.HodnotaZakazano,
			false,
			hodnotaFaktu == dataNastaveni.HodnotaZakazano ? 2 : 1,
			0,
			false,
			0,
			0
		);

		if pridano {
			this.nastaveniBinarniZobrazeni = this.nastaveniBinarniZobrazeni + this.decimalToHex(EnumInt(dataNastaveni.GlobalniID), true, true) + "0" + hodnotaFaktu + " ";
		}
	}

	private final func PridatMoznost(globalniID: MenuAkceTyp, btnName: String, btnSecName: String, factCond: Bool, barvaTextu: Int32, barvaDruhehoTextu: Int32) -> Void {
		this.PridatMoznostInterni(globalniID, [], btnName, btnSecName, factCond, barvaTextu, false, StrCmp(btnSecName, "") == 0, barvaDruhehoTextu, 0, false, 0, 0);
	}

	private final func PridatMoznostInterni(akce: MenuAkceTyp, data: array<Int32>, btnName: String, btnSecName: String, factCond: Bool, barvaTextu: Int32, cervenePozadi: Bool, vycentrovani: Bool, barvaDruhehoTextu: Int32, cena: Int32, oblibene: Bool, extText: Int32, sleva: Int32) -> Bool {
		if !factCond {
			return false;
		}

		let maxTlacitek: Int32 = 17;
		if !this.zobrazitZakladniNavigaci { maxTlacitek = 19; }
		if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_Hlavni) {
			/*if this.zobrazitZakladniNavigaci { maxTlacitek = 14; }
			else { maxTlacitek = 15; }*/
			maxTlacitek = 13;
		}
		if this.mensiVerzeMenu {
			maxTlacitek = 9;
		}

		if (NotEquals(akce, MenuAkceTyp.Globalni_DalsiStranka) && NotEquals(akce, MenuAkceTyp.Globalni_Zpet)) && (this.menuTrvale == 0) {
			if this.soucasnyIndexPolozky > maxTlacitek {
				this.soucasnyIndexGenerovaniStranky += 1;
				this.soucasnyIndexPolozky = 0;
			}

			this.pocetPolozekVKategorii += 1;

			if this.menuStrom.StrankovaniOp(0) != this.soucasnyIndexGenerovaniStranky { this.soucasnyIndexPolozky += 1; return false; }
		}

		if Equals(akce, MenuAkceTyp.Globalni_DalsiStranka) || Equals(akce, MenuAkceTyp.Globalni_Zpet) || this.menuTrvale > 0 {
			this.soucasnyIndexPolozky = ArraySize(this.polePolozkyMenu);
		}

		let pridatText: String = "";

		if this.lizziesBDsOnline.Instalovano() {
			if Equals(akce, MenuAkceTyp.__Postava) || Equals(akce, MenuAkceTyp.LokaceKontejner_Lokace) || Equals(akce, MenuAkceTyp.Hlavni_Lokace) {
				let zhaveDnes: array<Int32> = this.lizziesBDsOnline.zhaveDnesID;
				if ArrayContains(zhaveDnes, data[0]) {
					pridatText = s" <Rich color=\"#ff0000\">\(GetLocalizedText("LocKey#15144063"))</>";
				}
				/*if Equals(akce, MenuAkceTyp.LokaceKontejner_Lokace) {
					if ArrayContains(zhaveDnes, data[1]) {
						pridatText = s" <Rich color=\"#ff0000\">\(GetLocalizedText("LocKey#15144063"))</>";
					}
				} else {
					if ArrayContains(zhaveDnes, data[0]) {
						pridatText = s" <Rich color=\"#ff0000\">\(GetLocalizedText("LocKey#15144063"))</>";
					}
				}*/
			}
		}

		if extText == 1 {
			pridatText += s" <Rich color=\"#FFD700\">\(GetLocalizedText("LocKey#15144070"))</>";
		}
		if extText == 2 {
			pridatText += s" <Rich color=\"#ff0000\">\(GetLocalizedText("LocKey#15144089"))</>";
		}

		let polozka: MenuPolozkaData;
		polozka.Akce = akce;
		polozka.Hodnota = this.soucasnyIndexPolozky;
		polozka.Data = data;
		polozka.Zakazano = barvaTextu == 3 && StrCmp(btnSecName, "") == 0 && extText == 0; //Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) && 
		polozka.AnimaceVybrana = new inkAnimProxy();
		polozka.AnimaceKonec = new inkAnimProxy();
		ArrayPush(this.polePolozkyMenu, polozka);

		let root: ref<inkCanvas> = new inkCanvas();
		root.SetName(StringToName("button_" + this.soucasnyIndexPolozky));
		root.SetSize(new Vector2(500.0, 50.0));
		root.SetAnchorPoint(new Vector2(0.5, 0));
		root.SetAnchor(inkEAnchor.TopCenter);
		root.SetMargin(new inkMargin(0.0, 0.0, 0.0, 10.0));
		root.Reparent(this.menuTrvale > 0 ? this.tlacitkaTrvaleCtrl : this.tlacitkaCtrl);

		this.soucasnyIndexPolozky += 1;

		let frame: ref<inkImage> = new inkImage();
		frame.SetName(n"frame");
		frame.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
		frame.SetTexturePart(n"cell_fg");
		frame.SetNineSliceScale(true);
		frame.SetTintColor(this.vlastniBarvaPozadi);
		frame.SetSize(new Vector2(840.0, 50.0));
		frame.SetAnchorPoint(new Vector2(0.5, 0));
		frame.SetAnchor(inkEAnchor.TopCenter);
		frame.Reparent(root);

		if cervenePozadi {
			let frameBG: ref<inkImage> = new inkImage();
			frameBG.SetName(n"frameBG");
			frameBG.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
			frameBG.SetTexturePart(n"cell_bg");
			frameBG.SetNineSliceScale(true);
			frameBG.SetTintColor(new HDRColor(0.3, 0, 0, 1));
			frameBG.SetSize(new Vector2(835.0, 46.0));
			frameBG.SetAnchorPoint(new Vector2(0.5, 0.5));
			frameBG.SetAnchor(inkEAnchor.Centered);
			frameBG.Reparent(root);
		}

		let containerSel: ref<inkCanvas> = new inkCanvas();
		containerSel.SetName(n"container_sel");
		containerSel.SetOpacity(0.0);
		containerSel.SetAnchor(inkEAnchor.TopCenter);
		containerSel.Reparent(root);

		let frameH: ref<inkImage> = new inkImage();
		frameH.SetName(n"frameH");
		frameH.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
		frameH.SetTexturePart(n"cell_fg");
		frameH.SetNineSliceScale(true);
		frameH.SetTintColor(this.vlastniBarvaVyber);
		frameH.SetSize(new Vector2(840.0, 50.0));
		frameH.SetAnchorPoint(new Vector2(0.5, 0));
		frameH.SetAnchor(inkEAnchor.TopCenter);
		frameH.Reparent(containerSel);

		let frameHBG: ref<inkImage> = new inkImage();
		frameHBG.SetName(n"frameHBG");
		frameHBG.SetAtlasResource(r"base\\gameplay\\gui\\common\\shapes\\atlas_shapes_sync.inkatlas");
		frameHBG.SetTexturePart(n"cell_bg");
		frameHBG.SetNineSliceScale(true);
		frameHBG.SetTintColor(this.vlastniBarva);
		frameHBG.SetSize(new Vector2(840.0, 50.0));
		frameHBG.SetAnchorPoint(new Vector2(0.5, 0));
		frameHBG.SetAnchor(inkEAnchor.TopCenter);
		frameHBG.SetOpacity(0.02);
		frameHBG.Reparent(containerSel);

		let btnNameCtrl: ref<inkRichTextBox> = new inkRichTextBox();
		btnNameCtrl.SetName(n"btnName");
		btnNameCtrl.SetText(btnName + pridatText);
		btnNameCtrl.SetMargin(new inkMargin(0.0, 0.0, 0.0, 0.0));
		btnNameCtrl.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
		btnNameCtrl.SetFontSize(30);
		btnNameCtrl.SetFontStyle(n"Semi-Bold");
		btnNameCtrl.SetAnchorPoint(new Vector2(0, 0.5));
		btnNameCtrl.SetAnchor(inkEAnchor.CenterLeft);
		btnNameCtrl.SetVerticalAlignment(textVerticalAlignment.Center);
		if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
			btnNameCtrl.SetSize(new Vector2(790.00, 50.0));
		} else {
			btnNameCtrl.SetSize(new Vector2(670.0, 50.0));
		}
		if vycentrovani && cena == 0 {
			btnNameCtrl.SetAnchor(inkEAnchor.Centered);
			btnNameCtrl.SetAnchorPoint(new Vector2(0.5, 0.5));
		} else {
			btnNameCtrl.textOverflowPolicy = textOverflowPolicy.DotsEnd;
			btnNameCtrl.SetFitToContent(false);
		}
		if barvaTextu == 1 {
			btnNameCtrl.SetTintColor(new HDRColor(0.59, 0.83, 0.31, 1));
		}
		if barvaTextu == 2 {
			btnNameCtrl.SetTintColor(new HDRColor(0.98, 0.36, 0.39, 1));
		}
		if barvaTextu == 3 || extText > 0 {
			btnNameCtrl.SetTintColor(new HDRColor(0.8, 0.8, 0.8, 1));
		}
		if barvaTextu == 4 {
			btnNameCtrl.SetTintColor(new HDRColor(1, 0.843, 0, 1));
		}
		btnNameCtrl.Reparent(root);

		if StrCmp(btnSecName, "") != 0 && extText == 0 {
			let btnSecNameCtrl: ref<inkText> = new inkText();
			btnSecNameCtrl.SetName(n"btnSecName");
			btnSecNameCtrl.SetText(btnSecName);
			btnSecNameCtrl.SetMargin(new inkMargin(0.0, 0.0, 10.0, 0.0));
			btnSecNameCtrl.SetSize(new Vector2(400.0, 50.0));
			btnSecNameCtrl.SetHorizontalAlignment(textHorizontalAlignment.Right);
			btnSecNameCtrl.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
			btnSecNameCtrl.SetFontSize(30);
			btnSecNameCtrl.SetFontStyle(n"Regular");
			btnSecNameCtrl.SetAnchorPoint(new Vector2(1, 0.5));
			btnSecNameCtrl.SetAnchor(inkEAnchor.CenterRight);
			btnSecNameCtrl.SetTintColor(new HDRColor(0.8, 0.8, 0.8, 1));
			btnSecNameCtrl.Reparent(root);

			if barvaDruhehoTextu == 1 {
				btnSecNameCtrl.SetTintColor(new HDRColor(0, 0.861, 0, 1));
			} else if barvaDruhehoTextu == 2 {
				btnSecNameCtrl.SetTintColor(new HDRColor(1.0, 0.0, 0.0, 1));
			}
		}

		if cena > 0 && StrCmp(btnSecName, "") == 0 && !polozka.Zakazano {
			let btnCenaCtrl: ref<inkText> = new inkText();
			btnCenaCtrl.SetName(n"btnCenaTxt");
			btnCenaCtrl.SetText("€$ " + GlobalniFunkce.FormatovanaCena(cena));
			btnCenaCtrl.SetMargin(new inkMargin(0.0, 0.0, 10.0, 0.0));
			btnCenaCtrl.SetSize(new Vector2(400.0, 50.0));
			btnCenaCtrl.SetHorizontalAlignment(textHorizontalAlignment.Right);
			btnCenaCtrl.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
			btnCenaCtrl.SetFontSize(30);
			btnCenaCtrl.SetFontStyle(n"Semi-Bold");
			btnCenaCtrl.SetAnchorPoint(new Vector2(1, 0.5));
			btnCenaCtrl.SetAnchor(inkEAnchor.CenterRight);
			btnCenaCtrl.SetTintColor(new HDRColor(1, 0.843, 0, 1));
			btnCenaCtrl.Reparent(root);

			if this.hracPenize < cena {
				btnCenaCtrl.SetTintColor(new HDRColor(1.0, 0.0, 0.0, 1));
			}

			if sleva > 0 {
				let btnSlevaCtrl: ref<inkText> = new inkText();
				btnSlevaCtrl.SetName(n"btnSlevaTxt");
				btnSlevaCtrl.SetText("-" + sleva + "%");
				btnSlevaCtrl.SetMargin(new inkMargin(0.0, 10.0, -40.0, 0.0));
				btnSlevaCtrl.SetSize(new Vector2(50.0, 50.0));
				btnSlevaCtrl.SetHorizontalAlignment(textHorizontalAlignment.Right);
				btnSlevaCtrl.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
				btnSlevaCtrl.SetFontSize(30);
				btnSlevaCtrl.SetFontStyle(n"Semi-Bold");
				btnSlevaCtrl.SetAnchorPoint(new Vector2(1, 0.5));
				btnSlevaCtrl.SetAnchor(inkEAnchor.TopRight);
				btnSlevaCtrl.SetTintColor(new HDRColor(1.0, 0.0, 0, 1));
				btnSlevaCtrl.SetRotation(30.0);
				btnSlevaCtrl.Reparent(root);
			}
		}

		if oblibene {
			let fav: ref<inkImage> = new inkImage();
			fav.SetName(n"fav");
			fav.SetAtlasResource(r"mod\\arman3_lizzies_bds\\gameplay\\gui\\icons\\icons.inkatlas");
			fav.SetTexturePart(n"favorite_lizzies_bds");
			fav.SetTintColor(new HDRColor(1.0, 0.8, 0.0, 1.0));
			fav.SetSize(new Vector2(30.0, 30.0));
			fav.SetMargin(new inkMargin(-33.0, 9.0, 0.0, 0.0));
			fav.SetAnchorPoint(new Vector2(0, 0));
			fav.SetAnchor(inkEAnchor.TopLeft);
			fav.SetScale(new Vector2(1, 1));
			fav.SetContentHAlign(inkEHorizontalAlign.Fill);
			fav.SetContentVAlign(inkEVerticalAlign.Fill);
			fav.SetRenderTransformPivot(0, 0);
			fav.SetOpacity(1);
			fav.Reparent(root);
		}

		if polozka.Zakazano {
			let ban: ref<inkImage> = new inkImage();
			ban.SetName(n"ban");
			ban.SetAtlasResource(r"mod\\arman3_lizzies_bds\\gameplay\\gui\\icons\\icons.inkatlas");
			ban.SetTexturePart(n"ban_lizzies_bds");
			ban.SetTintColor(new HDRColor(1.0, 0.0, 0.0, 1.0));
			ban.SetSize(new Vector2(30.0, 30.0));
			ban.SetMargin(new inkMargin(0.0, 9.0, 35.0, 0.0));
			ban.SetAnchorPoint(new Vector2(0, 0));
			ban.SetAnchor(inkEAnchor.TopRight);
			ban.SetScale(new Vector2(1, 1));
			ban.SetContentHAlign(inkEHorizontalAlign.Fill);
			ban.SetContentVAlign(inkEVerticalAlign.Fill);
			ban.SetRenderTransformPivot(0, 0);
			ban.SetOpacity(1);
			ban.Reparent(root);
		}

		//if this.nahledHudbyAktivni && this.menuData[this.vybraneMenu].SoucasneVybranaPolozka == polozka.Hodnota {
		if Equals(akce, MenuAkceTyp.VybratHudbu_Vybrat) {
			let ban: ref<inkImage> = new inkImage();
			ban.SetName(n"sound_icon");
			ban.SetAtlasResource(r"mod\\arman3_lizzies_bds\\gameplay\\gui\\icons\\icons.inkatlas");
			ban.SetTexturePart(n"sound_lizzies_bds");
			ban.SetTintColor(new HDRColor(0.0, 1.0, 0.0, 1.0));
			ban.SetSize(new Vector2(30.0, 30.0));
			ban.SetMargin(new inkMargin(0.0, 9.0, 35.0, 0.0));
			ban.SetAnchorPoint(new Vector2(0, 0));
			ban.SetAnchor(inkEAnchor.TopRight);
			ban.SetScale(new Vector2(1, 1));
			ban.SetContentHAlign(inkEHorizontalAlign.Fill);
			ban.SetContentVAlign(inkEVerticalAlign.Fill);
			ban.SetRenderTransformPivot(0, 0);
			ban.SetOpacity(0);
			ban.Reparent(root);
		}

		return true;
	}

	private final func PridatMezeru() -> Void {
		let root: ref<inkCanvas> = new inkCanvas();
		root.SetName(n"mezera");
		root.SetSize(new Vector2(500.0, 50.0));
		root.SetAnchorPoint(new Vector2(0.5, 0));
		root.SetAnchor(inkEAnchor.TopCenter);
		root.SetMargin(new inkMargin(0.0, 0.0, 0.0, 10.0));
		root.Reparent(this.menuTrvale > 0 ? this.tlacitkaTrvaleCtrl : this.tlacitkaCtrl);
	}

	private final func PridatMalyNadpis(text: String) -> Void {
		let root: ref<inkCanvas> = new inkCanvas();
		root.SetName(n"nadpis");
		root.SetSize(new Vector2(500.0, 50.0));
		root.SetAnchorPoint(new Vector2(0.5, 0));
		root.SetAnchor(inkEAnchor.TopCenter);
		root.SetMargin(new inkMargin(0.0, 0.0, 0.0, 10.0));
		root.Reparent(this.menuTrvale > 0 ? this.tlacitkaTrvaleCtrl : this.tlacitkaCtrl);
		
		let nadpis: ref<inkRichTextBox> = new inkRichTextBox();
		nadpis.SetName(n"nadpis_text");
		nadpis.SetText(text);
		nadpis.SetMargin(new inkMargin(-20.0, 0.0, 0.0, 0.0));
		nadpis.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
		nadpis.SetFontSize(30);
		nadpis.SetFontStyle(n"Semi-Bold");
		nadpis.SetAnchorPoint(new Vector2(0, 0.4));
		nadpis.SetAnchor(inkEAnchor.CenterLeft);
		nadpis.SetVerticalAlignment(textVerticalAlignment.Center);
		nadpis.SetSize(new Vector2(790.00, 50.0));
		nadpis.SetTintColor(new HDRColor(1, 0.843, 0, 1));
		nadpis.SetFitToContent(false);
		nadpis.Reparent(root);
	}

	private final func ZvyraznitMoznost() -> Void {
		let vybranaPolozka: Int32 = this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Ziskat);

		if this.posledniIndexMoznosti != 99 && this.posledniIndexMoznosti != vybranaPolozka {
			this.NastaveniOhraniceni(this.posledniIndexMoznosti, false);

			if this.nahledHudbyAktivni {
				this.nahledHudbyAktivniCtrlPic.SetOpacity(0);
			}
		}
		this.NastaveniOhraniceni(vybranaPolozka, true);
		this.posledniIndexMoznosti = vybranaPolozka;
	}

	private final func NastaveniOhraniceni(vybranaPolozka: Int32, zvyraznit: Bool) -> Void {
		let frameContainerCtrl: ref<inkCanvas> = this.GetChildWidgetByPath(StringToName("main_ui/main_container/buttons" + (vybranaPolozka >= this.menuTrvale && this.menuTrvale > 0 ? "_persist" : "") + "/button_" + vybranaPolozka + "/container_sel")) as inkCanvas;
		if zvyraznit {
			this.polePolozkyMenu[vybranaPolozka].AnimaceKonec.Stop();
			frameContainerCtrl.SetOpacity(1.0);
			
			let frameHCtrl: ref<inkImage> = this.GetChildWidgetByPath(StringToName("main_ui/main_container/buttons" + (vybranaPolozka >= this.menuTrvale && this.menuTrvale > 0 ? "_persist" : "") + "/button_" + vybranaPolozka + "/container_sel/frameH")) as inkImage;
			let opts: inkAnimOptions;
			opts.loopType = inkanimLoopType.Cycle;
			opts.loopInfinite = true;
			this.polePolozkyMenu[vybranaPolozka].AnimaceVybrana.Stop();
			this.polePolozkyMenu[vybranaPolozka].AnimaceVybrana = frameHCtrl.PlayAnimationWithOptions(this.animaceVybranaDef, opts);
		} else {
			this.polePolozkyMenu[vybranaPolozka].AnimaceVybrana.Stop();

			this.polePolozkyMenu[vybranaPolozka].AnimaceKonec.Stop();
			this.polePolozkyMenu[vybranaPolozka].AnimaceKonec = frameContainerCtrl.PlayAnimation(this.animaceKonecDef);
		}
	}

	private final func ZobrazitSpodniMenu(stred: Bool) -> Void {
		if stred {
			this.menuTrvaleCtrl.SetMargin(new inkMargin(-400.0, 464, 0, 0));
			this.tlacitkaTrvaleCtrl.SetMargin(new inkMargin(-400.0, 500, 0, 0));
		} else {
			this.menuTrvaleCtrl.SetMargin(new inkMargin(-400.0, 1000, 0, 0));
			this.tlacitkaTrvaleCtrl.SetMargin(new inkMargin(-400.0, 1030, 0, 0));
		}

		this.menuTrvale = this.soucasnyIndexPolozky;
		if !this.menuTrvaleCtrl.IsVisible() {
			this.menuTrvaleCtrl.SetVisible(true);
			this.PlayLibraryAnimation(n"show_menu_line");
		}
	}

	private func ZmenaVzhleduZiskatData(indexPostavy: Int32) -> ref<VybranaPostava> {
		let faktPostava: CName = StringToName(Konstanty.FaktVybranaPostava() + ToString(indexPostavy));
		let faktPostavaVlastni: CName = StringToName(Konstanty.FaktVybranaPostavaVlastni() + ToString(indexPostavy));
		let faktPostavaVzhled: CName = StringToName(Konstanty.FaktVybranyVzhled() + ToString(indexPostavy));

		let postava2: Int32 = this.questsSystem.GetFact(faktPostava);
		let postavaVlastni2: Int32 = this.questsSystem.GetFact(faktPostavaVlastni);
		let vzhled2: Int32 = this.questsSystem.GetFact(faktPostavaVzhled);
		let data2: ref<DataPostavy> = this.ZiskatDataPostav(IntEnum(postava2), postavaVlastni2);

		let strukt: ref<VybranaPostava> = new VybranaPostava();
		strukt.PostavaVybrana = IsDefined(data2);
		strukt.DataPostavy = data2;
		strukt.Nazev = strukt.PostavaVybrana ? data2.ZiskatNazevPostavy(vzhled2) : "-";
		strukt.Vzhled = vzhled2;
		strukt.Vlastni = postavaVlastni2;
		strukt.PostavaGID = strukt.PostavaVybrana ? data2.GlobalniID : GlobalniID.Prazdne;
		return strukt;
	}

	private func VytvoritMenuPolozekZUloziste(typUloziste: UlozisteTyp, pouzeLokace: Int32, nazevLokace: Bool) -> Int32 {
		let ulozeno: array<ref<LizziesBDsUlozistePolozkaV5>> = this.lizziesBDsUloziste.VratitPoleDat(typUloziste);
		let pocet: Int32 = ArraySize(ulozeno);

		let i = 0;
		while i < pocet {
			if pouzeLokace == -1 || (pouzeLokace >= 0 && pouzeLokace == ulozeno[i].LokaceID) {
				let validni: Bool = true;
			
				let dataLokace: ref<DataLokace> = this.ZiskatDataLokace(ulozeno[i].LokaceID);

				if IsDefined(dataLokace) && ArraySize(ulozeno[i].Postavy) == dataLokace.PocetPostav {
					let cena: Int32 = dataLokace.Cena;
					let nazev: String = "";
					let druhyNazev: String = "";

					if dataLokace.BezPostavy {
						nazev = dataLokace.Nazev;
					} else {
						nazev = nazevLokace ? ("<Rich color=\"#AAAAAA\">" + dataLokace.Nazev + "</> <Rich color=\"#cc008c\">|</> ") : "";
						druhyNazev = GetLocalizedText("LocKey#15144002");

						let j = 0;
						while j < dataLokace.PocetPostav && validni {
							if NotEquals(ulozeno[i].Postavy[j].PostavaGID, GlobalniID.Prazdne) {
								let postava: ref<DataPostavy> = this.ZiskatDataPostav(ulozeno[i].Postavy[j]);
								if IsDefined(postava) {
									cena += postava.Cena;
									nazev += (j > 0 ? ", " : "") + postava.ZiskatNazevPostavy(ulozeno[i].Postavy[j].Vzhled);
								} else {
									validni = false;
								}
							}
							j += 1;
						}
					}

					cena += this.VybraneOpakovaniCena(GlobalniFunkce.ZiskatNastaveni(ulozeno[i].Nastaveni, this.factClipCount));

					if Equals(this.aktivniTypMenu, MenuUITyp.Pevecka) || Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
						cena = 0;
					}

					this.PridatMoznostInterni(MenuAkceTyp.__Ulozeno, [EnumInt(typUloziste), ulozeno[i].ID], nazev, druhyNazev, true, 0, false, false, 1, cena, NotEquals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv), 0, 0);
				} else {
					validni = false;
				}

				if !validni {
					this.lizziesBDsUloziste.SmazatID(typUloziste, ulozeno[i].ID);
				}
			}

			i += 1;
		}

		return pocet;
	}

	private final func SoukromePVPridat(lokace: GlobalniID, fakt: CName, faktPodminka: CName) -> Void {
		let faktPodm: Int32 = 1;
		if NotEquals(faktPodminka, n"") {
			faktPodm = this.questsSystem.GetFact(faktPodminka);
		}
		if faktPodm > 0 {
			let podm: Bool = this.questsSystem.GetFact(fakt) == 2;
			let lokaceData: ref<DataLokace> = this.ZiskatDataLokace(EnumInt(lokace));
			let druhyNazev: String = "";
			if podm { druhyNazev = GetLocalizedText("LocKey#15142272"); }
			this.PridatMoznostInterni(MenuAkceTyp.HlavniRecepceSoukromePV_Lokace, [EnumInt(lokaceData.GlobalniID)], lokaceData.NazevUplny, druhyNazev, true, 0, false, false, 1, podm ? 0 : 20000, false, 0, 0);
		}
	}

	private final func NastaveniEEX(nameVal: CName) -> Int32 {
		let eexOutfity: array<CName> = GlobalniFunkce.EquipmentExSeznamOutfitu(this.game);
		let i = 0;
		while i < ArraySize(eexOutfity) {
			if Equals(eexOutfity[i], nameVal) {
				return i;
			}
			i += 1;
		}

		return 0;
	}

	private final func VytvoritMenu(stranka: MenuStrankaTyp, opt vlastniID: Int32) -> Void {
		this.menuStrom.ZpracovatMenu(stranka, vlastniID);

		this.tlacitkaCtrl.RemoveAllChildren();
		this.tlacitkaTrvaleCtrl.RemoveAllChildren();
		ArrayClear(this.polePolozkyMenu);
		this.soucasnyIndexPolozky = 0;
		this.soucasnyIndexGenerovaniStranky = 0;
		this.maximalniPocetStranek = 0;
		this.pocetPolozekVKategorii = 0;
		this.posledniIndexMoznosti = 99;
		this.nastaveniBinarniZobrazeni = "";
		this.menuTrvale = 0;
		this.akceMenuZpet = MenuAkceTyp.Prazdne;
		if !this.menuStrom.Soucasne(MenuStrankaTyp.Menu_Hlavni) { this.menuTrvaleCtrl.SetVisible(false); }

		let nadpis: String = this.hlavniNadpisText;

		let maxTlacitek: Int32 = 18;
		if !this.zobrazitZakladniNavigaci { maxTlacitek = 20; }
		if this.mensiVerzeMenu {
			maxTlacitek = 10;
		}

		if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_Hlavni) {
			/*if this.zobrazitZakladniNavigaci { maxTlacitek = 15; }
			else { maxTlacitek = 16; }*/
			//maxTlacitek = 16;
			maxTlacitek = 14;

			let i = 0;
			while i < ArraySize(this.poleLokaciData) {
				let loc: ref<DataLokace> = this.ZiskatDataLokace(EnumInt(this.poleLokaciData[i].GlobalniID));
				if (Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) && loc.JeKoupena) || NotEquals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
					this.PridatMoznostInterni(MenuAkceTyp.Hlavni_Lokace, [EnumInt(loc.GlobalniID)], loc.Nazev, GetLocalizedText("LocKey#15144002"), loc.Fakt, 0, false, false, 1, 0, false, loc.ExtData, 0);
				}

				i += 1;
			}

			if /*this.zobrazitZakladniNavigaci &&*/ this.pocetPolozekVKategorii > maxTlacitek { //NotEquals(this.aktivniTypMenu, MenuUITyp.Pevecka) 
				this.PridatMoznost(MenuAkceTyp.Globalni_DalsiStranka, GetLocalizedText("LocKey#15144004"), "", true, 1, 0);
			}

			this.ZobrazitSpodniMenu(false);

			if NotEquals(this.aktivniTypMenu, MenuUITyp.Pevecka) && NotEquals(this.aktivniTypMenu, MenuUITyp.KoupeniPV) {
				this.PridatMoznost(MenuAkceTyp.Hlavni_Nastaveni, GetLocalizedText("LocKey#15142339"), "", true, 0, 0);
			}

			if NotEquals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) && !this.pozvaniDoBytuAktivni {
				this.PridatMoznost(MenuAkceTyp.Hlavni_Oblibene, GetLocalizedText("LocKey#15142116"), "", true, 4, 0);
			}

			this.PridatZnovuKoupit();
			this.PridatMoznost(MenuAkceTyp.Globalni_Zpet, Equals(this.aktivniTypMenu, MenuUITyp.Streamovani) ? GetLocalizedText("LocKey#15144021") : GetLocalizedText("LocKey#15144015"), "", true, 2, 0);

			this.akceMenuZpet = MenuAkceTyp.Globalni_Ukonceni;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_KatalogNastaveni) {
			this.poleNastaveniData = DataPoleNastaveniKatalog(this.nahotaJePovolena);

			let i = 0;
			while i < ArraySize(this.poleNastaveniData) {
				this.PridatMoznostNastaveni(this.poleNastaveniData[i].GlobalniID, i);
				i += 1;
			}

			/*if this.zobrazitZakladniNavigaci {
				this.PridatMoznost(MenuAkceTyp.Globalni_DalsiStranka, GetLocalizedText("LocKey#15144004"), "", true, 1, 0);
			}*/

			this.PridatZakladniNavigaci(true, true);

			this.akceMenuZpet = MenuAkceTyp.Globalni_ZpetDoMenu;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_LokaceKontejner) {
			let i = 0;
			while i < ArraySize(this.menuVybranaLokace.Kontejner) {
				let loc: ref<DataLokace> = this.ZiskatDataLokace(EnumInt(this.menuVybranaLokace.Kontejner[i].GlobalniID));
				let pridat: Bool = true;

				if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) && !loc.JeKoupena {
					pridat = false;
				}

				if loc.VolnePV && NotEquals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
					pridat = false;
				}

				if pridat {
					let druhyNazev: String = ""; //this.menuVybranaLokace.Kontejner[i].BezPostavy ? GetLocalizedText("LocKey#15144001") : GetLocalizedText("LocKey#15144002");

					let oblibene: Bool = false;
					let koupeno: Bool = false;

					if loc.BezPostavy {
						let a: ref<VybranaPostava> = new VybranaPostava();
						a.PostavaGID = GlobalniID.Postava_LokaceBezPostavy;

						if NotEquals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
							oblibene = this.lizziesBDsUloziste.JeVUlozisti(UlozisteTyp.Oblibene, EnumInt(loc.GlobalniID), [], [a]) != -1;
						}

						if Equals(this.aktivniTypMenu, MenuUITyp.KoupeniPV) {
							let jeKoupeno: Bool = this.lizziesBDsUloziste.JeVUlozisti(UlozisteTyp.Koupeno, EnumInt(loc.GlobalniID), [], [a]) != -1;
							if jeKoupeno {
								druhyNazev = GetLocalizedText("LocKey#15142272");
							}
						}
						else if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) && loc.VolnePV {
							druhyNazev = GetLocalizedText("LocKey#15144002");
						}
						else if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
							druhyNazev = GetLocalizedText("LocKey#15144001");
						}
					}
					else if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
						druhyNazev = GetLocalizedText("LocKey#15144002");
					}

					this.PridatMoznostInterni(MenuAkceTyp.LokaceKontejner_Lokace, [EnumInt(loc.GlobalniID)], loc.Nazev, druhyNazev, loc.Fakt, 0, false, false, 1, koupeno || Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) ? 0 : this.menuVybranaLokace.Kontejner[i].Cena, oblibene, loc.ExtData, 0);
				}
				
				i += 1;
			}

			this.PridatZakladniNavigaci(this.pocetPolozekVKategorii < maxTlacitek, !this.menuLokaceAktivni);

			this.akceMenuZpet = this.menuLokaceAktivni ? MenuAkceTyp.Globalni_KategorieNahoru : MenuAkceTyp.Globalni_ZpetDoMenu;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_Pohlavi) {
			this.PridatMoznost(MenuAkceTyp.Pohlavi_Zeny, GetLocalizedText("LocKey#15144005"), GetLocalizedText("LocKey#15144002"), NotEquals(this.menuVybranaLokace.PouzeProPohlavi, GenderType.Male), 0, 1);
			this.PridatMoznost(MenuAkceTyp.Pohlavi_Muzi, GetLocalizedText("LocKey#15144006"), GetLocalizedText("LocKey#15144002"), NotEquals(this.menuVybranaLokace.PouzeProPohlavi, GenderType.Female), 0, 1);
			this.PridatZakladniNavigaci(true, false);

			if Equals(this.aktivniTypMenu, MenuUITyp.GFH) {
				this.akceMenuZpet = MenuAkceTyp.Globalni_MenuGFH;
			} else {
				this.akceMenuZpet = MenuAkceTyp.Globalni_MenuLokace;
			}
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_MenuLokace) {
			this.menuLokaceAktivni = true;

			let podminkaProSpusteni: Bool = true;
			let cenaKoupit: Int32 = 0;
			let PVKdekoliv: Bool = Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv);
			let tmpLokace: ref<DataLokace> = this.ZiskatVybranouLokaci();

			if ArraySize(this.menuVybranaLokace.Kontejner) > 0 {
				this.PridatMalyNadpis(GetLocalizedText("LocKey#15142278") + ":");

				let epizodaVybrana: Bool = IsDefined(this.menuVybranaLokaceEpizoda);
				podminkaProSpusteni = podminkaProSpusteni && epizodaVybrana;

				this.PridatMoznostInterni(MenuAkceTyp.MenuLokace_VybratEpizodu, [], (epizodaVybrana ? this.menuVybranaLokaceEpizoda.Nazev : "-"), "", true, PVKdekoliv ? 3 : 0, false, false, 0, 0, false, 0, 0);
			
				if IsDefined(tmpLokace) {
					this.PridatMezeru();
				}
			}

			if IsDefined(tmpLokace) && !tmpLokace.VolnePV {
				this.PridatMalyNadpis(GetLocalizedText("LocKey#15142279") + ":");

				if !tmpLokace.PohlaviSpolecne && !this.pozvaniDoBytuAktivni {
					let zobrazitPohlavi: Int32 = this.questsSystem.GetFact(Konstanty.FaktZobrazitPohlavi());
					if zobrazitPohlavi == 0 {
						let pohlaviText: String = "";
						if Equals(this.vybranePohlavi, GenderType.Female) { pohlaviText = GetLocalizedText("LocKey#15144005"); }
						if Equals(this.vybranePohlavi, GenderType.Male) { pohlaviText = GetLocalizedText("LocKey#15144006"); }
						this.PridatMoznostInterni(MenuAkceTyp.MenuLokace_Pohlavi, [], GetLocalizedText("LocKey#15142280") + ": " + pohlaviText, "", true, NotEquals(tmpLokace.PouzeProPohlavi, GenderType.None) || PVKdekoliv ? 3 : 0, false, false, 0, 0, false, 0, 0);
					}
				}

				let i = 0;
				while i < tmpLokace.PocetPostav {
					let text: String = "";
					if i == 0 { text = GetLocalizedText("LocKey#15142126"); }
					if i == 1 { text = GetLocalizedText("LocKey#15142127"); }
					if i == 2 { text = GetLocalizedText("LocKey#15142132"); }
					if i == 3 { text = GetLocalizedText("LocKey#15142244"); }
					if i == 4 { text = GetLocalizedText("LocKey#15142255"); }
					if i == 5 { text = GetLocalizedText("LocKey#15142257"); }

					let zakazano: Int32 = 0;
					if (PVKdekoliv && ArraySize(this.menuVybranaPostavaPole[i].DataPostavy.Vzhledy) == 1) /*|| (this.pozvaniDoBytuAktivni && i == 0)*/ {
						zakazano = 3;
					}
					if this.pozvaniDoBytuAktivni {
						let partner: GlobalniID = this.PozvaniDoBytuAktivniPostava();
						if Equals(this.menuVybranaPostavaPole[i].DataPostavy.GlobalniID, partner) {
							zakazano = 3;
						}
					}

					this.PridatMoznostInterni(MenuAkceTyp.MenuLokace_VybratPostavu, [i], text + ": " + this.menuVybranaPostavaPole[i].Nazev, "", true, zakazano, false, false, 0, this.menuVybranaPostavaPole[i].DataPostavy.Cena, false, 0, this.menuVybranaPostavaPole[i].DataPostavy.MaSlevu);

					if
						i == 0 ||
						(
							NotEquals(tmpLokace.GlobalniID, GlobalniID.Lokace_Poledance_Triple) &&
							NotEquals(tmpLokace.GlobalniID, GlobalniID.Lokace_Beach)
						)
					{
						podminkaProSpusteni = podminkaProSpusteni && this.menuVybranaPostavaPole[i].PostavaVybrana;
					}

					cenaKoupit += this.menuVybranaPostavaPole[i].DataPostavy.Cena;

					i += 1;
				}
			}

			//this.Dialog(1, 300, GetLocalizedText("LocKey#000"), GetLocalizedText("LocKey#000"));

			if IsDefined(tmpLokace) {
				let podporujeOpakovani: Bool = tmpLokace.PodporujeOpakovani && NotEquals(this.aktivniTypMenu, MenuUITyp.Pevecka);
				let podporujeHudbu: Bool = tmpLokace.VychoziHudba != -1 && tmpLokace.VychoziHudba != 1;

				if !tmpLokace.VolnePV {
					this.PridatMezeru();
				}

				if podporujeOpakovani || podporujeHudbu || tmpLokace.PocetPostav > 0 {
					this.PridatMalyNadpis(GetLocalizedText("LocKey#15142281") + ":");
				}

				if !tmpLokace.VolnePV {
					this.PridatMoznostInterni(MenuAkceTyp.MenuLokace_NastaveniPostav, [], GetLocalizedText("LocKey#15142336"), "", true, 0, false, false, 0, 0, false, 0, 0);
				}

				if podporujeOpakovani {
					let opakovani: String = this.VybraneOpakovaniText(GlobalniFunkce.ZiskatNastaveni(this.menuVybraneNastaveni, this.factClipCount), false);
					let cena: Int32 = this.VybraneOpakovaniCena(GlobalniFunkce.ZiskatNastaveni(this.menuVybraneNastaveni, this.factClipCount));
					cenaKoupit += cena;

					this.PridatMoznostInterni(MenuAkceTyp.MenuLokace_OpakovaniSceny, [], opakovani, "", true, 0, false, false, 0, cena, false, 0, 0);
				}
				if podporujeHudbu {
					let hudba: ref<DataHudby> = this.ZiskatDataHudby(GlobalniFunkce.ZiskatNastaveni(this.menuVybraneNastaveni, Konstanty.FaktVybratHudbu()));
					if IsDefined(hudba) {
						this.PridatMoznostInterni(MenuAkceTyp.MenuLokace_VybratHudbu, [], GetLocalizedText("LocKey#15142282") + ": " + hudba.Nazev, "", true, 0, false, false, 0, 0, false, 0, 0);
					}
				}
				
				if !tmpLokace.VolnePV {
					this.PridatMoznostInterni(MenuAkceTyp.MenuLokace_Nastaveni, [], GetLocalizedText("LocKey#15142347"), "", true, 0, false, false, 0, 0, false, 0, 0);
				}

				this.ZobrazitSpodniMenu(false);

				if podminkaProSpusteni {
					if NotEquals(this.aktivniTypMenu, MenuUITyp.KoupeniPV) {
						this.PridatMoznostInterni(MenuAkceTyp.MenuLokace_Spustit, [], GetLocalizedText("LocKey#15142167"), "", true, 1, false, false, 0, cenaKoupit, false, 0, 0);
					} else {
						let jeKoupeno: Bool = this.lizziesBDsUloziste.JeVUlozisti(UlozisteTyp.Koupeno, EnumInt(tmpLokace.GlobalniID), this.menuVybraneNastaveni, this.menuVybranaPostavaPole) != -1;
						this.PridatMoznostInterni(MenuAkceTyp.MenuLokace_Koupit, [], GetLocalizedText("LocKey#15142168"), jeKoupeno ? GetLocalizedText("LocKey#15142272") : "", true, 1, false, false, jeKoupeno ? 1 : 0, jeKoupeno ? 0 : cenaKoupit, false, 0, 0);
					}

					if !PVKdekoliv && !this.pozvaniDoBytuAktivni {
						this.oblibeneVybraneID = this.lizziesBDsUloziste.JeVUlozisti(UlozisteTyp.Oblibene, EnumInt(tmpLokace.GlobalniID), this.menuVybraneNastaveni, this.menuVybranaPostavaPole);

						if this.oblibeneVybraneID != -1 {
							this.PridatMoznost(MenuAkceTyp.MenuLokace_OblibeneOd, GetLocalizedText("LocKey#15144073"), "", true, 4, 1);
						} else {
							this.PridatMoznost(MenuAkceTyp.MenuLokace_Oblibene, GetLocalizedText("LocKey#15144072"), "", true, 4, 1);
						}
					} else {
						this.oblibeneVybraneID = this.lizziesBDsUloziste.JeVUlozisti(UlozisteTyp.Koupeno, EnumInt(tmpLokace.GlobalniID), this.menuVybraneNastaveni, this.menuVybranaPostavaPole);

						if this.oblibeneVybraneID != -1 {
							this.PridatMoznostInterni(MenuAkceTyp.MenuLokace_ZahoditPV, [], GetLocalizedText("LocKey#15142166"), "", true, 2, false, false, 0, 0, false, 0, 0);
						}
					}
				}
			} else {
				this.ZobrazitSpodniMenu(false);
			}

			this.PridatZakladniNavigaci(true, true);

			this.akceMenuZpet = MenuAkceTyp.Globalni_ZpetDoMenu;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_KoupenePVSeznam) {
			let lokace: ref<DataLokace> = this.ZiskatVybranouLokaci();
			let pocet: Int32 = this.VytvoritMenuPolozekZUloziste(UlozisteTyp.Koupeno, EnumInt(lokace.GlobalniID), false);
			this.PridatZakladniNavigaci(pocet < maxTlacitek, true);
			this.akceMenuZpet = MenuAkceTyp.Globalni_ZpetDoMenu;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_VybratHudbu) {
			let i = 0;
			while i < ArraySize(this.poleHudbyData) {
				if ((Equals(this.aktivniTypMenu, MenuUITyp.VyberHudby) && this.poleHudbyData[i].PouzeHangout) || !this.poleHudbyData[i].PouzeHangout) && this.poleHudbyData[i].ID != -1 {
					this.PridatMoznostInterni(MenuAkceTyp.VybratHudbu_Vybrat, [this.poleHudbyData[i].ID], this.poleHudbyData[i].Nazev, "", true, 0, false, false, 0, 0, false, 0, 0);
				}
				i += 1;
			}

			this.PridatZakladniNavigaci(this.pocetPolozekVKategorii < maxTlacitek, false);

			this.akceMenuZpet = Equals(this.aktivniTypMenu, MenuUITyp.VyberHudby) ? MenuAkceTyp.Globalni_Ukonceni : MenuAkceTyp.Globalni_KategorieNahoru;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_MenuLokace_NastaveniPostav) {
			let i = 0;
			while i < ArraySize(this.menuVybranaPostavaPole) {
				if this.menuVybranaPostavaPole[i].PostavaVybrana {
					this.PridatMoznostInterni(MenuAkceTyp.MenuLokace_NastaveniPostav_Postava, [i], this.menuVybranaPostavaPole[i].Nazev, "", true, 0, false, false, 1, 0, false, 0, 0);
				}
				i += 1;
			}

			this.PridatZakladniNavigaci(this.pocetPolozekVKategorii < maxTlacitek, false);

			this.akceMenuZpet = MenuAkceTyp.Globalni_KategorieNahoru;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_MenuLokace_NastaveniPostav_Postava) || this.menuStrom.Soucasne(MenuStrankaTyp.Menu_GFH_NastaveniPostavy) {
			let postava: ref<DataPostavy> = this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].DataPostavy;
			let jeHrac: Bool = Equals(postava.GlobalniID, GlobalniID.Postava_Female_V) || Equals(postava.GlobalniID, GlobalniID.Postava_Male_V);
			
			this.poleNastaveniData = DataPoleNastaveniPostavy(jeHrac, this.nahotaJePovolena, this.lizziesBDsResources.bodInstalovan, Equals(postava.Pohlavi, GenderType.Female));

			let i = 0;
			while i < ArraySize(this.poleNastaveniData) {
				this.PridatMoznostNastaveni(this.poleNastaveniData[i].GlobalniID, i);
				i += 1;
			}

			this.PridatZakladniNavigaci(this.pocetPolozekVKategorii < maxTlacitek, false);

			this.akceMenuZpet = MenuAkceTyp.Globalni_KategorieNahoru;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_MenuLokace_Nastaveni) {
			let plrZena: Bool = this.questsSystem.GetFact(this.factPlayerGender) == 2;

			let eexOutfity: array<CName> = GlobalniFunkce.EquipmentExSeznamOutfitu(this.game);
			let eexOutfityStr: array<String> = [];
			for outf in eexOutfity {
				ArrayPush(eexOutfityStr, NameToString(outf));
			}

			let eexVyb: Bool = GlobalniFunkce.ZiskatNastaveni(this.menuVybraneNastaveni, Konstanty.FaktObleceniPlr()) == 3;

			this.poleNastaveniData = DataPoleNastaveniLokace(this.nahotaJePovolena, plrZena, eexVyb, eexOutfityStr, Equals(this.aktivniTypMenu, MenuUITyp.GFH) ? false : this.menuVybranaLokaceEpizoda.PodporujeReplacer);

			let i = 0;
			while i < ArraySize(this.poleNastaveniData) {
				this.PridatMoznostNastaveni(this.poleNastaveniData[i].GlobalniID, i);
				i += 1;
			}

			this.PridatZakladniNavigaci(this.pocetPolozekVKategorii < maxTlacitek, false);

			this.akceMenuZpet = MenuAkceTyp.Globalni_KategorieNahoru;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_HlavniRecepce) {
			this.PridatMoznost(MenuAkceTyp.Globalni_Zpet, GetLocalizedText("LocKey#15144019"), "", true, 2, 0);
			this.PridatMezeru();

			let streamovaniKoupeno: Int32 = this.questsSystem.GetFact(this.factStreaming);
			this.PridatMoznost(MenuAkceTyp.HlavniRecepce_Sluzba, GetLocalizedText("LocKey#15142043"), this.TextPovolenoZakazano(streamovaniKoupeno == 1), this.questsSystem.GetFact(this.factStreamingMsg) == 1, 0, streamovaniKoupeno == 1 ? 1 : 2);
			
			let erKoupeno: Int32 = this.questsSystem.GetFact(this.factER);
			if erKoupeno == 0 {
				this.PridatMoznostInterni(MenuAkceTyp.HlavniRecepce_ER, [], GetLocalizedText("LocKey#15142351"), "", true, 0, false, false, 1, 5000, false, 0, 0);
			}
			
			if this.questsSystem.GetFact(this.factViews) >= 5 {
				let soukromePVBezi: Bool = this.questsSystem.GetFact(Konstanty.FaktSoukromePV()) == 1;
				this.PridatMoznostInterni(MenuAkceTyp.HlavniRecepce_SoukromePV, [], GetLocalizedText("LocKey#15142294"), soukromePVBezi ? GetLocalizedText("LocKey#15142296") : GetLocalizedText("LocKey#15144002"), true, 0, false, false, soukromePVBezi ? 2 : 1, 0, false, 0, 0);
			}

			this.PridatMezeru();
			this.PridatMoznost(MenuAkceTyp.HlavniRecepce_OnlineStat, GetLocalizedText("LocKey#15142124"), "", true, 0, 0);
			
			this.akceMenuZpet = MenuAkceTyp.Globalni_Ukonceni;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_HlavniRecepceSoukromePV) {
			this.SoukromePVPridat(GlobalniID.Lokace_Hangout_Priv_Megabuilding, Konstanty.FaktSoukromePVMegabuilding(), n"");
			this.SoukromePVPridat(GlobalniID.Lokace_Hangout_Priv_Downtown, Konstanty.FaktSoukromePVDowntown(), n"dlc6_apart_cct_dtn_purchased");
			this.SoukromePVPridat(GlobalniID.Lokace_Hangout_Priv_Heywood, Konstanty.FaktSoukromePVHeywood(), n"dlc6_apart_hey_gle_purchased");
			this.SoukromePVPridat(GlobalniID.Lokace_Hangout_Priv_Japantown, Konstanty.FaktSoukromePVJapantown(), n"dlc6_apart_wbr_jpn_purchased");
			this.SoukromePVPridat(GlobalniID.Lokace_Hangout_Priv_Northside, Konstanty.FaktSoukromePVNorthside(), n"dlc6_apart_wat_nid_purchased");
			this.SoukromePVPridat(GlobalniID.Lokace_Hangout_Priv_EdenPlaza, Konstanty.FaktSoukromePVEdenPlaza(), n"ch_penthouse");
			this.SoukromePVPridat(GlobalniID.Lokace_Hangout_Priv_SantoSerenity, Konstanty.FaktSoukromePVSantoSerenity(), n"ModernCozyHouse");

			this.PridatZakladniNavigaci(true, false);

			this.akceMenuZpet = MenuAkceTyp.Globalni_KategorieNahoru;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_NastaveniPostavy) {
			this.PridatMoznost(MenuAkceTyp.NastaveniPostavy_Zeny, GetLocalizedText("LocKey#15144005"), GetLocalizedText("LocKey#15144002"), true, 0, 1);
			this.PridatMoznost(MenuAkceTyp.NastaveniPostavy_Muzi, GetLocalizedText("LocKey#15144006"), GetLocalizedText("LocKey#15144002"), true, 0, 1);
			this.PridatMoznost(MenuAkceTyp.Globalni_Zpet, GetLocalizedText("LocKey#15144019"), "", true, 2, 0);
			
			this.akceMenuZpet = MenuAkceTyp.Globalni_Ukonceni;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_NastaveniRuzne) {
			//maxTlacitek = 19;
			let i = 0;
			while i < ArraySize(this.poleNastaveniData) {
				this.PridatMoznostNastaveni(this.poleNastaveniData[i].GlobalniID, i);
				i += 1;
			}

			if this.zobrazitZakladniNavigaci {
				this.PridatMoznost(MenuAkceTyp.Globalni_DalsiStranka, GetLocalizedText("LocKey#15144004"), "", true, 1, 0);
			}
			this.PridatMoznost(MenuAkceTyp.Globalni_Zpet, GetLocalizedText("LocKey#15144019"), "", true, 2, 0);

			this.akceMenuZpet = MenuAkceTyp.Globalni_Ukonceni;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_BarLokace) {
			let i = 0;
			while i < ArraySize(this.poleLokaciData) {
				let barSoucasnaLokace: Int32 = this.questsSystem.GetFact(this.factBarLoc);
				let barLokace: Int32 = EnumInt(this.poleLokaciData[i].GlobalniID);

				let loc: ref<DataLokace> = this.ZiskatDataLokace(barLokace);
				this.PridatMoznostInterni(MenuAkceTyp.BarLokace_Lokace, [i], loc.Nazev, "", barSoucasnaLokace != barLokace && loc.Fakt, 0, false, false, 1, 0, false, 0, 0);

				i += 1;
			}
			this.PridatMoznost(MenuAkceTyp.Globalni_Zpet, GetLocalizedText("LocKey#15144020"), "", true, 2, 0);

			this.akceMenuZpet = MenuAkceTyp.Globalni_Ukonceni;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_Debug) {
			this.PridatMoznost(MenuAkceTyp.Debug_Debug, "DEBUG", "", true, 0, 0);
			this.akceMenuZpet = MenuAkceTyp.Globalni_Ukonceni;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_Oblibene) {
			let pocet: Int32 = this.VytvoritMenuPolozekZUloziste(UlozisteTyp.Oblibene, -1, true);
			this.PridatZakladniNavigaci(pocet < maxTlacitek, true);
			nadpis = GetLocalizedText("LocKey#15142116");
			this.akceMenuZpet = MenuAkceTyp.Globalni_ZpetDoMenu;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_PostavaMoznosti) {
			let i = 0;
			while i < ArraySize(this.menuVybranaPostavaPole) {
				if this.menuVybranaPostavaPole[i].PostavaVybrana {
					this.PridatMoznostInterni(MenuAkceTyp.PostavaMoznosti_Postava, [i], this.menuVybranaPostavaPole[i].Nazev, "", true, 0, false, false, 1, 0, false, 0, 0);
				}
				i += 1;
			}

			this.PridatMoznostInterni(
				MenuAkceTyp.PostavaMoznosti_Zkop,
				[],
				GetLocalizedText("LocKey#15142262"),
				this.TextPovolenoZakazano(this.postavaMoznostiOblicejZkop),
				true,
				0,
				!this.postavaMoznostiOblicejZkop,
				false,
				!this.postavaMoznostiOblicejZkop ? 2 : 1,
				0,
				false,
				0,
				0
			);

			this.PridatMoznost(MenuAkceTyp.Globalni_Zpet, GetLocalizedText("LocKey#15144020"), "", true, 2, 0);

			this.akceMenuZpet = MenuAkceTyp.Globalni_Ukonceni;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_PostavaMoznostiPostava) {
			let oblicejKlid: Int32 = this.questsSystem.GetFact(StringToName(Konstanty.FaktVybranyOblicejKlid() + ToString(this.lokaceVyberPostavVybP)));
			let oblicejPoza: Int32 = this.questsSystem.GetFact(StringToName(Konstanty.FaktVybranyOblicejPoza() + ToString(this.lokaceVyberPostavVybP)));

			this.PridatMoznost(MenuAkceTyp.PostavaMoznostiPostava_Vzhled, GetLocalizedText("LocKey#15142261"), GetLocalizedText("LocKey#15144002"), true, 0, 1);
			this.PridatMoznost(MenuAkceTyp.PostavaMoznostiPostava_Oblicej_Klid, GetLocalizedText("LocKey#15142128") + ": " + this.poleOblicejuData.KlidNazev[oblicejKlid], GetLocalizedText("LocKey#15144002"), true, 0, 1);
			this.PridatMoznost(MenuAkceTyp.PostavaMoznostiPostava_Oblicej_Poza, GetLocalizedText("LocKey#15142131") + ": " + this.poleOblicejuData.PozaNazev[oblicejPoza], GetLocalizedText("LocKey#15144002"), true, 0, 1);

			this.poleNastaveniData = DataPoleNastaveniOblicej();
			
			let i = 0;
			while i < ArraySize(this.poleNastaveniData) {
				this.PridatMoznostNastaveni(this.poleNastaveniData[i].GlobalniID, i);
				i += 1;
			}

			this.PridatZakladniNavigaci(true, false);

			this.akceMenuZpet = MenuAkceTyp.Globalni_KategorieNahoru;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_PostavaMoznostiPostavaOblicejKlid) {
			let i = 0;
			while i < ArraySize(this.poleOblicejuData.KlidNazev) {
				this.PridatMoznostInterni(MenuAkceTyp.PostavaMoznostiPostavaOblicejKlid_Klid, [i], this.poleOblicejuData.KlidNazev[i], "", true, 0, false, false, 0, 0, false, 0, 0);

				i += 1;
			}

			this.PridatZakladniNavigaci(false, false);

			this.akceMenuZpet = MenuAkceTyp.Globalni_KategorieNahoru;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_PostavaMoznostiPostavaOblicejPoza) {
			let i = 0;
			while i < ArraySize(this.poleOblicejuData.PozaNazev) {
				this.PridatMoznostInterni(MenuAkceTyp.PostavaMoznostiPostavaOblicejPoza_Poza, [i], this.poleOblicejuData.PozaNazev[i], "", true, 0, false, false, 0, 0, false, 0, 0);

				i += 1;
			}

			this.PridatZakladniNavigaci(false, false);

			this.akceMenuZpet = MenuAkceTyp.Globalni_KategorieNahoru;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_PostavaVzhledy) {
			let postava: ref<DataPostavy> = this.ZiskatDataPostav(this.menuVybranaPostavaDocasna);
			let cena: Int32 = 0;
			let sleva: Int32 = 0;

			if NotEquals(this.aktivniTypMenu, MenuUITyp.Pevecka) && NotEquals(this.aktivniTypMenu, MenuUITyp.PostavaMoznosti) && NotEquals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
				cena = postava.Cena;
				sleva = postava.MaSlevu;
			}

			this.menuVybranaPostavaDocasna.Vzhled = 0;
			//let oblibene: Bool = this.OblibeneOp(3);
			this.PridatMoznostInterni(MenuAkceTyp.PostavaVzhledy_Vzhled, [0], GetLocalizedText("LocKey#15144074"), "", true, 0, false, false, 0, cena, false, 0, sleva);

			let poleVzhledy: array<ref<DataVzhled>> = postava.Vzhledy;
			let pocet: Int32 = ArraySize(poleVzhledy);

			let i = 1;
			while i < pocet {
				this.menuVybranaPostavaDocasna.Vzhled = i;
				//oblibene = this.OblibeneOp(3);
				this.PridatMoznostInterni(MenuAkceTyp.PostavaVzhledy_Vzhled, [i], poleVzhledy[i].ZiskatNazev(), "", true, 0, false, false, 0, cena, false, 0, sleva);
				i += 1;
			}

			nadpis = postava.ZiskatNazevPostavy(0);
			this.PridatZakladniNavigaci(pocet < maxTlacitek, false);
			this.akceMenuZpet = MenuAkceTyp.Globalni_KategorieNahoru;
		} else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_GFH) {
			this.PridatMalyNadpis(GetLocalizedText("LocKey#15142279") + ":");
			this.PridatMoznostInterni(MenuAkceTyp.MenuGFH_VybratPostavu, [0], this.menuVybranaPostavaPole[0].Nazev, "", true, 0, false, false, 0, this.menuVybranaPostavaPole[0].DataPostavy.Cena, false, 0, this.menuVybranaPostavaPole[0].DataPostavy.MaSlevu);
			
			this.PridatMalyNadpis(GetLocalizedText("LocKey#15142336") + ":");
			if this.menuVybranaPostavaPole[0].PostavaVybrana {
				this.PridatMoznostInterni(MenuAkceTyp.MenuGFH_NastaveniPostavy, [0], this.menuVybranaPostavaPole[0].Nazev, "", true, 0, false, false, 1, 0, false, 0, 0);
			}

			this.PridatMezeru();

			this.PridatMalyNadpis(GetLocalizedText("LocKey#15142336") + ":");
			this.PridatMoznostInterni(MenuAkceTyp.MenuLokace_Nastaveni, [], GetLocalizedText("LocKey#15142347"), "", true, 0, false, false, 0, 0, false, 0, 0);

			this.ZobrazitSpodniMenu(false);

			if this.menuVybranaPostavaPole[0].PostavaVybrana {
				this.PridatMoznostInterni(MenuAkceTyp.MenuGFH_Spustit, [], GetLocalizedText("LocKey#15142350"), "", true, 1, false, false, 0, 0, false, 0, 0);
			}

			this.PridatZakladniNavigaci(true, false);
			this.akceMenuZpet = MenuAkceTyp.Globalni_Ukonceni;
		} else {
			let i = 0;
			while i < ArraySize(this.polePostavData) {
				let p: ref<DataPostavy> = this.polePostavData[i];

				let j = 0;
				while j < ArraySize(p.VlozitDoMenu) {
					let vlastniCateg: Int32 = ArraySize(p.VlozitDoMenuVlastni);

					if vlastniCateg > 0 {
						if Equals(this.menuStrom.SoucasnaStranka().Stranka, MenuStrankaTyp.Kateg_Vlastni) && this.menuStrom.SoucasnaStranka().VlastniID > 0 && p.CustomID > 0 && Equals(p.Pohlavi, this.vybranePohlavi) {
							let k = 0;
							while k < vlastniCateg {
								if this.menuStrom.Soucasne(p.VlozitDoMenu[j], p.VlozitDoMenuVlastni[k]) {
									this.PridatMoznostPostava(p);
								}
								k += 1;
							}
						}
					} else {
						if this.menuStrom.Soucasne(p.VlozitDoMenu[j]) && (Equals(p.Pohlavi, this.vybranePohlavi) || Equals(p.Pohlavi, GenderType.Robot)) {
							this.PridatMoznostPostava(p);
						}
						else if this.menuStrom.Soucasne(p.VlozitDoMenu[j]) && p.JeKateg {
							if !(Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) && p.CustomID > 0) {
								this.PridatMoznostPostava(p);
							}
						}
					}

					j += 1;
				}
				i += 1;
			}

			if
				this.menuStrom.Soucasne(MenuStrankaTyp.Menu_Zeny) ||
				this.menuStrom.Soucasne(MenuStrankaTyp.Menu_Muzi) ||
				this.menuStrom.Soucasne(MenuStrankaTyp.Menu_ZenyPouzeMox) ||
				this.menuStrom.Soucasne(MenuStrankaTyp.Menu_MuziPouzeMox)
			{
				this.PridatZakladniNavigaci(this.pocetPolozekVKategorii < maxTlacitek, false);
				
				if Equals(this.aktivniTypMenu, MenuUITyp.GFH) {
					this.akceMenuZpet = MenuAkceTyp.Globalni_MenuGFH;
				} else if Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) {
					this.akceMenuZpet = MenuAkceTyp.Globalni_KategorieNahoru;
				} else {
					this.akceMenuZpet = MenuAkceTyp.Globalni_MenuLokace;
				}
			} else {
				this.PridatZakladniNavigaci(this.pocetPolozekVKategorii < maxTlacitek, false);
				this.akceMenuZpet = MenuAkceTyp.Globalni_KategorieNahoru;
			}
		}

		this.maximalniPocetStranek = CeilF(Cast<Float>(this.pocetPolozekVKategorii) / Cast<Float>(maxTlacitek));

		let citacStranekCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/page_counter") as inkText;
		citacStranekCtrl.SetText(this.maximalniPocetStranek == 1 ? "" : GetLocalizedText("LocKey#15144022") + " " + (this.menuStrom.StrankovaniOp(0) + 1) + "/" + this.maximalniPocetStranek);

		if this.maximalniPocetStranek == 1 {
			if this.ovladaniStranky {
				this.PlayLibraryAnimation(n"hide_pages_tooltip");
				this.ovladaniStranky = false;
			}
		} else {
			if !this.ovladaniStranky {
				this.PlayLibraryAnimation(n"show_pages_tooltip");
				this.ovladaniStranky = true;
			}
		}

		if Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) || Equals(this.aktivniTypMenu, MenuUITyp.NastaveniRuzne) {
			this.ZobrazitNastaveniBinarniData();
		}

		let hlavniNadpisCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/buttons_header") as inkText;
		hlavniNadpisCtrl.SetText(nadpis);
	}

	private final func PridatZakladniNavigaci(pouzeZpet: Bool, textZpetHlavniMenu: Bool) -> Void {
		if !this.zobrazitZakladniNavigaci { return; }

		if !pouzeZpet {
			this.PridatMoznost(MenuAkceTyp.Globalni_DalsiStranka, GetLocalizedText("LocKey#15144004"), "", true, 1, 0);
		}
		this.PridatMoznost(MenuAkceTyp.Globalni_Zpet, textZpetHlavniMenu ? GetLocalizedText("LocKey#15144003") : GetLocalizedText("LocKey#15144020"), "", true, 2, 0);
	}

	private final func JeVMenu(akce: MenuAkceTyp, opt data: array<Int32>, opt nastavit: Bool) -> Bool {
		let i = 0;
		while i < ArraySize(this.polePolozkyMenu) {
			if
				Equals(this.polePolozkyMenu[i].Akce, akce) &&
				this.polePolozkyMenu[i].Hodnota == this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Ziskat)
			{
				if ArraySize(data) > 0 {
					let j = 0;
					while j < ArraySize(data) {
						if this.polePolozkyMenu[i].Data[j] != data[j] {
							return false;
						}
						j += 1;
					}
				}

				if !nastavit {
					this.menuAkceTyp = akce;
				}
				return true;
			}
			i += 1;
		}
		return false;
	}

	private final func JeVMenuZiskatData() -> array<Int32> {
		let i = 0;
		while i < ArraySize(this.polePolozkyMenu) {
			if
				Equals(this.polePolozkyMenu[i].Akce, this.menuAkceTyp) &&
				this.polePolozkyMenu[i].Hodnota == this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Ziskat)
			{
				return this.polePolozkyMenu[i].Data;
			}
			i += 1;
		}
		return [];
	}

	private final func PolozkaZakazana() -> Bool {
		let i = 0;
		while i < ArraySize(this.polePolozkyMenu) {
			if
				Equals(this.polePolozkyMenu[i].Akce, this.menuAkceTyp) &&
				this.polePolozkyMenu[i].Hodnota == this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Ziskat)
			{
				return this.polePolozkyMenu[i].Zakazano;
			}
			i += 1;
		}
		return false;
	}

	protected final func ZvyraznitPolozkuMenu() -> Void {
		this.ZvyraznitMoznost();

		this.NastavitMensiVerzi(2);
		this.OblibeneOp(0);
		this.NastavitViditelnostPodleNazvu("location", false);
		this.NastavitViditelnostPodleNazvu("character", false);
		this.NastavitViditelnostPodleNazvu("text", false);
		this.NastavitViditelnostPodleNazvu("oblibene", false);
		this.NastavitViditelnostPodleNazvu("character_custom", false);
		let textNastaven: Bool = false;
		this.menuAkceTyp = MenuAkceTyp.Prazdne;
		this.menuAkceData = EnumInt(GlobalniID.Prazdne);
		this.specialniTlacitkoAkce = SpecTlacAkce.ZadnaAkce;
		
		this.menuVybranaPostavaDocasna.Vzhled = 0;

		if this.nahledHudbyAktivni {
			this.questsSystem.SetFact(this.factMusicToggle, 42);
			this.nahledHudbyAktivni = false;
							
			this.audioSystem.GlobalParameter(n"mix_MUTE_sfx_vo", 0.0);
		}

		if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_Hlavni) {
			if this.JeVMenu(MenuAkceTyp.Hlavni_Lokace) {
				let polozkaData: array<Int32> = this.JeVMenuZiskatData();
				let dataLokace: ref<DataLokace> = this.ZiskatDataLokace(polozkaData[0]);
				textNastaven = this.ZobrazitDataLokace(dataLokace);
			}
			else if this.JeVMenu(MenuAkceTyp.Hlavni_Nastaveni) { this.NastavitDataTextu(GetLocalizedText("LocKey#15142339"), GetLocalizedText("LocKey#15142340")); textNastaven = true; }
			else if this.JeVMenu(MenuAkceTyp.Hlavni_Oblibene) { this.NastavitDataTextu(GetLocalizedText("LocKey#15142116"), GetLocalizedText("LocKey#15142117")); textNastaven = true; }
		}
		else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_LokaceKontejner) {
			if this.JeVMenu(MenuAkceTyp.LokaceKontejner_Lokace) {
				let polozkaData: array<Int32> = this.JeVMenuZiskatData();
				let dataLokace: ref<DataLokace> = this.ZiskatDataLokace(polozkaData[0]);
				textNastaven = this.ZobrazitDataLokace(dataLokace);
			}
		}
		else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_Pohlavi) {
			if this.JeVMenu(MenuAkceTyp.Pohlavi_Zeny) { }
			else if this.JeVMenu(MenuAkceTyp.Pohlavi_Muzi) { }
		}
		else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_MenuLokace) {
			if this.JeVMenu(MenuAkceTyp.MenuLokace_Spustit) { }
			else if this.JeVMenu(MenuAkceTyp.MenuLokace_Oblibene) { }
			else if this.JeVMenu(MenuAkceTyp.MenuLokace_Pohlavi) { this.NastavitDataTextu(GetLocalizedText("LocKey#15142280"), GetLocalizedText("LocKey#15142283")); textNastaven = true; }
			else if this.JeVMenu(MenuAkceTyp.MenuLokace_VybratEpizodu) {
				if IsDefined(this.menuVybranaLokaceEpizoda) {
					textNastaven = this.ZobrazitDataLokace(this.menuVybranaLokaceEpizoda);
				}

				this.menuAkceTyp = MenuAkceTyp.MenuLokace_VybratEpizodu;
			}
			else if this.JeVMenu(MenuAkceTyp.MenuLokace_NastaveniPostav) { this.NastavitDataTextu(GetLocalizedText("LocKey#15142336"), GetLocalizedText("LocKey#15142337")); textNastaven = true; }
			else if this.JeVMenu(MenuAkceTyp.MenuLokace_OblibeneOd) { }
			else if this.JeVMenu(MenuAkceTyp.MenuLokace_ZahoditPV) { this.NastavitDataTextu(GetLocalizedText("LocKey#15142166"), GetLocalizedText("LocKey#15144098")); textNastaven = true; }
			else if this.JeVMenu(MenuAkceTyp.MenuLokace_VybratHudbu) { this.NastavitDataTextu(GetLocalizedText("LocKey#15142282"), GetLocalizedText("LocKey#15142284")); textNastaven = true; }
			else if this.JeVMenu(MenuAkceTyp.MenuLokace_Koupit) { }
			else if this.JeVMenu(MenuAkceTyp.MenuLokace_Nastaveni) { this.NastavitDataTextu(GetLocalizedText("LocKey#15142347"), GetLocalizedText("LocKey#15142348")); textNastaven = true; }
			else if this.JeVMenu(MenuAkceTyp.MenuLokace_OpakovaniSceny) { this.NastavitDataTextu(GetLocalizedText("LocKey#15142049"), GetLocalizedText("LocKey#15142048")); textNastaven = true; }
			else {
				let i = 0;
				while i < ArraySize(this.menuVybranaPostavaPole) {
					if this.JeVMenu(MenuAkceTyp.MenuLokace_VybratPostavu, [i]) {
						this.lokaceVyberPostavVybP = i;

						let popis: Bool = false;

						if IsDefined(this.menuVybranaLokaceEpizoda) {
							if Equals(this.menuVybranaLokaceEpizoda.GlobalniID, GlobalniID.Lokace_Concert_RedDirt) {
								this.NastavitDataTextu(GetLocalizedText("LocKey#15142241"), GetLocalizedText("LocKey#15142246"));
								popis = true;
							}
						} else {
							if Equals(this.menuVybranaLokace.GlobalniID, GlobalniID.Lokace_Beach) {
								this.NastavitDataTextu(GetLocalizedText("LocKey#15142253"), GetLocalizedText("LocKey#15142260"));
								popis = true;
							}
						}

						if !popis {
							if i == 0 { this.NastavitDataTextu(GetLocalizedText("LocKey#15142126"), GetLocalizedText("LocKey#15142129")); }
							if i == 1 { this.NastavitDataTextu(GetLocalizedText("LocKey#15142127"), GetLocalizedText("LocKey#15142130")); }
							if i == 2 { this.NastavitDataTextu(GetLocalizedText("LocKey#15142132"), GetLocalizedText("LocKey#15142133")); }
							if i == 3 { this.NastavitDataTextu(GetLocalizedText("LocKey#15142244"), GetLocalizedText("LocKey#15142245")); }
							if i == 4 { this.NastavitDataTextu(GetLocalizedText("LocKey#15142255"), GetLocalizedText("LocKey#15142256")); }
							if i == 5 { this.NastavitDataTextu(GetLocalizedText("LocKey#15142257"), GetLocalizedText("LocKey#15142258")); }
						}

						textNastaven = true;
					}
					i += 1;
				}
			}
		}
		else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_VybratHudbu) {
			if this.JeVMenu(MenuAkceTyp.VybratHudbu_Vybrat) {
				this.specialniTlacitkoAkce = SpecTlacAkce.NahledHudby;
				this.ZobrazitSpecTlac(true);

				let polozkaData: array<Int32> = this.JeVMenuZiskatData();
				let hudba: ref<DataHudby> = this.ZiskatDataHudby(polozkaData[0]);
				if IsDefined(hudba) {
					this.NastavitDataTextu(hudba.Nazev, hudba.Popis, hudba.Autor);
					textNastaven = true;
				}
			}
		}
		else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_MenuLokace_NastaveniPostav) {
			if this.JeVMenu(MenuAkceTyp.MenuLokace_NastaveniPostav_Postava) { }
		}
		else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_HlavniRecepce) {
			if !this.JeVMenu(MenuAkceTyp.HlavniRecepce_OnlineStat) {
				this.OnlineFunkceNastavitText("", "", "", "");
			}

			if this.JeVMenu(MenuAkceTyp.HlavniRecepce_SoukromePV) {
				this.NastavitDataTextu(GetLocalizedText("LocKey#15142294"), GetLocalizedText("LocKey#15142295"));
				textNastaven = true;
			}
			else if this.JeVMenu(MenuAkceTyp.HlavniRecepce_ER) {
				this.NastavitDataTextu(GetLocalizedText("LocKey#15142351"), GetLocalizedText("LocKey#15142354"));
				textNastaven = true;
			}
			else if this.JeVMenu(MenuAkceTyp.HlavniRecepce_OnlineStat) {
				let text: String = "";

				if this.lizziesBDsOnline.Instalovano() {
					text = text + s"<Rich style=\"Bold\">\(GetLocalizedText("LocKey#15144064")):</> \(this.lizziesBDsOnline.celkovyPocet)\n\n";
					text = text + GetLocalizedText("LocKey#15142235");

					let slp1: String = s"\n\n\n\n<Rich style=\"Bold\">\(GetLocalizedText("LocKey#15142236"))</>\n";
					let slp2: String = s"\n\n\n\n<Rich style=\"Bold\">\(GetLocalizedText("LocKey#15142238"))</>\n";
					let slp3: String = s"\n\n\n\n<Rich style=\"Bold\">\(GetLocalizedText("LocKey#15142237"))</>\n";
					let slp4: String = s"\n\n\n\n<Rich style=\"Bold\">\(GetLocalizedText("LocKey#15142238"))</>\n";

					let m: Int32 = 29;
					let i = 0;
					while i < ArraySize(this.lizziesBDsOnline.zhaveDnesCelkemPostavy) && i < m {
						let data: ref<DataPostavy> = this.ZiskatDataPostav(IntEnum(this.lizziesBDsOnline.zhaveDnesCelkemPostavy[i]), 0);
						slp1 += (IsDefined(data) ? data.ZiskatNazevPostavy() : "-") + "\n";
						i += 1;
					}
					i = 0;
					while i < ArraySize(this.lizziesBDsOnline.zhaveDnesCelkemPostavyPocet) && i < m {
						slp2 += ToString(this.lizziesBDsOnline.zhaveDnesCelkemPostavyPocet[i]) + "\n";
						i += 1;
					}
					i = 0;
					while i < ArraySize(this.lizziesBDsOnline.zhaveDnesCelkemLokace) && i < m {
						let dataLokace: ref<DataLokace> = this.ZiskatDataLokace(this.lizziesBDsOnline.zhaveDnesCelkemLokace[i]);
						slp3 += (IsDefined(dataLokace) ? ToString(dataLokace.NazevUplny) : "-") + "\n";
						i += 1;
					}
					i = 0;
					while i < ArraySize(this.lizziesBDsOnline.zhaveDnesCelkemLokacePocet) && i < m {
						slp4 += ToString(this.lizziesBDsOnline.zhaveDnesCelkemLokacePocet[i]) + "\n";
						i += 1;
					}

					this.OnlineFunkceNastavitText(slp1, slp2, slp3, slp4);
				} else {
					text = text + s"<Rich style=\"Bold\" color=\"#FF0000\">\(GetLocalizedText("LocKey#15142095"))</>";
				}

				this.NastavitDataTextu(GetLocalizedText("LocKey#15142124"), text);

				textNastaven = true;
			} else {
				this.ZobrazitRecepci();
				textNastaven = true;
				if this.JeVMenu(MenuAkceTyp.HlavniRecepce_Sluzba) { }
			}
		}
		else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_HlavniRecepceSoukromePV) {
			if this.JeVMenu(MenuAkceTyp.HlavniRecepceSoukromePV_Lokace) {
				this.NastavitDataTextu(GetLocalizedText("LocKey#15142294"), GetLocalizedText("LocKey#15142295"));
				textNastaven = true;
			}
		}
		else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_NastaveniPostavy) {
			if this.JeVMenu(MenuAkceTyp.NastaveniPostavy_Zeny) { this.menuAkceTyp = MenuAkceTyp.Pohlavi_Zeny; }
			else if this.JeVMenu(MenuAkceTyp.NastaveniPostavy_Muzi) { this.menuAkceTyp = MenuAkceTyp.Pohlavi_Muzi; }
		}
		else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_BarLokace) {
			if this.JeVMenu(MenuAkceTyp.BarLokace_Lokace) {
				let polozkaData: array<Int32> = this.JeVMenuZiskatData();
				textNastaven = this.ZobrazitDataLokace(this.poleLokaciData[polozkaData[0]]);
				this.menuAkceTyp = MenuAkceTyp.BarLokace_Lokace;
			}
		}
		else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_Debug) {
			if this.JeVMenu(MenuAkceTyp.Debug_Debug) {
				let arr: array<String> = [
					"active", "active_bd", "msg_allow", "judy_msgs_01",
					"breach", "booth_state", "reset", "views", "apartment", "stream", "stream_msg", "stream_bought", "menu_ui", "menu_ui_active", "tax", "tax_disabled",
					"sel_0", "sel_app_0", "sel_custom_0", "sel_gender_0", "sel_special_0", "sel_big_0", "sel_facial_idle_0", "sel_facial_pose_0",
					"sel_1", "sel_app_1", "sel_custom_1", "sel_gender_1", "sel_special_1", "sel_big_1", "sel_facial_idle_1", "sel_facial_pose_1",
					"sel_2", "sel_app_2", "sel_custom_2", "sel_gender_2", "sel_special_2", "sel_big_2", "sel_facial_idle_2", "sel_facial_pose_2",
					"sel_3", "sel_app_3", "sel_custom_3", "sel_gender_3", "sel_special_3", "sel_big_3", "sel_facial_idle_3", "sel_facial_pose_3",
					"sel_4", "sel_app_4", "sel_custom_4", "sel_gender_4", "sel_special_4", "sel_big_4", "sel_facial_idle_4", "sel_facial_pose_4",
					"sel_5", "sel_app_5", "sel_custom_5", "sel_gender_5", "sel_special_5", "sel_big_5", "sel_facial_idle_5", "sel_facial_pose_5",
					"sel_loc"
				];

				let text: String = "";
				let i = 0;
				while i < ArraySize(arr) {
					let faktNazev: CName = StringToName("lizzies_bds_" + arr[i]);
					text = text + arr[i] + " = <Rich style=\"Bold\">" + ToString(this.questsSystem.GetFact(faktNazev)) + "</> <Rich style=\"Bold\" color=\"#FF0000\">|</> ";
					i += 1;
				}

				i = 0;
				while i < ArraySize(this.poleNastaveniData) {
					let faktNazev: CName = this.poleNastaveniData[i].FaktKeZmene;
					text = text + ToString(faktNazev) + " = <Rich style=\"Bold\">" + ToString(this.questsSystem.GetFact(faktNazev)) + "</> <Rich style=\"Bold\" color=\"#FF0000\">|</> ";
					i += 1;
				}

				this.NastavitDataTextu("DEBUG", text);

				textNastaven = true;
			}
		}
		else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_PostavaMoznosti) {
			this.lokaceVyberPostavVybP = -1;
		
			if this.JeVMenu(MenuAkceTyp.PostavaMoznosti_Postava) {
				let polozkaData: array<Int32> = this.JeVMenuZiskatData();
				this.lokaceVyberPostavVybP = polozkaData[0];
				let vzhled: Int32 = this.questsSystem.GetFact(StringToName(Konstanty.FaktVybranyVzhled() + ToString(this.lokaceVyberPostavVybP)));
				this.menuVybranaPostavaDocasna.Vzhled = vzhled;
				textNastaven = this.ZobrazitDataPostavy(this.menuVybranaPostavaPole[polozkaData[0]].DataPostavy, true);
				this.menuAkceTyp = MenuAkceTyp.PostavaMoznosti_Postava;
			}
			else if this.JeVMenu(MenuAkceTyp.PostavaMoznosti_Zkop) { this.NastavitDataTextu(GetLocalizedText("LocKey#15142262"), GetLocalizedText("LocKey#15142263")); textNastaven = true; }
		}
		else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_PostavaMoznostiPostava) {
			if this.JeVMenu(MenuAkceTyp.PostavaMoznostiPostava_Vzhled) {
				let vzhled: Int32 = this.questsSystem.GetFact(StringToName(Konstanty.FaktVybranyVzhled() + ToString(this.lokaceVyberPostavVybP)));
				this.menuVybranaPostavaDocasna.Vzhled = vzhled;

				textNastaven = this.ZobrazitDataPostavy(this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].DataPostavy, true);
				this.menuAkceTyp = MenuAkceTyp.Postava_Vzhledy;
			}
			else if this.JeVMenu(MenuAkceTyp.PostavaMoznostiPostava_Oblicej_Klid) { this.NastavitDataTextu(GetLocalizedText("LocKey#15142128"), GetLocalizedText("LocKey#15142180")); textNastaven = true; }
			else if this.JeVMenu(MenuAkceTyp.PostavaMoznostiPostava_Oblicej_Poza) { this.NastavitDataTextu(GetLocalizedText("LocKey#15142131"), GetLocalizedText("LocKey#15142181")); textNastaven = true; }
		}
		else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_PostavaMoznostiPostavaOblicejKlid) {
			if this.JeVMenu(MenuAkceTyp.PostavaMoznostiPostavaOblicejKlid_Klid) {
				let polozkaData: array<Int32> = this.JeVMenuZiskatData();
				//this.menuVybranaPostavaDocasna.Vzhled = polozkaData[0];

				this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyOblicejKlid() + ToString(this.lokaceVyberPostavVybP)), polozkaData[0]);
				this.questsSystem.SetFact(this.factUISel, 1);
				
				this.menuAkceTyp = this.akceMenuZpet;
			}
		}
		else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_PostavaMoznostiPostavaOblicejPoza) {
			if this.JeVMenu(MenuAkceTyp.PostavaMoznostiPostavaOblicejPoza_Poza) {
				let polozkaData: array<Int32> = this.JeVMenuZiskatData();
				//this.menuVybranaPostavaDocasna.Vzhled = polozkaData[0];
				
				this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyOblicejPoza() + ToString(this.lokaceVyberPostavVybP)), polozkaData[0]);
				this.questsSystem.SetFact(this.factUISel, 1);

				this.menuAkceTyp = this.akceMenuZpet;
			}
		}
		else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_PostavaVzhledy) {
			if this.JeVMenu(MenuAkceTyp.PostavaVzhledy_Vzhled) {
				let polozkaData: array<Int32> = this.JeVMenuZiskatData();

				this.menuVybranaPostavaDocasna.Vzhled = polozkaData[0];

				let data: ref<DataPostavy> = this.ZiskatDataPostav(this.menuVybranaPostavaDocasna);
				textNastaven = this.ZobrazitDataPostavy(data, true);
			}
		}
		else if this.menuStrom.Soucasne(MenuStrankaTyp.Menu_GFH) {
			if this.JeVMenu(MenuAkceTyp.MenuGFH_NastaveniPostavy) { }
			else if this.JeVMenu(MenuAkceTyp.MenuGFH_Spustit) { }
			else if this.JeVMenu(MenuAkceTyp.MenuLokace_Nastaveni) { this.NastavitDataTextu(GetLocalizedText("LocKey#15142347"), GetLocalizedText("LocKey#15142349")); textNastaven = true; }
			else {
				if this.JeVMenu(MenuAkceTyp.MenuGFH_VybratPostavu, [0]) {
					this.lokaceVyberPostavVybP = 0;
				}
			}
		}
		else {
			if this.JeVMenu(MenuAkceTyp.__Postava) {
				let polozkaData: array<Int32> = this.JeVMenuZiskatData();
				let postavaData: ref<DataPostavy> = this.ZiskatDataPostav(IntEnum(polozkaData[0]), polozkaData[1]);
				textNastaven = this.ZobrazitDataPostavy(postavaData, false);
			}
		}

		if this.JeVMenu(MenuAkceTyp.Globalni_DalsiStranka) { }
		else if this.JeVMenu(MenuAkceTyp.Globalni_Zpet) { this.menuAkceTyp = this.akceMenuZpet; }
		else if
			this.menuStrom.Soucasne(MenuStrankaTyp.Menu_NastaveniRuzne) ||
			this.menuStrom.Soucasne(MenuStrankaTyp.Menu_PostavaMoznostiPostava) ||
			this.menuStrom.Soucasne(MenuStrankaTyp.Menu_MenuLokace_NastaveniPostav_Postava) ||
			this.menuStrom.Soucasne(MenuStrankaTyp.Menu_MenuLokace_Nastaveni) ||
			this.menuStrom.Soucasne(MenuStrankaTyp.Menu_GFH_NastaveniPostavy) ||
			this.menuStrom.Soucasne(MenuStrankaTyp.Menu_KatalogNastaveni)
		{
			if this.JeVMenu(MenuAkceTyp.NastaveniRuzne_Nastaveni) {
				let polozkaData: array<Int32> = this.JeVMenuZiskatData();
				textNastaven = this.ZobrazitDataNastaveni(this.poleNastaveniData[polozkaData[0]]);

				this.specialniTlacitkoAkce = SpecTlacAkce.NastaveniZpetne;
				this.ZobrazitSpecTlac(true);
			}
		}
		else if this.JeVMenu(MenuAkceTyp.__Ulozeno) {
			let polozkaData: array<Int32> = this.JeVMenuZiskatData();

			let specifickaPolozka: Int32 = -1;
			let typUloziste: UlozisteTyp = IntEnum(polozkaData[0]);

			if Equals(typUloziste, UlozisteTyp.SledovatZnovu) && Equals(this.aktivniTypMenu, MenuUITyp.Pevecka) { specifickaPolozka = 1; }
			else if Equals(typUloziste, UlozisteTyp.SledovatZnovu) && NotEquals(this.aktivniTypMenu, MenuUITyp.Pevecka) { specifickaPolozka = 0; }

			let ulozeno: array<ref<LizziesBDsUlozistePolozkaV5>> = this.lizziesBDsUloziste.VratitPoleDat(typUloziste);
			let pocet: Int32 = ArraySize(ulozeno);

			let i = 0;
			while i < pocet {
				if ulozeno[i].ID == polozkaData[1] || specifickaPolozka == i {
					this.NastavitViditelnostPodleNazvu("oblibene", true);
					textNastaven = true;

					let picCtrlPostava: ref<inkImage> = this.GetChildWidgetByPath(n"main_ui/main_container/oblibene/postava1_container/postava") as inkImage;
					picCtrlPostava.SetVisible(false);
					let picCtrlPostava2: ref<inkImage> = this.GetChildWidgetByPath(n"main_ui/main_container/oblibene/postava2_container/postava") as inkImage;
					picCtrlPostava2.SetVisible(false);
					let picCtrlPostava3: ref<inkImage> = this.GetChildWidgetByPath(n"main_ui/main_container/oblibene/postava3_container/postava") as inkImage;
					picCtrlPostava3.SetVisible(false);

					let dataLokace: ref<DataLokace> = this.ZiskatDataLokace(ulozeno[i].LokaceID);
					if IsDefined(dataLokace.Nadrazene) && !dataLokace.VolnePV {
						this.menuVybranaLokace = dataLokace.Nadrazene;
						this.menuVybranaLokaceEpizoda = dataLokace;
					} else {
						this.menuVybranaLokace = dataLokace;
						this.menuVybranaLokaceEpizoda = null;
					}

					this.NastavitVybranePostavyPole(dataLokace.PocetPostav);

					let picCtrlLokace: ref<inkImage> = this.GetChildWidgetByPath(n"main_ui/main_container/oblibene/lokace") as inkImage;
					this.NastavitObrazek(picCtrlLokace, dataLokace.ObrAtlasID, dataLokace.ObrAtlasNazev, 0);
					if GlobalniFunkce.LokaceVelkyObrazek(dataLokace.ObrAtlasID) {
						picCtrlLokace.SetSize(new Vector2(320.0, 320.0));
					} else {
						picCtrlLokace.SetSize(new Vector2(800.0, 320.0));
					}

					let nameCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/oblibene/nameTxt") as inkText;
					nameCtrl.SetText("");

					let text: String = "";
					if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) { text = "LocKey#15142164"; }
					else if Equals(typUloziste, UlozisteTyp.SledovatZnovu) { text = "LocKey#15142259"; }
					else { text = "LocKey#15142115"; }
					text = GetLocalizedText(text) + ":\n";

					text = text + "<Rich style=\"Bold\">" + GetLocalizedText("LocKey#15142089") + ":</> " + dataLokace.NazevUplny;
					if dataLokace.BezPostavy {
						if NotEquals(this.aktivniTypMenu, MenuUITyp.Pevecka) && NotEquals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) && dataLokace.Cena > 0 {
							text = text + " <Rich style=\"Bold\" color=\"#FFD700\">€$ " + GlobalniFunkce.FormatovanaCena(dataLokace.Cena) + "</>";
						}
					} else {
						text = text + "\n";
						text = text + "<Rich style=\"Bold\">" + GetLocalizedText("LocKey#15142090") + ":</> ";
					}

					let pohlavi: GenderType = GenderType.None;

					let j = 0;
					while j < dataLokace.PocetPostav {
						if NotEquals(ulozeno[i].Postavy[j].PostavaGID, GlobalniID.Prazdne) {
							let postava: ref<DataPostavy> = this.ZiskatDataPostav(ulozeno[i].Postavy[j]);
							if IsDefined(postava) {
								this.menuVybranaPostavaPole[j] = ulozeno[i].Postavy[j].NovaInstance();
								this.menuVybranaPostavaPole[j].NastavitData(postava);
								this.menuVybranaPostavaPole[j].PostavaVybrana = true;
								this.menuVybranaPostavaPole[j].Nazev = postava.ZiskatNazevPostavy(ulozeno[i].Postavy[j].Vzhled);

								pohlavi = postava.Pohlavi;

								if this.pozvaniDoBytuAktivni {
									let partner: GlobalniID = this.PozvaniDoBytuAktivniPostava();
									if Equals(ulozeno[i].Postavy[j].PostavaGID, partner) {
										this.PozvaniDoBytuPostavaData(j);
									}
								}
								
								let p: ref<inkImage> = null;
								if j == 0 { p = picCtrlPostava; }
								//if j == 1 { p = picCtrlPostava2; }
								//if j == 2 { p = picCtrlPostava3; }

								if !dataLokace.BezPostavy {
									text = text + (j > 0 ? ", " : "") + this.OblibeneNastavitObrazek(p, this.menuVybranaPostavaPole[j].DataPostavy, ulozeno[i].Postavy[j].Vzhled);
								}
							}
						}
						j += 1;
					}

					if NotEquals(pohlavi, GenderType.None) {
						this.vybranePohlavi = pohlavi;
					}

					if dataLokace.BezPostavy && !dataLokace.VolnePV {
						this.menuAkceTyp = Equals(this.aktivniTypMenu, MenuUITyp.KoupeniPV) ? MenuAkceTyp.MenuLokace_Koupit : MenuAkceTyp.MenuLokace_Spustit;
					} else {
						this.menuAkceTyp = MenuAkceTyp.Globalni_MenuLokace;
					}
					
					text = text + "\n";

					GlobalniFunkce.ZkopirovatNastaveni(ulozeno[i].Nastaveni, this.menuVybraneNastaveni);

					if NotEquals(this.aktivniTypMenu, MenuUITyp.Pevecka) && this.menuVybranaLokace.PodporujeOpakovani {
						let opakovani: String = this.VybraneOpakovaniText(GlobalniFunkce.ZiskatNastaveni(this.menuVybraneNastaveni, this.factClipCount), true);
						text = text + opakovani;

						let cena: Int32 = this.VybraneOpakovaniCena(GlobalniFunkce.ZiskatNastaveni(this.menuVybraneNastaveni, this.factClipCount));
						if cena > 0 {
							text = text + " <Rich style=\"Bold\" color=\"#FFD700\">€$ " + GlobalniFunkce.FormatovanaCena(cena) + "</>" + "\n";
						}
					}

					let descCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/oblibene/descTxt") as inkText;
					descCtrl.SetText(text);

					this.oblibeneVybraneID = ulozeno[i].ID;
					this.OblibeneOp(1);

					i = 999;
				}

				i += 1;
			}
		}

		if !textNastaven {
			this.ZobrazitDefaultniText();
		}

		if Equals(this.specialniTlacitkoAkce, SpecTlacAkce.ZadnaAkce) {
			this.ZobrazitSpecTlac(false);
		}

		this.Gamepad(1);

		if Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) {
			let cyb: Int32 = this.questsSystem.GetFact(n"lizzies_bds_cyb_begin");
			if cyb == 0 {
				GameInstance.GetAudioSystem(this.game).Play(n"mus_lizzies_bds_q50_stop");

				GameInstance.GetDelaySystem(this.game).CancelDelay(this.VVIDProdlevy);
				GameInstance.GetDelaySystem(this.game).CancelDelay(this.VVIDProdlevy2);
				
				let callback = new VVListenerCallback();
				callback.typ = 1;
				callback.controller = this;
				this.VVIDProdlevy = GameInstance.GetDelaySystem(this.game).DelayCallback(callback, 300, false);
			}
		}
	}

	private final func OblibeneNastavitObrazek(picCtrlPostava: ref<inkImage>, dataPostavy: ref<DataPostavy>, vzhledNum: Int32) -> String {
		let popis: String = "";

		if IsDefined(dataPostavy) {
			let nazev: String = dataPostavy.ZiskatNazevPostavy(vzhledNum);
			popis = nazev + (NotEquals(this.aktivniTypMenu, MenuUITyp.Pevecka) && NotEquals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) && dataPostavy.Cena > 0 ? " <Rich style=\"Bold\" color=\"#FFD700\">€$ " + GlobalniFunkce.FormatovanaCena(dataPostavy.Cena) + "</>" + (dataPostavy.MaSlevu > 0 ? " <Rich style=\"Bold\" color=\"#FF0000\">-" + dataPostavy.MaSlevu + "%</>" : "") : "");

			if picCtrlPostava != null {
				if vzhledNum > 0 {
					let vzhled: ref<DataVzhled> = dataPostavy.Vzhledy[vzhledNum];
					if NotEquals(vzhled.ObrAtlasNazev, n"") {
						picCtrlPostava.SetVisible(true);
						this.NastavitObrazek(picCtrlPostava, vzhled.ObrAtlasID, vzhled.ObrAtlasNazev, vzhled.ObrVelikost, vzhled.ObrAtlasCesta);
						GlobalniFunkce.PostavaModObrazek(picCtrlPostava, vzhled.ObrAtlasID, 0);
						this.DynamickyNahled(dataPostavy, vzhledNum);
					}
				} else {
					if NotEquals(dataPostavy.Vzhledy[0].ObrAtlasNazev, n"") {
						picCtrlPostava.SetVisible(true);
						this.NastavitObrazek(picCtrlPostava, dataPostavy.Vzhledy[0].ObrAtlasID, dataPostavy.Vzhledy[0].ObrAtlasNazev, dataPostavy.Vzhledy[0].ObrVelikost, dataPostavy.Vzhledy[0].ObrAtlasCesta);
						GlobalniFunkce.PostavaModObrazek(picCtrlPostava, dataPostavy.Vzhledy[0].ObrAtlasID, 0);
						this.DynamickyNahled(dataPostavy, 0);
					}
				}
			}
		}

		return popis;
	}

	private final func ZobrazitDataPostavy(postava: ref<DataPostavy>, jeVeVyberuVzhledu: Bool) -> Bool {
		if (postava.JeKateg && NotEquals(this.aktivniTypMenu, MenuUITyp.Nastaveni)) || (postava.JeKateg && postava.NastaveniKateg && Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni)) {
			this.menuAkceTyp = MenuAkceTyp.Postava_Kateg;
			this.menuAkceData = EnumInt(postava.PrirazenaStranka);
		} else if ArraySize(postava.Vzhledy) > 1 && !jeVeVyberuVzhledu && NotEquals(this.aktivniTypMenu, MenuUITyp.Nastaveni) && NotEquals(this.aktivniTypMenu, MenuUITyp.KoupeniPV) {
			this.menuAkceTyp = MenuAkceTyp.Postava_Vzhledy;
		} else {
			if Equals(this.aktivniTypMenu, MenuUITyp.PostavaMoznosti) || Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
				this.menuAkceTyp = MenuAkceTyp.PostavaMoznostiPostava_Vzhled;
			} else {
				this.menuAkceTyp = MenuAkceTyp.__Postava;
			}
		}

		this.menuVybranaPostavaDocasna.PostavaGID = postava.GlobalniID;
		this.menuVybranaPostavaDocasna.Vlastni = postava.CustomID;

		if jeVeVyberuVzhledu && this.menuVybranaPostavaDocasna.Vzhled > 0 {
			let vzhled: ref<DataVzhled> = postava.Vzhledy[this.menuVybranaPostavaDocasna.Vzhled];

			if postava.CustomID > 0 && NotEquals(vzhled.ObrAtlasNazev, n"") {
				this.NastavitDataPostavyVlastniObrazek(postava.ZiskatNazevPostavy(this.menuVybranaPostavaDocasna.Vzhled), vzhled.ZiskatPopis(), vzhled.ObrAtlasID, vzhled.ObrAtlasCesta, vzhled.ObrAtlasNazev, postava.Autor, vzhled.ObrVelikost);
				this.DynamickyNahled(postava, this.menuVybranaPostavaDocasna.Vzhled);
				return true;
			}

			if NotEquals(vzhled.ObrAtlasID, InkAtlasSoubor.Prazdne) {
				this.NastavitDataPostavy(postava.ZiskatNazevPostavy(this.menuVybranaPostavaDocasna.Vzhled), vzhled.ObrAtlasID, vzhled.ObrAtlasNazev, postava.Autor, vzhled.ObrVelikost);
				this.DynamickyNahled(postava, this.menuVybranaPostavaDocasna.Vzhled);
				return true;
			}

			if Equals(vzhled.ObrAtlasID, InkAtlasSoubor.Prazdne) && StrCmp(vzhled.Popis, "") != 0 {
				this.NastavitDataTextu(postava.ZiskatNazevPostavy(this.menuVybranaPostavaDocasna.Vzhled), vzhled.ZiskatPopis(), postava.Autor);
				return true;
			}
		}

		if postava.CustomID > 0 && NotEquals(postava.Vzhledy[0].ObrAtlasNazev, n"") {
			this.NastavitDataPostavyVlastniObrazek(postava.ZiskatNazevPostavy(this.menuVybranaPostavaDocasna.Vzhled), postava.ZiskatPopis(), postava.Vzhledy[0].ObrAtlasID, postava.Vzhledy[0].ObrAtlasCesta, postava.Vzhledy[0].ObrAtlasNazev, postava.Autor, postava.Vzhledy[0].ObrVelikost);
			this.DynamickyNahled(postava, 0);
			return true;
		}

		if NotEquals(postava.Vzhledy[0].ObrAtlasID, InkAtlasSoubor.Prazdne) && StrCmp(postava.Vzhledy[0].Popis, "") != 0 {
			this.NastavitDataLokace(postava.ZiskatNazevPostavy(), postava.ZiskatPopis(), postava.Vzhledy[0].ObrAtlasNazev, postava.Vzhledy[0].ObrAtlasID);
			return true;
		}

		if Equals(postava.Vzhledy[0].ObrAtlasID, InkAtlasSoubor.Prazdne) && StrCmp(postava.Vzhledy[0].Popis, "") != 0 {
			this.NastavitDataTextu(postava.ZiskatNazevPostavy(), postava.ZiskatPopis(), postava.Autor);
			return true;
		}

		if NotEquals(postava.Vzhledy[0].ObrAtlasID, InkAtlasSoubor.Prazdne) {
			this.NastavitDataPostavy(postava.ZiskatNazevPostavy(), postava.Vzhledy[0].ObrAtlasID, postava.Vzhledy[0].ObrAtlasNazev, postava.Autor, postava.Vzhledy[0].ObrVelikost);
			this.DynamickyNahled(postava, 0);
			return true;
		}

		return false;
	}

	private final func ZobrazitDataNastaveni(nastaveni: DataNastaveni) -> Bool {
		this.menuAkceData = EnumInt(nastaveni.GlobalniID);

		this.NastavitDataTextu(nastaveni.Nazev, nastaveni.Popis);

		return true;
	}

	private final func ZobrazitDataLokace(lokace: ref<DataLokace>) -> Bool {
		if lokace.ExtData > 0 {
			this.menuAkceTyp = MenuAkceTyp.Prazdne;
			this.menuAkceData = EnumInt(GlobalniID.Prazdne);
		} else {
			if NotEquals(this.aktivniTypMenu, MenuUITyp.Recepce) {
				if this.menuLokaceAktivni {
					this.menuAkceTyp = MenuAkceTyp.__Lokace;
				} else if ArraySize(lokace.Kontejner) > 0 || !lokace.BezPostavy || lokace.VolnePV {
					this.menuAkceTyp = MenuAkceTyp.__Lokace;
					this.menuAkceData = EnumInt(lokace.GlobalniID);
				} else if Equals(this.aktivniTypMenu, MenuUITyp.KoupeniPV) {
					this.menuAkceTyp = MenuAkceTyp.MenuLokace_Koupit;
					this.menuVybranaLokaceEpizoda = lokace;
				} else {
					this.menuAkceTyp = MenuAkceTyp.MenuLokace_Spustit;
					this.menuVybranaLokaceEpizoda = lokace;
				}
			}
		}

		let text: String = "";
		
		if lokace.InteraktivniPV {
			text = "\n\n<Rich style=\"Bold\">" + GetLocalizedText("LocKey#15142094") + "</>";
		}

		if lokace.ExtData == 1 {
			text = "\n\n\n<Rich style=\"Bold\">" + GetLocalizedText("LocKey#15144071") + "</>";
		}
		if lokace.ExtData == 2 {
			text = "\n\n\n<Rich style=\"Bold\" color=\"#ff0000\">" + GetLocalizedText("LocKey#15144090") + "</>";
		}

		if Equals(lokace.ObrAtlasID, InkAtlasSoubor.Prazdne) {
			this.NastavitDataTextu(lokace.Nazev, lokace.Popis + text);
		} else {
			this.NastavitDataLokace(lokace.Nazev, lokace.Popis + text, lokace.ObrAtlasNazev, lokace.ObrAtlasID);
		}

		if !this.menuLokaceAktivni && lokace.BezPostavy && !lokace.VolnePV && NotEquals(this.aktivniTypMenu, MenuUITyp.Recepce) {
			this.LokaceBezPostavyNastavitPole();
			this.OblibeneOp(1);
		}

		return true;
	}

	private final func LokaceBezPostavyNastavitPole() -> Void {
		this.menuVybranaPostavaPole[0].PostavaGID = GlobalniID.Postava_LokaceBezPostavy;
		this.menuVybranaPostavaPole[0].NastavitData(this.ZiskatDataPostav(GlobalniID.Postava_LokaceBezPostavy, 0));
		this.menuVybranaPostavaPole[0].Vlastni = 0;
		this.menuVybranaPostavaPole[0].Vzhled = 0;
		this.menuVybranaPostavaPole[0].PostavaVybrana = true;
		GlobalniFunkce.VlozitNastaveni(this.menuVybraneNastaveni, Konstanty.FaktVybratHudbu(), this.menuVybranaLokace.VychoziHudba);
	}

	private final func VybratPolozkuMenu() -> Void {
		if Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) {
			this.PlayLibraryAnimation(n"glitch_anim");
			GameObjectEffectHelper.StartEffectEvent(this.player, n"personal_link_glitch");
		}

		if Equals(this.menuAkceTyp, MenuAkceTyp.MenuLokace_OpakovaniSceny) {
			let op: Int32 = GlobalniFunkce.ZiskatNastaveni(this.menuVybraneNastaveni, this.factClipCount);
			op = op + 1;
			if op > 2 {
				op = 0;
			}
			GlobalniFunkce.VlozitNastaveni(this.menuVybraneNastaveni, this.factClipCount, op);
			this.VytvoritMenu(MenuStrankaTyp.Soucasne);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.__Lokace) {
			//this.Dialog(true, "Test header", "Some testing text to test the dialog.");
			if !this.menuLokaceAktivni {
				this.menuVybranaLokace = this.ZiskatDataLokace(this.menuAkceData);
				this.VybratLokaci(IntEnum(this.menuAkceData));
			}

			if ArraySize(this.menuVybranaLokace.Kontejner) > 0 &&
				(
					Equals(this.menuVybranaLokace.GlobalniID, GlobalniID.Lokace_Kont_Various) ||
					Equals(this.menuVybranaLokace.GlobalniID, GlobalniID.Lokace_Kont_Relaxing) ||
					Equals(this.menuVybranaLokace.GlobalniID, GlobalniID.Lokace_Kont_Cyberpsycho)
				)
			{
				this.NastavitVybranePostavyPole(this.menuVybranaLokace.PocetPostav);
				this.VytvoritMenu(MenuStrankaTyp.Menu_LokaceKontejner);
				this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Resetovat);
			} else {
				if this.menuLokaceAktivni {
					this.menuStrom.StrankovaniOp(1);

					this.menuAkceTyp = MenuAkceTyp.LokaceKontejner_Lokace;
					let polozkaData: array<Int32> = this.JeVMenuZiskatData();
					this.menuVybranaLokaceEpizoda = this.ZiskatDataLokace(polozkaData[0]);

					//GlobalniFunkce.VlozitNastaveni(this.menuVybraneNastaveni, Konstanty.FaktVybratHudbu(), this.menuVybranaLokaceEpizoda.VychoziHudba);
					//GlobalniFunkce.VlozitNastaveni(this.menuVybraneNastaveni, this.factClipCount, 0);
					this.SestavitNastaveniLokace(false, this.menuVybranaLokaceEpizoda);

					this.NastavitVybranePostavyPole(this.menuVybranaLokaceEpizoda.PocetPostav);

					this.NastavitPohlaviPodleLokace();

					this.VytvoritMenu(MenuStrankaTyp.ZpetStranka);
				} else if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) && ArraySize(this.menuVybranaLokace.Kontejner) == 0 && !this.menuVybranaLokace.VolnePV {
					this.VytvoritMenu(MenuStrankaTyp.Menu_KoupenePVSeznam);
				} else if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) && !this.menuVybranaLokace.VolnePV {
					this.VytvoritMenu(MenuStrankaTyp.Menu_LokaceKontejner);
				} else {
					this.menuVybranaLokaceEpizoda = null;
					this.NastavitVybranePostavyPole(this.menuVybranaLokace.PocetPostav);

					if ArraySize(this.menuVybranaLokace.Kontejner) == 0 {
						//GlobalniFunkce.VlozitNastaveni(this.menuVybraneNastaveni, Konstanty.FaktVybratHudbu(), this.menuVybranaLokace.VychoziHudba);
						this.SestavitNastaveniLokace(false, this.menuVybranaLokace);
						this.NastavitPohlaviPodleLokace();
					}

					if this.menuVybranaLokace.VolnePV {
						this.LokaceBezPostavyNastavitPole();
					}

					this.VytvoritMenu(MenuStrankaTyp.Menu_MenuLokace);
				}
			}
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.Globalni_MenuLokace) {
			this.menuStrom.StrankovaniOp(1);
			this.OblibeneOp(0);
			this.VybratLokaci(this.menuVybranaLokace.GlobalniID);
			this.VytvoritMenu(MenuStrankaTyp.Menu_MenuLokace);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.Globalni_MenuGFH) {
			this.menuStrom.StrankovaniOp(1);
			this.VytvoritMenu(MenuStrankaTyp.Menu_GFH);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.MenuLokace_VybratEpizodu) {
			if NotEquals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
				this.menuStrom.StrankovaniOp(1);
				this.VytvoritMenu(MenuStrankaTyp.Menu_LokaceKontejner);
			}
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.MenuLokace_VybratHudbu) {
			this.menuStrom.StrankovaniOp(1);
			this.VytvoritMenu(MenuStrankaTyp.Menu_VybratHudbu);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.MenuLokace_Pohlavi) {
			let tmpLokace: ref<DataLokace> = this.ZiskatVybranouLokaci();
			if NotEquals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) && Equals(tmpLokace.PouzeProPohlavi, GenderType.None) {
				this.vybranePohlavi = Equals(this.vybranePohlavi, GenderType.Female) ? GenderType.Male : GenderType.Female;
				//GlobalniFunkce.VlozitNastaveni(this.menuVybraneNastaveni, this.factClipCount, 0);
				this.NastavitVybranePostavyPole(tmpLokace.PocetPostav);
				this.VytvoritMenu(MenuStrankaTyp.Soucasne);
			}
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.MenuLokace_VybratPostavu) {
			let tmpLokace: ref<DataLokace> = this.ZiskatVybranouLokaci();
			let podminka: Bool = true;

			if this.pozvaniDoBytuAktivni {
				let podminkaSl: Bool = true;

				let i = 0;
				while i < tmpLokace.PocetPostav {
					if this.menuVybranaPostavaPole[i].PostavaVybrana {
						podminkaSl = false;
						i = 999;
					}
					i += 1;
				}

				let partner: GlobalniID = this.PozvaniDoBytuAktivniPostava();

				if podminkaSl {
					this.DataPoleLokaciPozvaniDoBytu(partner, this.lokaceVyberPostavVybP);
					this.VytvoritMenu(MenuStrankaTyp.Soucasne);
					podminka = false;
				} else {
					if Equals(this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].DataPostavy.GlobalniID, partner) {
						podminka = false;
					}
				}
			}
			
			if podminka {
				if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
					if ArraySize(this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].DataPostavy.Vzhledy) == 1 { return; }
					this.menuVybranaPostavaDocasna = this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].NovaInstance();

					this.VytvoritMenu(MenuStrankaTyp.Menu_PostavaVzhledy);
					this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Resetovat);
				} else {
					if tmpLokace.PohlaviSpolecne {
						let zobrazitPohlavi: Int32 = this.questsSystem.GetFact(Konstanty.FaktZobrazitPohlavi());
						if zobrazitPohlavi == 0 {
							this.VytvoritMenu(MenuStrankaTyp.Menu_Pohlavi);
						} else {
							this.OtevritKatalogPostav();
						}
					} else {
						this.OtevritKatalogPostav();
					}
				}
			}
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.Pohlavi_Muzi) || Equals(this.menuAkceTyp, MenuAkceTyp.Pohlavi_Zeny) {
			if Equals(this.menuAkceTyp, MenuAkceTyp.Pohlavi_Zeny) {
				this.vybranePohlavi = GenderType.Female;
			}
			else if Equals(this.menuAkceTyp, MenuAkceTyp.Pohlavi_Muzi) {
				this.vybranePohlavi = GenderType.Male;
			}

			this.OtevritKatalogPostav();
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.MenuLokace_Spustit) || Equals(this.menuAkceTyp, MenuAkceTyp.MenuGFH_Spustit) {
			let tmpLokace: ref<DataLokace> = null;

			if NotEquals(this.menuAkceTyp, MenuAkceTyp.MenuGFH_Spustit) {
				tmpLokace = this.ZiskatVybranouLokaci();

				if tmpLokace.BezPostavy && !tmpLokace.VolnePV {
					this.SestavitNastaveniLokace(false, tmpLokace);
				}

				if !this.ZpracovatCenu(this.menuVybranaPostavaPole, GlobalniFunkce.ZiskatNastaveni(this.menuVybraneNastaveni, this.factClipCount), EnumInt(tmpLokace.GlobalniID)) {
					return;
				}

				this.questsSystem.SetFact(Konstanty.FaktVybranaLokace(), EnumInt(tmpLokace.GlobalniID));
				//this.questsSystem.SetFact(this.factClipCount, this.menuVybranyPocetOpakovani);
				//this.questsSystem.SetFact(Konstanty.FaktVybratHudbu(), this.menuVybranaHudba);

				this.PrehraneKazety(tmpLokace.GlobalniID);

				let tmpPostavyPole: array<ref<VybranaPostava>> = this.menuVybranaPostavaPole;
				this.DataPoleLokaciVychoziVyber();

				if NotEquals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
					this.lizziesBDsUloziste.Pridat(UlozisteTyp.SledovatZnovu, EnumInt(tmpLokace.GlobalniID), this.menuVybraneNastaveni, tmpPostavyPole, 0);
				}
			}

			for n in this.menuVybraneNastaveni {
				this.questsSystem.SetFact(n.NastaveniName, n.Hodnota);
			}

			let i = 0;
			while i < ArraySize(this.menuVybranaPostavaPole) {
				let faktPostava: CName = StringToName(Konstanty.FaktVybranaPostava() + ToString(i));

				if this.menuVybranaPostavaPole[i].PostavaVybrana {
					this.questsSystem.SetFact(faktPostava, EnumInt(this.menuVybranaPostavaPole[i].PostavaGID));
					this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranaPostavaVlastni() + ToString(i)), this.menuVybranaPostavaPole[i].Vlastni);
					this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyVzhled() + ToString(i)), this.menuVybranaPostavaPole[i].Vzhled);
					this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyPohlavi() + ToString(i)), Equals(GenderType.Female, this.menuVybranaPostavaPole[i].Pohlavi) ? 2 : 1);
					this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranySpecialni() + ToString(i)), this.menuVybranaPostavaPole[i].Specialni ? 1 : 0);
					this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyVelke() + ToString(i)), this.menuVybranaPostavaPole[i].VelkaPostava ? 1 : 0);
					this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyRobot() + ToString(i)), this.menuVybranaPostavaPole[i].Robot ? 1 : 0);

					for n in this.menuVybranaPostavaPole[i].Nastaveni {
						let fN: CName = n.NastaveniName;
						
						if
							NotEquals(this.menuVybranaPostavaPole[i].PostavaGID, GlobalniID.Postava_Female_V) &&
							NotEquals(this.menuVybranaPostavaPole[i].PostavaGID, GlobalniID.Postava_Male_V)
						{
							fN = StringToName(NameToString(n.NastaveniName) + "_" + ToString(i));
						}

						this.questsSystem.SetFact(fN, n.Hodnota);
					}

					this.NastavitDB(this.menuVybranaPostavaPole[i].DataPostavy, this.menuVybranaPostavaPole[i].Vzhled, i);

					if NotEquals(this.menuAkceTyp, MenuAkceTyp.MenuGFH_Spustit) {
						this.ZhaveDnesOD(this.menuVybranaPostavaPole[i].DataPostavy, i > 0 ? -1 : EnumInt(tmpLokace.GlobalniID));
					}

					/*if Equals(tmpLokace.GlobalniID, GlobalniID.Lokace_PONC_JigJig) {
						this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyOblicejKlid() + ToString(i)), 19);
						this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyOblicejPoza() + ToString(i)), 54);
						this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyOblicejKlidVaha() + ToString(i)), 0);
						this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyOblicejPozaVaha() + ToString(i)), 0);
					}*/
				} else {
					this.questsSystem.SetFact(faktPostava, 0);
				}
				i += 1;
			}

			this.NastavitAudio();
			this.UkonceniMenu();
			return;
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.MenuLokace_Oblibene) || Equals(this.menuAkceTyp, MenuAkceTyp.MenuLokace_Koupit) {
			let tmpLokace: ref<DataLokace> = this.ZiskatVybranouLokaci();

			if Equals(this.menuAkceTyp, MenuAkceTyp.MenuLokace_Koupit) {
				if this.lizziesBDsUloziste.JeVUlozisti(UlozisteTyp.Koupeno, EnumInt(tmpLokace.GlobalniID), this.menuVybraneNastaveni, this.menuVybranaPostavaPole) != -1 {
					return;
				}

				if !this.ZpracovatCenu(this.menuVybranaPostavaPole, GlobalniFunkce.ZiskatNastaveni(this.menuVybraneNastaveni, this.factClipCount), EnumInt(tmpLokace.GlobalniID)) {
					return;
				}
			}

			this.lizziesBDsUloziste.Pridat(Equals(this.menuAkceTyp, MenuAkceTyp.MenuLokace_Koupit) ? UlozisteTyp.Koupeno : UlozisteTyp.Oblibene, EnumInt(tmpLokace.GlobalniID), this.menuVybraneNastaveni, this.menuVybranaPostavaPole);

			if Equals(this.menuAkceTyp, MenuAkceTyp.MenuLokace_Koupit) {
				this.questsSystem.SetFact(this.factBoughtBD, 1);

				this.UkonceniMenu();
				return;
			} else {
				this.VytvoritMenu(MenuStrankaTyp.Soucasne);
			}
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.MenuLokace_OblibeneOd) {
			this.lizziesBDsUloziste.SmazatID(UlozisteTyp.Oblibene, this.oblibeneVybraneID);
			this.VytvoritMenu(MenuStrankaTyp.Soucasne);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.MenuLokace_ZahoditPV) {
			this.lizziesBDsUloziste.SmazatID(UlozisteTyp.Koupeno, this.oblibeneVybraneID);
			this.KoupenePVSeznam();
			//this.NastavitVybranePostavyPole(this.menuVybranaLokace.PocetPostav);
			//this.ResetovatVyber();
			//this.VytvoritMenu(this.menuData[this.vybraneMenu]);
			this.menuAkceTyp = MenuAkceTyp.Globalni_ZpetDoMenu;
			this.VybratPolozkuMenu();
			return;
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.MenuLokace_NastaveniPostav) {
			this.menuStrom.StrankovaniOp(1);
			this.VytvoritMenu(MenuStrankaTyp.Menu_MenuLokace_NastaveniPostav);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.MenuLokace_Nastaveni) {
			this.menuStrom.StrankovaniOp(1);
			this.VytvoritMenu(MenuStrankaTyp.Menu_MenuLokace_Nastaveni);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.__Postava) {
			let data: ref<DataPostavy> = this.ZiskatDataPostav(this.menuVybranaPostavaDocasna); //.NovaInstance()
			let jeGFHMenu: Bool = Equals(this.aktivniTypMenu, MenuUITyp.GFH);

			if this.menuLokaceAktivni || jeGFHMenu {
				this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP] = this.menuVybranaPostavaDocasna.NovaInstance();
				this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].NastavitData(data);
				this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].Nazev = data.ZiskatNazevPostavy(this.menuVybranaPostavaDocasna.Vzhled);
				this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].PostavaVybrana = true;
				this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].Pohlavi = this.vybranePohlavi;

				let zachovatNastaveni: Int32 = this.questsSystem.GetFact(Konstanty.FaktNastaveniZachovatNst());
				if zachovatNastaveni == 0 {
					let ulozeno: array<ref<LizziesBDsUlozistePolozkaV5>> = this.lizziesBDsUloziste.VratitPoleDat(UlozisteTyp.SledovatZnovu);
					if ArraySize(ulozeno) > 0 {
						let index: Int32 = Equals(this.aktivniTypMenu, MenuUITyp.Pevecka) ? 1 : 0;
						let ulozenoVyb: ref<LizziesBDsUlozistePolozkaV5> = ulozeno[index];
						if ArraySize(ulozenoVyb.Postavy) > this.lokaceVyberPostavVybP {
							GlobalniFunkce.ZkopirovatNastaveni(ulozenoVyb.Postavy[this.lokaceVyberPostavVybP].Nastaveni, this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].Nastaveni);
						}
					}
				}

				if jeGFHMenu {
					this.VytvoritMenu(MenuStrankaTyp.Menu_GFH);
				} else {
					this.VytvoritMenu(MenuStrankaTyp.Menu_MenuLokace);
				}
			}
			if Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) {
				if StrCmp(data.Fakt, "") != 0 {
					let hodnotaFaktu: Int32 = this.questsSystem.GetFact(data.FaktPostavy());
					this.questsSystem.SetFact(data.FaktPostavy(), hodnotaFaktu == 0 ? 1 : 0);
				}

				this.VytvoritMenu(MenuStrankaTyp.Soucasne);
			}
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.VybratHudbu_Vybrat) {
			this.menuStrom.StrankovaniOp(1);
			let polozkaData: array<Int32> = this.JeVMenuZiskatData();

			if Equals(this.aktivniTypMenu, MenuUITyp.VyberHudby) {
				this.questsSystem.SetFact(Konstanty.FaktVybratHudbu(), polozkaData[0]);
				this.UkonceniMenu();
				return;
			} else {
				GlobalniFunkce.VlozitNastaveni(this.menuVybraneNastaveni, Konstanty.FaktVybratHudbu(), polozkaData[0]);
				this.VytvoritMenu(MenuStrankaTyp.ZpetStranka);
			}
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.MenuLokace_NastaveniPostav_Postava) || Equals(this.menuAkceTyp, MenuAkceTyp.MenuGFH_NastaveniPostavy) {
			this.menuStrom.StrankovaniOp(1);
			let polozkaData: array<Int32> = this.JeVMenuZiskatData();
			this.lokaceVyberPostavVybP = polozkaData[0];

			if Equals(this.menuAkceTyp, MenuAkceTyp.MenuGFH_NastaveniPostavy) {
				this.VytvoritMenu(MenuStrankaTyp.Menu_GFH_NastaveniPostavy);
			} else {
				this.VytvoritMenu(MenuStrankaTyp.Menu_MenuLokace_NastaveniPostav_Postava);
			}
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.MenuGFH_VybratPostavu) {
			this.menuStrom.StrankovaniOp(1);
			this.VytvoritMenu(MenuStrankaTyp.Menu_Pohlavi);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.NastaveniRuzne_Nastaveni) || Equals(this.menuAkceTyp, MenuAkceTyp.NastaveniRuzne_Nastaveni_Zpetne) {
			let data: DataNastaveni = this.ZiskatDataNastaveni(IntEnum(this.menuAkceData));

			let fakt: CName = data.FaktKeZmene;
			let hodnotaFaktu: Int32 = 0;
			if Equals(data.Typ, NastaveniTyp.Postava) {
				hodnotaFaktu = GlobalniFunkce.ZiskatNastaveni(this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].Nastaveni, fakt);
			} else if Equals(data.Typ, NastaveniTyp.Lokace) {
				hodnotaFaktu = GlobalniFunkce.ZiskatNastaveni(this.menuVybraneNastaveni, fakt);
			} else if Equals(data.Typ, NastaveniTyp.PV) {
				hodnotaFaktu = this.questsSystem.GetFact(StringToName(NameToString(fakt) + ToString(this.lokaceVyberPostavVybP)));
			} else {
				hodnotaFaktu = this.questsSystem.GetFact(fakt);
			}

			let vlastniMoznostiPocet: Int32 = ArraySize(data.VlastniMoznosti);
			if vlastniMoznostiPocet > 0 {
				if Equals(this.menuAkceTyp, MenuAkceTyp.NastaveniRuzne_Nastaveni) {
					hodnotaFaktu += 1;
				} else {
					hodnotaFaktu -= 1;
				}

				if hodnotaFaktu >= vlastniMoznostiPocet { hodnotaFaktu = 0; }
				if hodnotaFaktu < 0 { hodnotaFaktu = vlastniMoznostiPocet - 1; }
			} else {
				hodnotaFaktu = hodnotaFaktu == 0 ? 1 : 0;
			}
			
			if Equals(data.Typ, NastaveniTyp.Postava) {
				GlobalniFunkce.VlozitNastaveni(this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].Nastaveni, fakt, hodnotaFaktu);
			} else if Equals(data.Typ, NastaveniTyp.Lokace) {
				GlobalniFunkce.VlozitNastaveni(this.menuVybraneNastaveni, fakt, hodnotaFaktu);
			} else if Equals(data.Typ, NastaveniTyp.PV) {
				this.questsSystem.SetFact(StringToName(NameToString(fakt) + ToString(this.lokaceVyberPostavVybP)), hodnotaFaktu);
				this.questsSystem.SetFact(this.factUISel, 1);
			} else {
				this.questsSystem.SetFact(fakt, hodnotaFaktu);
			}

			if this.menuAkceData == EnumInt(GlobalniID.Nastaveni_Opt1) {
				this.NastavitAudio();
				this.TestAudio(0, hodnotaFaktu);
			}
			if this.menuAkceData == EnumInt(GlobalniID.Nastaveni_Opt33) {
				this.NastavitAudio();
				this.TestAudio(0, hodnotaFaktu);
			}
			if this.menuAkceData == EnumInt(GlobalniID.Nastaveni_Opt11) {
				this.NastavitAudio();
				this.TestAudio(1, hodnotaFaktu);
			}

			this.VytvoritMenu(MenuStrankaTyp.Soucasne);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.BarLokace_Lokace) {
			this.questsSystem.SetFact(this.factBarLoc, this.menuAkceData);
			this.UkonceniMenu();
			return;
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.PostavaMoznosti_Zkop) {
			this.postavaMoznostiOblicejZkop = !this.postavaMoznostiOblicejZkop;
			this.VytvoritMenu(MenuStrankaTyp.Soucasne);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.PostavaMoznosti_Postava) {
			this.VytvoritMenu(MenuStrankaTyp.Menu_PostavaMoznostiPostava);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.PostavaMoznostiPostava_Vzhled) {
			this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyVzhled() + ToString(this.lokaceVyberPostavVybP)), this.menuVybranaPostavaDocasna.Vzhled);

			this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].Vzhled = this.menuVybranaPostavaDocasna.Vzhled;
			this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].Nazev = this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].DataPostavy.ZiskatNazevPostavy(this.menuVybranaPostavaDocasna.Vzhled);

			this.menuAkceTyp = MenuAkceTyp.Globalni_KategorieNahoru;
			this.VybratPolozkuMenu();
			return;
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.PostavaMoznostiPostava_Oblicej_Klid) {
			this.VytvoritMenu(MenuStrankaTyp.Menu_PostavaMoznostiPostavaOblicejKlid);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.PostavaMoznostiPostava_Oblicej_Poza) {
			this.VytvoritMenu(MenuStrankaTyp.Menu_PostavaMoznostiPostavaOblicejPoza);
		}
		/*else if Equals(this.menuAkceTyp, MenuAkceTyp.PostavaMoznostiPostavaOblicejKlid_Klid) {
			this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyOblicejKlid() + ToString(this.lokaceVyberPostavVybP)), this.menuVybranaPostavaDocasna.Vzhled);

			this.menuAkceTyp = MenuAkceTyp.Globalni_KategorieNahoru;
			this.VybratPolozkuMenu();
			return;
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.PostavaMoznostiPostavaOblicejPoza_Poza) {
			this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyOblicejPoza() + ToString(this.lokaceVyberPostavVybP)), this.menuVybranaPostavaDocasna.Vzhled);

			this.menuAkceTyp = MenuAkceTyp.Globalni_KategorieNahoru;
			this.VybratPolozkuMenu();
			return;
		}*/
		else if Equals(this.menuAkceTyp, MenuAkceTyp.Globalni_DalsiStranka) {
			this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Resetovat);
			if this.menuStrom.StrankovaniOp(2) > (this.maximalniPocetStranek - 1) { this.menuStrom.StrankovaniOp(1); }
			this.VytvoritMenu(MenuStrankaTyp.Soucasne);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.Globalni_PredchoziStranka) {
			this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Resetovat);
			if this.menuStrom.StrankovaniOp(3) < 0 { this.menuStrom.StrankovaniOp(4, this.maximalniPocetStranek - 1); }
			this.VytvoritMenu(MenuStrankaTyp.Soucasne);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.Postava_Kateg) {
			this.VytvoritMenu(IntEnum(this.menuAkceData), this.menuVybranaPostavaDocasna.Vlastni);
			this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Resetovat);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.Globalni_KategorieNahoru) {
			this.menuStrom.StrankovaniOp(1);
			this.VytvoritMenu(MenuStrankaTyp.ZpetStranka);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.Postava_Vzhledy) {
			this.VytvoritMenu(MenuStrankaTyp.Menu_PostavaVzhledy);
			this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Resetovat);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.Globalni_Ukonceni) {
			if Equals(this.aktivniTypMenu, MenuUITyp.BarVyberLokace) { this.questsSystem.SetFact(this.factBarLoc, 0); }

			if Equals(this.aktivniTypMenu, MenuUITyp.PostavaMoznosti) && this.postavaMoznostiOblicejZkop {
				let fKlid: Int32 = this.questsSystem.GetFact(StringToName(Konstanty.FaktVybranyOblicejKlid() + "0"));
				let fPoza: Int32 = this.questsSystem.GetFact(StringToName(Konstanty.FaktVybranyOblicejPoza() + "0"));
				let fKlidVaha: Int32 = this.questsSystem.GetFact(StringToName(Konstanty.FaktVybranyOblicejKlidVaha() + "0"));
				let fPozaVaha: Int32 = this.questsSystem.GetFact(StringToName(Konstanty.FaktVybranyOblicejPozaVaha() + "0"));

				let i = 1;
				while i < ArraySize(this.menuVybranaPostavaPole) || i < 1 {
					this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyOblicejKlid() + ToString(i)), fKlid);
					this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyOblicejPoza() + ToString(i)), fPoza);
					this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyOblicejKlidVaha() + ToString(i)), fKlidVaha);
					this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyOblicejPozaVaha() + ToString(i)), fPozaVaha);
					
					i += 1;
				}
			}

			if this.questsSystem.GetFact(n"lizzies_bds_active") == 0 && this.questsSystem.GetFact(n"lizzies_bds_er_active") == 0 {
				this.ResetovatFakta();
			}

			this.UkonceniMenu();
			return;
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.HlavniRecepce_Sluzba) {
			this.questsSystem.SetFact(this.factStreaming, this.questsSystem.GetFact(this.factStreaming) == 0 ? 1 : 0);
			this.VytvoritMenu(MenuStrankaTyp.Soucasne);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.HlavniRecepce_SoukromePV) {
			if this.questsSystem.GetFact(Konstanty.FaktSoukromePV()) == 1 {
				this.VytvoritMenu(MenuStrankaTyp.Soucasne);
			} else {
				this.VytvoritMenu(MenuStrankaTyp.Menu_HlavniRecepceSoukromePV);
			}
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.HlavniRecepceSoukromePV_Lokace) {
			let polozkaData: array<Int32> = this.JeVMenuZiskatData();

			if this.SoukromePVAktivace(polozkaData[0], GlobalniID.Lokace_Hangout_Priv_Megabuilding, Konstanty.FaktSoukromePVMegabuilding()) { return; }
			if this.SoukromePVAktivace(polozkaData[0], GlobalniID.Lokace_Hangout_Priv_Downtown, Konstanty.FaktSoukromePVDowntown()) { return; }
			if this.SoukromePVAktivace(polozkaData[0], GlobalniID.Lokace_Hangout_Priv_Heywood, Konstanty.FaktSoukromePVHeywood()) { return; }
			if this.SoukromePVAktivace(polozkaData[0], GlobalniID.Lokace_Hangout_Priv_Japantown, Konstanty.FaktSoukromePVJapantown()) { return; }
			if this.SoukromePVAktivace(polozkaData[0], GlobalniID.Lokace_Hangout_Priv_Northside, Konstanty.FaktSoukromePVNorthside()) { return; }
			if this.SoukromePVAktivace(polozkaData[0], GlobalniID.Lokace_Hangout_Priv_EdenPlaza, Konstanty.FaktSoukromePVEdenPlaza()) { return; }
			if this.SoukromePVAktivace(polozkaData[0], GlobalniID.Lokace_Hangout_Priv_SantoSerenity, Konstanty.FaktSoukromePVSantoSerenity()) { return; }

			this.VytvoritMenu(MenuStrankaTyp.Soucasne);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.HlavniRecepce_ER) {
			if this.OveritPenizeAOdecist(5000) {
				this.questsSystem.SetFact(this.factER, 1);
				this.UkonceniMenu();
				return;
			}
			this.VytvoritMenu(MenuStrankaTyp.Soucasne);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.Hlavni_Oblibene) {
			this.VytvoritMenu(MenuStrankaTyp.Menu_Oblibene);
			this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Resetovat);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.Hlavni_Nastaveni) {
			this.VytvoritMenu(MenuStrankaTyp.Menu_KatalogNastaveni);
			this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Resetovat);
		}
		else if Equals(this.menuAkceTyp, MenuAkceTyp.Globalni_ZpetDoMenu) {
			this.menuStrom.Vycistit();

			if Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) {
				this.VytvoritMenu(MenuStrankaTyp.Menu_NastaveniPostavy);
			} else {
				this.VybratLokaci(GlobalniID.Prazdne);
				this.VytvoritMenu(MenuStrankaTyp.Menu_Hlavni);
			}

			//GlobalniFunkce.VlozitNastaveni(this.menuVybraneNastaveni, this.factClipCount, 0);
			this.SestavitNastaveniLokace(false, null);

			this.menuLokaceAktivni = false;
			this.lokaceVyberPostavVybP = 0;

			let a: ref<VybranaPostava> = new VybranaPostava();
			this.menuVybranaPostavaDocasna = a;

			this.NastavitVybranePostavyPole(0);
		}

		this.menuAkceTyp = MenuAkceTyp.Prazdne;
		this.menuAkceData = 0;

		this.ZvyraznitPolozkuMenu();
	}

	private final func SoukromePVAktivace(vybLokace: Int32, lokace: GlobalniID, fakt: CName) -> Bool {
		if vybLokace == EnumInt(lokace) {
			if this.questsSystem.GetFact(fakt) != 2 {
				if this.OveritPenizeAOdecist(20000) {
					this.questsSystem.SetFact(Konstanty.FaktSoukromePV(), 1);
					this.questsSystem.SetFact(fakt, 1);

					this.UkonceniMenu();
					return true;
				}
			}
		}

		return false;
	}

	private final func ResetovatFakta() -> Void {
		let i = 0;
		while i < 6 {
			let faktPostava: CName = StringToName(Konstanty.FaktVybranaPostava() + ToString(i));
			let faktPostavaVlastni: CName = StringToName(Konstanty.FaktVybranaPostavaVlastni() + ToString(i));
			let faktPostavaVzhled: CName = StringToName(Konstanty.FaktVybranyVzhled() + ToString(i));
			
			this.questsSystem.SetFact(faktPostava, 0);
			this.questsSystem.SetFact(faktPostavaVlastni, 0);
			this.questsSystem.SetFact(faktPostavaVzhled, 0);

			let nastaveni: array<DataNastaveni> = DataPoleNastaveniPostavy(false, false, false, false);
			for n in nastaveni {
				this.questsSystem.SetFact(StringToName(NameToString(n.FaktKeZmene) + "_" + ToString(i)), 0);
			}

			i += 1;
		}

		//this.SestavitNastaveniLokace(true, null);
	}

	private final func SestavitNastaveniLokace(resetovat: Bool, lokace: ref<DataLokace>) -> Void {
		let zachovatNastaveni: Bool = this.questsSystem.GetFact(Konstanty.FaktNastaveniZachovatNst()) == 0;

		this.menuVybraneNastaveni = [];
		let o: Int32 = 0;
		if IsDefined(lokace) {
			if lokace.PodporujeOpakovani {
				o = zachovatNastaveni ? this.questsSystem.GetFact(this.factClipCount) : 0;
			}
		}
		GlobalniFunkce.VlozitNastaveni(this.menuVybraneNastaveni, this.factClipCount, o);

		/*if zachovatNastaveni {
			GlobalniFunkce.VlozitNastaveni(this.menuVybraneNastaveni, Konstanty.FaktVybratHudbu(), this.questsSystem.GetFact(Konstanty.FaktVybratHudbu()));
		} else {
			GlobalniFunkce.VlozitNastaveni(this.menuVybraneNastaveni, Konstanty.FaktVybratHudbu(), vybHudba);
		}*/
		GlobalniFunkce.VlozitNastaveni(this.menuVybraneNastaveni, Konstanty.FaktVybratHudbu(), IsDefined(lokace) ? lokace.VychoziHudba : 0);
		
		let nastaveniLokace: array<DataNastaveni> = DataPoleNastaveniLokace(true, true, true, [], IsDefined(lokace) ? lokace.PodporujeReplacer : false);
		for n in nastaveniLokace {
			GlobalniFunkce.VlozitNastaveni(this.menuVybraneNastaveni, n.FaktKeZmene, zachovatNastaveni && n.FaktZobrazeni ? this.questsSystem.GetFact(n.FaktKeZmene) : 0);
		}
	}

	private final func NastavitPohlaviPodleLokace() -> Void {
		let tmpLokace: ref<DataLokace> = this.ZiskatVybranouLokaci();
		let zobrazitPohlavi: Int32 = this.questsSystem.GetFact(Konstanty.FaktZobrazitPohlavi());
		if zobrazitPohlavi == 0 {
			this.vybranePohlavi = tmpLokace.PouzeProPohlavi;
			if Equals(this.vybranePohlavi, GenderType.None) { this.vybranePohlavi = GenderType.Female; }
		}
		else if zobrazitPohlavi == 1 { this.vybranePohlavi = GenderType.Male; }
		else if zobrazitPohlavi == 2 { this.vybranePohlavi = GenderType.Female; }
	}

	private final func OtevritKatalogPostav() -> Void {
		let gid: MenuStrankaTyp = MenuStrankaTyp.Prazdne;

		if Equals(this.vybranePohlavi, GenderType.Female) {
			gid = this.pouzeMox ? MenuStrankaTyp.Menu_ZenyPouzeMox : MenuStrankaTyp.Menu_Zeny;
		}
		else if Equals(this.vybranePohlavi, GenderType.Male) {
			gid = this.pouzeMox ? MenuStrankaTyp.Menu_MuziPouzeMox : MenuStrankaTyp.Menu_Muzi;
		}

		this.VytvoritMenu(gid);
		this.menuStrom.VyberPolozkyVMenu(MenuStromPolozkaVybranaAkce.Resetovat);
	}

	private final func NastavitVybranePostavyPole(pocet: Int32) -> Void {
		ArrayResize(this.menuVybranaPostavaPole, pocet);

		let i = 0;
		while i < pocet {
			let a: ref<VybranaPostava> = new VybranaPostava();
			a.PostavaVybrana = false;
			this.menuVybranaPostavaPole[i] = a;
			i += 1;
		}
		
		let a: ref<VybranaPostava> = new VybranaPostava();
		this.menuVybranaPostavaDocasna = a;
	}

	private final func UkonceniMenu() -> Void {
		if Equals(this.aktivniTypMenu, MenuUITyp.KoupeniPV) || Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
			this.KoupeneKazety();
		}

		this.questsSystem.SetFact(Konstanty.FaktMenuUI(), 0);
	}

	private final func ZpracovatCenu(postavy: array<ref<VybranaPostava>>, vybraneOpakovani: Int32, vybranaLokace: Int32) -> Bool {
		if Equals(this.aktivniTypMenu, MenuUITyp.Pevecka) || Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) { return true; }
	
		let cena: Int32 = 0;
	
		let i = 0;
		while i < ArraySize(postavy) {
			if postavy[i].PostavaVybrana {
				cena = cena + postavy[i].DataPostavy.Cena;
			}
			i += 1;
		}
	
		let data: ref<DataLokace> = this.ZiskatDataLokace(vybranaLokace);
		if data.PodporujeOpakovani && NotEquals(this.aktivniTypMenu, MenuUITyp.KoupeniPV) {
			if vybraneOpakovani == 1 { cena = cena + 50; }
			if vybraneOpakovani == 2 { cena = cena + 100; }
		}
		if data.BezPostavy {
			cena += data.Cena;
		}

		return this.OveritPenizeAOdecist(cena);
	}

	private final func ZpracovatCenu(pData: ref<DataPostavy>, vybraneOpakovani: Int32, vybranaLokace: Int32) -> Bool {
		if Equals(this.aktivniTypMenu, MenuUITyp.Pevecka) || Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) { return true; }
		
		let cena: Int32 = pData.Cena;

		let data: ref<DataLokace> = this.ZiskatDataLokace(vybranaLokace);
		if data.PodporujeOpakovani {
			if vybraneOpakovani == 1 { cena = cena + 50; }
			if vybraneOpakovani == 2 { cena = cena + 100; }
		}
		if data.BezPostavy {
			cena = data.Cena;
		}

		return this.OveritPenizeAOdecist(cena);
	}

	private final func OveritPenizeAOdecist(cena: Int32) -> Bool {
		if this.hracPenize < cena {
			let notif = new UIInGameNotificationEvent();
			notif.m_title = "LocKey#54029";
			notif.m_notificationType = UIInGameNotificationType.GenericNotification;
			this.uiSystem.QueueEvent(notif);
			return false;
		}

		let transSystem: wref<TransactionSystem> = GameInstance.GetTransactionSystem(this.game);
		transSystem.RemoveMoney(this.player, cena, n"money");

		return true;
	}

	private final func NastavitAudio() -> Void {
		let faktHodVol1: Int32 = this.questsSystem.GetFact(Konstanty.FaktAudioHlasitost());
		this.audioSystem.GlobalParameter(n"lizzies_bds_perf_volume", Cast<Float>(faktHodVol1));

		let faktHodVol2: Int32 = this.questsSystem.GetFact(Konstanty.FaktAudioHlasitost2());
		this.audioSystem.GlobalParameter(n"lizzies_bds_perf2_volume", Cast<Float>(faktHodVol2));
	}

	private final func TestAudio(typ: Int32, hodnota: Int32) -> Void {
		GlobalniFunkce.NastavitMoaning(this.game, this.player.GetEntityID(), this.menuVybranaPostavaPole[this.lokaceVyberPostavVybP].DataPostavy.Pohlavi, 0, true, hodnota);

		if typ == 0 {
			this.audioSystem.Play(n"lizzies_bds_moaning_open_long", this.player.GetEntityID());
		}
		if typ == 1 {
			this.audioSystem.Play(n"lizzies_bds_q108_alt_vo_01", this.player.GetEntityID());
		}
	}

	private final func DynamickyNahled(data: ref<DataPostavy>, vybranyVzhled: Int32) -> Void {
		if !data.JeKateg && Equals(data.Vzhledy[vybranyVzhled].ObrAtlasID, InkAtlasSoubor.DynamickyNahled) {
			GameInstance.GetDelaySystem(this.game).CancelDelay(this.dynamickyNahledProdleva);

			let callback = new DynPrewListenerCallback();
			callback.questsSystem = this.questsSystem;
			this.dynamickyNahledProdleva = GameInstance.GetDelaySystem(this.game).DelayCallback(callback, 0.1, false);

			this.NastavitDB(data, vybranyVzhled, 100);

			this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranaPostava() + ToString(100)), EnumInt(data.GlobalniID));
			this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranaPostavaVlastni() + ToString(100)), data.CustomID);
			this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyVzhled() + ToString(100)), vybranyVzhled);
			this.questsSystem.SetFact(StringToName(Konstanty.FaktVybranyVelke() + ToString(100)), data.VelkaPostava ? 1 : 0);
		}
	}

	private final func NastavitDB(data: ref<DataPostavy>, vybranyVzhled: Int32, vybranyP: Int32) -> Void {
		let cestaKEnt: ResRef;

		if Equals(GlobalniID.Postava_Vlastni_Zena, data.GlobalniID) || Equals(GlobalniID.Postava_Vlastni_Muz, data.GlobalniID) {
			let poleVlastnichPostav: array<ref<DataPostavy>> = this.lizziesBDsSystem.VlastniPostavy();
			let i = 0;
			while i < ArraySize(poleVlastnichPostav) {
				if data.CustomID == poleVlastnichPostav[i].CustomID { cestaKEnt = poleVlastnichPostav[i].VlastniPostavaEnt; }
				i += 1;
			}
		}
		else {
			cestaKEnt = DataEntit(data.GlobalniID, vybranyVzhled, data.Pohlavi);
		}

		let dbPostavaZaklad: TweakDBID = t"LizziesBDs_Performer_Base";

		if Equals(GlobalniID.Postava_Female_V, data.GlobalniID) {
			dbPostavaZaklad = t"Character.TPP_Player_Cutscene_Female";
		}
		else if Equals(GlobalniID.Postava_Male_V, data.GlobalniID) {
			dbPostavaZaklad = t"Character.TPP_Player_Cutscene_Male";
		}

		let sf: TweakDBID = t"";
		if vybranyP == 1 { sf = t"_2"; }
		if vybranyP == 2 { sf = t"_3"; }
		if vybranyP == 3 { sf = t"_4"; }
		if vybranyP == 4 { sf = t"_5"; }
		if vybranyP == 5 { sf = t"_6"; }
		if vybranyP == 100 { sf = t"_Preview"; }

		let dbPostava: TweakDBID = t"Character.LizziesBDs_Performer" + sf;
		let jmeno: CName = StringToName(data.Vzhledy[0].Nazev);

		TweakDBManager.SetFlat(dbPostava + t".appearanceName", TweakDBInterface.GetFlat(dbPostavaZaklad + t".appearanceName"));
		TweakDBManager.SetFlat(dbPostava + t".genders", TweakDBInterface.GetFlat(dbPostavaZaklad + t".genders"));
		TweakDBManager.SetFlat(dbPostava + t".baseAttitudeGroup", TweakDBInterface.GetFlat(dbPostavaZaklad + t".baseAttitudeGroup"));
		TweakDBManager.SetFlat(dbPostava + t".priority", TweakDBInterface.GetFlat(dbPostavaZaklad + t".priority"));
		TweakDBManager.SetFlat(dbPostava + t".quest", TweakDBInterface.GetFlat(dbPostavaZaklad + t".quest"));
		TweakDBManager.SetFlat(dbPostava + t".attachmentSlots", TweakDBInterface.GetFlat(dbPostavaZaklad + t".attachmentSlots")); // kvuli Equipment-EX

		TweakDBManager.SetFlat(dbPostava + t".displayName", jmeno);
		TweakDBManager.SetFlat(dbPostava + t".fullDisplayName", jmeno);
		TweakDBManager.SetFlat(dbPostava + t".entityTemplatePath", cestaKEnt);

		TweakDBManager.UpdateRecord(dbPostava);

		// kvuli Equipment-EX
		if vybranyP == 0 && Equals(this.aktivniTypMenu, MenuUITyp.Pevecka) {
			let pz: TweakDBID = t"Character.TPP_Player_Cutscene_Female";
			let pc: TweakDBID = pz + t"_LizziesBDs";

			TweakDBManager.SetFlat(pc + t".attachmentSlots", TweakDBInterface.GetFlat(pz + t".attachmentSlots"));
			TweakDBManager.UpdateRecord(pc);

			pz = t"Character.TPP_Player_Cutscene_Male";
			pc = pz + t"_LizziesBDs";

			TweakDBManager.SetFlat(pc + t".attachmentSlots", TweakDBInterface.GetFlat(pz + t".attachmentSlots"));
			TweakDBManager.UpdateRecord(pc);
		}
	}

	private final func ZhaveDnesOD(data: ref<DataPostavy>, lokace: Int32) -> Void {
		if NotEquals(GlobalniID.Postava_Vlastni_Muz, data.GlobalniID) && NotEquals(GlobalniID.Postava_Vlastni_Zena, data.GlobalniID) {
			this.lizziesBDsOnline.OdeslatData(EnumInt(data.GlobalniID), lokace);
		}
	}

	private final func PridatZnovuKoupit() -> Void {
		if Equals(this.aktivniTypMenu, MenuUITyp.KoupeniPV) || Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
			return;
		}

		let ulozeno: array<ref<LizziesBDsUlozistePolozkaV5>> = this.lizziesBDsUloziste.VratitPoleDat(UlozisteTyp.SledovatZnovu);
		if ArraySize(ulozeno) > 0 {
			let index: Int32 = Equals(this.aktivniTypMenu, MenuUITyp.Pevecka) ? 1 : 0;
			let pocet: Int32 = ArraySize(ulozeno[index].Postavy);

			let pole: array<ref<VybranaPostava>> = [];
			ArrayResize(pole, pocet);

			let i = 0;
			while i < pocet {
				let a: ref<VybranaPostava> = new VybranaPostava();
				pole[i] = a;
				i += 1;
			}

			let validni: Bool = true;
			let validni2: Bool = false;

			let j = 0;
			while j < pocet {
				if NotEquals(ulozeno[index].Postavy[j].PostavaGID, GlobalniID.Prazdne) {
					pole[j] = ulozeno[index].Postavy[j].NovaInstance();

					let postava: ref<DataPostavy> = this.ZiskatDataPostav(ulozeno[index].Postavy[j]);
					if !IsDefined(postava) {
						validni = false;
					} else {
						validni2 = true;
					}
				}

				j += 1;
			}

			if validni2 && validni {
				let oblibene: Bool = this.lizziesBDsUloziste.JeVUlozisti(UlozisteTyp.Oblibene, ulozeno[index].LokaceID, [], pole) != -1;

				this.PridatMoznostInterni(MenuAkceTyp.__Ulozeno, [EnumInt(UlozisteTyp.SledovatZnovu), -1], GetLocalizedText("LocKey#15142087"), "", true, 0, false, true, 0, 0, oblibene, 0, 0);
			}
		}
	}

	private final func ZobrazitSpecTlac(zobrazit: Bool) -> Void {
		if zobrazit {
			let favNavCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/TooltipPages/FavoriteTooltipText") as inkText;

			if Equals(this.specialniTlacitkoAkce, SpecTlacAkce.NastaveniZpetne) {
				favNavCtrl.SetText(GetLocalizedText("LocKey#15144096"));
			}
			else if Equals(this.specialniTlacitkoAkce, SpecTlacAkce.OblibenePridat) {
				favNavCtrl.SetText(GetLocalizedText("LocKey#15144067"));
			}
			else if Equals(this.specialniTlacitkoAkce, SpecTlacAkce.OblibeneOdstranit) {
				if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
					favNavCtrl.SetText(GetLocalizedText("LocKey#15142166"));
				} else {
					favNavCtrl.SetText(GetLocalizedText("LocKey#15144104"));
				}
			}
			else if Equals(this.specialniTlacitkoAkce, SpecTlacAkce.NahledHudby) {
				favNavCtrl.SetText(GetLocalizedText("LocKey#15144115"));
			}

			if !this.specialniTlacitko {
				this.PlayLibraryAnimation(n"show_favorite");
				this.specialniTlacitko = true;
			}
		} else {
			if this.specialniTlacitko {
				this.PlayLibraryAnimation(n"hide_favorite");
				this.specialniTlacitko = false;
			}
		}
	}

	private final func OblibeneOp(akce: Int32) -> Bool {
		if this.menuLokaceAktivni {
			return false;
		}

		if akce == 0 {
			this.oblibeneVybraneID = -1;
		}

		if Equals(this.aktivniTypMenu, MenuUITyp.Nastaveni) || Equals(this.aktivniTypMenu, MenuUITyp.PostavaMoznosti) || this.pozvaniDoBytuAktivni {
			return false;
		}

		let uloziste: UlozisteTyp;
		if Equals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
			uloziste = UlozisteTyp.Koupeno;
		} else {
			uloziste = UlozisteTyp.Oblibene;
		}

		if akce == 1 || akce == 2 || akce == 3 {
			let pole: array<ref<VybranaPostava>> = this.menuVybranaPostavaPole;
			let tmpLokace: ref<DataLokace> = this.ZiskatVybranouLokaci();

			if akce == 1 {
				this.oblibeneVybraneID = this.lizziesBDsUloziste.JeVUlozisti(uloziste, EnumInt(tmpLokace.GlobalniID), [], pole);
				if this.oblibeneVybraneID != -1 {
					this.specialniTlacitkoAkce = SpecTlacAkce.OblibeneOdstranit;
				} else {
					this.specialniTlacitkoAkce = SpecTlacAkce.OblibenePridat;
				}

				this.ZobrazitSpecTlac(true);
			}

			if akce == 2 {
				if Equals(this.specialniTlacitkoAkce, SpecTlacAkce.OblibenePridat) {
					this.lizziesBDsUloziste.Pridat(uloziste, EnumInt(tmpLokace.GlobalniID), this.menuVybraneNastaveni, pole);
				}
				if Equals(this.specialniTlacitkoAkce, SpecTlacAkce.OblibeneOdstranit) {
					this.lizziesBDsUloziste.SmazatID(uloziste, this.oblibeneVybraneID);
				}
			}

			if akce == 3 {
				return this.lizziesBDsUloziste.JeVUlozisti(uloziste, EnumInt(tmpLokace.GlobalniID), [], pole) != -1;
			}
		}

		return true;
	}

	private final func VybraneOpakovaniText(hodnota: Int32, tucnyText: Bool) -> String {
		let opakovani: String = "";

		if hodnota == 0 { opakovani = GetLocalizedText("LocKey#15144016"); }
		if hodnota == 1 { opakovani = GetLocalizedText("LocKey#15144017"); }
		if hodnota == 2 { opakovani = GetLocalizedText("LocKey#15144018"); }

		return (tucnyText ? "<Rich style=\"Bold\">" : "") + GetLocalizedText("LocKey#15142049") + (tucnyText ? "</>" : "") + ": " + opakovani;
	}

	private final func VybraneOpakovaniCena(hodnota: Int32) -> Int32 {
		let cena: Int32 = 0;

		if NotEquals(this.aktivniTypMenu, MenuUITyp.KoupeniPV) && NotEquals(this.aktivniTypMenu, MenuUITyp.Pevecka) && NotEquals(this.aktivniTypMenu, MenuUITyp.PVKdekoliv) {
			if hodnota == 1 { cena = 50; }
			if hodnota == 2 { cena = 100; }
		}

		return cena;
	}

	private final func VybratLokaci(gID: GlobalniID) -> Void {
		if Equals(gID, GlobalniID.Prazdne) {
			this.PlayLibraryAnimation(n"hide_sel_loc");
		} else {
			this.PlayLibraryAnimation(n"show_sel_loc");
		}

		let selLocTextCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/selected_location") as inkText;
		let selLoc: String = s"<Rich style=\"Bold\">\(GetLocalizedText("LocKey#15142066")):</>\n";

		if NotEquals(gID, GlobalniID.Prazdne) {
			selLoc = selLoc + this.menuVybranaLokace.Nazev;
		}

		selLocTextCtrl.SetText(selLoc);
	}

	private final func ZobrazitNastaveniBinarniData() -> Void {
		let selLocTextCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/selected_location") as inkText;
		let selLoc: String = s"<Rich style=\"Bold\">\(GetLocalizedText("LocKey#15144025")):</>\n\n";

		let pocetPolozekVMenu: Int32 = ArraySize(this.polePolozkyMenu);
		this.nastaveniBinarniZobrazeni = this.decimalToHex(pocetPolozekVMenu, true, true) + this.nastaveniBinarniZobrazeni;

		let i: Int32 = 0;
		let i2: Int32 = 0;
		let delkaTextu: Int32 = StrLen(this.nastaveniBinarniZobrazeni);
		while i < delkaTextu {
			selLoc = selLoc + this.decimalToHex(i2, false, false) + ": <Rich style=\"Bold\">" + StrMid(this.nastaveniBinarniZobrazeni, i, 24) + "</>\n";
			i += 24;
			i2 += 8;
		}

		selLocTextCtrl.SetText(selLoc);
	}

	private final func ZobrazitDefaultniText() -> Void {
		this.NastavitDataTextu("", GetLocalizedText("LocKey#15142057"));
	}

	private final func ZobrazitRecepci() -> Void {
		let text: String = "";
		text = text + s"\(GetLocalizedTextGanderDepened("LocKey#15142051", this.questsSystem.GetFact(this.factPlayerGender) == 2))\n";
		text = text + s"<Rich style=\"Bold\">\(GetLocalizedText("LocKey#15142052")):</> \(this.questsSystem.GetFact(this.factViews))\n";

		text = text + s"<Rich style=\"Bold\">\(GetLocalizedText("LocKey#15142043")):</> ";
		if this.questsSystem.GetFact(this.factStreaming) == 1 {
			text = text + s"<Rich color=\"#00ff00\">\(GetLocalizedText("LocKey#15142054"))</>";
		} else {
			text = text + s"<Rich color=\"#ff0000\">\(GetLocalizedText("LocKey#15142055"))</>";
		}

		text = text + "\n\n";

		text = text + s"\(GetLocalizedText("LocKey#15142053"))\n\n";

		text = text + s"<Rich style=\"Bold\">\(GetLocalizedText("LocKey#15142043"))</>\n";
		text = text + s"\(GetLocalizedText("LocKey#15142069"))\n\n";

		text = text + s"<Rich style=\"Bold\">\(GetLocalizedText("LocKey#15142070"))</>\n";
		text = text + s"\(GetLocalizedText("LocKey#15142071"))\n\n";

		text = text + s"<Rich style=\"Bold\">\(GetLocalizedText("LocKey#15142101"))</>\n";
		text = text + s"\(GetLocalizedText("LocKey#15142102"))\n";
		text = text + Prekladatele();

		this.NastavitDataTextu("", text);
	}

	private final func NastavitViditelnostPodleNazvu(picCtrlName: String, visib: Bool) -> Void {
		let picCtrl: ref<inkWidget> = this.GetChildWidgetByPath(StringToName("main_ui/main_container/" + picCtrlName)) as inkWidget;
		picCtrl.SetOpacity(visib ? 1.0 : 0.0);
		picCtrl.SetVisible(visib);
		
		if visib && this.mensiVerzeMenu {
			if StrCmp(picCtrlName, "character_custom") == 0 || StrCmp(picCtrlName, "character") == 0 {
				this.NastavitMensiVerzi(1);
			}
		}
	}

	private final func NastavitObrazek(ctrl: ref<inkImage>, atlas: InkAtlasSoubor, texture: CName, meritko: Float, opt atlasCesta: ResRef) -> Void {
		if Equals(atlas, InkAtlasSoubor.Prazdne) {
			ctrl.SetAtlasResource(atlasCesta);
		} else {
			ctrl.SetAtlasResource(DataInkAtlas(atlas));
		}
		ctrl.SetTexturePart(texture);
		if meritko > 0.0 {
			ctrl.SetScale(new Vector2(meritko, meritko));
		}
	}

	private final func NastavitDataPostavyVlastniObrazek(name: String, desc: String, atlas: InkAtlasSoubor, atlasCesta: ResRef, texture: CName, author: String, meritko: Float) -> Void {
		let nameCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/character_custom/nameTxt") as inkText;
		nameCtrl.SetText(name);

		let picCtrl: ref<inkImage> = this.GetChildWidgetByPath(n"main_ui/main_container/character_custom/loc") as inkImage;
		this.NastavitObrazek(picCtrl, atlas, texture, meritko, atlasCesta);
		GlobalniFunkce.PostavaModObrazek(picCtrl, atlas, 1);

		let descCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/character_custom/descTxt") as inkText;
		descCtrl.SetText(desc);

		let authorCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/character_custom/author") as inkText;
		if StrCmp(author, "") == 0 {
			authorCtrl.SetText("");
		} else {
			authorCtrl.SetText(s"<Rich style=\"Bold\">\(GetLocalizedText("LocKey#15142067"))</>\n" + author);
		}

		this.NastavitViditelnostPodleNazvu("character_custom", true);
	}

	private final func NastavitDataPostavy(name: String, atlas: InkAtlasSoubor, texture: CName, author: String, meritko: Float) -> Void {
		let nameCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/character/nameTxt") as inkText;
		nameCtrl.SetText(name);

		let picCtrl: ref<inkImage> = this.GetChildWidgetByPath(n"main_ui/main_container/character/loc") as inkImage;
		this.NastavitObrazek(picCtrl, atlas, texture, meritko);
		GlobalniFunkce.PostavaModObrazek(picCtrl, atlas, 2);

		let authorCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/character/author") as inkText;
		if StrCmp(author, "") == 0 {
			authorCtrl.SetText("");
		} else {
			authorCtrl.SetText(s"<Rich style=\"Bold\">\(GetLocalizedText("LocKey#15142067"))</>\n" + author);
		}

		this.NastavitViditelnostPodleNazvu("character", true);
	}

	private final func NastavitDataLokace(name: String, desc: String, texture: CName, atlas: InkAtlasSoubor) -> Void {
		let nameCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/location/nameTxt") as inkText;
		nameCtrl.SetText(name);

		let descCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/location/descTxt") as inkText;
		descCtrl.SetText(desc);

		let picCtrl: ref<inkImage> = this.GetChildWidgetByPath(n"main_ui/main_container/location/loc") as inkImage;
		this.NastavitObrazek(picCtrl, atlas, texture, 0);

		if GlobalniFunkce.LokaceVelkyObrazek(atlas) {
			//picCtrl.SetMargin(new inkMargin(0.0, 640.0, 0.0, 80.0));
			picCtrl.SetSize(new Vector2(800.0, 800.0));
			descCtrl.SetMargin(new inkMargin(640.0, 900.0, 0.0, 0.0));
		} else {
			//picCtrl.SetMargin(new inkMargin(0.0, 640.0, 0.0, 80.0));
			if GlobalniFunkce.LokaceBarObrazekPuvodni(atlas) {
				picCtrl.SetSize(new Vector2(1000.0, 327.0));
				descCtrl.SetMargin(new inkMargin(640.0, 427.0, 0.0, 0.0));
			} else {
				picCtrl.SetSize(new Vector2(1000.0, 420.0));
				descCtrl.SetMargin(new inkMargin(640.0, 520.0, 0.0, 0.0));
			}
		}

		this.NastavitViditelnostPodleNazvu("location", true);
	}

	private final func NastavitDataTextu(name: String, desc: String, opt autor: String) -> Void {
		let nameCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/text/nameTxt") as inkText;
		nameCtrl.SetText(name);

		let descCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/text/descTxt") as inkText;
		descCtrl.SetText(desc);

		let authorCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/text/author") as inkText;
		if StrCmp(autor, "") == 0 {
			authorCtrl.SetText("");
		} else {
			authorCtrl.SetText(s"<Rich style=\"Bold\">\(GetLocalizedText("LocKey#15142067"))</>\n" + autor);
		}

		this.NastavitViditelnostPodleNazvu("text", true);
	}

	private final func OnlineFunkcePridatText() -> Void {
		let ctrl: ref<inkCanvas> = this.GetChildWidgetByPath(n"main_ui/main_container/text") as inkCanvas;

		let ctrl01: ref<inkRichTextBox> = new inkRichTextBox();
		ctrl01.SetName(n"descTxt_tbl01");
		ctrl01.SetText("");
		ctrl01.SetMargin(new inkMargin(270, 80, 0.0, 0));
		ctrl01.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
		ctrl01.SetFontSize(28);
		ctrl01.SetFontStyle(n"Regular");
		ctrl01.SetAnchorPoint(new Vector2(0.5, 0));
		ctrl01.SetAnchor(inkEAnchor.TopCenter);
		ctrl01.SetVerticalAlignment(textVerticalAlignment.Top);
		ctrl01.SetFitToContent(false);
		ctrl01.SetSize(new Vector2(400, 1300));
		ctrl01.textOverflowPolicy = textOverflowPolicy.DotsEnd;
		ctrl01.Reparent(ctrl);

		let ctrl02: ref<inkRichTextBox> = new inkRichTextBox();
		ctrl02.SetName(n"descTxt_tbl02");
		ctrl02.SetText("");
		ctrl02.SetMargin(new inkMargin(620, 80, 0.0, 0));
		ctrl02.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
		ctrl02.SetFontSize(28);
		ctrl02.SetFontStyle(n"Regular");
		ctrl02.SetAnchorPoint(new Vector2(0.5, 0));
		ctrl02.SetAnchor(inkEAnchor.TopCenter);
		ctrl02.SetVerticalAlignment(textVerticalAlignment.Top);
		ctrl02.SetFitToContent(false);
		ctrl02.SetSize(new Vector2(275, 1300));
		ctrl02.Reparent(ctrl);

		let ctrl03: ref<inkRichTextBox> = new inkRichTextBox();
		ctrl03.SetName(n"descTxt_tbl03");
		ctrl03.SetText("");
		ctrl03.SetMargin(new inkMargin(860, 80, 0.0, 0));
		ctrl03.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
		ctrl03.SetFontSize(28);
		ctrl03.SetFontStyle(n"Regular");
		ctrl03.SetAnchorPoint(new Vector2(0.5, 0));
		ctrl03.SetAnchor(inkEAnchor.TopCenter);
		ctrl03.SetVerticalAlignment(textVerticalAlignment.Top);
		ctrl03.SetFitToContent(false);
		ctrl03.SetSize(new Vector2(550, 1300));
		ctrl03.textOverflowPolicy = textOverflowPolicy.DotsEnd;
		ctrl03.Reparent(ctrl);

		let ctrl04: ref<inkRichTextBox> = new inkRichTextBox();
		ctrl04.SetName(n"descTxt_tbl04");
		ctrl04.SetText("");
		ctrl04.SetMargin(new inkMargin(1300, 80, 0.0, 0));
		ctrl04.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
		ctrl04.SetFontSize(28);
		ctrl04.SetFontStyle(n"Regular");
		ctrl04.SetAnchorPoint(new Vector2(0.5, 0));
		ctrl04.SetAnchor(inkEAnchor.TopCenter);
		ctrl04.SetVerticalAlignment(textVerticalAlignment.Top);
		ctrl04.SetFitToContent(false);
		ctrl04.SetSize(new Vector2(275, 1300));
		ctrl04.Reparent(ctrl);
	}

	private final func OnlineFunkceNastavitText(slp1: String, slp2: String, slp3: String, slp4: String) -> Void {
		let descCtrl: ref<inkText> = this.GetChildWidgetByPath(n"main_ui/main_container/text/descTxt_tbl01") as inkText;
		descCtrl.SetText(slp1);
		descCtrl = this.GetChildWidgetByPath(n"main_ui/main_container/text/descTxt_tbl02") as inkText;
		descCtrl.SetText(slp2);
		descCtrl = this.GetChildWidgetByPath(n"main_ui/main_container/text/descTxt_tbl03") as inkText;
		descCtrl.SetText(slp3);
		descCtrl = this.GetChildWidgetByPath(n"main_ui/main_container/text/descTxt_tbl04") as inkText;
		descCtrl.SetText(slp4);
	}

	private func DataPoleLokaciVychoziVyber() -> Void {
		if Equals(this.menuVybranaLokace.GlobalniID, GlobalniID.Lokace_Beach) {
			let pole: array<GlobalniID> = [GlobalniID.Postava_Mox_Female_01, GlobalniID.Postava_Mox_Female_03, GlobalniID.Postava_Mox_Female_05, GlobalniID.Postava_Mox_Male_01, GlobalniID.Postava_Mox_Male_09];
			let pole2: array<Int32> = [1, 0, 0, 0, 0];

			let i = 1;
			while i < ArraySize(this.menuVybranaPostavaPole) {
				if !this.menuVybranaPostavaPole[i].PostavaVybrana {
					let p: ref<VybranaPostava> = new VybranaPostava();
					p.PostavaVybrana = true;
					p.PostavaGID = pole[i - 1];
					p.Vzhled = pole2[i - 1];
					p.NastavitData(this.ZiskatDataPostav(p));
					this.menuVybranaPostavaPole[i] = p;
				}
				i += 1;
			}
		}
	}

	private func PozvaniDoBytuAktivniPostava() -> GlobalniID {
		let postavaGID: GlobalniID = GlobalniID.Prazdne;
		
		let vybLover: Int32 = this.questsSystem.GetFact(this.factLover);
		if vybLover == 1 { postavaGID = GlobalniID.Postava_Judy_Alvarez; }
		if vybLover == 2 { postavaGID = GlobalniID.Postava_Kerry_Eurodyne; }
		if vybLover == 3 { postavaGID = GlobalniID.Postava_Panam_Palmer; }
		if vybLover == 4 { postavaGID = GlobalniID.Postava_River_Ward; }

		return postavaGID;
	}

	private func PozvaniDoBytuPostavaData(postavaIndex: Int32) -> Void {
		this.menuVybranaPostavaPole[postavaIndex].Nazev = GetLocalizedText("LocKey#15142318");
		this.menuVybranaPostavaPole[postavaIndex].DataPostavy.Cena = 500;
	}

	private func DataPoleLokaciPozvaniDoBytu(postava: GlobalniID, postavaIndex: Int32) -> Void {
		let vzhled: Int32 = 0;

		let vybLover: Int32 = this.questsSystem.GetFact(this.factLover);
		if vybLover == 1 { vzhled = 0; this.vybranePohlavi = GenderType.Female; }
		if vybLover == 2 { vzhled = 0; this.vybranePohlavi = GenderType.Male; }
		if vybLover == 3 { vzhled = 0; this.vybranePohlavi = GenderType.Female; }
		if vybLover == 4 { vzhled = 0; this.vybranePohlavi = GenderType.Male; }

		let p: ref<VybranaPostava> = new VybranaPostava();
		p.PostavaVybrana = true;
		p.PostavaGID = postava;
		p.Vzhled = vzhled;
		p.NastavitData(this.ZiskatDataPostav(p));
		this.menuVybranaPostavaPole[postavaIndex] = p;
		this.PozvaniDoBytuPostavaData(postavaIndex);
	}

	private final func decimalToHex(decimalNumber: Int32, lit: Bool, four: Bool) -> String {
		let hexString: String = "";
		let remaining: Int32 = decimalNumber;
		let numBytes: Int32 = 0;

		while numBytes < (four ? 4 : 2) {
			let hexStringD: String = "";
			let numBytes2: Int32 = 0;
			while numBytes2 < 2 {
				let remainderDigit: Int32 = remaining % 16;
				let hexDigit: String = "";
				if remainderDigit >= 10 {
					hexDigit = StrChar(remainderDigit + 55);
				} else {
					hexDigit = StrChar(remainderDigit + 48);
				}
				hexStringD = hexDigit + hexStringD;
				remaining /= 16;
				numBytes2 += 1;
			}
			if lit { hexString = hexString + hexStringD + " "; }
			else { hexString = hexStringD + hexString; }
			numBytes += 1;
		}

		return hexString;
	}
}
