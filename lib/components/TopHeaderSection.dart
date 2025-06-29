import 'package:flutter/material.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../settings.dart';
import '../api_service.dart';
import '../controllers/controllers-class.dart';

/// 顶部背景图组件，可复用于 MainPage 和 CategoryPage
class TopHeaderSection extends StatelessWidget {
  final double? height;
  
  const TopHeaderSection({
    Key? key,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appBarController = Get.find<AppBarController>();
    final headerHeight = height ?? appBarController.imgHeight.w;
    
    return SizedBox(
      height: headerHeight,
      width: double.infinity,
      child: Stack(
        children: [
          // 背景图
          ExtendedImage.network(
            Constants.baseUrl +
                ApiAddr.fileGetResourcet +
                ApiAddr.LoginBackGround,
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
          ),
          // 渐变遮罩
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
