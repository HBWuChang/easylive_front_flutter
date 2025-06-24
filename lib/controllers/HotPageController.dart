import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:easylive/controllers/LocalSettingsController.dart';
import 'package:easylive/controllers/controllers-class2.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/settings.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../api_service.dart';
import '../Funcs.dart';
import 'package:media_kit/media_kit.dart';
import '../pages/MainPage/MainPage.dart';
import 'MainPageController.dart';
import 'VideoCommentController.dart';
import 'dart:async';

import 'controllers-class.dart';

class HotPageController extends GetxController {
  var videos = <VideoInfo>[].obs;
  int pageNo = 1;
  int pageTotal = 1;
  var isLoading = false.obs;
  var loadingMore = false.obs;
  @override
  void onInit() {
    super.onInit();
    loadHotVideoList();
  }

  Future<void> loadHotVideoList() async {
    try {
      pageNo = 1; // 重置页码
      var res = await ApiService.videoLoadHotVideoList(pageNo);
      if (showResSnackbar(res, notShowIfSuccess: true)) {
        pageNo = res['data']['pageNo'] ?? 1;
        pageTotal = res['data']['pageTotal'] ?? 1;
        videos.value = (res['data']['list'] as List)
            .map((item) => VideoInfo(item as Map<String, dynamic>))
            .toList();
        debugPrint('加载热门视频列表成功: ${videos.length}个视频');
      } else {
        throw Exception('加载热门视频失败: ${res['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }

  Future<bool> loadMoreHotVideoList() async {
    if (loadingMore.value || pageNo >= pageTotal) {
      return false; // 如果正在加载或已经是最后一页，直接返回
    }
    loadingMore.value = true;
    try {
      var res = await ApiService.videoLoadHotVideoList(++pageNo);
      if (showResSnackbar(res, notShowIfSuccess: true)) {
        var newVideos = (res['data']['list'] as List)
            .map((item) => VideoInfo(item as Map<String, dynamic>))
            .toList();
        videos.addAll(newVideos);
        debugPrint('加载更多热门视频成功: ${newVideos.length}个新视频');
        return true; // 成功加载更多视频
      } else {
        throw Exception('加载更多热门视频失败: ${res['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
      return false; // 加载失败
    } finally {
      loadingMore.value = false;
    }
  }
}
