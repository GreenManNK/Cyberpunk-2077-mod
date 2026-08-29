module populations

enum DynamicCrowdDensity {
    Low = 0,
    Medium = 1,
    High = 2,
    Psycho = 3
}

public class DynamicCrowdDensitySettings {
    public static func Get() -> ref<DynamicCrowdDensitySettings> {
        let self: ref<DynamicCrowdDensitySettings> = new DynamicCrowdDensitySettings();
        return self;
    }

    
    let enabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "Time-based Density Mod")
    @runtimeProperty("ModSettings.displayName", "Enable Mod")
    @runtimeProperty("ModSettings.description", "Time-based crowd density")
    let timeBasedEnabled: Bool = true;

    @runtimeProperty("ModSettings.mod", "Time-based Density Mod")
    @runtimeProperty("ModSettings.displayName", "Day Density")
    @runtimeProperty("ModSettings.description", "Density during day time hours (6am to 10pm)")
    @runtimeProperty("ModSettings.displayValues.Low", "UI-Settings-Gameplay-Misc-CrowdDensityLow")
    @runtimeProperty("ModSettings.displayValues.Medium", "UI-Settings-Gameplay-Misc-CrowdDensityMedium")
    @runtimeProperty("ModSettings.displayValues.High", "UI-Settings-Gameplay-Misc-CrowdDensityHigh")
    @runtimeProperty("ModSettings.displayValues.Psycho", "UI-Settings-Gameplay-Misc-CrowdDensityPsycho")
    @runtimeProperty("ModSettings.dependency", "timeBasedEnabled")
    let dayTimeDensity: DynamicCrowdDensity = DynamicCrowdDensity.Medium;

    @runtimeProperty("ModSettings.mod", "Time-based Density Mod")
    @runtimeProperty("ModSettings.displayName", "Night Density")
    @runtimeProperty("ModSettings.description", "Density during night time hours (10pm to 6am)")
    @runtimeProperty("ModSettings.displayValues.Low", "UI-Settings-Gameplay-Misc-CrowdDensityLow")
    @runtimeProperty("ModSettings.displayValues.Medium", "UI-Settings-Gameplay-Misc-CrowdDensityMedium")
    @runtimeProperty("ModSettings.displayValues.High", "UI-Settings-Gameplay-Misc-CrowdDensityHigh")
    @runtimeProperty("ModSettings.displayValues.Psycho", "UI-Settings-Gameplay-Misc-CrowdDensityPsycho")
    @runtimeProperty("ModSettings.dependency", "timeBasedEnabled")
    let nightTimeDensity: DynamicCrowdDensity = DynamicCrowdDensity.Low;

    @runtimeProperty("ModSettings.mod", "Time-based Density Mod")
    @runtimeProperty("ModSettings.displayName", "Peak Hour Density")
    @runtimeProperty("ModSettings.description", "Density during peak time hours (10am to 7pm)")
    @runtimeProperty("ModSettings.displayValues.Low", "UI-Settings-Gameplay-Misc-CrowdDensityLow")
    @runtimeProperty("ModSettings.displayValues.Medium", "UI-Settings-Gameplay-Misc-CrowdDensityMedium")
    @runtimeProperty("ModSettings.displayValues.High", "UI-Settings-Gameplay-Misc-CrowdDensityHigh")
    @runtimeProperty("ModSettings.displayValues.Psycho", "UI-Settings-Gameplay-Misc-CrowdDensityPsycho")
    @runtimeProperty("ModSettings.dependency", "timeBasedEnabled")
    let peakTimeDensity: DynamicCrowdDensity = DynamicCrowdDensity.High;

    
    // Check if it is night
    
    public func IsNightTimeDensity(gameInstance: GameInstance) -> Bool {
        let currentTime: GameTime = GameInstance.GetGameTime(gameInstance);
        let hour: Int32 = GameTime.Hours(currentTime);
        return hour >= 22 || hour < 6;
    }

    
    // Check if it is peak time
    
    public func IsPeakTimeDensity(gameInstance: GameInstance) -> Bool {
        let currentTime: GameTime = GameInstance.GetGameTime(gameInstance);
        let hour: Int32 = GameTime.Hours(currentTime);
        return hour >= 9 && hour <= 18;
    }

    
    // Determine if the current district is low or high population
    
    private func IsAlwaysLowArea() -> Bool {
       let gi: GameInstance = GetGameInstance();
        let mapBB: wref<IBlackboard> = GameInstance.GetBlackboardSystem(gi).Get(GetAllBlackboardDefs().UI_Map);
        let currLocEnum: String = mapBB.GetString(GetAllBlackboardDefs().UI_Map.currentLocationEnumName); 

        switch currLocEnum {
            case "Badlands_RedPeaks":
                return true;
            case "Badlands_RockyRidge":
                return true;
            case "Badlands_VasquezPass":
                return true;
            case "Badlands_SierraSonora":
                return true;
            case "Badlands_LagunaBend":
                return true;
            case "Badlands_JacksonPlains":
                return true;
            case "Badlands_BiotechnicaFlats":
                return true;
            case "Badlands_DryCreek":
                return true;
            case "SouthBadlands_EdgewoodFarm":
                return true;
            case "Badlands_JacksonPlains":
                return true;
            case "Badlands_LasPalapas":
                return true;
            case "Badlands_NorthSunriseOilField":
                return true;
            case "SouthBadlands_PoppyFarm":
                return true;
            case "Badlands_RattlesnakeCreek":
                return true;
            case "Badlands_SantaClara":
                return true;
            case "SouthBadlands_TrailerPark":
                return true;
            case "Badlands_Yucca":
                return true;
            default:
                return false;    
        }
    }

    private func IsPsychoArea() -> Bool {
    let gi: GameInstance = GetGameInstance();
    let mapBB: wref<IBlackboard> = GameInstance.GetBlackboardSystem(gi).Get(GetAllBlackboardDefs().UI_Map);
    let currLocEnum: String = mapBB.GetString(GetAllBlackboardDefs().UI_Map.currentLocationEnumName);

    switch currLocEnum {
        case "Kabuki_LizziesBar":
            return true;
        default:
            return false;
    };
}


    private func IsLowPopulationDistrict() -> Bool {
    let gi: GameInstance = GetGameInstance();
    let mapBB: wref<IBlackboard> = GameInstance.GetBlackboardSystem(gi).Get(GetAllBlackboardDefs().UI_Map);
    let currLocEnum: String = mapBB.GetString(GetAllBlackboardDefs().UI_Map.currentLocationEnumName);

    switch currLocEnum {
        case "Northside":
            return true;
        case "NorthOaks":
            return true;
        case "RanchoCoronado":
            return true;
        case "WestWindEstate":
            return true;
        case "Coastview":
            return true;
        case "Pacifica":
            return true;
        case "Westbrook":
            return true;
        case "ArasakaWaterfront":
            return true;
        case "Arroyo":
            return true;
        default:
            return false;
    };
}

