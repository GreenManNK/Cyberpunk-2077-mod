// -----------------------------------------------------------------------------
// NCFTooltipPriceTax
// -----------------------------------------------------------------------------
//
// Adds tax info ("(+N sls. tax)" / "(-N inc. tax)") to the price area of
// vendor item tooltips, so the player sees the tax cost at the point of
// decision instead of only feeling it after the wallet update.
//
// === Why FOUR wrap points ===
//
// Cyberpunk has TWO parallel tooltip class trees, each with TWO update paths,
// for a total of FOUR Update entry points that can render an item tooltip:
//
//   ItemTooltipBottomModule        (older inventory/vendor screens)
//     .Update(MinimalItemTooltipData)        ← legacy path
//     .NEW_Update(UIInventoryItem, ...)      ← modern path
//
//   NewItemTooltipBottomModule     (newer pop-up / floating tooltips)
//     .Update(MinimalItemTooltipData)        ← legacy path
//     .NEW_Update(UIInventoryItem, ...)      ← modern path
//
// v0.13.15..v0.13.18 only wrapped the FIRST of these (legacy on legacy class),
// which is why the tax line appeared on the vendor inventory grid but NOT on
// the floating tooltip the user sees when hovering a consumable in the
// vendor's "category list" (Broseph Lager screenshot). v0.13.19 hooks all
// four. (Each wrap is independent and a no-op when not invoked, so this is
// safe even on tooltip variants that only use one path.)
//
// === Coexistence with Virtual Atelier ===
//
// VA wraps ItemTooltipBottomModule.Update only. Our wrap on the same method
// chains via wrappedMethod(), both run on every legacy update. We do not
// touch any of the methods VA touches in any other way.
//
// === Read strategy: append to existing priceText ===
//
// Established in v0.13.17. Spawning a sibling inkText into priceWrapper
// failed to render (parent type unknown without the .inkwidget layout file).
// Modifying priceText in-place via inkTextRef.Get(...).GetText() / SetText()
// is what VA already proves works. Vanilla overwrites the price string on
// each Update so no dedupe needed.
//
// === Buy/sell distinction ===
//
//  - Legacy path (Update with MinimalItemTooltipData): read
//    data.displayContextData.GetDisplayContext() (the gameItemDisplayContext
//    enum, redscript spelling `ItemDisplayContext`).
//  - Modern path (NEW_Update with UIInventoryItem): the
//    `itemDisplayContext` field on the parent module controller IS in
//    the RTTI dump but is not script-accessible (compile fails with
//    UNRESOLVED_MEMBER, confirmed v0.13.19 attempt). Instead compare
//    `data.GetOwner()` to the `player` arg of NEW_Update:
//      - owner == player    → V owns the item   → SELL (income tax)
//      - owner != player    → vendor owns it    → BUY  (sales tax)
//    Backpack/ripperdoc/etc. contexts still hit our wrap, but vanilla
//    leaves m_priceText empty for those, our empty-string guard in
//    NCF_AppendToPriceText short-circuits before adding any text.
//
// === Read strategy: price source ===
//
//  - Legacy path: data.price (Float), already routed by vanilla through
//    sell-vs-buy logic before Update is called.
//  - Modern path: UIInventoryItem.GetBuyPrice() / GetSellPrice() ,
//    different methods. We pick based on the owner-comparison result.
//    overridePrice (when > 0) wins over both.
//
// Both strategies feed NCF_CalculatePercentage so the displayed number is
// the same Int32 floor-division result that the live wallet deduction uses.
//

module NightCityFinance.UI

import NightCityFinance.Settings.*
import NightCityFinance.Utils.*

// Build the tax suffix string. Returns empty string when nothing should
// be shown (rate 0, mod disabled, settings missing, price <= 0).
//
// `isBuy` selects which rate to apply:
//   true  → sales tax (buying from vendor)
//   false → income tax (selling to vendor)
private func NCF_BuildTaxSuffix(price: Float, isBuy: Bool) -> String {
    if price <= 0.0 { return ""; }

    let settings: ref<NCFSettings> = NCFSettings.Get();
    if !IsDefined(settings) { return ""; }

    let rate: Int32 = isBuy ? settings.salesTaxRate : settings.incomeTaxRate;
    if rate <= 0 { return ""; }

    // Match the live deduction math exactly. NCF_CalculateTaxWithFloor
    // floors to 1 €$ when a non-zero rate and a non-zero base produce a
    // truncated zero, preserves "Night City always taxes" without
    // drifting from what HandlePurchase actually deducts.
    let priceInt: Int32 = Cast<Int32>(price);
    let tax: Int32 = NCF_CalculateTaxWithFloor(priceInt, rate);
    if tax <= 0 { return ""; }

    let sign: String = isBuy ? "+" : "-";
    let label: String = isBuy ? " sls. tax" : " inc. tax";
    return " (" + sign + ToString(tax) + label + ")";
}

