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

class VideoPlayPageComments extends StatelessWidget {
  final String videoId;
  const VideoPlayPageComments({required this.videoId, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GetBuilder<CommentController>(
            tag: '${videoId}CommentController',
            builder: (commentController) => Obx(() {
                  return Column(
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
                                                CommentOrderTypeEnum.HOT.type
                                            ? null
                                            : Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                        fontWeight: commentController
                                                    .orderType.value ==
                                                CommentOrderTypeEnum.HOT.type
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
                                                CommentOrderTypeEnum.NEW.type
                                            ? null
                                            : Theme.of(context)
                                                .colorScheme
                                                .tertiary,
                                        fontWeight: commentController
                                                    .orderType.value ==
                                                CommentOrderTypeEnum.NEW.type
                                            ? FontWeight.bold
                                            : FontWeight.normal)))),
                          ],
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Obx(() => ListView.builder(
                                shrinkWrap: true,
                                itemCount:
                                    commentController.commentDataList.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      SizedBox(),
                                      DividerWithPaddingHorizontal(padding: 8)
                                    ],
                                  );
                                },
                              ))),
                      // 可扩展评论列表
                      if (commentController.isLoading.value)
                        CircularProgressIndicator()
                    ],
                  );
                })));
  }
}
