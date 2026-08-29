import iconicshop.Helpers.Products.*
import iconicshop.Helpers.ProductsList.*
import iconicshop.Prices.Legendary.*

@addMethod(gameuiInGameMenuGameController)
protected cb func RegisterISLegendaryStore(event: ref<VirtualShopRegistration>) -> Bool {
  let quality = "Legendary";
  let products = GetProductsList(quality);
  
  event.AddStore(
    n"ISLegendary",
    "IS: Legendary",
    ISGetItems(products),
    ISGetPrices(products),
    r"iconicshop/icons/icons.inkatlas",
    n"Legendary",
    ISGetQualities(products)
  );
}