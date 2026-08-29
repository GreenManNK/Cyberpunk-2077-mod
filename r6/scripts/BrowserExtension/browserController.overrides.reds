//Cyberpunk 2077 Browser Extension Framework
//by r457 & gh057

/*

"NETdir://ncity.pub" address is considered a home page
the game uses home_page_recent inkwidget with 10 pre-defined slots for it
BrowserExtension can show much more than 10 sites by imitating PgUp/PgDwn
behavior with UI_MoveDown/UI_MoveUp actions (usually mouse scroll)
this can be redone in the future to use proper scroll widget

Vanilla sites are added last, so you can override existing address with yours

Public BrowserGameController interface you can use for your sites:

public final func LoadPageByAddress(address: String) -> Void
main function to show your site pages/vanilla sites/homepage

public func LoadHomePage() -> Void
a function do directly call for "NETdir://ncity.pub" page

public func RefreshHomePage() -> Void
a function to force home page refresh, will do nothing if not on the home page

public func IsHomePage() -> Bool
returns true if the device is currently showing "NETdir://ncity.pub" page

public final func GetCustomSites() -> array<CustomInternetSite>
builds an array of all the current custom internet sites for the current device

public final func GetBlockedSites() -> array<String>
builds an array of all the blocked sites (site address list)

*/

import BrowserExtension.DataStructures.*
import BrowserExtension.Classes.*
import BrowserExtension.System.*
import HomePagePagination.*
import BrowserExtensionModSettings.*

@addMethod(BrowserGameController)
public final func LoadPageByAddress(address: String) -> Void {
    let logicScript = inkWidgetRef.GetController(this.m_logicControllerRef) as BrowserController;
	if IsDefined(logicScript) {
		logicScript.LoadPageByAddress(address);
	};
}

@addMethod(BrowserGameController)
public func LoadHomePage() -> Void {
	this.LoadPageByAddress(s"NETdir://ncity.pub");
}

@addMethod(BrowserGameController)
public func RefreshHomePage() -> Void {
	let logicScript = inkWidgetRef.GetController(this.m_logicControllerRef) as BrowserController;
	if IsDefined(logicScript) {
		if logicScript.IsHomePage() {
			logicScript.RefreshHomePage();
		};
	};
}

@addMethod(BrowserGameController)
public func IsHomePage() -> Bool {
    let logicScript = inkWidgetRef.GetController(this.m_logicControllerRef) as BrowserController;
	if IsDefined(logicScript) {
		return logicScript.IsHomePage();
	};
	return false;
}

@addMethod(BrowserGameController)
public final func GetCustomSites() -> array<CustomInternetSite> {
	let customSites: array<CustomInternetSite>;
	let system = BrowserExtensionSystem.GetInstance(this.GetOwnerEntity() as GameObject);
	if IsDefined(system) {
		customSites = system.GetSitesData(this.GetOwnerEntity() as GameObject);
	};
	return customSites;
}

@addMethod(BrowserGameController)
public final func GetBlockedSites() -> array<String> {
	let blockedSites: array<String>;
	let system = BrowserExtensionSystem.GetInstance(this.GetOwnerEntity() as GameObject);
	if IsDefined(system) {
		blockedSites = system.GetBlockedSites();
	};
	return blockedSites;
}

@addField(BrowserGameController)
private let m_customBrowserInputListener: ref<CustomBrowserInputListener>;

@wrapMethod(BrowserGameController)
protected cb func OnInitialize() -> Bool {
    let ret: Bool = wrappedMethod();
    this.m_customBrowserInputListener = new CustomBrowserInputListener();
	this.m_customBrowserInputListener.Init(this);
	this.GetPlayerControlledObject().RegisterInputListener(this.m_customBrowserInputListener);
	return ret;
}

@wrapMethod(BrowserGameController)
protected cb func OnUninitialize() -> Bool {
    let ret: Bool = wrappedMethod();
	this.GetPlayerControlledObject().UnregisterInputListener(this.m_customBrowserInputListener);
	return ret;
}

@addMethod(BrowserGameController)
public func GetHomePagePageNumber() -> Int32 {
	return this.m_customBrowserInputListener.m_pageNumber;
}

@addMethod(BrowserGameController)
public func SetHomePagePageNumber(num: Int32) -> Void {
	this.m_customBrowserInputListener.m_pageNumber = num;
}

@addMethod(BrowserGameController)
public func IncHomePagePageNumber(num: Int32) -> Void {
	this.m_customBrowserInputListener.m_pageNumber += num;
}

