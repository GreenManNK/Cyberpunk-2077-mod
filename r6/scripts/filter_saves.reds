module FilterSaves

// CUSTOM FUNCS AND TYPES

public func GetLifepathFilterButtonAction() -> CName { return n"world_map_menu_cycle_filter_next"; }

public func GetSaveTypeFilterButtonAction() -> CName { return n"world_map_menu_cycle_filter_prev"; }

class FilterSavesConfig {
  public static func RememberType() -> Bool = false
  public static func RememberLifepath() -> Bool = false
  public static func SaveTypeFilter(filter: SaveTypeFilter) -> Void {}
  public static func SaveLifepathFilter(filter: LifePathFilter) -> Void {}
  public static func GetSavedTypeFilter() -> SaveTypeFilter { return SaveTypeFilter.All; }
  public static func GetSavedLifepathFilter() -> LifePathFilter { return LifePathFilter.All; }
}

public func GetLifepathFilterText(filter: LifePathFilter) -> String {
  let choice: String = "";
  switch filter {
    case LifePathFilter.All:
      choice = GetLocalizedText("LocKey#45642"); // "Show All"
      break;
    case LifePathFilter.Corpo:
      choice = GetLocalizedText("LocKey#1800"); // "Corpo"
      break;
    case LifePathFilter.Nomad:
      choice = GetLocalizedText("LocKey#1799"); // "Nomad"
      break;
    case LifePathFilter.StreetKid:
      choice = GetLocalizedText("LocKey#1801"); // "StreetKid"
      break;
    case LifePathFilter.Invalid:
      choice = GetLocalizedText("LocKey#3178953369"); // "Fresh Start"
      break;
    default:
      break;
  }
  // Lifepath Filter: choice
  return GetLocalizedText("LocKey#46336") + " " + GetLocalizedText("LocKey#15393") + ": " + choice + "";
}

public func GetSaveTypeFilterText(filter: SaveTypeFilter) -> String {
  let choice: String = "";
  switch filter {
    case SaveTypeFilter.All:
      choice = GetLocalizedText("LocKey#45642"); // "Show All"
      break;
    case SaveTypeFilter.AutoSaves:
      choice = GetLocalizedText("LocKey#50915"); // "AutoSave-"
      break;
    case SaveTypeFilter.QuickSaves:
      choice = GetLocalizedText("LocKey#50914"); // "Quicksave"
      break;
    case SaveTypeFilter.ManualSaves:
      choice = GetLocalizedText("LocKey#50913"); // "ManualSave-"
      break;
    case SaveTypeFilter.PointOfNoReturn:
      choice = GetLocalizedText("LocKey#76974"); // "PointOfNoReturn-"
      break;
    // case SaveTypeFilter.EndGameSave:
    //   choice = GetLocalizedText("LocKey#76975"); // "EndGameSave-"
    //   break;
    default:
      break;
  }

  // Type Filter: choice
  return GetLocalizedText("LocKey#22100") + " " + GetLocalizedText("LocKey#15393") + ": " + StrReplace(choice, "-", "");
}

enum LifePathFilter {
  All = 0,
  Corpo = 1,
  Nomad = 2,
  StreetKid = 3,
  Invalid = 4
}

enum SaveTypeFilter {
  All = 0,
  ManualSaves = 1,
  QuickSaves = 2,
  AutoSaves = 3,
  PointOfNoReturn = 4,
  // EndGameSave = 5
}

public func IsFreshStartInstalled() -> Bool {
  let newStart: ref<LifePath_Record> = TweakDBInterface.GetLifePathRecord(t"LifePaths.NewStart");
  return IsDefined(newStart);
}

// LOAD MENU

@addField(LoadGameMenuGameController)
private let m_saveTypeFilter: SaveTypeFilter;

@addField(LoadGameMenuGameController)
private let m_lifePathFilter: LifePathFilter;

@addField(LoadGameMenuGameController)
private let freshStartInstalled: Bool;

@wrapMethod(LoadGameMenuGameController)
protected cb func OnInitialize() -> Bool {
  this.m_lifePathFilter = FilterSavesConfig.RememberLifepath() ? FilterSavesConfig.GetSavedLifepathFilter() : LifePathFilter.All;
  this.m_saveTypeFilter = FilterSavesConfig.RememberType() ? FilterSavesConfig.GetSavedTypeFilter() : SaveTypeFilter.All;
  this.freshStartInstalled = IsFreshStartInstalled();

  wrappedMethod();
}

@wrapMethod(LoadGameMenuGameController)
private final func UpdateButtonHints(savesCount: Int32) -> Void {
  wrappedMethod(savesCount);
  if savesCount > 0 {
    this.m_buttonHintsController.AddButtonHint(GetLifepathFilterButtonAction(), GetLifepathFilterText(this.m_lifePathFilter));
    this.m_buttonHintsController.AddButtonHint(GetSaveTypeFilterButtonAction(), GetSaveTypeFilterText(this.m_saveTypeFilter));
  }
}

