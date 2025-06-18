import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';
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
import 'package:canvas_danmaku/canvas_danmaku.dart';

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
  late DanmakuController barrageController;
  DanmakuController? fullscreenBarrageController;
  RxBool loading = true.obs;
  Player? player;
  var barrageEnabled = true.obs;
  BuildContext? context;
  //   DanmakuOption({
  //   this.fontSize = 16,
  //   this.fontWeight = 4,
  //   this.area = 1.0,
  //   this.duration = 10,
  //   this.opacity = 1.0,
  //   this.hideBottom = false,
  //   this.hideScroll = false,
  //   this.hideTop = false,
  //   this.hideSpecial = false,
  //   this.showStroke = true,
  //   this.massiveMode = false,
  //   this.safeArea = true,
  // });
  var duration = 10.0.obs;
  var fontSize = 16.0.obs;
  var area = 1.0.obs;
  var opacity = 1.0.obs;
  var enableScroll = true.obs;
  var enableTop = true.obs;
  var enableBottom = true.obs;
  Size? size;
  List<Timer> timers = [];
  bool enableSendOnUpdate = false;
  VideoDamnuController({required this.videoId, required this.fileId});
  late final LocalSettingsController localSettingsController;
  @override
  void onInit() {
    super.onInit();
    localSettingsController = Get.find<LocalSettingsController>();
    barrageEnabled.value = localSettingsController.getSetting('开启弹幕');
    duration.value = localSettingsController.getSetting('弹幕速度');
    fontSize.value = localSettingsController.getSetting('弹幕字体大小');
    area.value = localSettingsController.getSetting('弹幕显示区域');
    opacity.value = localSettingsController.getSetting('弹幕不透明度');
    enableScroll.value = localSettingsController.getSetting('弹幕启用滚动');
    enableTop.value = localSettingsController.getSetting('弹幕启用顶部');
    enableBottom.value = localSettingsController.getSetting('弹幕启用底部');
    loadDanmu();
    ever(danmus, (_) {
      if (enableSendOnUpdate) {
        sendToBarrage();
      }
    });
    ever(barrageEnabled, (enabled) {
      if (!enabled) {
        barrageController.clear();
        fullscreenBarrageController?.clear();
      }
    });
    ever(duration, (_) {
      updateDanmuStyle();
    });
    ever(fontSize, (_) {
      updateDanmuStyle();
    });
    ever(area, (_) {
      updateDanmuStyle();
    });
    ever(opacity, (_) {
      updateDanmuStyle();
    });
    ever(enableScroll, (_) {
      updateDanmuStyle();
    });
    ever(enableTop, (_) {
      updateDanmuStyle();
    });
    ever(enableBottom, (_) {
      updateDanmuStyle();
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

  void updateDanmuStyle() {
    barrageController.updateOption(
      DanmakuOption(
        fontSize: fontSize.value,
        area: area.value,
        duration: duration.value.toInt(),
        opacity: opacity.value,
        hideBottom: !enableBottom.value,
        hideScroll: !enableScroll.value,
        hideTop: !enableTop.value,
        hideSpecial: false,
        showStroke: true,
        massiveMode: false,
        safeArea: true,
      ),
    );
    if (fullscreenBarrageController != null) {
      fullscreenBarrageController!.updateOption(
        DanmakuOption(
          fontSize: fontSize.value,
          area: area.value,
          duration: duration.value.toInt(),
          opacity: opacity.value,
          hideBottom: !enableBottom.value,
          hideScroll: !enableScroll.value,
          hideTop: !enableTop.value,
          hideSpecial: false,
          showStroke: true,
          massiveMode: false,
          safeArea: true,
        ),
      );
    }
    localSettingsController.setSetting('弹幕字体大小', fontSize.value);
    localSettingsController.setSetting('弹幕显示区域', area.value);
    localSettingsController.setSetting('弹幕速度', duration.value);
    localSettingsController.setSetting('弹幕不透明度', opacity.value);
    localSettingsController.setSetting('弹幕启用滚动', enableScroll.value);
    localSettingsController.setSetting('弹幕启用顶部', enableTop.value);
    localSettingsController.setSetting('弹幕启用底部', enableBottom.value);
    debugPrint('保存到本地: fontSize=$fontSize, area=$area, duration=$duration');
  }

  DanmakuItemType toDanmakuItemType(int mode) {
    switch (DanmuModeEnum.getByType(mode)) {
      case DanmuModeEnum.NORMAL:
        return DanmakuItemType.scroll;
      case DanmuModeEnum.TOP:
        return DanmakuItemType.top;
      case DanmuModeEnum.BOTTOM:
        return DanmakuItemType.bottom;
      default:
        return DanmakuItemType.scroll; // 默认滚动弹幕
    }
  }

  void addToTimer(VideoDanmu danmu, {bool force = false}) async {
    if (!barrageEnabled.value) {
      debugPrint('弹幕已暂停，无法添加弹幕: ${danmu.text}');
      return;
    }
    Duration nowDuration = player!.state.position;
    Duration danmuDuration = Duration(seconds: danmu.time);
    if (nowDuration.inSeconds > danmuDuration.inSeconds + 1 && !force) {
      return;
    }
    final random = Random();
    // 随机前后延迟（-0.75~+0.75秒）
    double offset = (random.nextDouble() * 1.5) - 0.75;
    Duration randomDelay = Duration(milliseconds: (offset * 1000).round());
    Duration timerDelay = (danmuDuration < nowDuration
            ? Duration.zero
            : danmuDuration - nowDuration) +
        randomDelay;
    if (timerDelay.isNegative) timerDelay = Duration.zero;
    final timer = Timer(timerDelay, () async {
      DanmakuContentItem toAddItem = DanmakuContentItem(
        danmu.text,
        selfSend: danmu.userId == Get.find<AccountController>().userId,
        color: _parseColor(danmu.color),
        type: toDanmakuItemType(danmu.mode),
      );
      if (fullscreenBarrageController != null) {
        fullscreenBarrageController!.addDanmaku(toAddItem);
      }
      barrageController.addDanmaku(toAddItem);
      debugPrint(
          '发送弹幕: [33m${danmu.danmuId}  ${danmu.text} (延迟: [36m${timerDelay.inMilliseconds}ms[0m)');
    });
    timers.add(timer);
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
    // barrageController.play();
    for (var danmu in danmus) {
      addToTimer(danmu);
    }
    enableSendOnUpdate = true;
  }

  void pauseDanmu() async {
    debugPrint('暂停弹幕');
    barrageController.pause();
    if (fullscreenBarrageController != null) {
      fullscreenBarrageController!.pause();
    }
    cleanTimers();
  }

  void resumeDanmu() async {
    debugPrint('恢复弹幕');
    barrageController.resume();
    if (fullscreenBarrageController != null) {
      fullscreenBarrageController!.resume();
    }
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
