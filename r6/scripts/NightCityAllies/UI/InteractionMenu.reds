module NightCityAllies.UI

import NightCityAllies.*
import NightCityAllies.Npc.*
import NightCityAllies.Persistence.*
import NightCityAllies.Settings.*
import NightCityAllies.UI.Interactions.*
import NightCityAllies.Event.*
import NightCityAllies.Localization.*

public class NCAInteractionMenu extends ScriptableSystem {
    private static func GetButtonHubId() -> Int32 = -69419;
    private static func GetMenuHubId() -> Int32 = -69420;
    private let m_hub: ListChoiceHubData;
    private let m_isShown: Bool;
    private let m_selectedIndex: Int32;
    private let m_lastNativeEdge: Int32;
    private let m_swallowNextScroll: Bool;
    private let m_confirmDone: Bool;
    private let m_inProximity: array<ref<NpcHandle>>;
    private let m_lookAtNpc: ref<NpcHandle>;
    private let m_activeNpc: ref<NpcHandle>;
    private let m_isCollapsed: Bool;
    private let m_collapsedGearRow: Int32;
    private let m_buttonNpc: ref<NpcHandle>;
    private let m_nativeHubCount: Int32;
    private let m_nativePromptActive: Bool;
    private let m_nativePromptId: Int32;
    private let m_inDialogsEvent: Bool;
    private let m_nativeLootActive: Bool;
    private let m_suppressed: Bool;
    private let m_entries: array<ref<NCAInteractionEntry>>;
    private let m_pageEntries: array<ref<NCAInteractionEntry>>;
    private let m_pageTitle: String;
    private let m_pageToken: Int32;
    private let m_visibleEntries: array<ref<NCAInteractionEntry>>;
    private let m_visibleRows: array<Int32>;
    private let m_scrollOffset: Int32;
    private let m_totalRows: Int32;

    public func OpenPage(title: String, entries: array<ref<NCAInteractionEntry>>) -> Void {
        if !IsDefined(this.m_activeNpc) {
            return;
        }

        this.m_pageTitle = title;
        this.m_pageEntries = entries;
        this.m_isRootPage = false;
        this.m_pageToken += 1;

        this.ShowHub(this.m_activeNpc);
    }

// ==================================================== Lua ============================================================
    private let m_luaEntries: array<ref<NCALuaInteractionEntry>>;
    private let m_luaToken: Int32;
    private let m_isRootPage: Bool;
    private let m_isBuildingPage: Bool;

    public func AddLuaEntry(token: Int32, id: Int32, label: String, icon: TweakDBID, choiceType: gameinteractionsChoiceType) -> Void {
        if token != this.m_luaToken || !IsDefined(this.m_activeNpc) {
            return;
        }

        ArrayPush(this.m_luaEntries, NCALuaInteractionEntry.Create(id, label, icon, choiceType));

        if !this.m_isBuildingPage {
            this.RefreshFor(this.m_activeNpc);
        }
    }

    public func RegisterEntry(entry: ref<NCAInteractionEntry>) -> Void {
        ArrayPush(this.m_entries, entry);
    }

    public func ClearEntries() -> Void {
        ArrayClear(this.m_entries);
    }

    public func IsShown() -> Bool = this.m_isShown

    public func GetHub() -> ListChoiceHubData = this.m_hub

    public func GetHubId() -> Int32 = this.m_hub.id

    public func GetSelectedIndex() -> Int32 = this.m_selectedIndex

    public func CursorIsOurs() -> Bool {
        return this.IsShown() && this.GetActiveHubId() == this.m_hub.id;
    }

    public func OwnsCursor() -> Bool {
        return this.CursorIsOurs() && this.NativeHubCount() <= 0;
    }

// ================================================= Proximity =========================================================

    public func OnProximityChanged(npc: ref<NpcHandle>) -> Void {
        if npc.playerProximity {
            if !ArrayContains(this.m_inProximity, npc) {
                ArrayPush(this.m_inProximity, npc);
            }
        } else {
            ArrayRemove(this.m_inProximity, npc);
        }

        this.UpdateHub();
    }

    public func OnLookAtChanged(npc: ref<NpcHandle>) -> Void {
        this.m_lookAtNpc = npc;

        this.UpdateHub();
    }

    public func OnTick() -> Void {
        if !this.m_isShown && !IsDefined(this.m_buttonNpc) {
            return;
        }

        this.UpdateHub();
    }

