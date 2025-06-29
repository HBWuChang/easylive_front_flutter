import 'dart:async';
import 'package:easylive/Funcs.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/settings.dart';
import 'package:easylive/widgets.dart';
import 'package:easylive/widgets/HighlightText.dart';
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
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 视频信息展示组件
class VideoInfoWidget extends StatefulWidget {
  final VideoInfo video;
  const VideoInfoWidget({required this.video, Key? key}) : super(key: key);
  @override
  State<VideoInfoWidget> createState() => _VideoInfoWidgetState();
}

class _VideoInfoWidgetState extends State<VideoInfoWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HoverFollowWidget(
            maxOffset: 12.w,
            child: MouseRegion(
              onEnter: (_) => setState(() => _hovered = true),
              onExit: (_) => setState(() => _hovered = false),
              child: AnimatedScale(
                scale: _hovered ? 1.05 : 1.0,
                duration: Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final videoId = widget.video.videoId;
                        if (videoId != null) {
                          Get.find<AppBarController>()
                              .extendBodyBehindAppBar
                              .value = false;
                          Get.toNamed('${Routes.videoPlayPage}/$videoId',
                              id: Routes.mainGetId);
                        }
                      },
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: widget.video.videoCover != null &&
                                  widget.video.videoCover!.isNotEmpty
                              ? ExtendedImage.network(
                                  Constants.baseUrl +
                                      ApiAddr.fileGetResourcet +
                                      widget.video.videoCover!,
                                  fit: BoxFit.cover,
                                )
                              : Container(color: Colors.grey[200]),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 38.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(8.r)),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7)
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8.w,
                      bottom: 8.w,
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow,
                              color: Colors.white, size: 16.w),
                          SizedBox(width: 2.w),
                          Text(
                            (widget.video.playCount ?? 0).toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 2.r)
                                ]),
                          ),
                          SizedBox(width: 10.w),
                          Icon(Icons.subtitles,
                              color: Colors.white, size: 16.w),
                          SizedBox(width: 2.w),
                          Text(
                            (widget.video.danmuCount ?? 0).toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 2.r)
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
        SizedBox(height: 4.w),
        HoverFollowWidget(
            child: HighlightText(
          text: widget.video.videoName ?? '',
          maxLines: 1,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
              color: Theme.of(context).colorScheme.tertiary),
          highlightStyle: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15.sp,
            color: Theme.of(context).primaryColor,
          ),
        )),
        HoverFollowWidget(
            maxOffset: 8.w,
            child: Row(
              children: [
                TextButton.icon(
                    style: ButtonStyle(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    icon: Icon(Icons.person, size: 14.w, color: Colors.grey),
                    onPressed: () {
                      Get.toNamed('${Routes.uhome}/${widget.video.userId}',
                          id: Routes.mainGetId);
                    },
                    label: Text(
                      widget.video.nickName ?? '',
                      style:
                          TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                    )),
                SizedBox(width: 10.w),
                Icon(Icons.access_time, size: 14.w, color: Colors.grey),
                SizedBox(width: 3.w),
                SelectableText(
                  widget.video.createTime != null
                      ? _formatDate(widget.video.createTime!)
                      : '',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                ),
              ],
            )),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}

// 横向视频信息组件
class VideoInfoWidgetHorizon extends StatefulWidget {
  final VideoInfo video;
  final bool big;
  const VideoInfoWidgetHorizon(
      {required this.video, this.big = false, Key? key})
      : super(key: key);

  @override
  State<VideoInfoWidgetHorizon> createState() => _VideoInfoWidgetHorizonState();
}

