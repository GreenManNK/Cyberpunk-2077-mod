module NightCityAllies.UI

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.Metadata.*
import NightCityAllies.Equipment.*
import NightCityAllies.Localization.*
import NightCityAllies.Util.*
import NightCityAllies.Web.*

public final class NCAEquipmentPanel {
    public static func WidgetName() -> CName = n"nca\\gameplay\\gui\\widgets\\inventory.inkwidget";
    public static func QueueName() -> CName = n"nca_equipment";
    public static func MiniGridName() -> CName = n"itemInventoryMiniGrid";
    public static func PlayerColumnPath() -> CName = n"Main/Backpack";
    public static func ScrollAreaPath() -> CName = n"Main/Backpack/scroller_wrapper/scroll_cache_widget/scroll_area";
    public static func HintsPath() -> CName = n"ButtonHints";
    public static func StatsPath() -> CName = n"Companion/Stats";
    public static func StatRowName() -> CName = n"StatRow";
    public static func GangIconAtlas() -> ResRef = r"base\\gameplay\\gui\\common\\icons\\gang_logos.inkatlas";
}

public class NCAEquipmentPanelRefreshEvent extends Event {}

public class NCAEquipmentPanelController extends inkLogicController {
    private let m_title: wref<inkText>;
    private let m_fluff: wref<inkText>;
    private let m_companionSlots: wref<inkCompoundWidget>;
    private let m_playerItems: wref<inkCompoundWidget>;
    private let m_stats: wref<inkCompoundWidget>;
    private let m_playerColumn: wref<inkWidget>;
    private let m_tooltips: wref<gameuiTooltipsManager>;
    private let m_scroll: wref<inkScrollController>;
    private let m_hints: wref<ButtonHints>;
    private let m_itemsManager: ref<UIInventoryItemsManager>;
    private let m_displayContext: ref<ItemDisplayContextData>;
    private let m_companionItemData: array<ref<UIInventoryItem>>;
    private let m_playerItemData: array<ref<UIInventoryItem>>;
    private let m_selectedSlot: CName;
    private let m_playerWeapons: array<ItemID>;
    private let m_refreshScheduled: Bool;
    private let m_hoveredSlot: CName;
    private let m_iconsRight: array<wref<inkWidget>>;
    private let m_iconsLeft: array<wref<inkWidget>>;
    private let m_iconIdle: HDRColor;
    private let m_slotIconRow: wref<inkWidget>;
    private let m_selectedSlotOccupied: Bool;
    private let m_panelAnim: ref<inkAnimProxy>;
    private let m_backpackAnim: ref<inkAnimProxy>;
    private let m_pickerShown: Bool;

    protected cb func OnInitialize() -> Bool {
        this.m_title = this.GetChildWidgetByPath(n"Companion/Header") as inkText;
        this.m_companionSlots = this.GetChildWidgetByPath(n"Companion/slots_wrapper/Slots") as inkCompoundWidget;
        this.m_fluff = this.GetChildWidgetByPath(n"Companion/Fluff") as inkText;
        this.m_stats = this.GetChildWidgetByPath(NCAEquipmentPanel.StatsPath()) as inkCompoundWidget;

        this.m_playerItems = this.ResolvePlayerItems();
        this.m_playerColumn = this.GetChildWidgetByPath(NCAEquipmentPanel.PlayerColumnPath());
        this.m_hints = this.SpawnHints();
        this.ResolveSlotIcons();

        if IsDefined(this.m_playerColumn) {
            this.m_scroll = this.m_playerColumn.GetController() as inkScrollController;
        }

        this.ReportMissing();

        this.m_tooltips = this.FindTooltipsManager();
        if IsDefined(this.m_tooltips) {
            this.m_tooltips.Setup(ETooltipsStyle.Menus);
        }

        let cursor = new inkGameNotificationLayer_SetCursorVisibility();
        cursor.Init(true);
        this.QueueEvent(cursor);

        this.RegisterToGlobalInputCallback(n"OnPostOnPress", this, n"OnHandlePressInput");

        NCA.UI().RegisterEquipmentPanel(this);

        this.m_displayContext = ItemDisplayContextData.Make(NCA.Player(), ItemDisplayContext.Backpack);
        this.m_itemsManager = UIInventoryItemsManager.Make(
            NCA.Player(),
            GameInstance.GetTransactionSystem(GetGameInstance()),
            UIScriptableSystem.GetInstance(GetGameInstance()));

        this.SetPickerVisible(false);

        this.BuildStats();
        this.Refresh();
        this.PlayIntro();
    }

