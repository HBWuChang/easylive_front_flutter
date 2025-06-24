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
import 'VideoCommentController.dart';
import 'dart:async';

// 简化：Getx分区状态控制器
class CategoryViewStateController extends GetxController {
  var isExpanded = false.obs; // 控制ExpansionPanel的展开/收缩
  var selectedCategoryCode = ''.obs;

  void setExpanded(bool value) {
    isExpanded.value = value;
  }
}
