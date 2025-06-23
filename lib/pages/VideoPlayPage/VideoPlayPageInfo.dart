import 'dart:async';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:easylive/Funcs.dart';
import 'package:easylive/controllers/LocalSettingsController.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/pages/MainPage/VideoInfoWidget.dart';
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
import 'VideoPlayPageInfoWidgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoPlayPageInfo extends StatelessWidget {
  final String videoId;
  final RxBool expandInfo = false.obs; // 是否展开更多信息
  final RxBool showFab = false.obs; // 控制FAB显示
  VideoPlayPageInfo({required this.videoId, super.key});

  @override
  Widget build(BuildContext context) {
    VideoLoadVideoPListController videoLoadVideoPListController =
        Get.find<VideoLoadVideoPListController>(
            tag: '${videoId}VideoLoadVideoPListController');
    VideoGetVideoRecommendController videoGetVideoRecommendController;
    if (Get.isRegistered<VideoGetVideoRecommendController>(
        tag: '${videoId}VideoGetVideoRecommendController')) {
      videoGetVideoRecommendController =
          Get.find<VideoGetVideoRecommendController>(
              tag: '${videoId}VideoGetVideoRecommendController');
    } else {
      videoGetVideoRecommendController = Get.put(
          VideoGetVideoRecommendController(),
          tag: '${videoId}VideoGetVideoRecommendController',
          permanent: true);
    }
    final infoColor1 = Theme.of(context).colorScheme.secondary;
    final infoColor2 = Theme.of(context).colorScheme.tertiary;
    final ScrollController scrollController = ScrollController(); // 用于监听滚动事件
    // 监听滚动
    scrollController.addListener(() {
      showFab.value = scrollController.offset > 50;
    });
    // 直接使用已在 VideoPlayPage put 的 controller
    return Scaffold(
      body: GetBuilder<VideoGetVideoInfoController>(
          tag: '${videoId}VideoGetVideoInfoController',
          builder: (videoGetVideoInfoController) => Obx(() {
                if (videoGetVideoInfoController.isLoading.value) {
                  return CircularProgressIndicator();
                } else {
                  UhomeGetUserInfoController uhomeGetUserInfoController =
                      UhomeGetUserInfoController();
                  uhomeGetUserInfoController.getUserInfo(
                      videoGetVideoInfoController.videoInfo.value.userId ?? '');
                  return SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SizedBox(
                                height: 54.w,
                                child: Row(
                                  children: [
                                    SizedBox(
                                        width: 54.w,
                                        child: Avatar(
                                            userId: videoGetVideoInfoController
                                                .videoInfo.value.userId,
                                            avatarValue:
                                                videoGetVideoInfoController
                                                        .videoInfo
                                                        .value
                                                        .avatar ??
                                                    '',
                                            radius: 27.r)),
                                    SizedBox(
                                        width: 300.w,
                                        child: ListTile(
                                          hoverColor: Colors.transparent,
                                          onTap: () {
                                            // 跳转到用户主页
                                            Get.toNamed(
                                                '/uhome/${videoGetVideoInfoController.videoInfo.value.userId}',
                                                id: Routes.mainGetId);
                                          },
                                          title: Text(
                                            videoGetVideoInfoController
                                                    .videoInfo.value.nickName ??
                                                '',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                            ),
                                          ),
                                          subtitle: Obx(() => Text(
                                                '${toShowNumText(uhomeGetUserInfoController.userInfo.value.fansCount ?? 0)}粉丝·${toShowNumText(uhomeGetUserInfoController.userInfo.value.likeCount ?? 0)}点赞',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              )),
                                          trailing: Obx(() => ElevatedButton(
                                                onPressed: () async {
                                                  if (uhomeGetUserInfoController
                                                      .userInfo
                                                      .value
                                                      .haveFocus) {
                                                    // 取消关注
                                                    var res = await ApiService
                                                        .uhomeCancelFocus(
                                                            videoGetVideoInfoController
                                                                .videoInfo
                                                                .value
                                                                .userId!);
                                                    showResSnackbar(res);
                                                  } else {
                                                    // 关注
                                                    var res = await ApiService
                                                        .uhomeFocus(
                                                            videoGetVideoInfoController
                                                                .videoInfo
                                                                .value
                                                                .userId!);
                                                    showResSnackbar(res);
                                                  }
                                                  uhomeGetUserInfoController
                                                      .getUserInfo(
                                                          videoGetVideoInfoController
                                                                  .videoInfo
                                                                  .value
                                                                  .userId ??
                                                              '');
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.r),
                                                  ),
                                                  backgroundColor:
                                                      uhomeGetUserInfoController
                                                              .userInfo
                                                              .value
                                                              .haveFocus
                                                          ? Colors.grey[200]
                                                          : null,
                                                  foregroundColor:
                                                      uhomeGetUserInfoController
                                                              .userInfo
                                                              .value
                                                              .haveFocus
                                                          ? Colors.black87
                                                          : null,
                                                  elevation:
                                                      uhomeGetUserInfoController
                                                              .userInfo
                                                              .value
                                                              .haveFocus
                                                          ? 0
                                                          : 2,
                                                ),
                                                child: Text(
                                                  uhomeGetUserInfoController
                                                          .userInfo
                                                          .value
                                                          .haveFocus
                                                      ? '已关注'
                                                      : '关注',
                                                  style: TextStyle(
                                                      fontSize: 16.sp),
                                                ),
                                              )),
                                        )),
                                  ],
                                )),
                          ),
                          Stack(children: [
                            Padding(
                              padding: const EdgeInsets.all(0.0),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    SizedBox(
                                        width: 300.w,
                                        child: Obx(() => Text(
                                              videoGetVideoInfoController
                                                      .videoInfo
                                                      .value
                                                      .videoName ??
                                                  '',
                                              style: TextStyle(
                                                  fontSize: 18.sp,
                                                  fontWeight: FontWeight.bold),
                                              maxLines:
                                                  expandInfo.value ? null : 1,
                                              overflow: expandInfo.value
                                                  ? TextOverflow.visible
                                                  : TextOverflow.ellipsis,
                                            )))
                                  ],
                                ),
                                subtitle: Obx(() => Column(children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.play_arrow_rounded,
                                            color: infoColor1,
                                            size: 14,
                                          ),
                                          Text(
                                            ' ${toShowNumText(videoGetVideoInfoController.videoInfo.value.playCount ?? 0)}',
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                color: infoColor1),
                                          ),
                                          SizedBox(width: 16),
                                          Icon(
                                            Icons.subtitles,
                                            color: infoColor1,
                                            size: 14,
                                          ),
                                          Text(
                                            ' ${toShowNumText(videoGetVideoInfoController.videoInfo.value.danmuCount ?? 0)}',
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                color: infoColor1),
                                          ),
                                          SizedBox(width: 16),
                                          // 创建时间
                                          Icon(
                                            Icons.query_builder,
                                            color: infoColor1,
                                            size: 14,
                                          ),
                                          if ((videoGetVideoInfoController
                                                      .videoInfo
                                                      .value
                                                      .createTime
                                                      .toString() ??
                                                  '')
                                              .isNotEmpty)
                                            Text(
                                              '${(videoGetVideoInfoController.videoInfo.value.createTime ?? '')}'
                                                  .substring(0, 19),
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: infoColor1),
                                            ),
                                        ],
                                      ),
                                      if (expandInfo.value)
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              videoGetVideoInfoController
                                                      .videoInfo
                                                      .value
                                                      .videoId ??
                                                  '',
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: infoColor1),
                                            )),
                                      if (expandInfo.value) SizedBox(height: 6),
                                      if (expandInfo.value)
                                        Align(
                                            alignment: Alignment.centerLeft,
                                            child: _buildIntroductionText(
                                              videoGetVideoInfoController
                                                      .videoInfo
                                                      .value
                                                      .introduction ??
                                                  '',
                                              infoColor2,
                                            )),
                                    ])),
                              ),
                            ),
                            Positioned(
                                top: 8,
                                right: 0,
                                child: Obx(
                                  () => TextButton.icon(
                                    iconAlignment: IconAlignment.end,
                                    onPressed: () {
                                      expandInfo.value = !expandInfo.value;
                                    },
                                    label: Text(
                                      expandInfo.value ? '收起' : '展开',
                                      style: TextStyle(fontSize: 16.sp),
                                    ),
                                    icon: AnimatedRotation(
                                      turns: expandInfo.value
                                          ? 0.5
                                          : 0.0, // 0.5圈=180度
                                      duration: Duration(milliseconds: 200),
                                      child: Icon(
                                        Icons.expand_more,
                                        size: 20.sp,
                                      ),
                                    ),
                                  ),
                                ))
                          ]),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32.0.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // 点赞按钮
                                btnsWithCount(
                                    ParticleIconButton(
                                      isActive:
                                          videoGetVideoInfoController.hasLike,
                                      icon: Icon(Icons.thumb_up,
                                          size: 26.w,
                                          color: videoGetVideoInfoController
                                                  .hasLike
                                              ? Colors.pink
                                              : Colors.grey),
                                      particleColor: Colors.pinkAccent,
                                      onPressed: () async {
                                        var res =
                                            await ApiService.userActionDoAction(
                                                videoId: videoId,
                                                actionType: UserActionEnum
                                                    .VIDEO_LIKE.type);
                                        showResSnackbar(res,
                                            notShowIfSuccess: true);
                                        videoGetVideoInfoController
                                            .loadVideoInfo(videoId);
                                      },
                                    ),
                                    count: videoGetVideoInfoController
                                        .videoInfo.value.likeCount,
                                    text: '点赞'),
                                // 投币按钮
                                btnsWithCount(
                                  ParticleIconButton(
                                    isActive:
                                        videoGetVideoInfoController.hasCoin,
                                    icon: Obx(() => SvgPicture.string(
                                          Constants.Coin_svg,
                                          height: 26.w,
                                          width: 26.w,
                                          colorFilter:
                                              videoGetVideoInfoController
                                                      .hasCoin
                                                  ? ColorFilter.mode(
                                                      Colors.pink,
                                                      BlendMode.srcIn)
                                                  : ColorFilter.mode(
                                                      Colors.grey,
                                                      BlendMode.srcIn),
                                        )),
                                    particleColor: Colors.pinkAccent,
                                    onPressed: () async {
                                      final coin = await showCoinDialog();
                                      // 这里可根据 coin 进行后续操作
                                      if (coin != null) {
                                        var res =
                                            await ApiService.userActionDoAction(
                                                videoId: videoId,
                                                actionType: UserActionEnum
                                                    .VIDEO_COIN.type,
                                                actionCount: coin['coins']);
                                        showResSnackbar(res,
                                            notShowIfSuccess: true);
                                        if (coin['like'] &&
                                            !videoGetVideoInfoController
                                                .hasLike) {
                                          var res = await ApiService
                                              .userActionDoAction(
                                                  videoId: videoId,
                                                  actionType: UserActionEnum
                                                      .VIDEO_LIKE.type);
                                          showResSnackbar(res,
                                              notShowIfSuccess: true);
                                        }
                                        videoGetVideoInfoController
                                            .loadVideoInfo(videoId);
                                      }
                                    },
                                  ),
                                  count: videoGetVideoInfoController
                                      .videoInfo.value.coinCount,
                                  text: '投币',
                                ), // 收藏按钮
                                btnsWithCount(
                                    ParticleIconButton(
                                      isActive: videoGetVideoInfoController
                                          .hasCollect,
                                      icon: Obx(() => Icon(
                                            size: 26.w,
                                            Icons.star_rate_rounded,
                                            color: videoGetVideoInfoController
                                                    .hasCollect
                                                ? Colors.pink
                                                : Colors.grey,
                                          )),
                                      particleColor: Colors.pinkAccent,
                                      onPressed: () async {
                                        var res =
                                            await ApiService.userActionDoAction(
                                                videoId: videoId,
                                                actionType: UserActionEnum
                                                    .VIDEO_COLLECT.type);
                                        showResSnackbar(res,
                                            notShowIfSuccess: true);
                                        videoGetVideoInfoController
                                            .loadVideoInfo(videoId);
                                      },
                                    ),
                                    count: videoGetVideoInfoController
                                        .videoInfo.value.collectCount,
                                    text: '收藏'),
                                btnsWithCount(
                                    IconButton(
                                        onPressed: () {},
                                        // 分享
                                        icon: Icon(
                                            Icons
                                                .switch_access_shortcut_add_rounded,
                                            size: 24.w,
                                            color: Colors.grey)),
                                    text: '分享'),
                              ],
                            ),
                          ),
                          SizedBox(height: 16.w),
                          if (videoLoadVideoPListController.multi)
                            DividerWithPaddingHorizontal(),
                          if (videoLoadVideoPListController.multi)
                            Obx(() => Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: SizedBox(
                                  height: 300.w,
                                  child: Card(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainer,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(14.0),
                                              child: Text(
                                                '视频选集(${videoLoadVideoPListController.selectFileIndex + 1}/${videoLoadVideoPListController.videoPList.length})',
                                                style:
                                                    TextStyle(fontSize: 16.sp),
                                              ),
                                            ),
                                            Obx(() => IconButton(
                                                  icon: Icon(
                                                    Get.find<LocalSettingsController>()
                                                                .settings[
                                                            'listOrGrid']
                                                        ? Icons.list
                                                        : Icons.grid_view,
                                                    size: 20,
                                                  ),
                                                  onPressed: () {
                                                    Get.find<LocalSettingsController>()
                                                            .settings[
                                                        'listOrGrid'] = !Get.find<
                                                            LocalSettingsController>()
                                                        .settings['listOrGrid'];
                                                  },
                                                )),
                                          ],
                                        ),
                                        DividerWithPaddingHorizontal(),
                                        Expanded(
                                          child: Obx(() {
                                            if (Get.find<
                                                    LocalSettingsController>()
                                                .settings['listOrGrid']) {
                                              return ListView.builder(
                                                itemCount:
                                                    videoLoadVideoPListController
                                                        .videoPList.length,
                                                itemBuilder: (context, index) {
                                                  final videoP =
                                                      videoLoadVideoPListController
                                                          .videoPList[index];
                                                  final isSelected =
                                                      videoLoadVideoPListController
                                                              .selectFileId
                                                              .value ==
                                                          videoP.fileId;
                                                  return ListTile(
                                                    title: Text(
                                                      videoP.fileName ?? '',
                                                      style: TextStyle(
                                                        color: isSelected
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                            : null,
                                                      ),
                                                    ),
                                                    trailing: Text(
                                                        textAlign:
                                                            TextAlign.end,
                                                        toShowdurationText(
                                                            videoP.duration ??
                                                                0)),
                                                    onTap: () {
                                                      videoLoadVideoPListController
                                                              .selectFileId
                                                              .value =
                                                          videoP.fileId ?? '';
                                                    },
                                                  );
                                                },
                                              );
                                            } else {
                                              return GridView.builder(
                                                gridDelegate:
                                                    SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 5,
                                                  childAspectRatio: 1,
                                                ),
                                                itemCount:
                                                    videoLoadVideoPListController
                                                        .videoPList.length,
                                                itemBuilder: (context, index) {
                                                  final videoP =
                                                      videoLoadVideoPListController
                                                          .videoPList[index];
                                                  final isSelected =
                                                      videoLoadVideoPListController
                                                              .selectFileId
                                                              .value ==
                                                          videoP.fileId;
                                                  return Card(
                                                      color: isSelected
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .primaryContainer
                                                          : null,
                                                      child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.r),
                                                          clipBehavior:
                                                              Clip.hardEdge,
                                                          child: InkWell(
                                                            onTap: () {
                                                              videoLoadVideoPListController
                                                                  .selectFileId
                                                                  .value = videoP
                                                                      .fileId ??
                                                                  '';
                                                            },
                                                            child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                child: Center(
                                                                  child: Text(
                                                                    '$index',
                                                                    style:
                                                                        TextStyle(
                                                                      color: isSelected
                                                                          ? Theme.of(context)
                                                                              .colorScheme
                                                                              .onPrimaryContainer
                                                                          : null,
                                                                    ),
                                                                  ),
                                                                )),
                                                          )));
                                                },
                                              );
                                            }
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ))),
                          DividerWithPaddingHorizontal(),

                          Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Obx(() => ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: videoGetVideoRecommendController
                                        .videoRecommendList.length,
                                    itemBuilder: (context, index) {
                                      return VideoInfoWidgetHorizon(
                                          video:
                                              videoGetVideoRecommendController
                                                  .videoRecommendList[index]);
                                    },
                                  ))),
                          // 可扩展更多分P信息
                        ],
                      ));
                }
              })),
      floatingActionButton: Obx(() => showFab.value
          ? FloatingActionButton(
              mini: true,
              onPressed: () {
                scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: HoverFollowWidget(child: Icon(Icons.arrow_upward)),
            )
          : SizedBox.shrink()),
    );
  }

  Widget btnsWithCount(Widget btn, {int? count, String? text}) {
    return SizedBox(
        width: 60.w,
        height: 64.w,
        child: Tooltip(
          message: text ?? '',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              HoverFollowWidget(child: btn),
              if (count != null)
                Text(
                  toShowNumText(count),
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                )
              else if (text != null)
                Text(
                  text,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                )
            ],
          ),
        ));
  }

  Widget _buildIntroductionText(String text, Color color) {
    final urlReg = RegExp(r'(https?://[\w\-._~:/?#\[\]@!$&()*+,;=%]+)');
    final spans = <TextSpan>[];
    int start = 0;
    for (final match in urlReg.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(
            text: text.substring(start, match.start),
            style: TextStyle(fontSize: 12.sp, color: color)));
      }
      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(Get.context!).colorScheme.primary,
            decoration: TextDecoration.underline),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final uri = Uri.parse(url);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
      ));
      start = match.end;
    }
    if (start < text.length) {
      spans.add(TextSpan(
          text: text.substring(start),
          style: TextStyle(fontSize: 12.sp, color: color)));
    }
    return Text.rich(TextSpan(children: spans));
  }
}
