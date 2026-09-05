module NightCityAllies.Web

import NightCityAllies.*
import NightCityAllies.Localization.*
import NightCityAllies.Persistence.*
import NightCityAllies.Metadata.*

public final class NCAWebsite {
    public static func Address() -> String = "NETdir://nightcityallies.web";
    public static func TabName() -> String = "ncaWebsite";
    public static func WidgetPath() -> ResRef = r"nca\\gameplay\\gui\\widgets\\website.inkwidget";
    public static func WidgetItem() -> CName = n"Root";
    public static func CharacterRowItem() -> CName = n"CharacterRow";
    public static func IconAtlas() -> ResRef = r"nca\\icons\\nca_icons.inkatlas";
    public static func IconPart() -> CName = n"banner2";

    // One per character row, so it reads the collected metadata rather than walking to the
    // affiliation record every time the list is drawn.
    public static func FactionIconPart(recordID: TweakDBID) -> CName {
        return NCA.Metadata().Get(recordID).affiliationIcon;
    }
}

public enum NCAWebsitePage {
    Database = 0,
    Missions = 1
}

public class NCAWebsiteController extends inkLogicController {
    private let m_navDatabase: wref<inkText>;
    private let m_navMissions: wref<inkText>;
    private let m_databasePage: wref<inkWidget>;
    private let m_databaseRows: wref<inkCompoundWidget>;
    private let m_missionsPage: wref<inkWidget>;

    private static func GetInactiveNavOpacity() -> Float = 0.4;

    protected cb func OnInitialize() -> Bool {
        this.m_navDatabase = this.GetChildWidgetByPath(n"Content/Header/NavDatabase") as inkText;
        this.m_navMissions = this.GetChildWidgetByPath(n"Content/Header/NavMissions") as inkText;
        this.m_databasePage = this.GetChildWidgetByPath(n"Content/Database");
        this.m_databaseRows = this.GetChildWidgetByPath(n"Content/Database/scroll/scrollArea/tracks") as inkCompoundWidget;
        this.m_missionsPage = this.GetChildWidgetByPath(n"Content/Missions");

        this.BindNav(this.m_navDatabase, n"OnDatabaseClicked");
        this.BindNav(this.m_navMissions, n"OnMissionsClicked");

        this.RefreshDatabase();
        this.ShowPage(NCAWebsitePage.Database);
    }

    protected cb func OnUninitialize() -> Bool {
        this.UnbindNav(this.m_navDatabase, n"OnDatabaseClicked");
        this.UnbindNav(this.m_navMissions, n"OnMissionsClicked");
    }

    protected cb func OnDatabaseClicked(evt: ref<inkPointerEvent>) -> Bool {
        if evt.IsAction(n"click") {
            this.ShowPage(NCAWebsitePage.Database);
        }
    }

    protected cb func OnMissionsClicked(evt: ref<inkPointerEvent>) -> Bool {
        if evt.IsAction(n"click") {
            this.ShowPage(NCAWebsitePage.Missions);
        }
    }

    private func ShowPage(page: NCAWebsitePage) -> Void {
        let onDatabase: Bool = Equals(page, NCAWebsitePage.Database);

        this.SetPageVisible(this.m_databasePage, onDatabase);
        this.SetPageVisible(this.m_missionsPage, !onDatabase);

        this.SetNavActive(this.m_navDatabase, onDatabase);
        this.SetNavActive(this.m_navMissions, !onDatabase);
    }

    private func RefreshDatabase() -> Void {
        if !IsDefined(this.m_databaseRows) {
            return;
        }

        this.m_databaseRows.RemoveAllChildren();

        let companions: array<CompanionModData> = NCA.Persistence().GetCompanions();
        let i: Int32 = 0;
        while i < ArraySize(companions) {
            this.AddCharacterRow(companions[i]);
            i += 1;
        }
    }

    private func AddCharacterRow(companion: CompanionModData) -> Void {
        let row = this.SpawnFromExternal(this.m_databaseRows, NCAWebsite.WidgetPath(), NCAWebsite.CharacterRowItem()) as inkCompoundWidget;
        if !IsDefined(row) {
            return;
        }

        let nameText = row.GetWidgetByPathName(n"Name") as inkText;
        if IsDefined(nameText) {
            nameText.SetText(companion.name);
        }

        this.SetFactionIcon(row.GetWidgetByPathName(n"Icon") as inkImage, companion.recordID);
    }

    private func SetFactionIcon(icon: wref<inkImage>, recordID: TweakDBID) -> Void {
        if !IsDefined(icon) {
            return;
        }

        let part: CName = NCAWebsite.FactionIconPart(recordID);
        icon.SetVisible(IsNameValid(part));

        if IsNameValid(part) {
            icon.SetTexturePart(part);
        }
    }

    private func SetPageVisible(page: wref<inkWidget>, isVisible: Bool) -> Void {
        if IsDefined(page) {
            page.SetVisible(isVisible);
        }
    }

    private func SetNavActive(nav: wref<inkText>, isActive: Bool) -> Void {
        if !IsDefined(nav) {
            return;
        }

        if isActive {
            nav.SetOpacity(1.0);
        } else {
            nav.SetOpacity(NCAWebsiteController.GetInactiveNavOpacity());
        }
    }

    private func BindNav(nav: wref<inkText>, callback: CName) -> Void {
        if !IsDefined(nav) {
            return;
        }

        nav.SetInteractive(true);
        nav.RegisterToCallback(n"OnRelease", this, callback);
    }

    private func UnbindNav(nav: wref<inkText>, callback: CName) -> Void {
        if IsDefined(nav) {
            nav.UnregisterFromCallback(n"OnRelease", this, callback);
        }
    }
}
