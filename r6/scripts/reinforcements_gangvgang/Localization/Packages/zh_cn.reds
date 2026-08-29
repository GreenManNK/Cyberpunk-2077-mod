module Gibbon.GR.Localization.Packages
import Codeware.Localization.*

public class GR_zh_cn extends ModLocalizationPackage{

	protected func DefineTexts(){
        this.Text("GibbonGR-Title","Reinforcements Gang Vs Gang");
		this.Text("GibbonGR-Enabled-Name", "启用");
        this.Text("GibbonGR-EnabledInCombat-Name", "玩家战斗时启用");
        this.Text("GibbonGR-EnabledWhenPlayerIsPassenger-Name", "玩家为乘客时启用");
        this.Text("GibbonGR-GracePeriodMin-Name", "最小宽限时间");
        this.Text("GibbonGR-GracePeriodMin-Description", "帮派在战斗中首次呼叫支援前的最短时间");
        this.Text("GibbonGR-GracePeriodMax-Name", "最大宽限时间");
        this.Text("GibbonGR-GracePeriodMax-Description", "帮派在战斗中首次呼叫支援前的最大时间");
        this.Text("GibbonGR-CallSuccessCooldownMin-Name", "最小呼叫冷却");
        this.Text("GibbonGR-CallSuccessCooldownMin-Description", "帮派在同一战斗中再次呼叫支援前必须等待的最短时间");
        this.Text("GibbonGR-CallSuccessCooldownMax-Name", "最大呼叫冷却");
        this.Text("GibbonGR-CallSuccessCooldownMax-Description", "帮派在同一战斗中再次呼叫支援前必须等待的最大时间");
        this.Text("GibbonGR-InitialHeat-Name", "初始热度");
        this.Text("GibbonGR-InitialHeat-Description", "第一次支援呼叫的强度");
        this.Text("GibbonGR-HeatEscalation-Name", "热度升级");
        this.Text("GibbonGR-HeatEscalation-Description", "每个帮派每次呼叫的热度增加量");
        this.Text("GibbonGR-CallsLimit-Name", "呼叫限制");
        this.Text("GibbonGR-CallsLimit-Description", "帮派在必须等待限制冷却前可以进行的呼叫次数");
        this.Text("GibbonGR-StrongCallChance-Name", "强力呼叫几率");
        this.Text("GibbonGR-StrongCallChance-Description", "下一次支援呼叫比当前热度等级更强的几率");
        this.Text("GibbonGR-StrongCallHeatBonus-Name", "强力呼叫热度奖励");
        this.Text("GibbonGR-StrongCallHeatBonus-Description", "强力呼叫将获得的额外热度");
        this.Text("GibbonGR-GracePeriod-Category", "宽限时间");
        this.Text("GibbonGR-Cooldowns-Category", "冷却时间");
        this.Text("GibbonGR-Heat-Category", "热度");

        // ==================== NEW SETTINGS LOCALIZATION ==================== //
        this.Text("GibbonGR-PresetMode-Name", "预设模式");
        this.Text("GibbonGR-PresetMode-Description", "为不同的游戏体验选择预设模式");
        this.Text("GibbonGR-PresetMode-Limited", "有限");
        this.Text("GibbonGR-PresetMode-Balanced", "平衡");
        this.Text("GibbonGR-PresetMode-RareBigFight", "偶尔大型战斗");
        this.Text("GibbonGR-PresetMode-Chaos", "混乱");
        this.Text("GibbonGR-ShowAdvancedSettings-Name", "显示高级设置");
        this.Text("GibbonGR-ShowAdvancedSettings-Description", "显示高级设置以微调各个参数。覆盖预设模式。");
        this.Text("GibbonGR-MinVehiclesPerCall-Name", "每次呼叫最小载具数");
        this.Text("GibbonGR-MinVehiclesPerCall-Description", "单次支援呼叫中生成的最小载具数量");
        this.Text("GibbonGR-MaxVehiclesPerCall-Name", "每次呼叫最大载具数");
        this.Text("GibbonGR-MaxVehiclesPerCall-Description", "单次支援呼叫中可生成的最大载具数量");
	}
}
