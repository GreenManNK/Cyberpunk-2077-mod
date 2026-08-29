module iconicshop.Settings.General

public class ISGeneralSetting {
// Description text
  @runtimeProperty("ModSettings.displayName", "For the shop price changes to take effect, you need to confirm the changes in the current settings below and load your save (F9). After that, the shop prices will be updated.")
  @runtimeProperty("ModSettings.mod", "Iconic Shops")
  @runtimeProperty("ModSettings.category", "Confirm the changes below and load your save (F9) to update shop prices.")
  @runtimeProperty("ModSettings.category.order", "0")
  @runtimeProperty("ModSettings.dependency", "description")
  let description: Bool = false;

// General
  @runtimeProperty("ModSettings.displayName", "Duplicate Items")
  @runtimeProperty("ModSettings.mod", "Iconic Shops")
  @runtimeProperty("ModSettings.category", "General Settings")
  @runtimeProperty("ModSettings.category.order", "1")
  @runtimeProperty("ModSettings.description", "This setting enables item duplication mode to prevent conflicts with original items.")
  let isDuplicate: Bool = true;

  @runtimeProperty("ModSettings.displayName", "Enable Global Prices?")
  @runtimeProperty("ModSettings.mod", "Iconic Shops")
  @runtimeProperty("ModSettings.category", "Global Prices")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.description", "This setting enables global price adjustments for all items in the shops.")
  let isGlobalPrices: Bool = false;

  @runtimeProperty("ModSettings.displayName", "Prices for all items")
  @runtimeProperty("ModSettings.mod", "Iconic Shops")
  @runtimeProperty("ModSettings.category", "Global Prices")
  @runtimeProperty("ModSettings.category.order", "3")
  @runtimeProperty("ModSettings.description", "This setting allows you to set a global price for all items in the shops when global price adjustments are enabled.")
  @runtimeProperty("ModSettings.step", "500")
  @runtimeProperty("ModSettings.min", "1000")
  @runtimeProperty("ModSettings.max", "300000")
  let globalPrice: Int32 = 40000;
}