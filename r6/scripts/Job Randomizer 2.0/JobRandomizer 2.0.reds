enum RandomMappinType{
  Mappin_Gig = 0,
  Mappin_NCPD = 1,
}
public class MappinControllerWrapper{
  let mappin:wref<BaseWorldMapMappinController>;
    public static func Create(mappin:ref<BaseWorldMapMappinController>)->ref<MappinControllerWrapper>{
    let self = new MappinControllerWrapper();
    self.mappin = mappin;
    return self;
  }
}

public class MappinControllerRandomWrapper extends MappinControllerWrapper
{
  let randStartNum: Int32;
  let randEndNum: Int32;
  public func IsInRandRange(num:Int32)->Bool
  {
    if num>=this.randStartNum &&num<this.randEndNum
    {
      return true;
    }
    return false;
  }
  public func Mappin ()->wref<BaseWorldMapMappinController> = this.mappin;
  public func RandStartNum ()->Int32 = this.randStartNum;
  public func RandEndNum ()->Int32 = this.randEndNum;
  public static func Create(mappin:ref<BaseWorldMapMappinController>,randStartNum:Int32,randEndNum:Int32)->ref<MappinControllerRandomWrapper>{
    let self = new MappinControllerRandomWrapper();
    self.mappin = mappin;
    self.randEndNum = randEndNum;
    self.randStartNum = randStartNum;
    return self;
  }
}
public func GetRangeArray()-> array<Float> = [
  400.0,900.0,1500.0,2500.0,3500.0,4700.0,6000.0,7500.0,9000.0
]

public func GetRandomWeightFromDistance(distance:Float) ->Int32
{
  let profile = GetRangeProfile(distance);
  let rangeArray = GetRangeArray();
  let profileCount = ArraySize(rangeArray);
  let baseWeight = profileCount-profile;
  //let weight = baseWeight*baseWeight*(baseWeight+1)/3;
  let weight = RoundF(PowF(3.0,Cast<Float>(baseWeight)))*baseWeight/10;
  return weight;
}

public func GetRangeProfile(distance:Float) ->Int32
{
  let rangeArray = GetRangeArray();
  let i=0;
  while i<ArraySize(rangeArray)
  {
    if distance<rangeArray[i]
    {
      return i;
    }
    i+=1;
  }
  return i;
}

@addField(WorldMapMenuGameController)
let hintPriority : Int32 =1;

@addField(WorldMapMenuGameController)
let randomMappinSelected : Bool = false;

@addField(WorldMapMenuGameController)
private let jobRandomizerSetting:ref<JobRandomizerSettings>;

@addField(WorldMapMenuGameController)
private let controllerSupport:Bool;

