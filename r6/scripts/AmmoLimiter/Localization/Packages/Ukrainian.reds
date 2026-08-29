module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class Ukrainian extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === ЗАГАЛЬНІ НАЛАШТУВАННЯ ===
		this.Text("AmmoLimiter-Settings-Title","Ammo Limiter");
		this.Text("AmmoLimiter-Settings-Options","• Загальні налаштування");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","Відображати повідомлення");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","Відображати повідомлення про конвертацію, зберігання або відновлення боєприпасів.");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","Сувора межа боєприпасів в інвентарі");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","Дозволяє суворо обмежити передачу в інвентар, покупки та виготовлення боєприпасів, на відміну від стандартного м'якого обмеження.");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","Попередження про нестачу боєприпасів (поріг у %)");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","Коли поріг більше 0%, дозволяє попереджати, коли кількість боєприпасів у витягнутій зброї менше порогу.");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","Вимкнути ручне розбирання боєприпасів");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","Дозволяє вимкнути можливість ручного розбирання боєприпасів, не вимикаючи інші механізми мода.");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","Відновлення з розбирання (% від магазину)");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","Дозволяє отримати боєприпаси при розбиранні зброї, навіть зламаної. Випадкова кількість між 0 і цим % від максимальної ємності магазину. Доповнює гандикап систему.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","Категорія відображення боєприпасів");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","Оберіть в якій категорії інвентарю відображати боєприпаси та рецепти.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","Далекобійна зброя");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","Аксесуари зброї");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","Бойові витратні матеріали");

		// === МЕЖІ БОЄПРИПАСІВ ===
		this.Text("AmmoLimiter-Settings-Limits","• Межі боєприпасів в інвентарі");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","Контроль сплячих боєприпасів");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","Запобігає накопиченню підбираючи боєприпаси що не відповідають активній зброї, безпосередньо конвертовані або кинуті на землю.");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","Бонус межі активної зброї (у %)");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","Дозволяє перевищити межу для боєприпасів відповідних екіпованій зброї.");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","Максимум боєприпасів для пістолетів в інвентарі, застосовується лише для підбирання та виготовлення.");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","Максимум боєприпасів для важкої зброї в інвентарі, застосовується лише для підбирання та виготовлення.");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","Максимум боєприпасів для рушниць в інвентарі, застосовується лише для підбирання та виготовлення.");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","Максимум боєприпасів для снайперської зброї в інвентарі, застосовується лише для підбирання та виготовлення.");

		// === ЯЩИКИ З БОЄПРИПАСАМИ ===
		this.Text("AmmoLimiter-Settings-Box","• Максимальні кількості знайдені в ящиках");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","Максимальна кількість боєприпасів для пістолетів у кожному ящику в світі.");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","Максимальна кількість боєприпасів для важкої зброї у кожному ящику в світі.");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","Максимальна кількість боєприпасів для рушниць у кожному ящику в світі.");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","Максимальна кількість боєприпасів для снайперської зброї у кожному ящику в світі.");

		// === СИСТЕМА ГАНДИКАПУ ===
		this.Text("AmmoLimiter-Settings-Hand","• Система гандикапу");
		this.Text("AmmoLimiter-Settings-HandMode-Name","Режим гандикапу");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","Регулює відновлення боєприпасів з ворогів відповідно до вашої поточної кількості. \"Оптимізований\" режим розраховується з ваших налаштувань і збалансований.");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","Оптимізований (рекомендується)");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","Вимкнено");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","Користувацький");

		// === КОРИСТУВАЦЬКИЙ ГАНДИКАП ПО БОЄПРИПАСАХ ===
		this.Text("AmmoLimiter-Settings-CustomHand","• Користувацький гандикап по боєприпасах");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","Пістолет - поріг гандикапу");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","Пістолет - мінімум");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","Пістолет - максимум");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","Важка зброя - поріг гандикапу");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","Важка зброя - мінімум");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","Важка зброя - максимум");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","Рушниця - поріг гандикапу");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","Рушниця - мінімум");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","Рушниця - максимум");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","Снайперська - поріг гандикапу");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","Снайперська - мінімум");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","Снайперська - максимум");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","Поріг спрацьовування гандикапу нижче якого лут може приховати боєприпаси.");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","Мінімум відновлюваних боєприпасів якщо гандикап активний.");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","Максимум відновлюваних боєприпасів якщо гандикап активний.");

		// === ВАГА БОЄПРИПАСІВ ===
		this.Text("AmmoLimiter-Settings-Weight","• Вага боєприпасів");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","Вага одного боєприпасу для пістолета.");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","Вага одного боєприпасу для важкої зброї.");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","Вага одного боєприпасу для рушниці.");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","Вага одного боєприпасу для снайперської зброї.");

		// === МНОЖНИКИ ЦІНHИ БОЄПРИПАСІВ ===
		this.Text("AmmoLimiter-Settings-Eddies","• Множники ціни боєприпасів");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","Множник ціни покупки одного боєприпасу для пістолета в єдіях.");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","Множник ціни покупки одного боєприпасу для важкої зброї в єдіях.");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","Множник ціни покупки одного боєприпасу для рушниці в єдіях.");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","Множник ціни покупки одного боєприпасу для снайперської зброї в єдіях.");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","Автоматичний продаж надлишку (у % від ціни покупки)");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","Відсоток автоматичної ціни продажу на основі сирої ціни покупки (без знижки) для надлишкових боєприпасів (0 = вимкнено).");

		// === ВИГОТОВЛЕННЯ ТА КОНВЕРТАЦІЯ ===
		this.Text("AmmoLimiter-Settings-Craft","• Пакетне виготовлення боєприпасів");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","Кількість боєприпасів для пістолетів за пакетне виготовлення.");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","Кількість боєприпасів для важкої зброї за пакетне виготовлення.");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","Кількість боєприпасів для рушниць за пакетне виготовлення.");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","Кількість боєприпасів для снайперської зброї за пакетне виготовлення.");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","Компоненти необхідні для виготовлення");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","Кількість компонентів потрібна для виготовлення 1 пакету боєприпасів.");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","Автоматичне перетворення патронів (у %)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","Відсоток автоматичного перетворення патронів у компоненти.");

		// === ІГРОВІ ТЕКСТИ ===
		this.Text("AmmoLimiter-Message-Dropped","кинуто на землю");
		this.Text("AmmoLimiter-Message-Crafted","конвертовано в");
		this.Text("AmmoLimiter-Message-Recovered","Відновлено:");
		this.Text("AmmoLimiter-Message-From","з");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","Межа боєприпасів досягнута!");
		// Будь ласка, поважайте мій гумор, НІКОЛИ не змінюючи слово "PROUTS":
		this.Text("AmmoLimiter-UI-LowAmmoWarning","НЕДОСТАТНЬО РЕЗЕРВУ PROUTS!");
		this.Text("AmmoLimiter-UI-Total","загалом");
		this.Text("AmmoLimiter-UI-Unit","одиниця");
	}
}
