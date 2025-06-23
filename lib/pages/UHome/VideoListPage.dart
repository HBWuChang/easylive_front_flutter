import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:easylive/Funcs.dart';
import 'package:easylive/controllers/VideoCommentController.dart';
import 'package:easylive/controllers/VideoDamnuController.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/pages/VideoPlayPage/VideoPlayPageComments.dart';
import 'package:easylive/pages/VideoPlayPage/VideoPlayPageInfo.dart';
import 'package:easylive/settings.dart';
import 'package:easylive/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controllers-class.dart';
import '../../api_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
// import 'package:iconify_flutter_plus/iconify_flutter_plus.dart'; // For Iconify Widget
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter_plus/icons/zondicons.dart'; // for Non Colorful Icons
import 'package:iconify_flutter/icons/tabler.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../../controllers/UhomeController.dart';
import '../MainPage/VideoInfoWidget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoListPage extends StatelessWidget {
  final userId;
  // 构建视频页面
  const VideoListPage({Key? key, this.userId}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    UHomeLoadVideoListController uHomeLoadVideoListController;
    if (Get.isRegistered<UHomeLoadVideoListController>(
        tag: '${userId}UHomeLoadVideoListController')) {
      uHomeLoadVideoListController = Get.find<UHomeLoadVideoListController>(
          tag: '${userId}UHomeLoadVideoListController');
    } else {
      uHomeLoadVideoListController = Get.put(
          UHomeLoadVideoListController(userId: userId),
          tag: '${userId}UHomeLoadVideoListController');
    }
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // 计算每行能显示多少个 Widget
              double availableWidth = constraints.maxWidth;
              int itemsPerRow = (availableWidth / 320).floor(); // 280 是期望的最小宽度
              if (itemsPerRow < 1) itemsPerRow = 1;

              // 计算每个 Widget 的实际宽度
              double itemWidth = (availableWidth - (itemsPerRow - 1) * 8) /
                  itemsPerRow; // 8是间距

              return Obx(() => Wrap(
                    spacing: 16.w, // 水平间距
                    runSpacing: 8.w, // 垂直间距
                    children: [
                      for (var video in uHomeLoadVideoListController.videoList)
                        Padding(
                            padding: EdgeInsets.all(4.0.w),
                            child: SizedBox(
                                width: itemWidth.w,
                                child: VideoInfoWidget(
                                  video: video,
                                )))
                    ],
                  ));
            },
          ),
          SizedBox(height: 24.w),
          // 分页组件
          Obx(() =>
              _buildPaginationWidget(context, uHomeLoadVideoListController)),
        ],
      ),
    );
  }

  // 构建分页组件
  Widget _buildPaginationWidget(
      BuildContext context, UHomeLoadVideoListController controller) {
    final TextEditingController _pageInputController = TextEditingController();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 上一页按钮
          _buildPageButton(
            context,
            '上一页',
            controller.pageNo.value > 1,
            () => _goToPage(controller, controller.pageNo.value - 1),
          ),
          SizedBox(width: 8),

          // 页码按钮区域
          ..._buildPageNumbers(context, controller),

          // 超过10页时显示输入框
          if (controller.pageTotal.value > 10) ...[
            SizedBox(width: 8),
            Container(
              width: 60.w,
              height: 32.w,
              child: TextField(
                controller: _pageInputController,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.sp),
                decoration: InputDecoration(
                  hintText: '页码',
                  hintStyle: TextStyle(fontSize: 10.sp),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide:
                        BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide:
                        BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                onSubmitted: (value) {
                  final page = int.tryParse(value);
                  if (page != null &&
                      page >= 1 &&
                      page <= controller.pageTotal.value) {
                    _goToPage(controller, page);
                    _pageInputController.clear();
                  }
                },
              ),
            ),
            SizedBox(width: 4),
            Text(
              '/ ${controller.pageTotal.value}',
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ],

          SizedBox(width: 8),
          // 下一页按钮
          _buildPageButton(
            context,
            '下一页',
            controller.pageNo.value < controller.pageTotal.value,
            () => _goToPage(controller, controller.pageNo.value + 1),
          ),
        ],
      ),
    );
  }

  // 构建页码按钮列表
  List<Widget> _buildPageNumbers(
      BuildContext context, UHomeLoadVideoListController controller) {
    List<Widget> pageButtons = [];
    int currentPage = controller.pageNo.value;
    int totalPages = controller.pageTotal.value;

    // 当页数较少时显示所有页码
    if (totalPages <= 7) {
      for (int i = 1; i <= totalPages; i++) {
        pageButtons.add(_buildPageNumberButton(context, controller, i));
        if (i < totalPages) pageButtons.add(SizedBox(width: 4));
      }
    } else {
      // 页数较多时的逻辑
      pageButtons.add(_buildPageNumberButton(context, controller, 1));

      if (currentPage > 4) {
        pageButtons.add(SizedBox(width: 4));
        pageButtons.add(_buildEllipsis(context));
      }

      int start = math.max(2, currentPage - 2);
      int end = math.min(totalPages - 1, currentPage + 2);

      for (int i = start; i <= end; i++) {
        pageButtons.add(SizedBox(width: 4));
        pageButtons.add(_buildPageNumberButton(context, controller, i));
      }

      if (currentPage < totalPages - 3) {
        pageButtons.add(SizedBox(width: 4));
        pageButtons.add(_buildEllipsis(context));
      }

      pageButtons.add(SizedBox(width: 4));
      pageButtons.add(_buildPageNumberButton(context, controller, totalPages));
    }

    return pageButtons;
  }

  // 构建单个页码按钮
  Widget _buildPageNumberButton(BuildContext context,
      UHomeLoadVideoListController controller, int pageNumber) {
    bool isCurrentPage = controller.pageNo.value == pageNumber;

    return Container(
      width: 32.w,
      height: 32.w,
      child: TextButton(
        onPressed:
            isCurrentPage ? null : () => _goToPage(controller, pageNumber),
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          backgroundColor: isCurrentPage
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.transparent,
          foregroundColor: isCurrentPage
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).textTheme.bodyMedium?.color,
        ),
        child: Text(
          pageNumber.toString(),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isCurrentPage ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // 构建省略号
  Widget _buildEllipsis(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.w,
      alignment: Alignment.center,
      child: Text(
        '...',
        style: TextStyle(
          fontSize: 12.sp,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
      ),
    );
  }

  // 构建分页按钮（上一页/下一页）
  Widget _buildPageButton(
      BuildContext context, String text, bool enabled, VoidCallback onPressed) {
    return Container(
      height: 32.w,
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          backgroundColor: enabled
              ? Theme.of(context).colorScheme.surface
              : Theme.of(context).disabledColor.withOpacity(0.05),
          foregroundColor: enabled
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).disabledColor,
          side: BorderSide(
            color: enabled
                ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
                : Theme.of(context).disabledColor.withOpacity(0.1),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // 跳转到指定页面
  void _goToPage(UHomeLoadVideoListController controller, int page) {
    if (page >= 1 &&
        page <= controller.pageTotal.value &&
        page != controller.pageNo.value) {
      controller.loadVideos(pageNo: page);
    }
  }
}
