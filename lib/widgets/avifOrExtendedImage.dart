import 'package:flutter_avif/flutter_avif.dart';
import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../api_service.dart';
import '../settings.dart';

Widget avifOrExtendedImage({
  required String url,
}) {
  if (url.endsWith('.avif') && GetPlatform.isWeb) {
  // if (url.endsWith('.avif')) {
    return CachedNetworkAvifImage(
      Constants.baseUrl + ApiAddr.fileGetResourcet + url,
      fit: BoxFit.cover,
    );
  }
  return ExtendedImage.network(
    Constants.baseUrl + ApiAddr.fileGetResourcet + url,
    fit: BoxFit.cover,
    cache: true,
    enableLoadState: true,
    loadStateChanged: (state) {
      if (state.extendedImageLoadState == LoadState.loading) {
        return Center(child: CircularProgressIndicator());
      } else if (state.extendedImageLoadState == LoadState.completed) {
        return null; // 图片加载完成
      } else {
        return Center(child: Text('加载失败'));
      }
    },
  );
}
