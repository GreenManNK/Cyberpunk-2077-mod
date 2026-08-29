@addMethod(gameuiInGameMenuGameController)
protected cb func RegisterNETRUNNERStore(event: ref<VirtualShopRegistration>) -> Bool {
  event.AddStore(
    n"NETRUNNER",
    "Netrunner Quickhacks Store",
    [
      // overheat
      "Items.OverheatProgram",
      "Items.OverheatLvl1Program",
      "Items.OverheatLvl2Program",
      "Items.OverheatLvl3Program",
      "Items.OverheatLvl4Program",
      "Items.OverheatLvl4PlusPlusProgram",
      // short circuit
      "Items.EMPOverloadProgram",
      "Items.EMPOverloadLvl1Program",
      "Items.EMPOverloadLvl2Program",
      "Items.EMPOverloadLvl3Program",
      "Items.EMPOverloadLvl4Program",
      "Items.EMPOverloadLvl4PlusPlusProgram",
      // contagion
      "Items.ContagionProgram",
      "Items.ContagionLvl2Program",
      "Items.ContagionLvl3Program",
      "Items.ContagionLvl4Program",
      "Items.ContagionLvl4PlusPlusProgram",
      // brain melt
      "Items.BrainMeltLvl2Program",
      "Items.BrainMeltLvl3Program",
      "Items.BrainMeltLvl4Program",
      "Items.BrainMeltLvl4PlusPlusProgram",
      // cripple movement
      "Items.LocomotionMalfunctionProgram",
      "Items.LocomotionMalfunctionLvl2Program",
      "Items.LocomotionMalfunctionLvl3Program",
      "Items.LocomotionMalfunctionLvl4Program",
      "Items.LocomotionMalfunctionLvl4PlusPlusProgram",
      // ping
      "Items.PingProgram",
      "Items.PingLvl2Program",
      "Items.PingLvl3Program",
      "Items.PingLvl4Program",
      "Items.PingLvl4PlusPlusProgram",
      // cyberpsychosis
      "Items.MadnessLvl3Program",
      "Items.MadnessLvl4Program",
      "Items.MadnessLvl4PlusPlusProgram",
      // reset optics
      "Items.BlindProgram",
      "Items.BlindLvl1Program",
      "Items.BlindLvl2Program",
      "Items.BlindLvl3Program",
      "Items.BlindLvl4Program",
      "Items.BlindLvl4PlusPlusProgram",
      // call backup
      "Items.CommsCallInLvl1Program",
      "Items.CommsCallInLvl2Program",
      "Items.CommsCallInLvl3Program",
      "Items.CommsCallInLvl4Program",
      "Items.CommsCallInLvl4PlusPlusProgram",
      // sonic shock
      "Items.CommsNoiseProgram",
      "Items.CommsNoiseLvl2Program",
      "Items.CommsNoiseLvl3Program",
      "Items.CommsNoiseLvl4Program",
      "Items.CommsNoiseLvl4PlusPlusProgram",
      // cyberware malfunction
      "Items.DisableCyberwareProgram",
      "Items.DisableCyberwareLvl2Program",
      "Items.DisableCyberwareLvl3Program",
      "Items.DisableCyberwareLvl4Program",
      "Items.DisableCyberwareLvl4PlusPlusProgram",
      // amnesy
      "Items.MemoryWipeLvl2Program",
      "Items.MemoryWipeLvl3Program",
      "Items.MemoryWipeLvl4Program",
      "Items.MemoryWipeLvl4PlusPlusProgram",
      // suicide
      "Items.SuicideLvl3Program",
      "Items.SuicideLvl4Program",
      "Items.SuicideLvl4PlusPlusProgram",
      // weapon glitch
      "Items.WeaponMalfunctionProgram",
      "Items.WeaponMalfunctionLvl2Program",
      "Items.WeaponMalfunctionLvl3Program",
      "Items.WeaponMalfunctionLvl4Program",
      "Items.WeaponMalfunctionLvl4PlusPlusProgram",
      // whistle
      "Items.WhistleLvl0Program",
      "Items.WhistleLvl1Program",
      "Items.WhistleLvl2Program",
      "Items.WhistleLvl3Program",
      "Items.WhistleLvl4Program",
      "Items.WhistleLvl4PlusPlusProgram",
      // system collapse
      "Items.SystemCollapseLvl3Program",
      "Items.SystemCollapseLvl4Program",
      "Items.SystemCollapseLvl4PlusPlusProgram",
      // grenade explosion
      "Items.GrenadeExplodeLvl3Program",
      "Items.GrenadeExplodeLvl4Program",
      "Items.GrenadeExplodeLvl4PlusPlusProgram",
      // materials
      "Items.QuickHackUncommonMaterial1",
      "Items.QuickHackRareMaterial1",
      "Items.QuickHackEpicMaterial1",
      "Items.QuickHackLegendaryMaterial1"
    ],
    [0],
    r"base/gameplay/gui/common/icons/items/item_icons13.inkatlas",
    n"quickhack_contagion",
    [
      // overheat
      "Common","Uncommon","Rare","Epic","Legendary","Legendary",
      // short circuit
      "Common","Uncommon","Rare","Epic","Legendary","Legendary",
      // contagion
      "Uncommon","Rare","Epic","Legendary","Legendary",
      // brain melt
      "Rare","Epic","Legendary","Legendary",
      // cripple movement
      "Uncommon","Rare","Epic","Legendary","Legendary",
      // ping
      "Common","Rare","Epic","Legendary","Legendary",
      // cyberpsychosis
      "Epic","Legendary","Legendary",
      // reset optics
      "Common","Uncommon","Rare","Epic","Legendary","Legendary",
      // call backup
      "Uncommon","Rare","Epic","Legendary","Legendary",
      // sonic shock
      "Uncommon","Rare","Epic","Legendary","Legendary",
      // cyberware malfunction
      "Uncommon","Rare","Epic","Legendary","Legendary",
      // amnesy
      "Rare","Epic","Legendary","Legendary",
      // suicide
      "Epic","Legendary","Legendary",
      // weapon glitch
      "Uncommon","Rare","Epic","Legendary","Legendary",
      // whistle
      "Common","Uncommon","Rare","Epic","Legendary","Legendary",
      // system collapse
      "Epic","Legendary","Legendary",
      // grenade explosion
      "Epic","Legendary","Legendary",
      // materials
      "Uncommon","Rare","Epic","Legendary"
    ],
    [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,25,25,25,25]
  );
}