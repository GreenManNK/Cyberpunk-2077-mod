public class MoreGunsMoreFun {

	@runtimeProperty("ModSettings.mod", "More Guns More Fun")
	@runtimeProperty("ModSettings.displayName", "Onslaught Tweak And Fix")
	@runtimeProperty("ModSettings.description", "ON: Uses custom value for amount ammo refilled and apply a minimum value as a fix for Onslaught to work with low (<5) magazine size guns like some Shotguns, Comrade's Hammer and other Burya varriants... OFF: Uses unmodded values and mechanics.")
	public let modActivated: Bool = true;

	@runtimeProperty("ModSettings.mod", "More Guns More Fun")
	@runtimeProperty("ModSettings.displayName", "Onslaught Tweak And Fix - Refill Percentage")
	@runtimeProperty("ModSettings.description", "How much ammo refill (magazine count based) after neutralizing an enemy. Mod's default values: 20%. Game's default values: 20%.")
	@runtimeProperty("ModSettings.step", "1.0")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "100.0")
	let refillPercentage: Float = 20.0;

	@runtimeProperty("ModSettings.mod", "More Guns More Fun")
	@runtimeProperty("ModSettings.displayName", "Onslaught Tweak And Fix - Refill Minimum")
	@runtimeProperty("ModSettings.description", "Minimum value of how much ammo refill (magazine count based) after neutralizing an enemy. Mod's default values: 1. Game's default values: 0.")
	@runtimeProperty("ModSettings.step", "1.0")
	@runtimeProperty("ModSettings.min", "0.0")
	@runtimeProperty("ModSettings.max", "20.0")
	let refillMin: Float = 1.0;
}

@replaceMethod(CeaselessLeadAmmoEffector)
  private final func ProcessAction(owner: ref<GameObject>) -> Void {
	let settings = new MoreGunsMoreFun();
	let minValue: Float;
    let refundEvent: ref<SetAmmoCountEvent>;
    let weapon: wref<WeaponObject> = ScriptedPuppet.GetWeaponRight(owner);
    if IsDefined(weapon) && WeaponObject.HasAvailableAmmoInInventory(weapon) && ((!settings.modActivated && WeaponObject.GetMagazineCapacity(weapon) > WeaponObject.GetMagazineAmmoCount(weapon) && (Cast<Float>(WeaponObject.GetMagazineCapacity(weapon)) * this.m_percentToRefund) >= 1.00) || (settings.modActivated && (WeaponObject.GetMagazineCapacity(weapon) + Cast<Uint32>(settings.refillMin)) > WeaponObject.GetMagazineAmmoCount(weapon) && MaxF(Cast<Float>(WeaponObject.GetMagazineCapacity(weapon)) * settings.refillPercentage / 100.0, settings.refillMin) >= 1.00)) {
      refundEvent = new SetAmmoCountEvent();
      refundEvent.ammoTypeID = WeaponObject.GetAmmoType(weapon);
      if settings.modActivated {
        refundEvent.count = Cast<Uint32>(MinF(Cast<Float>(WeaponObject.GetMagazineCapacity(weapon) - WeaponObject.GetMagazineAmmoCount(weapon)), MaxF(Cast<Float>(WeaponObject.GetMagazineCapacity(weapon)) * settings.refillPercentage / 100.0, settings.refillMin))) + WeaponObject.GetMagazineAmmoCount(weapon);
      } else {
        refundEvent.count = Cast<Uint32>(Cast<Float>(WeaponObject.GetMagazineCapacity(weapon)) * this.m_percentToRefund) + WeaponObject.GetMagazineAmmoCount(weapon);
      };      
      weapon.QueueEvent(refundEvent);
      GameObject.PlaySoundEvent(owner, n"w_gun_perk_ceaseless_lead");
    };
  }