// Map an ItemDisplayContext to (shouldRender, isBuy).
// Returns false in the return value if this context is not a vendor surface
// (Backpack, Ripperdoc, Crafting, GearPanel, Tooltip, Attachment, etc.).
// Used by the LEGACY Update wraps where data.displayContextData carries
// the precise gameItemDisplayContext enum.
private func NCF_ResolveBuyContext(ctx: ItemDisplayContext, out isBuy: Bool) -> Bool {
    switch ctx {
        case ItemDisplayContext.Vendor:
            isBuy = true;
            return true;
        case ItemDisplayContext.VendorPlayer:
            isBuy = false;
            return true;
        default:
            return false;
    }
}

// Map (item owner, current player) to (shouldRender, isBuy).
// Used by the MODERN NEW_Update wraps where the gameItemDisplayContext
// field is in the RTTI dump but not accessible to scripted access.
// Always returns true, context filtering relies on m_priceText being
// non-empty (vanilla writes a price only in vendor-screen contexts).
private func NCF_ResolveBuyContextFromOwner(data: wref<UIInventoryItem>, player: wref<PlayerPuppet>, out isBuy: Bool) -> Bool {
    if !IsDefined(data) { return false; }
    let owner: wref<GameObject> = data.GetOwner();
    // owner == player → V owns the item → it's the vendor's "buy from V" panel
    //   (V is selling, vendor is buying). Tax rate applied is INCOME tax.
    // owner != player → vendor owns it → vendor's stock panel (V is buying).
    //   Tax rate applied is SALES tax.
    if IsDefined(owner) && IsDefined(player) && Equals(owner, player) {
        isBuy = false;
    } else {
        isBuy = true;
    }
    return true;
}

// Append `suffix` to the live price text widget at `m_priceText`.
// Returns true if applied, false if the widget couldn't be resolved or
// the existing text was empty (which means vanilla decided not to show
// a price at all, adding tax to an empty string would render as a
// stray "(+N sales tax)" with no number and look broken).
private func NCF_AppendToPriceText(priceTextRef: inkTextRef, suffix: String) -> Bool {
    let priceWidget: ref<inkText> = inkTextRef.Get(priceTextRef) as inkText;
    if !IsDefined(priceWidget) { return false; }
    let currentText: String = priceWidget.GetText();
    if StrLen(currentText) == 0 { return false; }
    priceWidget.SetText(currentText + suffix);
    return true;
}

// =============================================================================
// Wrap 1: ItemTooltipBottomModule.Update, legacy path, legacy class
// (vendor inventory screen / older tooltips, used by Virtual Atelier too)
// =============================================================================
@wrapMethod(ItemTooltipBottomModule)
public func Update(data: ref<MinimalItemTooltipData>) -> Void {
    wrappedMethod(data);
    if !IsDefined(data) { return; }

    let ctxData: ref<ItemDisplayContextData> = data.displayContextData;
    if !IsDefined(ctxData) { return; }
    let isBuy: Bool;
    if !NCF_ResolveBuyContext(ctxData.GetDisplayContext(), isBuy) { return; }

    let suffix: String = NCF_BuildTaxSuffix(data.price, isBuy);
    if StrLen(suffix) == 0 { return; }
    NCF_AppendToPriceText(this.m_priceText, suffix);
}

// =============================================================================
// Wrap 2: ItemTooltipBottomModule.NEW_Update, modern path, legacy class
// (covers tooltips that route through the modern data pipeline but still
// instantiate the older bottom module, observed on some vendor list hovers)
// =============================================================================
@wrapMethod(ItemTooltipBottomModule)
public func NEW_Update(data: wref<UIInventoryItem>, player: wref<PlayerPuppet>, overridePrice: Int32) -> Void {
    wrappedMethod(data, player, overridePrice);
    if !IsDefined(data) { return; }

    let isBuy: Bool;
    if !NCF_ResolveBuyContextFromOwner(data, player, isBuy) { return; }

    // Modern path price source: UIInventoryItem.GetBuyPrice() / GetSellPrice().
    // overridePrice (when non-zero) takes precedence, matches what vanilla
    // displays in the price text after wrappedMethod above.
    let price: Float;
    if overridePrice > 0 {
        price = Cast<Float>(overridePrice);
    } else {
        price = isBuy ? data.GetBuyPrice() : data.GetSellPrice();
    }

    let suffix: String = NCF_BuildTaxSuffix(price, isBuy);
    if StrLen(suffix) == 0 { return; }
    NCF_AppendToPriceText(this.m_priceText, suffix);
}

