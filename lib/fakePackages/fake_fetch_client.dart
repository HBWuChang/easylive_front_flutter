// 虚假的 fetch_client 库，用于非 Web 平台
// 这个文件确保在 Android 和 Desktop 平台上不会因为导入 fetch_client 而出错

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

/// 虚假的 RequestMode 枚举
enum RequestMode {
  cors,
  noCors,
  sameOrigin,
  navigate,
}

/// 虚假的 FetchClient 类，实现 http.Client 以保持兼容性
class FetchClient implements http.Client {
  final RequestMode mode;
  
  FetchClient({required this.mode});
  
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
