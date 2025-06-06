import 'package:easylive/Funcs.dart';
import 'package:easylive/pages2.dart';
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

import 'PlatformPageComment.dart';
import 'PlatformPageDanmaku.dart';
import 'PlatformPageHome.dart';
import 'PlatformPageManage.dart';
import 'PlatformPageSubmit.dart';

class PlatformPage extends StatefulWidget {
  const PlatformPage({Key? key}) : super(key: key);
  @override
  State<PlatformPage> createState() => _PlatformPageState();
}

var platformPageJumpToPage;

class _PlatformPageState extends State<PlatformPage> {
  final AccountController accountController = Get.find<AccountController>();
  final PreloadPageController _pageController = PreloadPageController();
  int _selectedIndex = 0;
  final pages = [
    PlatformPageHome(),
    PlatformPageSubmit(),
    PlatformPageManage(),
    PlatformPageComment(),
    PlatformPageDanmaku(),
  ];
  void _jumpToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  void initState() {
    super.initState();
    platformPageJumpToPage = _jumpToPage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 130,
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Center(
                  child: Text(
                    '创作中心',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.upload_file,
                        color: Theme.of(context).colorScheme.onPrimary),
                    label: Text('投稿'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      textStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _jumpToPage(1),
                  ),
                ),
                _sideBtn('首页', Icons.home, 0, _selectedIndex == 0, _jumpToPage),
                _sideBtn(
                    '稿件管理', Icons.article, 2, _selectedIndex == 2, _jumpToPage),
                _sideBtn(
                    '评论管理', Icons.comment, 3, _selectedIndex == 3, _jumpToPage),
                _sideBtn('弹幕管理', Icons.subtitles, 4, _selectedIndex == 4,
                    _jumpToPage),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
          Expanded(
            child: PreloadPageView.builder(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              preloadPagesCount: pages.length - 1,
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return pages[index];
              },
            ),
          ),
        ],
      ),
    );
  }
}

Widget _sideBtn(String text, IconData icon, int pageIndex, bool selected,
    void Function(int) onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
    child: TextButton.icon(
      icon: Icon(icon,
          size: 16,
          color: selected
              ? Theme.of(Get.context!).colorScheme.primary
              : Theme.of(Get.context!).colorScheme.onSurface),
      label: Text(text,
          style: TextStyle(
              fontSize: 13,
              color: selected
                  ? Theme.of(Get.context!).colorScheme.primary
                  : Theme.of(Get.context!).colorScheme.onSurface)),
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        alignment: Alignment.centerLeft,
        backgroundColor: selected
            ? Theme.of(Get.context!).colorScheme.primary.withOpacity(0.08)
            : null,
        elevation: 0,
      ),
      onPressed: () => onTap(pageIndex),
    ),
  );
}
