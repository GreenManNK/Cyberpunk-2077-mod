module NightCityAllies.UI.Hooks

@addMethod(InventoryItemDisplayController)
public func NCAClearPlayerState() -> Void {
    inkWidgetRef.SetState(this.m_requirementsWrapper, n"Default");
    inkWidgetRef.SetVisible(this.m_quantityWrapper, false);
}
