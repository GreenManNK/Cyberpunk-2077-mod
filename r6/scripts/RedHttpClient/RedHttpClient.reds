// RedHttpClient v0.7.0
module RedHttpClient

@if(ModuleExists("RedData.Json"))
import RedData.Json.*

public native class AsyncHttpClient {
  public static native func Get(callback: HttpCallback, url: String, opt headers: array<HttpHeader>) -> Void;
  public static native func Post(callback: HttpCallback, url: String, body: String, opt headers: array<HttpHeader>) -> Void;
  public static native func PostForm(callback: HttpCallback, url: String, form: array<HttpPair>, opt headers: array<HttpHeader>) -> Void;
  public static native func PostMultipart(callback: HttpCallback, url: String, form: ref<HttpMultipart>, opt headers: array<HttpHeader>) -> Void;
  @if(ModuleExists("RedData.Json"))
  public static func PostJson(callback: HttpCallback, url: String, body: ref<JsonVariant>, opt headers: array<HttpHeader>) -> Void {
    let requestHeaders: array<HttpHeader> = [
      HttpHeader.Create("Content-Type", "application/json; charset=utf-8")
    ];
    for header in headers {
      if StrCmp(header.name, "Content-Type", -1, true) != 0 {
        ArrayPush(requestHeaders, header);
      }
    }
    AsyncHttpClient.Post(callback, url, body.ToString(), requestHeaders);
  }
  public static native func Put(callback: HttpCallback, url: String, body: String, opt headers: array<HttpHeader>) -> Void;
  public static native func PutForm(callback: HttpCallback, url: String, form: array<HttpPair>, opt headers: array<HttpHeader>) -> Void;
  public static native func PutMultipart(callback: HttpCallback, url: String, form: ref<HttpMultipart>, opt headers: array<HttpHeader>) -> Void;
  @if(ModuleExists("RedData.Json"))
  public static func PutJson(callback: HttpCallback, url: String, body: ref<JsonVariant>, opt headers: array<HttpHeader>) -> Void {
    let requestHeaders: array<HttpHeader> = [
      HttpHeader.Create("Content-Type", "application/json; charset=utf-8")
    ];
    for header in headers {
      if StrCmp(header.name, "Content-Type", -1, true) != 0 {
        ArrayPush(requestHeaders, header);
      }
    }
    AsyncHttpClient.Put(callback, url, body.ToString(), requestHeaders);
  }
  public static native func Patch(callback: HttpCallback, url: String, body: String, opt headers: array<HttpHeader>) -> Void;
  public static native func PatchForm(callback: HttpCallback, url: String, form: array<HttpPair>, opt headers: array<HttpHeader>) -> Void;
  public static native func PatchMultipart(callback: HttpCallback, url: String, form: ref<HttpMultipart>, opt headers: array<HttpHeader>) -> Void;
  @if(ModuleExists("RedData.Json"))
  public static func PatchJson(callback: HttpCallback, url: String, body: ref<JsonVariant>, opt headers: array<HttpHeader>) -> Void {
    let requestHeaders: array<HttpHeader> = [
      HttpHeader.Create("Content-Type", "application/json; charset=utf-8")
    ];
    for header in headers {
      if StrCmp(header.name, "Content-Type", -1, true) != 0 {
        ArrayPush(requestHeaders, header);
      }
    }
    AsyncHttpClient.Patch(callback, url, body.ToString(), requestHeaders);
  }
  public static native func Delete(callback: HttpCallback, url: String, opt body: String, opt headers: array<HttpHeader>) -> Void;
  public static native func DeleteForm(callback: HttpCallback, url: String, form: array<HttpPair>, opt headers: array<HttpHeader>) -> Void;
  public static native func DeleteMultipart(callback: HttpCallback, url: String, form: ref<HttpMultipart>, opt headers: array<HttpHeader>) -> Void;
  @if(ModuleExists("RedData.Json"))
  public static func DeleteJson(callback: HttpCallback, url: String, body: ref<JsonVariant>, opt headers: array<HttpHeader>) -> Void {
    let requestHeaders: array<HttpHeader> = [
      HttpHeader.Create("Content-Type", "application/json; charset=utf-8")
    ];
    for header in headers {
      if StrCmp(header.name, "Content-Type", -1, true) != 0 {
        ArrayPush(requestHeaders, header);
      }
    }
    AsyncHttpClient.Delete(callback, url, body.ToString(), requestHeaders);
  }
}
public native struct HttpCallback {
  public static func Create(target: wref<IScriptable>, function: CName, opt data: array<Variant>) -> HttpCallback {
    let self: HttpCallback;
    self.target = target;
    self.function = function;
    self.data = data;
    return self;
  }
  public native let target: wref<IScriptable>;
  public native let function: CName;
  public native let data: array<Variant>;
}
public native class HttpClient {
  public static native func Get(url: String, opt headers: array<HttpHeader>) -> ref<HttpResponse>;
  public static native func Post(url: String, body: String, opt headers: array<HttpHeader>) -> ref<HttpResponse>;
  public static native func PostForm(url: String, form: array<HttpPair>, opt headers: array<HttpHeader>) -> ref<HttpResponse>;
  public static native func PostMultipart(url: String, form: ref<HttpMultipart>, opt headers: array<HttpHeader>) -> ref<HttpResponse>;
  @if(ModuleExists("RedData.Json"))
  public static func PostJson(url: String, body: ref<JsonVariant>, opt headers: array<HttpHeader>) -> ref<HttpResponse> {
    let requestHeaders: array<HttpHeader> = [
      HttpHeader.Create("Content-Type", "application/json; charset=utf-8")
    ];
    for header in headers {
      if StrCmp(header.name, "Content-Type", -1, true) != 0 {
        ArrayPush(requestHeaders, header);
      }
    }
    return HttpClient.Post(url, body.ToString(), requestHeaders);
  }
  public static native func Put(url: String, body: String, opt headers: array<HttpHeader>) -> ref<HttpResponse>;
  public static native func PutForm(url: String, form: array<HttpPair>, opt headers: array<HttpHeader>) -> ref<HttpResponse>;
  public static native func PutMultipart(url: String, form: ref<HttpMultipart>, opt headers: array<HttpHeader>) -> ref<HttpResponse>;
  @if(ModuleExists("RedData.Json"))
  public static func PutJson(url: String, body: ref<JsonVariant>, opt headers: array<HttpHeader>) -> ref<HttpResponse> {
    let requestHeaders: array<HttpHeader> = [
      HttpHeader.Create("Content-Type", "application/json; charset=utf-8")
    ];
    for header in headers {
      if StrCmp(header.name, "Content-Type", -1, true) != 0 {
        ArrayPush(requestHeaders, header);
      }
    }
    return HttpClient.Put(url, body.ToString(), requestHeaders);
  }
  public static native func Patch(url: String, body: String, opt headers: array<HttpHeader>) -> ref<HttpResponse>;
  public static native func PatchForm(url: String, form: array<HttpPair>, opt headers: array<HttpHeader>) -> ref<HttpResponse>;
  public static native func PatchMultipart(url: String, form: ref<HttpMultipart>, opt headers: array<HttpHeader>) -> ref<HttpResponse>;
  @if(ModuleExists("RedData.Json"))
  public static func PatchJson(url: String, body: ref<JsonVariant>, opt headers: array<HttpHeader>) -> ref<HttpResponse> {
    let requestHeaders: array<HttpHeader> = [
      HttpHeader.Create("Content-Type", "application/json; charset=utf-8")
    ];
    for header in headers {
      if StrCmp(header.name, "Content-Type", -1, true) != 0 {
        ArrayPush(requestHeaders, header);
      }
    }
    return HttpClient.Patch(url, body.ToString(), requestHeaders);
  }
  public static native func Delete(url: String, opt body: String, opt headers: array<HttpHeader>) -> ref<HttpResponse>;
  public static native func DeleteForm(url: String, form: array<HttpPair>, opt headers: array<HttpHeader>) -> ref<HttpResponse>;
  public static native func DeleteMultipart(url: String, form: ref<HttpMultipart>, opt headers: array<HttpHeader>) -> ref<HttpResponse>;
  @if(ModuleExists("RedData.Json"))
  public static func DeleteJson(url: String, body: ref<JsonVariant>, opt headers: array<HttpHeader>) -> ref<HttpResponse> {
    let requestHeaders: array<HttpHeader> = [
      HttpHeader.Create("Content-Type", "application/json; charset=utf-8")
    ];
    for header in headers {
      if StrCmp(header.name, "Content-Type", -1, true) != 0 {
        ArrayPush(requestHeaders, header);
      }
    }
    return HttpClient.Delete(url, body.ToString(), requestHeaders);
  }
}
public native struct HttpHeader {
  public static func Create(name: String, value: String) -> HttpHeader {
    let self: HttpHeader;
    self.name = name;
    self.value = value;
    return self;
  }
  public native let name: String;
  public native let value: String;
}
public native class HttpMultipart {
  public native func AddPart(name: String, value: String) -> Void;
  public native func SetPart(name: String, value: String) -> Void;
  public native func GetPart(name: String) -> String;
}
public native struct HttpPair {
  public static func Create(key: String, value: String) -> HttpPair {
    let self: HttpPair;
    self.key = key;
    self.value = value;
    return self;
  }
  public native let key: String;
  public native let value: String;
}
public native class HttpResponse {
  public native func GetStatus() -> HttpStatus;
  public native func GetStatusCode() -> Int32;
  public native func GetHeaders() -> array<HttpHeader>;
  public native func HasHeader(header: String) -> Bool;
  public native func GetHeader(header: String) -> String;
  public native func GetText() -> String;
  @if(ModuleExists("RedData.Json"))
  public func GetJson() -> ref<JsonVariant> {
    return ParseJson(this.GetText());
  }
}
public enum HttpStatus {
  Continue = 100,
  SwitchingProtocols = 101,
  Processing = 102,
  EarlyHints = 103,
  OK = 200,
  Created = 201,
  Accepted = 202,
  NonAuthoritativeInformation = 203,
  NoContent = 204,
  ResetContent = 205,
  PartialContent = 206,
  MultiStatus = 207,
  AlreadyReported = 208,
  IMUsed = 226,
  MultipleChoices = 300,
  MovedPermanently = 301,
  Found = 302,
  SeeOther = 303,
  NotModified = 304,
  UseProxy = 305,
  TemporaryRedirect = 307,
  PermanentRedirect = 308,
  BadRequest = 400,
  Unauthorized = 401,
  PaymentRequired = 402,
  Forbidden = 403,
  NotFound = 404,
  MethodNotAllowed = 405,
  NotAcceptable = 406,
  ProxyAuthenticationRequired = 407,
  RequestTimeout = 408,
  Conflict = 409,
  Gone = 410,
  LengthRequired = 411,
  PreconditionFailed = 412,
  ContentTooLarge = 413,
  PayloadTooLarge = 413,
  URITooLong = 414,
  UnsupportedMediaType = 415,
  RangeNotSatisfiable = 416,
  ExpectationFailed = 417,
  ImATeapot = 418,
  MisdirectedRequest = 421,
  UnprocessableContent = 422,
  UnprocessableEntity = 422,
  Locked = 423,
  FailedDependency = 424,
  TooEarly = 425,
  UpgradeRequired = 426,
  PreconditionRequired = 428,
  TooManyRequests = 429,
  RequestHeaderFieldsTooLarge = 431,
  UnavailableForLegalReasons = 451,
  InternalServerError = 500,
  NotImplemented = 501,
  BadGateway = 502,
  ServiceUnavailable = 503,
  GatewayTimeout = 504,
  HTTPVersionNotSupported = 505,
  VariantAlsoNegotiates = 506,
  InsufficientStorage = 507,
  LoopDetected = 508,
  NotExtended = 510,
  NetworkAuthenticationRequired = 511
}
