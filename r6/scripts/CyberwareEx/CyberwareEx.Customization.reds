module CyberwareEx.Customization
import CyberwareEx.*

public class UserConfig extends DefaultConfig {
    public static func SlotExpansions() -> array<ExpansionArea> = [
		ExpansionArea.Create(gamedataEquipmentArea.ArmsCW, [
            ExpansionSlot.Create(gamedataNewPerkType.Espionage_Central_Perk_1_1, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Espionage_Central_Perk_1_4, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Espionage_Central_Perk_1_3, 1)
		]),
		ExpansionArea.Create(gamedataEquipmentArea.LegsCW, [
			ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Perk_3_2, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Cool_Central_Milestone_3, 3),
			ExpansionSlot.Create(gamedataNewPerkType.Reflexes_Central_Milestone_2, 2)
        ]),
		ExpansionArea.Create(gamedataEquipmentArea.HandsCW, [
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Perk_3_2, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Cool_Master_Perk_1, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Body_Master_Perk_1, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Reflexes_Master_Perk_1, 1)
		]),
        ExpansionArea.Create(gamedataEquipmentArea.SystemReplacementCW, [
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Master_Perk_3, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Espionage_Central_Milestone_1, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Intelligence_Central_Milestone_3, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Reflexes_Master_Perk_5, 1)
        ]),		        
        ExpansionArea.Create(gamedataEquipmentArea.FrontalCortexCW, [
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Master_Perk_3, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Espionage_Central_Milestone_1, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Intelligence_Master_Perk_1, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Intelligence_Master_Perk_3, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Espionage_Right_Perk_1_1, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Intelligence_Left_Milestone_2, 2),
			ExpansionSlot.Create(gamedataNewPerkType.Intelligence_Left_Milestone_3, 3),
			ExpansionSlot.Create(gamedataNewPerkType.Intelligence_Central_Milestone_2, 2),
			ExpansionSlot.Create(gamedataNewPerkType.Intelligence_Central_Milestone_3, 3)
        ]),
		ExpansionArea.Create(gamedataEquipmentArea.MusculoskeletalSystemCW, [
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Master_Perk_3, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Espionage_Central_Milestone_1, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Espionage_Central_Perk_1_2, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Espionage_Left_Perk_1_2, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Body_Central_Perk_3_1, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Perk_3_4, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Body_Right_Milestone_2, 2),
			ExpansionSlot.Create(gamedataNewPerkType.Body_Right_Milestone_3, 3)
        ]),
		ExpansionArea.Create(gamedataEquipmentArea.NervousSystemCW, [
			ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Milestone_3, 3),
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Master_Perk_3, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Espionage_Central_Milestone_1, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Reflexes_Master_Perk_3, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Reflexes_Central_Milestone_3, 3),
			ExpansionSlot.Create(gamedataNewPerkType.Reflexes_Left_Milestone_3, 3),
			ExpansionSlot.Create(gamedataNewPerkType.Cool_Left_Milestone_2, 2),
			ExpansionSlot.Create(gamedataNewPerkType.Cool_Left_Milestone_3, 3),
			ExpansionSlot.Create(gamedataNewPerkType.Espionage_Right_Milestone_1, 1)
        ]),
		ExpansionArea.Create(gamedataEquipmentArea.IntegumentarySystemCW, [
			ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Milestone_3, 3),
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Master_Perk_3, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Espionage_Central_Milestone_1, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Body_Master_Perk_3, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Body_Master_Perk_5, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Body_Central_Perk_3_2, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Body_Central_Perk_3_4, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Espionage_Left_Milestone_Perk, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Cool_Inbetween_Left_3, 1)
        ]),
		ExpansionArea.Create(gamedataEquipmentArea.CardiovascularSystemCW, [
			ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Milestone_3, 3),
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Master_Perk_3, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Espionage_Central_Milestone_1, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Body_Central_Milestone_1, 1),
			ExpansionSlot.Create(gamedataNewPerkType.Body_Central_Milestone_3, 3),
			ExpansionSlot.Create(gamedataNewPerkType.Reflexes_Right_Milestone_2, 2),
			ExpansionSlot.Create(gamedataNewPerkType.Reflexes_Right_Milestone_3, 3),
			ExpansionSlot.Create(gamedataNewPerkType.Tech_Left_Milestone_2, 2),
			ExpansionSlot.Create(gamedataNewPerkType.Cool_Right_Milestone_2, 2)
        ])
    ];

    public static func CombinedAbilityMode() -> Bool = false
}