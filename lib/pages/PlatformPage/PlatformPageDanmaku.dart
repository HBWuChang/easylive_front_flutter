import 'package:easylive/Funcs.dart';
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
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlatformPageDanmaku extends StatefulWidget {
  const PlatformPageDanmaku({Key? key}) : super(key: key);
  @override
  State<PlatformPageDanmaku> createState() => _PlatformPageDanmakuState();
}

class _PlatformPageDanmakuState extends State<PlatformPageDanmaku> {
  @override
  void initState() {
    super.initState();
    print('PlatformPageDanmaku initState');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text('弹幕管理',
            style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold)));
  }
}