    // Hides the prompt and the menu for as long as something else owns the screen, and puts them
    // back by re-running the normal decision rather than restoring what was showing before - the
    // player may have walked away or looked elsewhere while it was hidden.
    public func SetSuppressed(suppressed: Bool) -> Void {
        if Equals(suppressed, this.m_suppressed) {
            return;
        }

        this.m_suppressed = suppressed;
        this.UpdateHub();
    }

    public func UpdateHub() -> Void {
        if this.m_suppressed {
            this.HideHub();
            return;
        }

        let target: ref<NpcHandle> = this.GetProximityTarget();

        if !IsDefined(target) {
            this.HideHub();
            return;
        }

        if this.IsBlockedByNativeUI() {
            this.HideHub();
            return;
        }

        if this.m_isShown && !this.m_isCollapsed {
            if target != this.m_activeNpc {
                this.OpenRootPage(target);
            }

            return;
        }

        if NCA.Settings().collapseInteractionMenu {
            this.ShowCollapsed(target);
            return;
        }

        if target != this.m_activeNpc || !this.m_isShown {
            this.OpenRootPage(target);
        }
    }

    public func SetNativeHubCount(count: Int32) -> Void {
        if count == this.m_nativeHubCount {
            return;
        }

        this.m_nativeHubCount = count;

        this.m_inDialogsEvent = true;
        this.UpdateHub();
        this.m_inDialogsEvent = false;
    }

    public func SetNativePrompt(id: Int32, active: Bool) -> Void {
        let value: Bool = active && id != NCAInteractionMenu.GetButtonHubId();

        if Equals(value, this.m_nativePromptActive) && id == this.m_nativePromptId {
            return;
        }

        this.m_nativePromptActive = value;
        this.m_nativePromptId = id;
        this.UpdateHub();
    }

    public func SetNativeLootActive(active: Bool) -> Void {
        if Equals(active, this.m_nativeLootActive) {
            return;
        }

        this.m_nativeLootActive = active;
        this.UpdateHub();
    }

    private func IsBlockedByNativeUI() -> Bool {
        if this.m_nativeHubCount > 0 {
            return false;
        }

        return this.m_nativePromptActive || this.m_nativeLootActive;
    }

    private func OpenRootPage(npc: ref<NpcHandle>) -> Void {
        this.HideButton();
        this.m_isCollapsed = false;
        this.SetActiveNpc(npc);
        this.m_pageTitle = npc.GetName();
        this.m_pageEntries = this.m_entries;
        this.m_isRootPage = true;
        this.m_pageToken += 1;

        ArrayClear(this.m_luaEntries);
        this.m_luaToken += 1;

        this.m_isBuildingPage = true;
        NCA.Events().OnBuildInteractionMenu(npc, this.m_luaToken);
        this.m_isBuildingPage = false;

        this.ShowHub(npc);
    }

    public func RefreshFor(npc: ref<NpcHandle>) -> Void {
        if !this.m_isShown || this.m_isCollapsed || npc != this.m_activeNpc {
            return;
        }

        let rebuilt: ListChoiceHubData = this.BuildHub(npc, this.m_hub.id);

        if ArraySize(rebuilt.choices) <= 0 {
            this.HideHub();
            return;
        }

        if this.HasSameRows(rebuilt) {
            return;
        }

        this.m_hub = rebuilt;

        if this.m_selectedIndex >= ArraySize(rebuilt.choices) {
            this.m_selectedIndex = this.LastContentIndex();
        }

        this.RefreshDialogHubs();

        if this.OwnsCursor() {
            this.AssertCursor();
        }
    }

    private func HasSameRows(rebuilt: ListChoiceHubData) -> Bool {
        if ArraySize(rebuilt.choices) != ArraySize(this.m_hub.choices) {
            return false;
        }

        let i: Int32 = 0;

        while i < ArraySize(rebuilt.choices) {
            if !Equals(rebuilt.choices[i].localizedName, this.m_hub.choices[i].localizedName) {
                return false;
            }

            i += 1;
        }

        return true;
    }

    private static func GetSelectionRadius() -> Float = 5.0

