import 'dart:async';
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
import 'VideoPlayPageInfoWidgets.dart';
import 'package:flutter_barrage_craft/flutter_barrage_craft.dart';

class VideoPlayPage extends StatelessWidget {
  const VideoPlayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    print('当前路由名称: $routeName');
    final videoId = toParameters(routeName!)?['videoId'];
    // put 前判断是否已存在对应 tag 的 controller，若存在则不再 put
    CommentController commentController;
    if (Get.isRegistered<CommentController>(
        tag: '${videoId!}CommentController')) {
      commentController =
          Get.find<CommentController>(tag: '${videoId}CommentController');
    } else {
      commentController =
          Get.put(CommentController(), tag: '${videoId}CommentController');
      commentController.setVideoId(videoId);
      commentController.loadComments();
    }
    VideoGetVideoInfoController videoGetVideoInfoController;
    if (Get.isRegistered<VideoGetVideoInfoController>(
        tag: '${videoId}VideoGetVideoInfoController')) {
      videoGetVideoInfoController = Get.find<VideoGetVideoInfoController>(
          tag: '${videoId}VideoGetVideoInfoController');
    } else {
      videoGetVideoInfoController = Get.put(VideoGetVideoInfoController(),
          tag: '${videoId}VideoGetVideoInfoController');
      videoGetVideoInfoController.loadVideoInfo(videoId, routeName: routeName);
    }

    if (Get.isRegistered<VideoLoadVideoPListController>(
        tag: '${videoId}VideoLoadVideoPListController')) {
    } else {
      Get.put(VideoLoadVideoPListController(videoId),
          tag: '${videoId}VideoLoadVideoPListController');
    }

