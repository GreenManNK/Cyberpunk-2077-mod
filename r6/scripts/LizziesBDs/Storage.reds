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

module LizziesBDs.Storage

import LizziesBDs.Classes.*
import LizziesBDs.Data.*

public class LizziesBDsUlozistePolozkaV5 {
	public let ID: Int32;

	public persistent let Postavy: array<ref<VybranaPostava>>;
	public persistent let LokaceID: Int32;
	public persistent let Nastaveni: array<ref<VybranaPostavaNastaveni>>;
}

public enum UlozisteTyp {
	Oblibene = 0,
	Koupeno = 1,
	SledovatZnovu = 2
}

public class LizziesBDsUloziste extends ScriptableSystem {
	private let oblibeneId: Int32;
	private persistent let oblibenePoleV5: array<ref<LizziesBDsUlozistePolozkaV5>>;
	private persistent let oblibenePeveckaPoleV5: array<ref<LizziesBDsUlozistePolozkaV5>>;
	private let oblibenePeveckaAktivni: Bool = false;

	private let koupenoId: Int32;
	private persistent let koupenoPoleV5: array<ref<LizziesBDsUlozistePolozkaV5>>;

	private persistent let sledovatZnovuPoleV5: array<ref<LizziesBDsUlozistePolozkaV5>>;

	public static func ZiskatInstanci(gameInstance: GameInstance) -> ref<LizziesBDsUloziste> {
		let service: ref<LizziesBDsUloziste> = GameInstance.GetScriptableSystemsContainer(gameInstance).Get(n"LizziesBDs.Storage.LizziesBDsUloziste") as LizziesBDsUloziste;
		return service;
	}

	public func VypsatPolozka(index: Int32, polozka: ref<LizziesBDsUlozistePolozkaV5>) -> Void {
		let vypis: String = "";

		vypis = "#" + ToString(index) + " - Loc: " + ToString(polozka.LokaceID) + ", Opts: [";
		let i = 0;
		while i < ArraySize(polozka.Nastaveni) {
			vypis += (i > 0 ? ", " : "") + NameToString(polozka.Nastaveni[i].NastaveniName) + "=" + ToString(polozka.Nastaveni[i].Hodnota);
			i += 1;
		}
		vypis = "], Chars: ";
		i = 0;
		while i < ArraySize(polozka.Postavy) {
			vypis += (i > 0 ? ", " : "") + "[" + ToString(polozka.Postavy[i].PostavaGID) + ", " + ToString(polozka.Postavy[i].Vzhled) + ", " + ToString(polozka.Postavy[i].Vlastni);
			for n in polozka.Postavy[i].Nastaveni {
				vypis += ", " + NameToString(n.NastaveniName) + "=" + ToString(n.Hodnota);
			}
			vypis += "]";
			i += 1;
		}
		FTLog(vypis);
	}

	public func Vypsat() -> Void {
		FTLog("[LizziesBDs] Storage");

		this.Nacist(false);

		FTLog("Favorites");
		let i = 0;
		while i < ArraySize(this.oblibenePoleV5) {
			this.VypsatPolozka(i, this.oblibenePoleV5[i]);
			i += 1;
		}

		FTLog("Bought");
		i = 0;
		while i < ArraySize(this.koupenoPoleV5) {
			this.VypsatPolozka(i, this.koupenoPoleV5[i]);
			i += 1;
		}

		FTLog("Watch again");
		i = 0;
		while i < ArraySize(this.sledovatZnovuPoleV5) {
			this.VypsatPolozka(i, this.sledovatZnovuPoleV5[i]);
			i += 1;
		}

		this.Nacist(true);

		FTLog("Favorites virtus");
		i = 0;
		while i < ArraySize(this.oblibenePeveckaPoleV5) {
			this.VypsatPolozka(i, this.oblibenePeveckaPoleV5[i]);
			i += 1;
		}
	}

