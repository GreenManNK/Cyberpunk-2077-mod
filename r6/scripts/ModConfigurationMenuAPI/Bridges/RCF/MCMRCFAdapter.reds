@if(ModuleExists("RedscriptConfigFramework"))
import RedscriptConfigFramework.*
@if(ModuleExists("RedscriptConfigFramework"))
import Codeware.Localization.*
@if(ModuleExists("RedscriptConfigFramework"))
import RedFileSystem.*
@if(ModuleExists("RedscriptConfigFramework"))
import RedData.Json.*

public class MCMRCFBridgeModRecord {
  public let id: String;
  public let name: String;
  public let description: String;
}

public class MCMRCFBridgeRowRecord {
  public let kind: Int32;
  public let key: String;
  public let label: String;
  public let tooltip: String;
  public let minValue: Float;
  public let maxValue: Float;
  public let stepValue: Float;
  public let isInt: Bool;
  public let boolValue: Bool;
  public let intValue: Int32;
  public let floatValue: Float;
  public let hasDefault: Bool;
  public let defaultTemporarilyUnavailable: Bool;
  public let defaultBoolValue: Bool;
  public let defaultIntValue: Int32;
  public let defaultFloatValue: Float;
  public let keyValue: String;
  public let defaultKeyValue: String;
  public let localOnly: Bool;
  public let pad: Bool;
  public let anyDevice: Bool;
  public let options: array<String>;
}

public class MCMRCFBridgeCategoryRecord {
  public let id: String;
  public let name: String;
  public let rows: array<ref<MCMRCFBridgeRowRecord>>;
}

@if(ModuleExists("RedscriptConfigFramework"))
public abstract class MCMRCFAdapter {
  private static func Registry() -> ref<DVRCF_Registry> {
    let gi: GameInstance = GetGameInstance();
    return DVRCF_Registry.Get(gi);
  }

  private static func Entry(modId: String) -> ref<DVRCF_RegistryEntry> {
    let registry: ref<DVRCF_Registry> = MCMRCFAdapter.Registry();
    return IsDefined(registry) ? registry.GetEntry(modId) : null;
  }

  public static func IsAvailable() -> Bool {
    return IsDefined(MCMRCFAdapter.Registry());
  }

  public static func PrepareRegistry() -> Bool {
    let gi: GameInstance = GetGameInstance();
    let registry: ref<DVRCF_Registry> = DVRCF_Registry.Get(gi);
    if !IsDefined(registry) {
      return false;
    };

    DVRCF_SchemaCache.RegisterCached(gi);
    return true;
  }

  private static func IsNativeEntry(entry: ref<DVRCF_RegistryEntry>) -> Bool {
    return IsDefined(entry)
      && IsDefined(entry.provider)
      && entry.source == 0
      && !entry.ownsPersistence;
  }

  public static func GetRevision() -> Uint32 {
    let registry: ref<DVRCF_Registry> = MCMRCFAdapter.Registry();
    if !IsDefined(registry) {
      return 0u;
    };

    let entries: array<ref<DVRCF_RegistryEntry>> = registry.GetEntries();
    let revision: Uint32 = 0u;
    let i: Int32 = 0;
    while i < ArraySize(entries) {
      if MCMRCFAdapter.IsNativeEntry(entries[i]) {
        revision = revision + 1u;
      };
      i += 1;
    };
    return revision;
  }

  public static func GetMods() -> array<ref<MCMRCFBridgeModRecord>> {
    let out: array<ref<MCMRCFBridgeModRecord>>;
    let registry: ref<DVRCF_Registry> = MCMRCFAdapter.Registry();
    if !IsDefined(registry) {
      return out;
    };

    let entries: array<ref<DVRCF_RegistryEntry>> = registry.GetEntries();
    let i: Int32 = 0;
    while i < ArraySize(entries) {
      if MCMRCFAdapter.IsNativeEntry(entries[i]) {
        let record: ref<MCMRCFBridgeModRecord> = new MCMRCFBridgeModRecord();
        record.id = entries[i].modId;
        record.name = MCMRCFAdapter.Localize(entries[i].displayName);
        record.description = MCMRCFAdapter.Localize(entries[i].description);
        ArrayPush(out, record);
      };
      i += 1;
    };
    return out;
  }