@wrapMethod(LoadGameMenuGameController)
protected cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
  if evt.IsAction(GetLifepathFilterButtonAction()) {
    if this.freshStartInstalled {
      this.m_lifePathFilter = IntEnum((EnumInt(this.m_lifePathFilter) + 1) % (Cast<Int32>(EnumGetMax(n"FilterSaves.LifePathFilter")) + 1));
    }
    else {
      this.m_lifePathFilter = IntEnum((EnumInt(this.m_lifePathFilter) + 1) % (Cast<Int32>(EnumGetMax(n"FilterSaves.LifePathFilter"))));
    }
    FilterSavesConfig.SaveLifepathFilter(this.m_lifePathFilter);
    this.UpdateButtonHints(inkCompoundRef.GetNumChildren(this.m_list));
    this.UpdateListItemVisibilities();
  }
  if evt.IsAction(GetSaveTypeFilterButtonAction()) {
    this.m_saveTypeFilter = IntEnum((EnumInt(this.m_saveTypeFilter) + 1) % (Cast<Int32>(EnumGetMax(n"FilterSaves.SaveTypeFilter")) + 1));
    FilterSavesConfig.SaveTypeFilter(this.m_saveTypeFilter);
    this.UpdateButtonHints(inkCompoundRef.GetNumChildren(this.m_list));
    this.UpdateListItemVisibilities();
  }

  wrappedMethod(evt);
}

@addMethod(LoadGameMenuGameController)
private func UpdateListItemVisibilities() -> Void {
  let button: wref<inkWidget>;
  let controller: wref<LoadListItem>;
  let i: Int32 = 0;
  while i < inkCompoundRef.GetNumChildren(this.m_list) {
    button = inkCompoundRef.GetWidgetByIndex(this.m_list, i);
    controller = button.GetController() as LoadListItem;
    if controller.UpdateVisibility(this.m_lifePathFilter, this.m_saveTypeFilter) {
      this.GetSystemRequestsHandler().RequestSavedGameScreenshot(i, controller.GetPreviewImageWidget());
    }
    i += 1;
  }
}

@wrapMethod(LoadGameMenuGameController)
protected cb func OnSaveMetadataReady(info: ref<SaveMetadataInfo>) -> Bool {
  wrappedMethod(info);
  this.UpdateListItemVisibilities();
}

// SAVE MENU

@addField(SaveGameMenuGameController)
private let m_lifePathFilter: LifePathFilter;

@addField(SaveGameMenuGameController)
private let freshStartInstalled: Bool;

@wrapMethod(SaveGameMenuGameController)
protected cb func OnInitialize() -> Bool {
  wrappedMethod();

  this.RegisterToGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
  this.m_buttonHintsController.AddButtonHint(GetLifepathFilterButtonAction(), GetLifepathFilterText(LifePathFilter.All));
  this.m_lifePathFilter = FilterSavesConfig.RememberLifepath() ? FilterSavesConfig.GetSavedLifepathFilter() : LifePathFilter.All;
  this.freshStartInstalled = IsFreshStartInstalled();

  this.RefreshButtonHints();
}

@wrapMethod(SaveGameMenuGameController)
protected cb func OnUninitialize() -> Bool {
  this.UnregisterFromGlobalInputCallback(n"OnPostOnRelease", this, n"OnButtonRelease");
  wrappedMethod();
}

@addMethod(SaveGameMenuGameController)
private func RefreshButtonHints() -> Void {
  this.m_buttonHintsController.AddButtonHint(n"back", GetLocalizedText("Common-Access-Close"));
  this.m_buttonHintsController.AddButtonHint(n"delete_save", GetLocalizedText("UI-Menus-DeleteSave"));
  this.m_buttonHintsController.AddButtonHint(n"select", GetLocalizedText("UI-UserActions-Select"));
  this.m_buttonHintsController.AddButtonHint(GetLifepathFilterButtonAction(), GetLifepathFilterText(this.m_lifePathFilter));
}

@wrapMethod(SaveGameMenuGameController)
protected cb func OnButtonRelease(evt: ref<inkPointerEvent>) -> Bool {
  wrappedMethod(evt);
  if evt.IsAction(GetLifepathFilterButtonAction()) {
    if this.freshStartInstalled {
      this.m_lifePathFilter = IntEnum((EnumInt(this.m_lifePathFilter) + 1) % (Cast<Int32>(EnumGetMax(n"FilterSaves.LifePathFilter")) + 1));
    }
    else {
      this.m_lifePathFilter = IntEnum((EnumInt(this.m_lifePathFilter) + 1) % (Cast<Int32>(EnumGetMax(n"FilterSaves.LifePathFilter"))));
    }
    FilterSavesConfig.SaveLifepathFilter(this.m_lifePathFilter);
    this.RefreshButtonHints();
    this.UpdateListItemVisibilities();
  }
}

