module NightCityAllies.UI

import NightCityAllies.*
import NightCityAllies.Npc.*

public class SquadMemberController extends inkLogicController {
    private let m_nameText: wref<inkText>;
    private let m_levelText: wref<inkText>;

    private let m_staminaBar: wref<inkRectangle>;
    private let m_healthBar: wref<inkRectangle>;
    private let m_staminaWrapper: wref<inkBorder>;
    private let m_healthWrapper: wref<inkBorder>;

    private let m_miniLevelText: wref<inkText>;
    private let m_miniStaminaBar: wref<inkRectangle>;
    private let m_miniHealthBar: wref<inkRectangle>;
    private let m_miniFriendshipBar: wref<inkRectangle>;
    private let m_miniLoveBar: wref<inkRectangle>;

    private let m_pointsText: wref<inkText>;
    private let m_pointsValueText: wref<inkText>;
    private let m_statusText: wref<inkText>;

    private let m_npcEntityID: EntityID;
    private let m_npc: ref<NpcHandle>;
    private let m_healthListener: ref<NpcStatPoolListener>;
    private let m_staminaListener: ref<NpcStatPoolListener>;

    private let m_miniHealthListener: ref<NpcStatPoolListener>;
    private let m_miniStaminaListener: ref<NpcStatPoolListener>;
    private let m_miniFriendshipListener: ref<ManualStatBar>;
    private let m_miniLoveListener: ref<ManualStatBar>;

    //private let m_hasPlayedIntro: Bool;
    private let m_animProxy: ref<inkAnimProxy>;

    public func GetNpc() -> ref<NpcHandle> {
        return this.m_npc;
    }

    public func Setup(npc: ref<NpcHandle>) -> Void {
        this.m_npcEntityID = npc.entityID;
        this.m_npc = npc;

        let level: Int32 = npc.GetLevel();
        let name: String = npc.GetName();

        this.m_nameText = this.GetChildWidgetByPath(n"Name") as inkText;
        this.m_levelText = this.GetChildWidgetByPath(n"LevelContainer/Level") as inkText;
        this.m_staminaBar = this.GetChildWidgetByPath(n"StatBars/Stamina") as inkRectangle;
        this.m_healthBar = this.GetChildWidgetByPath(n"StatBars/Health") as inkRectangle;
        this.m_staminaWrapper = this.GetChildWidgetByPath(n"StatBars/StaminaWrapper") as inkBorder;
        this.m_healthWrapper = this.GetChildWidgetByPath(n"StatBars/HealthWrapper") as inkBorder;
        this.m_pointsText = this.GetChildWidgetByPath(n"LevelContainer/ExpLabel") as inkText;
        this.m_pointsValueText = this.GetChildWidgetByPath(n"LevelContainer/ExpAmount") as inkText;
        this.m_statusText = this.GetChildWidgetByPath(n"StatusText") as inkText;

        this.m_miniLevelText = this.GetChildWidgetByPath(n"MiniStats/LevelText") as inkText;
        this.m_miniStaminaBar = this.GetChildWidgetByPath(n"MiniStats/CStamina") as inkRectangle;
        this.m_miniHealthBar = this.GetChildWidgetByPath(n"MiniStats/CHealth") as inkRectangle;
        this.m_miniFriendshipBar = this.GetChildWidgetByPath(n"MiniStats/Friendship") as inkRectangle;
        this.m_miniLoveBar = this.GetChildWidgetByPath(n"MiniStats/Love") as inkRectangle;


        this.m_nameText.SetText(name);

        // Listen to npc stat changes
        this.RegisterListeners();

        this.Update();
    }

    public func Update() {
        this.m_levelText.SetText(IntToString(this.m_npc.GetLevel()));
        this.m_miniLevelText.SetText(IntToString(this.m_npc.GetLevel()));
        this.m_pointsValueText.SetText(this.m_npc.GetExpString());

        let friendshipInt = this.m_npc.GetFriendship();
        let loveInt = this.m_npc.GetLove();

        this.m_miniFriendshipListener.OnStatPoolValueChanged(-256.0, Cast<Float>(friendshipInt));
        this.m_miniLoveListener.OnStatPoolValueChanged(-256.0, Cast<Float>(loveInt));
    }

	public func CancelAnimation() {
		if IsDefined(this.m_animProxy) {
			this.m_animProxy.GotoEndAndStop();
			this.m_animProxy = null;
		}
	}
    
    public func PlayIntro() {
		this.CancelAnimation();
        // TODO wait for menu close
        //if (!this.m_hasPlayedIntro) {
            this.m_animProxy = this.PlayLibraryAnimation(n"intro");
            //this.m_hasPlayedIntro = true;
        //}
    }
    
    public func Expand() -> Void {
		this.CancelAnimation();
    	this.m_animProxy = this.PlayLibraryAnimation(n"expand");
    }

    
    public func Collapse() -> Void {
		this.CancelAnimation();
    	this.m_animProxy = this.PlayLibraryAnimation(n"collapse");
    }
    