	public func Pridat(
		typUloziste: UlozisteTyp,
		lokace: Int32,
		nastaveni: array<ref<VybranaPostavaNastaveni>>,
		postavy: array<ref<VybranaPostava>>,
		opt index: Int32
	) -> Void {
		let polozka: ref<LizziesBDsUlozistePolozkaV5> = new LizziesBDsUlozistePolozkaV5();
		for p in postavy {
			let pn: ref<VybranaPostava> = p.NovaInstance();
			pn.DataPostavy = null;
			ArrayPush(polozka.Postavy, pn);
		}
		polozka.LokaceID = lokace;

		GlobalniFunkce.ZkopirovatNastaveni(nastaveni, polozka.Nastaveni);

		if Equals(typUloziste, UlozisteTyp.Oblibene) {
			polozka.ID = this.oblibeneId;
			if this.oblibenePeveckaAktivni {
				ArrayPush(this.oblibenePeveckaPoleV5, polozka);
			} else {
				ArrayPush(this.oblibenePoleV5, polozka);
			}
			this.oblibeneId += 1;
		}
		else if Equals(typUloziste, UlozisteTyp.Koupeno) {
			polozka.ID = this.koupenoId;
			ArrayPush(this.koupenoPoleV5, polozka);
			this.koupenoId += 1;
		}
		else if Equals(typUloziste, UlozisteTyp.SledovatZnovu) {
			polozka.ID = index;
			this.sledovatZnovuPoleV5[index] = polozka;
		}
	}

	public func SmazatID(typUloziste: UlozisteTyp, id: Int32) -> Void {
		if Equals(typUloziste, UlozisteTyp.Oblibene) {
			let i = 0;

			if this.oblibenePeveckaAktivni {
				while i < ArraySize(this.oblibenePeveckaPoleV5) {
					if this.oblibenePeveckaPoleV5[i].ID == id {
						ArrayRemove(this.oblibenePeveckaPoleV5, this.oblibenePeveckaPoleV5[i]);
						return;
					}

					i += 1;
				}
			} else {
				while i < ArraySize(this.oblibenePoleV5) {
					if this.oblibenePoleV5[i].ID == id {
						ArrayRemove(this.oblibenePoleV5, this.oblibenePoleV5[i]);
						return;
					}

					i += 1;
				}
			}
		}
		else if Equals(typUloziste, UlozisteTyp.Koupeno) {
			let i = 0;
			while i < ArraySize(this.koupenoPoleV5) {
				if this.koupenoPoleV5[i].ID == id {
					ArrayRemove(this.koupenoPoleV5, this.koupenoPoleV5[i]);
					return;
				}

				i += 1;
			}
		}
		else if Equals(typUloziste, UlozisteTyp.SledovatZnovu) {
			this.koupenoPoleV5 = [];
		}
	}

	public func JeVUlozisti(
		typUloziste: UlozisteTyp,
		lokace: Int32,
		nastaveni: array<ref<VybranaPostavaNastaveni>>,
		postavy: array<ref<VybranaPostava>>
	) -> Int32 {
		let pole: array<ref<LizziesBDsUlozistePolozkaV5>>;

		if Equals(typUloziste, UlozisteTyp.Oblibene) {
			pole = this.oblibenePeveckaAktivni ? this.oblibenePeveckaPoleV5 : this.oblibenePoleV5;
		}
		else if Equals(typUloziste, UlozisteTyp.Koupeno) {
			pole = this.koupenoPoleV5;
		}
		else if Equals(typUloziste, UlozisteTyp.SledovatZnovu) {
			pole = this.sledovatZnovuPoleV5;
		}

		let i = 0;
		while i < ArraySize(pole) {
			let pocetPostav: Int32 = ArraySize(postavy);

			if ArraySize(pole[i].Postavy) == pocetPostav {
				let podminka: Bool = pole[i].LokaceID == lokace;

				if ArraySize(nastaveni) > 0 {
					for ulozNast in pole[i].Nastaveni {
						for inNast in nastaveni {
							if Equals(ulozNast.NastaveniName, inNast.NastaveniName) {
								podminka = podminka && ulozNast.Hodnota == inNast.Hodnota;
							}
						}
					}
				}

				let j = 0;
				while j < pocetPostav {
					podminka = podminka &&
						Equals(pole[i].Postavy[j].PostavaGID, postavy[j].PostavaGID) &&
						pole[i].Postavy[j].Vzhled == postavy[j].Vzhled &&
						pole[i].Postavy[j].Vlastni == postavy[j].Vlastni;

					podminka = podminka && ArraySize(pole[i].Postavy[j].Nastaveni) == ArraySize(postavy[j].Nastaveni);
					for ulozNast in pole[i].Postavy[j].Nastaveni {
						for inNast in postavy[j].Nastaveni {
							if Equals(ulozNast.NastaveniName, inNast.NastaveniName) {
								podminka = podminka && ulozNast.Hodnota == inNast.Hodnota;
							}
						}
					}

					j += 1;
				}

				if podminka {
					return pole[i].ID;
				}
			}

			i += 1;
		}

		return -1;
	}

