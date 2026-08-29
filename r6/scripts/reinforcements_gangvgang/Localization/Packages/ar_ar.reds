module Gibbon.GR.Localization.Packages
import Codeware.Localization.*

public class GR_ar_ar extends ModLocalizationPackage{

	protected func DefineTexts(){
        this.Text("GibbonGR-Title","Reinforcements Gang Vs Gang");
		this.Text("GibbonGR-Enabled-Name", "مفعل");
        this.Text("GibbonGR-EnabledInCombat-Name", "مفعل عندما يكون اللاعب في قتال");
        this.Text("GibbonGR-EnabledWhenPlayerIsPassenger-Name", "مفعل عندما يكون اللاعب راكب");
        this.Text("GibbonGR-GracePeriodMin-Name", "فترة السماح الدنيا");
        this.Text("GibbonGR-GracePeriodMin-Description", "الحد الأدنى للوقت قبل أن تتمكن العصابة من طلب الدعم لأول مرة في قتال");
        this.Text("GibbonGR-GracePeriodMax-Name", "فترة السماح القصوى");
        this.Text("GibbonGR-GracePeriodMax-Description", "الحد الأقصى للوقت قبل أن تتمكن العصابة من طلب الدعم لأول مرة في قتال");
        this.Text("GibbonGR-CallSuccessCooldownMin-Name", "الحد الأدنى لوقت انتظار الاستدعاء");
        this.Text("GibbonGR-CallSuccessCooldownMin-Description", "الحد الأدنى للوقت الذي يجب أن تنتظره العصابة قبل طلب الدعم مرة أخرى في نفس القتال");
        this.Text("GibbonGR-CallSuccessCooldownMax-Name", "الحد الأقصى لوقت انتظار الاستدعاء");
        this.Text("GibbonGR-CallSuccessCooldownMax-Description", "الحد الأقصى للوقت الذي يجب أن تنتظره العصابة قبل طلب الدعم مرة أخرى في نفس القتال");
        this.Text("GibbonGR-InitialHeat-Name", "الحرارة الأولية");
        this.Text("GibbonGR-InitialHeat-Description", "مدى قوة استدعاء الدعم الأول");
        this.Text("GibbonGR-HeatEscalation-Name", "تصعيد الحرارة");
        this.Text("GibbonGR-HeatEscalation-Description", "مقدار زيادة الحرارة لكل عصابة لكل استدعاء");
        this.Text("GibbonGR-CallsLimit-Name", "حد الاستدعاءات");
        this.Text("GibbonGR-CallsLimit-Description", "عدد الاستدعاءات التي يمكن للعصابة القيام بها قبل أن تضطر لانتظار وقت انتظار الحد");
        this.Text("GibbonGR-StrongCallChance-Name", "فرصة الاستدعاء القوي");
        this.Text("GibbonGR-StrongCallChance-Description", "احتمالية أن يكون استدعاء الدعم التالي أقوى من مستوى الحرارة الحالي");
        this.Text("GibbonGR-StrongCallHeatBonus-Name", "مكافأة الحرارة للاستدعاء القوي");
        this.Text("GibbonGR-StrongCallHeatBonus-Description", "كم من الحرارة الإضافية ستحصل عليها الاستدعاءات القوية");
        this.Text("GibbonGR-GracePeriod-Category", "فترة السماح");
        this.Text("GibbonGR-Cooldowns-Category", "أوقات الانتظار");
        this.Text("GibbonGR-Heat-Category", "الحرارة");

        // ==================== NEW SETTINGS LOCALIZATION ==================== //
        this.Text("GibbonGR-PresetMode-Name", "وضع الإعدادات المحددة مسبقاً");
        this.Text("GibbonGR-PresetMode-Description", "اختر من الأوضاع المحددة مسبقاً لتجارب لعب مختلفة");
        this.Text("GibbonGR-PresetMode-Limited", "خفيف");
        this.Text("GibbonGR-PresetMode-Balanced", "متوازن");
        this.Text("GibbonGR-PresetMode-RareBigFight", "نادر ومثير");
        this.Text("GibbonGR-PresetMode-Chaos", "فوضى");
        this.Text("GibbonGR-ShowAdvancedSettings-Name", "إظهار الإعدادات المتقدمة");
        this.Text("GibbonGR-ShowAdvancedSettings-Description", "إظهار الإعدادات المتقدمة لضبط المعاملات الفردية بدقة. يتجاوز وضع الإعدادات المحددة مسبقاً.");
        this.Text("GibbonGR-MinVehiclesPerCall-Name", "الحد الأدنى للمركبات لكل استدعاء");
        this.Text("GibbonGR-MinVehiclesPerCall-Description", "الحد الأدنى لعدد المركبات التي تظهر في استدعاء دعم واحد");
        this.Text("GibbonGR-MaxVehiclesPerCall-Name", "الحد الأقصى للمركبات لكل استدعاء");
        this.Text("GibbonGR-MaxVehiclesPerCall-Description", "الحد الأقصى لعدد المركبات التي يمكن أن تظهر في استدعاء دعم واحد");
	}
}
