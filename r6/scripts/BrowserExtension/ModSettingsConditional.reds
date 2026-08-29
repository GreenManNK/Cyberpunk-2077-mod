import BrowserExtensionModSettings.*

@if(ModuleExists("ModSettingsModule"))
public func RegisterBrowserExModSettingsListener(config: ref<BrowserExtensionConfig>) -> Bool {
	//LogChannel(n"DEBUG", s"Browser Extension Mod Settings listener registered");
	ModSettings.RegisterListenerToClass(config);
	return true;
}

@if(!ModuleExists("ModSettingsModule"))
public func RegisterBrowserExModSettingsListener(config: ref<BrowserExtensionConfig>) -> Bool {
	//LogChannel(n"DEBUG", s"Browser Extension: missing Mod Settings plugin");
	return false;
}