  public static func GetCategories(modId: String) -> array<ref<MCMRCFBridgeCategoryRecord>> {
    let out: array<ref<MCMRCFBridgeCategoryRecord>>;
    let entry: ref<DVRCF_RegistryEntry> = MCMRCFAdapter.Entry(modId);
    if !IsDefined(entry) || !IsDefined(entry.provider) {
      return out;
    };

    let schema: ref<DVRCF_Schema> = entry.provider.BuildSchema();
    if !IsDefined(schema) {
      return out;
    };
    let defaults: ref<JsonObject> = MCMRCFAdapter.Defaults(modId);

    let tabIndex: Int32 = 0;
    while tabIndex < ArraySize(schema.tabs) {
      let tab: ref<DVRCF_Tab> = schema.tabs[tabIndex];
      if IsDefined(tab) {
        let sectionIndex: Int32 = 0;
        while sectionIndex < ArraySize(tab.sections) {
          let section: ref<DVRCF_Section> = tab.sections[sectionIndex];
          if IsDefined(section) {
            let category: ref<MCMRCFBridgeCategoryRecord> = new MCMRCFBridgeCategoryRecord();
            category.id = MCMRCFAdapter.CategoryId(tabIndex, sectionIndex, tab.name, section.name);
            category.name = MCMRCFAdapter.CategoryName(
              MCMRCFAdapter.Localize(tab.name),
              MCMRCFAdapter.Localize(section.name)
            );
            category.rows = MCMRCFAdapter.Rows(entry.provider, section, defaults);
            ArrayPush(out, category);
          };
          sectionIndex += 1;
        };
      };
      tabIndex += 1;
    };
    return out;
  }

  public static func SetBool(modId: String, key: String, value: Bool) -> Bool {
    let entry: ref<DVRCF_RegistryEntry> = MCMRCFAdapter.Entry(modId);
    if !IsDefined(entry) || !IsDefined(entry.provider) {
      return false;
    };
    entry.provider.SetBool(key, value);
    return Equals(entry.provider.GetBool(key), value);
  }

  public static func SetInt(modId: String, key: String, value: Int32) -> Bool {
    let entry: ref<DVRCF_RegistryEntry> = MCMRCFAdapter.Entry(modId);
    if !IsDefined(entry) || !IsDefined(entry.provider) {
      return false;
    };
    entry.provider.SetInt(key, value);
    return Equals(entry.provider.GetInt(key), value);
  }

  public static func SetFloat(modId: String, key: String, value: Float) -> Bool {
    let entry: ref<DVRCF_RegistryEntry> = MCMRCFAdapter.Entry(modId);
    if !IsDefined(entry) || !IsDefined(entry.provider) {
      return false;
    };
    entry.provider.SetFloat(key, value);
    return Equals(entry.provider.GetFloat(key), value);
  }

  public static func SetKey(modId: String, key: String, value: String) -> Bool {
    let entry: ref<DVRCF_RegistryEntry> = MCMRCFAdapter.Entry(modId);
    if !IsDefined(entry) || !IsDefined(entry.provider) {
      return false;
    };

    let keyValue: Int64 = EnumValueFromString("EInputKey", value);
    if !Equals(NameToString(EnumValueToName(n"EInputKey", keyValue)), value) {
      return false;
    };

    let row: ref<DVRCF_Row> = MCMRCFAdapter.FindRow(entry.provider.BuildSchema(), key);
    if !IsDefined(row) || !Equals(row.kind, DVRCF_RowKind.Keybind) {
      return false;
    };

    let keyInt: Int32 = Cast<Int32>(keyValue);
    entry.provider.SetInt(key, keyInt);
    if !row.localOnly {
      DVRCF_Hotkeys.PushKey(key, entry.provider.GetInt(key));
    };
    return Equals(entry.provider.GetInt(key), keyInt);
  }

  public static func InvokeButton(modId: String, key: String) -> Bool {
    let entry: ref<DVRCF_RegistryEntry> = MCMRCFAdapter.Entry(modId);
    if !IsDefined(entry) || !IsDefined(entry.provider) {
      return false;
    };
    entry.provider.OnButton(key);
    return true;
  }

  public static func Commit(modId: String) -> Bool {
    let entry: ref<DVRCF_RegistryEntry> = MCMRCFAdapter.Entry(modId);
    if !IsDefined(entry) || !IsDefined(entry.provider) {
      return false;
    };
    let schema: ref<DVRCF_Schema> = entry.provider.BuildSchema();
    if !IsDefined(schema) {
      return false;
    };
    let gi: GameInstance = GetGameInstance();
    DVRCF_Store.PersistFrom(gi, modId, entry.provider, schema);
    entry.provider.OnSave();
    return true;
  }

  private static func Defaults(modId: String) -> ref<JsonObject> {
    let service: ref<DVRCF_StoreService> = GameInstance.GetScriptableServiceContainer().GetService(n"RedscriptConfigFramework.DVRCF_StoreService") as DVRCF_StoreService;
    if !IsDefined(service) {
      return null;
    };

    let storage: ref<FileSystemStorage> = service.GetStorage();
    if !IsDefined(storage) {
      return null;
    };

    let safeId: String = StrReplaceAll(modId, "/", "_");
    safeId = StrReplaceAll(safeId, "\\", "_");
    let fileName: String = safeId + ".defaults.json";
    if !Equals(storage.Exists(fileName), FileSystemStatus.True) {
      return null;
    };

    let file: ref<File> = storage.GetFile(fileName);
    return IsDefined(file) ? file.ReadAsJson() as JsonObject : null;
  }

  private static func IsValueRow(row: ref<DVRCF_Row>) -> Bool {
    return Equals(row.kind, DVRCF_RowKind.Toggle)
      || Equals(row.kind, DVRCF_RowKind.Dropdown)
      || Equals(row.kind, DVRCF_RowKind.Slider)
      || Equals(row.kind, DVRCF_RowKind.Stepper)
      || Equals(row.kind, DVRCF_RowKind.Keybind);
  }

