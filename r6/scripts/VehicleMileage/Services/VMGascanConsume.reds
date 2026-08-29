@wrapMethod(ConsumeAction)
public func CompleteAction(gameInstance: GameInstance) -> Void {
  let consumedItemID: ItemID = this.GetItemData().GetID();

  wrappedMethod(gameInstance);

  if ItemID.GetTDBID(consumedItemID) == t"Items.chooh2_gascan" {
    let questSystem: ref<QuestsSystem> = GameInstance.GetQuestsSystem(gameInstance);
    if !IsDefined(questSystem) {
      return;
    };

    let pendingCount: Int32 = questSystem.GetFact(n"elm_chooh2_gascan_pending");

    questSystem.SetFact(
      n"elm_chooh2_gascan_pending",
      pendingCount + 1
    );
  };
}