private func IsHighDensityDistrict() -> Bool {
    let gi: GameInstance = GetGameInstance();
    let mapBB: wref<IBlackboard> = GameInstance.GetBlackboardSystem(gi).Get(GetAllBlackboardDefs().UI_Map);
    let currLocEnum: String = mapBB.GetString(GetAllBlackboardDefs().UI_Map.currentLocationEnumName);

    switch currLocEnum {
        case "CharterHill":
            return true;
        case "CityCenter":
            return true;
        case "LittleChina":
            return true;
        case "Downtown":
            return true;
        case "Kabuki":
            return true;
        case "JapanTown":
            return true;
        case "Heywood":
            return true;
        case "Wellsprings":
            return true;
        case "VistaDelRey":
            return true;
        case "CorpoPlaza":
            return true;
        case "Glen":
            return true;    
        default:
            return false;
    };
}
    
    // Apply a given density to the UserSettings
    
    private func ApplyCrowdDensity(settings: ref<UserSettings>, density: DynamicCrowdDensity) -> Void {
        let var: ref<ConfigVar> = settings.GetVar(n"/graphics/performance", n"CrowdDensity");
        if (var == null) {
            return;
        }

        let varType: ConfigVarType = var.GetType();
        if (NotEquals(varType, ConfigVarType.NameList)) {
            return;
        }

        let listVar: ref<ConfigVarListName> = var as ConfigVarListName;
        let newIndex: Int32 = EnumInt(density);
        let values: [CName] = listVar.GetValues();

        if (ArraySize(values) < 5 && newIndex == 4) {
            listVar.SetIndex(2);
            return;
        }

        if (listVar.GetIndex() != newIndex) {
            listVar.SetIndex(newIndex);
        }
    }

    // Process the crowd density for the current player

    public func ProcessCrowdChange(gameInstance: GameInstance, settings: ref<UserSettings>) -> Void {
        let player: ref<PlayerPuppet> = GameInstance.GetPlayerSystem(gameInstance).GetLocalPlayerMainGameObject() as PlayerPuppet;
        if (!IsDefined(player)) { return; }
        if (!this.enabled || !this.timeBasedEnabled) { return; }

        let isNight: Bool = this.IsNightTimeDensity(gameInstance);
        let isPeak: Bool = this.IsPeakTimeDensity(gameInstance);

        // Determine base density
        let baseDensity: DynamicCrowdDensity = isPeak ? this.peakTimeDensity : (isNight ? this.nightTimeDensity : this.dayTimeDensity);

        // Apply population cap
        let finalDensity: DynamicCrowdDensity =
        this.IsPsychoArea()
        ? DynamicCrowdDensity.Psycho
        : (this.IsAlwaysLowArea()
        ? DynamicCrowdDensity.Low
        : ((this.IsLowPopulationDistrict() && EnumInt(baseDensity) > EnumInt(DynamicCrowdDensity.Medium))
        || (this.IsHighDensityDistrict() && EnumInt(baseDensity) < EnumInt(DynamicCrowdDensity.Medium))
        ? DynamicCrowdDensity.Medium
        : baseDensity));
        
        this.ApplyCrowdDensity(settings, finalDensity);

        if (settings.NeedsConfirmation()) {
            settings.ConfirmChanges();
        }
    }

    
    
    // Process Crowd Update
    
    public func ProcessAutoCrowdUpdate(gameInstance: GameInstance) -> Void {
        if (!this.enabled) { return; }

        let settings: ref<UserSettings> = GameInstance.GetSettingsSystem(gameInstance);
        this.ProcessCrowdChange(gameInstance, settings);
    }
}

