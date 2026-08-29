@addMethod(gameuiInGameMenuGameController)
protected cb func RegisterLEGEWEAPONSMODSStore(event: ref<VirtualShopRegistration>) -> Bool {
  event.AddStore(
    n"LEGEWEAPONSMODS",
    "Weapons Mods",
    ["Items.SimpleWeaponMod01","Items.SimpleWeaponMod02","Items.SimpleWeaponMod03","Items.SimpleWeaponMod04","Items.SimpleWeaponMod11","Items.SimpleWeaponMod12","Items.SimpleWeaponMod13","Items.SimpleWeaponMod16","Items.SimpleWeaponMod17","Items.TygerRangedWeaponMod","Items.ValentinosRangedWeaponMod","Items.WraithsRangedWeaponMod","Items.TygerMeleeWeaponMod","Items.ValentinosMeleeWeaponMod","Items.WraithsMeleeWeaponMod","Items.ArasakaMeleeWeaponMod"],
    [5000,5000,5000,5000,5000,5000,5000,5000,5000,5000,5000,5000,5000,5000,5000,5000],
    r"base/gameplay/gui/common/icons/items/item_icons5.inkatlas",
    n"wmod_wraiths_ranged",
    ["Legendary", "Legendary", "Legendary", "Rare", "Epic", "Uncommon", "Rare", "Rare", "Uncommon", "Rare", "Rare", "Uncommon", "Legendary", "Legendary", "Legendary", "Rare"]
  );
}