@addMethod(SaveGameMenuGameController)
private func UpdateListItemVisibilities() -> Void {
  let button: wref<inkWidget>;
  let controller: wref<LoadListItem>;
  let i: Int32 = 0;
  while i < inkCompoundRef.GetNumChildren(this.m_list) {
    button = inkCompoundRef.GetWidgetByIndex(this.m_list, i);
    controller = button.GetController() as LoadListItem;
    if controller.UpdateVisibility(this.m_lifePathFilter, SaveTypeFilter.All) {
      this.GetSystemRequestsHandler().RequestSavedGameScreenshot(i, controller.GetPreviewImageWidget());
    }
    i += 1;
  }
}

@wrapMethod(SaveGameMenuGameController)
protected cb func OnSaveMetadataReady(info: ref<SaveMetadataInfo>) -> Bool {
  wrappedMethod(info);
  this.UpdateListItemVisibilities();
}

// LOAD/SAVE LIST

@addField(LoadListItem)
let m_lifePathFilter: LifePathFilter;

@addField(LoadListItem)
let m_saveTypeFilter: SaveTypeFilter;

@wrapMethod(LoadListItem)
protected cb func OnInitialize() -> Bool {
  wrappedMethod();
  this.m_rootWidget.SetAffectsLayoutWhenHidden(false);
  this.m_lifePathFilter = LifePathFilter.All;
  this.m_saveTypeFilter = SaveTypeFilter.All;
}

@wrapMethod(LoadListItem)
public final func SetMetadata(metadata: ref<SaveMetadataInfo>, opt isEp1Enabled: Bool) -> Void {
  wrappedMethod(metadata, isEp1Enabled);

  switch metadata.lifePath {
    case inkLifePath.Corporate:
      this.m_lifePathFilter = LifePathFilter.Corpo;
      break;
    case inkLifePath.Nomad:
      this.m_lifePathFilter = LifePathFilter.Nomad;
      break;
    case inkLifePath.StreetKid:
      this.m_lifePathFilter = LifePathFilter.StreetKid;
      break;
    case inkLifePath.Invalid:
      this.m_lifePathFilter = LifePathFilter.Invalid;
      break;
    default:
      break;
  }
  
  switch metadata.saveType {
    case inkSaveType.ManualSave:
      this.m_saveTypeFilter = SaveTypeFilter.ManualSaves;
      break;
    case inkSaveType.QuickSave:
      this.m_saveTypeFilter = SaveTypeFilter.QuickSaves;
      break;
    case inkSaveType.AutoSave:
      this.m_saveTypeFilter = SaveTypeFilter.AutoSaves;
      break;
    case inkSaveType.PointOfNoReturn:
      this.m_saveTypeFilter = SaveTypeFilter.PointOfNoReturn;
      break;
    // case inkSaveType.EndGameSave:
    //   this.m_saveTypeFilter = SaveTypeFilter.EndGameSave;
    //   break;
    default:
      break;
  }
}

@addMethod(LoadListItem)
public func UpdateVisibility(lifePathFilter: LifePathFilter, saveTypeFilter: SaveTypeFilter) -> Bool {
  if this.m_emptySlot {
    return false;
  }

  let wasVisible: Bool = this.m_rootWidget.IsVisible();
  let shouldHide: Bool = false;

  if !Equals(lifePathFilter, this.m_lifePathFilter) && !Equals(lifePathFilter, LifePathFilter.All) {
    shouldHide = true;
  }

  if !Equals(saveTypeFilter, this.m_saveTypeFilter) && !Equals(saveTypeFilter, SaveTypeFilter.All) {
    shouldHide = true;
  }

  // return true if this item is going to be displayed and should have image loaded
  this.m_rootWidget.SetVisible(!shouldHide);
  return !wasVisible && !shouldHide;
}


// LocKey#15393 : UI-ResourceExports-Filter = Filter
// LocKey#46336 : Story-base-quest-side_quests-sq029-scenes-sq029_xx_debug-sq029_xx_ch_lifepath_displayNameOverride = Lifepath
// 22100 - UI-Sorting-ItemType = Type
// 45642 - UI-Menus-WorldMap-Filter-All = Show All

// 1799 - Gameplay-LifePaths-Nomad = Nomad
// 1800 - Gameplay-LifePaths-Corporate = Corpo
// 1801 - Gameplay-LifePaths-Streetkid = StreetKid

// 50913 - UI-Menus-Saving-ManualSave
// 50914	UI-Menus-Saving-QuickSave	QuickSave-
// 50915 - UI-Menus-Saving-AutoSave
// 76974	UI-Menus-Saving-PointOfNoReturn	PointOfNoReturn-
// 76975	UI-Menus-Saving-EndGameSave	EndGameSave-