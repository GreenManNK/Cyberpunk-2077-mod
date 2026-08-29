module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class Russian extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === ОБЩИЕ ОПЦИИ ===
		this.Text("AmmoLimiter-Settings-Title","Ограничитель Боеприпасов");
		this.Text("AmmoLimiter-Settings-Options","• Общие опции");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","Показывать сообщения");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","Показывать сообщения о конвертации, хранении или восстановлении боеприпасов.");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","Строгое ограничение боеприпасов в инвентаре");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","Позволяет строго ограничить передачи в инвентарь, покупки и изготовление боеприпасов, в отличие от мягкого ограничения по умолчанию.");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","Предупреждение о малом количестве боеприпасов (порог в %)");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","Когда порог больше 0%, позволяет предупреждать, когда оставшееся количество боеприпасов вытащенного оружия ниже порога.");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","Отключить ручную разборку боеприпасов");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","Позволяет отключить возможность ручной разборки боеприпасов, не отключая другие механизмы мода.");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","Восстановление от разборки (% от магазина)");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","Позволяет получить боеприпасы при разборке оружия, даже сломанного. Случайное количество между 0 и этим % от максимальной емкости его магазина. Дополняет систему гандикапа.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","Категория отображения боеприпасов");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","Выберите в какой категории инвентаря отображать боеприпасы и рецепты.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","Дальнобойное оружие");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","Аксессуары для оружия");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","Боевые расходники");

		// === ЛИМИТЫ БОЕПРИПАСОВ ===
		this.Text("AmmoLimiter-Settings-Limits","• Лимиты боеприпасов в инвентаре");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","Контроль спящих боеприпасов");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","Предотвращает накопление подбором боеприпасов, не соответствующих активному оружию, напрямую конвертированных или брошенных на землю.");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","Бонус лимита активного оружия (в %)");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","Позволяет превысить лимит для боеприпасов, соответствующих экипированному оружию.");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","Максимум боеприпасов для пистолета в инвентаре, применяется только к подбору и изготовлению.");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","Максимум боеприпасов для тяжелого оружия в инвентаре, применяется только к подбору и изготовлению.");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","Максимум боеприпасов для дробовика в инвентаре, применяется только к подбору и изготовлению.");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","Максимум боеприпасов для снайперской винтовки в инвентаре, применяется только к подбору и изготовлению.");

		// === ЯЩИКИ С БОЕПРИПАСАМИ ===
		this.Text("AmmoLimiter-Settings-Box","• Максимальные количества найденные в ящиках");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","Максимальное количество боеприпасов для пистолета в каждом ящике в мире.");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","Максимальное количество боеприпасов для тяжелого оружия в каждом ящике в мире.");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","Максимальное количество боеприпасов для дробовика в каждом ящике в мире.");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","Максимальное количество боеприпасов для снайперской винтовки в каждом ящике в мире.");

		// === СИСТЕМА ГАНДИКАПА ===
		this.Text("AmmoLimiter-Settings-Hand","• Система гандикапа");
		this.Text("AmmoLimiter-Settings-HandMode-Name","Режим гандикапа");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","Регулирует восстановление боеприпасов с врагов согласно вашему текущему количеству. Режим \"Оптимизированный\" рассчитывается из ваших настроек и сбалансирован.");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","Оптимизированный (рекомендуется)");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","Отключен");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","Пользовательский");

		// === ПОЛЬЗОВАТЕЛЬСКИЙ ГАНДИКАП ПО БОЕПРИПАСАМ ===
		this.Text("AmmoLimiter-Settings-CustomHand","• Пользовательский гандикап по боеприпасам");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","Пистолет - порог гандикапа");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","Пистолет - минимум");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","Пистолет - максимум");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","Тяжелое оружие - порог гандикапа");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","Тяжелое оружие - минимум");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","Тяжелое оружие - максимум");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","Дробовик - порог гандикапа");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","Дробовик - минимум");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","Дробовик - максимум");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","Снайперская винтовка - порог гандикапа");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","Снайперская винтовка - минимум");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","Снайперская винтовка - максимум");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","Порог срабатывания гандикапа, ниже которого добыча может скрыть боеприпасы.");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","Минимум восстанавливаемых боеприпасов, если гандикап активен.");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","Максимум восстанавливаемых боеприпасов, если гандикап активен.");

		// === ВЕС БОЕПРИПАСОВ ===
		this.Text("AmmoLimiter-Settings-Weight","• Вес боеприпасов");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","Вес одного боеприпаса для пистолета.");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","Вес одного боеприпаса для тяжелого оружия.");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","Вес одного боеприпаса для дробовика.");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","Вес одного боеприпаса для снайперской винтовки.");

		// === МНОЖИТЕЛИ ЦЕН БОЕПРИПАСОВ ===
		this.Text("AmmoLimiter-Settings-Eddies","• Множители цен боеприпасов");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","Множитель цены покупки одного боеприпаса для пистолета в эдди.");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","Множитель цены покупки одного боеприпаса для тяжелого оружия в эдди.");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","Множитель цены покупки одного боеприпаса для дробовика в эдди.");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","Множитель цены покупки одного боеприпаса для снайперской винтовки в эдди.");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","Автоматическая продажа излишков (в % от цены покупки)");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","Процент автоматической цены продажи на основе сырой цены покупки (без скидки) для излишних боеприпасов (0 = отключено).");

		// === ИЗГОТОВЛЕНИЕ И КОНВЕРТАЦИЯ ===
		this.Text("AmmoLimiter-Settings-Craft","• Изготовление партий боеприпасов");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","Количество боеприпасов для пистолета на изготовление партии.");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","Количество боеприпасов для тяжелого оружия на изготовление партии.");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","Количество боеприпасов для дробовика на изготовление партии.");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","Количество боеприпасов для снайперской винтовки на изготовление партии.");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","Компоненты требуемые для изготовления");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","Количество компонентов необходимых для изготовления 1 партии боеприпасов.");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","Автоматическое преобразование патронов (в %)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","Процент автоматического преобразования патронов в компоненты.");

		// === ТЕКСТЫ В ИГРЕ ===
		this.Text("AmmoLimiter-Message-Dropped","брошены на землю");
		this.Text("AmmoLimiter-Message-Crafted","конвертированы в");
		this.Text("AmmoLimiter-Message-Recovered","Восстановлено:");
		this.Text("AmmoLimiter-Message-From","из");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","Лимит боеприпасов достигнут!");
		// Пожалуйста, уважайте мой юмор, НИКОГДА не изменяя слово "PROUTS":
		this.Text("AmmoLimiter-UI-LowAmmoWarning","НЕДОСТАТОЧНЫЙ ЗАПАС PROUTS!");
		this.Text("AmmoLimiter-UI-Total","всего");
		this.Text("AmmoLimiter-UI-Unit","единица");
	}
}
