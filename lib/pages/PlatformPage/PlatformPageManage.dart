import 'package:easylive/Funcs.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/pages/PlatformPage/PlatformPage.dart';
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
import 'package:flutter/services.dart';

class PlatformPageManage extends StatefulWidget {
  const PlatformPageManage({Key? key}) : super(key: key);
  @override
  State<PlatformPageManage> createState() => _PlatformPageManageState();
}

class _PlatformPageManageState extends State<PlatformPageManage> {
  @override
  void initState() {
    super.initState();
    print('PlatformPageManage initState');
    loadData();
  }

  var videoCountInfo =
      {"auditPassCount": 0, "auditFailCount": 0, "inProgress": 0}.obs;
  var auditPassData = {}.obs;
  var auditFailData = {}.obs;
  var inProgressData = {}.obs;
  var nowSelectIndex = 0.obs;
  TextEditingController videoNameFuzzy = TextEditingController();
  void loadData({List<int> index = const [0, 1, 2]}) async {
    try {
      var videoCountInfoRes = await ApiService.ucenterGetVideoCountInfo();
      videoCountInfo.value = Map<String, int>.from(
        (videoCountInfoRes['data'] as Map)
            .map((k, v) => MapEntry(k as String, (v as num).toInt())),
      );
      for (var i in index) {
        switch (i) {
          case 0:
            var t = (await ApiService.ucenterLoadVideoList(
                status: VideoStatusEnum.STATUS3.status,
                pageNo: 1,
                videoNameFuzzy: videoNameFuzzy.text))['data'];
            auditPassData.value = t;
            break;
          case 1:
            var t = (await ApiService.ucenterLoadVideoList(
                status: VideoStatusEnum.STATUS4.status,
                pageNo: 1,
                videoNameFuzzy: videoNameFuzzy.text))['data'];
            auditFailData.value = t;
            break;
          case 2:
            var t = (await ApiService.ucenterLoadVideoList(
                status: VideoStatusEnum.STATUS2.status,
                pageNo: 1,
                videoNameFuzzy: videoNameFuzzy.text))['data'];
            inProgressData.value = t;
            break;
        }
      }
    } catch (e) {
      showErrorSnackbar("加载数据失败$e");
    }
  }

