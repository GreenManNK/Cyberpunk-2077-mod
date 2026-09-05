module NightCityAllies.Web.Hooks

import NightCityAllies.*
import NightCityAllies.Web.*
import NightCityAllies.Localization.*

@if(ModuleExists("BrowserExtension.System"))
import BrowserExtension.DataStructures.*
@if(ModuleExists("BrowserExtension.System"))
import BrowserExtension.Classes.*

@if(ModuleExists("BrowserExtension.System"))
public class NCAWebsiteListener extends BrowserEventsListener {
    public func Init(logic: ref<BrowserGameController>) {
        super.Init(logic);

        this.m_siteData.address = NCAWebsite.Address();
        this.m_siteData.shortName = NCA.Labels().Night_city_allies();
        this.m_siteData.iconAtlasPath = NCAWebsite.IconAtlas();
        this.m_siteData.iconTexturePart = NCAWebsite.IconPart();
    }

    public func GetWebPage(address: String) -> ref<inkCompoundWidget> {
        return this.m_deviceLogicController.SpawnFromExternal(
            this.m_deviceLogicController.GetRootCompoundWidget(),
            NCAWebsite.WidgetPath(),
            NCAWebsite.WidgetItem()
        ) as inkCompoundWidget;
    }
}

@if(ModuleExists("BrowserExtension.System"))
@addField(BrowserGameController)
private let m_ncaWebsiteListener: ref<NCAWebsiteListener>;

@if(ModuleExists("BrowserExtension.System"))
@wrapMethod(BrowserGameController)
protected cb func OnInitialize() -> Bool {
    wrappedMethod();

    if NCAConstants.Dev() {
        this.m_ncaWebsiteListener = new NCAWebsiteListener();
        this.m_ncaWebsiteListener.Init(this);
    }
}

@if(ModuleExists("BrowserExtension.System"))
@wrapMethod(BrowserGameController)
protected cb func OnUninitialize() -> Bool {
    wrappedMethod();

    if IsDefined(this.m_ncaWebsiteListener) {
        this.m_ncaWebsiteListener.Uninit();
        this.m_ncaWebsiteListener = null;
    }
}
