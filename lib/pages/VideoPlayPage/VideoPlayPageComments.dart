import 'dart:async';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:easylive/Funcs.dart';
import 'package:easylive/controllers/VideoCommentController.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/settings.dart';
import 'package:easylive/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
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
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'VideoPlayPageCommentsInner.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bx.dart';

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

  @override
  void initState() {
    super.initState();
    outterScrollController =
        Get.find<CommentController>(tag: '${widget.videoId}CommentController')
            .outterScrollController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: HeroControllerScope(
            controller: MaterialApp.createMaterialHeroController(),
            child: Navigator(
              key: Get.nestedKey(Routes.videoPlayPageCommentsInnerNavId +
                  widget.videoId.hashCode),
              onGenerateRoute: (settings) {
                return MaterialPageRoute(
                  builder: (context) => GetBuilder<CommentController>(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextButton(
                                              onPressed: () {
                                                if (commentController
                                                        .orderType.value ==
                                                    CommentOrderTypeEnum
                                                        .HOT.type) {
                                                  return;
                                                }
                                                commentController
                                                        .orderType.value =
                                                    CommentOrderTypeEnum
                                                        .HOT.type;
                                                commentController
                                                    .loadComments();
                                              },
                                              child: Obx(() => Text('最热',
                                                  style: TextStyle(
                                                      color: commentController
                                                                  .orderType
                                                                  .value ==
                                                              CommentOrderTypeEnum
                                                                  .HOT.type
                                                          ? null
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .tertiary,
                                                      fontWeight: commentController
                                                                  .orderType
                                                                  .value ==
                                                              CommentOrderTypeEnum
                                                                  .HOT.type
                                                          ? FontWeight.bold
                                                          : FontWeight
                                                              .normal)))),
                                          SizedBox(
                                            height: 32,
                                            width: 2,
                                            child: DividerWithPaddingVertical(
                                                padding: 8),
                                          ), // 间隔

                                          TextButton(
                                              onPressed: () {
                                                if (commentController
                                                        .orderType.value ==
                                                    CommentOrderTypeEnum
                                                        .NEW.type) {
                                                  return;
                                                }
                                                commentController
                                                        .orderType.value =
                                                    CommentOrderTypeEnum
                                                        .NEW.type;
                                                commentController
                                                    .loadComments();
                                              },
                                              child: Obx(() => Text('最新',
                                                  style: TextStyle(
                                                      color: commentController
                                                                  .orderType
                                                                  .value ==
                                                              CommentOrderTypeEnum
                                                                  .NEW.type
                                                          ? null
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .tertiary,
                                                      fontWeight: commentController
                                                                  .orderType
                                                                  .value ==
                                                              CommentOrderTypeEnum
                                                                  .NEW.type
                                                          ? FontWeight.bold
                                                          : FontWeight
                                                              .normal)))),
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
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Column(children: [
                                                        SizedBox(height: 16),
                                                        Hero(
                                                            tag:
                                                                'commentAvatar${commentController.commentDataList[index].commentId}',
                                                            child: Avatar(
                                                              avatarValue:
                                                                  commentController
                                                                      .commentDataList[
                                                                          index]
                                                                      .avatar,
                                                              userId: commentController
                                                                  .commentDataList[
                                                                      index]
                                                                  .userId,
                                                            ))
                                                      ]),
                                                      SizedBox(width: 16),
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          SizedBox(
                                                              width: 320,
                                                              child: ListTile(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                title: Hero(
                                                                    tag:
                                                                        'commentNickName${commentController.commentDataList[index].commentId}',
                                                                    child:
                                                                        NickNameTextWidget(
                                                                      commentController
                                                                              .commentDataList[index]
                                                                              .nickName ??
                                                                          '',
                                                                      userId: commentController
                                                                          .commentDataList[
                                                                              index]
                                                                          .userId,
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold),
                                                                    )),
                                                                subtitle: Hero(
                                                                    tag:
                                                                        'commentPostTime${commentController.commentDataList[index].commentId}',
                                                                    child: Text(
                                                                      toShowDatetext(commentController
                                                                          .commentDataList[
                                                                              index]
                                                                          .postTime!),
                                                                      style: TextStyle(
                                                                          color: Theme.of(context)
                                                                              .colorScheme
                                                                              .tertiary),
                                                                    )),
                                                              )),
                                                          SizedBox(height: 8),
                                                          // 评论内容可展开/收起
                                                          Hero(
                                                              tag:
                                                                  'commentContent${commentController.commentDataList[index].commentId}',
                                                              child:
                                                                  ExpandableCommentContent(
                                                                comment:
                                                                    commentController
                                                                            .commentDataList[
                                                                        index],
                                                              )),
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
                                                            Hero(
                                                                tag:
                                                                    'commentImgPath${commentController.commentDataList[index].commentId}',
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    final imgUrl = ApiService
                                                                            .baseUrl +
                                                                        ApiAddr
                                                                            .fileGetResourcet +
                                                                        commentController
                                                                            .commentDataList[index]
                                                                            .imgPath!;
                                                                    Get.dialog(ImagePreviewDialog(
                                                                        imgUrl:
                                                                            imgUrl));
                                                                  },
                                                                  child: ExtendedImage
                                                                      .network(
                                                                    ApiService
                                                                            .baseUrl +
                                                                        ApiAddr
                                                                            .fileGetResourcet +
                                                                        commentController
                                                                            .commentDataList[index]
                                                                            .imgPath!,
                                                                    width: 300,
                                                                    height: 200,
                                                                    fit: BoxFit
                                                                        .contain, // 保证图片完整显示且有圆角
                                                                    cache: true,
                                                                    alignment:
                                                                        Alignment
                                                                            .centerLeft,
                                                                    enableLoadState:
                                                                        false,
                                                                  ),
                                                                )),
                                                          SizedBox(height: 8),
                                                          // 点赞，点踩，评论
                                                          Hero(
                                                              tag:
                                                                  'commentBtns${commentController.commentDataList[index].commentId}',
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Obx(() =>
                                                                      IconButton(
                                                                        icon:
                                                                            Icon(
                                                                          commentController.isLike(commentController.commentDataList[index].commentId!)
                                                                              ? Icons.thumb_up
                                                                              : Icons.thumb_up_outlined,
                                                                          color: commentController.isLike(commentController.commentDataList[index].commentId!)
                                                                              ? Theme.of(context).colorScheme.primary
                                                                              : null,
                                                                        ),
                                                                        iconSize:
                                                                            16,
                                                                        onPressed:
                                                                            () {
                                                                          commentController.likeComment(commentController
                                                                              .commentDataList[index]
                                                                              .commentId!);
                                                                        },
                                                                      )),
                                                                  Obx(() => Text(commentController
                                                                      .commentDataList[
                                                                          index]
                                                                      .likeCount
                                                                      .toString())),
                                                                  SizedBox(
                                                                      width:
                                                                          16),
                                                                  Transform.flip(
                                                                      flipX: true,
                                                                      child: Obx(() => IconButton(
                                                                            icon:
                                                                                Icon(
                                                                              commentController.isHate(commentController.commentDataList[index].commentId!) ? Icons.thumb_down : Icons.thumb_down_outlined,
                                                                              color: commentController.isHate(commentController.commentDataList[index].commentId!) ? Theme.of(context).colorScheme.primary : null,
                                                                            ),
                                                                            iconSize:
                                                                                16,
                                                                            onPressed:
                                                                                () {
                                                                              commentController.hateComment(commentController.commentDataList[index].commentId!);
                                                                            },
                                                                          ))),
                                                                  // Obx(() => Text(commentController
                                                                  //         .commentDataList[index]
                                                                  //         .hateCount
                                                                  //         .toString() ??
                                                                  //     '0')),
                                                                  SizedBox(
                                                                      width:
                                                                          16),
                                                                  IconButton(
                                                                    icon: Icon(
                                                                        Icons
                                                                            .messenger_outline_rounded,
                                                                        size:
                                                                            16),
                                                                    onPressed:
                                                                        () {
                                                                      // 回复评论逻辑
                                                                      commentController
                                                                          .nowSelectCommentId
                                                                          .value = commentController.commentDataList[index].commentId !=
                                                                              commentController
                                                                                  .nowSelectCommentId.value
                                                                          ? commentController
                                                                              .commentDataList[index]
                                                                              .commentId!
                                                                          : 0;
                                                                    },
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          64),
                                                                  Builder(
                                                                      builder: (buttonContext) => IconButton(
                                                                          onPressed: () async {
                                                                            final RenderBox
                                                                                button =
                                                                                buttonContext.findRenderObject() as RenderBox;
                                                                            final RenderBox
                                                                                overlay =
                                                                                Overlay.of(buttonContext).context.findRenderObject() as RenderBox;
                                                                            final Offset
                                                                                position =
                                                                                button.localToGlobal(Offset.zero, ancestor: overlay);
                                                                            final result =
                                                                                await showMenu(
                                                                              context: buttonContext,
                                                                              position: RelativeRect.fromLTRB(
                                                                                position.dx,
                                                                                position.dy + button.size.height,
                                                                                position.dx + button.size.width,
                                                                                position.dy,
                                                                              ),
                                                                              items: [
                                                                                commentController.commentDataList[index].topType == CommentTopTypeEnum.TOP.type
                                                                                    ? PopupMenuItem(
                                                                                        value: 'cancelTop',
                                                                                        child: Text('取消置顶'),
                                                                                      )
                                                                                    : PopupMenuItem(
                                                                                        value: 'top',
                                                                                        child: Text('置顶'),
                                                                                      ),
                                                                                PopupMenuItem(
                                                                                  value: 'del',
                                                                                  child: Text('删除'),
                                                                                ),
                                                                              ],
                                                                              color: Theme.of(context).colorScheme.surface,
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(12),
                                                                              ),
                                                                            );
                                                                            if (result ==
                                                                                'top') {
                                                                              await commentController.topComment(commentController.commentDataList[index].commentId!);
                                                                            }
                                                                            if (result ==
                                                                                'cancelTop') {
                                                                              await commentController.cancelTopComment(commentController.commentDataList[index].commentId!);
                                                                            }
                                                                            if (result ==
                                                                                'del') {
                                                                              await commentController.delComment(commentController.commentDataList[index].commentId!);
                                                                            }
                                                                          },
                                                                          icon: Icon(Icons.more_vert_rounded))),
                                                                ],
                                                              )),
                                                          Obx(() {
                                                            if (commentController
                                                                    .nowSelectCommentId
                                                                    .value !=
                                                                commentController
                                                                    .commentDataList[
                                                                        index]
                                                                    .commentId!) {
                                                              return SizedBox
                                                                  .shrink();
                                                            }
                                                            return Column(
                                                                children: [
                                                                  AnimatedSize(
                                                                    duration: Duration(
                                                                        milliseconds:
                                                                            120),
                                                                    curve: Curves
                                                                        .easeInOut,
                                                                    child:
                                                                        ConstrainedBox(
                                                                      constraints:
                                                                          BoxConstraints(
                                                                        minWidth:
                                                                            300,
                                                                        maxWidth:
                                                                            300,
                                                                        minHeight:
                                                                            40,
                                                                        maxHeight:
                                                                            200,
                                                                      ),
                                                                      child:
                                                                          TextField(
                                                                        controller:
                                                                            commentController.mainCommentController,
                                                                        autofocus:
                                                                            true,
                                                                        minLines:
                                                                            1,
                                                                        maxLines:
                                                                            null, // 支持多行自适应
                                                                        keyboardType:
                                                                            TextInputType.multiline,
                                                                        maxLength:
                                                                            500, // 限制最大字数为500
                                                                        decoration:
                                                                            InputDecoration(
                                                                          labelText:
                                                                              '发表评论...',
                                                                          border:
                                                                              OutlineInputBorder(),
                                                                          isDense:
                                                                              true,
                                                                          contentPadding: EdgeInsets.symmetric(
                                                                              vertical: 10,
                                                                              horizontal: 12),
                                                                        ),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15),
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
                                                                            message: commentController.mainImgPath.value.isEmpty ? "添加图片" : '单击以修改,长按以删除',
                                                                            child: GestureDetector(
                                                                                onTap: () async {
                                                                                  commentController.mainImgPath.value = (await showUploadImageCard(imagePath: commentController.mainImgPath.value, shadow: true)) ?? commentController.mainImgPath.value;
                                                                                },
                                                                                onLongPress: () {
                                                                                  commentController.mainImgPath.value = '';
                                                                                },
                                                                                child: commentController.mainImgPath.value != ''
                                                                                    ? ExtendedImage.network(
                                                                                        ApiService.baseUrl + ApiAddr.fileGetResourcet + commentController.mainImgPath.value,
                                                                                        width: 100,
                                                                                        height: 100,
                                                                                        fit: BoxFit.contain, // 保证图片完整显示且有圆角
                                                                                        cache: true,
                                                                                        alignment: Alignment.centerLeft,
                                                                                        enableLoadState: false,
                                                                                      )
                                                                                    : Iconify(
                                                                                        Bx.image_add,
                                                                                        color: Theme.of(context).colorScheme.tertiary,
                                                                                        size: 28,
                                                                                      )))),
                                                                        Obx(() =>
                                                                            IconButton(
                                                                              tooltip: '发表评论',
                                                                              icon: Icon(Icons.send),
                                                                              color: Theme.of(context).colorScheme.primary,
                                                                              onPressed: commentController.operating.value
                                                                                  ? null
                                                                                  : () async {
                                                                                      await commentController.postCommentMain();
                                                                                    },
                                                                            )),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ]);
                                                          }),
                                                          Obx(() {
                                                            if (commentController
                                                                .commentDataList[
                                                                    index]
                                                                .children
                                                                .isEmpty) {
                                                              return SizedBox
                                                                  .shrink();
                                                            }
                                                            return GestureDetector(
                                                              onTap: () async {
                                                                bool t =
                                                                    commentController
                                                                        .showFAB
                                                                        .value;
                                                                commentController
                                                                        .showFAB
                                                                        .value =
                                                                    false;
                                                                commentController
                                                                    .nowSelectCommentId
                                                                    .value = commentController
                                                                        .commentDataList[
                                                                            index]
                                                                        .commentId ??
                                                                    0;
                                                                commentController
                                                                    .inInnerPage
                                                                    .value = true;
                                                                await Get.to(
                                                                    () =>
                                                                        VideoPlayPageCommentsInner(
                                                                          parentCommentId: commentController
                                                                              .commentDataList[index]
                                                                              .commentId!,
                                                                          videoId:
                                                                              widget.videoId,
                                                                        ),
                                                                    // 从右至左
                                                                    transition:
                                                                        Transition
                                                                            .rightToLeft,
                                                                    id: Routes
                                                                            .videoPlayPageCommentsInnerNavId +
                                                                        widget
                                                                            .videoId
                                                                            .hashCode);
                                                                commentController
                                                                    .inInnerPage
                                                                    .value = false;
                                                                commentController
                                                                    .nowSelectCommentId
                                                                    .value = 0;
                                                                commentController
                                                                    .showFAB
                                                                    .value = t;
                                                              },
                                                              child: Card(
                                                                child: SizedBox(
                                                                  width: 280,
                                                                  child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        ListView.builder(
                                                                            itemCount: math.min(commentController.commentDataList[index].children.length, 2),
                                                                            shrinkWrap: true,
                                                                            physics: NeverScrollableScrollPhysics(),
                                                                            itemBuilder: (context, childIndex) {
                                                                              final child = commentController.commentDataList[index].children[childIndex];
                                                                              return Hero(
                                                                                  tag: 'commentContent${child.commentId}',
                                                                                  child: ChildCommentItemWidget(
                                                                                    userName: child.nickName ?? '',
                                                                                    userId: child.userId ?? '',
                                                                                    content: child.content ?? '',
                                                                                    replyNickName: child.replyNickName,
                                                                                    replyUserId: child.replyUserId,
                                                                                  ));
                                                                            }),
                                                                        Obx(
                                                                          () {
                                                                            if (commentController.commentDataList[index].children.length <=
                                                                                2) {
                                                                              return SizedBox.shrink();
                                                                            }
                                                                            return Hero(
                                                                                tag: 'commentTotal${commentController.commentDataList[index].commentId}',
                                                                                child: Padding(
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4),
                                                                                    child: Text(
                                                                                      '共 ${commentController.commentDataList[index].children.length} 条回复',
                                                                                      textAlign: TextAlign.start,
                                                                                      style: TextStyle(
                                                                                        color: Theme.of(context).colorScheme.tertiary,
                                                                                        fontSize: 14,
                                                                                      ),
                                                                                    )));
                                                                          },
                                                                        )
                                                                      ]),
                                                                ),
                                                              ),
                                                            );
                                                          }),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  DividerWithPaddingHorizontal(
                                                      padding: 8)
                                                ]);
                                              },
                                            ))),
                                    // 可扩展评论列表
                                    if (commentController.isLoading.value)
                                      CircularProgressIndicator()
                                  ],
                                ));
                          })),
                  settings: settings,
                );
              },
            )),
        floatingActionButton: GetBuilder<CommentController>(
            tag: '${widget.videoId}CommentController',
            builder: (commentController) {
              if (commentController.showFAB.value) {
                return FloatingActionButton(
                  mini: true,
                  onPressed: () {
                    outterScrollController.animateTo(0,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut);
                  },
                  child: Icon(Icons.arrow_upward),
                );
              } else {
                return SizedBox.shrink();
              }
            }),
        bottomNavigationBar: GetBuilder<CommentController>(
          tag: '${widget.videoId}CommentController',
          builder: (commentController) => Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Row(
              children: [
                Obx(() => Tooltip(
                      message: commentController.inInnerPage.value
                          ? (commentController.innerOutterImgPath.value.isEmpty
                              ? "添加图片"
                              : '单击以修改,长按以删除')
                          : (commentController.outterImgPath.value.isEmpty
                              ? "添加图片"
                              : '单击以修改,长按以删除'),
                      child: GestureDetector(
                        onTap: () async {
                          if (commentController.inInnerPage.value) {
                            commentController.innerOutterImgPath.value =
                                (await showUploadImageCard(
                                      imagePath: commentController
                                          .innerOutterImgPath.value,
                                      shadow: true,
                                    )) ??
                                    commentController.innerOutterImgPath.value;
                          } else {
                            commentController.outterImgPath.value =
                                (await showUploadImageCard(
                                      imagePath:
                                          commentController.outterImgPath.value,
                                      shadow: true,
                                    )) ??
                                    commentController.outterImgPath.value;
                          }
                        },
                        onLongPress: () {
                          if (commentController.inInnerPage.value) {
                            commentController.innerOutterImgPath.value = '';
                          } else {
                            commentController.outterImgPath.value = '';
                          }
                        },
                        child: commentController.inInnerPage.value
                            ? (commentController.innerOutterImgPath.value != ''
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: ExtendedImage.network(
                                      ApiService.baseUrl +
                                          ApiAddr.fileGetResourcet +
                                          commentController
                                              .innerOutterImgPath.value,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      cache: true,
                                      enableLoadState: false,
                                    ),
                                  )
                                : Iconify(
                                    Bx.image_add,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    size: 28,
                                  ))
                            : (commentController.outterImgPath.value != ''
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
                                : Iconify(
                                    Bx.image_add,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    size: 28,
                                  )),
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
                      child: Obx(() => TextField(
                            controller: commentController.inInnerPage.value
                                ? commentController.innerOutterCommentController
                                : commentController.outterCommentController,
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
                          )),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                  tooltip: '发表评论',
                  onPressed: commentController.operating.value
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
