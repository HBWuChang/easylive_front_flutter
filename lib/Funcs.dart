import 'dart:math';

import 'package:easylive/controllers/controllers-class.dart';
import 'package:easylive/pages/pages.dart';
import 'package:easylive/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cards1.dart';
// import 'package:extended_image/extended_image.dart';
import 'dart:typed_data';
import 'dart:io';
// import 'package:image/image.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void openLoginDialog() {
  Get.dialog(
    LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: FractionallySizedBox(
            widthFactor: max(Get.width * Constants.loginDialogResizeRate,
                    Constants.loginDialogMinWidth) /
                Get.width,
            heightFactor: max(Get.height * Constants.loginDialogResizeRate,
                    Constants.loginDialogMinHeight) /
                Get.height,
            child: Material(
                borderRadius: BorderRadius.circular(12.r),
                clipBehavior: Clip.antiAlias,
                child: LoginPage(
                  areaWidth: max(Get.width * Constants.loginDialogResizeRate,
                      Constants.loginDialogMinWidth).w,
                  areaHeight: max(Get.height * Constants.loginDialogResizeRate,
                      Constants.loginDialogMinHeight).w,
                )),
          ),
        );
      },
    ),
    barrierDismissible: true,
  );
}

bool showResSnackbar(Map<String, dynamic> res,
    {bool notShowIfSuccess = false}) {
  Get.closeAllSnackbars();
  if (res['code'] != 200) {
    Get.snackbar(
      Texts.error,
      res['info'],
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(milliseconds: Constants.errorMsgDuration),
      instantInit: true,
    );
    return false;
  } else {
    if (notShowIfSuccess) return true;
    Get.snackbar(
      Texts.success,
      res['info'],
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withOpacity(0.8),
      colorText: Colors.white,
      duration: Duration(milliseconds: Constants.errorMsgDuration),
      instantInit: true,
    );
    return true;
  }
}

void showErrorSnackbar(String msg) {
  Get.closeAllSnackbars();
  Get.snackbar(
    Texts.error,
    msg,
    snackPosition: SnackPosition.TOP,
    backgroundColor: Colors.red.withOpacity(0.8),
    colorText: Colors.white,
    duration: Duration(milliseconds: Constants.errorMsgDuration),
    instantInit: true,
  );
}

String toShowNumText(int showCount) {
  String showText;
  if (showCount >= 1000000) {
    showText = (showCount / 1000000)
            .toStringAsFixed(showCount % 1000000 == 0 ? 0 : 1) +
        'M';
  } else if (showCount >= 1000) {
    showText =
        (showCount / 1000).toStringAsFixed(showCount % 1000 == 0 ? 0 : 1) + 'K';
  } else {
    showText = showCount.toString();
  }
  return showText;
}

String toShowdurationText(int duration) {
  String showText;
  int hours = duration ~/ 3600;
  int minutes = (duration % 3600) ~/ 60;
  int seconds = duration % 60;
  if (hours > 0) {
    // showText = '$hours:$minutes:$seconds'
    showText =
        '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  } else if (minutes > 0) {
    // showText = '$minutes:$seconds';
    showText = '$minutes:${seconds.toString().padLeft(2, '0')}';
  } else {
    // showText = '$seconds';
    showText = '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
  return showText;
}

String toShowDatetext(DateTime datetime) {
  String showText;
  DateTime now = DateTime.now();
  Duration difference = now.difference(datetime);
  if (datetime.year != now.year) {
    showText = datetime.toString().substring(2, 10);
  } else if (difference.inDays > 7) {
    showText = datetime.toString().substring(5, 10);
  } else if (difference.inDays > 1) {
    showText = '${difference.inDays}天前';
  } else if (difference.inDays == 1) {
    showText = '昨天';
  } else if (difference.inHours > 0) {
    showText = '${difference.inHours}小时前';
  } else if (difference.inMinutes > 0) {
    showText = '${difference.inMinutes}分钟前';
  } else {
    showText = '刚刚';
  }
  return showText;
}

void showUpdateUserInfoCard() async {
  await Get.dialog(
    Center(
      child: SizedBox(
        width: Constants.updateUserInfoCardWidth.w,
        height: Constants.updateUserInfoCardHeight.w,
        child: UpdateUserInfoCard(
          areaWidth: Constants.updateUserInfoCardWidth.w,
          areaHeight: Constants.updateUserInfoCardHeight.w,
        ),
      ),
    ),
    barrierDismissible: true,
  );
  await Get.find<AccountController>().autoLogin();
}

Future<dynamic> showUploadImageCard(
    {String? imagePath,
    Map<String, double?>? cropAspectRatios,
    bool shadow = false}) async {
  var res = await Get.dialog(
    Center(
      child: SizedBox(
        width: Constants.uploadImageCardWidth.w,
        height: Constants.uploadImageCardHeight.w,
        child: UploadImageCard(
          imagePath: imagePath,
          cropAspectRatios: cropAspectRatios,
        ),
      ),
    ),
    barrierColor: shadow ? null : const Color.fromARGB(0, 0, 0, 0),
    barrierDismissible: true,
  );
  return res;
}

Future<dynamic> showConfirmDialog(String msg, {String title = '提示'}) async {
  var res = await Get.dialog(
    AlertDialog(
      title: Text(title),
      content: Text(msg),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: Text('取消')),
        TextButton(onPressed: () => Get.back(result: true), child: Text('确定')),
      ],
    ),
  );
  return res ?? false;
}
String? getLastPath(String url) {
  if (url.isEmpty) return null;
  // 去掉查询参数
  if (url.contains('?')) {
    url = url.substring(0, url.indexOf('?'));
  }
  // 获取最后一个斜杠后的部分
  return url.split('/').last;
}
Map<String, String>? toParameters(String name) {
  name = name.substring(name.indexOf('?') + 1);
  Map<String, String> parameters = {};
  List<String> pairs = name.split('&');
  for (String pair in pairs) {
    List<String> keyValue = pair.split('=');
    if (keyValue.length == 2) {
      parameters[keyValue[0]] = keyValue[1];
    }
  }
  return parameters.isNotEmpty ? parameters : null;
}
Future<String> getDownloadDirectory() async {
  if (GetPlatform.isDesktop) {
    final downloads = await getDownloadsDirectory();
    return downloads?.path ?? Directory.current.path;
  }
  return Directory.current.path;
}

Future<File> saveBytesToFile(
    Uint8List bytes, String dir, String fileName) async {
  final file = File('$dir/$fileName');
  await file.writeAsBytes(bytes);
  return file;
}
