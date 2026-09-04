module NightlyNow.Transaction

// -----------------------------------------------------------------------------
// Transaction - NightlyNow Core
// -----------------------------------------------------------------------------
public class ItemStock {
    public persistent let itemIds: array<TweakDBID>;
    public persistent let quantity: array<Int32>;

    public static func Create(itemIds: array<TweakDBID>, quantity: array<Int32>) -> ref<ItemStock> {
        let itemStock = new ItemStock();
        itemStock.itemIds = itemIds;
        itemStock.quantity = quantity;
        return itemStock;
    }

    public func TotalQuantity() -> Int32 {
        let total = 0;
        for qty in this.quantity {
            total += qty;
        }
        return total;
    }

    // Used in Drug Dealer's street operations
    public func DecreaseQuantityOfRandomItem(quantity: Int32) -> DecreaseQuantityOfRandomItemResult {
        let result: DecreaseQuantityOfRandomItemResult;
        if quantity <= 0 {
            return result;
        }

        // Filter out non-eligible stuff
        let eligibleIndices: array<Int32>;
        let i = 0;
        while i < ArraySize(this.quantity) {
            if this.quantity[i] >= quantity {
                ArrayPush(eligibleIndices, i);
            }
            i += 1;
        }

        if ArraySize(eligibleIndices) > 0 {
            let pickedIndex = eligibleIndices[RandRange(0, ArraySize(eligibleIndices))];
            this.quantity[pickedIndex] -= quantity;
            // record kept even if it hits 0
            result.decreased = true;
            result.decreasedItemId = this.itemIds[pickedIndex];
            result.remainingQuantity = this.quantity[pickedIndex];
        }

        return result;
    }

    // If the item does not exist at all, 0 is returned
    public func GetItemQuantity(itemId: TweakDBID) -> Int32 {
        let i = 0;
        for item in this.itemIds {
            if Equals(itemId, item) {
                return this.quantity[i];
            }
            i += 1;
        }
        return 0;
    }

    public func ReduceQuantitiesByPercent(percent: Float) {
        let clampedPercent = ClampF(percent, 1.0, 100.0);
        let i = 0;
        while i < ArraySize(this.quantity) {
            this.quantity[i] = CeilF(Cast<Float>(this.quantity[i]) * clampedPercent / 100.0);
            i += 1;
        }
    }
}

public struct DecreaseQuantityOfRandomItemResult {
    public let decreased: Bool;
    public let decreasedItemId: TweakDBID;
    public let remainingQuantity: Int32;
}

public func AddMoney(amount: Int32) {
    let player = GetPlayer(GetGameInstance());
    let transactionSystem = GameInstance.GetTransactionSystem(player.GetGame());
    transactionSystem.GiveItem(player, MarketSystem.Money(), amount);
}

public func GetBalance() -> Int32 {
    let player = GetPlayer(GetGameInstance());
    let transactionSystem = GameInstance.GetTransactionSystem(player.GetGame());
    return transactionSystem.GetItemQuantity(player, MarketSystem.Money());
}

public func DeductMoney(amount: Int32) -> Bool {
    let player = GetPlayer(GetGameInstance());
    let transactionSystem = GameInstance.GetTransactionSystem(player.GetGame());
    let playerMoney = transactionSystem.GetItemQuantity(player, MarketSystem.Money());

    if playerMoney < amount || amount <= 0 {
        return false;
    }

    transactionSystem.RemoveItem(player, MarketSystem.Money(), amount);
    return true;
}

// Check if player has all items in required quantities
public func HasItems(itemIds: array<TweakDBID>, quantity: array<Int32>) -> Bool {
    let player = GetPlayer(GetGameInstance());
    let transactionSystem = GameInstance.GetTransactionSystem(player.GetGame());
    let i = 0;
    while i < ArraySize(itemIds) {
        let owned = transactionSystem.GetItemQuantity(player, ItemID.FromTDBID(itemIds[i]));
        if owned < quantity[i] {
            return false;
        }
        i += 1;
    }
    return true;
}

// Player's owned quantity of a single item
public func GetItemCount(itemId: TweakDBID) -> Int32 {
    let player = GetPlayer(GetGameInstance());
    let transactionSystem = GameInstance.GetTransactionSystem(player.GetGame());
    return transactionSystem.GetItemQuantity(player, ItemID.FromTDBID(itemId));
}

// Add item to player's inventory
public func AddItem(itemId: TweakDBID, quantity: Int32) {
    let player = GetPlayer(GetGameInstance());
    let transactionSystem = GameInstance.GetTransactionSystem(player.GetGame());
    transactionSystem.GiveItem(player, ItemID.FromTDBID(itemId), quantity);
}

// Get player's items matching any of the given tags with their quantities
public func GetItemsByTags(tags: array<CName>) -> ref<ItemStock> {
    let player = GetPlayer(GetGameInstance());
    let transactionSystem = GameInstance.GetTransactionSystem(player.GetGame());
    let itemStock = new ItemStock();
    let itemList: array<wref<gameItemData>>;
    transactionSystem.GetItemListByTags(player, tags, itemList);

    for itemData in itemList {
        let itemId = ItemID.GetTDBID(itemData.GetID());
        let qty = transactionSystem.GetItemQuantity(player, itemData.GetID());
        if qty > 0 {
            ArrayPush(itemStock.itemIds, itemId);
            ArrayPush(itemStock.quantity, qty);
        }
    }

    return itemStock;
}

// Remove player's items by quantity
public func RemoveItems(itemIds: array<TweakDBID>, quantity: array<Int32>) {
    let player = GetPlayer(GetGameInstance());
    let transactionSystem = GameInstance.GetTransactionSystem(player.GetGame());
    let i = 0;
    while i < ArraySize(itemIds) {
        let itemId = ItemID.FromTDBID(itemIds[i]);
        let owned = transactionSystem.GetItemQuantity(player, itemId);
        let toRemove = Min(owned, quantity[i]);
        if toRemove > 0 {
            transactionSystem.RemoveItem(player, itemId, toRemove);
        }
        i += 1;
    }
}

