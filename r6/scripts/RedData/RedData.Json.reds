// RedData v0.10.1
module RedData.Json

public native func ParseJson(text: String) -> ref<JsonVariant>;
public native func FromJson(json: ref<JsonObject>, type: CName) -> ref<IScriptable>;
public native func ToJson(object: ref<IScriptable>) -> ref<JsonObject>;
public native class JsonArray extends JsonVariant {
  public native func GetSize() -> Uint32;
  public native func GetItem(index: Uint32) -> ref<JsonVariant>;
  public native func SetItem(index: Uint32, value: ref<JsonVariant>) -> Void;
  public native func RemoveItem(index: Uint32) -> Bool;
  public native func AddItem(value: ref<JsonVariant>) -> Void;
  public native func InsertItem(index: Uint32, value: ref<JsonVariant>) -> Void;
  public native func GetItemBool(index: Uint32) -> Bool;
  public native func GetItemInt64(index: Uint32) -> Int64;
  public native func GetItemUint64(index: Uint32) -> Uint64;
  public native func GetItemDouble(index: Uint32) -> Double;
  public native func GetItemString(index: Uint32) -> String;
  public native func SetItemNull(index: Uint32) -> Void;
  public native func SetItemBool(index: Uint32, value: Bool) -> Void;
  public native func SetItemInt64(index: Uint32, value: Int64) -> Void;
  public native func SetItemUint64(index: Uint32, value: Uint64) -> Void;
  public native func SetItemDouble(index: Uint32, value: Double) -> Void;
  public native func SetItemString(index: Uint32, value: String) -> Void;
  public native func AddItemNull() -> Void;
  public native func AddItemBool(value: Bool) -> Void;
  public native func AddItemInt64(value: Int64) -> Void;
  public native func AddItemUint64(value: Uint64) -> Void;
  public native func AddItemDouble(value: Double) -> Void;
  public native func AddItemString(value: String) -> Void;
  public native func InsertItemNull(index: Uint32) -> Void;
  public native func InsertItemBool(index: Uint32, value: Bool) -> Void;
  public native func InsertItemInt64(index: Uint32, value: Int64) -> Void;
  public native func InsertItemUint64(index: Uint32, value: Uint64) -> Void;
  public native func InsertItemDouble(index: Uint32, value: Double) -> Void;
  public native func InsertItemString(index: Uint32, value: String) -> Void;
  public native func Clear() -> Void;
}
public native class JsonObject extends JsonVariant {
  public native func GetKeys() -> array<String>;
  public native func GetValues() -> array<ref<JsonVariant>>;
  public native func HasKey(key: String) -> Bool;
  public native func GetKey(key: String) -> ref<JsonVariant>;
  public native func SetKey(key: String, value: ref<JsonVariant>) -> Void;
  public native func RemoveKey(key: String) -> Bool;
  public native func GetKeyBool(key: String) -> Bool;
  public native func GetKeyInt64(key: String) -> Int64;
  public native func GetKeyUint64(key: String) -> Uint64;
  public native func GetKeyDouble(key: String) -> Double;
  public native func GetKeyString(key: String) -> String;
  public native func SetKeyNull(key: String) -> Void;
  public native func SetKeyBool(key: String, value: Bool) -> Void;
  public native func SetKeyInt64(key: String, value: Int64) -> Void;
  public native func SetKeyUint64(key: String, value: Uint64) -> Void;
  public native func SetKeyDouble(key: String, value: Double) -> Void;
  public native func SetKeyString(key: String, value: String) -> Void;
  public native func Clear() -> Void;
}
public abstract native class JsonVariant {
  public native func IsUndefined() -> Bool;
  public native func IsNull() -> Bool;
  public native func IsBool() -> Bool;
  public native func IsInt64() -> Bool;
  public native func IsUint64() -> Bool;
  public native func IsDouble() -> Bool;
  public native func IsString() -> Bool;
  public native func IsArray() -> Bool;
  public native func IsObject() -> Bool;
  public native func GetBool() -> Bool;
  public native func GetInt64() -> Int64;
  public native func GetUint64() -> Uint64;
  public native func GetDouble() -> Double;
  public native func GetString() -> String;
  public native func ToString(opt indent: String) -> String;
}
