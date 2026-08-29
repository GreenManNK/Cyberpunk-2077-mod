local localization = {
	--Mod Name
	["CMSName"] = "Car Modification Shop",
	
	--Part Types
	["Engine"] = "Moteur",
	["Ecu"] = "Ecu",
	["Transmission"] = "Transmission",
	["Suspension"] = "Suspension",
	["Tires"] = "Pneus",
	["Brakes"] = "Freins",
	["Weight Reduction"] = "Réduction de poids",
	["Stage"] = "Étape",
	
	--Totals text
	["basetotalTorqueText"] = "COUPLE: ",
	["basetotalGearsText"] = "VITESSES: ",
	["basetotalHeightText"] = "HAUTEUR: ",
	["basetotalWeightText"] = "POIDS: ",
	["basetotalTractionText"] = "TRACTION DES PNEUS: ",
	["basetotalBrakePowerText"] = "COUPLE DE FREINAGE: ",
	["basetotalPriceText"] = "PANIER: \n€$ ",
	
	--Main UI Text
	["ClearAllUpgrades"] = "Supprimer toutes les mises à niveau",
	["StopUpgradeClear"] = "Arrêter la suppression des mises à niveau",
	["ButtonStartDowngrading"] = "Commencer la dégradation",
	["ButtonStopDowngrading"] = "Arrêter la dégradation",
	["ButtonAcceptBroke"] = "Continuer",
	["ButtonReturn"] = "Page précédente",
	["ButtonConfirmUpgrade"] = "Confirmer la mise à niveau",
	["CloseUIButton"] = "     Fermer",
	["partBasketMainTextToSet"] = "PANIER DE PIÈCES:",
	["partListMainTextToSet"] = "PIÈCES MISES À NIVEAU:",
	["descriptionPrice"] = "Prix: ",
	["brokeConfirmBox"] = "EDDIES INSUFFISANTS CHOOM\n    OBTENEZ D'ABORD LES EDDIES\n        ALORS ON PARLE",
	["ButtonClearBasket"] = "Vider le panier",
	
	--MAP UI
	["mapTitleText"] = "Garage de voiture",
	["mapDescText"] = "Améliorez vos véhicules et faites manger la poussière à tout le monde dans cette ville!",
	["ButtonClearBasket"] = "Vider le panier",

	--Parts names and desc
	
	--Engine
	["PartName-0101"] = "Consommation d'air froid",
	["PartDesc-0101"] = "Petite amélioration du couple moteur",

	["PartName-0102"] = "Changer les en-têtes",
	["PartDesc-0102"] = "Petite amélioration du couple moteur",

	["PartName-0103"] = "Arbre à cames et engrenages de came",
	["PartDesc-0103"] = "Petite amélioration du couple moteur",

	["PartName-0104"] = "Échappement de performance",
	["PartDesc-0104"] = "Petite amélioration du couple moteur",

	["PartName-0121"] = "Système Turbo Étape 1",
	["PartDesc-0121"] = "Amélioration moyenne du couple moteur",

	["PartName-0105"] = "Système d'échappement Cat Back",
	["PartDesc-0105"] = "Amélioration moyenne du couple moteur",

	["PartName-0106"] = "Collecteur d'admission à haut débit",
	["PartDesc-0106"] = "Petite amélioration du couple moteur",

	["PartName-0107"] = "Tube descendant de plus grand diamètre",
	["PartDesc-0107"] = "Petite amélioration du couple moteur",

	["PartName-0122"] = "Système Turbo Étape 2",
	["PartDesc-0122"] = "Amélioration très large du couple moteur",

	["PartName-0108"] = "Arbre à cames de course et engrenages de came",
	["PartDesc-0108"] = "Amélioration moyenne du couple moteur",

	["PartName-0109"] = "Polissage des conduits de culasse",
	["PartDesc-0109"] = "Amélioration moyenne du couple moteur",

	["PartName-0110"] = "Conception du bloc moteur",
	["PartDesc-0110"] = "Amélioration moyenne du couple moteur",

	["PartName-0111"] = "En-têtes à haut débit",
	["PartDesc-0111"] = "Amélioration moyenne du couple moteur",

	["PartName-0123"] = "Système Turbo Double Étape 3",
	["PartDesc-0123"] = "Amélioration extrême du couple moteur",

	--ECU
	["PartName-0201"] = "Régulateur de pression de carburant",
	["PartDesc-0201"] = "Amélioration moyenne du couple moteur",

	["PartName-0202"] = "Rampe de carburant",
	["PartDesc-0202"] = "Petite amélioration du couple moteur",

	["PartName-0203"] = "Filtre à carburant",
	["PartDesc-0203"] = "Petite amélioration du couple moteur",

	["PartName-0204"] = "Puce d'amélioration",
	["PartDesc-0204"] = "Amélioration large du couple moteur",

	["PartName-0205"] = "Pompe à carburant à haut débit",
	["PartDesc-0205"] = "Petite amélioration du couple moteur",

	["PartName-0206"] = "Unité de gestion du moteur",
	["PartDesc-0206"] = "Amélioration extrême du couple moteur",

	["PartName-0207"] = "Injecteurs de carburant",
	["PartDesc-0207"] = "Amélioration moyenne du couple moteur",
	
	--Transmission
	["PartName-0301"] = "Kit de changement court",
	["PartDesc-0301"] = "Réduction moyenne du temps de changement de vitesse",

	["PartName-0302"] = "Volant moteur allégé",
	["PartDesc-0302"] = "Réduction large du poids du volant moteur",

	["PartName-0305"] = "Embrayage haute performance",
	["PartDesc-0305"] = "Réduction large du temps de changement de vitesse",

	["PartName-0306"] = "Transmission haute performance",
	["PartDesc-0306"] = "Vitesse supplémentaire, améliore la vitesse maximale",
	
	--Suspension
	["PartName-0401"] = "Ressorts et amortisseurs sportifs",
	["PartDesc-0401"] = "Réduction faible de l'abaissement",

	["PartName-0402"] = "Barre de support Billet Tower",
	["PartDesc-0402"] = "Petite amélioration de la suspension",

	["PartName-0403"] = "Ressorts et amortisseurs haute performance",
	["PartDesc-0403"] = "Réduction moyenne de l'abaissement",

	["PartName-0404"] = "Barres stabilisatrices avant et arrière",
	["PartDesc-0404"] = "Petite amélioration de la rigidité de la barre stabilisatrice",

	["PartName-0405"] = "Système de suspension Coilover",
	["PartDesc-0405"] = "Réduction élevée de l'abaissement",

	["PartName-0406"] = "Grandes barres stabilisatrices",
	["PartDesc-0406"] = "Amélioration large de la rigidité de la barre stabilisatrice",
		
	--Tires
	["PartName-0501"] = "Pneus de rue",
	["PartDesc-0501"] = "Amélioration moyenne de l'adhérence des pneus",

	["PartName-0502"] = "Pneus Semi Slick",
	["PartDesc-0502"] = "Amélioration large de l'adhérence des pneus",

	["PartName-0503"] = "Pneus Slick",
	["PartDesc-0503"] = "Amélioration extrême de l'adhérence des pneus",

	--Brakes
	["PartName-0601"] = "Plaquettes de frein composées pour la rue",
	["PartDesc-0601"] = "Augmentation moyenne du couple de freinage",

	["PartName-0602"] = "Lignes de frein en acier tressé",
	["PartDesc-0602"] = "Petite augmentation du couple de freinage",

	["PartName-0603"] = "Rotores perforés croisés",
	["PartDesc-0603"] = "Augmentation moyenne du couple de freinage",

	["PartName-0604"] = "Rotores de grand diamètre",
	["PartDesc-0604"] = "Augmentation large du couple de freinage",

	["PartName-0605"] = "Plaquette de freins de course",
	["PartDesc-0605"] = "Augmentation large du couple de freinage",

	["PartName-0606"] = "Rotores perforés et rainurés",
	["PartDesc-0606"] = "Augmentation extrême du couple de freinage",

	["PartName-0607"] = "6 étriers à piston",
	["PartDesc-0607"] = "Augmentation extrême du couple de freinage",
	
	--Weight Reduction
	["PartName-0801"] = "Tapis de voiture léger",
	["PartDesc-0801"] = "Réduction faible du poids",

	["PartName-0802"] = "Panneaux intérieurs légers",
	["PartDesc-0802"] = "Réduction faible du poids",

	["PartName-0803"] = "Fenêtres légères",
	["PartDesc-0803"] = "Réduction moyenne du poids",

	["PartName-0804"] = "Sièges légers",
	["PartDesc-0804"] = "Réduction moyenne du poids",

	["PartName-0805"] = "Portes légères",
	["PartDesc-0805"] = "Réduction large du poids",

	["PartName-0806"] = "Intérieur en mousse",
	["PartDesc-0806"] = "Réduction moyenne du poids",
	
	--Part Descriptions
	["Borpa"] = "Borpa"
}

return localization