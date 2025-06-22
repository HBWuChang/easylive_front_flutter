import 'package:easylive/Funcs.dart';
import 'package:easylive/settings.dart';
import 'package:easylive/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'controllers/controllers-class.dart';
import 'api_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UpdateUserInfoCard extends StatefulWidget {
  final double? areaWidth;
  final double? areaHeight;
  const UpdateUserInfoCard({Key? key, this.areaWidth, this.areaHeight})
      : super(key: key);
  @override
  _UpdateUserInfoCardState createState() => _UpdateUserInfoCardState();
}

class _UpdateUserInfoCardState extends State<UpdateUserInfoCard> {
  final UserInfoController userInfoController = UserInfoController();
  // {
  //   "userId": "0636309642",
  //   "nickName": "神山识",
  //   "avatar": "cover/202505\\\\zaPVfHfyRoJWX7EH5WOqLP2AytxhXB.webp",
  //   "sex": 2,
  //   "personIntroduction": null,
  //   "noticeInfo": null,
  //   "grade": null,
  //   "birthday": null,
  //   "school": null,
  //   "fansCount": 1,
  //   "focusCount": 1,
  //   "likeCount": 0,
  //   "playCount": 8,
  //   "haveFocus": false,
  //   "theme": "https://s.040905.xyz/d/v/business-spirit-unit.gif?%E2%80%A6gn=uDy2k6zQMaZr8CnNBem03KTPdcQGX-JVOIRcEBcVOhk=:0"
  // }
  final TextEditingController nickNameController = TextEditingController();
  final TextEditingController personIntroductionController =
      TextEditingController();
  final TextEditingController noticeInfoController = TextEditingController();
  final TextEditingController schoolController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  void getUserInfo() async {
    try {
      var userInfo = await userInfoController
          .getUserInfo(Get.find<AccountController>().userId!);
      nickNameController.text = userInfo['nickName'] ?? '';
      personIntroductionController.text = userInfo['personIntroduction'] ?? '';
      noticeInfoController.text = userInfo['noticeInfo'] ?? '';
      schoolController.text = userInfo['school'] ?? '';
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Constants.updateUserInfoCardWidth.w,
      height: Constants.updateUserInfoCardHeight.w,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                Column(children: [
                  Text(
                    Texts.updateUserInfo,
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16.w),
                ]),
                Tooltip(
                  message: Texts.changeAvatar,
                  child: GestureDetector(
                      onTap: () async {
                        var res = await showUploadImageCard(
                            imagePath: userInfoController.avatar!);
                        if (res != null) {
                          userInfoController.avatar = res;
                        }
                      },
                      child: Obx(() => Avatar(
                            avatarValue: userInfoController.avatar,
                            radius: 40.r,
                          ))),
                ),
              ]),
              TextField(
                controller: nickNameController,
                decoration: InputDecoration(
                  labelText: Texts.userName,
                ),
                maxLength: 20,
              ),
              SizedBox(height: 8.w),
              TextField(
                controller: personIntroductionController,
                decoration:
                    InputDecoration(labelText: Texts.personIntroduction),
                maxLength: 80,
              ),
              SizedBox(height: 8.w),
              TextField(
                controller: noticeInfoController,
                decoration: InputDecoration(labelText: Texts.noticeInfo),
                maxLength: 300,
              ),
              SizedBox(height: 8.w),
              TextField(
                controller: schoolController,
                decoration: InputDecoration(labelText: Texts.school),
                maxLength: 150,
              ),
              SizedBox(height: 16.w),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final updateInfo = {
                      'nickName': nickNameController.text.trim(),
                      'personIntroduction':
                          personIntroductionController.text.trim(),
                      'noticeInfo': noticeInfoController.text.trim(),
                      'school': schoolController.text.trim(),
                    };
                    var res =
                        await userInfoController.updateUserInfo(updateInfo);
                    if (res['code'] == 200) {
                      Get.back(result: res['data']);
                    } else {
                      showErrorSnackbar(res['info']);
                    }
                  } catch (e) {
                    showErrorSnackbar(e.toString());
                  }
                },
                child: Text(Texts.update),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UploadImageCard extends StatefulWidget {
  // imagePath
  final String? imagePath;
  final Map<String, double?>? cropAspectRatios;
  const UploadImageCard({Key? key, this.imagePath, this.cropAspectRatios})
      : super(key: key);
  @override
  _UploadImageCardState createState() => _UploadImageCardState();
}

class _UploadImageCardState extends State<UploadImageCard> {
  final UserInfoController userInfoController = UserInfoController();
  final ImageDataController imageDataController = ImageDataController();
  final editorKey = GlobalKey<ExtendedImageEditorState>();
  @override
  final ImageEditorController _imageEditorController = ImageEditorController();
  Map<String, double?> _cropAspectRatios = {
    Texts.unLimit: null,
    Texts.originalRatio: 0.0,
    '4:3': 4 / 3,
    '16:9': 16 / 9,
    '1:1': 1.0,
    '3:4': 3 / 4,
    '9:16': 9 / 16,
  };
  @override
  void initState() {
    if (widget.cropAspectRatios != null) {
      _cropAspectRatios = widget.cropAspectRatios!;
    }
    _selectedAspectRatio = _cropAspectRatios.keys.first.obs;
    _imageEditorController
        .updateCropAspectRatio(_cropAspectRatios[_selectedAspectRatio.value]);
    super.initState();
    loadImage();
    _imageEditorControllerListener();
  }

