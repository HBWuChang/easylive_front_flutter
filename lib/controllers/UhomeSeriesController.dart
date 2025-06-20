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

class UhomeSeriesController extends GetxController {
  final String userId;
  var userVideoSeries = <UserVideoSeries>[].obs;
  final LocalSettingsController localSettingsController =
      Get.find<LocalSettingsController>();
  bool lasttype = true; // true: 网格，false: 列表
  UhomeSeriesController({required this.userId});

  @override
  void onInit() {
    super.onInit();
    lasttype = localSettingsController.getSetting('uhomeVideoListType');
    loadUserVideoSeries();
    ever((localSettingsController.settings), (settings) {
      // 监听设置变化
      if (settings['uhomeVideoListType'] != null &&
          settings['uhomeVideoListType'] != lasttype) {
        lasttype = settings['uhomeVideoListType'];
        loadUserVideoSeries();
      }
    });
  }

  Future<void> loadUserVideoSeries() async {
    try {
      var res;
      if (lasttype) {
        res = await ApiService.uhomeSeriesLoadVideoSeries(userId);
      } else {
        res = await ApiService.uhomeSeriesLoadVideoSeriesWithVideo(userId);
      }
      if (res['code'] == 200) {
        userVideoSeries.value = (res['data'] as List<dynamic>)
            .map((item) => UserVideoSeries(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(res['info']);
      }
    } catch (e) {
      showErrorSnackbar(
        e.toString(),
      );
    }
  }
}

class UserVideoSeries {
  // public class UserVideoSeries implements Serializable {

// 	/**
// 	 * 列表ID
// 	 */
// 	private Integer seriesId;

// 	/**
// 	 * 列表名称
// 	 */
// 	private String seriesName;

// 	/**
// 	 * 描述
// 	 */
// 	private String seriesDescription;

// 	/**
// 	 * 用户ID
// 	 */
// 	private String userId;

// 	/**
// 	 * 排序
// 	 */
// 	private Integer sort;

// 	/**
// 	 * 更新时间
// 	 */
// 	@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
// 	@DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
// 	private Date updateTime;

// 	private String cover;
// 	private List<VideoInfo> videoInfoList;

  final int seriesId;
  final String seriesName;
  final String seriesDescription;
  final String userId;
  final int sort;
  final DateTime updateTime;
  final String cover;
  final List<VideoInfo> videoInfoList;

  UserVideoSeries(Map<String, dynamic> json)
      : seriesId = json['seriesId'] ?? 0,
        seriesName = json['seriesName'] ?? '',
        seriesDescription = json['seriesDescription'] ?? '',
        userId = json['userId'] ?? '',
        sort = json['sort'] ?? 0,
        updateTime =
            DateTime.parse(json['updateTime'] ?? '1970-01-01T00:00:00Z'),
        cover = json['cover'] ?? '',
        videoInfoList = (json['videoInfoList'] as List<dynamic>?)
                ?.map((item) => VideoInfo(item as Map<String, dynamic>))
                .toList() ??
            [];
}
