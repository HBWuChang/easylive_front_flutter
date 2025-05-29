import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class LoginController extends GetxController {
  var email = ''.obs;
  var checkCode = ''.obs;
  var checkCodeKey = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromPrefs();
    ever(email, (_) => _saveToPrefs());
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    email.value = prefs.getString('email') ?? '';
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email.value);
  }

  Future<void> freshCaptcha() async {
    var response = await ApiService.accountCheckCode();
    if (response['code'] == 200) {
      checkCode.value = response['data']['checkCode'];
      checkCodeKey.value = response['data']['checkCodeKey'];
    } else {
      Get.snackbar('获取验证码错误', response['msg'],
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}

class AccountController extends GetxController {
  var accountInfo = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAccountInfo();
    ever(accountInfo, (_) => saveAccountInfoToLocal(_));
  }

// {
  //   "userId": "0636309642",
  //   "nickName": "神山识",
  //   "avatar": null,
  //   "expireAt": 1748612962391,
  //   "token": "7dab79f2-5ee2-4673-aabe-d657bbb8477b",
  //   "fansCount": null,
  //   "currentCoinCount": 2,
  //   "focusCount": null
  // }
  String? get userId => accountInfo['userId'];
  String? get nickName => accountInfo['nickName'];
  String? get avatar => accountInfo['avatar'];
  int? get expireAt => accountInfo['expireAt'];
  String? get token => accountInfo['token'];
  int? get fansCount => accountInfo['fansCount'];
  int? get currentCoinCount => accountInfo['currentCoinCount'];
  int? get focusCount => accountInfo['focusCount'];

  Future<void> _loadAccountInfo() async {
    final prefs = await SharedPreferences.getInstance();
    accountInfo.value = jsonDecode(prefs.getString('accountInfo') ?? '{}');
  }

  Future<void> saveAccountInfoToLocal(Map<String, dynamic> info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accountInfo', jsonEncode(info));
  }

  Future<void> saveAccountInfo(Map<String, dynamic> accountInfo) async {
    this.accountInfo.value = accountInfo;
  }

  Future<void> getUserCountInfo() async {
    var response = await ApiService.accountGetUserCountInfo();
    if (response['code'] == 200) {
      accountInfo['fansCount'] = response['data']['fansCount'];
      accountInfo['focusCount'] = response['data']['focusCount'];
      accountInfo['currentCoinCount'] = response['data']['currentCoinCount'];
      saveAccountInfoToLocal(accountInfo);
    } else {
      Get.snackbar('获取用户信息错误', response['msg'],
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> autoLogin() async {
    var response = await ApiService.accountAutologin();
    if (response['code'] == 200) {
      accountInfo.value = response['data'];
      await saveAccountInfoToLocal(accountInfo);
      getUserCountInfo();
    } else {
      accountInfo.value = {};
    }
  }
}
