import 'package:easylive/Funcs.dart';
import 'package:easylive/enums.dart';
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

class PlatformPageSubmit extends StatefulWidget {
  const PlatformPageSubmit({Key? key}) : super(key: key);
  @override
  State<PlatformPageSubmit> createState() => _PlatformPageSubmitState();
}

class _PlatformPageSubmitState extends State<PlatformPageSubmit> {
  final ControllersInitController controllersInitController =
      Get.find<ControllersInitController>();
  late PlatformPageSubmitController platformPageSubmitController;
  var categoryLoadAllCategoryController =
      Get.find<CategoryLoadAllCategoryController>();
  final PageController _pageController = PageController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    initPlatformPageSubmitController();
  }

  initPlatformPageSubmitController({bool force = false}) {
    if (force) {
      Get.delete<PlatformPageSubmitController>();
      Get.put(PlatformPageSubmitController());
    } else {
      if (!controllersInitController
          .isPlatformPageSubmitControllerInitialized.value) {
        controllersInitController.initPlatformPageSubmitController();
      }
    }
    platformPageSubmitController = Get.find<PlatformPageSubmitController>();
  }

  void uploadFiles(List<XFile> files) async {
    print('开始上传文件: ${files.length} 个文件');

    for (var file in files) {
      print('上传文件: ${file.name}');
      String fileName = file.name;
      String ext = fileName.split('.').last.toLowerCase();
      fileName = fileName.replaceAll('.$ext', '');
      var videoInfoFilePostController = VideoInfoFilePostController();
      Uint8List videoData = await file.readAsBytes();
      String uploadId =
          await videoInfoFilePostController.preUploadVideo(videoData, fileName);
      Get.put(videoInfoFilePostController, tag: uploadId);
      VideoInfoFilePost videoInfoFilePost =
          VideoInfoFilePost(uploadId: uploadId, fileName: fileName);
      platformPageSubmitController.addUploadFile(videoInfoFilePost);
    }
  }

  void processFiles(List<XFile> files) async {
    try {
      print('onDragDone: ${files.length} files');
      for (var file in files) {
        final ext = file.name.split('.').last.toLowerCase();
        if (!(<String>['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv']
            .contains(ext))) {
          // hasUnVideoFile = true;
          throw Exception('请选择视频文件');
        }
      }
      int videoSizeLimit =
          Get.find<SysSettingGetSettingController>().videoSize.value *
              1024 *
              1024;
      for (var file in files) {
        var tl = await file.length();
        if (tl > videoSizeLimit) {
          throw Exception(
              '文件过大，最大限制为 ${Get.find<SysSettingGetSettingController>().videoSize.value} MB');
        }
      }
      uploadFiles(files);
      _pageController.jumpToPage(1);
    } catch (e) {
      Get.snackbar('错误', e.toString());
    }
  }

  // 选择文件（web和windows通用）
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'avi', 'mov', 'wmv', 'flv', 'webm', 'mkv'],
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      List<XFile> files = result.files.map((file) => file.xFile).toList();
      processFiles(files);
    } else {
      Get.snackbar('错误', '未选择任何文件');
    }
  }

  Widget widgetWithName(String name, Widget widget,
      {bool isRequired = false, double? width}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(isRequired ? '*' : '  ',
            style: TextStyle(color: Colors.red, fontSize: 16)),
        Text(name, style: TextStyle(fontSize: 16)),
        SizedBox(width: 16),
        SizedBox(
          width: width ?? Get.width - 230,
          child: widget,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        // 第一个页面：选择/拖放上传
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      platformPageSubmitController.uploadFileList.isEmpty
                          ? SizedBox.shrink()
                          : TextButton.icon(
                              onPressed: () {
                                _pageController.jumpToPage(1);
                              },
                              label: Text('修改上传信息'),
                              icon: Icon(Icons.edit, size: 16),
                            ),
                    ],
                  )),
              DropTarget(
                onDragDone: (detail) async {
                  processFiles(detail.files);
                },
                child: Container(
                  height: 400,
                  width: 600,
                  decoration: DottedDecoration(
                    color: Colors.blue,
                    shape: Shape.box,
                    borderRadius: const BorderRadius.all(Radius.circular(24)),
                  ),
                  child: Center(child: Text("将视频文件拖放到此处")),
                ),
              ),
              Text(
                '或',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.file_open),
                label: Text('选择视频文件'),
                onPressed: _pickFile,
              ),
              SizedBox(height: 24),
            ],
          ),
        ),
        // 第二个页面：显示上传信息
        Center(
          child: SingleChildScrollView(
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.start, children: [
            Obx(() {
              return Card(
                  child: Column(children: [
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ListTile(
                        title: Text(
                          '上传任务列表',
                        ),
                        subtitle: Text(
                            '已添加 ${platformPageSubmitController.uploadFileList.length} /${platformPageSubmitController.videoPcountLimit.value} '),
                        trailing: TextButton.icon(
                            onPressed: () {
                              _pageController.jumpToPage(0);
                            },
                            label: Text('添加视频'),
                            icon: Icon(Icons.add_circle_outline)))),
                ReorderableListView(
                  shrinkWrap: true,
                  clipBehavior: Clip.none,
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    var item = platformPageSubmitController.uploadFileList
                        .removeAt(oldIndex);
                    platformPageSubmitController.uploadFileList
                        .insert(newIndex, item);
                  },
                  children: platformPageSubmitController.uploadFileList
                      .map((videoInfoFilePost) {
                    String uploadId = videoInfoFilePost.uploadId!;
                    var videoInfoFilePostController =
                        Get.find<VideoInfoFilePostController>(tag: uploadId);
                    var fileName = videoInfoFilePostController.fileName.obs;
                    var _key = GlobalKey();
                    return Card(
                        key: _key,
                        color: Theme.of(context).colorScheme.onPrimary,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Obx(() => Text(fileName.value)),
                          subtitle: Obx(() {
                            return Text(
                              '上传进度: ${videoInfoFilePostController.process.value.toStringAsFixed(2)}%',
                              style: TextStyle(
                                color:
                                    videoInfoFilePostController.process.value ==
                                            100.0
                                        ? Colors.green
                                        : Colors.black87,
                              ),
                            );
                          }),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              if (platformPageSubmitController
                                      .uploadFileList.length <=
                                  1) {
                                Get.snackbar('提示', '至少保留一个上传任务');
                                return;
                              }
                              // 确认删除
                              bool? confirmDelete = await Get.dialog(
                                AlertDialog(
                                  title: Text('确认删除'),
                                  content: Text(
                                      '确定要删除上传任务 "${videoInfoFilePostController.fileName}" 吗？'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(result: false),
                                      child: Text('取消'),
                                    ),
                                    TextButton(
                                      onPressed: () => Get.back(result: true),
                                      child: Text('删除'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmDelete == null || !confirmDelete)
                                return;
                              // 删除上传任务
                              platformPageSubmitController
                                  .removeUploadFile(videoInfoFilePost);
                              await videoInfoFilePostController.cancelUpload();
                              Get.delete<VideoInfoFilePostController>(
                                  tag: uploadId);
                            },
                          ),
                          onTap: () {
                            void _do() {
                              try {
                                videoInfoFilePostController.updateFileName();
                                platformPageSubmitController
                                    .updateUploadFileName(videoInfoFilePost,
                                        videoInfoFilePostController.fileName);
                                fileName.value =
                                    videoInfoFilePostController.fileName;
                                Get.back();
                              } catch (e) {
                                Get.snackbar('错误', e.toString());
                                return;
                              }
                            }

                            // 修改名称
                            Get.dialog(
                              AlertDialog(
                                title: Text('修改分P名称'),
                                content: TextField(
                                  controller: videoInfoFilePostController
                                      .getVideoNameController,
                                  decoration: InputDecoration(
                                    labelText: '新名称',
                                  ),
                                  autofocus: true,
                                  onSubmitted: (value) => _do(),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: Text('取消'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _do();
                                    },
                                    child: Text('确定'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ));
                  }).toList(),
                )
              ]));
            }),
            SizedBox(height: 16),
            // 基本设置
            Form(
                key: _formKey,
                child: Card(
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(children: [
                          Text('基本设置',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),
                          widgetWithName(
                              '封面',
                              Card(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  clipBehavior: Clip.hardEdge,
                                  child: Container(
                                      width: 214,
                                      height: 120,
                                      child: GestureDetector(
                                        onTap: () async {
                                          platformPageSubmitController
                                              .videoCover
                                              .value = (await showUploadImageCard(
                                                  imagePath:
                                                      platformPageSubmitController
                                                                  .videoCover
                                                                  .value ==
                                                              ''
                                                          ? null
                                                          : platformPageSubmitController
                                                              .videoCover.value,
                                                  cropAspectRatios: {
                                                    CropAspectRatioEnum
                                                            .VIDEO_COVER.type:
                                                        CropAspectRatioEnum
                                                            .VIDEO_COVER.ratio
                                                  },
                                                  shadow: true)) ??
                                              platformPageSubmitController
                                                  .videoCover.value;
                                        },
                                        child: Obx(() {
                                          return platformPageSubmitController
                                                      .videoCover.value !=
                                                  ''
                                              ? ExtendedImage.network(
                                                  ApiService.baseUrl +
                                                      ApiAddr.fileGetResourcet +
                                                      platformPageSubmitController
                                                          .videoCover.value,
                                                  width: 214,
                                                  height: 120,
                                                  fit: BoxFit.cover,
                                                  cache: true,
                                                )
                                              : Center(child: Text('点击选择封面'));
                                        }),
                                      ))),
                              isRequired: true,
                              width: 230),
                          widgetWithName(
                            '标题',
                            TextFormField(
                              controller: platformPageSubmitController
                                  .videoNameController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '请输入视频标题',
                                // counterText: '',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '标题不能为空';
                                }
                                return null;
                              },
                              maxLength: 80, // 标题字数限制
                            ),
                            isRequired: true,
                          ),
                          SizedBox(height: 16),
                          widgetWithName(
                            '类型',
                            Row(children: [
                              Obx(() {
                                return Row(
                                  children: [
                                    Radio<int>(
                                      value: 0,
                                      groupValue: platformPageSubmitController
                                          .postType.value,
                                      onChanged: (value) {
                                        platformPageSubmitController
                                            .postType.value = value!;
                                      },
                                    ),
                                    Text('自制'),
                                    SizedBox(width: 16),
                                    Radio<int>(
                                      value: 1,
                                      groupValue: platformPageSubmitController
                                          .postType.value,
                                      onChanged: (value) {
                                        platformPageSubmitController
                                            .postType.value = value!;
                                      },
                                    ),
                                    Text('转载'),
                                  ],
                                );
                              }),
                              SizedBox(
                                width: 20,
                              ),
                              Obx(() {
                                if (platformPageSubmitController
                                        .postType.value !=
                                    1) return SizedBox.shrink();

                                return SizedBox(
                                  width: 590,
                                  child: TextFormField(
                                    controller: platformPageSubmitController
                                        .origin_infoController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: '请输入转载来源',
                                      // counterText: '',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '转载来源不能为空';
                                      }
                                      return null;
                                    },
                                    maxLength: 200,
                                  ),
                                );
                              })
                            ]),
                            isRequired: true,
                          ),
                          SizedBox(height: 16),
                          widgetWithName(
                            '分区',
                            Obx(() {
                              final categories =
                                  categoryLoadAllCategoryController.categories;
                              var currentId = platformPageSubmitController
                                  .pCategoryId.value;
                              final validIds = categories
                                  .map((c) => c['categoryId'])
                                  .toList();
                              if (!validIds.contains(currentId) &&
                                  validIds.isNotEmpty) {
                                // 自动修正
                                platformPageSubmitController.pCategoryId.value =
                                    validIds.first;
                                currentId = validIds.first;
                              }
                              final childCategories = categories
                                  .where((c) => c['categoryId'] == currentId)
                                  .toList()[0]['children'];
                              var childCurrentId =
                                  platformPageSubmitController.categoryId.value;
                              var childValidIds =
                                  childCategories.map((c) => c['categoryId']);
                              if (childCategories.isNotEmpty) {
                                if (!childValidIds.contains(childCurrentId)) {
                                  // 自动修正
                                  Future.microtask(() {
                                    platformPageSubmitController
                                        .categoryId.value = childValidIds.first;
                                  });
                                }
                              }

                              return SizedBox(
                                  width: 400,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                          width: 200,
                                          child: DropdownButtonFormField<int>(
                                            value: validIds.contains(currentId)
                                                ? currentId
                                                : null,
                                            items: categories
                                                .map<DropdownMenuItem<int>>(
                                                    (category) =>
                                                        DropdownMenuItem<int>(
                                                          value: category[
                                                              'categoryId'],
                                                          child: Text(category[
                                                              'categoryName']),
                                                        ))
                                                .toList(),
                                            onChanged: (value) {
                                              platformPageSubmitController
                                                  .pCategoryId
                                                  .value = value ?? 0;
                                              platformPageSubmitController
                                                  .categoryId.value = 0;
                                            },
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .outline,
                                                ),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  width: 2,
                                                ),
                                              ),
                                              filled: true,
                                              fillColor: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                              hintText: '请选择视频分类',
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 12),
                                            ),
                                            dropdownColor: Theme.of(context)
                                                .colorScheme
                                                .surface,
                                            icon: Icon(Icons.arrow_drop_down,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              fontSize: 15,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          )),
                                      SizedBox(width: 16),
                                      if (childCategories.isNotEmpty)
                                        SizedBox(
                                            width: 200,
                                            child: DropdownButtonFormField<int>(
                                              value: childValidIds
                                                      .contains(childCurrentId)
                                                  ? childCurrentId
                                                  : null,
                                              items: childCategories
                                                  .map<DropdownMenuItem<int>>(
                                                      (category) =>
                                                          DropdownMenuItem<int>(
                                                            value: category[
                                                                'categoryId'],
                                                            child: Text(category[
                                                                'categoryName']),
                                                          ))
                                                  .toList(),
                                              onChanged: (value) {
                                                platformPageSubmitController
                                                    .categoryId
                                                    .value = value ?? 0;
                                              },
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .outline,
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    width: 2,
                                                  ),
                                                ),
                                                filled: true,
                                                fillColor: Theme.of(context)
                                                    .colorScheme
                                                    .surface,
                                                hintText: '请选择视频二级分类',
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 12),
                                              ),
                                              dropdownColor: Theme.of(context)
                                                  .colorScheme
                                                  .surface,
                                              icon: Icon(Icons.arrow_drop_down,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary),
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                fontSize: 15,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ))
                                    ],
                                  ));
                            }),
                            isRequired: true,
                          ),
                          SizedBox(height: 16),
                          widgetWithName(
                            '标签',
                            Column(children: [
                              Obx(() => Wrap(
                                    spacing: 8,
                                    children: platformPageSubmitController.tags
                                        .map((tag) => Chip(
                                              label: Text(tag),
                                              onDeleted: () {
                                                platformPageSubmitController
                                                    .removeTag(tag);
                                              },
                                            ))
                                        .toList(),
                                  )),
                              Obx(() => TextFormField(
                                    controller: platformPageSubmitController
                                        .tagsController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                      suffixText:
                                          '还可添加 ${10 - platformPageSubmitController.tags.length} 个标签',
                                      hintText: '按回车键创建标签',
                                      // counterText: '',
                                    ),
                                    validator: (value) {
                                      if (platformPageSubmitController
                                          .tags.isEmpty) {
                                        return '至少添加一个标签';
                                      }
                                      return null;
                                    },
                                    maxLength: 19,
                                    onFieldSubmitted: (value) {
                                      if (value.trim().isNotEmpty &&
                                          platformPageSubmitController
                                                  .tags.length <
                                              10) {
                                        platformPageSubmitController
                                            .addTag(value);
                                        platformPageSubmitController
                                            .tagsController
                                            .clear();
                                        FocusScope.of(context)
                                            .requestFocus(FocusNode());
                                        // 再次聚焦到当前输入框
                                        Future.delayed(
                                            Duration(milliseconds: 10), () {
                                          FocusScope.of(context).requestFocus(
                                            platformPageSubmitController
                                                .tagsFocusNode,
                                          );
                                        });
                                      }
                                    },
                                    focusNode: platformPageSubmitController
                                        .tagsFocusNode,
                                  ))
                            ]),
                            isRequired: true,
                          ),
                          SizedBox(height: 16),
                          widgetWithName(
                            '简介',
                            TextFormField(
                              controller: platformPageSubmitController
                                  .introductionController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '请输入视频简介',
                                // counterText: '',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '简介不能为空';
                                }
                                return null;
                              },
                              maxLength: 2000, // 简介字数限制
                              maxLines: 5,
                            ),
                            isRequired: false,
                          ),
                          SizedBox(height: 16),
                          // widgetWithName(
                          //   '转载来源',
                          //   TextFormField(
                          //     // controller: platformPageSubmitController.sourceController,
                          //     decoration: InputDecoration(
                          //       border: OutlineInputBorder(),
                          //       hintText: '如为转载请填写来源',
                          //       // counterText: '',
                          //     ),
                          //     maxLength: 60, // 转载来源字数限制
                          //   ),
                          //   isRequired: false,
                          // ),
                          SizedBox(height: 16),
                        ])))),
            Card(
                child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(children: [
                      Text('更多设置',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 16),
                      widgetWithName(
                          '互动设置',
                          Row(children: [
                            Obx(() {
                              return Row(
                                children: [
                                  Checkbox(
                                    value: platformPageSubmitController
                                        .disableComment.value,
                                    onChanged: (value) {
                                      platformPageSubmitController
                                          .disableComment.value = value!;
                                    },
                                  ),
                                  Text('关闭评论'),
                                  SizedBox(width: 16),
                                  Checkbox(
                                    value: platformPageSubmitController
                                        .disableDanmaku.value,
                                    onChanged: (value) {
                                      platformPageSubmitController
                                          .disableDanmaku.value = value!;
                                    },
                                  ),
                                  Text('关闭弹幕'),
                                ],
                              );
                            }),
                          ]),
                          isRequired: false,
                          width: 230),
                    ]))),

            SizedBox(
                height: 50,
                child: TextButton.icon(
                    style: TextButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16))),
                    onPressed: () async {
                      try {
                        for (var filePost
                            in platformPageSubmitController.uploadFileList) {
                          if (filePost.fileName!.isEmpty) {
                            throw Exception('请确保所有分P名称不为空');
                          }
                          VideoInfoFilePostController
                              videoInfoFilePostController =
                              Get.find<VideoInfoFilePostController>(
                                  tag: filePost.uploadId);
                          if (videoInfoFilePostController.isUploading.value) {
                            throw Exception('请等待所有分P上传完成');
                          }
                        }
                        if (platformPageSubmitController.videoCover.value ==
                            '') {
                          throw Exception('请先选择视频封面');
                        }
                        if (!_formKey.currentState!.validate()) {
                          return;
                        }
                        await platformPageSubmitController.submitVideoInfo();
                        Get.snackbar('提示', '投稿成功，等待审核');
                        initPlatformPageSubmitController(force: true);
                        _pageController.jumpToPage(0);
                      } catch (e) {
                        Get.snackbar('错误', e.toString());
                        return;
                      }
                    },
                    icon: Icon(Icons.upload_file,
                        size: 20,
                        color: Theme.of(context).colorScheme.onPrimary),
                    label: Text('立即投稿',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)))),
            SizedBox(
              height: 50,
            )
          ])),
        ),
      ],
    );
  }
}
