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

class UHomeLoadVideoListController extends GetxController {
  final String userId;
  var videoList = <VideoInfo>[].obs;
  final RxBool isLoading = false.obs;
  var pageNo = 1.obs;
  var pageTotal = 1.obs;

  UHomeLoadVideoListController({required this.userId});

  @override
  void onInit() {
    super.onInit();
    loadVideos();
  }

  Future<void> loadVideos({
    int? type,
    int? pageNo,
    String? videoName,
    int? orderType,
  }) async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final response = await ApiService.uhomeLoadVideoList(
          userId: userId,
          type: type,
          pageNo: pageNo,
          videoName: videoName,
          orderType: orderType);
      if (response['code'] != 200) {
        throw Exception(response['info']);
      }
      final data = response['data'];
      this.pageNo.value = data['pageNo'] ?? 1;
      this.pageTotal.value = data['pageTotal'] ?? 1;
      videoList.value = (data['list'] as List<dynamic>)
          .map((item) => VideoInfo(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      showErrorSnackbar(
        e.toString(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
