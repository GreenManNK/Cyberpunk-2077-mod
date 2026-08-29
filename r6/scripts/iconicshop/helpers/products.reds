module iconicshop.Helpers.Products

import iconicshop.Settings.General.*

public class ISProduct {
  public let name: String;
  public let itemId: String;
  public let price: Int32;
  public let quality: String;
}

public func ISCreateProduct(name: String, itemId: String, price: Int32, quality: String) -> ref<ISProduct> {
  let product = new ISProduct();
  product.name = name;
  product.itemId = itemId;
  product.price = price;
  product.quality = quality;
  return product;
}

public func ISGetItems(products: array<ref<ISProduct>>) -> array<String> {
  let items: array<String>;
  for elem in products {
    ArrayPush(items, elem.itemId);
  }
  return items;
}

public func ISGetPrices(products: array<ref<ISProduct>>) -> array<Int32> {
  let prices: array<Int32>;
  let settings: ref<ISGeneralSetting> = new ISGeneralSetting();

  if settings.isGlobalPrices {
    for elem in products {
      ArrayPush(prices, settings.globalPrice);
    }
    return prices;
  }
  
  for elem in products {
    ArrayPush(prices, elem.price);
  }
  return prices;
}

public func ISGetQualities(products: array<ref<ISProduct>>) -> array<String> {
  let qualities: array<String>;
  for elem in products {
    ArrayPush(qualities, elem.quality);
  }
  return qualities;
}