  var pageController = PreloadPageController(initialPage: 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 360,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 30,
                    child: Row(
                      children: List.generate(3, (index) {
                        final titles = ['已通过', '未通过', '审核中'];
                        return Expanded(
                          child: TextButton(
                              onPressed: () {
                                pageController.animateToPage(
                                  index,
                                  duration: Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                              child: Obx(() => Text(
                                    titles[index] +
                                        (index == 0
                                            ? '(${videoCountInfo['auditPassCount']})'
                                            : (index == 1
                                                ? '(${videoCountInfo['auditFailCount']})'
                                                : '(${videoCountInfo['inProgress']})')),
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ))),
                        );
                      }),
                    ),
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
                              page = pageController.hasClients &&
                                      pageController.page != null
                                  ? pageController.page!
                                  : pageController.initialPage.toDouble();
                            } catch (_) {}
                            double width = constraints.maxWidth / 3;
                            // 计算下划线长度
                            double minLine = width * 0.7;
                            double maxLine = width * 1.4;
                            double progress = (page - page.floor()).abs();
                            // 取距离最近的整数页
                            double dist =
                                (progress > 0.5) ? 1 - progress : progress;
                            // dist: 0时在正下方，0.5时在中间
                            double lineWidth =
                                minLine + (maxLine - minLine) * (dist * 2);
                            // 计算下划线左侧位置，使其居中
                            double left =
                                page * width + (width - lineWidth) / 2;
                            return Stack(
                              children: [
                                Positioned(
                                  left: left,
                                  width: lineWidth,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
              ),
            ),
            SizedBox(
                height: 34,
                width: 300,
                child: TextField(
                  controller: videoNameFuzzy,
                  decoration: InputDecoration(
                      hintText: '请输入视频名称',
                      border: OutlineInputBorder(),
                      suffixIcon: SizedBox(
                          width: 80,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  size: 14,
                                ),
                                onPressed: () {
                                  videoNameFuzzy.clear();
                                  loadData(index: [nowSelectIndex.value]);
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.search,
                                  size: 20,
                                ),
                                onPressed: () {
                                  loadData(index: [nowSelectIndex.value]);
                                },
                              )
                            ],
                          ))),
                  onSubmitted: (value) {
                    loadData(index: [nowSelectIndex.value]);
                  },
                ))
          ],
        ),
        Expanded(
          child: PreloadPageView.builder(
            controller: pageController,
            itemCount: 3,
            preloadPagesCount: 3,
            physics: BouncingScrollPhysics(),
            onPageChanged: (index) {
              nowSelectIndex.value = index;
              loadData(index: [index]);
            },
            itemBuilder: (context, index) {
              return Obx(() {
                var data = {};
                switch (index) {
                  case 0:
                    data = auditPassData;
                    break;
                  case 1:
                    data = auditFailData;
                    break;
                  case 2:
                    data = inProgressData;
                    break;
                }
                if (data.isEmpty || data['list'].isEmpty) {
                  return Center(
                    child: Text(
                      '暂无数据',
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: data['list'].length,
                  itemBuilder: (context, i) {
                    var video = data['list'][i];
                    return Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Card(
                            clipBehavior: Clip.hardEdge,
                            child: ListTile(
                              subtitle: Row(children: [
                                SizedBox(
                                    width: 120 *
                                        CropAspectRatioEnum.VIDEO_COVER.ratio,
                                    height: 120,
                                    child: Card(
                                        clipBehavior: Clip.hardEdge,
                                        child: video['videoCover'] != null
                                            ? ExtendedImage.network(
                                                ApiService.baseUrl +
                                                    ApiAddr.fileGetResourcet +
                                                    video['videoCover'],
                                                fit: BoxFit.cover,
                                              )
                                            : Icon(Icons.video_file,
                                                size: 50))),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // 标题：点击后自动显示全部并全选，不可编辑
                                        GestureDetector(
                                          onTap: () async {
                                            await showDialog(
                                              context: context,
                                              builder: (ctx) {
                                                final controller =
                                                    TextEditingController(
                                                        text: video[
                                                                'videoName'] ??
                                                            '');
                                                // 弹窗打开后自动全选
                                                return AlertDialog(
                                                  title: Text('视频标题'),
                                                  content: TextField(
                                                    controller: controller,
                                                    autofocus: true,
                                                    readOnly: true,
                                                    enableInteractiveSelection:
                                                        true,
                                                    decoration: InputDecoration(
                                                        border:
                                                            OutlineInputBorder()),
                                                    onTap: () => controller
                                                            .selection =
                                                        TextSelection(
                                                            baseOffset: 0,
                                                            extentOffset:
                                                                controller.text
                                                                    .length),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Clipboard.setData(
                                                            ClipboardData(
                                                                text: controller
                                                                    .text));
                                                        Navigator.of(ctx).pop();
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                              content: Text(
                                                                  '已复制到剪贴板')),
                                                        );
                                                      },
                                                      child: Text('复制'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.of(ctx)
                                                              .pop(),
                                                      child: Text('关闭'),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                                maxWidth:
                                                    Get.width - 600), // 限制最大宽度
                                            child: Text(
                                              video['videoName'] ?? '',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Container(
                                          width: 70,
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.shade50,
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            video['statusName'] ?? '',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    // 简介：点击后自动显示全部并全选，不可编辑
                                    GestureDetector(
                                      onTap: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (ctx) {
                                            final controller =
                                                TextEditingController(
                                                    text:
                                                        video['introduction'] ??
                                                            '');
                                            return AlertDialog(
                                              title: Text('视频简介'),
                                              content: TextField(
                                                controller: controller,
                                                autofocus: true,
                                                readOnly: true,
                                                enableInteractiveSelection:
                                                    true,
                                                maxLines: null,
                                                decoration: InputDecoration(
                                                    border:
                                                        OutlineInputBorder()),
                                                onTap: () => controller
                                                        .selection =
                                                    TextSelection(
                                                        baseOffset: 0,
                                                        extentOffset: controller
                                                            .text.length),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Clipboard.setData(
                                                        ClipboardData(
                                                            text: controller
                                                                .text));
                                                    Navigator.of(ctx).pop();
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content:
                                                              Text('已复制到剪贴板')),
                                                    );
                                                  },
                                                  child: Text('复制'),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.of(ctx).pop(),
                                                  child: Text('关闭'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: SizedBox(
                                          width: Get.width - 600,
                                          child: Text(
                                            video['introduction'] ?? '',
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.grey[700]),
                                          )),
                                    ),

                                    SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Text('更新时间',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                        SizedBox(width: 2),
                                        Text(video['lastUpdateTime'] ?? '',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                        SizedBox(width: 16),
                                        Text('创建时间',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                        SizedBox(width: 2),
                                        Text(video['createTime'] ?? '',
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey)),
                                      ],
                                    ),
                                    SizedBox(height: 6),
                                    if ((video['tags'] ?? '').isNotEmpty)
                                      Wrap(
                                        spacing: 6,
                                        children: [
                                          for (var tag
                                              in (video['tags'] as String)
                                                  .split(','))
                                            Chip(
                                              label: Text(tag,
                                                  style:
                                                      TextStyle(fontSize: 11)),
                                              backgroundColor:
                                                  Colors.green.shade50,
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                              ]),
                              onTap: () {},
                              trailing: SizedBox(
                                  width: 80,
                                  child: Row(children: [
                                    index != 2
                                        ? IconButton(
                                            tooltip: '编辑视频',
                                            icon: Icon(Icons.edit),
                                            onPressed: () async {
                                              bool confirm =
                                                  await showConfirmDialog(
                                                      '确认编辑此视频吗？\n此操作会覆盖当前正在投稿的视频信息');
                                              if (confirm == true) {
                                                try {
                                                  var platformPageSubmitController =
                                                      Get.find<
                                                          PlatformPageSubmitController>();
                                                  await platformPageSubmitController
                                                      .setVideoDataFromVideoId(
                                                          video['videoId']);
                                                  platformPageJumpToPage(1);
                                                  platformPageSubmitController
                                                      .pageController
                                                      .jumpToPage(1);
                                                } catch (e) {
                                                  showErrorSnackbar("编辑视频失败$e");
                                                }
                                              }
                                            })
                                        : SizedBox(width: 40),
                                    IconButton(
                                        tooltip: '删除视频',
                                        icon: Icon(Icons.delete),
                                        onPressed: () async {
                                          bool confirm =
                                              await showConfirmDialog(
                                                  '确认删除此视频吗？');
                                          if (confirm == true) {
                                            try {
                                              await ApiService
                                                  .ucenterDeleteVideo(
                                                      video['videoId']);
                                              loadData(index: [
                                                nowSelectIndex.value
                                              ]);
                                            } catch (e) {
                                              showErrorSnackbar("删除失败$e");
                                            }
                                          }
                                        }),
                                  ])),
                            )));
                  },
                );
              });
            },
          ),
        ),
      ],
    ));
  }
}
