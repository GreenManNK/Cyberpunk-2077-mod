module NightCityAllies.Settings
    
import NightCityAllies.*
import NightCityAllies.Phone.*
import NightCityAllies.Npc.*
import NightCityAllies.UI.*

public enum NCAPhoneEntryPosition {
    Bottom = 0,
	BelowQuest = 1,
	BelowQuestTop = 2,
	AboveQuest = 3,
	AboveQuestTop = 4
}

@if(ModuleExists("ModSettingsModule")) 
public func RegisterNCASettingsListener(listener: ref<IScriptable>) {
	ModSettings.RegisterListenerToClass(listener);
  	ModSettings.RegisterListenerToModifications(listener);
}

@if(ModuleExists("ModSettingsModule")) 
public func UnregisterNCASettingsListener(listener: ref<IScriptable>) {
	ModSettings.UnregisterListenerToClass(listener);
  	ModSettings.UnregisterListenerToModifications(listener);
}

@if(!ModuleExists("ModSettingsModule")) 
public func RegisterNCASettingsListener(listener: ref<IScriptable>) {
}
@if(!ModuleExists("ModSettingsModule")) 
public func UnregisterNCASettingsListener(listener: ref<IScriptable>) {
}

public class NCASettings extends ScriptableSystem {
	private let m_isListening: Bool;

	// ============================================== User Interface =======================================================
	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "User Interface")
	@runtimeProperty("ModSettings.category.order", "10")
	@runtimeProperty("ModSettings.displayName", "Interaction Menu Rows")
	@runtimeProperty("ModSettings.description", "How many rows the interaction menu shows at once")
	@runtimeProperty("ModSettings.step", "1")
	@runtimeProperty("ModSettings.min", "4")
	@runtimeProperty("ModSettings.max", "20")
	public let interactionMenuRows: Int32 = 10;

	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "User Interface")
	@runtimeProperty("ModSettings.category.order", "10")
	@runtimeProperty("ModSettings.displayName", "Interact Button")
	@runtimeProperty("ModSettings.description", "Show button before opening the full menu")
	public let collapseInteractionMenu: Bool = true;

	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "User Interface")
	@runtimeProperty("ModSettings.category.order", "10")
	@runtimeProperty("ModSettings.dependency", "collapseInteractionMenu")
	@runtimeProperty("ModSettings.displayName", "Equipment Button")
	@runtimeProperty("ModSettings.description", "Add a second key to the interact button that opens companion equipment directly, instead of reaching it through the menu")
	public let equipmentPromptButton: Bool = true;

	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "User Interface")
	@runtimeProperty("ModSettings.category.order", "10")
	@runtimeProperty("ModSettings.dependency", "collapseInteractionMenu")
	@runtimeProperty("ModSettings.displayName", "Close Menu After Selection")
	@runtimeProperty("ModSettings.description", "Close the interaction menu after selecting an option")
	public let collapseAfterSelection: Bool = true;

	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "User Interface")
	@runtimeProperty("ModSettings.category.order", "10")
	@runtimeProperty("ModSettings.displayName", "Show Squad HUD")
	@runtimeProperty("ModSettings.description", "The list of companions currently with you, at the side of the screen")
	public let showSquadHUD: Bool = true;

	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "User Interface")
	@runtimeProperty("ModSettings.category.order", "10")
	@runtimeProperty("ModSettings.dependency", "showSquadHUD")
	@runtimeProperty("ModSettings.displayName", "Squad HUD Size")
	@runtimeProperty("ModSettings.description", "Scale of the squad list")
	@runtimeProperty("ModSettings.step", "0.1")
	@runtimeProperty("ModSettings.min", "0.5")
	@runtimeProperty("ModSettings.max", "2.0")
	public let squadHUDSize: Float = 1.2;

	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "User Interface")
	@runtimeProperty("ModSettings.category.order", "10")
	@runtimeProperty("ModSettings.dependency", "showSquadHUD")
	@runtimeProperty("ModSettings.displayName", "Squad HUD Position X")
	@runtimeProperty("ModSettings.description", "Move the squad widget left to right")
	@runtimeProperty("ModSettings.step", "10")
	@runtimeProperty("ModSettings.min", "-100")
	@runtimeProperty("ModSettings.max", "3600")
	public let squadHUDOffsetX: Float = 0.0;

	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "User Interface")
	@runtimeProperty("ModSettings.category.order", "10")
	@runtimeProperty("ModSettings.dependency", "showSquadHUD")
	@runtimeProperty("ModSettings.displayName", "Squad HUD Position Y")
	@runtimeProperty("ModSettings.description", "Move the squad widget top to bottom")
	@runtimeProperty("ModSettings.step", "10")
	@runtimeProperty("ModSettings.min", "-1200")
	@runtimeProperty("ModSettings.max", "200")
	public let squadHUDOffsetY: Float = 0.0;