@addMethod(WorldMapMenuGameController)
private func SelectAreaWeightedRandomMappin(type:RandomMappinType)
{
  let container = this.GetSpawnContainer();
  let numChildren = container.GetNumChildren();
  let ncpdWrappers : array<ref<MappinControllerRandomWrapper>>;
  let gigWrappers : array<ref<MappinControllerRandomWrapper>>;
  let sumNCPDWeights :Int32 = 0;
  let sumGigWeights :Int32 = 0;
  let distance : Float;
  let randomWeight :Int32 = 0;
  let i = 0;

  while i < numChildren {
    let child = container.GetWidgetByIndex(i) as inkCompoundWidget;
    let controller = child.GetController() as BaseWorldMapMappinController;
    let mappinVariant = controller.m_mappin.GetVariant();
    if !controller.m_mappin.IsPlayerTracked() && NotEquals(controller.m_mappin.GetPhase(),gamedataMappinPhase.CompletedPhase)
    {
      switch mappinVariant
      {
        case gamedataMappinVariant.GangWatchVariant:
        case gamedataMappinVariant.HiddenStashVariant:
        case gamedataMappinVariant.OutpostVariant:
          distance = controller.GetDistanceToPlayer();
          randomWeight = GetRandomWeightFromDistance(distance);
          ArrayPush(ncpdWrappers,MappinControllerRandomWrapper.Create(controller, sumNCPDWeights, sumNCPDWeights+=randomWeight));
          //Debug(s"WorldMapMenuGameController SelectRandomMappin NCPD Mappin: \(mappinVariant) - DistanceToPlayer: \(distance) - RandomWeight: \(randomWeight) - SumNCPDWeights: \(sumNCPDWeights)");
          break;
        case gamedataMappinVariant.QuestGiverVariant:
        case gamedataMappinVariant.BountyHuntVariant:
        case gamedataMappinVariant.SabotageVariant:
        case gamedataMappinVariant.RetrievingVariant:
        case gamedataMappinVariant.ClientInDistressVariant:
        //case gamedataMappinVariant.FixerVariant:
        case gamedataMappinVariant.ThieveryVariant:
        case gamedataMappinVariant.Zzz06_NCPDGigVariant:
        case gamedataMappinVariant.Zzz18_RacingVariant:
        case gamedataMappinVariant.Zzz09_CourierSandboxActivityVariant:
          //ArrayPush(gigControllers,controller);
          distance = controller.GetDistanceToPlayer();
          randomWeight = GetRandomWeightFromDistance(distance);
          ArrayPush(gigWrappers,MappinControllerRandomWrapper.Create(controller, sumGigWeights, sumGigWeights+=randomWeight));
          //Debug(s"WorldMapMenuGameController SelectRandomMappin Gig Mappin: \(mappinVariant) - DistanceToPlayer: \(distance) - RandomWeight: \(randomWeight) - SumGigWeights: \(sumGigWeights)");
          break;
      }
    }
    i+=1;
  }
  if Equals(type,RandomMappinType.Mappin_NCPD)
  {
    let rand = RandRange(0,sumNCPDWeights);
    let randMappin : ref<BaseWorldMapMappinController>;
    for wrapper in ncpdWrappers
    {
      if wrapper.IsInRandRange(rand)
      {
        randMappin = wrapper.Mappin();
        //Debug(s"WorldMapMenuGameController SelectRandomMappin SelectedNCPDMappinDistance: \(randMappin.GetDistanceToPlayer()) - StartWeight: \(wrapper.RandStartNum()) - EndWeight: \(wrapper.RandEndNum()) - RandomNum: \(rand)");
       
        this.PlaySound(n"MapPin", n"OnEnable");
        this.TrackMappin(randMappin);
        break;
      }
    }
  }
  if Equals(type,RandomMappinType.Mappin_Gig)
  {
    let rand = RandRange(0,sumGigWeights);
    let randMappin : ref<BaseWorldMapMappinController>;
    for wrapper in gigWrappers
    {
      if wrapper.IsInRandRange(rand)
      {
        randMappin = wrapper.Mappin();
        //Debug(s"WorldMapMenuGameController SelectRandomMappin SelectedGigMappinDistance: \(randMappin.GetDistanceToPlayer()) - StartWeight: \(wrapper.RandStartNum()) - EndWeight: \(wrapper.RandEndNum()) - RandomNum: \(rand)");
        
        this.PlaySound(n"MapPin", n"OnEnable");
        this.TrackQuestMappin(randMappin);
        break;
      }
    }

  }
}

@addMethod(WorldMapMenuGameController)
private func SelectRandomMappin(type:RandomMappinType)
{
  let container = this.GetSpawnContainer();
  let numChildren = container.GetNumChildren();
  let ncpdControllers : array<ref<BaseWorldMapMappinController>>;
  let gigControllers : array<ref<BaseWorldMapMappinController>>;

  let i = 0;
  while i < numChildren {
    let child = container.GetWidgetByIndex(i) as inkCompoundWidget;
    let controller = child.GetController() as BaseWorldMapMappinController;
    let mappinVariant = controller.m_mappin.GetVariant();
    if !controller.m_mappin.IsPlayerTracked() && NotEquals(controller.m_mappin.GetPhase(),gamedataMappinPhase.CompletedPhase)
    {
      switch mappinVariant
      {
        case gamedataMappinVariant.GangWatchVariant:
        case gamedataMappinVariant.HiddenStashVariant:
        case gamedataMappinVariant.OutpostVariant:
          ArrayPush(ncpdControllers,controller);
          break;
      
        case gamedataMappinVariant.QuestGiverVariant:
        case gamedataMappinVariant.BountyHuntVariant:
        case gamedataMappinVariant.SabotageVariant:
        case gamedataMappinVariant.RetrievingVariant:
        case gamedataMappinVariant.ClientInDistressVariant:
        //case gamedataMappinVariant.FixerVariant:
        case gamedataMappinVariant.ThieveryVariant:
        case gamedataMappinVariant.Zzz06_NCPDGigVariant:
        case gamedataMappinVariant.Zzz18_RacingVariant:
        case gamedataMappinVariant.Zzz09_CourierSandboxActivityVariant:
          ArrayPush(gigControllers,controller); 
          break;
      } 

    }
    
       
    i+=1;
  }
  if Equals(type,RandomMappinType.Mappin_NCPD)
  {
    let rand = RandRange(0,ArraySize(ncpdControllers));
    let randMappin = ncpdControllers[rand];
    //this.UnselectMappin();
    //this.SetSelectedMappin(randMappin);
    //this.TryTrackQuestOrSetWaypoint();
    
    this.PlaySound(n"MapPin", n"OnEnable");
    this.TrackMappin(randMappin);
  }
  if Equals(type,RandomMappinType.Mappin_Gig)
  {
    let rand = RandRange(0,ArraySize(gigControllers));
    let randMappin = gigControllers[rand];
    //this.UnselectMappin();
    //this.SetSelectedMappin(randMappin);
    //this.TryTrackQuestOrSetWaypoint();
    //this.TrackMappin(randMappin);
    
    this.PlaySound(n"MapPin", n"OnEnable");
    this.TrackQuestMappin(randMappin);

  }
}

