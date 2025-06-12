import 'dart:async';
import 'dart:math' as math;
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
import 'package:flutter_svg/flutter_svg.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'VideoPlayPageInfoWidgets.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class VideoPlayPageComments extends StatefulWidget {
  final String videoId;
  const VideoPlayPageComments({required this.videoId, Key? key})
      : super(key: key);

  @override
  State<VideoPlayPageComments> createState() => _VideoPlayPageCommentsState();
}

class _VideoPlayPageCommentsState extends State<VideoPlayPageComments> {
  late ScrollController outterScrollController;
  // bool showFAB = false;
  var showFAB = false.obs;

  @override
  void initState() {
    super.initState();
    outterScrollController = ScrollController();
    outterScrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (outterScrollController.offset > 100 && !showFAB.value) {
      // setState(() {
      //   showFAB = true;
      // });
      showFAB.value = true;
    } else if (outterScrollController.offset <= 100 && showFAB.value) {
      // setState(() {
      //   showFAB = false;
      // });
      showFAB.value = false;
    }
  }

  @override
  void dispose() {
    outterScrollController.removeListener(_scrollListener);
    outterScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GetBuilder<CommentController>(
            tag: '${widget.videoId}CommentController',
            builder: (commentController) => Obx(() {
                  return SingleChildScrollView(
                      controller: outterScrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 最新/最热 按钮
                          SizedBox(
                            width: 128,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                    onPressed: () {
                                      if (commentController.orderType.value ==
                                          CommentOrderTypeEnum.HOT.type) {
                                        return;
                                      }
                                      commentController.orderType.value =
                                          CommentOrderTypeEnum.HOT.type;
                                      commentController.loadComments();
                                    },
                                    child: Obx(() => Text('最热',
                                        style: TextStyle(
                                            color: commentController
                                                        .orderType.value ==
                                                    CommentOrderTypeEnum
                                                        .HOT.type
                                                ? null
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .tertiary,
                                            fontWeight: commentController
                                                        .orderType.value ==
                                                    CommentOrderTypeEnum
                                                        .HOT.type
                                                ? FontWeight.bold
                                                : FontWeight.normal)))),
                                SizedBox(
                                  height: 32,
                                  width: 2,
                                  child: DividerWithPaddingVertical(padding: 8),
                                ), // 间隔

                                TextButton(
                                    onPressed: () {
                                      if (commentController.orderType.value ==
                                          CommentOrderTypeEnum.NEW.type) {
                                        return;
                                      }
                                      commentController.orderType.value =
                                          CommentOrderTypeEnum.NEW.type;
                                      commentController.loadComments();
                                    },
                                    child: Obx(() => Text('最新',
                                        style: TextStyle(
                                            color: commentController
                                                        .orderType.value ==
                                                    CommentOrderTypeEnum
                                                        .NEW.type
                                                ? null
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .tertiary,
                                            fontWeight: commentController
                                                        .orderType.value ==
                                                    CommentOrderTypeEnum
                                                        .NEW.type
                                                ? FontWeight.bold
                                                : FontWeight.normal)))),
                              ],
                            ),
                          ),
                          Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Obx(() => ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: commentController
                                        .commentDataList.length,
                                    itemBuilder: (context, index) {
                                      return Column(children: [
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Column(children: [
                                              SizedBox(height: 12),
                                              Avatar(
                                                avatarValue: commentController
                                                    .commentDataList[index]
                                                    .avatar,
                                              )
                                            ]),
                                            SizedBox(width: 16),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(height: 8),
                                                Text(
                                                  commentController
                                                          .commentDataList[
                                                              index]
                                                          .nickName ??
                                                      '',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Text(
                                                  toShowDatetext(
                                                      commentController
                                                          .commentDataList[
                                                              index]
                                                          .postTime!),
                                                  style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .tertiary),
                                                ),
                                                SizedBox(height: 8),
                                                // 评论内容可展开/收起
                                                _ExpandableCommentContent(
                                                  content: commentController
                                                          .commentDataList[
                                                              index]
                                                          .content ??
                                                      '',
                                                ),
                                                if (!(commentController
                                                            .commentDataList[
                                                                index]
                                                            .imgPath ==
                                                        null ||
                                                    commentController
                                                            .commentDataList[
                                                                index]
                                                            .imgPath ==
                                                        ''))
                                                  GestureDetector(
                                                    onTap: () {
                                                      final imgUrl = ApiService
                                                              .baseUrl +
                                                          ApiAddr
                                                              .fileGetResourcet +
                                                          commentController
                                                              .commentDataList[
                                                                  index]
                                                              .imgPath!;
                                                      Get.dialog(
                                                          _ImagePreviewDialog(
                                                              imgUrl: imgUrl));
                                                    },
                                                    child:
                                                        ExtendedImage.network(
                                                      ApiService.baseUrl +
                                                          ApiAddr
                                                              .fileGetResourcet +
                                                          commentController
                                                              .commentDataList[
                                                                  index]
                                                              .imgPath!,
                                                      width: 300,
                                                      height: 200,
                                                      fit: BoxFit
                                                          .contain, // 保证图片完整显示且有圆角
                                                      cache: true,
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      enableLoadState: false,
                                                    ),
                                                  ),
                                                SizedBox(height: 8),
                                                // 点赞，点踩，评论
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Obx(() => IconButton(
                                                          icon: Icon(
                                                            commentController.isLike(
                                                                    commentController
                                                                        .commentDataList[
                                                                            index]
                                                                        .commentId!)
                                                                ? Icons.thumb_up
                                                                : Icons
                                                                    .thumb_up_outlined,
                                                            color: commentController.isLike(
                                                                    commentController
                                                                        .commentDataList[
                                                                            index]
                                                                        .commentId!)
                                                                ? Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary
                                                                : null,
                                                          ),
                                                          iconSize: 16,
                                                          onPressed: () {
                                                            commentController.likeComment(
                                                                commentController
                                                                    .commentDataList[
                                                                        index]
                                                                    .commentId!);
                                                          },
                                                        )),
                                                    Obx(() => Text(
                                                        commentController
                                                                .commentDataList[
                                                                    index]
                                                                .likeCount
                                                                .toString() ??
                                                            '0')),
                                                    SizedBox(width: 16),
                                                    Transform.flip(
                                                        flipX: true,
                                                        child:
                                                            Obx(
                                                                () =>
                                                                    IconButton(
                                                                      icon:
                                                                          Icon(
                                                                        commentController.isHate(commentController.commentDataList[index].commentId!)
                                                                            ? Icons.thumb_down
                                                                            : Icons.thumb_down_outlined,
                                                                        color: commentController.isHate(commentController.commentDataList[index].commentId!)
                                                                            ? Theme.of(context).colorScheme.primary
                                                                            : null,
                                                                      ),
                                                                      iconSize:
                                                                          16,
                                                                      onPressed:
                                                                          () {
                                                                        commentController.hateComment(commentController
                                                                            .commentDataList[index]
                                                                            .commentId!);
                                                                      },
                                                                    ))),
                                                    // Obx(() => Text(commentController
                                                    //         .commentDataList[index]
                                                    //         .hateCount
                                                    //         .toString() ??
                                                    //     '0')),
                                                    SizedBox(width: 16),
                                                    IconButton(
                                                      icon: Icon(
                                                          Icons
                                                              .messenger_outline_rounded,
                                                          size: 16),
                                                      onPressed: () {
                                                        // 回复评论逻辑
                                                        commentController
                                                            .nowSelectCommentId
                                                            .value = commentController
                                                                    .commentDataList[
                                                                        index]
                                                                    .commentId !=
                                                                commentController
                                                                    .nowSelectCommentId
                                                                    .value
                                                            ? commentController
                                                                .commentDataList[
                                                                    index]
                                                                .commentId!
                                                            : 0;
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Obx(() {
                                                  if (commentController
                                                          .nowSelectCommentId
                                                          .value !=
                                                      commentController
                                                          .commentDataList[
                                                              index]
                                                          .commentId!) {
                                                    return SizedBox.shrink();
                                                  }
                                                  return Column(children: [
                                                    AnimatedSize(
                                                      duration: Duration(
                                                          milliseconds: 120),
                                                      curve: Curves.easeInOut,
                                                      child: ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                          minWidth: 300,
                                                          maxWidth: 300,
                                                          minHeight: 40,
                                                          maxHeight: 200,
                                                        ),
                                                        child: TextField(
                                                          controller:
                                                              commentController
                                                                  .mainCommentController,
                                                          minLines: 1,
                                                          maxLines:
                                                              null, // 支持多行自适应
                                                          keyboardType:
                                                              TextInputType
                                                                  .multiline,
                                                          maxLength:
                                                              500, // 限制最大字数为500
                                                          decoration:
                                                              InputDecoration(
                                                            labelText:
                                                                '发表评论...',
                                                            border:
                                                                OutlineInputBorder(),
                                                            isDense: true,
                                                            contentPadding:
                                                                EdgeInsets
                                                                    .symmetric(
                                                                        vertical:
                                                                            10,
                                                                        horizontal:
                                                                            12),
                                                          ),
                                                          style: TextStyle(
                                                              fontSize: 15),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 300,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Obx(() => Tooltip(
                                                              message: commentController
                                                                      .mainImgPath
                                                                      .value
                                                                      .isEmpty
                                                                  ? "添加图片"
                                                                  : '单击以修改,长按以删除',
                                                              child: GestureDetector(
                                                                  onTap: () async {
                                                                    commentController
                                                                        .mainImgPath
                                                                        .value = (await showUploadImageCard(
                                                                            imagePath: commentController
                                                                                .mainImgPath.value,
                                                                            shadow:
                                                                                true)) ??
                                                                        commentController
                                                                            .mainImgPath
                                                                            .value;
                                                                  },
                                                                  onLongPress: () {
                                                                    commentController
                                                                        .mainImgPath
                                                                        .value = '';
                                                                  },
                                                                  child: commentController.mainImgPath.value != ''
                                                                      ? ExtendedImage.network(
                                                                          ApiService.baseUrl +
                                                                              ApiAddr.fileGetResourcet +
                                                                              commentController.mainImgPath.value,
                                                                          width:
                                                                              100,
                                                                          height:
                                                                              100,
                                                                          fit: BoxFit
                                                                              .contain, // 保证图片完整显示且有圆角
                                                                          cache:
                                                                              true,
                                                                          alignment:
                                                                              Alignment.centerLeft,
                                                                          enableLoadState:
                                                                              false,
                                                                        )
                                                                      : Icon(
                                                                          Icons
                                                                              .add_a_photo,
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .tertiary,
                                                                          size:
                                                                              24,
                                                                        )))),
                                                          Obx(() => IconButton(
                                                                tooltip: '发表评论',
                                                                icon: Icon(
                                                                    Icons.send),
                                                                color: Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .primary,
                                                                onPressed: commentController
                                                                        .sendingComment
                                                                        .value
                                                                    ? null
                                                                    : () async {
                                                                        await commentController
                                                                            .postCommentMain();
                                                                      },
                                                              )),
                                                        ],
                                                      ),
                                                    )
                                                  ]);
                                                }),
                                                if (commentController
                                                    .commentDataList[index]
                                                    .children
                                                    .isNotEmpty)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 16.0),
                                                    child: Text(
                                                      '回复(${commentController.commentDataList[index].children.length})',
                                                      style: TextStyle(
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .tertiary),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        DividerWithPaddingHorizontal(padding: 8)
                                      ]);
                                    },
                                  ))),
                          // 可扩展评论列表
                          if (commentController.isLoading.value)
                            CircularProgressIndicator()
                        ],
                      ));
                })),
        floatingActionButton: Obx(() => showFAB.value
            ? FloatingActionButton(
                mini: true,
                onPressed: () {
                  outterScrollController.animateTo(0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                },
                child: Icon(Icons.arrow_upward),
              )
            : SizedBox.shrink()),
        bottomNavigationBar: GetBuilder<CommentController>(
          tag: '${widget.videoId}CommentController',
          builder: (commentController) => Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: [
                Obx(() => Tooltip(
                      message: commentController.outterImgPath.value.isEmpty
                          ? "添加图片"
                          : '单击以修改,长按以删除',
                      child: GestureDetector(
                        onTap: () async {
                          commentController.outterImgPath.value =
                              (await showUploadImageCard(
                                    imagePath:
                                        commentController.outterImgPath.value,
                                    shadow: true,
                                  )) ??
                                  commentController.outterImgPath.value;
                        },
                        onLongPress: () {
                          commentController.outterImgPath.value = '';
                        },
                        child: commentController.outterImgPath.value != ''
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: ExtendedImage.network(
                                  ApiService.baseUrl +
                                      ApiAddr.fileGetResourcet +
                                      commentController.outterImgPath.value,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  cache: true,
                                  enableLoadState: false,
                                ),
                              )
                            : Icon(
                                Icons.add_a_photo,
                                color: Theme.of(context).colorScheme.tertiary,
                                size: 28,
                              ),
                      ),
                    )),
                SizedBox(width: 12),
                Expanded(
                  child: AnimatedSize(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 40,
                        maxHeight: 200,
                      ),
                      child: TextField(
                        controller: commentController.outterCommentController,
                        minLines: 1,
                        maxLines: null, // 支持多行自适应
                        keyboardType: TextInputType.multiline,
                        // maxLength: 500, // 限制最大字数为500
                        decoration: InputDecoration(
                          hintText: '发表评论...',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 12),
                        ),
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                  tooltip: '发表评论',
                  onPressed: commentController.sendingComment.value
                      ? null
                      : () async {
                          await commentController.postCommentOutter();
                        },
                ),
              ],
            ),
          ),
        ));
  }
}