    private func GetProximityTarget() -> ref<NpcHandle> {
        if NCA.Context().isInCar || NCA.Context().isInCombat || NCA.Context().isInInteraction {
            return null;
        }

        this.PruneProximity();

        if ArraySize(this.m_inProximity) <= 0 {
            return null;
        }

        let player: ref<PlayerPuppet> = NCA.Player();

        if !IsDefined(player) {
            return this.FindClosest(this.m_inProximity);
        }

        let candidates: array<ref<NpcHandle>> = NCA.NPC().GetSpawnedNear(player.GetWorldPosition(), NCAInteractionMenu.GetSelectionRadius());

        if IsDefined(this.m_lookAtNpc) && ArrayContains(candidates, this.m_lookAtNpc) {
            return this.m_lookAtNpc;
        }

        let closest: ref<NpcHandle> = this.FindClosest(candidates);

        if IsDefined(closest) {
            return closest;
        }

        return this.FindClosest(this.m_inProximity);
    }

    private func PruneProximity() -> Void {
        let i: Int32 = ArraySize(this.m_inProximity) - 1;

        while i >= 0 {
            let npc: ref<NpcHandle> = this.m_inProximity[i];

            if !npc.IsSpawned() || !IsDefined(npc.GetEntity()) {
                ArrayErase(this.m_inProximity, i);
            }

            i -= 1;
        }
    }

    private func FindClosest(candidates: array<ref<NpcHandle>>) -> ref<NpcHandle> {
        let player: ref<PlayerPuppet> = NCA.Player();

        if !IsDefined(player) {
            return null;
        }

        let playerPosition: Vector4 = player.GetWorldPosition();
        let closest: ref<NpcHandle>;
        let closestDistance: Float = 0.0;
        let i: Int32 = 0;

        while i < ArraySize(candidates) {
            let npc: ref<NpcHandle> = candidates[i];

            if IsDefined(npc.GetEntity()) {
                let distance: Float = Vector4.Distance(playerPosition, npc.GetEntity().GetWorldPosition());

                if !IsDefined(closest) || distance < closestDistance {
                    closest = npc;
                    closestDistance = distance;
                }
            }

            i += 1;
        }

        return closest;
    }

// ================================================== Display ==========================================================

    public func HideHub() -> Void {
        if !this.m_suppressed {
            this.SetActiveNpc(null);
        }

        this.HideButton();
        this.m_isCollapsed = false;

        if !this.m_isShown {
            return;
        }

        this.m_isShown = false;
        this.RefreshDialogHubs();
    }

    private func SetActiveNpc(npc: ref<NpcHandle>) -> Void {
        if this.m_activeNpc == npc {
            return;
        }

        if IsDefined(this.m_activeNpc) {
            this.m_activeNpc.CollapseSquadWidget();
            this.m_activeNpc.SetInteractionHold(false);
        }

        this.m_activeNpc = npc;

        if IsDefined(npc) {
            npc.ExpandSquadWidget();
            npc.SetInteractionHold(true);
        }
    }

    private func ShowHub(npc: ref<NpcHandle>) -> Void {
        this.m_scrollOffset = 0;

        let hub: ListChoiceHubData = this.BuildHub(npc, NCAInteractionMenu.GetMenuHubId());

        if ArraySize(hub.choices) <= 0 {
            this.HideHub();
            return;
        }

        this.m_hub = hub;
        this.m_selectedIndex = 0;
        this.m_lastNativeEdge = 0;
        this.m_swallowNextScroll = false;
        this.m_isShown = true;
        this.RefreshDialogHubs();

        if this.NativeHubCount() <= 0 {
            this.AssertCursor();
        }
    }

    private func ShowCollapsed(npc: ref<NpcHandle>) -> Void {
        if this.m_nativeHubCount > 0 {
            this.HideButton();
            this.ShowCollapsedHub(npc);
            return;
        }

        this.HideDialogHub();
        this.ShowButton(npc);
    }

