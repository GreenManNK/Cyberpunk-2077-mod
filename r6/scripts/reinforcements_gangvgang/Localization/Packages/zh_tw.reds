module Gibbon.GR.Localization.Packages
import Codeware.Localization.*

public class GR_zh_tw extends ModLocalizationPackage{

	protected func DefineTexts(){
        this.Text("GibbonGR-Title","Reinforcements Gang Vs Gang");
		this.Text("GibbonGR-Enabled-Name", "啟用");
        this.Text("GibbonGR-EnabledInCombat-Name", "玩家戰鬥時啟用");
        this.Text("GibbonGR-EnabledWhenPlayerIsPassenger-Name", "玩家為乘客時啟用");
        this.Text("GibbonGR-GracePeriodMin-Name", "最小寬限時間");
        this.Text("GibbonGR-GracePeriodMin-Description", "幫派在戰鬥中首次呼叫支援前的最短時間");
        this.Text("GibbonGR-GracePeriodMax-Name", "最大寬限時間");
        this.Text("GibbonGR-GracePeriodMax-Description", "幫派在戰鬥中首次呼叫支援前的最大時間");
        this.Text("GibbonGR-CallSuccessCooldownMin-Name", "最小呼叫冷卻");
        this.Text("GibbonGR-CallSuccessCooldownMin-Description", "幫派在同一戰鬥中再次呼叫支援前必須等待的最短時間");
        this.Text("GibbonGR-CallSuccessCooldownMax-Name", "最大呼叫冷卻");
        this.Text("GibbonGR-CallSuccessCooldownMax-Description", "幫派在同一戰鬥中再次呼叫支援前必須等待的最大時間");
        this.Text("GibbonGR-InitialHeat-Name", "初始熱度");
        this.Text("GibbonGR-InitialHeat-Description", "第一次支援呼叫的強度");
        this.Text("GibbonGR-HeatEscalation-Name", "熱度升級");
        this.Text("GibbonGR-HeatEscalation-Description", "每個幫派每次呼叫的熱度增加量");
        this.Text("GibbonGR-CallsLimit-Name", "呼叫限制");
        this.Text("GibbonGR-CallsLimit-Description", "幫派在必須等待限制冷卻前可以進行的呼叫次數");
        this.Text("GibbonGR-StrongCallChance-Name", "強力呼叫機率");
        this.Text("GibbonGR-StrongCallChance-Description", "下一次支援呼叫比當前熱度等級更強的機率");
        this.Text("GibbonGR-StrongCallHeatBonus-Name", "強力呼叫熱度獎勵");
        this.Text("GibbonGR-StrongCallHeatBonus-Description", "強力呼叫將獲得的額外熱度");
        this.Text("GibbonGR-GracePeriod-Category", "寬限時間");
        this.Text("GibbonGR-Cooldowns-Category", "冷卻時間");
        this.Text("GibbonGR-Heat-Category", "熱度");

        // ==================== NEW SETTINGS LOCALIZATION ==================== //
        this.Text("GibbonGR-PresetMode-Name", "預設模式");
        this.Text("GibbonGR-PresetMode-Description", "為不同的遊戲體驗選擇預設模式");
        this.Text("GibbonGR-PresetMode-Limited", "有限");
        this.Text("GibbonGR-PresetMode-Balanced", "平衡");
        this.Text("GibbonGR-PresetMode-RareBigFight", "偶爾大型戰鬥");
        this.Text("GibbonGR-PresetMode-Chaos", "混亂");
        this.Text("GibbonGR-ShowAdvancedSettings-Name", "顯示進階設定");
        this.Text("GibbonGR-ShowAdvancedSettings-Description", "顯示進階設定以微調各個參數。覆蓋預設模式。");
        this.Text("GibbonGR-MinVehiclesPerCall-Name", "每次呼叫最小載具數");
        this.Text("GibbonGR-MinVehiclesPerCall-Description", "單次支援呼叫中生成的最小載具數量");
        this.Text("GibbonGR-MaxVehiclesPerCall-Name", "每次呼叫最大載具數");
        this.Text("GibbonGR-MaxVehiclesPerCall-Description", "單次支援呼叫中可生成的最大載具數量");
	}
}
