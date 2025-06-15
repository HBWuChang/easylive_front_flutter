import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:easylive/controllers/controllers-class2.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/settings.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../Funcs.dart';
import 'package:media_kit/media_kit.dart';
import 'controllers-class.dart';

class VideoDamnuController extends GetxController {
  String videoId = '';
  String fileId = '';
  RxList<VideoDanmu> danmus = <VideoDanmu>[].obs;

  VideoDamnuController({required this.videoId, required this.fileId});
  @override
  void onInit() {
    super.onInit();
    loadDanmu();
  }

  Future<void> loadDanmu() async {
    try {
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