    private func ResolvePlayerItems() -> wref<inkCompoundWidget> {
        let none: wref<inkCompoundWidget>;

        let area: wref<inkWidget> = this.GetChildWidgetByPath(NCAEquipmentPanel.ScrollAreaPath());
        if !IsDefined(area) {
            NCA.CETLog("[panel] WARNING no scroll area at " + NameToString(NCAEquipmentPanel.ScrollAreaPath()));
            return none;
        }

        let miniGrid = this.SpawnFromLocal(area, NCAEquipmentPanel.MiniGridName()) as inkCompoundWidget;
        if !IsDefined(miniGrid) {
            NCA.CETLog("[panel] WARNING " + NameToString(NCAEquipmentPanel.MiniGridName()) + " did not spawn");
            return none;
        }

        return miniGrid.GetWidgetByPathName(n"item_grid_list") as inkCompoundWidget;
    }

    private func SpawnHints() -> wref<ButtonHints> {
        let none: wref<ButtonHints>;

        let container: wref<inkWidget> = this.GetChildWidgetByPath(NCAEquipmentPanel.HintsPath());
        if !IsDefined(container) {
            return none;
        }

        let widget: wref<inkWidget> = this.SpawnFromExternal(container, r"base\\gameplay\\gui\\common\\buttonhints.inkwidget", n"Root");

        return widget.GetController() as ButtonHints;
    }

    private func ReportMissing() -> Void {
        let missing: String = "";

        if !IsDefined(this.m_title) { missing += " Companion/Header"; }
        if !IsDefined(this.m_companionSlots) { missing += " Companion/slots_wrapper/Slots"; }
        if !IsDefined(this.m_fluff) { missing += " Companion/Fluff"; }
        if !IsDefined(this.m_stats) { missing += " " + NameToString(NCAEquipmentPanel.StatsPath()); }
        if !IsDefined(this.m_playerItems) { missing += " item_grid_list"; }
        if !IsDefined(this.m_playerColumn) { missing += " " + NameToString(NCAEquipmentPanel.PlayerColumnPath()); }
        if !IsDefined(this.m_scroll) { missing += " (no inkScrollController)"; }
        if !IsDefined(this.m_hints) { missing += " ButtonHints"; }
        if !IsDefined(this.m_slotIconRow) { missing += " Companion/SlotIcons"; }

        let i: Int32 = 0;
        while i < ArraySize(this.m_iconsRight) {
            let n: String = ToString(i + 1);
            if !IsDefined(this.m_iconsRight[i]) { missing += " Companion/SlotIcons/Slot" + n + "R"; }
            if !IsDefined(this.m_iconsLeft[i]) { missing += " Companion/SlotIcons/Slot" + n + "L"; }
            i += 1;
        }

        if IsStringValid(missing) {
            NCA.CETLog("[panel] WARNING unresolved widgets:" + missing);
        }
    }

    private func FindTooltipsManager() -> wref<gameuiTooltipsManager> {
        let main = this.GetChildWidgetByPath(n"Main") as inkCompoundWidget;
        if !IsDefined(main) {
            return null;
        }

        let i: Int32 = 0;
        while i < main.GetNumChildren() {
            let found = main.GetWidgetByIndex(i).GetController() as gameuiTooltipsManager;
            if IsDefined(found) {
                return found;
            }
            i += 1;
        }

        return null;
    }

    protected cb func OnUninitialize() -> Bool {
        this.UnregisterFromGlobalInputCallback(n"OnPostOnPress", this, n"OnHandlePressInput");

        NCA.UI().OnEquipmentPanelClosed();
    }

    protected cb func OnTileHoverOver(evt: ref<inkPointerEvent>) -> Bool {
        this.ShowItemTooltip(evt);
    }

    protected cb func OnCompanionTileHoverOver(evt: ref<inkPointerEvent>) -> Bool {
        if IsNameValid(this.m_selectedSlot) {
            return false;
        }

        this.ShowItemTooltip(evt);
    }

    private func ShowItemTooltip(evt: ref<inkPointerEvent>) -> Void {
        if !IsDefined(this.m_tooltips) {
            return;
        }

        this.m_tooltips.HideTooltips();

        let display = evt.GetCurrentTarget().GetController() as InventoryItemDisplayController;
        if !IsDefined(display) {
            return;
        }

        let item: wref<UIInventoryItem> = display.GetUIInventoryItem();
        if !IsDefined(item) {
            return;
        }

        let data = new UIInventoryItemTooltipWrapper();
        data.m_data = item;

        // (tooltipsManager.swift:335-341)
        this.m_tooltips.ShowTooltipAtWidget(n"itemTooltip", evt.GetCurrentTarget(), data, gameuiETooltipPlacement.RightTop);
    }

