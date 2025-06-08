import 'dart:async';
import 'package:easylive/Funcs.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/pages2.dart';
import 'package:easylive/settings.dart';
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

class VideoPlayPage extends StatelessWidget {
  const VideoPlayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    print('当前路由名称: $routeName');
    final videoId = toParameters(routeName!)?['videoId'];
    return GetBuilder(
        init: VideoLoadVideoPListController(videoId!),
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
                    CommentController commentController = CommentController();
                    commentController.loadComments(videoId);
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
                                return VideoPlayPageInfo(fileId: fileId);
                              } else {
                                return VideoPlayPageComments(fileId: fileId);
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
  final String fileId;
  const VideoPlayPageInfo({required this.fileId, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: VideoLoadVideoPListController(fileId),
        builder: (controller) {
          if (controller.isLoading.value) {
            return CircularProgressIndicator();
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(controller.videoPList[0].fileName ?? '',
                    style: TextStyle(fontSize: 20)),
                // 可扩展更多分P信息
              ],
            );
          }
        });
  }
}

class VideoPlayPageComments extends StatelessWidget {
  final String fileId;
  const VideoPlayPageComments({required this.fileId, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: VideoLoadVideoPListController(fileId),
        builder: (controller) {
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
        });
  }
}