class _VideoInfoWidgetHorizonState extends State<VideoInfoWidgetHorizon> {
  final RxBool hovered = false.obs;
  double get rate => widget.big ? 1.67 : 1;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => hovered.value = true,
      onExit: (_) => hovered.value = false,
      child: GestureDetector(
          onTap: () {
            final videoId = widget.video.videoId;
            if (videoId != null) {
              Get.find<AppBarController>().needRemove++;
              Get.toNamed('${Routes.videoPlayPage}/$videoId',
                  id: Routes.mainGetId);
            }
          },
          child: Obx(() => AnimatedContainer(
                duration: Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: hovered.value
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10 * rate.r),
                ),
                child: SizedBox(
                  height: 110 * rate.w,
                  child: Row(
                    children: [
                      // 左侧封面
                      Expanded(
                        flex: 2,
                        child: HoverFollowWidget(
                            child: MouseRegion(
                          onEnter: (_) => hovered.value = true,
                          onExit: (_) => hovered.value = false,
                          child: Obx(() => AnimatedScale(
                                scale: hovered.value ? 1.05 : 1.0,
                                duration: Duration(milliseconds: 220),
                                curve: Curves.easeOutCubic,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Stack(
                                    children: [
                                      AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: widget.video.videoCover !=
                                                    null &&
                                                widget.video.videoCover!
                                                    .isNotEmpty
                                            ? ExtendedImage.network(
                                                Constants.baseUrl +
                                                    ApiAddr.fileGetResourcet +
                                                    widget.video.videoCover!,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                color: Colors.grey[200]),
                                      ),
                                      // 下方黑色渐变阴影
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        height: 36 * rate.w,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.vertical(
                                                bottom: Radius.circular(
                                                    8 * rate.r)),
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.transparent,
                                                Colors.black.withOpacity(0.7)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      // 视频时长，右下角
                                      Positioned(
                                        right: 8 * rate.w,
                                        bottom: 8 * rate.w,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6 * rate,
                                              vertical: 2 * rate),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(
                                                6 * rate.r),
                                          ),
                                          child: SelectableText(
                                            toShowdurationText(
                                                widget.video.duration ?? 0),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12 * rate.sp),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        )),
                      ),
                      SizedBox(width: 12 * rate.w),
                      // 右侧信息
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 标题，两行
                            HoverFollowWidget(
                                maxOffset: 4 * rate,
                                child: SizedBox(
                                  height: 40 * rate.w,
                                  child: HighlightText(
                                    text: widget.video.videoName ?? '',
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15 * rate.sp),
                                    highlightStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15 * rate.sp,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                )),
                            SizedBox(height: 4 * rate.w),
                            // up主
                            HoverFollowWidget(
                                child: TextButton.icon(
                                    icon: Icon(Icons.person,
                                        size: 14 * rate.w, color: Colors.grey),
                                    onPressed: () {
                                      Get.toNamed(
                                          '${Routes.uhome}/${widget.video.userId}',
                                          id: Routes.mainGetId);
                                    },
                                    label: SelectableText(
                                      widget.video.nickName ?? '',
                                      style: TextStyle(
                                          fontSize: 13 * rate.sp,
                                          color: Colors.grey[700]),
                                      // overflow: TextOverflow.ellipsis,
                                    ))),
                            SizedBox(height: 4 * rate.w),
                            // 播放量和弹幕
                            HoverFollowWidget(
                                child: Row(
                              children: [
                                SizedBox(width: 12 * rate.w),
                                Icon(Icons.play_arrow,
                                    size: 14 * rate.w, color: Colors.grey),
                                SizedBox(width: 2 * rate.w),
                                SelectableText(
                                  (widget.video.playCount ?? 0).toString(),
                                  style: TextStyle(
                                      fontSize: 13 * rate.sp,
                                      color: Colors.grey[700]),
                                ),
                                SizedBox(width: 10 * rate.w),
                                Icon(Icons.subtitles,
                                    size: 14 * rate, color: Colors.grey),
                                SizedBox(width: 2 * rate.w),
                                SelectableText(
                                  (widget.video.danmuCount ?? 0).toString(),
                                  style: TextStyle(
                                      fontSize: 13 * rate.sp,
                                      color: Colors.grey[700]),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ))),
    );
  }
}