    private func ShowCollapsedHub(npc: ref<NpcHandle>) -> Void {
        if this.m_isShown && this.m_isCollapsed && this.m_activeNpc == npc {
            return;
        }

        this.SetActiveNpc(npc);
        this.m_scrollOffset = 0;

        ArrayClear(this.m_visibleEntries);
        ArrayClear(this.m_visibleRows);

        let hub: ListChoiceHubData;
        hub.id = NCAInteractionMenu.GetMenuHubId();
        hub.title = NCA.Labels().Interact();
        hub.activityState = EVisualizerActivityState.Active;
        ArrayPush(hub.choices, this.BuildChoice(npc.GetName(), t"ChoiceCaptionParts.None", gameinteractionsChoiceType.Blueline));

        this.m_collapsedGearRow = -1;

        if NCAInteractionMenu.ShowsEquipmentButtonFor(npc) {
            ArrayPush(hub.choices, this.BuildChoice(NCA.Labels().Gear(), t"ChoiceCaptionParts.GunIcon", gameinteractionsChoiceType.Blueline));
            this.m_collapsedGearRow = ArraySize(hub.choices) - 1;
        }

        this.m_hub = hub;
        this.m_totalRows = ArraySize(hub.choices);
        this.m_selectedIndex = 0;
        this.m_lastNativeEdge = 0;
        this.m_swallowNextScroll = false;
        this.m_isCollapsed = true;
        this.m_isShown = true;
        this.RefreshDialogHubs();

        if this.NativeHubCount() <= 0 {
            this.AssertCursor();
        }
    }

    private func HideDialogHub() -> Void {
        if !this.m_isShown {
            return;
        }

        this.m_isShown = false;
        this.m_isCollapsed = false;
        this.RefreshDialogHubs();
    }

    private func ShowButton(npc: ref<NpcHandle>) -> Void {
        if this.m_buttonNpc == npc && this.ReadButtonHub().id == NCAInteractionMenu.GetButtonHubId() {
            return;
        }

        let current: InteractionChoiceHubData = this.ReadButtonHub();

        if current.active && current.id != NCAInteractionMenu.GetButtonHubId() {
            return;
        }

        let choiceType: ChoiceTypeWrapper;
        ChoiceTypeWrapper.SetType(choiceType, gameinteractionsChoiceType.Blueline);

        let choice: InteractionChoiceData;
        choice.localizedName = npc.GetName();
        choice.inputAction = n"Choice1";
        choice.type = choiceType;

        let hub: InteractionChoiceHubData;
        hub.id = NCAInteractionMenu.GetButtonHubId();
        hub.active = true;
        ArrayPush(hub.choices, choice);

        if NCAInteractionMenu.ShowsEquipmentButtonFor(npc) {
            let equipment: InteractionChoiceData;
            equipment.localizedName = NCA.Labels().Gear();
            equipment.inputAction = n"Choice2";
            equipment.type = choiceType;

            ArrayPush(hub.choices, equipment);
        }

        this.WriteButtonHub(hub);

        this.m_buttonNpc = npc;
        this.m_isCollapsed = true;
        this.SetActiveNpc(npc);
    }

    private func HideButton() -> Void {
        let hadButton: Bool = IsDefined(this.m_buttonNpc);
        this.m_buttonNpc = null;

        let current: InteractionChoiceHubData = this.ReadButtonHub();

        if current.active && current.id != NCAInteractionMenu.GetButtonHubId() {
            return;
        }

        if !hadButton && current.id != NCAInteractionMenu.GetButtonHubId() {
            return;
        }

        let empty: InteractionChoiceHubData;
        this.WriteButtonHub(empty);
    }

    private func ReadButtonHub() -> InteractionChoiceHubData {
        let empty: InteractionChoiceHubData;
        let defs = GetAllBlackboardDefs();
        let blackboard = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(defs.UIInteractions);

        if !IsDefined(blackboard) {
            return empty;
        }

        return FromVariant<InteractionChoiceHubData>(blackboard.GetVariant(defs.UIInteractions.InteractionChoiceHub));
    }

    private func WriteButtonHub(hub: InteractionChoiceHubData) -> Void {
        let defs = GetAllBlackboardDefs();
        let blackboard = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(defs.UIInteractions);

        if !IsDefined(blackboard) {
            return;
        }

        let visualizers: VisualizersInfo;

        if hub.active {
            visualizers.activeVisId = hub.id;
            visualizers.visIds = [hub.id];
        } else {
            visualizers.activeVisId = -1;
        }

        blackboard.SetVariant(defs.UIInteractions.InteractionChoiceHub, ToVariant(hub), true);
        blackboard.SetVariant(defs.UIInteractions.VisualizersInfo, ToVariant(visualizers), true);
    }

