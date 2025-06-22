import 'dart:async';
import 'package:easylive/Funcs.dart';
import 'package:easylive/enums.dart';
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
            maxOffset: 12,
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
                          borderRadius:
                              BorderRadius.vertical(bottom: Radius.circular(8.r)),
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
                      left: 8,
                      bottom: 8,
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow, color: Colors.white, size: 16),
                          SizedBox(width: 2.w),
                          Text(
                            (widget.video.playCount ?? 0).toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 2)
                                ]),
                          ),
                          SizedBox(width: 10.w),
                          Icon(Icons.subtitles, color: Colors.white, size: 16),
                          SizedBox(width: 2.w),
                          Text(
                            (widget.video.danmuCount ?? 0).toString(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 13.sp,
                                shadows: [
                                  Shadow(color: Colors.black, blurRadius: 2)
                                ]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
        SizedBox(height: 6.w),
        HoverFollowWidget(
            child: ExpandableText(
          text: widget.video.videoName ?? '',
          maxLines: 1,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
        )),
        SizedBox(height: 2),
        HoverFollowWidget(
            maxOffset: 8,
            child: Row(
              children: [
                TextButton.icon(
                    icon: Icon(Icons.person, size: 14, color: Colors.grey),
                    onPressed: () {
                      Get.toNamed('${Routes.uhome}/${widget.video.userId}',
                          id: Routes.mainGetId);
                    },
                    label: Text(
                      widget.video.nickName ?? '',
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
                      overflow: TextOverflow.ellipsis,
                    )),
                SizedBox(width: 10.w),
                Icon(Icons.access_time, size: 14, color: Colors.grey),
                SizedBox(width: 3.w),
                Text(
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
  const VideoInfoWidgetHorizon({required this.video, Key? key})
      : super(key: key);

  @override
  State<VideoInfoWidgetHorizon> createState() => _VideoInfoWidgetHorizonState();
}

class _VideoInfoWidgetHorizonState extends State<VideoInfoWidgetHorizon> {
  final RxBool hovered = false.obs;

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
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: SizedBox(
                  height: 110.w,
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
                                        height: 36.w,
                                        child: Container(
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
                                      // 视频时长，右下角
                                      Positioned(
                                        right: 8,
                                        bottom: 8,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius:
                                                BorderRadius.circular(6.r),
                                          ),
                                          child: Text(
                                            toShowdurationText(
                                                widget.video.duration ?? 0),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.sp),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        )),
                      ),
                      SizedBox(width: 12.w),
                      // 右侧信息
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 标题，两行
                            HoverFollowWidget(
                                maxOffset: 4,
                                child: SizedBox(
                                  height: 40.w,
                                  child: Text(
                                    widget.video.videoName ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15.sp),
                                  ),
                                )),
                            SizedBox(height: 4.w),
                            // up主
                            HoverFollowWidget(
                                child: TextButton.icon(
                                    icon: Icon(Icons.person,
                                        size: 14.w, color: Colors.grey),
                                    onPressed: () {
                                      Get.toNamed(
                                          '${Routes.uhome}/${widget.video.userId}',
                                          id: Routes.mainGetId);
                                    },
                                    label: Text(
                                      widget.video.nickName ?? '',
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.grey[700]),
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                            SizedBox(height: 4.w),
                            // 播放量和弹幕
                            HoverFollowWidget(
                                child: Row(
                              children: [
                                SizedBox(width: 12.w),
                                Icon(Icons.play_arrow,
                                    size: 14, color: Colors.grey),
                                SizedBox(width: 2.w),
                                Text(
                                  (widget.video.playCount ?? 0).toString(),
                                  style: TextStyle(
                                      fontSize: 13.sp, color: Colors.grey[700]),
                                ),
                                SizedBox(width: 10.w),
                                Icon(Icons.subtitles,
                                    size: 14, color: Colors.grey),
                                SizedBox(width: 2.w),
                                Text(
                                  (widget.video.danmuCount ?? 0).toString(),
                                  style: TextStyle(
                                      fontSize: 13.sp, color: Colors.grey[700]),
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