// ================================================== Phone ============================================================
	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "Phone")
	@runtimeProperty("ModSettings.category.order", "20")
	@runtimeProperty("ModSettings.displayName", "Position - Companion App")
	@runtimeProperty("ModSettings.description", "Select where Night City Allies shows in your phone")
	public let phoneMercAppPosition: NCAPhoneEntryPosition = NCAPhoneEntryPosition.AboveQuestTop;

	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "Phone")
	@runtimeProperty("ModSettings.category.order", "20")
	@runtimeProperty("ModSettings.displayName", "Position - Conversations")
	@runtimeProperty("ModSettings.description", "Select where companion messages show in your phone")
	public let phoneConversationsPosition: NCAPhoneEntryPosition = NCAPhoneEntryPosition.BelowQuest;

	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "Phone")
	@runtimeProperty("ModSettings.category.order", "20")
	@runtimeProperty("ModSettings.displayName", "Message cooldown (minutes)")
	@runtimeProperty("ModSettings.description", "After getting a message, prevent another message for the selected time (Ingame minutes)")
	@runtimeProperty("ModSettings.step", "10")
	@runtimeProperty("ModSettings.min", "0")
	@runtimeProperty("ModSettings.max", "360")
	public let messageCooldown: Int32 = 0;

	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "Phone")
	@runtimeProperty("ModSettings.category.order", "20")
	@runtimeProperty("ModSettings.displayName", "Repeatable Conversations")
	@runtimeProperty("ModSettings.description", "Allow SMS conversations you already saw to be replayed")
	public let repeatableConversations: Bool = true;

// ================================================= Gameplay ==========================================================
	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.displayName", "Highest Allowed Gameplay Tier")
	@runtimeProperty("ModSettings.description", "Despawn companions when entering a higher gameplay tier than selected. Set lower if you want companions to disappear in cutscenes")
	@runtimeProperty("ModSettings.category", "Gameplay")
	@runtimeProperty("ModSettings.category.order", "30")
	public let maxGameplayTier: GameplayTier = GameplayTier.Tier4_FPPCinematic; // Tier2_StagedGameplay Tier1_FullGameplay; //

	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "Gameplay")
	@runtimeProperty("ModSettings.category.order", "30")
	@runtimeProperty("ModSettings.displayName", "Mercenary Respawn Time (hours)")
	@runtimeProperty("ModSettings.description", "Ingame hours before the mercenaries in the world are rerolled")
	@runtimeProperty("ModSettings.step", "1")
	@runtimeProperty("ModSettings.min", "1")
	@runtimeProperty("ModSettings.max", "12")
	public let mercRespawnTime: Int32 = 6;

