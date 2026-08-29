module Gibbon.GR.Localization.Packages
import Codeware.Localization.*

public class GR_ua_ua extends ModLocalizationPackage{

	protected func DefineTexts(){
        this.Text("GibbonGR-Title","Reinforcements Gang Vs Gang");
		this.Text("GibbonGR-Enabled-Name", "Увімкнено");
        this.Text("GibbonGR-EnabledInCombat-Name", "Увімкнено коли гравець в бою");
        this.Text("GibbonGR-EnabledWhenPlayerIsPassenger-Name", "Увімкнено коли гравець пасажир");
        this.Text("GibbonGR-GracePeriodMin-Name", "Мінімальний період затишшя");
        this.Text("GibbonGR-GracePeriodMin-Description", "Мінімальний час перед тим як банда може вперше викликати підкріплення в бою");
        this.Text("GibbonGR-GracePeriodMax-Name", "Максимальний період затишшя");
        this.Text("GibbonGR-GracePeriodMax-Description", "Максимальний час перед тим як банда може вперше викликати підкріплення в бою");
        this.Text("GibbonGR-CallSuccessCooldownMin-Name", "Мінімальний кулдаун виклику");
        this.Text("GibbonGR-CallSuccessCooldownMin-Description", "Мінімальний час який банда повинна чекати перед повторним викликом підкріплення в тому ж бою");
        this.Text("GibbonGR-CallSuccessCooldownMax-Name", "Максимальний кулдаун виклику");
        this.Text("GibbonGR-CallSuccessCooldownMax-Description", "Максимальний час який банда повинна чекати перед повторним викликом підкріплення в тому ж бою");
        this.Text("GibbonGR-InitialHeat-Name", "Початкова напруга");
        this.Text("GibbonGR-InitialHeat-Description", "Наскільки сильним буде перший виклик підкріплення");
        this.Text("GibbonGR-HeatEscalation-Name", "Ескалація напруги");
        this.Text("GibbonGR-HeatEscalation-Description", "На скільки збільшується напруга на банду за виклик");
        this.Text("GibbonGR-CallsLimit-Name", "Ліміт викликів");
        this.Text("GibbonGR-CallsLimit-Description", "Кількість викликів яку банда може зробити перед тим як повинна чекати ліміт кулдаун");
        this.Text("GibbonGR-StrongCallChance-Name", "Шанс сильного виклику");
        this.Text("GibbonGR-StrongCallChance-Description", "Шанс що наступний виклик підкріплення буде сильнішим за поточний рівень напруги");
        this.Text("GibbonGR-StrongCallHeatBonus-Name", "Бонус напруги за сильний виклик");
        this.Text("GibbonGR-StrongCallHeatBonus-Description", "Скільки додаткової напруги буде у сильного виклику");
        this.Text("GibbonGR-GracePeriod-Category", "Період затишшя");
        this.Text("GibbonGR-Cooldowns-Category", "Кулдауни");
        this.Text("GibbonGR-Heat-Category", "Напруга");

        // ==================== NEW SETTINGS LOCALIZATION ==================== //
        this.Text("GibbonGR-PresetMode-Name", "Режим налаштувань");
        this.Text("GibbonGR-PresetMode-Description", "Оберіть з режимів налаштувань для різного ігрового досвіду");
        this.Text("GibbonGR-PresetMode-Limited", "Обмежений");
        this.Text("GibbonGR-PresetMode-Balanced", "Збалансований");
        this.Text("GibbonGR-PresetMode-RareBigFight", "Рідкісні Великі Бої");
        this.Text("GibbonGR-PresetMode-Chaos", "Хаос");
        this.Text("GibbonGR-ShowAdvancedSettings-Name", "Показати розширені налаштування");
        this.Text("GibbonGR-ShowAdvancedSettings-Description", "Показати розширені налаштування для точного налаштування окремих параметрів. Перевизначає режим налаштувань.");
        this.Text("GibbonGR-MinVehiclesPerCall-Name", "Мінімум транспорту на виклик");
        this.Text("GibbonGR-MinVehiclesPerCall-Description", "Мінімальна кількість транспорту яка з'являється в одному виклику підкріплення");
        this.Text("GibbonGR-MaxVehiclesPerCall-Name", "Максимум транспорту на виклик");
        this.Text("GibbonGR-MaxVehiclesPerCall-Description", "Максимальна кількість транспорту яка може з'явитися в одному виклику підкріплення");
	}
}
