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
import LizziesBDs.Resources.*

public class CreditsUIController extends inkGameController {
	private let player: wref<PlayerPuppet>;
	private let game: GameInstance;
	private let questsSystem: wref<QuestsSystem>;
	private let lizziesBDsResources: wref<LizziesBDsResources>;

	protected cb func OnInitialize() -> Bool {
		this.player = this.GetPlayerControlledObject() as PlayerPuppet;
		this.game = this.player.GetGame();
		this.questsSystem = GameInstance.GetQuestsSystem(this.game);
		this.lizziesBDsResources = GameInstance.GetScriptableServiceContainer().GetService(n"LizziesBDs.Resources.LizziesBDsResources") as LizziesBDsResources;

		let poleLokaciData: array<ref<DataLokace>> = DataPoleLokaci(this.game, this.questsSystem, this.lizziesBDsResources, true, false, true);
		let polePostavData: array<ref<DataPostavy>> = DataPolePostav();

		let vybranaLokace: Int32 = this.questsSystem.GetFact(Konstanty.FaktVybranaLokace());

		let bdNazevHlavni: String = "";
		let bdNazevSEpizodou: String = "";
		let castJmena: String = "";
		let producerNazev: String = "Lizzie's Bar";
		let producerCNazev: String = "Lizzie's Bar LTD.";
		let spolupraceNazev: String = "";
		let bezMezer: Bool = false;

		let j = 0;
		while j < ArraySize(poleLokaciData) {
			if EnumInt(poleLokaciData[j].GlobalniID) == vybranaLokace {
				bdNazevHlavni = poleLokaciData[j].Nazev;
				bdNazevSEpizodou = bdNazevHlavni;
			}

			if ArraySize(poleLokaciData[j].Kontejner) > 0 {
				let i = 0;
				while i < ArraySize(poleLokaciData[j].Kontejner) {
					if EnumInt(poleLokaciData[j].Kontejner[i].GlobalniID) == vybranaLokace {
						if Equals(poleLokaciData[j].GlobalniID, GlobalniID.Lokace_Kont_Various) {
							bdNazevHlavni = poleLokaciData[j].Kontejner[i].Nazev;
							bdNazevSEpizodou = bdNazevHlavni;
						} else {
							bdNazevHlavni = poleLokaciData[j].Nazev;
							bdNazevSEpizodou = bdNazevHlavni + "\n" + poleLokaciData[j].Kontejner[i].Nazev;
						}
					}
					i += 1;
				}
			}

			j += 1;
		}

		if vybranaLokace == EnumInt(GlobalniID.Lokace_Ostatni_Edgerunners) {
			producerNazev = "Jimmy Kurosaki";
			producerCNazev = producerNazev;
			castJmena += "<Rich style=\"Bold\">Lt. Col. James Norris</>\n";
		}
		if vybranaLokace == EnumInt(GlobalniID.Lokace_Ostatni_Lizzy) {
			castJmena += "<Rich style=\"Bold\">Elisabeth \"Lizzy Wizzy\" Wissenfurth</>\n";
		}
		if vybranaLokace == EnumInt(GlobalniID.Lokace_Ostatni_LetYouDown) {
			producerNazev = "Akira Yamaoka, STUDIO MASSKET";
			producerCNazev = producerNazev;
			spolupraceNazev += "\n\nLYRICS\n<Rich style=\"Bold\">Dawid Podsiadło</>";
			spolupraceNazev += "\n\nMUSIC\n<Rich style=\"Bold\">Dawid Podsiadło and Magdalena Laskowska</>";
			spolupraceNazev += "\n\nDIRECTED BY\n<Rich style=\"Bold\">Ilya Kuvshinov</>";
			castJmena += "<Rich style=\"Bold\">Sasha Yakovleva</>\n";
			castJmena += "<Rich style=\"Bold\">Maine</>\n";
			castJmena += "<Rich style=\"Bold\">Dorio</>\n";
			castJmena += "<Rich style=\"Bold\">Rebecca</>\n";
			bezMezer = true;
		}
		if vybranaLokace == EnumInt(GlobalniID.Lokace_Ostatni_IReallyWantToStayAtYourHouse) {
			producerNazev = "Rosa Walton, Neil Comber";
			producerCNazev = producerNazev;
			spolupraceNazev += "\n\nLYRICS\n<Rich style=\"Bold\">Rosa Walton</>";
			spolupraceNazev += "\n\nMUSIC\n<Rich style=\"Bold\">Rosa Walton</>";
		}
		if vybranaLokace == EnumInt(GlobalniID.Lokace_Ostatni_Tutorial) {
			producerNazev = "Militech";
			producerCNazev = producerNazev;
		}
		if vybranaLokace == EnumInt(GlobalniID.Lokace_Ostatni_UsCracks) {
			producerNazev = "MSM Records";
			producerCNazev = producerNazev;
			spolupraceNazev = "\n\n\n\nIN ASSOCIATION WITH DIVERSE MEDIA SYSTEMS";
			castJmena += "<Rich style=\"Bold\">Aoi \"Blue Moon\" Tsuki</>\n";
			castJmena += "<Rich style=\"Bold\">Akai \"Red Menace\" Kyōi</>\n";
			castJmena += "<Rich style=\"Bold\">Purple Force</>\n";
		}
		if vybranaLokace == EnumInt(GlobalniID.Lokace_Cyberpsycho_Hey_Spr_04) {
			producerNazev = "Diverse Media Systems";
			producerCNazev = producerNazev + " Inc.";
			spolupraceNazev = "\n\n\n\nIN ASSOCIATION WITH MAX-TAC";
			castJmena += "<Rich style=\"Bold\">Dao Hyunh</>\n";
		}

		let m = 0;
		while m < 6 {
			let faktPostava: CName = StringToName(Konstanty.FaktVybranaPostava() + ToString(m));
			let faktPostavaVlastni: CName = StringToName(Konstanty.FaktVybranaPostavaVlastni() + ToString(m));

			let postava: Int32 = this.questsSystem.GetFact(faktPostava);
			let postavaVlastni: Int32 = this.questsSystem.GetFact(faktPostavaVlastni);

			let i = 0;
			while i < ArraySize(polePostavData) {
				if
					EnumInt(polePostavData[i].GlobalniID) == postava &&
					polePostavData[i].CustomID == postavaVlastni &&
					NotEquals(polePostavData[i].GlobalniID, GlobalniID.Postava_LokaceBezPostavy)
				{
					castJmena += "<Rich style=\"Bold\">" + polePostavData[i].ZiskatNazevPostavy() + "</>\n";
				}
				i += 1;
			}

			m += 1;
		}

		if NotEquals(castJmena, "") {
			castJmena = "CAST\n" + (bezMezer ? "" : "\n") + castJmena + (bezMezer ? "\n\n" : "\n\n\n\n");
		}

		let horniTextCtrl: ref<inkRichTextBox> = this.GetChildWidgetByPath(n"hlavni_kontejner_konec_pv/horni_text") as inkRichTextBox;
		let stredniTextCtrl: ref<inkRichTextBox> = this.GetChildWidgetByPath(n"hlavni_kontejner_konec_pv/stredni_text") as inkRichTextBox;
		let spodniTextCtrl: ref<inkRichTextBox> = this.GetChildWidgetByPath(n"hlavni_kontejner_konec_pv/spodni_text") as inkRichTextBox;

		horniTextCtrl.SetText(bdNazevSEpizodou);
		stredniTextCtrl.SetText(castJmena + "PRODUCER\n" + (bezMezer ? "" : "\n") + "<Rich style=\"Bold\">" + producerNazev + "</>" + spolupraceNazev);
		spodniTextCtrl.SetText(bdNazevHlavni + "® is registered trademark of " + producerCNazev + "\nBraindance Cartridge logo is registered trademark of Braindance Inc.\n© 2077 " + producerCNazev + ", Braindance Inc. All rights reserved. All other copyrights and trademarks are the property of their respective owners.");
	
		//horniTextCtrl.SetText("Pure Joytoy Experience\nJig-Jig Street");
		//stredniTextCtrl.SetText("CAST\n\n<Rich style=\"Bold\">Rita Wheeler</>\n<Rich style=\"Bold\">BD actor name</>\n\n\n\nPRODUCER\n\n<Rich style=\"Bold\">Lizzie's Bar</>\n\n\n\n<Rich style=\"Bold\">IN ASSOCIATION WITH XXX</>");
		//spodniTextCtrl.SetText("Pure Joytoy Experience® is registered trademark of Lizzie's Bar LTD.\nBraindance Cartridge logo is registered trademark of Braindance Inc.\n© 2077 Lizzie's Bar LTD., Braindance Inc. All rights reserved. All other copyrights and trademarks are the property of their respective owners.");
	}
}
