module INCFCore

import Codeware.*
import Codeware.Localization.*

public abstract class CompatibilityManager {
  public static func RequiredCodeware() -> String = "1.20.3";

  public static func RequiredArchiveXL() -> String = "1.27.1";

  public static func CheckRequirements() -> Bool {
    let codewareReady = Codeware.Require(CompatibilityManager.RequiredCodeware());
    let archiveXLReady = ArchiveXL.Require(CompatibilityManager.RequiredArchiveXL());

    return codewareReady && archiveXLReady;
  }
}

public class EnglishPackage extends ModLocalizationPackage {
  protected func DefineTexts() {
    this.Text(
      "UI-INCF-NotificationRequirements",
      "Immersive Night City Fixes requires:\\n\\nCodeware {codeware_req} or higher\\nDetected Codeware {codeware_ver}\\n\\nArchiveXL {archivexl_req} or higher\\nDetected ArchiveXL {archivexl_ver}\\n\\nPlease update the outdated requirement(s) to use this mod."
    );
  }
}

public class LocalizationProvider extends ModLocalizationProvider {
  public func GetPackage(language: CName) -> ref<ModLocalizationPackage> {
    switch language {
      case n"en-us": return new EnglishPackage();
      default: return null;
    }
  }

  public func GetFallback() -> CName {
    return n"en-us";
  }
}

public class RequirementsPopup {
  public static func Show(controller: ref<worlduiIGameController>) -> ref<inkGameNotificationToken> {
    let params = new inkTextParams();

    params.AddString("codeware_req", CompatibilityManager.RequiredCodeware());
    params.AddString("codeware_ver", Codeware.Version());
    params.AddString("archivexl_req", CompatibilityManager.RequiredArchiveXL());
    params.AddString("archivexl_ver", ArchiveXL.Version());

    return GenericMessageNotification.Show(
      controller,
      GetLocalizedText("LocKey#11447"),
      GetLocalizedTextByKey(n"UI-INCF-NotificationRequirements"),
      params,
      GenericMessageNotificationType.OK
    );
  }
}

@addField(QuestTrackerGameController)
private let m_INCFPopup: ref<inkGameNotificationToken>;

@wrapMethod(QuestTrackerGameController)
protected cb func OnInitialize() -> Bool {
  wrappedMethod();

  if !CompatibilityManager.CheckRequirements() {
    this.m_INCFPopup = RequirementsPopup.Show(this);

    if IsDefined(this.m_INCFPopup) {
      this.m_INCFPopup.RegisterListener(this, n"OnINCFPopupClose");
    }
  }
}

@addMethod(QuestTrackerGameController)
protected cb func OnINCFPopupClose(data: ref<inkGameNotificationData>) {
  this.m_INCFPopup = null;
}

@if(ModuleExists("Codeware"))
public class INCFCoreMarker extends ScriptableSystem {}

@if(ModuleExists("Codeware"))
public class INCFFloatingCrateNodeToggleCallback extends DelayCallback {
  private let m_service: wref<ImmersiveWorldFixesProcessing>;

  public static func Create(service: wref<ImmersiveWorldFixesProcessing>) -> ref<INCFFloatingCrateNodeToggleCallback> {
    let cb = new INCFFloatingCrateNodeToggleCallback();
    cb.m_service = service;
    return cb;
  }

  public func Call() -> Void {
    if IsDefined(this.m_service) {
      this.m_service.ResolveINACrateNodeState();
    }
  }
}

@if(ModuleExists("Codeware"))
public class INCFAirportProxyNodeToggleCallback extends DelayCallback {
  private let m_service: wref<ImmersiveWorldFixesProcessing>;

  public static func Create(service: wref<ImmersiveWorldFixesProcessing>) -> ref<INCFAirportProxyNodeToggleCallback> {
    let cb = new INCFAirportProxyNodeToggleCallback();
    cb.m_service = service;
    return cb;
  }