@addMethod(WorldMapMenuGameController)
private func SelectClosestMappin(type:RandomMappinType)
{
  let container = this.GetSpawnContainer();
  let numChildren = container.GetNumChildren();
  let closestNCPDController : ref<BaseWorldMapMappinController>;
  let closestNCPDDistance: Float = -1.0;
  let closestGigController : ref<BaseWorldMapMappinController>;
  let closestGigDistance :Float = -1.0;
  let i = 0;

  while i < numChildren {
    let child = container.GetWidgetByIndex(i) as inkCompoundWidget;
    let controller = child.GetController() as BaseWorldMapMappinController;
    let mappinVariant = controller.m_mappin.GetVariant();
    if !controller.m_mappin.IsPlayerTracked() && NotEquals(controller.m_mappin.GetPhase(),gamedataMappinPhase.CompletedPhase)
    {
      switch mappinVariant
      {
        case gamedataMappinVariant.GangWatchVariant:
        case gamedataMappinVariant.HiddenStashVariant:
        case gamedataMappinVariant.OutpostVariant:
          if closestNCPDDistance < 0.0 || controller.GetDistanceToPlayer()<closestNCPDDistance
          {
            closestNCPDDistance = controller.GetDistanceToPlayer();
            closestNCPDController = controller;
          }
          break;
        case gamedataMappinVariant.QuestGiverVariant:
        case gamedataMappinVariant.BountyHuntVariant:
        case gamedataMappinVariant.SabotageVariant:
        case gamedataMappinVariant.RetrievingVariant:
        case gamedataMappinVariant.ClientInDistressVariant:
        //case gamedataMappinVariant.FixerVariant:
        case gamedataMappinVariant.ThieveryVariant:
        case gamedataMappinVariant.Zzz06_NCPDGigVariant:
        case gamedataMappinVariant.Zzz18_RacingVariant:
        case gamedataMappinVariant.Zzz09_CourierSandboxActivityVariant:
          if closestGigDistance < 0.0 || controller.GetDistanceToPlayer()<closestGigDistance
          {
            closestGigDistance = controller.GetDistanceToPlayer();
            closestGigController = controller;
          }
          break;
      } 
    }
    i+=1;
  }
  if Equals(type,RandomMappinType.Mappin_NCPD)
  {
    
    this.PlaySound(n"MapPin", n"OnEnable");
    this.TrackMappin(closestNCPDController);
  }
  if Equals(type,RandomMappinType.Mappin_Gig)
  {
    
    this.PlaySound(n"MapPin", n"OnEnable");
    this.TrackQuestMappin(closestGigController);

  }
}

@addMethod(WorldMapMenuGameController)
private final func AddInputHint(out evt: ref<UpdateInputHintMultipleEvent>, show: Bool, action: CName, label: String, out priority: Int32) -> Void {
  let data: InputHintData;
  data.action = action;
  data.source = n"WorldMap";
  data.localizedLabel = label;
  data.sortingPriority = priority;
  data.queuePriority = priority;
  evt.AddInputHint(data, show);
  priority += 1;
}

@addMethod(WorldMapMenuGameController)
private final func AddAnimatedInputHint(out evt: ref<UpdateInputHintMultipleEvent>, show: Bool, action: CName, label: String, out priority: Int32)
{
  let data: InputHintData;
  data.action = action;
  data.source = n"WorldMap";
  data.localizedLabel = label;
  data.sortingPriority = priority;
  data.queuePriority = priority;
  data.enableHoldAnimation = true;
  data.holdIndicationType = inkInputHintHoldIndicationType.Hold;
  evt.AddInputHint(data, show);
  priority += 1;
}