// 新增可展开/收起的评论内容组件
class _ExpandableCommentContent extends StatefulWidget {
  final String content;
  const _ExpandableCommentContent({required this.content, Key? key})
      : super(key: key);

  @override
  State<_ExpandableCommentContent> createState() =>
      _ExpandableCommentContentState();
}

class _ExpandableCommentContentState extends State<_ExpandableCommentContent> {
  bool expanded = false;
  bool needExpand = false;
  final int maxLines = 5;
  @override
  Widget build(BuildContext context) {
    final text = widget.content;
    final textStyle =
        TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface);
    return LayoutBuilder(
      builder: (context, constraints) {
        double realMaxWidth = 300;
        // 先用TextPainter判断是否超出maxLines
        final span = TextSpan(text: text, style: textStyle);
        final tp = TextPainter(
          text: span,
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: realMaxWidth);
        needExpand = tp.didExceedMaxLines;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: realMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                maxLines: expanded ? null : maxLines,
                overflow:
                    expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: textStyle,
                softWrap: true,
              ),
              if (needExpand)
                TextButton(
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, minimumSize: Size(40, 24)),
                  onPressed: () => setState(() => expanded = !expanded),
                  child: Text(expanded ? '收起' : '展开',
                      style: TextStyle(fontSize: 14)),
                ),
            ],
          ),
        );
      },
    );
  }
}