@addMethod(BrowserGameController)
public func HomePageScrollDown() -> Int32 {
	let logicScript = inkWidgetRef.GetController(this.m_logicControllerRef) as BrowserController;
	if IsDefined(logicScript) {
		if logicScript.IsHomePage() {
			return logicScript.HomePageScroll(1);
		};
	};
	return 0;
}

@addMethod(BrowserGameController)
public func HomePageScrollUp() -> Int32 {
	let logicScript = inkWidgetRef.GetController(this.m_logicControllerRef) as BrowserController;
	if IsDefined(logicScript) {
		if logicScript.IsHomePage() {
			return logicScript.HomePageScroll(-1);
		};
	};
	return 0;
}

@addMethod(BrowserController)
public final func LoadPageByAddress(address: String) -> Void {
	this.LoadWebPage(address);
}

@addMethod(BrowserController)
public func IsHomePage() -> Bool {
	let system = BrowserExtensionSystem.GetInstance(this.m_gameController.GetOwnerEntity() as GameObject);
	if system.ShouldBypassBrowserExtension() {
		return false;
	};
	return Equals(this.m_currentRequestedAddress, s"NETdir://ncity.pub");
}

@addMethod(BrowserController)
public func RefreshHomePage() -> Void {
	if this.IsHomePage() {
		let currentController = this.m_currentPage.GetController() as WebPage;
		if IsDefined(currentController) {
			currentController.FillCustomHomePage(this.m_currentRequestedPage, this.m_gameController);
		};
	};
}

@addMethod(BrowserController)
public func HomePageScroll(inc: Int32) -> Int32 {
	if this.IsHomePage() {
		let currentController = this.m_currentPage.GetController() as WebPage;
		if IsDefined(currentController) {
			this.m_gameController.IncHomePagePageNumber(inc);
			return currentController.FillCustomHomePage(this.m_currentRequestedPage, this.m_gameController);
		};
	};
	return 0;
}

@wrapMethod(BrowserController)
protected cb func OnPageSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Bool {
	let device = this.m_gameController.GetOwnerEntity() as GameObject;
	let system = BrowserExtensionSystem.GetInstance(device);
	
	if !system.IsEnabled() || !this.IsHomePage() {
		return wrappedMethod(widget, userData);
	} else {
		this.OnHomePageSpawned(widget, userData);
	};
}

@addMethod(BrowserController)
protected func OnHomePageSpawned(widget: ref<inkWidget>, userData: ref<IScriptable>) -> Void {
	let currentController: ref<WebPage>;
	let scale: Vector2;
	this.m_currentPage = widget as inkCompoundWidget;
	this.m_currentPage.SetAnchor(inkEAnchor.Fill);
	scale.X = this.m_currentRequestedPage.GetScale();
	scale.Y = this.m_currentRequestedPage.GetScale();
	this.m_currentPage.SetScale(scale);
	currentController = this.m_currentPage.GetController() as WebPage;
	if IsDefined(currentController) {
		//fill custom home page: custom sites + vanilla sites
		this.m_gameController.SetHomePagePageNumber(currentController.FillCustomHomePage(this.m_currentRequestedPage, this.m_gameController));
		currentController.RegisterToCallback(n"OnLinkPressed", this, n"OnProcessLinkPressed");
	};
	this.SetFacts(this.m_currentRequestedPage);
	inkWidgetRef.SetVisible(this.m_spinnerContentRoot, false);
	this.m_webPageSpawnRequest = null;
}

@addField(BrowserController)
private let m_currentRequestedAddress: String;

@wrapMethod(BrowserController)
private final func LoadWebPage(const address: script_ref<String>) -> Void {
	let device = this.m_gameController.GetOwnerEntity() as GameObject;
	let system = BrowserExtensionSystem.GetInstance(device);
	
	if !system.IsEnabled() {
		wrappedMethod(address);
	} else {
		this.m_currentRequestedAddress = "" + address;
		if !this.TryLoadCustomWebPage(this.m_currentRequestedAddress) {
			wrappedMethod(address);
		};
	};
}

