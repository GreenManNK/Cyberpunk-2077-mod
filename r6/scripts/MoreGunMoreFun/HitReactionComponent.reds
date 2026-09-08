@replaceMethod(HitReactionComponent)
  protected final func IsValidBodyPerkDismemberAttack(healthMissing: Float) -> Bool {
    let weaponType: gamedataItemType;
    let chanceByHealth: Float = 0.00;
    if this.m_executeDismembered || this.m_invalidForExecuteDismember {
      return false;
    };
    if healthMissing < this.m_dismemberExecuteHealthRange.X {
      return false;
    };
    if this.m_ownerNPC.IsBoss() || Equals(this.m_ownerNPC.GetNPCRarity(), gamedataNPCRarity.MaxTac) {
      return false;
    };
    if !IsDefined(this.m_attackData) || NotEquals(this.m_attackData.GetAttackType(), gamedataAttackType.Ranged) || this.m_attackData.HasFlag(hitFlag.Explosion) {
      return false;
    };
    if !this.m_attackData.GetInstigator().IsPlayer() {
      return false;
    };
    if PlayerDevelopmentSystem.GetData(this.m_attackData.GetInstigator()).IsNewPerkBought(gamedataNewPerkType.Body_Left_Milestone_3) < 3 {
      return false;
    };
    if !IsDefined(this.m_attackData.GetWeapon()) {
      return false;
    };
    // weaponType = RPGManager.GetItemType(this.m_attackData.GetWeapon().GetItemID());
    // if NotEquals(weaponType, gamedataItemType.Wea_Shotgun) && NotEquals(weaponType, gamedataItemType.Wea_ShotgunDual) && NotEquals(weaponType, gamedataItemType.Wea_LightMachineGun) && NotEquals(weaponType, gamedataItemType.Wea_HeavyMachineGun) {
      // return false;
    // };
    chanceByHealth = this.m_statsSystem.GetStatValue(Cast<StatsObjectID>(this.m_attackData.GetInstigator().GetEntityID()), gamedataStatType.ExecuteDismemberByHealthChance);
    if chanceByHealth <= 0.00 {
      return false;
    };
    return true;
  }
