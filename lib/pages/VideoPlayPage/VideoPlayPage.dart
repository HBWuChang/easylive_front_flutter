import 'dart:async';
import 'package:crypto/crypto.dart';
import 'package:easylive/Funcs.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/settings.dart';
import 'package:easylive/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers-class.dart';
import '../../api_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'dart:ui' as ui;
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

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
    }
    VideoGetVideoInfoController videoGetVideoInfoController;
    if (Get.isRegistered<VideoGetVideoInfoController>(
        tag: '${videoId}VideoGetVideoInfoController')) {
      videoGetVideoInfoController = Get.find<VideoGetVideoInfoController>(
          tag: '${videoId}VideoGetVideoInfoController');
    } else {
      videoGetVideoInfoController = Get.put(VideoGetVideoInfoController(),
          tag: '${videoId}VideoGetVideoInfoController');
    }
    videoGetVideoInfoController.loadVideoInfo(videoId);
    commentController.loadComments(videoId);
    return GetBuilder(
        init: VideoLoadVideoPListController(videoId),
        builder: (controller) {
          if (controller.isLoading.value) {
            return CircularProgressIndicator();
          } else {
            return Row(children: [
              // 左侧：视频播放器
              Expanded(
                  child: VideoPlayerWidget(
                      fileId: controller.videoPList.isNotEmpty
                          ? controller.videoPList[0].fileId ?? ''
                          : '')),
              // 右侧：分P信息
              SizedBox(
                width: 400,
                child: GetBuilder<VideoLoadVideoPListController>(
                  builder: (controller) {
                    final videoList = controller.videoPList;
                    final fileId =
                        (videoList.isNotEmpty && videoList[0].fileId != null)
                            ? videoList[0].fileId as String
                            : '';
                    final RxInt nowTabIndex = 0.obs;
                    final pageController =
                        PreloadPageController(initialPage: 0);

                    return Column(
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
                                                          milliseconds: 300),
                                                      curve: Curves.ease,
                                                    );
                                                  },
                                                  child: Text(
                                                    '简介',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Theme.of(context)
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
                                                          milliseconds: 300),
                                                      curve: Curves.ease,
                                                    );
                                                  },
                                                  child: Obx(() => Text(
                                                        '评论${(commentController.commentDataTotalCount.value).toString()}',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color:
                                                              Theme.of(context)
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
                                              builder: (context, constraints) {
                                                return AnimatedBuilder(
                                                  animation: pageController,
                                                  builder: (context, child) {
                                                    double page = 0.0;
                                                    try {
                                                      page = pageController
                                                                  .hasClients &&
                                                              pageController
                                                                      .page !=
                                                                  null
                                                          ? pageController.page!
                                                          : pageController
                                                              .initialPage
                                                              .toDouble();
                                                    } catch (_) {}
                                                    double width =
                                                        constraints.maxWidth /
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
                                                    double lineWidth = minLine +
                                                        (maxLine - minLine) *
                                                            (dist * 2);
                                                    double left = page * width +
                                                        (width - lineWidth) / 2;
                                                    return Stack(
                                                      children: [
                                                        Positioned(
                                                          left: left,
                                                          width: lineWidth,
                                                          top: 0,
                                                          bottom: 0,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          2),
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
                                return VideoPlayPageComments(videoId: videoId);
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
            ]);
          }
        });
  }
}

// 新增：视频播放器组件
class VideoPlayerWidget extends StatefulWidget {
  final String fileId;
  const VideoPlayerWidget({required this.fileId, Key? key}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final Player player;
  late final VideoController controller;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Video(controller: controller);
  }
}

class VideoPlayPageInfo extends StatelessWidget {
  final String videoId;
  final RxBool expandInfo = false.obs; // 是否展开更多信息
  VideoPlayPageInfo({required this.videoId, super.key});
  @override
  Widget build(BuildContext context) {
    final infoColor1 = Theme.of(context).colorScheme.secondary;
    final infoColor2 = Theme.of(context).colorScheme.tertiary;
    // 直接使用已在 VideoPlayPage put 的 controller
    return GetBuilder<VideoGetVideoInfoController>(
        tag: '${videoId}VideoGetVideoInfoController',
        builder: (videoGetVideoInfoController) => Obx(() {
              if (videoGetVideoInfoController.isLoading.value) {
                return CircularProgressIndicator();
              } else {
                UhomeGetUserInfoController uhomeGetUserInfoController =
                    UhomeGetUserInfoController();
                uhomeGetUserInfoController.getUserInfo(
                    videoGetVideoInfoController.videoInfo.value.userId ?? '');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                          height: 54,
                          child: Row(
                            children: [
                              SizedBox(
                                  width: 54,
                                  child: Avatar(
                                      avatarValue: videoGetVideoInfoController
                                              .videoInfo.value.avatar ??
                                          '',
                                      radius: 27)),
                              SizedBox(
                                  width: 300,
                                  child: ListTile(
                                    title: Text(
                                      videoGetVideoInfoController
                                              .videoInfo.value.nickName ??
                                          '',
                                      style: TextStyle(
                                        fontSize: 16,
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
                                                .userInfo.value.haveFocus) {
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
                                              var res =
                                                  await ApiService.uhomeFocus(
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
                                          child: Text(
                                            uhomeGetUserInfoController
                                                    .userInfo.value.haveFocus
                                                ? '已关注'
                                                : '关注',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
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
                                        )),
                                  )),
                            ],
                          )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: ListTile(
                        title: Obx(() => Text(
                              videoGetVideoInfoController
                                      .videoInfo.value.videoName ??
                                  '',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              maxLines: expandInfo.value ? null : 1,
                              overflow: expandInfo.value
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                            )),
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
                                        fontSize: 12, color: infoColor1),
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
                                        fontSize: 12, color: infoColor1),
                                  ),
                                  SizedBox(width: 16),
                                  // 创建时间
                                  Icon(
                                    Icons.calendar_today,
                                    color: infoColor1,
                                    size: 14,
                                  ),
                                  Text(
                                    '${(videoGetVideoInfoController.videoInfo.value.createTime ?? '')}'
                                        .substring(0, 19),
                                    style: TextStyle(
                                        fontSize: 12, color: infoColor1),
                                  ),
                                ],
                              ),
                              if (expandInfo.value)
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      videoGetVideoInfoController
                                              .videoInfo.value.videoId ??
                                          '',
                                      style: TextStyle(
                                          fontSize: 12, color: infoColor1),
                                    )),
                              if (expandInfo.value) SizedBox(height: 6),
                              if (expandInfo.value)
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: _buildIntroductionText(
                                      videoGetVideoInfoController
                                              .videoInfo.value.introduction ??
                                          '',
                                      infoColor2,
                                    )),
                            ])),
                        trailing: Obx(
                          () => TextButton.icon(
                            iconAlignment: IconAlignment.end,
                            onPressed: () {
                              expandInfo.value = !expandInfo.value;
                            },
                            label: Text(
                              expandInfo.value ? '收起' : '展开',
                              style: TextStyle(fontSize: 16),
                            ),
                            icon: AnimatedRotation(
                              turns: expandInfo.value ? 0.5 : 0.0, // 0.5圈=180度
                              duration: Duration(milliseconds: 200),
                              child: Icon(
                                Icons.expand_more,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    // 可扩展更多分P信息
                  ],
                );
              }
            }));
  }

  Widget _buildIntroductionText(String text, Color color) {
    final urlReg = RegExp(r'(https?://[\w\-._~:/?#\[\]@!$&()*+,;=%]+)');
    final spans = <TextSpan>[];
    int start = 0;
    for (final match in urlReg.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(
            text: text.substring(start, match.start),
            style: TextStyle(fontSize: 12, color: color)));
      }
      final url = match.group(0)!;
      spans.add(TextSpan(
        text: url,
        style: TextStyle(
            fontSize: 12,
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
          style: TextStyle(fontSize: 12, color: color)));
    }
    return Text.rich(TextSpan(children: spans));
  }
}

class VideoPlayPageComments extends StatelessWidget {
  final String videoId;
  const VideoPlayPageComments({required this.videoId, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: VideoLoadVideoPListController(videoId),
        builder: (controller) => Obx(() {
              if (controller.isLoading.value) {
                return CircularProgressIndicator();
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('评论区', style: TextStyle(fontSize: 20)),
                    // 可扩展评论列表
                  ],
                );
              }
            }));
  }
}