//@wrapMethod(PlayerPuppet)
//protected cb func OnDistrictChanged(evt: ref<PlayerEnteredNewDistrictEvent>) -> Bool {
//   let result: Bool = wrappedMethod(evt);
//
//  DynamicCrowdDensitySettings.Get().ProcessAutoCrowdUpdate(this.GetGame());
//
//  return result;
//

public class CrowdUpdateCallback extends DelayCallback {
    private let gameInstance: GameInstance;

    public func Initialize(gameInstance: GameInstance) -> Void {
        this.gameInstance = gameInstance;
    }

    public func Call() -> Void {
        let settings: ref<DynamicCrowdDensitySettings> = DynamicCrowdDensitySettings.Get();

        if settings.enabled {
            settings.ProcessAutoCrowdUpdate(this.gameInstance);

            // Reschedule itself
            let delaySystem: ref<DelaySystem> = GameInstance.GetDelaySystem(this.gameInstance);
            let cb: ref<CrowdUpdateCallback> = new CrowdUpdateCallback();
            cb.Initialize(this.gameInstance);
            delaySystem.DelayCallback(cb, 7.0);
        }
    }
}

@wrapMethod(PlayerPuppet)
protected cb func OnGameAttached() -> Bool {
    wrappedMethod();
    this.QueueCrowdUpdateLoop();
}

@addMethod(PlayerPuppet)
private func QueueCrowdUpdateLoop() -> Void {
    let gameInstance: GameInstance = this.GetGame();
    let delaySystem: ref<DelaySystem> = GameInstance.GetDelaySystem(gameInstance);

    let cb: ref<CrowdUpdateCallback> = new CrowdUpdateCallback();
    cb.Initialize(gameInstance);
    delaySystem.DelayCallback(cb, 7.0);
}