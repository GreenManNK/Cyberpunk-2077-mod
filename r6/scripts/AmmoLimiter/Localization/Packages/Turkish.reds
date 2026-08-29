module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class Turkish extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === GENEL SEÇENEKLER ===
		this.Text("AmmoLimiter-Settings-Title","Mermi Sınırlayıcı");
		this.Text("AmmoLimiter-Settings-Options","• Genel seçenekler");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","Mesajları göster");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","Mermi dönüştürme, saklama veya kurtarma mesajlarını göster.");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","Envanterteki sıkı mermi sınırlaması");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","Varsayılan yumuşak sınırlamanın aksine, envantere transferleri, satın almaları ve mermi üretimini sıkı şekilde sınırlamaya izin verir.");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","Düşük mermi uyarısı (% eşik)");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","Eşik %0'dan fazla olduğunda, çekilen silahın kalan mermi miktarı eşiğin altında olduğunda uyarı verir.");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","Manuel mermi sökmeyi devre dışı bırak");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","Modun diğer mekanizmalarını devre dışı bırakmadan manuel mermi sökme olasılığını devre dışı bırakır.");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","Sökmeden kurtarma (şarjörün %'si)");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","Bir silahı sökerken, kırık bile olsa mermi elde etmeye izin verir. Şarjörünün maksimum kapasitesinin 0 ile bu %'si arasında rastgele miktar. Handikap sistemini tamamlar.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","Mermi görüntüleme kategorisi");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","Mermilerin ve tariflerin hangi envanter kategorisinde gösterileceğini seçin.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","Uzak mesafe silahları");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","Silah aksesuarları");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","Savaş sarf malzemeleri");

		// === MERMİ SINIRLARI ===
		this.Text("AmmoLimiter-Settings-Limits","• Envanterteki mermi sınırları");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","Uyuyan mermi kontrolü");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","Aktif silaha uymayan mermi toplamayı önler, doğrudan dönüştürülür veya yere düşürülür.");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","Aktif silah sınır bonusu (% olarak)");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","Donanımlı silaha karşılık gelen mermi için sınırı aşmaya izin verir.");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","Envanterteki maksimum tabanca mermisi, yalnızca toplama ve üretim için geçerlidir.");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","Envanterteki maksimum ağır silah mermisi, yalnızca toplama ve üretim için geçerlidir.");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","Envanterteki maksimum pompalı tüfek mermisi, yalnızca toplama ve üretim için geçerlidir.");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","Envanterteki maksimum keskin nişancı mermisi, yalnızca toplama ve üretim için geçerlidir.");

		// === MERMİ KUTULARI ===
		this.Text("AmmoLimiter-Settings-Box","• Kutularda bulunan maksimum miktarlar");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","Dünyadaki her kutuda maksimum tabanca mermisi miktarı.");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","Dünyadaki her kutuda maksimum ağır silah mermisi miktarı.");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","Dünyadaki her kutuda maksimum pompalı tüfek mermisi miktarı.");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","Dünyadaki her kutuda maksimum keskin nişancı mermisi miktarı.");

		// === HANDİKAP SİSTEMİ ===
		this.Text("AmmoLimiter-Settings-Hand","• Handikap sistemi");
		this.Text("AmmoLimiter-Settings-HandMode-Name","Handikap modu");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","Mevcut miktarınıza göre düşmanlardan mermi kurtarmayı düzenler. \"Optimize edilmiş\" mod ayarlarınızdan hesaplanır ve dengelidir.");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","Optimize edilmiş (önerilen)");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","Devre dışı");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","Özel");

		// === MERMİYE GÖRE ÖZEL HANDİKAP ===
		this.Text("AmmoLimiter-Settings-CustomHand","• Mermiye göre özel handikap");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","Tabanca - handikap eşiği");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","Tabanca - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","Tabanca - maksimum");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","Ağır silah - handikap eşiği");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","Ağır silah - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","Ağır silah - maksimum");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","Pompalı tüfek - handikap eşiği");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","Pompalı tüfek - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","Pompalı tüfek - maksimum");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","Keskin nişancı - handikap eşiği");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","Keskin nişancı - minimum");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","Keskin nişancı - maksimum");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","Ganimet mermi gizleyebileceği handikap aktivasyon eşiği.");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","Handikap aktifse kurtarılabilir minimum mermi.");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","Handikap aktifse kurtarılabilir maksimum mermi.");

		// === MERMİ AĞIRLIĞI ===
		this.Text("AmmoLimiter-Settings-Weight","• Mermi ağırlığı");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","Bir tabanca mermisinin ağırlığı.");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","Bir ağır silah mermisinin ağırlığı.");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","Bir pompalı tüfek mermisinin ağırlığı.");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","Bir keskin nişancı mermisinin ağırlığı.");

		// === MERMİ FİYAT ÇARPANLARI ===
		this.Text("AmmoLimiter-Settings-Eddies","• Mermi fiyat çarpanları");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","Eddy cinsinden bir tabanca mermisi için satın alma fiyatı çarpanı.");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","Eddy cinsinden bir ağır silah mermisi için satın alma fiyatı çarpanı.");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","Eddy cinsinden bir pompalı tüfek mermisi için satın alma fiyatı çarpanı.");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","Eddy cinsinden bir keskin nişancı mermisi için satın alma fiyatı çarpanı.");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","Fazla otomatik satış (satın alma fiyatının %'si)");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","Fazla mermi için ham satın alma fiyatına (indirim olmadan) dayanan otomatik satış fiyatı yüzdesi (0 = devre dışı).");

		// === ÜRETİM VE DÖNÜŞÜM ===
		this.Text("AmmoLimiter-Settings-Craft","• Mermi parti üretimi");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","Parti üretimi başına tabanca mermisi miktarı.");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","Parti üretimi başına ağır silah mermisi miktarı.");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","Parti üretimi başına pompalı tüfek mermisi miktarı.");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","Parti üretimi başına keskin nişancı mermisi miktarı.");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","Üretim için gerekli bileşenler");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","1 parti mermi üretmek için gereken bileşen miktarı.");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","Otomatik mermi dönüşümü (yüzde olarak)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","Merminin bileşenlere otomatik dönüşüm yüzdesi.");

		// === OYUN İÇİ METİNLER ===
		this.Text("AmmoLimiter-Message-Dropped","yere düşürüldü");
		this.Text("AmmoLimiter-Message-Crafted","dönüştürüldü");
		this.Text("AmmoLimiter-Message-Recovered","Kurtarıldı:");
		this.Text("AmmoLimiter-Message-From","dan");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","Mermi sınırına ulaşıldı!");
		// Lütfen mizahıma saygı gösterin ve "PROUTS" kelimesini ASLA değiştirmeyin:
		this.Text("AmmoLimiter-UI-LowAmmoWarning","YETERSİZ PROUTS REZERVI!");
		this.Text("AmmoLimiter-UI-Total","toplam");
		this.Text("AmmoLimiter-UI-Unit","birim");
	}
}