  void loadImage() async {
    if (widget.imagePath != null) {
      await imageDataController.loadImageFromUrl(widget.imagePath!);
    }
  }

  void _imageEditorControllerListener() {}

  late var _selectedAspectRatio;
  FocusNode _focusNodeDropdownButton = FocusNode();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Constants.uploadImageCardWidth.w,
      height: Constants.uploadImageCardHeight.w,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                  height: 400.w,
                  width: 400.w,
                  child: Obx(() {
                    if (imageDataController.hasImage) {
                      return ExtendedImage.memory(
                        imageDataController.data,
                        fit: BoxFit.contain,
                        mode: ExtendedImageMode.editor,
                        extendedImageEditorKey: editorKey,
                        initEditorConfigHandler: (state) {
                          return EditorConfig(
                            maxScale: 8.0,
                            cropRectPadding: EdgeInsets.all(20.0),
                            hitTestSize: 20.0,
                            controller: _imageEditorController,
                            cropAspectRatio:
                                _cropAspectRatios[_selectedAspectRatio.value],
                          );
                        },
                      );
                    }
                    return Center(
                        child: Text(
                      Texts.noImageSelected,
                    ));
                  })),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        // 从本地选择文件
                        if (await Permission.manageExternalStorage
                                .request()
                                .isGranted ||
                            await Permission.storage.request().isGranted) {
                          // 弹出系统文件选择器选择文件
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            type: FileType.any,
                          );
                          print(result);
                          if (result != null && result.files.isNotEmpty) {
                            // 获取选择的文件路径
                            String? filePath = result.files.single.path;
                            if (filePath != null) {
                              // 读取文件内容
                              Uint8List fileBytes =
                                  await File(filePath).readAsBytes();
                              // 更新ImageDataController
                              imageDataController.loadImageFromMem(fileBytes);
                            }
                          }
                        }
                      } catch (e) {
                        showErrorSnackbar(e.toString());
                      }
                    },
                    icon: Icon(Icons.file_open),
                    label: Text(Texts.selectImage),
                  ),
                  Obx(() => DropdownButton<String>(
                        value: _selectedAspectRatio.value,
                        items: _cropAspectRatios.keys
                            .map((String key) => DropdownMenuItem<String>(
                                  value: key,
                                  child: Text(key),
                                ))
                            .toList(),
                        onChanged: (value) {
                          _selectedAspectRatio.value = value!;
                          _imageEditorController
                              .updateCropAspectRatio(_cropAspectRatios[value]);
                          _focusNodeDropdownButton.unfocus(); // 失去焦点
                        },
                        focusNode: _focusNodeDropdownButton,
                        dropdownColor:
                            Theme.of(context).colorScheme.surface, // 跟随主题
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 16.sp,
                        ),
                        iconEnabledColor: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12.r),
                        underline: SizedBox(), // 去掉下划线
                      )),
                  TextButton.icon(
                      onPressed: () async {
                        _imageEditorController.reset();
                        _selectedAspectRatio.value =
                            _cropAspectRatios.keys.first;
                      },
                      icon: Icon(Icons.refresh),
                      label: Text(Texts.reset)),
                ],
              ),
              SizedBox(height: 16.w),
              ElevatedButton(
                onPressed: () async {
                  try {
                    if (imageDataController.hasImage) {
                      final Rect cropRect =
                          await editorKey.currentState!.getCropRect()!;
                      var data = editorKey.currentState!.rawImageData;
                      if (data != null) {
                        // 裁剪图片
                        img.Image? image = img.decodeImage(data);
                        if (image != null) {
                          img.Image croppedImage = img.copyCrop(
                            image,
                            x: cropRect.left.toInt(),
                            y: cropRect.top.toInt(),
                            width: cropRect.width.w.toInt(),
                            height: cropRect.height.w.toInt(),
                          );
                          Uint8List croppedData =
                              Uint8List.fromList(img.encodePng(croppedImage));
                          // 上传图片
                          var res = await ApiService.fileUploadImage(
                            file: croppedData,
                          );
                          if (res['code'] == 200) {
                            Get.back(result: res['data']);
                          } else {
                            showErrorSnackbar(res['info']);
                          }
                        } else {
                          showErrorSnackbar(Texts.imageProcessingError);
                        }
                      } else {
                        showErrorSnackbar(Texts.noImageSelected);
                      }
                    }
                  } catch (e) {
                    showErrorSnackbar(e.toString());
                  }
                },
                child: Text(Texts.enter),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