    protected cb func OnTileHoverOut(evt: ref<inkPointerEvent>) -> Bool {
        if IsDefined(this.m_tooltips) {
            this.m_tooltips.HideTooltips();
        }
    }

    protected cb func OnHandlePressInput(evt: ref<inkPointerEvent>) -> Bool {
        if evt.IsAction(n"cancel") {
            this.PlayOutro();
        }
    }

// ============================================= Animation =============================================================
    private func PlayIntro() -> Void {
        this.m_panelAnim = this.PlayLibraryAnimation(n"intro");
    }

    private func PlayOutro() -> Void {
        if IsDefined(this.m_panelAnim) {
            this.m_panelAnim.GotoEndAndStop();
        }

        this.m_panelAnim = this.PlayLibraryAnimation(n"outro");
        this.m_panelAnim.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnOutroFinished");
    }

    protected cb func OnOutroFinished(anim: ref<inkAnimProxy>) -> Bool {
        NCA.UI().CloseEquipmentPanel();
    }

    private func ShowPickerView(show: Bool) -> Void {
        if Equals(this.m_pickerShown, show) {
            return;
        }

        this.m_pickerShown = show;

        if IsDefined(this.m_backpackAnim) {
            this.m_backpackAnim.GotoEndAndStop();
        }

        if show {
            this.SetPickerVisible(true);
            this.m_backpackAnim = this.PlayLibraryAnimation(n"backpack_intro");
            return;
        }

        this.m_backpackAnim = this.PlayLibraryAnimation(n"backpack_outro");
        this.m_backpackAnim.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnBackpackOutroFinished");
    }

    protected cb func OnBackpackOutroFinished(anim: ref<inkAnimProxy>) -> Bool {
        this.SetPickerVisible(false);
    }

    private func SetPickerVisible(visible: Bool) -> Void {
        if IsDefined(this.m_playerColumn) {
            this.m_playerColumn.SetVisible(visible);
        }

        if IsDefined(this.m_slotIconRow) {
            this.m_slotIconRow.SetVisible(visible);
        }
    }

// ============================================== Swapping =============================================================
    private func CanEdit() -> Bool {
        let npc: ref<NpcHandle> = NCA.UI().GetEquipmentPanelNpc();

        return IsDefined(npc) && npc.CanEditEquipment();
    }

    protected cb func OnCompanionSlotClick(evt: ref<inkPointerEvent>) -> Bool {
        if !evt.IsAction(n"click") || !this.CanEdit() {
            return false;
        }

        let slot: CName = this.SlotOfTile(evt);
        if !IsNameValid(slot) {
            return false;
        }

        // clicking the armed slot again disarms it, so there is always a way back to no selection
        let none: CName;
        this.m_selectedSlot = Equals(slot, this.m_selectedSlot) ? none : slot;

        this.ScheduleRefresh();
    }

    protected cb func OnPlayerItemClick(evt: ref<inkPointerEvent>) -> Bool {
        if !evt.IsAction(n"click") || !IsNameValid(this.m_selectedSlot) {
            return false;
        }

        let npc: ref<NpcHandle> = NCA.UI().GetEquipmentPanelNpc();
        let display = evt.GetCurrentTarget().GetController() as InventoryItemDisplayController;

        if !IsDefined(npc) || !IsDefined(display) {
            return false;
        }

        let index: Int32 = display.GetSlotIndex();
        if index < 0 || index >= ArraySize(this.m_playerWeapons) {
            return false;
        }

        npc.GiveWeapon(this.m_selectedSlot, this.m_playerWeapons[index]);

        let none: CName;
        this.m_selectedSlot = none;

        this.ScheduleRefresh();
    }

// =============================================== Hints ===============================================================

