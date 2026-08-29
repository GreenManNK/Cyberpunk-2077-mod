public struct ftPoint {
    private let recordID: TweakDBID;
    private let node: NodeRef;
    private let id: CName;

    public static func New(recordID: TweakDBID, nodeHash: Uint64, id: CName) -> ftPoint {
        let ft: ftPoint;
        ft.recordID = recordID;
        ft.node = HashToNodeRef(nodeHash);
        ft.id = id;
        return ft;
    }

    public static func GetPoint(pointID: CName) -> ftPoint {	
		for i in ftPoint.All()
		{
			if (Equals(i.id, pointID)){
				return i;
			}
		}
        return ftPoint.New(t"FastTravelPoints.bls_nth_dataterm_01", 0ul, n"NotFound");
    }

    public static func All() -> array<ftPoint> {
        let allPoints: array<ftPoint> = [];
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_nth_dataterm_01", 16493866806625052523ul, n"bls_nth_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_nth_dataterm_02", 16493867906136680734ul, n"bls_nth_dataterm_02"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_nth_dataterm_04", 16493870105159937156ul, n"bls_nth_dataterm_04"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_nth_dataterm_05", 16493871204671565367ul, n"bls_nth_dataterm_05"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_nth_dataterm_07", 16493873403694821789ul, n"bls_nth_dataterm_07"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_nth_dataterm_08", 16493856911020398624ul, n"bls_nth_dataterm_08"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_nth_dataterm_09", 16494861864648394253ul, n"bls_nth_dataterm_09"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_nth_dataterm_10", 16494860765136766042ul, n"bls_nth_dataterm_10"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_nth_dataterm_11", 16494859665625137831ul, n"bls_nth_dataterm_11"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_nth_dataterm_12", 16494858566113509620ul, n"bls_nth_dataterm_12"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_nth_dataterm_13", 16494848670508855721ul, n"bls_nth_dataterm_13"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_nth_dataterm_14", 16494847570997227510ul, n"bls_nth_dataterm_14"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_nth_dataterm_15", 16495702991043786443ul, n"bls_nth_dataterm_15"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_nth_dataterm_16", 16495699692508901810ul, n"bls_nth_dataterm_16"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_nth_dataterm_17", 16495709588113555709ul, n"bls_nth_dataterm_17"));
		
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_sth_dataterm_01", 16493858010532026835ul, n"bls_sth_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_sth_dataterm_02", 16494857466601881409ul, n"bls_sth_dataterm_02"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_sth_dataterm_03", 16494856367090253198ul, n"bls_sth_dataterm_03"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_sth_dataterm_04", 16494855267578624987ul, n"bls_sth_dataterm_04"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_sth_dataterm_05", 16494854168066996776ul, n"bls_sth_dataterm_05"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_sth_dataterm_06", 16495708488601927498ul, n"bls_sth_dataterm_06"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_sth_dataterm_08", 16495706289578671076ul, n"bls_sth_dataterm_08"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_sth_dataterm_09", 16495707389090299287ul, n"bls_sth_dataterm_09"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_sth_dataterm_10", 16495704090555414654ul, n"bls_sth_dataterm_10"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_sth_dataterm_11", 16495705190067042865ul, n"bls_sth_dataterm_11"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.bls_sth_dataterm_12", 16495701891532158232ul, n"bls_sth_dataterm_12"));
		
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.cct_cpz_dataterm_01", 14662752634753016918ul, n"cct_cpz_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.cct_cpz_dataterm_02", 14662751535241388707ul, n"cct_cpz_dataterm_02"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.cct_cpz_dataterm_03", 14662750435729760496ul, n"cct_cpz_dataterm_03"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.cct_dtn_dataterm_01", 17201872818207620835ul, n"cct_dtn_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.cct_dtn_dataterm_02", 17201873917719249046ul, n"cct_dtn_dataterm_02"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.cct_dtn_dataterm_03", 17201875017230877257ul, n"cct_dtn_dataterm_03"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.cct_dtn_dataterm_04", 17201876116742505468ul, n"cct_dtn_dataterm_04"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.cct_dtn_dataterm_05", 17201877216254133679ul, n"cct_dtn_dataterm_05"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.cct_dtn_dataterm_07", 17201879415277390101ul, n"cct_dtn_dataterm_07"));

        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.dlc6_apart_cct_dtn_dataterm", 15094828628317876848ul, n"dlc6_apart_cct_dtn_dataterm"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.dlc6_apart_hey_gle_dataterm", 925008255176299316ul, n"dlc6_apart_hey_gle_dataterm"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.dlc6_apart_wat_nid_dataterm", 12741316748559091154ul, n"dlc6_apart_wat_nid_dataterm"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.dlc6_apart_wbr_jpn_dataterm", 16718327260655701543ul, n"dlc6_apart_wbr_jpn_dataterm"));
		
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_gle_dataterm_01", 4141487508616261419ul, n"hey_gle_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_gle_dataterm_02", 4141488608127889630ul, n"hey_gle_dataterm_02"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_gle_dataterm_03", 4141489707639517841ul, n"hey_gle_dataterm_03"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_gle_dataterm_04", 4141490807151146052ul, n"hey_gle_dataterm_04"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_gle_dataterm_05", 4141491906662774263ul, n"hey_gle_dataterm_05"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_gle_dataterm_06", 4141493006174402474ul, n"hey_gle_dataterm_06"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_gle_dataterm_07", 4141494105686030685ul, n"hey_gle_dataterm_07"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_gle_dataterm_08", 4141477613011607520ul, n"hey_gle_dataterm_08"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_rey_dataterm_01", 15602690535274136717ul, n"hey_rey_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_rey_dataterm_02", 15602687236739252084ul, n"hey_rey_dataterm_02"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_rey_dataterm_03", 15602688336250880295ul, n"hey_rey_dataterm_03"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_rey_dataterm_04", 15602685037715995662ul, n"hey_rey_dataterm_04"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_rey_dataterm_05", 15602686137227623873ul, n"hey_rey_dataterm_05"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_rey_dataterm_06", 15602682838692739240ul, n"hey_rey_dataterm_06"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_rey_dataterm_07", 15602683938204367451ul, n"hey_rey_dataterm_07"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_spr_dataterm_01", 12335256362470956358ul, n"hey_spr_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_spr_dataterm_02", 12335255262959328147ul, n"hey_spr_dataterm_02"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_spr_dataterm_03", 12335254163447699936ul, n"hey_spr_dataterm_03"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_spr_dataterm_04", 12335261860029097413ul, n"hey_spr_dataterm_04"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_spr_dataterm_05", 12335260760517469202ul, n"hey_spr_dataterm_05"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_spr_dataterm_06", 12335259661005840991ul, n"hey_spr_dataterm_06"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.hey_spr_dataterm_07", 12335258561494212780ul, n"hey_spr_dataterm_07"));
		
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.pac_cvi_dataterm_01", 4930252676984815019ul, n"pac_cvi_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.pac_cvi_dataterm_02", 4930253776496443230ul, n"pac_cvi_dataterm_02"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.pac_cvi_dataterm_03", 4930254876008071441ul, n"pac_cvi_dataterm_03"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.pac_cvi_dataterm_04", 4930255975519699652ul, n"pac_cvi_dataterm_04"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.pac_cvi_dataterm_05", 4930257075031327863ul, n"pac_cvi_dataterm_05"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.pac_wwd_dataterm_03", 8421890504370085691ul, n"pac_wwd_dataterm_03"));
		
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_arr_dataterm_01", 12510532072937730797ul, n"std_arr_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_arr_dataterm_02", 12510528774402846164ul, n"std_arr_dataterm_02"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_arr_dataterm_03", 12510529873914474375ul, n"std_arr_dataterm_03"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_arr_dataterm_04", 12510526575379589742ul, n"std_arr_dataterm_04"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_arr_dataterm_05", 12510527674891217953ul, n"std_arr_dataterm_05"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_arr_dataterm_06", 12510524376356333320ul, n"std_arr_dataterm_06"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_arr_dataterm_07", 12510525475867961531ul, n"std_arr_dataterm_07"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_arr_dataterm_08", 12510522177333076898ul, n"std_arr_dataterm_08"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_arr_dataterm_09", 12983162032129539274ul, n"std_arr_dataterm_09"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_rcr_dataterm_01", 14513164656797639057ul, n"std_rcr_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_rcr_dataterm_02", 14513161358262754424ul, n"std_rcr_dataterm_02"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_rcr_dataterm_03", 14513162457774382635ul, n"std_rcr_dataterm_03"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_rcr_dataterm_05", 14513169054844151901ul, n"std_rcr_dataterm_05"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_rcr_dataterm_06", 14513165756309267268ul, n"std_rcr_dataterm_06"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_rcr_dataterm_07", 14513166855820895479ul, n"std_rcr_dataterm_07"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_rcr_dataterm_08", 14513154761192985158ul, n"std_rcr_dataterm_08"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_rcr_dataterm_09", 14513155860704613369ul, n"std_rcr_dataterm_09"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_rcr_dataterm_10", 14514155316774467943ul, n"std_rcr_dataterm_10"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.std_rcr_dataterm_11", 1389063165612451677ul, n"std_rcr_dataterm_11"));
		
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_awf_dataterm_01", 16490430286373786921ul, n"wat_awf_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_awf_dataterm_03", 16490428087350530499ul, n"wat_awf_dataterm_03"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_kab_dataterm_01", 17129877245692633793ul, n"wat_kab_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_kab_dataterm_02", 17129873947157749160ul, n"wat_kab_dataterm_02"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_kab_dataterm_03", 17129875046669377371ul, n"wat_kab_dataterm_03"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_kab_dataterm_04", 17129880544227518426ul, n"wat_kab_dataterm_04"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_kab_dataterm_05", 17129881643739146637ul, n"wat_kab_dataterm_05"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_kab_dataterm_06", 17129878345204262004ul, n"wat_kab_dataterm_06"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_kab_dataterm_07", 17129879444715890215ul, n"wat_kab_dataterm_07"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_kab_dataterm_08", 17129867350087979894ul, n"wat_kab_dataterm_08"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_kab_dataterm_10", 17130727168181051671ul, n"wat_kab_dataterm_10"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_kab_dataterm_11", 3741755697364336333ul, n"wat_kab_dataterm_11"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_kab_dataterm_12", 7108739680868950322ul, n"wat_kab_dataterm_12"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_lch_dataterm_01", 9866370690882420920ul, n"wat_lch_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_lch_dataterm_02", 9866373989417305553ul, n"wat_lch_dataterm_02"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_lch_dataterm_03", 9866372889905677342ul, n"wat_lch_dataterm_03"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_lch_dataterm_04", 9866376188440561975ul, n"wat_lch_dataterm_04"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_lch_dataterm_05", 9866375088928933764ul, n"wat_lch_dataterm_05"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_lch_dataterm_07", 9866377287952190186ul, n"wat_lch_dataterm_07"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_lch_dataterm_09", 9866361894789395232ul, n"wat_lch_dataterm_09"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_lch_dataterm_10", 9865380030905592034ul, n"wat_lch_dataterm_10"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_lch_dataterm_11", 9865381130417220245ul, n"wat_lch_dataterm_11"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_nid_dataterm_01", 7037965860905952832ul, n"wat_nid_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_nid_dataterm_02", 7037969159440837465ul, n"wat_nid_dataterm_02"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_nid_dataterm_03", 7037968059929209254ul, n"wat_nid_dataterm_03"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_nid_dataterm_04", 7037971358464093887ul, n"wat_nid_dataterm_04"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_nid_dataterm_05", 7037970258952465676ul, n"wat_nid_dataterm_05"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_nid_dataterm_06", 7037973557487350309ul, n"wat_nid_dataterm_06"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_nid_dataterm_07", 7037972457975722098ul, n"wat_nid_dataterm_07"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_nid_dataterm_08", 7037975756510606731ul, n"wat_nid_dataterm_08"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wat_nid_dataterm_09", 11020164614808685513ul, n"wat_nid_dataterm_09"));
		
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_hil_dataterm_01", 8620281247010309419ul, n"wbr_hil_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_hil_dataterm_02", 8620282346521937630ul, n"wbr_hil_dataterm_02"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_hil_dataterm_03", 8620283446033565841ul, n"wbr_hil_dataterm_03"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_hil_dataterm_04", 8620284545545194052ul, n"wbr_hil_dataterm_04"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_hil_dataterm_05", 8620285645056822263ul, n"wbr_hil_dataterm_05"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_jpn_dataterm_01", 14855945090552163386ul, n"wbr_jpn_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_jpn_dataterm_02", 14855943991040535175ul, n"wbr_jpn_dataterm_02"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_jpn_dataterm_03", 14855942891528906964ul, n"wbr_jpn_dataterm_03"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_jpn_dataterm_04", 14855941792017278753ul, n"wbr_jpn_dataterm_04"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_jpn_dataterm_05", 14855940692505650542ul, n"wbr_jpn_dataterm_05"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_jpn_dataterm_06", 14855939592994022331ul, n"wbr_jpn_dataterm_06"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_jpn_dataterm_07", 14855938493482394120ul, n"wbr_jpn_dataterm_07"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_jpn_dataterm_08", 14855937393970765909ul, n"wbr_jpn_dataterm_08"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_jpn_dataterm_09", 14855936294459137698ul, n"wbr_jpn_dataterm_09"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_jpn_dataterm_10", 14854954430575334500ul, n"wbr_jpn_dataterm_10"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_jpn_dataterm_11", 14854955530086962711ul, n"wbr_jpn_dataterm_11"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_jpn_dataterm_12", 8664398550832132899ul, n"wbr_jpn_dataterm_12"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_nok_dataterm_01", 15405989836884596390ul, n"wbr_nok_dataterm_01"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_nok_dataterm_02", 15405988737372968179ul, n"wbr_nok_dataterm_02"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_nok_dataterm_03", 15405987637861339968ul, n"wbr_nok_dataterm_03"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_nok_dataterm_04", 15405995334442737445ul, n"wbr_nok_dataterm_04"));
        ArrayPush(allPoints, ftPoint.New(t"FastTravelPoints.wbr_nok_dataterm_05", 15405994234931109234ul, n"wbr_nok_dataterm_05"));

        for i in allPoints {
            let rec = TweakDBInterface.GetFastTravelPointRecord(i.recordID);
            if !IsDefined(rec) || !rec.ShowOnWorldMap() || !rec.ShowInWorld() {
                ArrayRemove(allPoints, i);
            }
        }
        return allPoints;
    }
}

  
@wrapMethod(PlayerPuppet)
protected cb func OnItemAddedToInventory(evt: ref<ItemAddedEvent>) -> Bool {
	let itemRecord: ref<Item_Record>;
	itemRecord = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(evt.itemID));
	if (RoundF(itemRecord.UpgradeCostMult()) == 5566){
		
		let fts = this.GetFastTravelSystem() as FastTravelSystem;
		GameInstance.GetQuestsSystem(this.GetGame()).SetFactStr(itemRecord.FriendlyName(), 1);
		for i in itemRecord.Tags() {
			let point: ftPoint = ftPoint.GetPoint(i);
			if (NotEquals(point.id, n"NotFound")){ 		
				fts.RegisterftPoint_BrochureEntry(point.recordID,point.node);
			}
		};
	}
	wrappedMethod(evt);
}
  


@addMethod(FastTravelSystem)
public func RegisterftPoint_BrochureEntry(pointRecord: TweakDBID, markerRef: NodeRef) -> Void {
    let data = new FastTravelPointData();
	let emptyID: EntityID;
    data.pointRecord = pointRecord;
    data.markerRef = markerRef;
    data.isEP1 = false;
    data.requesterID = emptyID;
    this.RegisterFastTravelPoint(data, emptyID);
}