//Cyberpunk 2077 Browser Extension Framework
//by r457 & gh057

module BrowserExtension.Classes
import BrowserExtension.DataStructures.*
import BrowserExtension.System.*

public class BrowserEventsListener extends IScriptable {
	protected let m_deviceLogicController: wref<BrowserGameController>;
	protected let m_deviceObject: wref<GameObject>;
	protected let m_siteData: CustomInternetSite;
	
	public func Init(logic: ref<BrowserGameController>) {
		let system: wref<BrowserExtensionSystem>;
		
		this.m_deviceLogicController = logic;
		this.m_deviceObject = this.m_deviceLogicController.GetOwnerEntity() as GameObject;
		system = BrowserExtensionSystem.GetInstance(this.m_deviceObject);
		system.Register(this);
		
		this.m_siteData.address = s"NETdir://none";
		this.m_siteData.shortName = s"NONE";
		this.m_siteData.iconAtlasPath = r"base\\gameplay\\gui\\world\\internet\\templates\\atlases\\icons_atlas.inkatlas";
		this.m_siteData.iconTexturePart = n"zetatech1";
	}
	
	public func Uninit() {
		let system: wref<BrowserExtensionSystem>;
		
		system = BrowserExtensionSystem.GetInstance(this.m_deviceObject);
		system.Unregister(this);
		this.m_deviceObject = null;
		this.m_deviceLogicController = null;
	}
	
	public final func GetSiteData() -> CustomInternetSite {
		return this.m_siteData;
	}
	
	public final func GetSiteAddress() -> String {
		return this.m_siteData.address;
	}
	
	public final func GetDevice() -> wref<GameObject> {
		return this.m_deviceObject;
	}
	
	public func GetWebPage(address: String) -> ref<inkCompoundWidget> {
		let canvas = new inkCanvas();
		return canvas;
	}
}