@addMethod(WorldMapMenuGameController)
private func SelectMappin(mappinType:RandomMappinType)
{
  let jobRandomizerSelection:JobSelectionType;
  if Equals(mappinType,RandomMappinType.Mappin_Gig)
  {
    jobRandomizerSelection = this.jobRandomizerSetting.GetGigSelectionType();
  }
  else
  {
    if Equals(mappinType,RandomMappinType.Mappin_NCPD)
    {
      jobRandomizerSelection = this.jobRandomizerSetting.GetNCPDSelectionType();
    }
  }
  //let jobRandomizerSelection = this.jobRandomizerSetting.GetGigSelectionType();
  //Debug(s"WorldMapMenuGameController SelectMappin jobRandomizerSelection: \(jobRandomizerSelection)");
  this.randomMappinSelected = true;
  switch jobRandomizerSelection
  {
    case JobSelectionType.Random:
      this.SelectRandomMappin(mappinType);
      break;
    case JobSelectionType.DistanceRandom:
      this.SelectAreaWeightedRandomMappin(mappinType);
      break;
    case JobSelectionType.Distance:
      this.SelectClosestMappin(mappinType);
  }
}

@wrapMethod(WorldMapMenuGameController)
protected cb func OnInitialize() -> Bool {
  wrappedMethod();
  this.jobRandomizerSetting = new JobRandomizerSettings();
  
  this.controllerSupport = this.jobRandomizerSetting.HasControllerSupport();
}

@wrapMethod(WorldMapMenuGameController)
private final func HandlePressInput(e: ref<inkPointerEvent>) -> Void {
  //LogChannel(n"DEBUG","WorldMapMenuGameController HandlePressInput");
  
  if this.controllerSupport
  {  
    if e.IsAction(n"call")||e.IsAction(n"run_benchmark")
    {
      this.randomMappinSelected = false;
    }

  }
  else
  {
    if e.IsAction(n"call")
    {
      this.SelectMappin(RandomMappinType.Mappin_NCPD);
    }
    if(e.IsAction(n"run_benchmark"))
    {
      this.SelectMappin(RandomMappinType.Mappin_Gig);
      //LogChannel(n"DEBUG","select gig");
    }
  }

  wrappedMethod(e);
}


@wrapMethod(WorldMapMenuGameController)
private final func HandleReleaseInput(e: ref<inkPointerEvent>) -> Void {

  if this.controllerSupport
  {
      if (e.IsAction(n"world_map_menu_open_quest_static")||e.IsAction(n"open_map_link")||e.IsAction(n"world_map_menu_open_quest")||e.IsAction(n"world_map_menu_toggle_custom_filter"))
      {
        if this.randomMappinSelected
        {
          return;
        }
      }
  }
  wrappedMethod(e);
}

@wrapMethod(WorldMapMenuGameController)
private final func HandleHoldInput(e: ref<inkPointerEvent>) -> Void {

  let holdProgress: Float;
  if (e.IsAction(n"world_map_menu_fast_travel")||!this.controllerSupport) {
    wrappedMethod(e);
  }
  else
  {
    holdProgress = e.GetHoldProgress();
    if holdProgress < 1.00 {
      return;
    };

    if(e.IsAction(n"call"))
    {
     
      //LogChannel(n"DEBUG",s"WorldMapMenuGameController HandleHoldInput Select Random NCPD");
      //this.SelectRandomMappin(RandomMappinType.Mappin_NCPD);
      this.SelectMappin(RandomMappinType.Mappin_NCPD);
      
    }
    else
    {
      if(e.IsAction(n"run_benchmark"))
      {
        //LogChannel(n"DEBUG",s"WorldMapMenuGameController HandleHoldInput Run Benchmark Progress: \(e.GetHoldProgress())");
        this.SelectMappin(RandomMappinType.Mappin_Gig);
      } 
    }
  
  }
}


@wrapMethod(WorldMapMenuGameController)
private final func RefreshInputHints() -> Void {
  this.hintPriority = 1;
  wrappedMethod();
  let evt: ref<UpdateInputHintMultipleEvent> = new UpdateInputHintMultipleEvent();
  evt.targetHintContainer = n"WorldMapInputHints";
  if this.controllerSupport
  {
    this.AddAnimatedInputHint(evt, true, n"run_benchmark", "Track Random Gigs", this.hintPriority);
    this.AddAnimatedInputHint(evt, true, n"call", "Track Random NCPD-Scanner", this.hintPriority);

  }
  else
  {
    this.AddInputHint(evt, true, n"run_benchmark", "Track Random Gigs", this.hintPriority);
    this.AddInputHint(evt, true, n"call", "Track Random NCPD-Scanner", this.hintPriority);
  }
  this.QueueEvent(evt);
}

@wrapMethod(WorldMapMenuGameController)
protected final func AddInputHintUpdate(out evt: ref<UpdateInputHintMultipleEvent>, show: Bool, action: CName, const locKey: script_ref<String>, out priority: Int32) -> Void {
  wrappedMethod(evt,show,action, locKey, priority);
  this.hintPriority +=1;
}