// ================================================ Characters =========================================================
	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "Characters")
	@runtimeProperty("ModSettings.category.order", "50")
	@runtimeProperty("ModSettings.displayName", "Load AMM Custom Characters (needs reload)")
	@runtimeProperty("ModSettings.description", "Add AMM characters you have installed as companions")
	public let loadAMMCharacters: Bool = true;

	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "Characters")
	@runtimeProperty("ModSettings.category.order", "50")
	@runtimeProperty("ModSettings.displayName", "Load AMM Default Characters (needs reload)")
	@runtimeProperty("ModSettings.description", "Add AMM default characters")
	@runtimeProperty("ModSettings.dependency", "loadAMMCharacters")
	public let loadAMMDefaultCharacters: Bool = false;

// ================================================== Cheats ===========================================================
	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "Cheats")
	@runtimeProperty("ModSettings.category.order", "500")
	@runtimeProperty("ModSettings.displayName", "Invulnerable Companions")
	@runtimeProperty("ModSettings.description", "Companions cannot be hurt or killed")
	public let invulnerableCompanions: Bool = false;

	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "Cheats")
	@runtimeProperty("ModSettings.category.order", "500")
	@runtimeProperty("ModSettings.displayName", "Unlock all companions")
	@runtimeProperty("ModSettings.description", "Every companion can be called")
	public let unlockAll: Bool = false;

	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "Cheats")
	@runtimeProperty("ModSettings.category.order", "500")
	@runtimeProperty("ModSettings.displayName", "Skip all timers")
	@runtimeProperty("ModSettings.description", "All timers finish the next ingame minute (commute, death penalty, etc.)")
	public let skipAllTimers: Bool = false;

	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "Cheats")
	@runtimeProperty("ModSettings.category.order", "500")
	@runtimeProperty("ModSettings.displayName", "Skip commute")
	@runtimeProperty("ModSettings.description", "Companions spawn in front of you instantly when you call them")
	public let skipCommute: Bool = false;

// =============================================== Experimental ========================================================
	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "Experimental")
	@runtimeProperty("ModSettings.category.order", "1000")
	@runtimeProperty("ModSettings.displayName", "Experimental Features")
	@runtimeProperty("ModSettings.description", "Unlocks features that are unfinished or can have smaller issues")
	public let experimentalFeaturesEnabled: Bool = false;

	@runtimeProperty("ModSettings.mod", "Night City Allies")
	@runtimeProperty("ModSettings.category", "Experimental")
	@runtimeProperty("ModSettings.category.order", "1000")
	@runtimeProperty("ModSettings.displayName", "Show HP Bars")
	@runtimeProperty("ModSettings.dependency", "experimentalFeaturesEnabled")
	@runtimeProperty("ModSettings.description", "Show a healthbar above companions when looking at them")
	public let companionHpBarsEnabled: Bool = false;

	public func OnAttach() {
		GameInstance.GetCallbackSystem().RegisterCallback(n"Session/Start", this, n"OnSessionStart");
	}

	public final func OnSessionStart(evt: ref<GameSessionEvent>) {
        this.Init(NCA.Player());
        this.ApplySettings(this);
	}

	public func OnModSettingsChange() -> Void {
        NCA.UI().RefreshSquadHUD();
        NCA.NPC().RefreshGodMode();
	}

    public func ApplySettings(settings: ref<NCASettings>) -> Void {} // Notify lua

	public final static func GetInstance(gameInstance: GameInstance) -> ref<NCASettings> {
		return GameInstance.GetScriptableSystemsContainer(gameInstance).Get(NameOf<NCASettings>()) as NCASettings;
	}

	public final static func Get() -> ref<NCASettings> {
		return NCASettings.GetInstance(GetGameInstance());
	}
	
	public func OnDetach() -> Void {
		this.m_isListening = false;
		UnregisterNCASettingsListener(this);
	}

	public func Init(attachedPlayer: ref<PlayerPuppet>) -> Void {
		if this.m_isListening {
			return;
		}

		this.m_isListening = true;
		RegisterNCASettingsListener(this);
    }

    public func GetCompanionGodModeType() -> gameGodModeType {
        if (this.invulnerableCompanions) {
            return gameGodModeType.Invulnerable;
        }

        return gameGodModeType.Mortal;
    }
}