    protected cb func OnCompanionSlotHoverOver(evt: ref<inkPointerEvent>) -> Bool {
        let display = evt.GetCurrentTarget().GetController() as InventoryItemDisplayController;

        this.m_hoveredSlot = this.SlotOfTile(evt);

        let carried: wref<UIInventoryItem>;
        if IsDefined(display) {
            carried = display.GetUIInventoryItem();
        }

        this.LightSlotIcons(IsDefined(carried) && Equals(this.m_hoveredSlot, this.m_selectedSlot), false);

        if !IsDefined(this.m_hints) || !IsDefined(display) {
            return false;
        }

        this.m_hints.ClearButtonHints();

        if !this.CanEdit() {
            return false;
        }

        this.m_hints.AddButtonHint(n"click", GetLocalizedText("UI-UserActions-Select"));

        if IsDefined(carried) {
            this.m_hints.AddButtonHint(NCAEquipmentPanelController.TakeBackAction(),
                GetLocalizedText("UI-UserActions-Unequip"));
        }
    }

    // (inventoryItemDisplayController.swift:314-317)
    protected cb func OnCompanionSlotHoverOut(evt: ref<inkPointerEvent>) -> Bool {
        let display = evt.GetCurrentTarget().GetController() as InventoryItemDisplayController;
        if !IsDefined(display) {
            return false;
        }

        this.SetTileDimmed(display, this.IsSlotDimmed(this.SlotOfTile(evt)));
    }

    protected cb func OnPlayerItemHoverOver(evt: ref<inkPointerEvent>) -> Bool {
        this.LightSlotIcons(this.m_selectedSlotOccupied, true);

        if !IsDefined(this.m_hints) {
            return false;
        }

        this.m_hints.ClearButtonHints();

        if IsNameValid(this.m_selectedSlot) {
            this.m_hints.AddButtonHint(n"click", GetLocalizedText("UI-UserActions-Equip"));
        }
    }

    protected cb func OnHintsHoverOut(evt: ref<inkPointerEvent>) -> Bool {
        let none: CName;
        this.m_hoveredSlot = none;

        this.ShowSlotIcons();

        if IsDefined(this.m_hints) {
            this.m_hints.ClearButtonHints();
        }
    }

// ============================================= Slot icons ============================================================
    private func ResolveSlotIcons() -> Void {
        this.m_slotIconRow = this.GetChildWidgetByPath(n"Companion/SlotIcons");

        let slots: array<CName> = NCAEquipmentSystem.Slots();
        let i: Int32 = 0;

        while i < ArraySize(slots) {
            let path: String = "Companion/SlotIcons/Slot" + ToString(i + 1);

            ArrayPush(this.m_iconsRight, this.GetChildWidgetByPath(StringToName(path + "R")));
            ArrayPush(this.m_iconsLeft, this.GetChildWidgetByPath(StringToName(path + "L")));
            i += 1;
        }

        if IsDefined(this.m_iconsRight[0]) {
            this.m_iconIdle = this.m_iconsRight[0].GetTintColor();
        }
    }

    private func ShowSlotIcons() -> Void {
        let selected: Int32 = this.SelectedSlotIndex();
        let i: Int32 = 0;

        while i < ArraySize(this.m_iconsRight) {
            let opacity: Float = NCAEquipmentPanelController.HiddenIconOpacity();
            if i == selected {
                opacity = NCAEquipmentPanelController.RestingIconOpacity();
            }

            this.SetIcon(this.m_iconsRight[i], this.m_iconIdle, opacity);
            this.SetIcon(this.m_iconsLeft[i], this.m_iconIdle, opacity);
            i += 1;
        }
    }

    private func SetIcon(icon: wref<inkWidget>, color: HDRColor, opacity: Float) -> Void {
        if IsDefined(icon) {
            icon.SetTintColor(color);
            icon.SetOpacity(opacity);
        }
    }

    private func LightSlotIcons(take: Bool, give: Bool) -> Void {
        let i: Int32 = this.SelectedSlotIndex();
        if i < 0 {
            return;
        }

        this.LightIcon(this.m_iconsRight[i], take, NCAEquipmentPanelController.TakeBackColor());
        this.LightIcon(this.m_iconsLeft[i], give, NCAEquipmentPanelController.GiveColor());
    }

    private func LightIcon(icon: wref<inkWidget>, lit: Bool, color: HDRColor) -> Void {
        if lit {
            this.SetIcon(icon, color, 1.0);
            return;
        }

        this.SetIcon(icon, this.m_iconIdle, NCAEquipmentPanelController.RestingIconOpacity());
    }

    private static func RestingIconOpacity() -> Float = 0.15;
    private static func HiddenIconOpacity() -> Float = 0.01;

    private func SelectedSlotIndex() -> Int32 {
        let slots: array<CName> = NCAEquipmentSystem.Slots();
        let i: Int32 = 0;

        while i < ArraySize(slots) {
            if Equals(slots[i], this.m_selectedSlot) {
                return i;
            }
            i += 1;
        }

        return -1;
    }

