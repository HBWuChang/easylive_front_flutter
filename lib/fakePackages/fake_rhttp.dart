// 虚假的 rhttp 库，用于非 Desktop 平台
// 这个文件确保在 Web 和 Android 平台上不会因为导入 rhttp 而出错

/// 虚假的 Rhttp 类
class Rhttp {
  static Future<void> init() async {
    // 虚假的初始化，什么都不做
  }
}

/// 虚假的 ClientSettings 类
class ClientSettings {
  final String? baseUrl;
  final CookieSettings? cookieSettings;
  
  const ClientSettings({
    this.baseUrl,
    this.cookieSettings,
  });
}

/// 虚假的 CookieSettings 类
class CookieSettings {
  final bool storeCookies;
  
  const CookieSettings({required this.storeCookies});
}

/// 虚假的 HttpHeaders 类
class HttpHeaders {
  static HttpHeaders rawMap(Map<String, String> headers) {
    return HttpHeaders._(headers);
  }
  
  final Map<String, String> headers;
  HttpHeaders._(this.headers);
}

/// 虚假的 HttpBody 类
class HttpBody {
  static HttpBody json(dynamic data) {
    return HttpBody._('json', data);
  }
  
  static HttpBody form(Map<String, String> data) {
    return HttpBody._('form', data);
  }
  
  static HttpBody multipart(Map<String, MultipartItem> data) {
    return HttpBody._('multipart', data);
  }
  
  final String type;
  final dynamic data;
  HttpBody._(this.type, this.data);
}

/// 虚假的 MultipartItem 类
class MultipartItem {
  static MultipartItem bytes({required List<int> bytes, String? fileName}) {
    return MultipartItem._('bytes', bytes, fileName);
  }
  
  static MultipartItem text({required String text}) {
    return MultipartItem._('text', text, null);
  }
  
  final String type;
  final dynamic data;
  final String? fileName;
  MultipartItem._(this.type, this.data, this.fileName);
}

/// 虚假的响应类
class HttpTextResponse {
  final int statusCode;
  final Map<String, dynamic> bodyToJson;
  
  HttpTextResponse(this.statusCode, this.bodyToJson);
}

/// 虚假的字节响应类
class HttpBytesResponse {
  final int statusCode;
  final List<int> body;
  
  HttpBytesResponse(this.statusCode, this.body);
}

/// 虚假的 RhttpClient 类
class RhttpClient {
  static Future<RhttpClient> create({ClientSettings? settings}) async {
    return RhttpClient._();
  }
  
  RhttpClient._();
  
  /// 虚假的 get 方法
  Future<HttpTextResponse> get(
    String path, {
    Map<String, String>? query,
    HttpHeaders? headers,
  }) async {
    throw UnsupportedError('RhttpClient is not available on this platform');
  }
  
  /// 虚假的 getBytes 方法
  Future<HttpBytesResponse> getBytes(
    String path, {
    Map<String, String>? query,
    HttpHeaders? headers,
  }) async {
    throw UnsupportedError('RhttpClient is not available on this platform');
  }
  
  /// 虚假的 post 方法
  Future<HttpTextResponse> post(
    String path, {
    HttpBody? body,
    HttpHeaders? headers,
  }) async {
    throw UnsupportedError('RhttpClient is not available on this platform');
  }
}
