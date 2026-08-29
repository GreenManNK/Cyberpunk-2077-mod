//Cyberpunk 2077 Browser Extension Framework
//by r457 & gh057

module BrowserExtension.System
import BrowserExtension.DataStructures.*
import BrowserExtension.Classes.*
import BrowserExtensionModSettings.*

public class BrowserExtensionSystem extends ScriptableSystem {
	private let m_config: ref<BrowserExtensionConfig>;
	private let m_listeners: array<wref<BrowserEventsListener>>;
	private let m_blockedAddress: array<String>;
	
	public static func GetInstance(obj: ref<GameObject>) -> ref<BrowserExtensionSystem> {
		let gi: GameInstance = obj.GetGame();
		let system: ref<BrowserExtensionSystem> = GameInstance.GetScriptableSystemsContainer(gi).Get(n"BrowserExtension.System.BrowserExtensionSystem") as BrowserExtensionSystem;
		return system;
	}
	
	public func Register(listener: ref<BrowserEventsListener>) {
		if IsDefined(listener) {
			ArrayPush(this.m_listeners, listener);
		};
	}
	
	public func Unregister(listener: ref<BrowserEventsListener>) {
		if IsDefined(listener) {
			if ArrayContains(this.m_listeners, listener) {
				ArrayRemove(this.m_listeners, listener);
			};
		};
	}
	
	public func BlockAddress(addr: String) {
		if !ArrayContains(this.m_blockedAddress, addr) {
			ArrayPush(this.m_blockedAddress, addr);
		};
	}
	
	public func UnblockAddress(addr: String) {
		if ArrayContains(this.m_blockedAddress, addr) {
			ArrayRemove(this.m_blockedAddress, addr);
		};
	}
	
	public func IsAddressBlocked(addr: String) -> Bool {
		return ArrayContains(this.m_blockedAddress, addr);
	}
	
	public func GetBlockedSites() -> array<String> {
		return this.m_blockedAddress;
	}
	
	public func GetSitesData(device: wref<GameObject>) -> array<CustomInternetSite> {
		let siteData: CustomInternetSite;
		let sitesData: array<CustomInternetSite>;
		
		for listener in this.m_listeners {
			if IsDefined(listener) && Equals(listener.GetDevice(), device) {
				siteData = listener.GetSiteData();
				if !ArrayContains(this.m_blockedAddress, siteData.address) {
					ArrayPush(sitesData, siteData);
				};
			};
		};
		
		return sitesData;
	}
	
	public func GetWebPage(address: String, device: wref<GameObject>) -> ref<inkCompoundWidget> {
		for listener in this.m_listeners {
			if IsDefined(listener) && Equals(listener.GetDevice(), device) && StrBeginsWith(address, listener.GetSiteAddress()) {
				return listener.GetWebPage(address);
			};
		};
		
		return null;
	}
	
	public func ShouldBypassBrowserExtension() -> Bool {
		return !this.GetConfig().enabled || this.IsCorpoStartActive() || this.IsEP1EpilogueActive();
	}
	
	public func IsCorpoStartActive() -> Bool {
		let journal: wref<JournalManager> = GameInstance.GetJournalManager(this.GetGameInstance());
		let corpoStartQuest: wref<JournalQuest> = journal.GetEntryByString(s"quests/main_quest/prologue/q000_corpo", "gameJournalQuest") as JournalQuest;
		let state: gameJournalEntryState = journal.GetEntryState(corpoStartQuest);
		return Equals(state, gameJournalEntryState.Active);
	}
	
	public func IsEP1EpilogueActive() -> Bool {
		let journal: wref<JournalManager> = GameInstance.GetJournalManager(this.GetGameInstance());
		let corpoStartQuest: wref<JournalQuest> = journal.GetEntryByString(s"ep1/quests/main_quest/q307_tomorrow", "gameJournalQuest") as JournalQuest;
		let state: gameJournalEntryState = journal.GetEntryState(corpoStartQuest);
		return Equals(state, gameJournalEntryState.Active);
	}
	
	public func GetConfig() -> ref<BrowserExtensionConfig> {
		if this.m_config == null {
			this.m_config = new BrowserExtensionConfig();
			//ModSettings.RegisterListenerToClass(this.m_config);
			RegisterBrowserExModSettingsListener(this.m_config);
		};
		return this.m_config;
	}
	
	public func IsEnabled() -> Bool {
		return this.GetConfig().enabled;
	}
}
