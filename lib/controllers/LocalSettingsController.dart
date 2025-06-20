import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:easylive/controllers/controllers-class2.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/settings.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../api_service.dart';
import '../Funcs.dart';
import 'package:media_kit/media_kit.dart';
import 'VideoCommentController.dart';
import 'dart:async';

class LocalSettingsController extends GetxController {
  var settings = <String, dynamic>{}.obs;
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    settings.value = prefs.getString('localSettings') != null
        ? Map<String, dynamic>.from(
            jsonDecode(prefs.getString('localSettings')!))
        : {};
    Map<String, dynamic> defaultSettings = {
      'listOrGrid': true,
      'uhomeVideoListType': true,
      '开启弹幕': true,
      '弹幕不透明度': 1.0,
      '弹幕字体大小': 16.0,
      '弹幕速度': 10.0,
      '弹幕显示区域': 1.0,
      '弹幕启用滚动': true,
      '弹幕启用顶部': true,
      '弹幕启用底部': true,
    };
    defaultSettings.addAll(settings);
    settings.value = defaultSettings;
  }

  void setSetting(String key, dynamic value) {
    settings[key] = value;
  }

  dynamic getSetting(String key) {
    return settings[key];
  }

  String getLastPlayFileId(String videoId) {
    return settings['videoPListSelectFileId$videoId'] ?? '';
  }

  String get deviceId {
    return settings['deviceId'] ?? creatDeviceId();
  }

  String creatDeviceId() {
    // 生成两个uuid
    var uuid = Uuid();
    String uuid1 = uuid.v4();
    String uuid2 = uuid.v4();
    // 拼接后取md5
    String raw = uuid1 + uuid2;
    String newDeviceId = md5.convert(raw.codeUnits).toString();
    settings['deviceId'] = newDeviceId;
    return newDeviceId;
  }

  @override
  void onInit() {
    super.onInit();
    ever(settings, (_) {
      saveSettings();
    });
  }

  Timer? _saveTimer;
  void saveSettings() {
    if (_saveTimer != null && _saveTimer!.isActive) {
      _saveTimer!.cancel();
    }
    _saveTimer = Timer(const Duration(seconds: 1), _saveSettings);
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('localSettings', jsonEncode(settings.value));
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('localSettings', jsonEncode(settings.value));
  }
}
