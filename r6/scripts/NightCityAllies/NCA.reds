module NightCityAllies

import NightCityAllies.Settings.*
import NightCityAllies.UI.*
import NightCityAllies.Persistence.*
import NightCityAllies.Event.*
import NightCityAllies.Npc.*
import NightCityAllies.Location.*
import NightCityAllies.Localization.*
import NightCityAllies.Phone.*
import NightCityAllies.Spawn.*
import NightCityAllies.Effect.*
import NightCityAllies.Util.*
import NightCityAllies.Timer.*
import NightCityAllies.Animation.*

// API class for quick access to all systems
public final class NCA {
	public static func Settings() -> ref<NCASettings> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<NCASettings>()) as NCASettings;
	public static func UI() -> ref<UISystem> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<UISystem>()) as UISystem;
	public static func Context() -> ref<ContextSystem> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<ContextSystem>()) as ContextSystem;
	public static func Persistence() -> ref<PersistenceSystem> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<PersistenceSystem>()) as PersistenceSystem;
	public static func Events() -> ref<EventBus> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<EventBus>()) as EventBus;
	public static func Phone() -> ref<NCAPhoneSystem> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<NCAPhoneSystem>()) as NCAPhoneSystem;
	public static func NPC() -> ref<NpcManager> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<NpcManager>()) as NpcManager;
	public static func Labels() -> ref<NCALabels> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<NCALabels>()) as NCALabels;
	public static func Spawn() -> ref<SpawnSystem> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<SpawnSystem>()) as SpawnSystem;
    public static func Damage() -> ref<DamageTrackerSystem> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<DamageTrackerSystem>()) as DamageTrackerSystem;
    public static func Effect() -> ref<NCAEffectSystem> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<NCAEffectSystem>()) as NCAEffectSystem;
    public static func Util() -> ref<NCAUtil> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<NCAUtil>()) as NCAUtil;
    public static func Location() -> ref<LocationSystem> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<LocationSystem>()) as LocationSystem;
    public static func Timer() -> ref<NCATimerSystem> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<NCATimerSystem>()) as NCATimerSystem;
    public static func Animation() -> ref<NCAAnimationSystem> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<NCAAnimationSystem>()) as NCAAnimationSystem;
    public static func InteractionMenu() -> ref<NCAInteractionMenu> = GameInstance.GetScriptableSystemsContainer(GetGameInstance()).Get(NameOf<NCAInteractionMenu>()) as NCAInteractionMenu;

    public static func Player() -> ref<PlayerPuppet> = GetPlayer(GetGameInstance()) as PlayerPuppet;

	public static func CETLog(text: String) -> Void {
        NCA.Phone().CETLog(text);
    }

	public static func T(key: CName) -> String {
        return NCA.Labels().T(key);
    }
}