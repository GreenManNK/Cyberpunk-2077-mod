module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class Arabic extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === الخيارات العامة ===
		this.Text("AmmoLimiter-Settings-Title","محدد الذخيرة");
		this.Text("AmmoLimiter-Settings-Options","• الخيارات العامة");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","عرض الرسائل");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","عرض رسائل التحويل أو الإيداع أو استعادة الذخيرة.");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","حد صارم للذخيرة في المخزون");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","يسمح بالحد الصارم من النقل إلى المخزون، والشراء وتصنيع الذخيرة، على عكس الحد الناعم الافتراضي.");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","تحذير انخفاض الذخيرة (عتبة بالنسبة المئوية)");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","عندما تكون العتبة أكبر من 0%، يسمح بالتحذير عندما تكون الكمية المتبقية من ذخيرة السلاح المسحوب تحت العتبة.");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","تعطيل التفكيك اليدوي للذخيرة");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","يسمح بتعطيل إمكانية التفكيك اليدوي للذخيرة، دون تعطيل الآليات الأخرى للتعديل.");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","الاستعادة من التفكيك (% من المخزن)");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","يسمح بالحصول على الذخيرة عند تفكيك سلاح، حتى لو كان مكسوراً. كمية عشوائية بين 0 وهذه النسبة المئوية من السعة القصوى لمخزنه. مكمل لنظام الإعاقة.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","فئة عرض الذخيرة");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","اختر في أي فئة من المخزون لعرض الذخيرة والوصفات.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","الأسلحة بعيدة المدى");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","ملحقات الأسلحة");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","المواد الاستهلاكية القتالية");

		// === حدود الذخيرة ===
		this.Text("AmmoLimiter-Settings-Limits","• حدود الذخيرة في المخزون");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","تحكم الذخيرة النائمة");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","يمنع التراكم عن طريق جمع الذخيرة التي لا تتطابق مع السلاح النشط، المحولة مباشرة أو المسقطة على الأرض.");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","مكافأة حد السلاح النشط (بالنسبة المئوية)");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","يسمح بتجاوز الحد للذخيرة المقابلة للسلاح المجهز.");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","حد أقصى لذخيرة المسدس في المخزون، ينطبق فقط على الجمع والتصنيع.");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","حد أقصى لذخيرة السلاح الثقيل في المخزون، ينطبق فقط على الجمع والتصنيع.");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","حد أقصى لذخيرة البندقية في المخزون، ينطبق فقط على الجمع والتصنيع.");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","حد أقصى لذخيرة القناص في المخزون، ينطبق فقط على الجمع والتصنيع.");

		// === صناديق الذخيرة ===
		this.Text("AmmoLimiter-Settings-Box","• الكميات القصوى الموجودة في الصناديق");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","الكمية القصوى لذخيرة المسدس في كل صندوق في العالم.");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","الكمية القصوى لذخيرة السلاح الثقيل في كل صندوق في العالم.");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","الكمية القصوى لذخيرة البندقية في كل صندوق في العالم.");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","الكمية القصوى لذخيرة القناص في كل صندوق في العالم.");

		// === نظام الإعاقة ===
		this.Text("AmmoLimiter-Settings-Hand","• نظام الإعاقة");
		this.Text("AmmoLimiter-Settings-HandMode-Name","وضع الإعاقة");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","ينظم استعادة الذخيرة من الأعداء وفقاً لكميتك الحالية. الوضع \"المحسن\" محسوب من إعداداتك ومتوازن.");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","محسن (موصى به)");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","معطل");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","مخصص");

		// === إعاقة مخصصة حسب الذخيرة ===
		this.Text("AmmoLimiter-Settings-CustomHand","• إعاقة مخصصة حسب الذخيرة");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","مسدس - عتبة الإعاقة");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","مسدس - الحد الأدنى");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","مسدس - الحد الأقصى");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","سلاح ثقيل - عتبة الإعاقة");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","سلاح ثقيل - الحد الأدنى");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","سلاح ثقيل - الحد الأقصى");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","بندقية - عتبة الإعاقة");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","بندقية - الحد الأدنى");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","بندقية - الحد الأقصى");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","قناص - عتبة الإعاقة");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","قناص - الحد الأدنى");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","قناص - الحد الأقصى");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","عتبة تفعيل الإعاقة التي تحتها يمكن للغنائم إخفاء الذخيرة.");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","الحد الأدنى للذخيرة القابلة للاستعادة إذا كانت الإعاقة نشطة.");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","الحد الأقصى للذخيرة القابلة للاستعادة إذا كانت الإعاقة نشطة.");

		// === وزن الذخيرة ===
		this.Text("AmmoLimiter-Settings-Weight","• وزن الذخيرة");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","وزن ذخيرة المسدس الواحدة.");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","وزن ذخيرة السلاح الثقيل الواحدة.");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","وزن ذخيرة البندقية الواحدة.");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","وزن ذخيرة القناص الواحدة.");

		// === مضاعفات أسعار الذخيرة ===
		this.Text("AmmoLimiter-Settings-Eddies","• مضاعفات أسعار الذخيرة");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","مضاعف سعر شراء ذخيرة المسدس الواحدة بالإيدي.");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","مضاعف سعر شراء ذخيرة السلاح الثقيل الواحدة بالإيدي.");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","مضاعف سعر شراء ذخيرة البندقية الواحدة بالإيدي.");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","مضاعف سعر شراء ذخيرة القناص الواحدة بالإيدي.");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","بيع آلي للفائض (بالنسبة المئوية من سعر الشراء)");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","النسبة المئوية لسعر البيع الآلي المبني على السعر الخام للشراء (بدون خصم) للذخيرة الزائدة (0 = معطل).");

		// === التصنيع والتحويل ===
		this.Text("AmmoLimiter-Settings-Craft","• تصنيع دفعات الذخيرة");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","كمية ذخيرة المسدس لكل تصنيع دفعة.");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","كمية ذخيرة السلاح الثقيل لكل تصنيع دفعة.");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","كمية ذخيرة البندقية لكل تصنيع دفعة.");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","كمية ذخيرة القناص لكل تصنيع دفعة.");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","المكونات المطلوبة للتصنيع");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","كمية المكونات اللازمة لتصنيع دفعة واحدة من الذخيرة.");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","تحويل الذخيرة التلقائي (بالنسبة المئوية)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","نسبة التحويل التلقائي للذخيرة إلى مكونات.");

		// === النصوص داخل اللعبة ===
		this.Text("AmmoLimiter-Message-Dropped","أسقط على الأرض");
		this.Text("AmmoLimiter-Message-Crafted","تحول إلى");
		this.Text("AmmoLimiter-Message-Recovered","تم الاستعادة:");
		this.Text("AmmoLimiter-Message-From","من");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","تم الوصول إلى حد الذخيرة!");
		// يرجى احترام روح الدعابة الخاصة بي بعدم تغيير كلمة "PROUTS" أبداً:
		this.Text("AmmoLimiter-UI-LowAmmoWarning","احتياطي غير كافٍ من PROUTS !");
		this.Text("AmmoLimiter-UI-Total","إجمالي");
		this.Text("AmmoLimiter-UI-Unit","وحدة");
	}
}