    return GetBuilder<VideoLoadVideoPListController>(
        tag: '${videoId}VideoLoadVideoPListController',
        builder: (videoLoadVideoPListController) {
          if (videoLoadVideoPListController.isLoading.value) {
            return CircularProgressIndicator();
          } else {
            final RxInt nowTabIndex = 0.obs;
            final pageController = PreloadPageController(initialPage: 0);
            // 新增：侧边栏显示控制
            final RxBool showSidebar = true.obs;
            return Obx(() => Row(children: [
                  // 左侧：视频播放器
                  Expanded(
                      child: VideoPlayerWidget(
                          videoId: videoId,
                          fileId:
                              videoLoadVideoPListController.selectFileId.value,
                          showSidebar: showSidebar)),
                  // 右侧：分P信息（简介/评论）
                  AnimatedContainer(
                    duration: Duration(milliseconds: 150),
                    width: showSidebar.value ? 400 : 0,
                    child: showSidebar.value
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 顶部按钮栏和横条
                              SizedBox(
                                  height: 38,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                            width: 200,
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 30,
                                                  child: Row(children: [
                                                    Expanded(
                                                      child: TextButton(
                                                        onPressed: () {
                                                          pageController
                                                              .animateToPage(
                                                            0,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    300),
                                                            curve: Curves.ease,
                                                          );
                                                        },
                                                        child: Text(
                                                          '简介',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: TextButton(
                                                        onPressed: () {
                                                          pageController
                                                              .animateToPage(
                                                            1,
                                                            duration: Duration(
                                                                milliseconds:
                                                                    300),
                                                            curve: Curves.ease,
                                                          );
                                                        },
                                                        child: Obx(() => Text(
                                                              '评论 ${commentController.commentDataTotalCount.value}',
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                              ),
                                                            )),
                                                      ),
                                                    )
                                                  ]),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                  child: LayoutBuilder(
                                                    builder:
                                                        (context, constraints) {
                                                      return AnimatedBuilder(
                                                        animation:
                                                            pageController,
                                                        builder:
                                                            (context, child) {
                                                          double page = 0.0;
                                                          try {
                                                            page = pageController
                                                                        .hasClients &&
                                                                    pageController
                                                                            .page !=
                                                                        null
                                                                ? pageController
                                                                    .page!
                                                                : pageController
                                                                    .initialPage
                                                                    .toDouble();
                                                          } catch (_) {}
                                                          double width =
                                                              constraints
                                                                      .maxWidth /
                                                                  2;
                                                          double minLine =
                                                              width * 0.7;
                                                          double maxLine =
                                                              width * 1.4;
                                                          double progress =
                                                              (page - page.floor())
                                                                  .abs();
                                                          double dist =
                                                              (progress > 0.5)
                                                                  ? 1 - progress
                                                                  : progress;
                                                          double lineWidth =
                                                              minLine +
                                                                  (maxLine -
                                                                          minLine) *
                                                                      (dist *
                                                                          2);
                                                          double left = page *
                                                                  width +
                                                              (width -
                                                                      lineWidth) /
                                                                  2;
                                                          return Stack(
                                                            children: [
                                                              Positioned(
                                                                left: left,
                                                                width:
                                                                    lineWidth,
                                                                top: 0,
                                                                bottom: 0,
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(2),
                                                                    color: Theme.of(
                                                                            context)
                                                                        .colorScheme
                                                                        .primary,
                                                                  ),
                                                                  height: 4,
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )),
                                        SizedBox(
                                            width: 50,
                                            child: IconButton(
                                              icon: Icon(
                                                Icons.more_vert,
                                                size: 20,
                                              ),
                                              onPressed: () {},
                                            ))
                                      ])),
                              DividerWithPaddingHorizontal(padding: 0),
                              // 内容区 PreloadPageView
                              Expanded(
                                child: PreloadPageView.builder(
                                  controller: pageController,
                                  itemCount: 2,
                                  preloadPagesCount: 2,
                                  physics: BouncingScrollPhysics(),
                                  onPageChanged: (tabIndex) {
                                    nowTabIndex.value = tabIndex;
                                  },
                                  itemBuilder: (context, tabIndex) {
                                    if (tabIndex == 0) {
                                      return VideoPlayPageInfo(
                                        videoId: videoId,
                                      );
                                    } else {
                                      return VideoPlayPageComments(
                                          videoId: videoId);
                                    }
                                  },
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                ]));
          }
        });
  }
}

// 新增：视频播放器组件
class VideoPlayerWidget extends StatefulWidget {
  final String videoId;
  final String fileId;
  final RxBool showSidebar;
  const VideoPlayerWidget(
      {required this.videoId,
      required this.fileId,
      required this.showSidebar,
      Key? key})
      : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final Player player;
  late final VideoController controller;
  late final VideoDamnuController videoDamnuController;
  final TextEditingController textEditingController = TextEditingController();
  FocusNode focusNode = FocusNode();
  DateTime? lastSendTime;
  final RxBool isSending = false.obs;
  @override
  void initState() {
    super.initState();
    player = Player(
        configuration: PlayerConfiguration(
            // 其他配置项
            ));
    Get.find<AppBarController>().playerList.add(player);
    controller = VideoController(player);
    // videoDamnuController =
    //     VideoDamnuController(videoId: widget.videoId, fileId: widget.fileId);
    videoDamnuController = Get.put(
        VideoDamnuController(videoId: widget.videoId, fileId: widget.fileId),
        tag: '${widget.videoId}VideoDamnuController');
    _openVideo();
    focusNode.addListener(() {
      if (focusNode.hasFocus && player.state.playing) {
        player.pause();
      }
    });
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fileId != widget.fileId) {
      _openVideo();
      videoDamnuController.videoId = widget.videoId;
      videoDamnuController.fileId = widget.fileId;
      videoDamnuController.loadDanmu();
    }
  }

  void _openVideo() {
    final url =
        ApiService.baseUrl + '/file/videoResource/' + widget.fileId + '/';
    player.open(
      Media(url, httpHeaders: {
        'token-xuan': Get.find<AccountController>().token ?? '',
        'cookie': Get.find<AccountController>().token != null
            ? 'token-xuan=${Get.find<AccountController>().token}'
            : '',
      }),
    );
  }

  @override
  void dispose() {
    player.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void sendDanmu() async {
    if (isSending.value) {
      Get.snackbar('どうやら壊れたようです。', '发送失败，请稍后再试');
      return;
    }
    try {
      String text = textEditingController.text.trim();
      int time =
          (controller.player.state.position.inMilliseconds / 1000).round();
      if (text.isEmpty) {
        throw Exception('弹幕内容不能为空');
      }
      isSending.value = true;
      videoDamnuController.postDanmu(
          text, DanmuModeEnum.NORMAL.type, 'FFFFFF', time);
      textEditingController.clear();
      await Future.delayed(Duration(seconds: 5));
    } catch (e) {
      Get.snackbar('发送弹幕失败', e.toString());
    } finally {
      isSending.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    MaterialDesktopVideoControlsThemeData t({bool fullscreen = false}) =>
        MaterialDesktopVideoControlsThemeData(
            toggleFullscreenOnDoublePress: true,
            playAndPauseOnTap: true,
            controlsHoverDuration: Duration(seconds: 2),
            seekBarColor: Theme.of(context).colorScheme.primary,
            seekBarThumbColor: Theme.of(context).colorScheme.primary,
            seekBarPositionColor: Theme.of(context).colorScheme.primary,
            bottomButtonBar: [
              // MaterialDesktopSkipPreviousButton(),
              MaterialDesktopPlayOrPauseButton(),
              // MaterialDesktopSkipNextButton(),
              MaterialDesktopVolumeButton(),
              MaterialDesktopPositionIndicator(),
              Spacer(),
              SizedBox(
                  width: 400,
                  height: 40,
                  child: TextField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: '发送弹幕',
                      hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7)),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Theme.of(context)
                          .colorScheme
                          .surface
                          .withOpacity(0.3),
                      prefixIcon: IconButton(
                        icon: Text('A',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary)),
                        onPressed: () {},
                      ),
                      suffixIcon: Obx(() => IconButton(
                            icon: Icon(
                              Icons.send,
                              color: isSending.value
                                  ? Theme.of(context).disabledColor
                                  : Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: isSending.value
                                ? null
                                : () {
                                    sendDanmu();
                                  },
                          )),
                    ),
                    onSubmitted: (text) {
                      sendDanmu();
                    },
                  )),
              Spacer(),
              if (!fullscreen)
                MaterialDesktopCustomButton(
                    icon: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: SizedBox(
                            width: 40,
                            height: 20,
                            child: Row(
                              children: [
                                Obx(() => Icon(
                                      widget.showSidebar.value
                                          ? Icons.chevron_left
                                          : Icons.chevron_right,
                                      size: 20,
                                    )),
                                Obx(() => Icon(
                                      widget.showSidebar.value
                                          ? Icons.chevron_right
                                          : Icons.chevron_left,
                                      size: 20,
                                    )),
                              ],
                            ))),
                    onPressed: () {
                      widget.showSidebar.value = !widget.showSidebar.value;
                    }),
              MaterialDesktopFullscreenButton()
            ],
            topButtonBar: [
              Obx(() => Text(
                  '${(Get.find<VideoNowWatchingCountController>().nowWatchingCountMap[widget.fileId] ?? 1).toString()} 人正在观看',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold))),
              Obx(() => Text(
                  videoDamnuController.danmus.length.toString() + ' 条弹幕',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)))
            ]);

    return MaterialDesktopVideoControlsTheme(
        normal: t(),
        fullscreen: t(fullscreen: true),
        child: Video(controller: controller));
  }
}