	public func VratitPoleDat(typUloziste: UlozisteTyp) -> array<ref<LizziesBDsUlozistePolozkaV5>> {
		if Equals(typUloziste, UlozisteTyp.Oblibene) {
			return this.oblibenePeveckaAktivni ? this.oblibenePeveckaPoleV5 : this.oblibenePoleV5;
		}
		else if Equals(typUloziste, UlozisteTyp.Koupeno) {
			return this.koupenoPoleV5;
		}
		else if Equals(typUloziste, UlozisteTyp.SledovatZnovu) {
			return this.sledovatZnovuPoleV5;
		}

		let p: array<ref<LizziesBDsUlozistePolozkaV5>> = [];
		return p;
	}

	public func Nacist(peveckaAktivni: Bool) -> Void {
		if peveckaAktivni {
			this.oblibenePeveckaPoleV5 = this.NacistZpetneData(this.oblibenePeveckaPoleV4, this.oblibenePeveckaPoleV5);
		} else {
			this.oblibenePoleV5 = this.NacistZpetneData(this.oblibenePoleV4, this.oblibenePoleV5);
		}

		this.koupenoPoleV5 = this.NacistZpetneData(this.koupenoPoleV4, this.koupenoPoleV5);

		this.sledovatZnovuPoleV5 = this.NacistZpetneData(this.sledovatZnovuPoleV4, this.sledovatZnovuPoleV5);

		this.oblibenePeveckaAktivni = peveckaAktivni;
		let i = 0;

		if peveckaAktivni {
			while i < ArraySize(this.oblibenePeveckaPoleV5) {
				this.oblibenePeveckaPoleV5[i].ID = i;
				i += 1;
			}
			this.oblibeneId = ArraySize(this.oblibenePeveckaPoleV5);
		} else {
			while i < ArraySize(this.oblibenePoleV5) {
				this.oblibenePoleV5[i].ID = i;
				i += 1;
			}
			this.oblibeneId = ArraySize(this.oblibenePoleV5);
		}

		i = 0;
		while i < ArraySize(this.koupenoPoleV5) {
			this.koupenoPoleV5[i].ID = i;
			i += 1;
		}
		this.koupenoId = ArraySize(this.koupenoPoleV5);

		if ArraySize(this.sledovatZnovuPoleV5) == 0 {
			ArrayResize(this.sledovatZnovuPoleV5, 2);

			let a: ref<VybranaPostava>;
			a.PostavaGID = GlobalniID.Prazdne;
			this.Pridat(UlozisteTyp.SledovatZnovu, 0, [], [a], 0);
			this.Pridat(UlozisteTyp.SledovatZnovu, 0, [], [a], 1);
		}
	}

	private func NacistZpetneData(stareData: array<ref<LizziesBDsUlozistePolozkaV4>>, noveDataPrm: array<ref<LizziesBDsUlozistePolozkaV5>>) -> array<ref<LizziesBDsUlozistePolozkaV5>> {
		let noveData: array<ref<LizziesBDsUlozistePolozkaV5>> = noveDataPrm;

		if ArraySize(noveDataPrm) == 0 && ArraySize(stareData) > 0 {
			let i = 0;
			while i < ArraySize(stareData) {
				let polozka: ref<LizziesBDsUlozistePolozkaV5> = new LizziesBDsUlozistePolozkaV5();
				polozka.LokaceID = stareData[i].LokaceID;
				
				polozka.Nastaveni = [];
				let j = 0;
				while j < ArraySize(stareData[i].Parametry) {
					let nn: ref<VybranaPostavaNastaveni> = new VybranaPostavaNastaveni();
					if j == 0 { nn.NastaveniName = n"lizzies_bds_joytoy_repeat_sel"; }
					if j == 1 { nn.NastaveniName = Konstanty.FaktVybratHudbu(); }
					nn.Hodnota = stareData[i].Parametry[j];
					ArrayPush(polozka.Nastaveni, nn);
					j += 1;
				}

				polozka.Postavy = stareData[i].Postavy;

				ArrayPush(noveData, polozka);
				i += 1;
			}
		}

		return noveData;
	}
	
	private persistent let oblibenePoleV4: array<ref<LizziesBDsUlozistePolozkaV4>>;
	private persistent let oblibenePeveckaPoleV4: array<ref<LizziesBDsUlozistePolozkaV4>>;
	private persistent let koupenoPoleV4: array<ref<LizziesBDsUlozistePolozkaV4>>;
	private persistent let sledovatZnovuPoleV4: array<ref<LizziesBDsUlozistePolozkaV4>>;
}

public class LizziesBDsUlozistePolozkaV4 {
	public let ID: Int32;

	public persistent let Postavy: array<ref<VybranaPostava>>;

	public persistent let LokaceID: Int32;
	public persistent let Parametry: array<Int32>;
}
