module NightCityAllies.Web.Hooks

import NightCityAllies.*
import NightCityAllies.Web.*
import NightCityAllies.Localization.*

@if(!ModuleExists("BrowserExtension.System"))
public class NCAWebsiteRequestEvent extends Event {
    public let show: Bool;

    public static func Create(show: Bool) -> ref<NCAWebsiteRequestEvent> {
        let evt: ref<NCAWebsiteRequestEvent> = new NCAWebsiteRequestEvent();
        evt.show = show;
        return evt;
    }
}

@if(!ModuleExists("BrowserExtension.System"))
@wrapMethod(ComputerControllerPS)
public final func GetMenuButtonWidgets() -> array<SComputerMenuButtonWidgetPackage> {
    let packages: array<SComputerMenuButtonWidgetPackage> = wrappedMethod();

    if !NCAConstants.Dev() || ArraySize(packages) == 0 || !this.IsMenuEnabled(EComputerMenuType.INTERNET) {
        return packages;
    }

    let package: SComputerMenuButtonWidgetPackage;
    package.widgetName = NCAWebsite.TabName();
    package.displayName = NCA.Labels().Night_city_allies();
    package.ownerID = this.GetID();
    package.iconID = n"iconInternet";
    package.widgetTweakDBID = this.GetMenuButtonWidgetTweakDBID();
    package.isValid = true;
    SWidgetPackageBase.ResolveWidgetTweakDBData(package.widgetTweakDBID, package.libraryID, package.libraryPath);
    ArrayPush(packages, package);

    return packages;
}

@if(!ModuleExists("BrowserExtension.System"))
@wrapMethod(ComputerInkGameController)
private final func ShowMenuByName(elementName: String) -> Void {
    wrappedMethod(elementName);

    if NotEquals(elementName, NCAWebsite.TabName()) {
        return;
    }

    this.QueueEvent(NCAWebsiteRequestEvent.Create(true));
    this.ShowInternet();
    this.GetMainLayoutController().MarkManuButtonAsSelected(elementName);
}

@if(!ModuleExists("BrowserExtension.System"))
@wrapMethod(ComputerInkGameController)
private final func HideMenuByName(elementName: String) -> Void {
    wrappedMethod(elementName);

    if Equals(elementName, NCAWebsite.TabName()) {
        this.GetMainLayoutController().HideInternet();
    }
}

@if(!ModuleExists("BrowserExtension.System"))
@addField(BrowserController)
private let m_ncaWebsitePending: Bool;

@if(!ModuleExists("BrowserExtension.System"))
@addMethod(BrowserController)
protected cb func OnNCAWebsiteRequestEvent(evt: ref<NCAWebsiteRequestEvent>) -> Bool {
    this.m_ncaWebsitePending = evt.show;
}

@if(!ModuleExists("BrowserExtension.System"))
@wrapMethod(BrowserController)
protected cb func OnPageSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
    wrappedMethod(widget, userData);

    if this.m_ncaWebsitePending {
        this.m_ncaWebsitePending = false;
        this.ShowNCAWebsitePage();
    }
}

@if(!ModuleExists("BrowserExtension.System"))
@addMethod(BrowserController)
private func ShowNCAWebsitePage() -> Void {
    let page: ref<WebPage> = this.m_currentPage.GetController() as WebPage;
    if !IsDefined(page) {
        return;
    }

    inkTextRef.SetText(this.m_addressText, NCAWebsite.Address());
    page.PopulateNCAWebsite();
}

@if(!ModuleExists("BrowserExtension.System"))
@addMethod(WebPage)
public func PopulateNCAWebsite() -> Void {
    let root: ref<inkCompoundWidget> = this.GetChildWidgetByPath(n"page/linkPanel/panel") as inkCompoundWidget;
    if !IsDefined(root) {
        root = this.GetChildWidgetByPath(n"Page/linkPanel/panel") as inkCompoundWidget;
    }

    if !IsDefined(root) {
        return;
    }

    root.RemoveAllChildren();
    this.SpawnFromExternal(root, NCAWebsite.WidgetPath(), NCAWebsite.WidgetItem());
}
