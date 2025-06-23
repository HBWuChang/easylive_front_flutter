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
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class VideoPlayPage extends StatelessWidget {
  const VideoPlayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    print('当前路由名称: $routeName');
    final videoId = getLastPath(routeName!);
    // put 前判断是否已存在对应 tag 的 controller，若存在则不再 put
    CommentController commentController;
    if (Get.isRegistered<CommentController>(
        tag: '${videoId!}CommentController')) {
      commentController =
          Get.find<CommentController>(tag: '${videoId}CommentController');
    } else {
      commentController =
          Get.put(CommentController(), tag: '${videoId}CommentController',permanent: true);
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
          tag: '${videoId}VideoGetVideoInfoController',permanent: true);
      videoGetVideoInfoController.loadVideoInfo(videoId, routeName: routeName);
    }

    if (Get.isRegistered<VideoLoadVideoPListController>(
        tag: '${videoId}VideoLoadVideoPListController')) {
    } else {
      Get.put(VideoLoadVideoPListController(videoId),
          tag: '${videoId}VideoLoadVideoPListController',permanent: true);
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
                    width: (showSidebar.value ? 400 : 0).w,
                    child: showSidebar.value
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 顶部按钮栏和横条
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 200.w,
                                    child: Obx(() => AnimatedTabBarWidget(
                                      pageController: pageController,
                                      tabLabels: [
                                        TextSpan(text: '简介'),
                                        TextSpan(
                                          children: [
                                            TextSpan(text: '评论 '),
                                            TextSpan(
                                              text: '${commentController.commentDataTotalCount.value}',
                                            ),
                                          ],
                                        ),
                                      ],
                                    )),
                                  ),
                                  SizedBox(
                                    width: 50.w,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.more_vert,
                                        size: 20,
                                      ),
                                      onPressed: () {},
                                    ),
                                  ),
                                ],
                              ),
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
  late Widget damnuOverlay;
  late Widget fullscreenDamnuOverlay;
  GlobalKey danmuKey = GlobalKey();
  FocusNode focusNode = FocusNode();
  DateTime? lastSendTime;
  final RxBool isSending = false.obs;
  // 新增：弹幕样式选择
  int danmuMode = DanmuModeEnum.NORMAL.type;
  String danmuColor = 'FFFFFF';
  final TextEditingController colorController =
      TextEditingController(text: 'FFFFFF');
  final List<Color> presetColors = [
    Colors.white,
    Colors.black,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.pink,
    Colors.cyan,
    Colors.brown,
    Colors.grey,
  ];
  late RxBool barrageEnabled;
  final RxBool showDanmuPanel = false.obs;
  Timer? _danmuPanelTimer;
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
    barrageEnabled = videoDamnuController.barrageEnabled;
    damnuOverlay = DanmakuScreen(
        createdController: (e) {
          videoDamnuController.barrageController = e;
        },
        option: DanmakuOption(
          massiveMode: true,
          fontSize: videoDamnuController.fontSize.value.sp,
          opacity: videoDamnuController.opacity.value,
          area: videoDamnuController.area.value,
          hideScroll: !videoDamnuController.enableScroll.value,
          hideTop: !videoDamnuController.enableTop.value,
          hideBottom: !videoDamnuController.enableBottom.value,
          duration: videoDamnuController.duration.value.toInt(),
        ));
    fullscreenDamnuOverlay = DanmakuScreen(
      createdController: (e) {
        videoDamnuController.fullscreenBarrageController = e;
      },
      option: DanmakuOption(
        massiveMode: true,
        fontSize: videoDamnuController.fontSize.value.sp,
        opacity: videoDamnuController.opacity.value,
        area: videoDamnuController.area.value,
        hideScroll: !videoDamnuController.enableScroll.value,
        hideTop: !videoDamnuController.enableTop.value,
        hideBottom: !videoDamnuController.enableBottom.value,
        duration: videoDamnuController.duration.value.toInt(),
      ),
    );
    videoDamnuController.player = player;
    player.stream.playing.listen((playing) {
      if (playing) {
        videoDamnuController.resumeDanmu();
      } else {
        videoDamnuController.pauseDanmu();
      }
    });

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
      videoDamnuController.barrageController.clear();
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

  void _showDanmuPanel() {
    _danmuPanelTimer?.cancel();
    showDanmuPanel.value = true;
  }

  void _hideDanmuPanelWithDelay() {
    _danmuPanelTimer?.cancel();
    _danmuPanelTimer = Timer(Duration(milliseconds: 200), () {
      showDanmuPanel.value = false;
    });
  }

  void _cancelDanmuPanelTimer() {
    _danmuPanelTimer?.cancel();
  }

  @override
  void dispose() {
    player.dispose();
    focusNode.dispose();
    _danmuPanelTimer?.cancel();
    super.dispose();
  }

  void sendDanmu() async {
    if (isSending.value) {
      Get.snackbar('どうやら壊れたようです。', '发送失败，请稍后再试');
      return;
    }
    String text = textEditingController.text.trim();
    int time = (controller.player.state.position.inMilliseconds / 1000).round();
    if (text.isNotEmpty) {
      isSending.value = true;
      videoDamnuController.postDanmu(text, danmuMode, danmuColor, time);
      textEditingController.clear();
      await Future.delayed(Duration(seconds: 5));
      isSending.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'VideoPlayerWidget build: fileId=${widget.fileId}, videoId=${widget.videoId}');
    MaterialDesktopVideoControlsThemeData t({bool fullscreen = false}) =>
        MaterialDesktopVideoControlsThemeData(
            toggleFullscreenOnDoublePress: true,
            playAndPauseOnTap: true,
            controlsHoverDuration: Duration(seconds: 2),
            seekBarColor: Theme.of(context).colorScheme.primary,
            seekBarThumbColor: Theme.of(context).colorScheme.primary,
            seekBarPositionColor: Theme.of(context).colorScheme.primary,
            extraOverlay: fullscreen ? fullscreenDamnuOverlay : damnuOverlay,
            onSeekEnd: () => videoDamnuController.resumeDanmu(),
            onSeekStart: () => videoDamnuController.pauseDanmu(),
            bottomButtonBar: [
              // MaterialDesktopSkipPreviousButton(),
              MaterialDesktopPlayOrPauseButton(),
              // MaterialDesktopSkipNextButton(),
              MaterialDesktopVolumeButton(),
              MaterialDesktopPositionIndicator(),
              Spacer(),
              // 弹幕输入框和弹幕面板区域
              MouseRegion(
                onEnter: (_) => _cancelDanmuPanelTimer(),
                onExit: (_) => _hideDanmuPanelWithDelay(),
                child: Obx(() => AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      width: (showDanmuPanel.value ? 330 : 0).w,
                      height: 40.w,
                      margin: EdgeInsets.only(),
                      curve: Curves.easeOut,
                      child: showDanmuPanel.value
                          ? DanmuControlPanel(
                              videoDamnuController: videoDamnuController,
                            )
                          : null,
                    )),
              ),

              SizedBox(
                width: 400.w,
                height: 40.w,
                child: TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  style: TextStyle(
                    fontSize: 14.sp,
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
                    fillColor:
                        Theme.of(context).colorScheme.surface.withOpacity(0.3),
                    prefixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MouseRegion(
                            onEnter: (_) => _showDanmuPanel(),
                            onExit: (_) => _hideDanmuPanelWithDelay(),
                            child: Obx(() => IconButton(
                                  icon: Icon(
                                    barrageEnabled.value
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    size: 14,
                                    color: barrageEnabled.value
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).disabledColor,
                                  ),
                                  tooltip:
                                      barrageEnabled.value ? '关闭弹幕' : '开启弹幕',
                                  onPressed: () {
                                    barrageEnabled.value =
                                        !barrageEnabled.value;
                                  },
                                ))),
                        Builder(
                          builder: (iconContext) => IconButton(
                            icon: Text('A',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary)),
                            onPressed: () {
                              if (fullscreen) toggleFullscreen(iconContext);
                              showDanmuStyleMenu(iconContext);
                            },
                          ),
                        ),
                      ],
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
                ),
              ),
              // 弹幕控制面板区域

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
                            width: 40.w,
                            height: 20.w,
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
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold))),
              Obx(() => Text(
                  videoDamnuController.danmus.length.toString() + ' 条弹幕',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold)))
            ]);

    // 关键：弹幕层和视频同层，保证全屏时弹幕可见
    return MaterialDesktopVideoControlsTheme(
      normal: t(),
      fullscreen: t(fullscreen: true),
      child: Video(controller: controller),
    );
  }

  // 新增：弹幕样式选择弹窗（锚定按钮位置）
  void showDanmuStyleMenu(BuildContext anchorContext) {
    final RenderBox button = anchorContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position =
        button.localToGlobal(Offset.zero, ancestor: overlay);
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + button.size.height,
        position.dx + button.size.width,
        position.dy,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          child: StatefulBuilder(
            builder: (context, setState) {
              final theme = Theme.of(context);
              // 模式选择
              final List<Map<String, dynamic>> modes = [
                {'label': '滚动', 'value': DanmuModeEnum.NORMAL.type},
                {'label': '顶部', 'value': DanmuModeEnum.TOP.type},
                {'label': '底部', 'value': DanmuModeEnum.BOTTOM.type},
              ];
              // 默认颜色两排
              final List<List<Color>> colorRows = [
                presetColors.sublist(0, 6),
                presetColors.sublist(6),
              ];
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 模式选择
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: modes.map((m) {
                      final selected = danmuMode == m['value'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              danmuMode = m['value'];
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected
                                  ? theme.colorScheme.primary.withOpacity(0.08)
                                  : null,
                              border: Border.all(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : theme.dividerColor,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Text(
                              m['label'],
                              style: TextStyle(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : theme.textTheme.bodyMedium?.color,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 12.w),
                  // 自定义颜色输入和预览
                  Row(
                    children: [
                      Text('颜色:',
                          style: TextStyle(color: theme.colorScheme.primary)),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 70.w,
                        child: TextField(
                          controller: colorController,
                          maxLength: 6,
                          style: TextStyle(
                              fontSize: 14.sp, color: theme.colorScheme.primary),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: 'HEX',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 8),
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: theme.colorScheme.primary),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (v) {
                            setState(() {
                              danmuColor = v.toUpperCase();
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 24.w,
                        height: 24.w,
                        decoration: BoxDecoration(
                          color: _parseColor(danmuColor),
                          border: Border.all(
                              color: theme.colorScheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.w),
                  // 默认颜色两排
                  ...colorRows.map((row) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: row.map((c) {
                            String hex = c.value
                                .toRadixString(16)
                                .padLeft(8, '0')
                                .substring(2)
                                .toUpperCase();
                            final selected = danmuColor == hex;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 2.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    danmuColor = hex;
                                    colorController.text = hex;
                                  });
                                },
                                child: Container(
                                  width: 24.w,
                                  height: 24.w,
                                  decoration: BoxDecoration(
                                    color: c,
                                    border: Border.all(
                                      color: selected
                                          ? theme.colorScheme.primary
                                          : theme.dividerColor,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Color _parseColor(String hex) {
    try {
      if (hex.length == 6) {
        return Color(int.parse('0xFF$hex'));
      }
    } catch (_) {}
    return Colors.white;
  }
}

class DanmuControlPanel extends StatefulWidget {
  final VideoDamnuController videoDamnuController;
  const DanmuControlPanel({Key? key, required this.videoDamnuController})
      : super(key: key);
  @override
  State<DanmuControlPanel> createState() => _DanmuControlPanelState();
}

class _DanmuControlPanelState extends State<DanmuControlPanel> {
  @override
  void initState() {
    super.initState();
    // 可从 controller 读取初始值
  }

  String toRead(String text, double v) {
    switch (text) {
      case '速度':
        return '${(1 / (v / 10.0) * 100.0).toStringAsFixed(2)}%';
      case '大小':
        return '${(v / 16.0 * 100.0).toStringAsFixed(2)}%';
      case '区域':
        return '${(v * 100).round()}%';
      case '不透明度':
        return '${(v * 100).round()}%';
      default:
        return text;
    }
  }

  Map<String, double> mins = {
    '速度': 1,
    '大小': 4,
    '区域': 0.1,
    '不透明度': 0.1,
  };
  Map<String, double> maxs = {
    '速度': 60,
    '大小': 32,
    '区域': 1,
    '不透明度': 1,
  };
  Map<String, int> divisions = {'速度': 60, '大小': 200, '区域': 16, '不透明度': 90};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget lw(String text, RxDouble value) {
      return SizedBox(
        width: 40,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: -8,
              left: -10,
              right: -10,
              child: Center(child: Text(text, style: TextStyle(fontSize: 12.sp))),
            ),
            Positioned(
                left: -20,
                right: -20,
                bottom: -4,
                child: Obx(() => Slider(
                      value: value.value,
                      min: mins[text]!,
                      max: maxs[text]!,
                      divisions: divisions[text],
                      label: toRead(text, value.value),
                      onChanged: (v) {
                        value.value = v;
                      },
                    ))),
          ],
        ),
      );
    }

    Padding rw(String text, RxBool b) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: GestureDetector(
          onTap: () {
            b.value = !b.value;
            widget.videoDamnuController.update();
          },
          child: Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: b.value
                      ? theme.colorScheme.primary.withOpacity(0.12)
                      : Colors.transparent,
                  border: Border.all(
                    color: b.value
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: b.value
                        ? theme.colorScheme.primary
                        : theme.textTheme.bodyMedium?.color,
                    fontWeight: b.value ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              )),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.45), // 半透明黑色背景
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 速度
          lw('速度', widget.videoDamnuController.duration),
          // 大小
          lw('大小', widget.videoDamnuController.fontSize),
          // 区域
          lw('区域', widget.videoDamnuController.area),
          lw('不透明度', widget.videoDamnuController.opacity),
          // 类型过滤
          Row(mainAxisSize: MainAxisSize.min, children: [
            rw('滚动', widget.videoDamnuController.enableScroll),
            rw('顶部', widget.videoDamnuController.enableTop),
            rw('底部', widget.videoDamnuController.enableBottom)
          ]),
        ],
      ),
    );
  }
}
