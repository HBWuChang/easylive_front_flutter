import 'dart:math';

import 'package:easylive/pages.dart';
import 'package:easylive/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

bool showResSnackbar(Map<String, dynamic> res) {
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


