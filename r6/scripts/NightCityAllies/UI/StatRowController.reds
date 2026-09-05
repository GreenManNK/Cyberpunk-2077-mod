module NightCityAllies.UI

import NightCityAllies.*

public class NCAStatRowController extends inkLogicController {
    private let m_icon: wref<inkImage>;
    private let m_title: wref<inkText>;
    private let m_label: wref<inkText>;
    private let m_value: wref<inkText>;
    private let m_barWrapper: wref<inkWidget>;
    private let m_fill: wref<inkWidget>;
    private let m_fullSize: Vector2;
    private let m_listener: ref<NCAStatRowListener>;
    private let m_watched: StatsObjectID;
    private let m_watchedPool: gamedataStatPoolType;
    private let m_isWatching: Bool;

    public func Setup() -> Void {
        this.m_icon = this.GetChildWidgetByPath(n"Icon") as inkImage;
        this.m_title = this.GetChildWidgetByPath(n"Content/text_wrapper/Title") as inkText;
        this.m_label = this.GetChildWidgetByPath(n"Content/header_wrapper/Label") as inkText;
        this.m_value = this.GetChildWidgetByPath(n"Content/text_wrapper/Value") as inkText;

        this.m_barWrapper = this.GetChildWidgetByPath(n"Content/bar_wrapper");
        this.m_fill = this.GetChildWidgetByPath(n"Content/bar_wrapper/Bar");

        this.ReportMissing();

        if IsDefined(this.m_fill) {
            this.m_fullSize = this.m_fill.GetSize();
        }

        this.HideIcon();
        this.HideLabel();
        this.SetValue("");
        this.HideBar();
    }

    protected cb func OnUninitialize() -> Bool {
        this.StopWatching();
    }

// ============================================ Plain values ===========================================================

    public func SetTitle(title: String) -> Void {
        if IsDefined(this.m_title) {
            this.m_title.SetText(title);
        }
    }

    public func SetValue(value: String) -> Void {
        if IsDefined(this.m_value) {
            this.m_value.SetText(value);
        }
    }

    public func SetLabel(label: String) -> Void {
        if !IsDefined(this.m_label) {
            return;
        }

        this.m_label.SetVisible(IsStringValid(label));

        if IsStringValid(label) {
            this.m_label.SetText(label);
        }
    }

    public func SetLabelColor(color: HDRColor) -> Void {
        if IsDefined(this.m_label) {
            this.m_label.SetTintColor(color);
        }
    }

    public func SetIcon(atlas: ResRef, part: CName) -> Void {
        if !IsDefined(this.m_icon) {
            return;
        }

        this.m_icon.SetVisible(IsNameValid(part));

        if IsNameValid(part) {
            this.m_icon.SetAtlasResource(atlas);
            this.m_icon.SetTexturePart(part);
        }
    }

    public func SetFill(fraction: Float) -> Void {
        if !IsDefined(this.m_barWrapper) || !IsDefined(this.m_fill) {
            return;
        }

        this.m_barWrapper.SetVisible(true);
        this.m_fill.SetSize(new Vector2(this.m_fullSize.X * ClampF(fraction, 0.0, 1.0), this.m_fullSize.Y));
    }

    public func HideIcon() -> Void {
        if IsDefined(this.m_icon) {
            this.m_icon.SetVisible(false);
        }
    }

    public func HideLabel() -> Void {
        if IsDefined(this.m_label) {
            this.m_label.SetVisible(false);
        }
    }

    public func HideBar() -> Void {
        if IsDefined(this.m_barWrapper) {
            this.m_barWrapper.SetVisible(false);
        }
    }

// ============================================= Watched values ========================================================

    public func WatchStatPool(entityID: EntityID, pool: gamedataStatPoolType) -> Void {
        this.StopWatching();

        let system = GameInstance.GetStatPoolsSystem(GetGameInstance());

        this.m_watched = Cast<StatsObjectID>(entityID);
        this.m_watchedPool = pool;

        let percent: Float = system.GetStatPoolValue(this.m_watched, pool, true);
        let points: Float = system.GetStatPoolValue(this.m_watched, pool, false);

        this.Apply(percent, percent > 0.0 ? points / percent : 0.0);

        this.m_listener = NCAStatRowListener.Create(this);
        system.RequestRegisteringListener(this.m_watched, pool, this.m_listener);
        this.m_isWatching = true;
    }

    public func StopWatching() -> Void {
        if !this.m_isWatching {
            return;
        }

        let system = GameInstance.GetStatPoolsSystem(GetGameInstance());
        system.RequestUnregisteringListener(this.m_watched, this.m_watchedPool, this.m_listener);

        this.m_listener = null;
        this.m_isWatching = false;
    }

    // (statPoolBasedStatusEffectEffector.swift:141)
    public func Apply(percent: Float, percToPoints: Float) -> Void {
        this.SetFill(percent / 100.0);
        this.SetValue(ToString(RoundF(percent * percToPoints)) + " / " + ToString(RoundF(100.0 * percToPoints)));
    }

    private func ReportMissing() -> Void {
        let missing: String = "";

        if !IsDefined(this.m_icon) { missing += " Icon"; }
        if !IsDefined(this.m_title) { missing += " Content/text_wrapper/Title"; }
        if !IsDefined(this.m_label) { missing += " Content/header_wrapper/Label"; }
        if !IsDefined(this.m_value) { missing += " Content/text_wrapper/Value"; }
        if !IsDefined(this.m_barWrapper) { missing += " Content/bar_wrapper"; }
        if !IsDefined(this.m_fill) { missing += " Content/bar_wrapper/Bar"; }

        if IsStringValid(missing) {
            NCA.CETLog("[statrow] WARNING unresolved widgets:" + missing);
        }
    }
}

public class NCAStatRowListener extends ScriptStatPoolsListener {
    private let m_row: wref<NCAStatRowController>;

    public static func Create(row: ref<NCAStatRowController>) -> ref<NCAStatRowListener> {
        let created = new NCAStatRowListener();
        created.m_row = row;
        return created;
    }

    public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
        if IsDefined(this.m_row) {
            this.m_row.Apply(newValue, percToPoints);
        }
    }
}