@addMethod(BrowserController)
private func TryLoadCustomWebPage(address: String) -> Bool {
	let device = this.m_gameController.GetOwnerEntity() as GameObject;
	let system = BrowserExtensionSystem.GetInstance(device);
	if IsDefined(system) {
		let widget = system.GetWebPage(address, device);
		if IsDefined(widget) {
			if this.m_webPageSpawnRequest != null {
				this.m_webPageSpawnRequest.Cancel();
			};
			this.UnloadCurrentWebsite();
			inkTextRef.SetText(this.m_addressText, this.m_currentRequestedAddress);
			//let contentWidget = this.GetRootCompoundWidget().GetWidget(n"page_content") as inkCompoundWidget;
			//(inkWidgetRef.Get(this.m_pageContentRoot) as inkCompoundWidget).AddChildWidget(widget);
			widget.Reparent(inkWidgetRef.Get(this.m_pageContentRoot) as inkCompoundWidget);
			this.m_currentPage = widget;
			this.m_currentPage.SetAnchor(inkEAnchor.Fill);
			this.m_webPageSpawnRequest = null;
			this.m_currentRequestedPage = null;
			inkWidgetRef.SetVisible(this.m_spinnerContentRoot, false);
			return true;
		};
	};
	return false;
}

@addField(WebPage)
public let m_homePagePgNumber: Int32 = 0;