// 图片预览弹窗
class _ImagePreviewDialog extends StatefulWidget {
  final String imgUrl;
  const _ImagePreviewDialog({required this.imgUrl});

  @override
  State<_ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<_ImagePreviewDialog> {
  double rotation = 0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(), // 点击图片外关闭
      child: Material(
        color: Colors.black54, // 半透明背景
        type: MaterialType.transparency,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Transform.rotate(
                      angle: rotation,
                      child: ExtendedImage.network(
                        widget.imgUrl,
                        fit: BoxFit.contain,
                        width: constraints.maxWidth * 0.95,
                        height: constraints.maxHeight * 0.95,
                        mode: ExtendedImageMode.gesture,
                        initGestureConfigHandler: (_) => GestureConfig(
                          minScale: 0.5,
                          maxScale: 5.0,
                          animationMinScale: 0.5,
                          animationMaxScale: 5.0,
                          speed: 1.0,
                          inertialSpeed: 100.0,
                          initialScale: 1.0,
                          inPageView: false,
                          initialAlignment: InitialAlignment.center,
                        ),
                      ));
                },
              ),
              Positioned(
                top: 24,
                right: 24,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Get.back(),
                ),
              ),
              Positioned(
                bottom: 32,
                right: 32,
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(Icons.rotate_right),
                      label: Text('旋转'),
                      onPressed: () {
                        setState(() {
                          rotation += 0.5 * 3.1415926; // 90度
                        });
                      },
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(Icons.download),
                      label: Text('保存到本地'),
                      onPressed: () async {
                        try {
                          final response =
                              await ExtendedNetworkImageProvider(widget.imgUrl)
                                  .getNetworkImageData();
                          final bytes = response;
                          final downloadsDir = await _getDownloadDirectory();
                          final fileName = widget.imgUrl.split('/').last;
                          final file = await _saveBytesToFile(
                              bytes!, downloadsDir, fileName);
                          Get.back();
                          Get.snackbar('提示', '图片已保存到: ${file.path}');
                        } catch (e) {
                          Get.snackbar('错误', '保存失败: $e');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<String> _getDownloadDirectory() async {
  if (GetPlatform.isDesktop) {
    final downloads = await getDownloadsDirectory();
    return downloads?.path ?? Directory.current.path;
  }
  return Directory.current.path;
}

Future<File> _saveBytesToFile(
    Uint8List bytes, String dir, String fileName) async {
  final file = File('$dir/$fileName');
  await file.writeAsBytes(bytes);
  return file;
}