    private func GetBuildEntries() -> array<ref<NCAInteractionEntry>> {
        let entries: array<ref<NCAInteractionEntry>> = this.m_pageEntries;

        if !this.m_isRootPage {
            return entries;
        }

        let i: Int32 = 0;

        while i < ArraySize(this.m_luaEntries) {
            ArrayPush(entries, this.m_luaEntries[i]);
            i += 1;
        }

        return entries;
    }

    private static func GetWindowRows() -> Int32 {
        return Max(4, NCA.Settings().interactionMenuRows);
    }

    private static func GetScrollMarkerLabel() -> String = "...";

    private func BuildHub(npc: ref<NpcHandle>, hubId: Int32) -> ListChoiceHubData {
        let hub: ListChoiceHubData;
        hub.id = hubId;
        hub.title = this.m_pageTitle;
        hub.activityState = EVisualizerActivityState.Active;

        ArrayClear(this.m_visibleEntries);
        ArrayClear(this.m_visibleRows);

        let choices: array<ListChoiceData>;
        let rowEntries: array<ref<NCAInteractionEntry>>;
        let rowIndices: array<Int32>;

        let entries: array<ref<NCAInteractionEntry>> = this.GetBuildEntries();
        let i: Int32 = 0;

        while i < ArraySize(entries) {
            let entry: ref<NCAInteractionEntry> = entries[i];

            if entry.IsAvailable(npc) {
                let row: Int32 = 0;
                let rowCount: Int32 = entry.GetRowCount(npc);

                while row < rowCount {
                    ArrayPush(choices, this.BuildChoice(entry.GetLabel(npc, row), entry.GetIcon(npc, row), entry.GetChoiceType(npc, row)));
                    ArrayPush(rowEntries, entry);
                    ArrayPush(rowIndices, row);

                    row += 1;
                }
            }

            i += 1;
        }

        this.WindowRows(choices, rowEntries, rowIndices, hub);

        return hub;
    }

    private func WindowRows(choices: array<ListChoiceData>, rowEntries: array<ref<NCAInteractionEntry>>,
                            rowIndices: array<Int32>, out hub: ListChoiceHubData) -> Void {
        this.m_totalRows = ArraySize(choices);

        if this.m_totalRows <= NCAInteractionMenu.GetWindowRows() {
            this.m_scrollOffset = 0;
            hub.choices = choices;
            this.m_visibleEntries = rowEntries;
            this.m_visibleRows = rowIndices;
            return;
        }

        let first: Int32;
        let last: Int32;
        this.ContentRange(this.m_scrollOffset, first, last);

        this.m_scrollOffset = first;

        if first > 0 {
            this.PushMarker(hub);
        }

        let i: Int32 = first;

        while i <= last {
            ArrayPush(hub.choices, choices[i]);
            ArrayPush(this.m_visibleEntries, rowEntries[i]);
            ArrayPush(this.m_visibleRows, rowIndices[i]);

            i += 1;
        }

        if last < this.m_totalRows - 1 {
            this.PushMarker(hub);
        }
    }

    private func ContentRange(offset: Int32, out first: Int32, out last: Int32) -> Void {
        let total: Int32 = this.m_totalRows;
        let windowRows: Int32 = NCAInteractionMenu.GetWindowRows();

        if total <= windowRows {
            first = 0;
            last = total - 1;
            return;
        }

        first = Max(0, Min(offset, total - windowRows + 1));

        if first <= 1 {
            first = 0;
            last = windowRows - 2;
            return;
        }

        if total - first <= windowRows - 1 {
            last = total - 1;
            return;
        }

        last = first + windowRows - 3;
    }

    private func PushMarker(out hub: ListChoiceHubData) -> Void {
        ArrayPush(hub.choices, this.BuildChoice(NCAInteractionMenu.GetScrollMarkerLabel(),
            t"ChoiceCaptionParts.None", gameinteractionsChoiceType.AlreadyRead));
        ArrayPush(this.m_visibleEntries, null);
        ArrayPush(this.m_visibleRows, -1);
    }

    private func IsMarker(index: Int32) -> Bool {
        return index >= 0 && index < ArraySize(this.m_visibleEntries) && !IsDefined(this.m_visibleEntries[index]);
    }

    private func FirstContentIndex() -> Int32 {
        return this.IsMarker(0) ? 1 : 0;
    }

    private func LastContentIndex() -> Int32 {
        let last: Int32 = ArraySize(this.m_visibleEntries) - 1;
        return this.IsMarker(last) ? last - 1 : last;
    }

