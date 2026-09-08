@replaceMethod(EquipmentBaseTransition)
  protected final const func HandleWeaponUnequip(scriptInterface: ref<StateGameScriptInterface>, stateContext: ref<StateContext>, stateMachineInstanceData: StateMachineInstanceData, item: ItemID) -> Void {
    let gunzerkerLevel: Int32;
    let mappedInstanceData: InstanceDataMappedToReferenceName = this.GetMappedInstanceData(stateMachineInstanceData.referenceName);
    let unequipStartEvent: ref<UnequipStart> = new UnequipStart();
    let animFeature: ref<AnimFeature_EquipUnequipItem> = new AnimFeature_EquipUnequipItem();
    let transactionSystem: ref<TransactionSystem> = scriptInterface.GetTransactionSystem();
    let placementSlot: TweakDBID = EquipmentSystem.GetPlacementSlot(item);
    let playerDevelopmentData: ref<PlayerDevelopmentData> = PlayerDevelopmentSystem.GetData(scriptInterface.executionOwner);
    let itemObject: wref<WeaponObject> = transactionSystem.GetItemInSlot(scriptInterface.executionOwner, TDBID.Create(mappedInstanceData.attachmentSlot)) as WeaponObject;
    animFeature.stateTransitionDuration = this.GetWeaponUnEquipDuration(scriptInterface, stateContext, stateMachineInstanceData);
    animFeature.itemState = 3;
    animFeature.itemType = TweakDBInterface.GetItemRecord(ItemID.GetTDBID(item)).ItemType().AnimFeatureIndex();
    this.BlockAimingForTime(stateContext, scriptInterface, animFeature.stateTransitionDuration + 0.10);
    scriptInterface.SetAnimationParameterFeature(mappedInstanceData.itemHandlingFeatureName, animFeature, scriptInterface.executionOwner);
    scriptInterface.SetAnimationParameterFeature(n"equipUnequipItem", animFeature, itemObject);
    unequipStartEvent.SetSlotID(placementSlot);
    scriptInterface.executionOwner.QueueEvent(unequipStartEvent);
    gunzerkerLevel = playerDevelopmentData.IsNewPerkBought(gamedataNewPerkType.Reflexes_Master_Perk_2);
	// Ranged weapon
    if IsDefined(itemObject) && gunzerkerLevel > 0 && (!itemObject.IsMelee() || itemObject.WeaponHasTag(n"Throwable")) {
      itemObject.StartReload();
      itemObject.StopReload(gameweaponReloadStatus.Standard);
      itemObject.StartReload();
      itemObject.StopReload(gameweaponReloadStatus.Standard);
      itemObject.StartReload();
      itemObject.StopReload(gameweaponReloadStatus.Standard);
      itemObject.StartReload();
      itemObject.StopReload(gameweaponReloadStatus.Standard);
      itemObject.StartReload();
      itemObject.StopReload(gameweaponReloadStatus.Standard);
      itemObject.StartReload();
      itemObject.StopReload(gameweaponReloadStatus.Standard);
    };
  }