    private static func TakeBackColor() -> HDRColor = new HDRColor(1.2, 0.2, 0.2, 1.0);
    private static func GiveColor() -> HDRColor = new HDRColor(0.2, 1.3, 0.4, 1.0);

// =========================================== Player input ============================================================

    public func HandleAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Void {
        if !IsNameValid(this.m_hoveredSlot) || !ListenerAction.IsButtonJustPressed(action)
        || !Equals(ListenerAction.GetName(action), NCAEquipmentPanelController.TakeBackAction())
        || !this.CanEdit() {
            return;
        }

        let npc: ref<NpcHandle> = NCA.UI().GetEquipmentPanelNpc();
        if !IsDefined(npc) {
            return;
        }

        ListenerActionConsumer.Consume(consumer);

        npc.TakeWeapon(this.m_hoveredSlot);
        this.ScheduleRefresh();
    }

    private static func TakeBackAction() -> CName = n"UI_vehicle_customization_fake_slider_value";

    private func SlotOfTile(evt: ref<inkPointerEvent>) -> CName {
        let none: CName;

        let display = evt.GetCurrentTarget().GetController() as InventoryItemDisplayController;
        if !IsDefined(display) {
            return none;
        }

        let slots: array<CName> = NCAEquipmentSystem.Slots();
        let index: Int32 = display.GetSlotIndex();

        return index >= 0 && index < ArraySize(slots) ? slots[index] : none;
    }

    private func ScheduleRefresh() -> Void {
        if this.m_refreshScheduled {
            return;
        }

        this.m_refreshScheduled = true;
        this.QueueEvent(new NCAEquipmentPanelRefreshEvent());
    }

    protected cb func OnRefreshNextFrame(evt: ref<NCAEquipmentPanelRefreshEvent>) -> Bool {
        this.m_refreshScheduled = false;
        this.Refresh();
    }

    private func Refresh() -> Void {
        let npc: ref<NpcHandle> = NCA.UI().GetEquipmentPanelNpc();
        if !IsDefined(npc) {
            return;
        }

        if IsDefined(this.m_tooltips) {
            this.m_tooltips.HideTooltips();
        }

        this.FillCompanionSlots(npc);
        this.FillPlayerItems();
        this.RefreshTitle(npc);
        this.RefreshFluff(npc);

        this.ShowPickerView(IsNameValid(this.m_selectedSlot));

        this.ShowSlotIcons();
    }

    private func RefreshTitle(npc: ref<NpcHandle>) -> Void {
        if !IsDefined(this.m_title) {
            return;
        }

        if IsNameValid(this.m_selectedSlot) {
            this.m_title.SetText(npc.GetName() + " - " + NameToString(this.m_selectedSlot));
            return;
        }

        this.m_title.SetText(npc.GetName());
    }

    private func RefreshFluff(npc: ref<NpcHandle>) -> Void {
        if IsDefined(this.m_fluff) {
            this.m_fluff.SetVisible(false);
        }
    }

// =============================================== Stats ===============================================================
    private func BuildStats() -> Void {
        let npc: ref<NpcHandle> = NCA.UI().GetEquipmentPanelNpc();
        if !IsDefined(this.m_stats) || !IsDefined(npc) {
            return;
        }

        let puppet: wref<ScriptedPuppet> = npc.GetEntity();

        this.BuildIdentityRows(npc, puppet);
        this.BuildGeneralRows(npc, puppet);
        this.BuildOffenceRows(puppet);
        this.BuildDefenceRows(puppet);
    }

    private func BuildIdentityRows(npc: ref<NpcHandle>, puppet: wref<ScriptedPuppet>) -> Void {
        let metadata: ref<CompanionMetadata> = npc.GetMetadata();
        if !metadata.isValidRecord {
            return;
        }

        this.AddFactionRow(metadata);

        if IsDefined(puppet) {
            this.AddLabelRow(NCA.Labels().Power_level(),
                ToString(RoundF(this.StatOf(puppet.GetEntityID(), gamedataStatType.PowerLevel))));
        }

        if NotEquals(metadata.rarity, gamedataNPCRarity.Invalid) {
            let row: ref<NCAStatRowController> = this.AddStatRow(NCA.Labels().Rarity());
            if IsDefined(row) {
                row.SetLabel(EnumValueToString("gamedataNPCRarity", Cast<Int64>(EnumInt(metadata.rarity))));
                row.SetValue(ToString(metadata.rarityValue));
                row.SetLabelColor(NCA.Util().RarityColor(metadata.rarity));
            }
        }

        if NotEquals(metadata.archetype, gamedataArchetypeType.Invalid) {
            this.AddLabelRow(NCA.Labels().Archetype(),
                EnumValueToString("gamedataArchetypeType", Cast<Int64>(EnumInt(metadata.archetype))));
        }

        if NotEquals(metadata.characterType, gamedataNPCType.Invalid) {
            this.AddLabelRow(NCA.Labels().Type(),
                EnumValueToString("gamedataNPCType", Cast<Int64>(EnumInt(metadata.characterType))));
        }
    }