    private func SetWindow(offset: Int32) -> Void {
        if offset == this.m_scrollOffset {
            return;
        }

        this.m_scrollOffset = offset; // ContentRange clamps it during the build
        this.m_hub = this.BuildHub(this.m_activeNpc, this.m_hub.id);
        this.RefreshDialogHubs();
    }

    private func SelectedRow() -> Int32 {
        let first: Int32;
        let last: Int32;
        this.ContentRange(this.m_scrollOffset, first, last);

        return first + this.m_selectedIndex - (first > 0 ? 1 : 0);
    }

    private func SelectRow(row: Int32) -> Void {
        let target: Int32 = Max(0, Min(row, this.m_totalRows - 1));
        let offset: Int32 = this.m_scrollOffset;
        let first: Int32;
        let last: Int32;
        let steps: Int32 = 0;

        while steps <= this.m_totalRows {
            this.ContentRange(offset, first, last);

            if target < first {
                offset -= 1;
            } else {
                if target > last {
                    offset += 1;
                } else {
                    break;
                }
            }

            steps += 1;
        }

        this.SetWindow(offset);

        this.ContentRange(this.m_scrollOffset, first, last);
        this.m_selectedIndex = (target - first) + (first > 0 ? 1 : 0);
    }

    private func BuildChoice(label: String, icon: TweakDBID, choiceType: gameinteractionsChoiceType) -> ListChoiceData {
        let choice: ListChoiceData;
        choice.localizedName = label;
        choice.inputActionName = n"None";

        let iconRecord: ref<ChoiceCaptionIconPart_Record> = TweakDBInterface.GetChoiceCaptionIconPartRecord(icon);

        if IsDefined(iconRecord) {
            let caption: InteractionChoiceCaption;
            InteractionChoiceCaption.AddPartFromRecord(caption, iconRecord);
            choice.captionParts = caption;
        }

        let wrapper: ChoiceTypeWrapper;
        ChoiceTypeWrapper.SetType(wrapper, choiceType);
        choice.type = wrapper;

        return choice;
    }

    private func ConfirmSelection() -> Void {
        if this.m_selectedIndex < 0 || this.m_selectedIndex >= ArraySize(this.m_visibleEntries) {
            return;
        }

        let entry: ref<NCAInteractionEntry> = this.m_visibleEntries[this.m_selectedIndex];

        if !IsDefined(entry) {
            return;
        }

        let row: Int32 = this.m_visibleRows[this.m_selectedIndex];
        let npc: ref<NpcHandle> = this.m_activeNpc;
        let token: Int32 = this.m_pageToken;

        entry.Run(npc, row, this);

        if this.m_pageToken != token {
            return;
        }

        let target: ref<NpcHandle> = this.GetProximityTarget();

        if !IsDefined(target) {
            this.HideHub();
            return;
        }

        if NCA.Settings().collapseInteractionMenu && NCA.Settings().collapseAfterSelection {
            this.ShowCollapsed(target);
            return;
        }

        this.OpenRootPage(target);
    }

    private func RefreshDialogHubs() -> Void {
        if this.m_inDialogsEvent {
            return;
        }

        let defs = GetAllBlackboardDefs();
        let blackboard = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(defs.UIInteractions);

        if !IsDefined(blackboard) {
            return;
        }

        blackboard.SetVariant(defs.UIInteractions.DialogChoiceHubs, blackboard.GetVariant(defs.UIInteractions.DialogChoiceHubs), true);
    }

// =================================================== Input ===========================================================

    private func GetConfirmAction() -> CName {
        if IsDefined(this.m_buttonNpc) {
            return n"Choice1";
        }

        return n"ChoiceApply";
    }

    private func ConfirmsOnRelease() -> Bool {
        return IsDefined(this.m_buttonNpc);
    }

    public static func ShowsEquipmentButton() -> Bool {
        return NCA.Settings().collapseInteractionMenu && NCA.Settings().equipmentPromptButton;
    }

    public static func ShowsEquipmentButtonFor(npc: ref<NpcHandle>) -> Bool {
        return NCAInteractionMenu.ShowsEquipmentButton() && IsDefined(npc) && npc.CanOpenEquipment();
    }

    private static func IsConfirmKey(actionName: CName) -> Bool {
        return Equals(actionName, n"Choice1") || Equals(actionName, n"ChoiceApply");
    }

