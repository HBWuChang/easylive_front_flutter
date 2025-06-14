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
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class VideoPlayPageCommentsInner extends StatefulWidget {
  final int parentCommentId; // 传入父评论id
  final String videoId; // 视频ID
  const VideoPlayPageCommentsInner(
      {Key? key, required this.parentCommentId, required this.videoId})
      : super(key: key);
  @override
  State<VideoPlayPageCommentsInner> createState() =>
      _VideoPlayPageCommentsInnerState();
}

class _VideoPlayPageCommentsInnerState
    extends State<VideoPlayPageCommentsInner> {
  int? replyToCommentId;
  final TextEditingController replyController = TextEditingController();

  @override
  void dispose() {
    replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommentController>(
      tag: '${widget.videoId}CommentController',
      builder: (commentController) {
        final parent = commentController.commentDataList
            .firstWhereOrNull((c) => c.commentId == widget.parentCommentId);
        final children = parent?.children ?? [];
        return Scaffold(
          appBar: AppBar(
            title: Text('评论详情'),
          ),
          body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(children: [
                        SizedBox(height: 12),
                        Hero(
                            tag: 'commentAvatar${widget.parentCommentId}',
                            child: Avatar(
                              avatarValue: parent!.avatar,
                            ))
                      ]),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 8),
                          Hero(
                              tag: 'commentNickName${widget.parentCommentId}',
                              child: Text(
                                parent.nickName ?? '',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                          Hero(
                              tag: 'commentPostTime${widget.parentCommentId}',
                              child: Text(
                                toShowDatetext(parent.postTime!),
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.tertiary),
                              )),
                          SizedBox(height: 8),
                          // 评论内容可展开/收起
                          Hero(
                              tag: 'commentContent${widget.parentCommentId}',
                              child: ExpandableCommentContent(
                                content: parent.content ?? '',
                              )),
                          if (!(parent.imgPath == null || parent.imgPath == ''))
                            Hero(
                                tag: 'commentImgPath${widget.parentCommentId}',
                                child: GestureDetector(
                                  onTap: () {
                                    final imgUrl = ApiService.baseUrl +
                                        ApiAddr.fileGetResourcet +
                                        parent.imgPath!;
                                    Get.dialog(
                                        ImagePreviewDialog(imgUrl: imgUrl));
                                  },
                                  child: ExtendedImage.network(
                                    ApiService.baseUrl +
                                        ApiAddr.fileGetResourcet +
                                        parent.imgPath!,
                                    width: 300,
                                    height: 200,
                                    fit: BoxFit.contain, // 保证图片完整显示且有圆角
                                    cache: true,
                                    alignment: Alignment.centerLeft,
                                    enableLoadState: false,
                                  ),
                                )),
                          SizedBox(height: 8),
                          // 点赞，点踩，评论
                          Hero(
                              tag: 'commentBtns${widget.parentCommentId}',
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Obx(() => IconButton(
                                        icon: Icon(
                                          commentController
                                                  .isLike(parent.commentId!)
                                              ? Icons.thumb_up
                                              : Icons.thumb_up_outlined,
                                          color: commentController
                                                  .isLike(parent.commentId!)
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : null,
                                        ),
                                        iconSize: 16,
                                        onPressed: () {
                                          commentController
                                              .likeComment(parent.commentId!);
                                        },
                                      )),
                                  Text(parent.likeCount.toString()),
                                  SizedBox(width: 16),
                                  Transform.flip(
                                      flipX: true,
                                      child: Obx(() => IconButton(
                                            icon: Icon(
                                              commentController
                                                      .isHate(parent.commentId!)
                                                  ? Icons.thumb_down
                                                  : Icons.thumb_down_outlined,
                                              color: commentController
                                                      .isHate(parent.commentId!)
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : null,
                                            ),
                                            iconSize: 16,
                                            onPressed: () {
                                              commentController.hateComment(
                                                  parent.commentId!);
                                            },
                                          ))),
                                  // Obx(() => Text(commentController
                                  //         .commentDataList[index]
                                  //         .hateCount
                                  //         .toString() ??
                                  //     '0')),
                                  SizedBox(width: 16),
                                  IconButton(
                                    icon: Icon(Icons.messenger_outline_rounded,
                                        size: 16),
                                    onPressed: () {
                                      // 回复评论逻辑
                                      commentController.nowSelectCommentId
                                          .value = parent.commentId !=
                                              commentController
                                                  .nowSelectCommentId.value
                                          ? parent.commentId!
                                          : 0;
                                    },
                                  ),
                                ],
                              )),
                        ],
                      ),
                    ],
                  ),
                  Hero(
                      tag: 'commentTotal${widget.parentCommentId}',
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        child: Text('共 ${children.length} 条回复',
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.tertiary)),
                      )),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: children.length,
                    itemBuilder: (context, index) {
                      final child = children[index];
                      return Column(children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Column(children: [
                              SizedBox(height: 12),
                              Avatar(
                                avatarValue: child.avatar,
                              )
                            ]),
                            SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 8),
                                Hero(
                                    tag: 'commentNickName${child.commentId}',
                                    child: Text(
                                      child.nickName ?? '',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )),
                                Hero(
                                    tag: 'commentPostTime${child.commentId}',
                                    child: Text(
                                      toShowDatetext(child.postTime!),
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .tertiary),
                                    )),
                                SizedBox(height: 8),
                                // 评论内容可展开/收起
                                Hero(
                                    tag: 'commentContent${child.commentId}',
                                    child: ExpandableCommentContent(
                                      content: child.content ?? '',
                                      replyNickName: child.replyNickName,
                                    )),
                                if (!(child.imgPath == null ||
                                    child.imgPath == ''))
                                  Hero(
                                      tag: 'commentImgPath${child.commentId}',
                                      child: GestureDetector(
                                        onTap: () {
                                          final imgUrl = ApiService.baseUrl +
                                              ApiAddr.fileGetResourcet +
                                              child.imgPath!;
                                          Get.dialog(ImagePreviewDialog(
                                              imgUrl: imgUrl));
                                        },
                                        child: ExtendedImage.network(
                                          ApiService.baseUrl +
                                              ApiAddr.fileGetResourcet +
                                              child.imgPath!,
                                          width: 300,
                                          height: 200,
                                          fit: BoxFit.contain, // 保证图片完整显示且有圆角
                                          cache: true,
                                          alignment: Alignment.centerLeft,
                                          enableLoadState: false,
                                        ),
                                      )),
                                SizedBox(height: 8),
                                // 点赞，点踩，评论
                                Hero(
                                    tag: 'commentBtns${child.commentId}',
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Obx(() => IconButton(
                                              icon: Icon(
                                                commentController.isLike(
                                                        child.commentId!)
                                                    ? Icons.thumb_up
                                                    : Icons.thumb_up_outlined,
                                                color: commentController.isLike(
                                                        child.commentId!)
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                    : null,
                                              ),
                                              iconSize: 16,
                                              onPressed: () {
                                                commentController.likeComment(
                                                    child.commentId!);
                                              },
                                            )),
                                        Text(
                                            child.likeCount.toString() ?? '0'),
                                        SizedBox(width: 16),
                                        Transform.flip(
                                            flipX: true,
                                            child: Obx(() => IconButton(
                                                  icon: Icon(
                                                    commentController.isHate(
                                                            child.commentId!)
                                                        ? Icons.thumb_down
                                                        : Icons
                                                            .thumb_down_outlined,
                                                    color: commentController
                                                            .isHate(child
                                                                .commentId!)
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                        : null,
                                                  ),
                                                  iconSize: 16,
                                                  onPressed: () {
                                                    commentController
                                                        .hateComment(
                                                            child.commentId!);
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
                                              Icons.messenger_outline_rounded,
                                              size: 16),
                                          onPressed: () {
                                            // 回复评论逻辑
                                            commentController
                                                .innerNowSelectCommentId
                                                .value = child.commentId !=
                                                    commentController
                                                        .innerNowSelectCommentId
                                                        .value
                                                ? child.commentId!
                                                : 0;
                                          },
                                        ),
                                      ],
                                    )),
                                Obx(() {
                                  if (commentController
                                          .innerNowSelectCommentId.value !=
                                      child.commentId!) {
                                    return SizedBox.shrink();
                                  }
                                  return Column(children: [
                                    AnimatedSize(
                                      duration: Duration(milliseconds: 120),
                                      curve: Curves.easeInOut,
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          minWidth: 300,
                                          maxWidth: 300,
                                          minHeight: 40,
                                          maxHeight: 200,
                                        ),
                                        child: TextField(
                                          controller: commentController
                                              .mainCommentController,
                                          autofocus: true,
                                          minLines: 1,
                                          maxLines: null, // 支持多行自适应
                                          keyboardType: TextInputType.multiline,
                                          maxLength: 500, // 限制最大字数为500
                                          decoration: InputDecoration(
                                            labelText: '发表评论...',
                                            border: OutlineInputBorder(),
                                            isDense: true,
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 12),
                                          ),
                                          style: TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 300,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Obx(() => Tooltip(
                                              message: commentController
                                                      .mainImgPath.value.isEmpty
                                                  ? "添加图片"
                                                  : '单击以修改,长按以删除',
                                              child: GestureDetector(
                                                  onTap: () async {
                                                    commentController
                                                            .mainImgPath.value =
                                                        (await showUploadImageCard(
                                                                imagePath:
                                                                    commentController
                                                                        .mainImgPath
                                                                        .value,
                                                                shadow:
                                                                    true)) ??
                                                            commentController
                                                                .mainImgPath
                                                                .value;
                                                  },
                                                  onLongPress: () {
                                                    commentController
                                                        .mainImgPath.value = '';
                                                  },
                                                  child: commentController
                                                              .mainImgPath
                                                              .value !=
                                                          ''
                                                      ? ExtendedImage.network(
                                                          ApiService.baseUrl +
                                                              ApiAddr
                                                                  .fileGetResourcet +
                                                              commentController
                                                                  .mainImgPath
                                                                  .value,
                                                          width: 100,
                                                          height: 100,
                                                          fit: BoxFit
                                                              .contain, // 保证图片完整显示且有圆角
                                                          cache: true,
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          enableLoadState:
                                                              false,
                                                        )
                                                      : Icon(
                                                          Icons.add_a_photo,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .tertiary,
                                                          size: 24,
                                                        )))),
                                          Obx(() => IconButton(
                                                tooltip: '发表评论',
                                                icon: Icon(Icons.send),
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                onPressed: commentController
                                                        .sendingComment.value
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
                              ],
                            ),
                          ],
                        ),
                        DividerWithPaddingHorizontal(padding: 8)
                      ]);
                    },
                  ),
                  if (replyToCommentId != null)
                    Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: replyController,
                              minLines: 1,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: '回复内容...',
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 12),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            color: Theme.of(context).colorScheme.primary,
                            tooltip: '发送',
                            onPressed: () {
                              // 发送评论逻辑暂时为空
                              replyController.clear();
                              setState(() {
                                replyToCommentId = null;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                ],
              ))),
        );
      },
    );
  }
}
