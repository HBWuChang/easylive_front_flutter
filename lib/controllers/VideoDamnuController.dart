import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:easylive/controllers/LocalSettingsController.dart';
import 'package:easylive/controllers/controllers-class2.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../Funcs.dart';
import 'package:media_kit/media_kit.dart';
import 'controllers-class.dart';
import 'package:flutter_barrage_craft/flutter_barrage_craft.dart';
import 'package:flutter_barrage_craft/src/model/barrage_model.dart';

class DanmuIdWithHashcode {
  int danmuId;
  int hashCode;

  DanmuIdWithHashcode(this.danmuId, this.hashCode);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DanmuIdWithHashcode) return false;
    return danmuId == other.danmuId && hashCode == other.hashCode;
  }
}

class VideoDamnuController extends GetxController {
  String videoId = '';
  String fileId = '';
  RxList<VideoDanmu> danmus = <VideoDanmu>[].obs;
  BarrageController barrageController = BarrageController();
  BarrageController? fullscreenBarrageController;
  RxBool loading = true.obs;
  Player? player;
  BuildContext? context;
  Size? size;
  List<Timer> timers = [];
  Set<DanmuIdWithHashcode> sentIds = {};
  bool enableSendOnUpdate = false;
  VideoDamnuController({required this.videoId, required this.fileId});
  late final LocalSettingsController localSettingsController;
  @override
  void onInit() {
    super.onInit();
    localSettingsController = Get.find<LocalSettingsController>();
    loadDanmu();
    ever(danmus, (_) {
      if (enableSendOnUpdate) {
        sendToBarrage();
      }
    });
    size = Size(300, 20);
  }

  Color _parseColor(String hex) {
    try {
      if (hex.startsWith('#')) hex = hex.substring(1);
      if (hex.length == 6) {
        return Color(int.parse('0xFF$hex'));
      }
    } catch (_) {}
    return Colors.white;
  }

  void reset() {
    debugPrint('_danmuController重置弹幕状态');
    // try {
    //   barrageController!.pause();
    //   barrageController!.clearScreen();
    //   barrageController!.dispose();
    // } catch (e) {
    //   debugPrint('清除弹幕失败: $e');
    // }
    sentIds.clear();
    // timers.forEach((timer) => timer.cancel());
    // timers.clear();
  }

