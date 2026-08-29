module Gibbon.GR.Localization.Packages
import Codeware.Localization.*

public class GR_ru_ru extends ModLocalizationPackage{

	protected func DefineTexts(){
        this.Text("GibbonGR-Title","Reinforcements Gang Vs Gang");
		this.Text("GibbonGR-Enabled-Name", "Включено");
        this.Text("GibbonGR-EnabledInCombat-Name", "Включено когда игрок в бою");
        this.Text("GibbonGR-EnabledWhenPlayerIsPassenger-Name", "Включено когда игрок пассажир");
        this.Text("GibbonGR-GracePeriodMin-Name", "Минимальный льготный период");
        this.Text("GibbonGR-GracePeriodMin-Description", "Минимальное время перед тем как банда может впервые вызвать подкрепление в бою");
        this.Text("GibbonGR-GracePeriodMax-Name", "Максимальный льготный период");
        this.Text("GibbonGR-GracePeriodMax-Description", "Максимальное время перед тем как банда может впервые вызвать подкрепление в бою");
        this.Text("GibbonGR-CallSuccessCooldownMin-Name", "Минимальный кулдаун вызова");
        this.Text("GibbonGR-CallSuccessCooldownMin-Description", "Минимальное время которое банда должна ждать перед повторным вызовом подкрепления в том же бою");
        this.Text("GibbonGR-CallSuccessCooldownMax-Name", "Максимальный кулдаун вызова");
        this.Text("GibbonGR-CallSuccessCooldownMax-Description", "Максимальное время которое банда должна ждать перед повторным вызовом подкрепления в том же бою");
        this.Text("GibbonGR-InitialHeat-Name", "Начальная жара");
        this.Text("GibbonGR-InitialHeat-Description", "Насколько сильным будет первый вызов подкрепления");
        this.Text("GibbonGR-HeatEscalation-Name", "Эскалация жары");
        this.Text("GibbonGR-HeatEscalation-Description", "На сколько увеличивается жара на банду за вызов");
        this.Text("GibbonGR-CallsLimit-Name", "Лимит вызовов");
        this.Text("GibbonGR-CallsLimit-Description", "Количество вызовов которое банда может сделать перед тем как должна ждать лимит кулдаун");
        this.Text("GibbonGR-StrongCallChance-Name", "Шанс сильного вызова");
        this.Text("GibbonGR-StrongCallChance-Description", "Шанс что следующий вызов подкрепления будет сильнее текущего уровня жары");
        this.Text("GibbonGR-StrongCallHeatBonus-Name", "Бонус жары за сильный вызов");
        this.Text("GibbonGR-StrongCallHeatBonus-Description", "Сколько дополнительной жары будет у сильного вызова");
        this.Text("GibbonGR-GracePeriod-Category", "Льготный период");
        this.Text("GibbonGR-Cooldowns-Category", "Кулдауны");
        this.Text("GibbonGR-Heat-Category", "Жара");

        // ==================== NEW SETTINGS LOCALIZATION ==================== //
        this.Text("GibbonGR-PresetMode-Name", "Режим настроек");
        this.Text("GibbonGR-PresetMode-Description", "Выберите из режимов настроек для разного игрового опыта");
        this.Text("GibbonGR-PresetMode-Limited", "Ограниченный");
        this.Text("GibbonGR-PresetMode-Balanced", "Сбалансированный");
        this.Text("GibbonGR-PresetMode-RareBigFight", "Редкие Крупные Бои");
        this.Text("GibbonGR-PresetMode-Chaos", "Хаос");
        this.Text("GibbonGR-ShowAdvancedSettings-Name", "Показать расширенные настройки");
        this.Text("GibbonGR-ShowAdvancedSettings-Description", "Показать расширенные настройки для точной настройки отдельных параметров. Переопределяет режим настроек.");
        this.Text("GibbonGR-MinVehiclesPerCall-Name", "Минимум транспорта на вызов");
        this.Text("GibbonGR-MinVehiclesPerCall-Description", "Минимальное количество транспорта которое появляется в одном вызове подкрепления");
        this.Text("GibbonGR-MaxVehiclesPerCall-Name", "Максимум транспорта на вызов");
        this.Text("GibbonGR-MaxVehiclesPerCall-Description", "Максимальное количество транспорта которое может появиться в одном вызове подкрепления");
	}
}
