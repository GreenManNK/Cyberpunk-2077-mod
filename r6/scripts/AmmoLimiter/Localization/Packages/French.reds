module AmmoLimiter.Localization.Packages
import Codeware.Localization.*

public class French extends ModLocalizationPackage{

	protected func DefineTexts(){
		// === OPTIONS GÉNÉRALES ===
		this.Text("AmmoLimiter-Settings-Title","Limiteur de munitions");
		this.Text("AmmoLimiter-Settings-Options","• Options générales");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Name","Afficher les messages");
		this.Text("AmmoLimiter-Settings-MessageDisplay-Desc","Afficher les messages de conversion, de dépôt ou de récupération de munitions.");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Name","Limitation stricte des munitions dans l’inventaire");
		this.Text("AmmoLimiter-Settings-StrictLimitation-Desc","Permet de limiter de manière stricte les transferts vers l’inventaire, achats et fabrications de munitions, contrairement à la limitation douce par défaut.");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Name","Alerte de faible quantité (seuil en %)");
		this.Text("AmmoLimiter-Settings-LowAmmoWarning-Desc","Quand le seuil est supérieur à 0 %, permet d’avertir quand la quantité restante de munitions de l’arme dégainée est en dessous du seuil.");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Name","Désactiver le démontage manuel de munitions");
		this.Text("AmmoLimiter-Settings-AmmoDisassDisabled-Desc","Permet de désactiver la possibilité de démonter manuellement les munitions, sans désactiver les autres mécanismes du mod.");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Name","Récupérer dépuis un démontage (en % du chargeur)");
		this.Text("AmmoLimiter-Settings-AmmoDisass-Desc","Permet d’obtenir des munitions lors d’un démontage d’arme, même cassée. Quantité aléatoire entre 0 et ce % de la capacité maximum de son chargeur. Complémentaire au système de handicap.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Name","Catégorie d’affichage des munitions");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Desc","Choisissez dans quelle catégorie d’inventaire afficher les munitions et les recettes.");
		this.Text("AmmoLimiter-Settings-AmmoCategory-RangedWeapons","Armes à distance");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Attachments","Accessoires d’armes");
		this.Text("AmmoLimiter-Settings-AmmoCategory-Consumables","Consommables de combat");

		// === LIMITES DE MUNITIONS ===
		this.Text("AmmoLimiter-Settings-Limits","• Limites de munitions dans l’inventaire");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Name","Contrôle des munitions dormantes");
		this.Text("AmmoLimiter-Settings-SleepingAmmoControl-Desc","Empêche l’accumulation par ramassage des munitions ne correspondant pas à l’arme active, directement converties ou lâchées au sol.");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Name","Bonus de limite pour l’arme active (en %)");
		this.Text("AmmoLimiter-Settings-ActiveWeaponBonus-Desc","Permet de dépasser la limite pour les munitions correspondant à l’arme équipée.");
		this.Text("AmmoLimiter-Settings-HandgunAmmoLimit-Desc","Maximum de munitions d’arme de poing dans l’inventaire, ne s’appliquant qu’au ramassage et à la fabrication.");
		this.Text("AmmoLimiter-Settings-RifleAmmoLimit-Desc","Maximum de munitions d’arme lourde dans l’inventaire, ne s’appliquant qu’au ramassage et à la fabrication.");
		this.Text("AmmoLimiter-Settings-ShotgunAmmoLimit-Desc","Maximum de munitions pour fusil à pompe dans l’inventaire, ne s’appliquant qu’au ramassage et à la fabrication.");
		this.Text("AmmoLimiter-Settings-SniperAmmoLimit-Desc","Maximum de munitions de sniper dans l’inventaire, ne s’appliquant qu’au ramassage et à la fabrication.");

		// === BOÎTES DE MUNITIONS ===
		this.Text("AmmoLimiter-Settings-Box","• Quantités maximum trouvées dans les boîtes");
		this.Text("AmmoLimiter-Settings-BoxHandgunAmmo-Desc","Quantité maximum de munitions d’arme de poing dans chaque boîte dans le monde.");
		this.Text("AmmoLimiter-Settings-BoxRifleAmmo-Desc","Quantité maximum de munitions d’arme lourde dans chaque boîte dans le monde.");
		this.Text("AmmoLimiter-Settings-BoxShotgunAmmo-Desc","Quantité maximum de munitions de fusil à pompe dans chaque boîte dans le monde.");
		this.Text("AmmoLimiter-Settings-BoxSniperAmmo-Desc","Quantité maximum de munitions de sniper dans chaque boîte dans le monde.");

		// === SYSTÈME DE HANDICAP ===
		this.Text("AmmoLimiter-Settings-Hand","• Système de handicap");
		this.Text("AmmoLimiter-Settings-HandMode-Name","Mode de handicap");
		this.Text("AmmoLimiter-Settings-HandMode-Desc","Règle la récupération de munitions sur les ennemis selon votre quantité actuelle. Le mode « Optimisé » est calculé à partir de vos paramètres et est équilibré.");
		this.Text("AmmoLimiter-Settings-HandMode-Optimized","Optimisé (recommandé)");
		this.Text("AmmoLimiter-Settings-HandMode-Disabled","Désactivé");
		this.Text("AmmoLimiter-Settings-HandMode-Custom","Personnalisé");

		// === HANDICAP PERSONNALISÉ ===
		this.Text("AmmoLimiter-Settings-CustomHand","• Handicap personnalisé par munition");
		this.Text("AmmoLimiter-Settings-HandLimitHandgunAmmo-Name","D’arme de poing - Seuil du handicap");
		this.Text("AmmoLimiter-Settings-HandMinHandgunAmmo-Name","D’arme de poing - Minimum");
		this.Text("AmmoLimiter-Settings-HandMaxHandgunAmmo-Name","D’arme de poing - Maximum");
		this.Text("AmmoLimiter-Settings-HandLimitRifleAmmo-Name","D’arme lourde - Seuil de handicap");
		this.Text("AmmoLimiter-Settings-HandMinRifleAmmo-Name","D’arme lourde - Minimum");
		this.Text("AmmoLimiter-Settings-HandMaxRifleAmmo-Name","D’arme lourde - Maximum");
		this.Text("AmmoLimiter-Settings-HandLimitShotgunAmmo-Name","De fusil à pompe - Seuil du handicap");
		this.Text("AmmoLimiter-Settings-HandMinShotgunAmmo-Name","De fusil à pompe - Minimum");
		this.Text("AmmoLimiter-Settings-HandMaxShotgunAmmo-Name","De fusil à pompe - Maximum");
		this.Text("AmmoLimiter-Settings-HandLimitSniperAmmo-Name","De fusil sniper - Seuil du handicap");
		this.Text("AmmoLimiter-Settings-HandMinSniperAmmo-Name","De fusil sniper - Minimum");
		this.Text("AmmoLimiter-Settings-HandMaxSniperAmmo-Name","De fusil sniper - Maximum");
		this.Text("AmmoLimiter-Settings-HandLimit-Desc","Seuil de déclenchement du handicap sous lequel les dépouilles peuvent cacher des munitions.");
		this.Text("AmmoLimiter-Settings-HandMin-Desc","Minimum de munitions récupérables si le handicap est actif.");
		this.Text("AmmoLimiter-Settings-HandMax-Desc","Maximum de munitions récupérables si le handicap est actif.");

		// === POIDS DES MUNITIONS ===
		this.Text("AmmoLimiter-Settings-Weight","• Poids des munitions");
		this.Text("AmmoLimiter-Settings-WeightHandgunAmmo-Desc","Poids d’une munition d’arme de poing.");
		this.Text("AmmoLimiter-Settings-WeightRifleAmmo-Desc","Poids d’une munition d’arme lourde.");
		this.Text("AmmoLimiter-Settings-WeightShotgunAmmo-Desc","Poids d’une munition de fusil à pompe.");
		this.Text("AmmoLimiter-Settings-WeightSniperAmmo-Desc","Poids d’une munition de sniper.");

		// === PRIX DES MUNITIONS ===
		this.Text("AmmoLimiter-Settings-Eddies","• Multiplicateurs des prix des munitions");
		this.Text("AmmoLimiter-Settings-PriceHandgunAmmo-Desc","Multiplicateur du prix d’achat d’une munition d’arme de poing en eddies.");
		this.Text("AmmoLimiter-Settings-PriceRifleAmmo-Desc","Multiplicateur du prix d’achat d’une munition d’arme lourde en eddies.");
		this.Text("AmmoLimiter-Settings-PriceShotgunAmmo-Desc","Multiplicateur du prix d’achat d’une munition de fusil à pompe en eddies.");
		this.Text("AmmoLimiter-Settings-PriceSniperAmmo-Desc","Multiplicateur du prix d’achat d’une munition de sniper en eddies.");
		this.Text("AmmoLimiter-Settings-AutoSell-Name","Vente automatique d’excès (en % du prix d’achat)");
		this.Text("AmmoLimiter-Settings-AutoSell-Desc","Pourcentage du prix de vente automatique basé sur le prix d’achat brut (sans remise) par excès de munitions (0 = désactivé).");

		// === FABRICATION & CONVERSION ===
		this.Text("AmmoLimiter-Settings-Craft","• Fabrication des lots de munitions");
		this.Text("AmmoLimiter-Settings-CraftHandgunAmmo-Desc","Quantité de munitions d’arme de poing par fabrication de lot.");
		this.Text("AmmoLimiter-Settings-CraftRifleAmmo-Desc","Quantité de munitions d’arme lourde par fabrication de lot.");
		this.Text("AmmoLimiter-Settings-CraftShotgunAmmo-Desc","Quantité de munitions de fusil à pompe par fabrication de lot.");
		this.Text("AmmoLimiter-Settings-CraftSniperAmmo-Desc","Quantité de munitions de sniper par fabrication de lot.");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Name","Composants requis pour la fabrication");
		this.Text("AmmoLimiter-Settings-CraftingCompForAmmo-Desc","Quantité de composants nécessaires pour fabriquer 1 lot de munitions.");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Name","Conversion auto des munitions (en %)");
		this.Text("AmmoLimiter-Settings-AmmoConversionRate-Desc","Pourcentage de conversion automatique des munitions en composants.");

		// === TEXTES EN JEU ===
		this.Text("AmmoLimiter-Message-Dropped","déposées au sol");
		this.Text("AmmoLimiter-Message-Crafted","converties en");
		this.Text("AmmoLimiter-Message-Recovered","Récupérées :");
		this.Text("AmmoLimiter-Message-From","depuis");
		this.Text("AmmoLimiter-UI-AmmoLimitReachedWarning","Limite de munitions atteinte !");
		// Veuillez respecter mon humour en ne modifiant JAMAIS le mot "PROUTS" :
		this.Text("AmmoLimiter-UI-LowAmmoWarning","RÉSERVE INSUFFISANTE DE PROUTS !");
		this.Text("AmmoLimiter-UI-Total","au total");
		this.Text("AmmoLimiter-UI-Unit","unité");
	}
}
