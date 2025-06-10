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