  public func Call() -> Void {
    if IsDefined(this.m_service) {
      this.m_service.DisableAirportShuttleProxyNode();
    }
  }
}

@if(ModuleExists("Codeware"))
public class ImmersiveWorldFixesProcessing extends ScriptableService {
  @runtimeProperty("ModSettings.mod", "Immersive Night City Fixes")
  @runtimeProperty("ModSettings.category", "Particles")
  @runtimeProperty("ModSettings.displayName", "Disable Floating Debris")
  @runtimeProperty("ModSettings.description", "Globally disables the floating / flying magazine debris particle effect. Save Reload Required.")
  public let disableMagazineDebris: Bool = false;

  private let m_callbackSystem: wref<CallbackSystem>;

  private let m_inaTargetCarPresent: Bool;
  private let m_inaPendingCrateCheck: Bool;

  private cb func OnLoad() {
    this.m_callbackSystem = GameInstance.GetCallbackSystem();

    ModSettings.RegisterListenerToClass(this);
    ModSettings.RegisterListenerToModifications(this);

    this.m_callbackSystem
      .RegisterCallback(n"Resource/Loaded", this, n"OnAudioEventsMetadataLoaded")
      .AddTarget(ResourceTarget.Path(r"base\\sound\\event\\eventsmetadata.json"));

    this.m_callbackSystem
      .RegisterCallback(n"Resource/Load", this, n"OnMagazineDebrisSectorLoad")
      .AddTarget(ResourceTarget.Type(n"worldStreamingSector"));

    this.m_callbackSystem
      .RegisterCallback(n"Resource/Load", this, n"OnSelectiveMagazineParticleLoad")
      .AddTarget(ResourceTarget.Path(r"ep1\\fx\\enviroment\\smoke\\e_smoke_dust_street_blowing_big_001.particle"));

    this.m_callbackSystem
      .RegisterCallback(n"Resource/Load", this, n"OnSelectiveMagazineParticleLoad")
      .AddTarget(ResourceTarget.Path(r"ep1\\fx\\enviroment\\debris\\e_debris_magazines_tornado_001.particle"));

    this.m_callbackSystem
      .RegisterCallback(n"Resource/Load", this, n"OnSelectiveMagazineParticleLoad")
      .AddTarget(ResourceTarget.Path(r"ep1\\fx\\enviroment\\debris\\e_debris_magazines_tornado_002.particle"));

    this.m_callbackSystem
      .RegisterCallback(n"Resource/Load", this, n"OnSelectiveMagazineParticleLoad")
      .AddTarget(ResourceTarget.Path(r"ep1\\fx\\enviroment\\debris\\e_debris_magazines_tornado_003.particle"));

    this.m_callbackSystem
      .RegisterCallback(n"Resource/PostLoad", this, n"q305sectorProc")
      .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\ep1\\exterior_-43_-39_0_0.streamingsector"));

    this.m_callbackSystem
      .RegisterCallback(n"Resource/Ready", this, n"FixJapanTownAirLeaningWorkspot")
      .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\exterior_-6_9_0_1.streamingsector"));

    this.m_callbackSystem
      .RegisterCallback(n"Resource/Ready", this, n"OnAirportQuestSectorReady")
      .AddTarget(ResourceTarget.Path(r"base\\worlds\\03_night_city\\_compiled\\default\\ep1\\quest_08e17fd8f7744ca7.streamingsector"));

    this.m_callbackSystem.RegisterCallback(n"Entity/Assemble", this, n"OnEntityAssemble");
    this.m_callbackSystem.RegisterCallback(n"Entity/Extract", this, n"OnEntityExtract");
  }

  public cb func OnModSettingsChange() -> Void {}

