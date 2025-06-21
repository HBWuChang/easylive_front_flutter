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
  var nowSelectSeriesId = 0.obs;
  var userVideoSeries = <UserVideoSeries>[].obs;
  final LocalSettingsController localSettingsController =
      Get.find<LocalSettingsController>();
  var videoSeriesDetail = UhomeGetVideoSeriesDetail().obs; // 用于存储当前系列的详细信息
  bool lasttype = true; // true: 网格，false: 列表
  var isAscendingSort = true.obs; // 排序方式：false为最新添加（降序），true为最早添加（升序）
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
    ever(nowSelectSeriesId, (id) {
      // 监听当前选择的系列ID变化
      if (id != 0) {
        videoSeriesDetail.value = UhomeGetVideoSeriesDetail.fromUserVideoSeries(
            userVideoSeries.firstWhere((series) => series.seriesId == id));
        loadVideoSeriesDetail();
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

  Future<void> loadVideoSeriesDetail() async {
    try {
      if (nowSelectSeriesId.value == 0) return; // 如果没有选择系列，直接返回
      var res = await ApiService.uhomeSeriesGetVideoSeriesDetail(
          nowSelectSeriesId.value);
      if (res['code'] == 200) {
        videoSeriesDetail.value =
            UhomeGetVideoSeriesDetail.fromJson(res['data']);
        // 加载完成后应用排序
      } else {
        throw Exception(res['info']);
      }
    } catch (e) {
      showErrorSnackbar(
        e.toString(),
      );
    }
  }

  // 切换排序方式
  void toggleSortOrder() {
    isAscendingSort.value = !isAscendingSort.value;
    update();
  }

  // 获取当前排序方式的显示文本
  String get sortOrderText => isAscendingSort.value ? '正序' : '倒序';

  Future<List<VideoInfo>> uhomeseriesloadAllVideo(int seriesId) async {
    try {
      var res = await ApiService.uhomeSeriesLoadAllVideo(seriesId);
      if (res['code'] == 200) {
        // 成功后重新加载系列列表
        return (res['data'] as List<dynamic>)
            .map((item) => VideoInfo(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(res['info']);
      }
    } catch (e) {
      showErrorSnackbar(
        e.toString(),
      );
      return [];
    }
  }
}

class UhomeGetVideoSeriesDetail {
  UserVideoSeries? videoSeries;
  List<UserVideoSeriesVideo>? seriesVideoList;
  UhomeGetVideoSeriesDetail();
  // 从 JSON 创建的构造函数
  UhomeGetVideoSeriesDetail.fromJson(Map<String, dynamic> json)
      : videoSeries =
            UserVideoSeries(json['videoSeries'] as Map<String, dynamic>),
        seriesVideoList = (json['seriesVideoList'] as List<dynamic>?)
                ?.map((item) =>
                    UserVideoSeriesVideo(item as Map<String, dynamic>))
                .toList() ??
            [];

  // 从 UserVideoSeries 创建的构造函数
  UhomeGetVideoSeriesDetail.fromUserVideoSeries(UserVideoSeries userVideoSeries)
      : videoSeries = userVideoSeries,
        seriesVideoList = userVideoSeries.videoInfoList.isEmpty
            ? [
                UserVideoSeriesVideo({
                  'seriesId': userVideoSeries.seriesId,
                  'videoId': '',
                  'userId': userVideoSeries.userId,
                  'sort': 0,
                  'videoCover': userVideoSeries.cover,
                  'videoName': '',
                  'playCount': 0,
                  'createTime': DateTime.now().toIso8601String(),
                })
              ]
            : userVideoSeries.videoInfoList
                .map((video) => UserVideoSeriesVideo({
                      'seriesId': userVideoSeries.seriesId,
                      'videoId': video.videoId,
                      'userId': userVideoSeries.userId,
                      'sort': 0,
                      'videoCover': video.videoCover,
                      'videoName': video.videoName,
                      'playCount': video.playCount,
                      'createTime': video.createTime?.toIso8601String(),
                    }))
                .toList();
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

class UserVideoSeriesVideo {
// public class UserVideoSeriesVideo implements Serializable {

// 	/**
// 	 * 列表ID
// 	 */
// 	private Integer seriesId;

// 	/**
// 	 * 视频ID
// 	 */
// 	private String videoId;

// 	/**
// 	 * 用户ID
// 	 */
// 	private String userId;

// 	/**
// 	 * 排序
// 	 */
// 	private Integer sort;

// 	private String videoCover;
// 	private String videoName;
// 	private Integer playCount;
// 	@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
// 	@DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
// 	private Date createTime;

  final int seriesId;
  final String videoId;
  final String userId;
  final int sort;
  final String videoCover;
  final String videoName;
  final int playCount;
  final DateTime createTime;

  UserVideoSeriesVideo(Map<String, dynamic> json)
      : seriesId = json['seriesId'] ?? 0,
        videoId = json['videoId'] ?? '',
        userId = json['userId'] ?? '',
        sort = json['sort'] ?? 0,
        videoCover = json['videoCover'] ?? '',
        videoName = json['videoName'] ?? '',
        playCount = json['playCount'] ?? 0,
        createTime =
            DateTime.parse(json['createTime'] ?? '1970-01-01T00:00:00Z');
}

VideoInfo userVideoSeriesVideoToVideoInfo(
    UserVideoSeriesVideo userVideoSeriesVideo) {
  return VideoInfo({
    'videoId': userVideoSeriesVideo.videoId,
    'userId': userVideoSeriesVideo.userId,
    'videoCover': userVideoSeriesVideo.videoCover,
    'videoName': userVideoSeriesVideo.videoName,
    'playCount': userVideoSeriesVideo.playCount,
    'createTime': userVideoSeriesVideo.createTime.toIso8601String(),
  });
}

UserVideoSeriesVideo videoInfoToUserVideoSeriesVideo(
    VideoInfo videoInfo, int seriesId) {
  return UserVideoSeriesVideo({
    'seriesId': seriesId,
    'videoId': videoInfo.videoId,
    'userId': videoInfo.userId,
    'sort': 0, // 默认排序为0
    'videoCover': videoInfo.videoCover,
    'videoName': videoInfo.videoName,
    'playCount': videoInfo.playCount,
    'createTime': videoInfo.createTime!.toIso8601String(),
  });
}
