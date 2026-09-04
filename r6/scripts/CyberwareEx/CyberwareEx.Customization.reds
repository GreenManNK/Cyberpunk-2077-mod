module CyberwareEx.Customization
import CyberwareEx.*

public class UserConfig extends DefaultConfig {
    public static func SlotExpansions() -> array<ExpansionArea> = [
        ExpansionArea.Create(gamedataEquipmentArea.SystemReplacementCW, [ 
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Milestone_3, 3), 
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Master_Perk_3, 1) 
        ]),
        ExpansionArea.Create(gamedataEquipmentArea.FrontalCortexCW, [  
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Milestone_2, 2),
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Milestone_3, 3)
            // ExpansionSlot.Create(gamedataNewPerkType.Intelligence_Central_Milestone_3, 3) 
        ]),
        ExpansionArea.Create(gamedataEquipmentArea.CardiovascularSystemCW, [ 
            ExpansionSlot.Create(gamedataNewPerkType.Body_Central_Milestone_3, 3) 
        ]),
        ExpansionArea.Create(gamedataEquipmentArea.NervousSystemCW, [ 
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Milestone_2, 2),
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Milestone_3, 3) 
        ]),
        ExpansionArea.Create(gamedataEquipmentArea.IntegumentarySystemCW, [ 
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Milestone_2, 2),
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Milestone_3, 3),
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Master_Perk_3, 1) 
        ]),
        ExpansionArea.Create(gamedataEquipmentArea.HandsCW, [ 
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Milestone_3, 1)
        ]),
        ExpansionArea.Create(gamedataEquipmentArea.LegsCW, [ 
            ExpansionSlot.Create(gamedataNewPerkType.Reflexes_Central_Milestone_1, 1),
            ExpansionSlot.Create(gamedataNewPerkType.Reflexes_Central_Milestone_2, 2),
            ExpansionSlot.Create(gamedataNewPerkType.Reflexes_Central_Milestone_3, 3),
            ExpansionSlot.Create(gamedataNewPerkType.Reflexes_Master_Perk_3, 1)
        ]),
        ExpansionArea.Create(gamedataEquipmentArea.EyesCW, [
            ExpansionSlot.Create(gamedataNewPerkType.Tech_Central_Milestone_3, 3) 
        ])
    ];

    public static func CombinedAbilityMode() -> Bool = false
}
