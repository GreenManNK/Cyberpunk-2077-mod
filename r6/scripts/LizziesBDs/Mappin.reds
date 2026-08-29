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

module LizziesBDs.Mappin

import LizziesBDs.Classes.*

@wrapMethod(WorldMapTooltipController)
public func SetData(const data: script_ref<WorldMapTooltipData>, menu: ref<WorldMapMenuGameController>) -> Void {
	wrappedMethod(data, menu);

	let lizziesBDsPoiMappin = Deref(data).mappin as PointOfInterestMappin;
	if IsDefined(lizziesBDsPoiMappin) {
		let poiJournalHash: Uint32 = lizziesBDsPoiMappin.GetJournalPathHash();

		let ar: array<Uint32> = Konstanty.MappinHashesBD();
		if ArrayContains(ar, poiJournalHash) {
			inkTextRef.SetText(this.m_titleText, GetLocalizedText("LocKey#15142003"));
			inkTextRef.SetText(this.m_descText, GetLocalizedText("LocKey#15142012"));
		}
		
		let ar2: array<Uint32> = Konstanty.MappinHashesER();
		if ArrayContains(ar2, poiJournalHash) {
			inkTextRef.SetText(this.m_titleText, GetLocalizedText("LocKey#15142357"));
			inkTextRef.SetText(this.m_descText, GetLocalizedText("LocKey#15142358"));
		}
	}
}

@wrapMethod(MinimapPOIMappinController)
protected final func UpdateIcon() -> Void {
	wrappedMethod();

	let lizziesBDsPoiMappin = this.GetMappin() as PointOfInterestMappin;
	if IsDefined(lizziesBDsPoiMappin) {
		let poiJournalHash: Uint32 = lizziesBDsPoiMappin.GetJournalPathHash();

		let ar: array<Uint32> = Konstanty.MappinHashesBD();
		if ArrayContains(ar, poiJournalHash) {
			inkImageRef.SetTexturePart(this.iconWidget, n"braindance");
		}
		
		let ar2: array<Uint32> = Konstanty.MappinHashesER();
		if ArrayContains(ar2, poiJournalHash) {
			inkImageRef.SetTexturePart(this.iconWidget, n"face_morph");
		}
	}
}

@wrapMethod(BaseWorldMapMappinController)
protected func UpdateIcon() -> Void {
	wrappedMethod();

	let lizziesBDsPoiMappin = this.GetMappin() as PointOfInterestMappin;
	if IsDefined(lizziesBDsPoiMappin) {
		let poiJournalHash: Uint32 = lizziesBDsPoiMappin.GetJournalPathHash();

		let ar: array<Uint32> = Konstanty.MappinHashesBD();
		if ArrayContains(ar, poiJournalHash) {
			inkImageRef.SetTexturePart(this.iconWidget, n"braindance");
		}
		
		let ar2: array<Uint32> = Konstanty.MappinHashesER();
		if ArrayContains(ar2, poiJournalHash) {
			inkImageRef.SetTexturePart(this.iconWidget, n"face_morph");
		}
	}
}

@wrapMethod(QuestMappinController)
protected func UpdateIcon() -> Void {
	wrappedMethod();

	let lizziesBDsPoiMappin = this.GetMappin() as PointOfInterestMappin;
	if IsDefined(lizziesBDsPoiMappin) {
		let poiJournalHash: Uint32 = lizziesBDsPoiMappin.GetJournalPathHash();
		
		let ar: array<Uint32> = Konstanty.MappinHashesBD();
		if ArrayContains(ar, poiJournalHash) {
			inkImageRef.SetTexturePart(this.iconWidget, n"braindance");
		}
		
		let ar2: array<Uint32> = Konstanty.MappinHashesER();
		if ArrayContains(ar2, poiJournalHash) {
			inkImageRef.SetTexturePart(this.iconWidget, n"face_morph");
		}
	}
}