    public func Commute() -> Void {
		this.CancelAnimation();
    	this.m_animProxy = this.PlayLibraryAnimation(n"commute");
    }


    public func SetStatusText(color: HDRColor, text: String) {
        this.m_statusText.SetTintColor(color);
        this.m_statusText.SetText(text);
    }

    public final func ShowStats(stats: SquadDamageStats) -> Void {
        this.m_statusText.SetTintColor(new HDRColor(1.0, 0.6, 0.1, 1.0));
        this.m_statusText.SetText("/LH_" + this.FormatNumber(stats.lastHitDamage) + " /TD_" + this.FormatNumber(stats.totalDamage) + " /DPS_" + this.FormatNumber(stats.dps));
    }

    private func FormatNumber(value: Float) -> String {
        let precision: Int32 = 100;
        let integerPart: Int32 = Cast<Int32>(value);
        let fractionalPart: Int32 = Cast<Int32>((value - Cast<Float>(integerPart)) * Cast<Float>(precision) + 0.5);
        let sInt: String = ToString(integerPart);
        let sFrac: String = fractionalPart < 10 ? "0" + ToString(fractionalPart) : ToString(fractionalPart);
        return sInt + "." + sFrac;
    }

    protected cb func OnInitialize() -> Bool {
    }

    private func RegisterListeners() -> Void {
        this.m_healthListener = NpcStatPoolListener.Create(this.m_healthBar);
        this.m_staminaListener = NpcStatPoolListener.Create(this.m_staminaBar);

        this.m_miniHealthListener = NpcStatPoolListener.Create(this.m_miniHealthBar);
        this.m_miniStaminaListener = NpcStatPoolListener.Create(this.m_miniStaminaBar);

        this.m_miniFriendshipListener = ManualStatBar.Create(this.m_miniFriendshipBar);
        this.m_miniLoveListener = ManualStatBar.Create(this.m_miniLoveBar);


        let statPoolSystem = GameInstance.GetStatPoolsSystem(GetGameInstance());
        statPoolSystem.RequestRegisteringListener(Cast<StatsObjectID>(this.m_npcEntityID), gamedataStatPoolType.Health, this.m_healthListener);
        statPoolSystem.RequestRegisteringListener(Cast<StatsObjectID>(this.m_npcEntityID), gamedataStatPoolType.Stamina, this.m_staminaListener);

        statPoolSystem.RequestRegisteringListener(Cast<StatsObjectID>(this.m_npcEntityID), gamedataStatPoolType.Health, this.m_miniHealthListener);
        statPoolSystem.RequestRegisteringListener(Cast<StatsObjectID>(this.m_npcEntityID), gamedataStatPoolType.Stamina, this.m_miniStaminaListener);
    }

    protected cb func OnUninitialize() -> Bool {
        let statPoolSystem = GameInstance.GetStatPoolsSystem(GetGameInstance());
        statPoolSystem.RequestUnregisteringListener(Cast<StatsObjectID>(this.m_npcEntityID), gamedataStatPoolType.Health, this.m_healthListener);
        statPoolSystem.RequestUnregisteringListener(Cast<StatsObjectID>(this.m_npcEntityID), gamedataStatPoolType.Stamina, this.m_staminaListener);

        statPoolSystem.RequestUnregisteringListener(Cast<StatsObjectID>(this.m_npcEntityID), gamedataStatPoolType.Health, this.m_miniHealthListener);
        statPoolSystem.RequestUnregisteringListener(Cast<StatsObjectID>(this.m_npcEntityID), gamedataStatPoolType.Stamina, this.m_miniStaminaListener);
    }
}

public class NpcStatPoolListener extends ScriptStatPoolsListener {
    let m_fullSize: Vector2;
    let m_bar: wref<inkRectangle>;

    public static func Create(bar: wref<inkRectangle>) -> ref<NpcStatPoolListener> {
        let created = new NpcStatPoolListener();
        created.m_bar = bar;
        created.m_fullSize = bar.GetSize();
        return created;
    }
    
    public func OnStatPoolValueChanged(oldValue: Float, newValue: Float, percToPoints: Float) -> Void {
        if newValue != oldValue {
            this.m_bar.SetSize(Vector2(this.m_fullSize.X * (newValue/100.0), this.m_fullSize.Y));
            //if newValue < 25.0 {
            //    inkWidgetRef.SetTintColor(this.m_healthBar, new HDRColor(1.0, 0.0, 0.0, 1.0));
            //}
        };
    }
}

public class ManualStatBar {
    let m_fullSize: Vector2;
    let m_bar: wref<inkRectangle>;

    public static func Create(bar: wref<inkRectangle>) -> ref<ManualStatBar> {
        let created = new ManualStatBar();
        created.m_bar = bar;
        created.m_fullSize = bar.GetSize();
        return created;
    }
    
    public func OnStatPoolValueChanged(oldValue: Float, newValue: Float) -> Void {
        if newValue != oldValue {
            this.m_bar.SetSize(Vector2(this.m_fullSize.X * newValue/100.0, this.m_fullSize.Y));
        };
    }
}