@addMethod(WebPage)
public final func FillCustomHomePage(requestedPage: wref<JournalInternetPage>, gameController: wref<BrowserGameController>) -> Int32 {
	//NETdir://ncity.pub is the default Internet homepage
	//it uses home_page_recent inkWidget with 2x5 <ImageLinkXX, TextLinkXX> pairs
	//prob need to redo it to use an actual scrollable page widget, but not now
	//right now scrolling is imitated with offset into array of site links
	
	let pgNum: Int32 = gameController.GetHomePagePageNumber();
	let journalManager: ref<JournalManager> = gameController.GetJournalManager();
	let blockedSites: array<String> = gameController.GetBlockedSites();
	let config: ref<BrowserExtensionConfig> = BrowserExtensionSystem.GetInstance(gameController.GetOwnerEntity() as GameObject).GetConfig();
	
	let customSites: array<CustomInternetSite>;
    
	let requestedPageTexts: array< ref<JournalInternetText> >;
	let requestedPageImages: array< ref<JournalInternetImage> >;
	let requestedPageLogo: CustomInternetSite;
	
    let context: JournalRequestContext;
    let entries: array<wref<JournalEntry>>;
    let pageEntry: wref<JournalInternetPage>;
    let siteEntry: wref<JournalInternetSite>;
	
    let i: Int32;
	let slotNumber: Int32 = 1;
	
    let MAX_ICONS_COUNT: Int32 = 10;
	let ICONS_PER_PAGE: Int32 = 10;
	
    let journalSites: array<CustomInternetSite>;
	
	let validSites: array<CustomInternetSite>;
    let customSiteEntry: CustomInternetSite;
	
	let validAddrHash: ref<inkStringMap>;
	
	validAddrHash = new inkStringMap();
	
	//fill the page with custom sites
	customSites = gameController.GetCustomSites();
	for customSiteEntry in customSites {
		if !validAddrHash.KeyExist(customSiteEntry.address) {
			validAddrHash.Insert(customSiteEntry.address, 1u);
			ArrayPush(validSites, customSiteEntry);
		};
	};
	
	//push AutoFixer and EZEstates on top of the list of vanilla sites (if enabled in settings)
	if config != null && config.pushAutoNEz {
		customSiteEntry.address = s"NETdir://reyescars.web/vehicles/1";
		if !validAddrHash.KeyExist(customSiteEntry.address) && !ArrayContains(blockedSites, customSiteEntry.address) {
			customSiteEntry.shortName = s"AutoFixer";
			customSiteEntry.iconAtlasPath = r"base\\gameplay\\gui\\world\\internet\\templates\\atlases\\icons_atlas.inkatlas";
			customSiteEntry.iconTexturePart = n"auto_fixer";
			validAddrHash.Insert(customSiteEntry.address, 1u);
			ArrayPush(validSites, customSiteEntry);
		};
		
		customSiteEntry.address = s"NETdir://ezestates.web/for_rent";
		if !validAddrHash.KeyExist(customSiteEntry.address) && !ArrayContains(blockedSites, customSiteEntry.address) {
			customSiteEntry.shortName = s"EZEstates";
			customSiteEntry.iconAtlasPath = r"base\\gameplay\\gui\\world\\internet\\templates\\atlases\\icons_atlas.inkatlas";
			customSiteEntry.iconTexturePart = n"EZestate";
			validAddrHash.Insert(customSiteEntry.address, 1u);
			ArrayPush(validSites, customSiteEntry);
		};
	};
	
	//add vanilla sites from the current requested homepage journal entry
	if requestedPage != null {
		ArrayResize(journalSites, 10); //there can be 10 vanilla sites defined for the homepage
		requestedPageTexts = requestedPage.GetTexts();
		requestedPageImages = requestedPage.GetImages();
		//process images: ImageLink01 to ImageLink10
		i = 0;
		while i < ArraySize(requestedPageImages) {
			let imageID = NameToString(requestedPageImages[i].GetName());
			if Equals(imageID, s"NetLogo") { //current subnet logo is also defined in that same array
				requestedPageLogo.iconAtlasPath = requestedPageImages[i].GetAtlasPath();
				requestedPageLogo.iconTexturePart = requestedPageImages[i].GetTexturePart();
			};
			let idx = -1;
			if (StrBeginsWith(imageID, s"ImageLink")) {
				idx = StringToInt(StrAfterFirst(imageID, s"ImageLink"), -1) - 1;
			};
			if idx >= 0 && idx < 10 {
				journalSites[idx].address = requestedPageTexts[i].GetLinkAddress();
				journalSites[idx].iconAtlasPath = requestedPageImages[i].GetAtlasPath();
				journalSites[idx].iconTexturePart = requestedPageImages[i].GetTexturePart();
			};
			i += 1;
		};
		//process texts: TextLink01 to TextLink10
		i = 0;
		while i < ArraySize(requestedPageTexts) {
			let textID = NameToString(requestedPageTexts[i].GetName());
			if Equals(textID, s"INTRANET") { //current subnet name is also defined in that same array
				requestedPageLogo.shortName = requestedPageTexts[i].GetText();
			};
			let idx = -1;
			if (StrBeginsWith(textID, s"TextLink")) {
				idx = StringToInt(StrAfterFirst(textID, s"TextLink"), -1) - 1;
			};
			if idx >= 0 && idx < 10 {
				if Equals(journalSites[idx].address, s"") {
					journalSites[idx].address = requestedPageTexts[i].GetLinkAddress();
				};
				journalSites[idx].shortName = requestedPageTexts[i].GetText();
			};
			i += 1;
		};
		//push found vanilla sites to the array
		i = 0;
		while i < 10 {
			if !Equals(journalSites[i].address, s"") && !validAddrHash.KeyExist(journalSites[i].address) && !ArrayContains(blockedSites, customSiteEntry.address) {
				validAddrHash.Insert(journalSites[i].address, 1u);
				ArrayPush(validSites, journalSites[i]);
			};
			i += 1;
		};
		//set current subnetwork logo and text
		let root = this.GetRootCompoundWidget() as inkCompoundWidget;
		if ResRef.IsValid(requestedPageLogo.iconAtlasPath) && !Equals(requestedPageLogo.iconTexturePart, n"None") {
			let logoImage = root.GetWidget(n"page/linkPanel/panel/network/text/NetLogo") as inkImage;
			logoImage.SetAtlasResource(requestedPageLogo.iconAtlasPath);
			logoImage.SetTexturePart(requestedPageLogo.iconTexturePart);
		};
		if !Equals(requestedPageLogo.shortName, s"") {
			let logoText = root.GetWidget(n"page/linkPanel/panel/network/text/INTRANET") as inkText;
			logoText.SetText(requestedPageLogo.shortName);
		};
	};
	
	//get all the sites defined in journal
	if config != null && config.showAdditional {
		context.stateFilter.active = true;
		journalManager.GetInternetSites(context, entries);
		i = 0;
		while i < ArraySize(entries) {
			siteEntry = entries[i] as JournalInternetSite;
			if IsDefined(siteEntry) {
				pageEntry = journalManager.GetMainInternetPage(siteEntry);
				if IsDefined(pageEntry) && !siteEntry.IsIgnoredAtDesktop() {
					customSiteEntry.address = pageEntry.GetAddress();
					if !validAddrHash.KeyExist(customSiteEntry.address) && !ArrayContains(blockedSites, customSiteEntry.address) {
						customSiteEntry.shortName = siteEntry.GetShortName();
						//fix missing DLC site names (CDPR decided not to respect their website journal entries data format for this one)
						if Equals(customSiteEntry.address, s"NETdir://fr34ks33k.web/") {
							customSiteEntry.shortName = s"fr34ks33k";
						};
						if Equals(customSiteEntry.address, s"NETdir://trufans.web/linamalina") {
							customSiteEntry.shortName = s"Lina Malina";
						};
						if Equals(customSiteEntry.address, s"NETdir://havenclinic.web") {
							customSiteEntry.shortName = s"Haven Clinic";
						};
						if Equals(customSiteEntry.address, s"NETdir://kurtzmilitia.web") {
							customSiteEntry.shortName = s"LocKey#93716";
						};
						if Equals(customSiteEntry.address, s"NETdir://goodolddogtown.web/") {
							customSiteEntry.shortName = s"Good Old Dogtown";
						};
						if Equals(customSiteEntry.address, s"NETdir://growlfm.web/aboutme") {
							customSiteEntry.shortName = s"LocKey#93842";
						};
						//do not display long names that break page layout
						if StrLen(GetLocalizedText(customSiteEntry.shortName)) > 40 {
							customSiteEntry.shortName = s"";
						};
						customSiteEntry.iconAtlasPath = siteEntry.GetAtlasPath();
						customSiteEntry.iconTexturePart = siteEntry.GetTexturePart();
						//fix missing goodolddogtown site icon
						if Equals(customSiteEntry.address, s"NETdir://goodolddogtown.web/") {
							customSiteEntry.iconTexturePart = n"freak_seek_icon";
						};
						//fix missing charonexotics site icon
						if Equals(customSiteEntry.address, s"NETdir://charonexotics.web/") {
							customSiteEntry.iconTexturePart = n"charon_exotics";
						};
						//fix AutoFixer name and icon
						if Equals(customSiteEntry.address, s"NETdir://reyescars.web/vehicles/1") {
							customSiteEntry.shortName = s"AutoFixer";
							customSiteEntry.iconAtlasPath = r"base\\gameplay\\gui\\world\\internet\\templates\\atlases\\icons_atlas.inkatlas";
							customSiteEntry.iconTexturePart = n"auto_fixer";
						};
						//fix EZEstates name
						if Equals(customSiteEntry.address, s"NETdir://ezestates.web/for_rent") {
							customSiteEntry.shortName = s"EZEstates";
						};
						//make sure not to add sites with missing icons
						if ResRef.IsValid(customSiteEntry.iconAtlasPath) && !Equals(customSiteEntry.iconTexturePart, n"None") {
							validAddrHash.Insert(customSiteEntry.address, 1u);
							ArrayPush(validSites, customSiteEntry);
						};
					};
				};
			};
			i += 1;
		};
	};
	
	let maxPgNum = Max(0, CeilF(Cast<Float>(ArraySize(validSites)) / Cast<Float>(ICONS_PER_PAGE)) - 1);
	this.m_homePagePgNumber = Clamp(pgNum, 0, maxPgNum);
	
	//cleanup
    slotNumber = 1;
	while slotNumber <= MAX_ICONS_COUNT {
		this.ClearSlot(slotNumber);
		slotNumber += 1;
	};
	
	//show current page
	i = this.m_homePagePgNumber * ICONS_PER_PAGE;
    slotNumber = 1;
	while slotNumber <= MAX_ICONS_COUNT && i < ArraySize(validSites) {
		//LogChannel(n"DEBUG", validSites[i].address);
		this.SetSlot(slotNumber, validSites[i].shortName, validSites[i].address, validSites[i].iconAtlasPath, validSites[i].iconTexturePart);
		i += 1;
		slotNumber += 1;
	};
	
	//add page numbering
	let root = this.GetRootCompoundWidget() as inkCompoundWidget;
	let canvas = new inkCanvas();
    canvas.SetName(n"homepageNum");
    canvas.SetAnchor(inkEAnchor.BottomRight);
    canvas.SetAnchorPoint(new Vector2(1.0, 1.0));
	canvas.SetFitToContent(true);
	root.RemoveChildByName(n"homepageNum");
	canvas.Reparent(root);
	let pgnum = new inkText();
	pgnum.SetText(ToString(this.m_homePagePgNumber + 1) + "/" + ToString(maxPgNum + 1));
	pgnum.SetFontFamily("base\\gameplay\\gui\\fonts\\raj\\raj.inkfontfamily");
	pgnum.SetFontStyle(n"Regular");
	pgnum.SetFontSize(60);
	pgnum.SetTintColor(new HDRColor(0.3686, 0.9647, 1.1888, 1.0));
	pgnum.SetAnchor(inkEAnchor.BottomRight);
	pgnum.SetAnchorPoint(1.0, 1.0);
	pgnum.SetMargin(new inkMargin(0.0, 0.0, 100.0, 50.0));
	pgnum.Reparent(canvas);
	
	return this.m_homePagePgNumber;
}
