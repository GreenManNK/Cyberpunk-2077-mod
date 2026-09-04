// RedFileSystem v0.15.1
module RedFileSystem

@if(ModuleExists("RedData.Json"))
import RedData.Json.*

public native class AsyncFile {
  public native func GetPath() -> String;
  public native func GetAbsolutePath() -> String;
  public native func GetFilename() -> String;
  public native func GetExtension() -> String;
  public native func GetSize() -> Uint64;
  public native func ReadAsText(promise: FilePromise) -> Void;
  public native func ReadAsBase64(promise: FilePromise) -> Void;
  public native func ReadAsLines(promise: FilePromise) -> Void;
  @if(ModuleExists("RedData.Json"))
  public native func ReadAsJson(promise: FilePromise) -> Void;
  public native func WriteText(promise: FilePromise, text: String, opt mode: FileSystemWriteMode) -> Void;
  public native func WriteLines(promise: FilePromise, lines: array<String>, opt mode: FileSystemWriteMode) -> Void;
  @if(ModuleExists("RedData.Json"))
  public native func WriteJson(promise: FilePromise, json: ref<JsonVariant>, opt indent: String) -> Void;
}
public native class File {
  public native func GetPath() -> String;
  public native func GetAbsolutePath() -> String;
  public native func GetFilename() -> String;
  public native func GetExtension() -> String;
  public native func GetSize() -> Uint64;
  public native func ReadAsText() -> String;
  public native func ReadAsBase64() -> String;
  public native func ReadAsLines() -> array<String>;
  @if(ModuleExists("RedData.Json"))
  public native func ReadAsJson() -> ref<JsonVariant>;
  public native func WriteText(text: String, opt mode: FileSystemWriteMode) -> Bool;
  public native func WriteLines(lines: array<String>, opt mode: FileSystemWriteMode) -> Bool;
  @if(ModuleExists("RedData.Json"))
  public native func WriteJson(json: ref<JsonVariant>, opt indent: String) -> Bool;
}
public native struct FilePromise {
  public native let target: wref<IScriptable>;
  public native let resolve: CName;
  public native let reject: CName;
  public native let data: array<Variant>;
  public static func Create(target: wref<IScriptable>, resolve: CName, opt reject: CName, opt data: array<Variant>) -> FilePromise {
    let self: FilePromise;
    self.target = target;
    self.resolve = resolve;
    self.reject = reject;
    self.data = data;
    return self;
  }
}
public native class FileSystem {
  public static native func GetStorage(name: String) -> ref<FileSystemStorage>;
  public static native func GetSharedStorage() -> ref<FileSystemStorage>;
}
public enum FileSystemStatus {
  True    = 0,
  False   = 1,
  Failure = 2,
  Denied  = 3
}
public native class FileSystemStorage {
  public native func Exists(path: String) -> FileSystemStatus;
  public native func IsFile(path: String) -> FileSystemStatus;
  public native func GetFile(path: String) -> ref<File>;
  public native func GetFiles() -> array<ref<File>>;
  public native func DeleteFile(path: String) -> FileSystemStatus;
  public native func GetAsyncFile(path: String) -> ref<AsyncFile>;
  public native func GetAsyncFiles() -> array<ref<AsyncFile>>;
}
public enum FileSystemWriteMode {
  Truncate  = 0,
  Append    = 1
}
