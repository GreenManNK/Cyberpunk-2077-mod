import iconicshop.Helpers.Products.*
import iconicshop.Helpers.ProductsList.*
import iconicshop.Prices.Common.*

@addMethod(gameuiInGameMenuGameController)
protected cb func RegisterISCommonStore(event: ref<VirtualShopRegistration>) -> Bool {
  let quality = "Common";
  let products = GetProductsList(quality);
  
  event.AddStore(
    n"ISCommon",
    "IS: Common",
    ISGetItems(products),
    ISGetPrices(products),
    r"iconicshop/icons/icons.inkatlas",
    n"Common",
    ISGetQualities(products)
  );
}