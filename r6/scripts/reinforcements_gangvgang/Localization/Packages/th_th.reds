module Gibbon.GR.Localization.Packages
import Codeware.Localization.*

public class GR_th_th extends ModLocalizationPackage{

	protected func DefineTexts(){
        this.Text("GibbonGR-Title","Reinforcements Gang Vs Gang");
		this.Text("GibbonGR-Enabled-Name", "เปิดใช้งาน");
        this.Text("GibbonGR-EnabledInCombat-Name", "เปิดใช้งานเมื่อผู้เล่นอยู่ในสงคราม");
        this.Text("GibbonGR-EnabledWhenPlayerIsPassenger-Name", "เปิดใช้งานเมื่อผู้เล่นเป็นผู้โดยสาร");
        this.Text("GibbonGR-GracePeriodMin-Name", "ช่วงเวลาประนีประนอมขั้นต่ำ");
        this.Text("GibbonGR-GracePeriodMin-Description", "เวลาขั้นต่ำก่อนที่แก๊งจะสามารถเรียกกำลังเสริมครั้งแรกในการต่อสู้");
        this.Text("GibbonGR-GracePeriodMax-Name", "ช่วงเวลาประนีประนอมสูงสุด");
        this.Text("GibbonGR-GracePeriodMax-Description", "เวลาสูงสุดก่อนที่แก๊งจะสามารถเรียกกำลังเสริมครั้งแรกในการต่อสู้");
        this.Text("GibbonGR-CallSuccessCooldownMin-Name", "คูลดาวน์การเรียกขั้นต่ำ");
        this.Text("GibbonGR-CallSuccessCooldownMin-Description", "เวลาขั้นต่ำที่แก๊งต้องรอก่อนเรียกกำลังเสริมอีกครั้งในการต่อสู้เดียวกัน");
        this.Text("GibbonGR-CallSuccessCooldownMax-Name", "คูลดาวน์การเรียกสูงสุด");
        this.Text("GibbonGR-CallSuccessCooldownMax-Description", "เวลาสูงสุดที่แก๊งต้องรอก่อนเรียกกำลังเสริมอีกครั้งในการต่อสู้เดียวกัน");
        this.Text("GibbonGR-InitialHeat-Name", "ความร้อนเริ่มต้น");
        this.Text("GibbonGR-InitialHeat-Description", "การเรียกกำลังเสริมครั้งแรกจะแข็งแกร่งแค่ไหน");
        this.Text("GibbonGR-HeatEscalation-Name", "การเพิ่มขึ้นของความร้อน");
        this.Text("GibbonGR-HeatEscalation-Description", "ความร้อนเพิ่มขึ้นเท่าไหร่ต่อแก๊งต่อการเรียก");
        this.Text("GibbonGR-CallsLimit-Name", "ขีดจำกัดการเรียก");
        this.Text("GibbonGR-CallsLimit-Description", "จำนวนการเรียกที่แก๊งสามารถทำได้ก่อนต้องรอคูลดาวน์จำกัด");
        this.Text("GibbonGR-StrongCallChance-Name", "โอกาสการเรียกที่แข็งแกร่ง");
        this.Text("GibbonGR-StrongCallChance-Description", "โอกาสที่การเรียกกำลังเสริมครั้งต่อไปจะแข็งแกร่งกว่าระดับความร้อนปัจจุบัน");
        this.Text("GibbonGR-StrongCallHeatBonus-Name", "โบนัสความร้อนสำหรับการเรียกที่แข็งแกร่ง");
        this.Text("GibbonGR-StrongCallHeatBonus-Description", "การเรียกที่แข็งแกร่งจะมีความร้อนเพิ่มเติมเท่าไหร่");
        this.Text("GibbonGR-GracePeriod-Category", "ช่วงเวลาประนีประนอม");
        this.Text("GibbonGR-Cooldowns-Category", "คูลดาวน์");
        this.Text("GibbonGR-Heat-Category", "ความร้อน");

        // ==================== NEW SETTINGS LOCALIZATION ==================== //
        this.Text("GibbonGR-PresetMode-Name", "โหมดที่ตั้งไว้");
        this.Text("GibbonGR-PresetMode-Description", "เลือกจากโหมดที่ตั้งไว้สำหรับประสบการณ์การเล่นที่แตกต่างกัน");
        this.Text("GibbonGR-PresetMode-Limited", "จำกัด");
        this.Text("GibbonGR-PresetMode-Balanced", "สมดุล");
        this.Text("GibbonGR-PresetMode-RareBigFight", "การต่อสู้ใหญ่ที่หายาก");
        this.Text("GibbonGR-PresetMode-Chaos", "ความวุ่นวาย");
        this.Text("GibbonGR-ShowAdvancedSettings-Name", "แสดงการตั้งค่าขั้นสูง");
        this.Text("GibbonGR-ShowAdvancedSettings-Description", "แสดงการตั้งค่าขั้นสูงเพื่อปรับแต่งพารามิเตอร์แต่ละตัวอย่างละเอียด ใช้แทนโหมดที่ตั้งไว้");
        this.Text("GibbonGR-MinVehiclesPerCall-Name", "ยานพาหนะขั้นต่ำต่อการเรียก");
        this.Text("GibbonGR-MinVehiclesPerCall-Description", "จำนวนยานพาหนะขั้นต่ำที่ปรากฏในการเรียกกำลังเสริมครั้งเดียว");
        this.Text("GibbonGR-MaxVehiclesPerCall-Name", "ยานพาหนะสูงสุดต่อการเรียก");
        this.Text("GibbonGR-MaxVehiclesPerCall-Description", "จำนวนยานพาหนะสูงสุดที่สามารถปรากฏในการเรียกกำลังเสริมครั้งเดียว");
	}
}
