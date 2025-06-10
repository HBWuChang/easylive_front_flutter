import 'dart:math';

import 'package:easylive/controllers-class.dart';
import 'package:easylive/pages/pages.dart';
import 'package:easylive/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'cards1.dart';
// import 'package:extended_image/extended_image.dart';
import 'dart:typed_data';
// import 'dart:io';
// import 'package:image/image.dart';
import 'package:flutter/foundation.dart';

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
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: LoginPage(
                  areaWidth: max(Get.width * Constants.loginDialogResizeRate,
                      Constants.loginDialogMinWidth),
                  areaHeight: max(Get.height * Constants.loginDialogResizeRate,
                      Constants.loginDialogMinHeight),
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
    showText = '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  } else if (minutes > 0) {
    // showText = '$minutes:$seconds';
    showText = '$minutes:${seconds.toString().padLeft(2, '0')}';
  } else {
    showText = '$seconds';
  }
  return showText;
}

void showUpdateUserInfoCard() async {
  await Get.dialog(
    Center(
      child: SizedBox(
        width: Constants.updateUserInfoCardWidth,
        height: Constants.updateUserInfoCardHeight,
        child: UpdateUserInfoCard(
          areaWidth: Constants.updateUserInfoCardWidth,
          areaHeight: Constants.updateUserInfoCardHeight,
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
        width: Constants.uploadImageCardWidth,
        height: Constants.uploadImageCardHeight,
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