    private func BuildGeneralRows(npc: ref<NpcHandle>, puppet: wref<ScriptedPuppet>) -> Void {
        if IsDefined(puppet) {
            this.AddWatchedRow(this.StatName(gamedataStatType.Health), puppet.GetEntityID(), gamedataStatPoolType.Health);
            this.AddWatchedRow(this.StatName(gamedataStatType.Stamina), puppet.GetEntityID(), gamedataStatPoolType.Stamina);
        }

        let friendship: ref<NCAStatRowController> = this.AddStatRow(NCA.Labels().Friendship());
        if IsDefined(friendship) {
            friendship.SetIcon(NCAWebsite.IconAtlas(), n"friendship");
            friendship.SetLabel(NCA.Util().FriendshipLabel(npc.GetFriendship()));
            friendship.SetValue(ToString(npc.GetFriendship()));
            friendship.SetFill(Cast<Float>(npc.GetFriendship()) / 100.0);
        }

        let love: ref<NCAStatRowController> = this.AddStatRow(NCA.Labels().Love());
        if IsDefined(love) {
            love.SetIcon(NCAWebsite.IconAtlas(), n"love");
            love.SetLabel(NCA.Util().LoveLabel(npc.GetLove()));
            love.SetValue(ToString(npc.GetLove()));
            love.SetFill(Cast<Float>(npc.GetLove()) / 100.0);
        }
    }

    private func BuildOffenceRows(puppet: wref<ScriptedPuppet>) -> Void {
        if !IsDefined(puppet) {
            return;
        }

        let id: EntityID = puppet.GetEntityID();

        this.AddValueRow(this.StatName(gamedataStatType.CritChance),
            ToString(RoundF(this.StatOf(id, gamedataStatType.CritChance))) + " %");
        this.AddValueRow(this.StatName(gamedataStatType.CritDamage),
            ToString(RoundF(this.StatOf(id, gamedataStatType.CritDamage))) + " %");
    }

    private func BuildDefenceRows(puppet: wref<ScriptedPuppet>) -> Void {
        if !IsDefined(puppet) {
            return;
        }

        let id: EntityID = puppet.GetEntityID();

        this.AddValueRow(this.StatName(gamedataStatType.Armor), ToString(RoundF(this.StatOf(id, gamedataStatType.Armor))));

        this.AddResistanceRow(id, gamedataStatType.PhysicalResistance);
        this.AddResistanceRow(id, gamedataStatType.ThermalResistance);
        this.AddResistanceRow(id, gamedataStatType.ElectricResistance);
        this.AddResistanceRow(id, gamedataStatType.ChemicalResistance);
        this.AddResistanceRow(id, gamedataStatType.HackingResistance);

        this.AddResistanceRow(id, gamedataStatType.MeleeResistance);
        this.AddResistanceRow(id, gamedataStatType.ExplosionResistance);
        this.AddResistanceRow(id, gamedataStatType.QuickhackResistance);
        this.AddResistanceRow(id, gamedataStatType.DamageOverTimeResistance);
        this.AddResistanceRow(id, gamedataStatType.BossResistance);
        this.AddResistanceRow(id, gamedataStatType.MechResistance);
    }

    private func AddFactionRow(metadata: ref<CompanionMetadata>) -> Void {
        if !IsStringValid(metadata.affiliationName) {
            return;
        }

        let row: ref<NCAStatRowController> = this.AddStatRow(NCA.Labels().Faction());
        if !IsDefined(row) {
            return;
        }

        row.SetLabel(metadata.affiliationName);
        row.SetIcon(NCAEquipmentPanel.GangIconAtlas(), metadata.affiliationIcon);
    }

    private func AddResistanceRow(entityID: EntityID, stat: gamedataStatType) -> Void {
        let value: Int32 = RoundF(this.StatOf(entityID, stat));
        if value == 0 {
            return;
        }

        this.AddValueRow(this.StatName(stat), ToString(value) + " %");
    }