// =============================================================================
// Wrap 3: NewItemTooltipBottomModule.Update, legacy path, new class
// (covers floating/popup tooltip variants that use the new common
// controller but still receive a MinimalItemTooltipData payload)
// =============================================================================
@wrapMethod(NewItemTooltipBottomModule)
public func Update(data: ref<MinimalItemTooltipData>) -> Void {
    wrappedMethod(data);
    if !IsDefined(data) { return; }

    let ctxData: ref<ItemDisplayContextData> = data.displayContextData;
    if !IsDefined(ctxData) { return; }
    let isBuy: Bool;
    if !NCF_ResolveBuyContext(ctxData.GetDisplayContext(), isBuy) { return; }

    let suffix: String = NCF_BuildTaxSuffix(data.price, isBuy);
    if StrLen(suffix) == 0 { return; }
    NCF_AppendToPriceText(this.m_priceText, suffix);
}

// =============================================================================
// Wrap 4: NewItemTooltipBottomModule.NEW_Update, modern path, new class
// (the canonical floating-tooltip path. This is the one missing from
// v0.13.18 that left the Broseph Lager tooltip without a tax line.)
// =============================================================================
@wrapMethod(NewItemTooltipBottomModule)
public func NEW_Update(data: wref<UIInventoryItem>, player: wref<PlayerPuppet>, overridePrice: Int32) -> Void {
    wrappedMethod(data, player, overridePrice);
    if !IsDefined(data) { return; }

    let isBuy: Bool;
    if !NCF_ResolveBuyContextFromOwner(data, player, isBuy) { return; }

    let price: Float;
    if overridePrice > 0 {
        price = Cast<Float>(overridePrice);
    } else {
        price = isBuy ? data.GetBuyPrice() : data.GetSellPrice();
    }

    let suffix: String = NCF_BuildTaxSuffix(price, isBuy);
    if StrLen(suffix) == 0 { return; }
    NCF_AppendToPriceText(this.m_priceText, suffix);
}

// =============================================================================
// Wrap 5+6: ProgramTooltipController, quickhack / program crafting specs
// =============================================================================
//
// Quickhack crafting specs (PING, Contagion, etc. sold by netrunners) and
// other "program" items use a SEPARATE tooltip controller tree ,
// ProgramTooltipController, not (New)ItemTooltipBottomModule. Different
// .inkwidget layout (TIER row, Duration, Upload Time, effects list, then
// price), different code path. v0.13.21 only hooked the bottom-module tree
// so these tooltips never got a tax line.
//
// The controller exposes both legacy and modern price update methods:
//   UpdatePrice()                     ← legacy, no player arg
//   NewUpdatePrice(player: PlayerPuppet)  ← modern path
//
// Both write to the same `m_priceText` widget. We wrap both. Owner
// comparison still works as the buy/sell signal: the legacy variant
// fetches the player via NCF_GetPlayer() (no arg available), the modern
// variant uses the passed-in player.
//

@wrapMethod(ProgramTooltipController)
private final func UpdatePrice() -> Void {
    wrappedMethod();
    let item: wref<UIInventoryItem> = this.m_itemData;
    if !IsDefined(item) { return; }
    let player: wref<PlayerPuppet> = NCF_GetPlayer();
    if !IsDefined(player) { return; }

    let isBuy: Bool;
    if !NCF_ResolveBuyContextFromOwner(item, player, isBuy) { return; }

    let price: Float = isBuy ? item.GetBuyPrice() : item.GetSellPrice();
    let suffix: String = NCF_BuildTaxSuffix(price, isBuy);
    if StrLen(suffix) == 0 { return; }
    NCF_AppendToPriceText(this.m_priceText, suffix);
}

@wrapMethod(ProgramTooltipController)
private final func NewUpdatePrice(player: wref<PlayerPuppet>) -> Void {
    wrappedMethod(player);
    let item: wref<UIInventoryItem> = this.m_itemData;
    if !IsDefined(item) { return; }
    if !IsDefined(player) { return; }

    let isBuy: Bool;
    if !NCF_ResolveBuyContextFromOwner(item, player, isBuy) { return; }

    let price: Float = isBuy ? item.GetBuyPrice() : item.GetSellPrice();
    let suffix: String = NCF_BuildTaxSuffix(price, isBuy);
    if StrLen(suffix) == 0 { return; }
    NCF_AppendToPriceText(this.m_priceText, suffix);
}