  void addToTimer(VideoDanmu danmu, {bool force = false}) {
    Duration nowDuration = player!.state.position;
    Duration danmuDuration = Duration(seconds: danmu.time);
    if (nowDuration.inSeconds > danmuDuration.inSeconds + 1 && !force) {
      return;
    }
    if (sentIds.contains(danmu.danmuId)) {
      debugPrint('弹幕已发送: ${danmu.danmuId}  ${danmu.text}');
      return;
    }
    // final timer = Timer(danmuDuration - nowDuration, () {
    final timer = Timer(
        danmuDuration < nowDuration
            ? Duration.zero
            : danmuDuration - nowDuration, () async {
      if (sentIds.any((test) => test.danmuId == danmu.danmuId)) {
        debugPrint('弹幕已发送: ${danmu.danmuId}  ${danmu.text}');
        return;
      }
      // sentIds.add(danmu.danmuId);
      if (fullscreenBarrageController != null) {
        fullscreenBarrageController!.addBarrage(
            barrageWidget: Text(
              danmu.text,
              style: TextStyle(
                color: _parseColor(danmu.color),
                fontSize: localSettingsController.settings['弹幕字体大小'],
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 2,
                    color: Colors.black.withOpacity(0.5),
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
            widgetSize: size);
      }
      var res = await barrageController!.addBarrage(
          barrageWidget: Text(
            danmu.text,
            style: TextStyle(
              color: _parseColor(danmu.color),
              fontSize: localSettingsController.settings['弹幕字体大小'],
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
          widgetSize: size);

      debugPrint('发送弹幕: ${danmu.danmuId}  ${danmu.text}  ${res.barrageId}');
      sentIds.add(
        DanmuIdWithHashcode(danmu.danmuId, res.barrageId.hashCode),
      );
      barrageController!.changeBarrageRate(
        localSettingsController.settings['弹幕速度'],
      );
      debugPrint('弹幕加载完成: ${barrageController!.barrages.length}');
    });
    timers.add(timer);
  }

  void SingleBarrageRemoveScreenCallBack(BarrageModel value) {
    debugPrint(
        '单条弹幕移除屏幕: ${(value.barrageWidget as Text).data} ${value.barrageId}');
    // 移除已发送的弹幕ID
    sentIds.removeWhere(
      (test) => test.hashCode == value.barrageId.hashCode,
    );
    barrageController.barrageManager.removeBarrageByKey(value.barrageId);
  }

  void fullscreenSingleBarrageRemoveScreenCallBack(BarrageModel value) {
    fullscreenBarrageController!.barrageManager
        .removeBarrageByKey(value.barrageId);
  }

  void cleanTimers() {
    debugPrint('清除所有定时器');
    for (var timer in timers) {
      timer.cancel();
    }
    timers.clear();
  }

  Future<void> sendToBarrage() async {
    if (loading.value) {
      final completer = Completer<void>();
      late Worker worker;
      worker = ever(loading, (val) {
        if (val == false) {
          completer.complete();
          worker.dispose();
        }
      });
      await completer.future;
    }
    debugPrint('加载弹幕: ${fileId}  ${danmus.length}');
    cleanTimers();
    barrageController.play();
    for (var danmu in danmus) {
      addToTimer(danmu);
    }
    enableSendOnUpdate = true;
  }

  void pauseDanmu() async {
    debugPrint('暂停弹幕');
    barrageController.pause();
    cleanTimers();
  }

  void resumeDanmu() async {
    debugPrint('恢复弹幕');
    sendToBarrage();
  }

  Future<void> loadDanmu() async {
    try {
      loading.value = true;
      final response =
          await ApiService.danmuLoadDanmu(videoId: videoId, fileId: fileId);
      if (response['code'] == 200) {
        danmus.value =
            (response['data'] as List).map((item) => VideoDanmu(item)).toList();
      } else {
        Get.snackbar('加载弹幕失败', response['message'] ?? '未知错误');
      }
    } catch (e) {
      Get.snackbar('加载弹幕出错', e.toString());
    } finally {
      loading.value = false;
    }
  }

  Future<void> postDanmu(String text, int mode, String color, int time) async {
    try {
      if (text.isEmpty) {
        throw Exception('弹幕内容不能为空');
      }
      if (text.length > 200) {
        throw Exception('弹幕内容不能超过200个字符');
      }
      // int maxdanmuId = 0;
      // if (danmus.isNotEmpty) {
      //   maxdanmuId =
      //       danmus.map((e) => e.danmuId).reduce((a, b) => a > b ? a : b);
      // }
      // danmus.add(VideoDanmu({
      //   'danmuId': maxdanmuId + 1,
      //   'videoId': videoId,
      //   'fileId': fileId,
      //   'userId': Get.find<AccountController>().userId,
      //   'postTime': DateTime.now().toIso8601String(),
      //   'text': text,
      //   'mode': mode,
      //   'color': color,
      //   'time': time,
      // }));
      // return;
      final response = await ApiService.danmuPostDanmu(
        videoId: videoId,
        fileId: fileId,
        text: text,
        mode: mode,
        color: color,
        time: time,
      );
      if (response['code'] == 200) {
        // 成功后重新加载弹幕
        // await loadDanmu();
        int maxdanmuId = 0;
        if (danmus.isNotEmpty) {
          maxdanmuId =
              danmus.map((e) => e.danmuId).reduce((a, b) => a > b ? a : b);
        }
        danmus.add(VideoDanmu({
          'danmuId': maxdanmuId + 1,
          'videoId': videoId,
          'fileId': fileId,
          'userId': Get.find<AccountController>().userId,
          'postTime': DateTime.now().toIso8601String(),
          'text': text,
          'mode': mode,
          'color': color,
          'time': time,
        }));
      } else {
        Get.snackbar('发送弹幕失败', response['message'] ?? '未知错误');
      }
    } catch (e) {
      Get.snackbar('发送弹幕出错', e.toString());
    }
  }
}

class VideoDanmu {
  // public class VideoDanmu implements Serializable {

  // /**
  //  * 自增ID
  //  */
  // private Integer danmuId;

  // /**
  //  * 视频ID
  //  */
  // private String videoId;

  // /**
  //  * 文件唯一ID
  //  */
  // private String fileId;

  // /**
  //  * 用户ID
  //  */
  // private String userId;

  // /**
  //  * 发布时间
  //  */
  // @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
  // @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
  // private Date postTime;

  // /**
  //  * 内容
  //  */
  // private String text;

  // /**
  //  * 展示位置
  //  */
  // private Integer mode;

  // /**
  //  * 颜色
  //  */
  // private String color;

  // /**
  //  * 展示时间
  //  */
  // private Integer time;
  // private String videoName;
  // private String videoCover;
  // private String nickName;

  int danmuId = 0;
  String videoId = '';
  String fileId = '';
  String userId = '';
  DateTime postTime = DateTime.now();
  String text = '';
  int mode = 0; // Assuming mode is an integer
  String color = '';
  int time = 0;
  String? videoName = '';
  String? videoCover = '';
  String? nickName = '';
//  {
//       "danmuId": 1,
//       "videoId": "1Gm6o77fPt",
//       "fileId": "9jW8ebZVH7nXrZHWeJKx",
//       "userId": "0636309642",
//       "postTime": "2025-05-12 11:20:33",
//       "text": "测试弹幕123",
//       "mode": 0,
//       "color": "#66ccff",
//       "time": 12
//     }
  VideoDanmu(Map<String, dynamic> json) {
    danmuId = json['danmuId'] ?? 0;
    videoId = json['videoId'] ?? '';
    fileId = json['fileId'] ?? '';
    userId = json['userId'] ?? '';
    postTime =
        DateTime.parse(json['postTime'] ?? DateTime.now().toIso8601String());
    text = json['text'] ?? '';
    mode = json['mode'] ?? 0;
    color = json['color'] ?? '';
    time = json['time'] ?? 0;
    videoName = json['videoName'];
    videoCover = json['videoCover'];
    nickName = json['nickName'];
  }
}
