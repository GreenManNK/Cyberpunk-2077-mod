module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class Thai extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === ตัวเลือกทั่วไป ===
		this.Text("AmmoLimiter-Settings-Title","ตัวจำกัดกระสุน");
		this.Text("AmmoLimiter-Settings-Options","• ตัวเลือกทั่วไป");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","แสดงข้อความ");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","แสดงข้อความการแปลง การเก็บ หรือการกู้คืนกระสุน");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","การจำกัดกระสุนในคลังอย่างเข้มงวด");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","อนุญาตให้จำกัดการถ่ายโอนไปยังคลัง การซื้อ และการผลิตกระสุนอย่างเข้มงวด ต่างจากการจำกัดแบบนุ่มเริ่มต้น");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","การเตือนกระสุนน้อย (เกณฑ์ใน %)");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","เมื่อเกณฑ์มากกว่า 0% อนุญาตให้เตือนเมื่อจำนวนกระสุนที่เหลือของอาวุธที่ชักออกมาอยู่ต่ำกว่าเกณฑ์");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","ปิดการถอดแยกกระสุนด้วยมือ");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","อนุญาตให้ปิดความเป็นไปได้ในการถอดแยกกระสุนด้วยมือ โดยไม่ปิดกลไกอื่นๆ ของม็อด");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","การกู้คืนจากการถอดแยก (% ของแม็กกาซีน)");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","อนุญาตให้ได้กระสุนเมื่อถอดแยกอาวุธ แม้แต่ที่เสียหาย จำนวนสุ่มระหว่าง 0 ถึง % นี้ของความจุสูงสุดของแม็กกาซีน เสริมระบบแฮนดิแคป");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","หมวดหมู่การแสดงกระสุน");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","เลือกว่าจะแสดงกระสุนและสูตรในหมวดหมู่คลังไหน");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","อาวุธระยะไกล");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","อุปกรณ์เสริมอาวุธ");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","วัสดุสิ้นเปลืองการต่อสู้");

		// === ขีดจำกัดกระสุน ===
		this.Text("AmmoLimiter-Settings-Limits","• ขีดจำกัดกระสุนในคลัง");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","การควบคุมกระสุนเฉยๆ");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","ป้องกันการสะสมโดยการเก็บกระสุนที่ไม่ตรงกับอาวุธที่ใช้งาน แปลงโดยตรงหรือทิ้งลงพื้น");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","โบนัสขีดจำกัดอาวุธที่ใช้งาน (ใน %)");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","อนุญาตให้เกินขีดจำกัดสำหรับกระสุนที่ตรงกับอาวุธที่สวมใส่");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","กระสุนปืนพกสูงสุดในคลัง ใช้เฉพาะกับการเก็บและการผลิต");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","กระสุนอาวุธหนักสูงสุดในคลัง ใช้เฉพาะกับการเก็บและการผลิต");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","กระสุนปืนลูกซองสูงสุดในคลัง ใช้เฉพาะกับการเก็บและการผลิต");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","กระสุนปืนสไนเปอร์สูงสุดในคลัง ใช้เฉพาะกับการเก็บและการผลิต");

		// === กล่องกระสุน ===
		this.Text("AmmoLimiter-Settings-Box","• จำนวนสูงสุดที่พบในกล่อง");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","จำนวนกระสุนปืนพกสูงสุดในแต่ละกล่องในโลก");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","จำนวนกระสุนอาวุธหนักสูงสุดในแต่ละกล่องในโลก");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","จำนวนกระสุนปืนลูกซองสูงสุดในแต่ละกล่องในโลก");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","จำนวนกระสุนปืนสไนเปอร์สูงสุดในแต่ละกล่องในโลก");

		// === ระบบแฮนดิแคป ===
		this.Text("AmmoLimiter-Settings-Hand","• ระบบแฮนดิแคป");
		this.Text("AmmoLimiter-Settings-HandMode-Name","โหมดแฮนดิแคป");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","ควบคุมการกู้คืนกระสุนจากศัตรูตามจำนวนปัจจุบันของคุณ โหมด \"ปรับให้เหมาะสม\" คำนวณจากการตั้งค่าของคุณและมีความสมดุล");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","ปรับให้เหมาะสม (แนะนำ)");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","ปิดใช้งาน");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","กำหนดเอง");

		// === แฮนดิแคปกำหนดเองตามกระสุน ===
		this.Text("AmmoLimiter-Settings-CustomHand","• แฮนดิแคปกำหนดเองตามกระสุน");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","ปืนพก - เกณฑ์แฮนดิแคป");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","ปืนพก - ขั้นต่ำ");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","ปืนพก - สูงสุด");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","อาวุธหนัก - เกณฑ์แฮนดิแคป");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","อาวุธหนัก - ขั้นต่ำ");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","อาวุธหนัก - สูงสุด");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","ปืนลูกซอง - เกณฑ์แฮนดิแคป");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","ปืนลูกซอง - ขั้นต่ำ");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","ปืนลูกซอง - สูงสุด");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","ปืนสไนเปอร์ - เกณฑ์แฮนดิแคป");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","ปืนสไนเปอร์ - ขั้นต่ำ");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","ปืนสไนเปอร์ - สูงสุด");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","เกณฑ์เปิดใช้งานแฮนดิแคปที่ต่ำกว่านี้ลูทสามารถซ่อนกระสุน");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","ขั้นต่ำของกระสุนที่กู้คืนได้หากแฮนดิแคปเปิดใช้งาน");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","สูงสุดของกระสุนที่กู้คืนได้หากแฮนดิแคปเปิดใช้งาน");

		// === น้ำหนักกระสุน ===
		this.Text("AmmoLimiter-Settings-Weight","• น้ำหนักกระสุน");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","น้ำหนักของกระสุนปืนพกหนึ่งนัด");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","น้ำหนักของกระสุนอาวุธหนักหนึ่งนัด");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","น้ำหนักของกระสุนปืนลูกซองหนึ่งนัด");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","น้ำหนักของกระสุนปืนสไนเปอร์หนึ่งนัด");

		// === ตัวคูณราคากระสุน ===
		this.Text("AmmoLimiter-Settings-Eddies","• ตัวคูณราคากระสุน");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","ตัวคูณราคาซื้อสำหรับกระสุนปืนพกหนึ่งนัดในเอ็ดดี้");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","ตัวคูณราคาซื้อสำหรับกระสุนอาวุธหนักหนึ่งนัดในเอ็ดดี้");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","ตัวคูณราคาซื้อสำหรับกระสุนปืนลูกซองหนึ่งนัดในเอ็ดดี้");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","ตัวคูณราคาซื้อสำหรับกระสุนปืนสไนเปอร์หนึ่งนัดในเอ็ดดี้");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","การขายส่วนเกินอัตโนมัติ (ใน % ของราคาซื้อ)");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","เปอร์เซ็นต์ของราคาขายอัตโนมัติขึ้นอยู่กับราคาซื้อดิบ (ไม่มีส่วนลด) สำหรับกระสุนส่วนเกิน (0 = ปิดใช้งาน)");

		// === การผลิตและการแปลง ===
		this.Text("AmmoLimiter-Settings-Craft","• การผลิตชุดกระสุน");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","จำนวนกระสุนปืนพกต่อการผลิตชุด");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","จำนวนกระสุนอาวุธหนักต่อการผลิตชุด");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","จำนวนกระสุนปืนลูกซองต่อการผลิตชุด");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","จำนวนกระสุนปืนสไนเปอร์ต่อการผลิตชุด");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","ส่วนประกอบที่ต้องการสำหรับการผลิต");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","จำนวนส่วนประกอบที่จำเป็นในการผลิตกระสุน 1 ชุด");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","การแปลงกระสุนอัตโนมัติ (เป็นเปอร์เซ็นต์)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","เปอร์เซ็นต์การแปลงกระสุนอัตโนมัติเป็นส่วนประกอบ");

		// === ข้อความในเกม ===
		this.Text("AmmoLimiter-Message-Dropped","ทิ้งลงพื้น");
		this.Text("AmmoLimiter-Message-Crafted","แปลงเป็น");
		this.Text("AmmoLimiter-Message-Recovered","กู้คืน:");
		this.Text("AmmoLimiter-Message-From","จาก");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","ถึงขีดจำกัดกระสุนแล้ว!");
		// โปรดเคารพอารมณ์ขันของฉันโดยไม่เปลี่ยนคำว่า "PROUTS" เด็ดขาด:
		this.Text("AmmoLimiter-UI-LowAmmoWarning","สำรองไม่เพียงพอของ PROUTS!");
		this.Text("AmmoLimiter-UI-Total","รวม");
		this.Text("AmmoLimiter-UI-Unit","หน่วย");
	}
}
