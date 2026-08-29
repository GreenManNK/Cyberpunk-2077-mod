import iconicshop.Helpers.Products.*
import iconicshop.Helpers.ProductsList.*
import iconicshop.Prices.Top.*

@addMethod(gameuiInGameMenuGameController)
protected cb func RegisterISTopStore(event: ref<VirtualShopRegistration>) -> Bool {
  let quality = "LegendaryPlusPlus";
  let products = GetProductsList(quality);
  
  event.AddStore(
    n"ISTop",
    "IS: Top",
    ISGetItems(products),
    ISGetPrices(products),
    r"iconicshop/icons/icons.inkatlas",
    n"Top",
    ISGetQualities(products)
  );
}