    // (rpgManager.swift:1599-1601)
    // (ripperdocInventoryController.swift:132).
    private func StatName(stat: gamedataStatType) -> String {
        let record: ref<Stat_Record> = RPGManager.GetStatRecord(stat);

        if IsDefined(record) && IsStringValid(record.LocalizedName()) {
            return record.LocalizedName();
        }

        return EnumValueToString("gamedataStatType", Cast<Int64>(EnumInt(stat)));
    }

    private func AddValueRow(title: String, value: String) -> Void {
        let row: ref<NCAStatRowController> = this.AddStatRow(title);
        if IsDefined(row) {
            row.SetValue(value);
        }
    }

    private func AddLabelRow(title: String, label: String) -> Void {
        let row: ref<NCAStatRowController> = this.AddStatRow(title);
        if IsDefined(row) {
            row.SetLabel(label);
        }
    }

    private func AddWatchedRow(title: String, entityID: EntityID, pool: gamedataStatPoolType) -> Void {
        let row: ref<NCAStatRowController> = this.AddStatRow(title);
        if IsDefined(row) {
            row.WatchStatPool(entityID, pool);
        }
    }

    private func StatOf(entityID: EntityID, stat: gamedataStatType) -> Float {
        return GameInstance.GetStatsSystem(GetGameInstance()).GetStatValue(Cast<StatsObjectID>(entityID), stat);
    }

    private func AddStatRow(title: String) -> ref<NCAStatRowController> {
        let none: ref<NCAStatRowController>;

        let widget: wref<inkWidget> = this.SpawnFromLocal(this.m_stats, NCAEquipmentPanel.StatRowName());
        if !IsDefined(widget) {
            NCA.CETLog("[panel] WARNING " + NameToString(NCAEquipmentPanel.StatRowName()) + " did not spawn");
            return none;
        }

        let row = widget.GetController() as NCAStatRowController;
        if !IsDefined(row) {
            NCA.CETLog("[panel] WARNING " + NameToString(NCAEquipmentPanel.StatRowName())
                + " has no NCAStatRowController");
            return none;
        }

        row.Setup();
        row.SetTitle(title);

        return row;
    }

    private func FillCompanionSlots(npc: ref<NpcHandle>) -> Void {
        if !IsDefined(this.m_companionSlots) {
            return;
        }

        this.m_companionSlots.RemoveAllChildren();
        ArrayClear(this.m_companionItemData);
        this.m_selectedSlotOccupied = false;

        let slots: array<CName> = NCAEquipmentSystem.Slots();
        let i: Int32 = 0;
        while i < ArraySize(slots) {
            this.SpawnCompanionTile(npc, slots[i], i);
            i += 1;
        }
    }

    private func FillPlayerItems() -> Void {
        if !IsDefined(this.m_playerItems) {
            return;
        }

        this.m_playerItems.RemoveAllChildren();
        ArrayClear(this.m_playerItemData);

        this.m_playerWeapons = NCA.Util().CollectPlayerWeapons();

        let transactions = GameInstance.GetTransactionSystem(GetGameInstance());
        let i: Int32 = 0;
        while i < ArraySize(this.m_playerWeapons) {
            let itemData: wref<gameItemData> = transactions.GetItemData(NCA.Player(), this.m_playerWeapons[i]);

            if IsDefined(itemData) {
                let item: ref<UIInventoryItem> = UIInventoryItem.Make(NCA.Player(), itemData, this.m_itemsManager);
                ArrayPush(this.m_playerItemData, item);

                let display = this.SpawnTile(this.m_playerItems, item, i);
                display.RegisterToCallback(n"OnRelease", this, n"OnPlayerItemClick");
                display.RegisterToCallback(n"OnHoverOver", this, n"OnTileHoverOver");
                display.RegisterToCallback(n"OnHoverOver", this, n"OnPlayerItemHoverOver");
                display.RegisterToCallback(n"OnHoverOut", this, n"OnHintsHoverOut");
            }

            i += 1;
        }
    }

