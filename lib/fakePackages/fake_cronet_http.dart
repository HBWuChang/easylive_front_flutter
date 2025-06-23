// 虚假的 cronet_http 库，用于非 Android 平台
// 这个文件确保在 Web 和 Desktop 平台上不会因为导入 cronet_http 而出错

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// 虚假的 CacheMode 枚举
enum CacheMode {
  memory,
  disk,
  disabled,
}

/// 虚假的 CronetEngine 类
class CronetEngine {
  static CronetEngine build({
    CacheMode? cacheMode,
    int? cacheMaxSize,
    String? userAgent,
    bool? enableQuic,
    bool? enableHttp2,
    bool? enableBrotli,
  }) {
    return CronetEngine._();
  }
  
  CronetEngine._();
}

/// 虚假的 CronetClient 类，实现 http.Client 以保持兼容性
class CronetClient implements http.Client {
  static CronetClient fromCronetEngine(CronetEngine engine) {
    return CronetClient._();
  }
  
  CronetClient._();
  
  @override
  void close() {}
  
  @override
  Future<http.Response> delete(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return http.Client().delete(url, headers: headers, body: body, encoding: encoding);
  }
  
  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return http.Client().get(url, headers: headers);
  }
  
  @override
  Future<http.Response> head(Uri url, {Map<String, String>? headers}) {
    return http.Client().head(url, headers: headers);
  }
  
  @override
  Future<http.Response> patch(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return http.Client().patch(url, headers: headers, body: body, encoding: encoding);
  }
  
  @override
  Future<http.Response> post(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return http.Client().post(url, headers: headers, body: body, encoding: encoding);
  }
  
  @override
  Future<http.Response> put(Uri url, {Map<String, String>? headers, Object? body, Encoding? encoding}) {
    return http.Client().put(url, headers: headers, body: body, encoding: encoding);
  }
  
  @override
  Future<String> read(Uri url, {Map<String, String>? headers}) {
    return http.Client().read(url, headers: headers);
  }
  
  @override
  Future<Uint8List> readBytes(Uri url, {Map<String, String>? headers}) {
    return http.Client().readBytes(url, headers: headers);
  }
  
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return http.Client().send(request);
  }
}
