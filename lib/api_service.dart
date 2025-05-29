import 'dart:convert';

import 'package:easylive/Funcs.dart';
import 'package:easylive/controllers.dart';
import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
import 'package:rhttp/rhttp.dart';

/// 全局API服务，所有网络请求通过此类实现
class ApiService {
  static RhttpClient? _client;
  static String _baseUrl = 'http://127.0.0.1:7071';
  static String get baseUrl => _baseUrl;

  /// 初始化rhttp，需在main函数启动时调用
  static Future<void> init({String? baseUrl}) async {
    _baseUrl = baseUrl ?? 'http://127.0.0.1:7071';
    await Rhttp.init();
    _client = await RhttpClient.create(
      settings: baseUrl != null
          ? ClientSettings(baseUrl: baseUrl)
          : const ClientSettings(),
    );
  }

  /// GET请求
  static Future<HttpTextResponse> get(String path,
      {Map<String, String>? query,
      Map<HttpHeaderName, String>? headers,
      bool useToken = false}) async {
    assert(_client != null, 'ApiService未初始化，请先调用ApiService.init()');
    final response = await _client!.get(
      path,
      query: query,
      headers: useToken
          ? HttpHeaders.rawMap(
              {'token-xuan': Get.find<AccountController>().token ?? ''})
          : (headers != null ? HttpHeaders.map(headers) : null),
    );
    if (response.statusCode == 901) {
      openLoginDialog();
    }
    return response;
  }

  /// POST请求（支持json、form等多种body）
  static Future<HttpTextResponse> post(String path,
      {Object? data,
      Map<HttpHeaderName, String>? headers,
      bool isJson = true}) async {
    assert(_client != null, 'ApiService未初始化，请先调用ApiService.init()');
    final body = data == null
        ? null
        : isJson
            ? HttpBody.json(data)
            : HttpBody.form((data as Map<String, String>));
    final response = await _client!.post(
      path,
      body: body,
      headers: headers != null ? HttpHeaders.map(headers) : null,
    );
    return response as HttpTextResponse;
  }

  static Map<String, dynamic> toJson(HttpTextResponse httpTextResponse) {
    return jsonDecode(httpTextResponse.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> accountCheckCode() async {
    return toJson(await get(
      ApiAddr.accountCheckCode,
    ));
  }

  static Future<Map<String, dynamic>> accountRegister({
    required String email,
    required String nickName,
    required String password,
    required String checkCodeKey,
    required String checkCode,
  }) async {
    return toJson(await get(
      ApiAddr.accountRegister,
      query: {
        "email": email,
        "nickName": nickName,
        "password": password,
        "checkCodeKey": checkCodeKey,
        "checkCode": checkCode,
      },
    ));
  }

  static Future<Map<String, dynamic>> accountLogin({
    required String email,
    required String password,
    required String checkCodeKey,
    required String checkCode,
  }) async {
    // 对密码进行MD5加密
    final passwordMd5 = md5.convert(utf8.encode(password)).toString();

    return toJson(await get(
      ApiAddr.accountLogin,
      query: {
        "email": email,
        "password": passwordMd5,
        "checkCodeKey": checkCodeKey,
        "checkCode": checkCode,
      },
    ));
  }

  static Future<Map<String, dynamic>> accountAutologin() async {
    return toJson(await get(
      ApiAddr.accountAutologin,
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> accountLogout() async {
    return toJson(await get(
      ApiAddr.accountLogout,
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> accountGetUserCountInfo() async {
    return toJson(await get(
      ApiAddr.accountGetUserCountInfo,
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> uhomeGetUserInfo(String userId) async {
    return toJson(await get(
      ApiAddr.uhomeGetUserInfo,
      query: {'userId': userId},
      useToken: true,
    ));
  }
}

class ApiAddr {
  static const String LoginBackGround =
      'cover/202505\\qHVupu9Jk8YNMgg5N9ovtPnu6DXAhg.webp';
  static const String accountLogin = '/account/login';
  static const String accountCheckCode = '/account/checkCode';
  static const String accountRegister = '/account/register';
  static const String accountAutologin = '/account/autologin';
  static const String accountLogout = '/account/logout';
  static const String accountGetUserCountInfo = '/account/getUserCountInfo';
  static const String fileGetResource = '/file/getResource?sourceName=';
  static const String uhomeGetUserInfo = '/uhome/getUserInfo';
}