    public func HandleAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Void {
        if this.m_suppressed {
            return;
        }

        let actionName: CName = ListenerAction.GetName(action);

        if NCAInteractionMenu.ShowsEquipmentButtonFor(this.m_buttonNpc) && Equals(actionName, n"Choice2_Release")
        && ListenerAction.IsButtonJustPressed(action) {
            NCA.UI().OpenEquipmentPanel(this.m_buttonNpc);
            return;
        }

        if NCA.Context().isInInteraction && Equals(actionName, n"ChoiceApply")
        && ListenerAction.IsButtonJustPressed(action) {
            NCA.NPC().StopPerformanceWithPlayer();
            return;
        }

        if NCAInteractionMenu.IsConfirmKey(actionName) && ListenerAction.IsButtonJustPressed(action) {
            this.m_confirmDone = false;
        }

        if Equals(actionName, this.GetConfirmAction()) && !this.m_confirmDone {
            let isConfirmEdge: Bool = this.ConfirmsOnRelease()
                ? ListenerAction.IsButtonJustReleased(action)
                : ListenerAction.IsButtonJustPressed(action);

            if isConfirmEdge {
                if this.CursorIsOurs() {
                    ListenerActionConsumer.Consume(consumer);
                }

                this.m_confirmDone = true;
                this.Confirm();
                return;
            }
        }

        if !ListenerAction.IsButtonJustPressed(action) {
            return;
        }

        if !this.IsShown() || ArraySize(this.m_hub.choices) <= 0 {
            return;
        }

        if Equals(actionName, n"ChoiceScrollDown") {
            this.ScrollDown(consumer);
            return;
        }

        if Equals(actionName, n"ChoiceScrollUp") {
            this.ScrollUp(consumer);
            return;
        }
    }

    private func Confirm() -> Void {
        if IsDefined(this.m_buttonNpc) {
            this.OpenRootPage(this.m_buttonNpc);
            return;
        }

        if !this.CursorIsOurs() {
            return;
        }

        if this.m_isCollapsed {
            if IsDefined(this.m_activeNpc) {
                if this.m_collapsedGearRow > 0 && this.SelectedRow() == this.m_collapsedGearRow {
                    NCA.UI().OpenEquipmentPanel(this.m_activeNpc);
                    return;
                }

                this.OpenRootPage(this.m_activeNpc);
            }

            return;
        }

        this.ConfirmSelection();
    }

    private func ScrollDown(consumer: ListenerActionConsumer) -> Void {
        if this.m_swallowNextScroll {
            this.m_swallowNextScroll = false;
            ListenerActionConsumer.Consume(consumer);
            return;
        }

        let hubs: array<ListChoiceHubData> = this.NativeHubs();

        if ArraySize(hubs) <= 0 && !this.CursorIsOurs() {
            this.ReclaimCursor(consumer);
            return;
        }

        if !this.CursorIsOurs() {
            if this.IsNativeAtLastChoice() {
                ListenerActionConsumer.Consume(consumer);
                this.SelectRow(0);
                this.m_lastNativeEdge = 1;
                this.AssertCursor();
            }

            return;
        }

        if this.SelectedRow() < this.m_totalRows - 1 {
            ListenerActionConsumer.Consume(consumer);
            this.SelectRow(this.SelectedRow() + 1);
            this.AssertCursor();
            return;
        }

        this.SelectRow(0);

        if ArraySize(hubs) <= 0 {
            ListenerActionConsumer.Consume(consumer);
            this.AssertCursor();
            return;
        }

        if this.m_lastNativeEdge == 0 || (ArraySize(hubs) == 1 && ArraySize(hubs[0].choices) == 1) {
            this.m_swallowNextScroll = true;
        }

        this.SetActiveHub(hubs[0].id);
        this.SetSelectedIndex(0);
    }

