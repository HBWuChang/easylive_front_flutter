import 'package:easylive/Funcs.dart';
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

class PlatformPageComment extends StatefulWidget {
  const PlatformPageComment({Key? key}) : super(key: key);
  @override
  State<PlatformPageComment> createState() => _PlatformPageCommentState();
}

class _PlatformPageCommentState extends State<PlatformPageComment> {
  @override
  void initState() {
    super.initState();
    print('PlatformPageComment initState');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text('评论管理',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)));
  }
}