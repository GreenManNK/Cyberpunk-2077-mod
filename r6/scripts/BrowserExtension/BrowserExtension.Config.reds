module BrowserExtensionModSettings

public class BrowserExtensionConfig {
	@runtimeProperty("ModSettings.mod", "Browser Extension")
	@runtimeProperty("ModSettings.displayName", "Enabled")
	@runtimeProperty("ModSettings.description", "Enable/disable the extension")
	public let enabled: Bool = true;
	
	@runtimeProperty("ModSettings.mod", "Browser Extension")
	@runtimeProperty("ModSettings.displayName", "Show additional sites")
	@runtimeProperty("ModSettings.description", "Show all the valid sites defined in the journal")
	public let showAdditional: Bool = true;
	
	@runtimeProperty("ModSettings.mod", "Browser Extension")
	@runtimeProperty("ModSettings.displayName", "AutoFixer and EZEstates on top")
	@runtimeProperty("ModSettings.description", "Push AutoFixer and EZEstates on top of the list of vanilla sites")
	public let pushAutoNEz: Bool = true;
}