  private cb func OnAudioEventsMetadataLoaded(event: ref<ResourceEvent>) -> Void {
    let jsonResource = event.GetResource() as JsonResource;
    let audioEvents: ref<audioAudioEventArray>;
    let index: Int32 = 0;

    if !IsDefined(jsonResource) {
      return;
    }

    audioEvents = jsonResource.root as audioAudioEventArray;

    if !IsDefined(audioEvents) {
      return;
    }

    while index < ArraySize(audioEvents.events) {
      if Equals(audioEvents.events[index].redId, n"sq017_sc_08_ladder") {
        audioEvents.events[index].wwiseId = 3765346442u;
        return;
      }

      index += 1;
    }
  }

  private cb func OnMagazineDebrisSectorLoad(event: ref<ResourceEvent>) -> Void {
    let sector = event.GetResource() as worldStreamingSector;
    let node: ref<worldStaticParticleNode>;
    let index: Int32 = 0;

    if !this.disableMagazineDebris || !IsDefined(sector) {
      return;
    }

    while index < sector.GetNodeCount() {
      node = sector.GetNode(index) as worldStaticParticleNode;

      if IsDefined(node) && (
        Equals(
          ResourceAsyncRef.GetPath(node.particleSystem),
          r"base\\fx\\environment\\debris\\e_debris_magazines.particle"
        ) || Equals(
          ResourceAsyncRef.GetPath(node.particleSystem),
          r"base\\fx\\environment\\debris\\e_debris_magazines_slow.particle"
        ) || Equals(
          ResourceAsyncRef.GetPath(node.particleSystem),
          r"ep1\\fx\\enviroment\\debris\\e_debris_magazines_slow_002.particle"
        ) || Equals(
          ResourceAsyncRef.GetPath(node.particleSystem),
          r"base\\fx\\environment\\debris\\e_debris_magazines_surface.particle"
        ) || Equals(
          ResourceAsyncRef.GetPath(node.particleSystem),
          r"ep1\\fx\\enviroment\\debris\\e_debris_magazines_slow_001.particle"
        )
      ) {
        node.forcedAutoHideDistance = 0.01;
        node.forcedAutoHideRange = 0.01;
      }

      index += 1;
    }
  }

  private cb func OnSelectiveMagazineParticleLoad(event: ref<ResourceEvent>) -> Void {
    let particle = event.GetResource() as CParticleSystem;
    let emitter: ref<CParticleEmitter>;
    let index: Int32 = 0;

    if !this.disableMagazineDebris || !IsDefined(particle) {
      return;
    }

    while index < ArraySize(particle.emitters) {
      emitter = particle.emitters[index];

      if IsDefined(emitter) && (
        Equals(emitter.editorName, "Magazine 01")
        || Equals(emitter.editorName, "Magazine 02")
        || Equals(emitter.editorName, "Magazine Air")
      ) {
        emitter.isEnabled = false;
        emitter.maxParticles = Cast<Uint16>(0u);
      }

      index += 1;
    }
  }

  private cb func q305sectorProc(event: ref<ResourceEvent>) {
    let sector: ref<worldStreamingSector> = event.GetResource() as worldStreamingSector;
    if !IsDefined(sector) {
      return;
    }

    let count: Int32 = sector.GetNodeSetupCount();

    if count < 728 {
      return;
    }

    let maxI: Int32 = 516;
    if (211 + maxI) >= count {
      maxI = count - 212;
    }
    if maxI <= 0 {
      return;
    }

    let i: Int32 = 1;
    while i <= maxI {
      let suffix: String = (i < 10) ? ("0" + ToString(i)) : ToString(i);
      let newNodeRef: NodeRef = CreateNodeRef("$/03_night_city/#q305_fix/#explosion_fix_node_" + suffix);

      sector.GetNodeSetup(211 + i).SetNodeRef(newNodeRef);
      i += 1;
    }
  }

