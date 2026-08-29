module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class ChineseTraditional extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === 通用選項 ===
		this.Text("AmmoLimiter-Settings-Title","彈藥限制器");
		this.Text("AmmoLimiter-Settings-Options","• 通用選項");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","顯示訊息");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","顯示彈藥轉換、存放或回收訊息。");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","庫存中彈藥的嚴格限制");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","允許嚴格限制向庫存的轉移、購買和製造彈藥，與預設的軟限制相反。");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","低彈藥量警告（百分比閾值）");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","當閾值大於0%時，允許在所拔出武器的剩餘彈藥量低於閾值時發出警告。");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","禁用手動拆解彈藥");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","允許禁用手動拆解彈藥的可能性，而不禁用模組的其他機制。");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","從拆解中回收（彈匣百分比）");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","允許在拆解武器時獲得彈藥，即使是破損的武器。介於0和其彈匣最大容量百分比之間的隨機數量。補充殘疾系統。");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","彈藥顯示類別");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","選擇在哪個庫存類別中顯示彈藥和配方。");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","遠程武器");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","武器附件");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","戰鬥消耗品");

		// === 彈藥限制 ===
		this.Text("AmmoLimiter-Settings-Limits","• 庫存中的彈藥限制");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","休眠彈藥控制");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","防止通過拾取不匹配活動武器的彈藥進行累積，直接轉換或掉落到地面。");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","活動武器限制獎勵（百分比）");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","允許為裝備武器對應的彈藥超過限制。");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","庫存中手槍彈藥的最大值，僅適用於拾取和製造。");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","庫存中重型武器彈藥的最大值，僅適用於拾取和製造。");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","庫存中霰彈槍彈藥的最大值，僅適用於拾取和製造。");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","庫存中狙擊槍彈藥的最大值，僅適用於拾取和製造。");

		// === 彈藥箱 ===
		this.Text("AmmoLimiter-Settings-Box","• 箱子中發現的最大數量");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","世界中每個箱子裡手槍彈藥的最大數量。");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","世界中每個箱子裡重型武器彈藥的最大數量。");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","世界中每個箱子裡霰彈槍彈藥的最大數量。");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","世界中每個箱子裡狙擊槍彈藥的最大數量。");

		// === 殘疾系統 ===
		this.Text("AmmoLimiter-Settings-Hand","• 殘疾系統");
		this.Text("AmmoLimiter-Settings-HandMode-Name","殘疾模式");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","根據您當前的數量調節從敵人那裡回收彈藥。\"優化\"模式是根據您的設置計算的，並且是平衡的。");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","優化（推薦）");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","禁用");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","自定義");

		// === 按彈藥自定義殘疾 ===
		this.Text("AmmoLimiter-Settings-CustomHand","• 按彈藥自定義殘疾");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","手槍 - 殘疾閾值");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","手槍 - 最小值");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","手槍 - 最大值");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","重型武器 - 殘疾閾值");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","重型武器 - 最小值");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","重型武器 - 最大值");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","霰彈槍 - 殘疾閾值");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","霰彈槍 - 最小值");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","霰彈槍 - 最大值");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","狙擊槍 - 殘疾閾值");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","狙擊槍 - 最小值");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","狙擊槍 - 最大值");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","殘疾觸發閾值，低於此值戰利品可以隱藏彈藥。");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","如果殘疾處於活動狀態，可回收彈藥的最小值。");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","如果殘疾處於活動狀態，可回收彈藥的最大值。");

		// === 彈藥重量 ===
		this.Text("AmmoLimiter-Settings-Weight","• 彈藥重量");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","一發手槍彈藥的重量。");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","一發重型武器彈藥的重量。");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","一發霰彈槍彈藥的重量。");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","一發狙擊槍彈藥的重量。");

		// === 彈藥價格倍數 ===
		this.Text("AmmoLimiter-Settings-Eddies","• 彈藥價格倍數");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","一發手槍彈藥的購買價格倍數（歐元）。");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","一發重型武器彈藥的購買價格倍數（歐元）。");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","一發霰彈槍彈藥的購買價格倍數（歐元）。");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","一發狙擊槍彈藥的購買價格倍數（歐元）。");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","自動出售過量（購買價格的百分比）");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","基於原始購買價格（無折扣）的自動銷售價格百分比，用於過量彈藥（0 = 禁用）。");

		// === 製造和轉換 ===
		this.Text("AmmoLimiter-Settings-Craft","• 彈藥批次製造");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","每個製造批次的手槍彈藥數量。");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","每個製造批次的重型武器彈藥數量。");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","每個製造批次的霰彈槍彈藥數量。");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","每個製造批次的狙擊槍彈藥數量。");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","製造所需組件");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","製造1批彈藥所需的組件數量。");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","自動彈藥轉換 (百分比)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","彈藥自動轉換為組件的百分比。");

		// === 遊戲內文本 ===
		this.Text("AmmoLimiter-Message-Dropped","丟棄到地面");
		this.Text("AmmoLimiter-Message-Crafted","轉換為");
		this.Text("AmmoLimiter-Message-Recovered","已回收：");
		this.Text("AmmoLimiter-Message-From","自");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","已達到彈藥限制！");
		// 請尊重我的幽默感，永遠不要修改"PROUTS"這個詞：
		this.Text("AmmoLimiter-UI-LowAmmoWarning","PROUTS 儲備不足！");
		this.Text("AmmoLimiter-UI-Total","總計");
		this.Text("AmmoLimiter-UI-Unit","單位");
	}
}