    private func ScrollUp(consumer: ListenerActionConsumer) -> Void {
        if this.m_swallowNextScroll {
            this.m_swallowNextScroll = false;
            ListenerActionConsumer.Consume(consumer);
            return;
        }

        let hubs: array<ListChoiceHubData> = this.NativeHubs();

        if ArraySize(hubs) <= 0 && !this.CursorIsOurs() {
            this.ReclaimCursor(consumer);
            return;
        }

        if !this.CursorIsOurs() {
            if this.IsNativeAtFirstChoice() {
                ListenerActionConsumer.Consume(consumer);
                this.SelectRow(this.m_totalRows - 1);
                this.m_lastNativeEdge = 0;
                this.AssertCursor();
            }

            return;
        }

        if this.SelectedRow() > 0 {
            ListenerActionConsumer.Consume(consumer);
            this.SelectRow(this.SelectedRow() - 1);
            this.AssertCursor();
            return;
        }

        if ArraySize(hubs) <= 0 {
            this.SelectRow(this.m_totalRows - 1);
            ListenerActionConsumer.Consume(consumer);
            this.AssertCursor();
            return;
        }

        let lastHub: ListChoiceHubData = hubs[ArraySize(hubs) - 1];

        if this.m_lastNativeEdge == 1 || (ArraySize(hubs) == 1 && ArraySize(hubs[0].choices) == 1) {
            this.m_swallowNextScroll = true;
        }

        this.SetActiveHub(lastHub.id);
        this.SetSelectedIndex(ArraySize(lastHub.choices) - 1);
    }

    private func ReclaimCursor(consumer: ListenerActionConsumer) -> Void {
        this.m_selectedIndex = this.FirstContentIndex();
        this.m_swallowNextScroll = false;
        this.AssertCursor();
        ListenerActionConsumer.Consume(consumer);
    }

// ================================================= Blackboard ========================================================

    private func AssertCursor() -> Void {
        this.SetActiveHub(this.m_hub.id);
        this.SetSelectedIndex(this.m_selectedIndex);
    }

    private func NativeHubs() -> array<ListChoiceHubData> {
        let empty: array<ListChoiceHubData>;
        let defs = GetAllBlackboardDefs();
        let blackboard = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(defs.UIInteractions);

        if !IsDefined(blackboard) {
            return empty;
        }

        let data: DialogChoiceHubs = FromVariant<DialogChoiceHubs>(blackboard.GetVariant(defs.UIInteractions.DialogChoiceHubs));

        return data.choiceHubs;
    }

    private func NativeHubCount() -> Int32 {
        let hubs: array<ListChoiceHubData> = this.NativeHubs();

        return ArraySize(hubs);
    }

    private func GetActiveHubId() -> Int32 {
        let defs = GetAllBlackboardDefs();
        let blackboard = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(defs.UIInteractions);

        if !IsDefined(blackboard) {
            return -1;
        }

        return blackboard.GetInt(defs.UIInteractions.ActiveChoiceHubID);
    }

    private func GetNativeSelectedIndex() -> Int32 {
        let defs = GetAllBlackboardDefs();
        let blackboard = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(defs.UIInteractions);

        if !IsDefined(blackboard) {
            return 0;
        }

        return blackboard.GetInt(defs.UIInteractions.SelectedIndex);
    }

    private func GetActiveNativeHubIndex() -> Int32 {
        let hubs: array<ListChoiceHubData> = this.NativeHubs();
        let activeId: Int32 = this.GetActiveHubId();
        let i: Int32 = 0;

        while i < ArraySize(hubs) {
            if hubs[i].id == activeId {
                return i;
            }

            i += 1;
        }

        return -1;
    }

    private func IsNativeAtLastChoice() -> Bool {
        let hubs: array<ListChoiceHubData> = this.NativeHubs();
        let index: Int32 = this.GetActiveNativeHubIndex();

        if index < 0 {
            return false;
        }

        return index == ArraySize(hubs) - 1 && this.GetNativeSelectedIndex() == ArraySize(hubs[index].choices) - 1;
    }

    private func IsNativeAtFirstChoice() -> Bool {
        return this.GetActiveNativeHubIndex() == 0 && this.GetNativeSelectedIndex() == 0;
    }

    private func SetActiveHub(id: Int32) -> Void {
        let defs = GetAllBlackboardDefs();
        let blackboard = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(defs.UIInteractions);

        if IsDefined(blackboard) {
            blackboard.SetInt(defs.UIInteractions.ActiveChoiceHubID, id, true);
        }
    }

    private func SetSelectedIndex(index: Int32) -> Void {
        let defs = GetAllBlackboardDefs();
        let blackboard = GameInstance.GetBlackboardSystem(GetGameInstance()).Get(defs.UIInteractions);

        if IsDefined(blackboard) {
            blackboard.SetInt(defs.UIInteractions.SelectedIndex, index, true);
        }
    }
}
