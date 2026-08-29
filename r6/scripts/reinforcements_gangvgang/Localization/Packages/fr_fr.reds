module Gibbon.GR.Localization.Packages
import Codeware.Localization.*

public class GR_fr_fr extends ModLocalizationPackage{

	protected func DefineTexts(){
        this.Text("GibbonGR-Title","Reinforcements Gang Vs Gang");
		this.Text("GibbonGR-Enabled-Name", "Activé");
        this.Text("GibbonGR-EnabledInCombat-Name", "Activé quand le joueur est en combat");
        this.Text("GibbonGR-EnabledWhenPlayerIsPassenger-Name", "Activé quand le joueur est passager");
        this.Text("GibbonGR-GracePeriodMin-Name", "Période de grâce minimale");
        this.Text("GibbonGR-GracePeriodMin-Description", "Temps minimum avant qu'un gang puisse appeler des renforts pour la première fois dans un combat");
        this.Text("GibbonGR-GracePeriodMax-Name", "Période de grâce maximale");
        this.Text("GibbonGR-GracePeriodMax-Description", "Temps maximum avant qu'un gang puisse appeler des renforts pour la première fois dans un combat");
        this.Text("GibbonGR-CallSuccessCooldownMin-Name", "Cooldown d'appel minimum");
        this.Text("GibbonGR-CallSuccessCooldownMin-Description", "Temps minimum qu'un gang doit attendre avant d'appeler des renforts à nouveau dans le même combat");
        this.Text("GibbonGR-CallSuccessCooldownMax-Name", "Cooldown d'appel maximum");
        this.Text("GibbonGR-CallSuccessCooldownMax-Description", "Temps maximum qu'un gang doit attendre avant d'appeler des renforts à nouveau dans le même combat");
        this.Text("GibbonGR-InitialHeat-Name", "Chaleur initiale");
        this.Text("GibbonGR-InitialHeat-Description", "À quel point le premier appel de renforts sera fort");
        this.Text("GibbonGR-HeatEscalation-Name", "Escalade de chaleur");
        this.Text("GibbonGR-HeatEscalation-Description", "Montant d'augmentation de chaleur par gang par appel");
        this.Text("GibbonGR-CallsLimit-Name", "Limite d'appels");
        this.Text("GibbonGR-CallsLimit-Description", "Le nombre d'appels qu'un gang peut faire avant de devoir attendre le cooldown limite");
        this.Text("GibbonGR-StrongCallChance-Name", "Chance d'appel fort");
        this.Text("GibbonGR-StrongCallChance-Description", "Chance que le prochain appel de renforts soit plus fort que le niveau de chaleur actuel");
        this.Text("GibbonGR-StrongCallHeatBonus-Name", "Bonus de chaleur pour appel fort");
        this.Text("GibbonGR-StrongCallHeatBonus-Description", "Combien de chaleur supplémentaire l'appel fort aura");
        this.Text("GibbonGR-GracePeriod-Category", "Période de grâce");
        this.Text("GibbonGR-Cooldowns-Category", "Cooldowns");
        this.Text("GibbonGR-Heat-Category", "Chaleur");

        // ==================== NEW SETTINGS LOCALIZATION ==================== //
        this.Text("GibbonGR-PresetMode-Name", "Mode Prédéfini");
        this.Text("GibbonGR-PresetMode-Description", "Choisissez parmi les modes prédéfinis pour différentes expériences de jeu");
        this.Text("GibbonGR-PresetMode-Limited", "Léger");
        this.Text("GibbonGR-PresetMode-Balanced", "Équilibré");
        this.Text("GibbonGR-PresetMode-RareBigFight", "Rare & Dramatique");
        this.Text("GibbonGR-PresetMode-Chaos", "Chaos");
        this.Text("GibbonGR-ShowAdvancedSettings-Name", "Afficher les Paramètres Avancés");
        this.Text("GibbonGR-ShowAdvancedSettings-Description", "Afficher les paramètres avancés pour ajuster finement les paramètres individuels. Remplace le mode prédéfini.");
        this.Text("GibbonGR-MinVehiclesPerCall-Name", "Véhicules Minimum par Appel");
        this.Text("GibbonGR-MinVehiclesPerCall-Description", "Nombre minimum de véhicules qui apparaissent dans un seul appel de renforts");
        this.Text("GibbonGR-MaxVehiclesPerCall-Name", "Véhicules Maximum par Appel");
        this.Text("GibbonGR-MaxVehiclesPerCall-Description", "Nombre maximum de véhicules qui peuvent apparaître dans un seul appel de renforts");
	}
}