    private func SpawnCompanionTile(npc: ref<NpcHandle>, equipSlot: CName, slotIndex: Int32) -> Void {
        let item: wref<UIInventoryItem> = this.MakeSlotItem(npc, equipSlot);

        if Equals(equipSlot, this.m_selectedSlot) {
            this.m_selectedSlotOccupied = IsDefined(item);
        }

        let display = this.SpawnTile(this.m_companionSlots, item, slotIndex);

        display.RegisterToCallback(n"OnRelease", this, n"OnCompanionSlotClick");

        display.RegisterToCallback(n"OnHoverOver", this, n"OnCompanionTileHoverOver");
        display.RegisterToCallback(n"OnHoverOver", this, n"OnCompanionSlotHoverOver");
        display.RegisterToCallback(n"OnHoverOut", this, n"OnHintsHoverOut");
        display.RegisterToCallback(n"OnHoverOut", this, n"OnCompanionSlotHoverOut");

        this.SetTileDimmed(display, this.IsSlotDimmed(equipSlot));
    }

    private func SetTileDimmed(display: ref<InventoryItemDisplayController>, dimmed: Bool) -> Void {
        display.GetRootWidget().SetOpacity(dimmed ? 0.4 : 1.0);
    }

    private func IsSlotDimmed(slot: CName) -> Bool {
        return IsNameValid(this.m_selectedSlot) && !Equals(slot, this.m_selectedSlot);
    }

    private func SpawnTile(container: wref<inkCompoundWidget>, item: wref<UIInventoryItem>, slotIndex: Int32)
            -> ref<InventoryItemDisplayController> {
        let widget: wref<inkWidget> = this.SpawnFromExternal(container, r"base\\gameplay\\gui\\common\\components\\slots.inkwidget", n"weaponDisplay");

        let display = widget.GetController() as InventoryItemDisplayController;
        display.Setup(item, gamedataEquipmentArea.Weapon, "", slotIndex, this.m_displayContext);
        display.NCAClearPlayerState();
        display.RegisterToCallback(n"OnHoverOut", this, n"OnTileHoverOut");

        return display;
    }

    private func MakeSlotItem(npc: ref<NpcHandle>, equipSlot: CName) -> wref<UIInventoryItem> {
        let empty: wref<UIInventoryItem>;

        let puppet: wref<ScriptedPuppet> = npc.GetEntity();
        if !IsDefined(puppet) {
            return empty;
        }

        let wanted: TweakDBID = NCA.Equipment().GetSlotRecordID(npc.GetRecordID(), equipSlot);
        if !TDBID.IsValid(wanted) {
            return empty;
        }

        let transactions = GameInstance.GetTransactionSystem(GetGameInstance());
        let carried: array<ItemID> = NCAEquipmentPanelController.CollectWeapons(puppet);

        NCA.CETLog("[panel] weapon rows: " + IntToString(ArraySize(carried)));

        let i: Int32 = 0;
        while i < ArraySize(carried) {
            if Equals(ItemID.GetTDBID(carried[i]), wanted) {
                let itemData: wref<gameItemData> = transactions.GetItemData(puppet, carried[i]);

                if IsDefined(itemData) {
                    let item: ref<UIInventoryItem> = UIInventoryItem.Make(puppet, itemData, this.m_itemsManager);
                    ArrayPush(this.m_companionItemData, item);

                    return item;
                }
            }

            i += 1;
        }

        return empty;
    }

    private static func CollectWeapons(owner: wref<GameObject>) -> array<ItemID> {
        let weapons: array<ItemID>;
        let transactions = GameInstance.GetTransactionSystem(GetGameInstance());

        NCAEquipmentPanelController.PushSlotWeapon(weapons, transactions, owner, t"AttachmentSlots.WeaponRight");
        NCAEquipmentPanelController.PushSlotWeapon(weapons, transactions, owner, t"AttachmentSlots.WeaponLeft");

        let carried: array<wref<gameItemData>>;
        transactions.GetItemList(owner, carried);

        let i: Int32 = 0;
        while i < ArraySize(carried) {
            let item: wref<gameItemData> = carried[i];
            if item.HasTag(n"Weapon") && !item.HasTag(n"Quest") {
                let id: String = TDBID.ToStringDEBUG(ItemID.GetTDBID(item.GetID()));
                if !StrContains(id, "fists") && !StrContains(id, "Cutscene") && !ArrayContains(weapons, item.GetID()) {
                    ArrayPush(weapons, item.GetID());
                }
            }
            i += 1;
        }

        return weapons;
    }

    private static func PushSlotWeapon(out weapons: array<ItemID>, transactions: ref<TransactionSystem>, owner: wref<GameObject>, slot: TweakDBID) -> Void {
        let held: ref<ItemObject> = transactions.GetItemInSlot(owner, slot);
        if IsDefined(held) && !ArrayContains(weapons, held.GetItemID()) {
            ArrayPush(weapons, held.GetItemID());
        }
    }
}