  private static func Rows(provider: ref<DVRCF_Provider>, section: ref<DVRCF_Section>, defaults: ref<JsonObject>) -> array<ref<MCMRCFBridgeRowRecord>> {
    let out: array<ref<MCMRCFBridgeRowRecord>>;
    let i: Int32 = 0;
    while i < ArraySize(section.rows) {
      let row: ref<DVRCF_Row> = section.rows[i];
      if IsDefined(row) {
        let record: ref<MCMRCFBridgeRowRecord> = new MCMRCFBridgeRowRecord();
        record.kind = EnumInt(row.kind);
        record.key = row.key;
        record.label = MCMRCFAdapter.Localize(row.label);
        record.tooltip = MCMRCFAdapter.Localize(row.tooltip);
        record.minValue = row.minValue;
        record.maxValue = row.maxValue;
        record.stepValue = row.stepValue;
        record.isInt = row.isInt;
        record.localOnly = row.localOnly;
        record.pad = row.pad;
        record.anyDevice = row.anyDevice;
        record.options = row.options;
        record.hasDefault = MCMRCFAdapter.IsValueRow(row)
          && IsDefined(defaults)
          && defaults.HasKey(row.key);
        record.defaultTemporarilyUnavailable = MCMRCFAdapter.IsValueRow(row)
          && !record.hasDefault;

        if Equals(row.kind, DVRCF_RowKind.Toggle) {
          record.boolValue = provider.GetBool(row.key);
          if record.hasDefault {
            record.defaultBoolValue = defaults.GetKeyBool(row.key);
          };
        } else {
          if Equals(row.kind, DVRCF_RowKind.Dropdown) {
            record.intValue = provider.GetInt(row.key);
            if record.hasDefault {
              record.defaultIntValue = Cast<Int32>(defaults.GetKeyInt64(row.key));
            };
          } else {
            if Equals(row.kind, DVRCF_RowKind.Keybind) {
              record.keyValue = MCMRCFAdapter.KeyName(provider.GetInt(row.key));
              if record.hasDefault {
                record.defaultKeyValue = MCMRCFAdapter.KeyName(
                  Cast<Int32>(defaults.GetKeyInt64(row.key))
                );
              };
            } else {
              if Equals(row.kind, DVRCF_RowKind.Slider)
              || Equals(row.kind, DVRCF_RowKind.Stepper) {
                if row.isInt {
                  record.intValue = provider.GetInt(row.key);
                  if record.hasDefault {
                    record.defaultIntValue = Cast<Int32>(defaults.GetKeyInt64(row.key));
                  };
                } else {
                  record.floatValue = provider.GetFloat(row.key);
                  if record.hasDefault {
                    record.defaultFloatValue = Cast<Float>(defaults.GetKeyDouble(row.key));
                  };
                };
              };
            };
          };
        };
        ArrayPush(out, record);
      };
      i += 1;
    };
    return out;
  }

  private static func FindRow(schema: ref<DVRCF_Schema>, key: String) -> ref<DVRCF_Row> {
    if !IsDefined(schema) {
      return null;
    };

    let tabIndex: Int32 = 0;
    while tabIndex < ArraySize(schema.tabs) {
      let sectionIndex: Int32 = 0;
      while sectionIndex < ArraySize(schema.tabs[tabIndex].sections) {
        let rows: array<ref<DVRCF_Row>> = schema.tabs[tabIndex].sections[sectionIndex].rows;
        let rowIndex: Int32 = 0;
        while rowIndex < ArraySize(rows) {
          if IsDefined(rows[rowIndex]) && Equals(rows[rowIndex].key, key) {
            return rows[rowIndex];
          };
          rowIndex += 1;
        };
        sectionIndex += 1;
      };
      tabIndex += 1;
    };
    return null;
  }

  private static func KeyName(value: Int32) -> String {
    let name: String = NameToString(EnumValueToName(n"EInputKey", Cast<Int64>(value)));
    return StrLen(name) > 0 ? name : "IK_None";
  }

  private static func CategoryName(tabName: String, sectionName: String) -> String {
    if StrLen(tabName) == 0 {
      return StrLen(sectionName) == 0 ? "General" : sectionName;
    };
    if StrLen(sectionName) == 0 || Equals(tabName, sectionName) {
      return tabName;
    };
    return tabName + " - " + sectionName;
  }

  private static func Localize(value: String) -> String {
    let localization: ref<LocalizationSystem> = LocalizationSystem.GetInstance(GetGameInstance());
    if !IsDefined(localization) {
      return value;
    };

    let localized: String = localization.GetText(value);
    return StrLen(localized) > 0 ? localized : value;
  }

  private static func CategoryId(tabIndex: Int32, sectionIndex: Int32, tabName: String, sectionName: String) -> String {
    return IntToString(tabIndex) + "_" + IntToString(sectionIndex);
  }
}