  private cb func FixJapanTownAirLeaningWorkspot(event: ref<ResourceEvent>) {
    let sector: ref<worldStreamingSector> = event.GetResource() as worldStreamingSector;

    if !IsDefined(sector) {
      return;
    }

    if sector.GetNodeSetupCount() != 2296 {
      return;
    }

    let nodes = sector.GetNodes();
    let node = nodes[32] as worldAISpotNode;

    if !IsDefined(node) {
      return;
    }

    let newSpot = new AIActionSpot();
    newSpot.resource *= r"base\\workspots\\common\\ground\\generic__stand_ground_cigarette__smoke__01.workspot";
    newSpot.useClippingSpace = false;

    node.spot = newSpot;
  }

  private cb func OnAirportQuestSectorReady(event: ref<ResourceEvent>) {
    let sector: ref<worldStreamingSector> = event.GetResource() as worldStreamingSector;

    if !IsDefined(sector) {
      return;
    }

    let count: Int32 = sector.GetNodeSetupCount();

    if count != 4 && count != 6 {
      return;
    }

    this.DisableAirportShuttleProxyNode();
  }

  public func DisableAirportShuttleProxyNode() -> Void {
    let worldStateSystem = GameInstance.GetWorldStateSystem();
    worldStateSystem.ToggleNode(
      ToNodeRef("$/03_night_city/nw4/#nw4_air_traffic/#air_traffic_space_shuttle_002/_entityProxyMesh"),
      false
    );
  }

  private cb func OnEntityAssemble(event: ref<EntityLifecycleEvent>) {
    let entity = event.GetEntity();

    if !IsDefined(entity) {
      return;
    }

    if entity.GetTemplatePath() == r"base\\open_world\\minor_activities\\pacifica\\coastview\\ma_pac_cvi_14\\entities\\ma_pac_cvi_14_destroy_wreck_car_01.ent"
      && Equals(entity.GetCurrentAppearanceName(), n"default") {
      this.m_inaTargetCarPresent = true;
      this.SetINACrateNodeActive(true);
      return;
    }

    if entity.GetTemplatePath() == r"base\\gameplay\\loot\\containers\\crates\\crate_small.ent"
      && Equals(entity.GetCurrentAppearanceName(), n"crate_small_entropy_a") {
      this.m_inaPendingCrateCheck = true;

      GameInstance
        .GetDelaySystem(GetGameInstance())
        .DelayCallback(INCFFloatingCrateNodeToggleCallback.Create(this), 1.00, false);
    }
  }

  private cb func OnEntityExtract(event: ref<EntityLifecycleEvent>) {
    let entity = event.GetEntity();

    if !IsDefined(entity) {
      return;
    }

    if entity.GetTemplatePath() == r"base\\open_world\\minor_activities\\pacifica\\coastview\\ma_pac_cvi_14\\entities\\ma_pac_cvi_14_destroy_wreck_car_01.ent"
      && Equals(entity.GetCurrentAppearanceName(), n"default") {
      this.m_inaTargetCarPresent = false;
    }
  }

  public func ResolveINACrateNodeState() -> Void {
    if !this.m_inaPendingCrateCheck {
      return;
    }

    if this.m_inaTargetCarPresent {
      this.SetINACrateNodeActive(true);
      this.m_inaTargetCarPresent = false;
      this.m_inaPendingCrateCheck = false;
      return;
    }

    this.SetINACrateNodeActive(false);
    this.m_inaPendingCrateCheck = false;
  }

  private final func SetINACrateNodeActive(active: Bool) -> Void {
    let worldStateSystem = GameInstance.GetWorldStateSystem();
    worldStateSystem.ToggleNode(
      ToNodeRef("$/03_night_city/se1/loc_ma_bls_ina_se1_10_prefabBM2XS4I/loc_ma_bls_ina_se1_10_gameplay_prefabGZ2VZLQ/loc_ma_bls_ina_se1_10_loot_prefabHRTZ3AQ/{ma_bls_ina_se1_10_crate}_prefab6CFLOIY"),
      active
    );
  }
}
