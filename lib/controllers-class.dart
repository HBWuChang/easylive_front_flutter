import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'Funcs.dart';

class ControllersInitController extends GetxController {
  var isLoginControllerInitialized = false.obs;
  var isAccountControllerInitialized = false.obs;
  var isPlatformPageSubmitControllerInitialized = false.obs;
  var isSysSettingGetSettingControllerInitialized = false.obs;
  var isCategoryLoadAllCategoryControllerInitialized = false.obs;
  void initNeedControllers() {
    initLoginController();
    initAccountController();
    // initPlatformPageSubmitController();
    initSysSettingGetSettingController();
    initCategoryLoadAllCategoryController();
  }

  void initLoginController() {
    if (!isLoginControllerInitialized.value) {
      Get.put(LoginController());
      isLoginControllerInitialized.value = true;
    }
  }

  void initAccountController() {
    if (!isAccountControllerInitialized.value) {
      Get.put(AccountController());
      isAccountControllerInitialized.value = true;
    }
  }

  void initPlatformPageSubmitController() {
    if (!isPlatformPageSubmitControllerInitialized.value) {
      Get.put(PlatformPageSubmitController());
      isPlatformPageSubmitControllerInitialized.value = true;
    }
  }

  void initSysSettingGetSettingController() {
    if (!isSysSettingGetSettingControllerInitialized.value) {
      Get.put(SysSettingGetSettingController());
      isSysSettingGetSettingControllerInitialized.value = true;
    }
  }

  void initCategoryLoadAllCategoryController() {
    if (!isCategoryLoadAllCategoryControllerInitialized.value) {
      Get.put(CategoryLoadAllCategoryController());
      isCategoryLoadAllCategoryControllerInitialized.value = true;
    }
  }
}

class LoginController extends GetxController {
  var email = ''.obs;
  var checkCode = ''.obs;
  var checkCodeKey = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromPrefs();
    ever(email, (_) => _saveToPrefs());
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    email.value = prefs.getString('email') ?? '';
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('email', email.value);
  }

  Future<void> freshCaptcha() async {
    var response = await ApiService.accountCheckCode();
    if (response['code'] == 200) {
      checkCode.value = response['data']['checkCode'];
      checkCodeKey.value = response['data']['checkCodeKey'];
    } else {
      Get.snackbar('获取验证码错误', response['msg'],
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}

class AccountController extends GetxController {
  var accountInfo = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadAccountInfo();
    ever(accountInfo, (_) => saveAccountInfoToLocal(_));
  }

// {
  //   "userId": "0636309642",
  //   "nickName": "神山识",
  //   "avatar": null,
  //   "expireAt": 1748612962391,
  //   "token": "7dab79f2-5ee2-4673-aabe-d657bbb8477b",
  //   "fansCount": null,
  //   "currentCoinCount": 2,
  //   "focusCount": null
  // }
  String? get userId => accountInfo['userId'];
  String? get nickName => accountInfo['nickName'];
  String? get avatar => accountInfo['avatar'];
  int? get expireAt => accountInfo['expireAt'];
  String? get token => accountInfo['token'];
  int? get fansCount => accountInfo['fansCount'];
  int? get currentCoinCount => accountInfo['currentCoinCount'];
  int? get focusCount => accountInfo['focusCount'];

  Future<void> _loadAccountInfo() async {
    final prefs = await SharedPreferences.getInstance();
    accountInfo.value = jsonDecode(prefs.getString('accountInfo') ?? '{}');
    if (accountInfo.isEmpty) {
      await autoLogin();
    } else {
      getUserCountInfo();
    }
  }

  Future<void> saveAccountInfoToLocal(Map<String, dynamic> info) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accountInfo', jsonEncode(info));
  }

  Future<void> saveAccountInfo(Map<String, dynamic> accountInfo) async {
    this.accountInfo.value = accountInfo;
  }

  Future<void> getUserCountInfo() async {
    var response = await ApiService.accountGetUserCountInfo();
    if (response['code'] == 200) {
      accountInfo['fansCount'] = response['data']['fansCount'];
      accountInfo['focusCount'] = response['data']['focusCount'];
      accountInfo['currentCoinCount'] = response['data']['currentCoinCount'];
      saveAccountInfoToLocal(accountInfo);
    } else {
      Get.snackbar('获取用户信息错误', response['info'],
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> autoLogin() async {
    var response = await ApiService.accountAutologin();
    if (response['code'] == 200) {
      accountInfo.value = response['data'];
      await saveAccountInfoToLocal(accountInfo);
      getUserCountInfo();
    } else {
      accountInfo.value = {};
    }
  }
}

class UserInfoController extends GetxController {
  var userInfo = <String, dynamic>{}.obs;

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
  String get userId => userInfo['userId'] ?? '';
  String get nickName => userInfo['nickName'] ?? '';
  set nickName(String value) {
    userInfo['nickName'] = value;
  }

  String get avatar => userInfo['avatar'] ?? '';
  set avatar(String value) {
    userInfo['avatar'] = value;
  }

  int get sex => userInfo['sex'] ?? 0;
  set sex(int value) {
    userInfo['sex'] = value;
  }

  String get personIntroduction => userInfo['personIntroduction'] ?? '';
  set personIntroduction(String value) {
    userInfo['personIntroduction'] = value;
  }

  String get noticeInfo => userInfo['noticeInfo'] ?? '';
  set noticeInfo(String value) {
    userInfo['noticeInfo'] = value;
  }

  String? get grade => userInfo['grade'] ?? '';
  String get birthday => userInfo['birthday'] ?? '';
  set birthday(String value) {
    userInfo['birthday'] = value;
  }

  String get school => userInfo['school'] ?? '';
  set school(String value) {
    userInfo['school'] = value;
  }

  int? get fansCount => userInfo['fansCount'] ?? 0;
  int? get focusCount => userInfo['focusCount'] ?? 0;
  int? get likeCount => userInfo['likeCount'] ?? 0;
  int? get playCount => userInfo['playCount'] ?? 0;
  bool get haveFocus => userInfo['haveFocus'] ?? false;
  String? get theme => userInfo['theme'] ?? '';

  Future<Map<String, dynamic>> getUserInfo(String userId) async {
    try {
      var res = await ApiService.uhomeGetUserInfo(userId);
      if (res['code'] == 200) {
        userInfo.value = res['data'];
        return userInfo;
      } else {
        throw Exception(res['info']);
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
      return {};
    }
  }

  Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> updateInfo) async {
    try {
      updateInfo.forEach((key, value) {
        userInfo[key] = value;
      });
      var res = await ApiService.uhomeUpdateUserInfo(
          nickName: nickName,
          avatar: avatar,
          sex: sex,
          birthday: birthday,
          school: school,
          noticeInfo: noticeInfo,
          personIntroduction: personIntroduction);
      return res;
    } catch (e) {
      showErrorSnackbar(e.toString());
      return {};
    }
  }
}

class ImageDataController extends GetxController {
  var imageData = <Uint8List>[].obs;
  bool get hasImage => imageData.isNotEmpty;
  Uint8List get data => imageData.isNotEmpty ? imageData[0] : Uint8List(0);
  Future<void> loadImageFromUrl(String imageUrl) async {
    try {
      var res = await ApiService.fileGetResource(imageUrl);
      imageData.value = [res];
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }

  Future<void> loadImageFromMem(Uint8List data) async {
    try {
      imageData.value = [data];
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }
}

class VideoInfoFilePost {
  // "videoInfoFilePostList": [
//       {
//         "fileId": "zGNppAnSd5wynW0f01nS",
//         "uploadId": "DkvfxVGiRv61q28y",
//         "userId": "0636309642",
//         "videoId": "KyEpKukJra",
//         "fileIndex": 1,
//         "fileName": "文件名2",
//         "fileSize": null,
//         "filePath": "video/20250521/0636309642DkvfxVGiRv61q28y",
//         "updateType": 0,
//         "transferResult": 1,
//         "duration": 44
//       }
//     ]
//   }
  String? fileId;
  String? uploadId;
  String? userId;
  String? videoId;
  int? fileIndex;
  String? fileName;
  int? fileSize;
  String? filePath;
  int? updateType;
  int? transferResult;
  int? duration;
  String? get getFileId => fileId;
  set setFileId(String? value) => fileId = value;

  String? get getUploadId => uploadId;
  set setUploadId(String? value) => uploadId = value;

  String? get getUserId => userId;
  set setUserId(String? value) => userId = value;

  String? get getVideoId => videoId;
  set setVideoId(String? value) => videoId = value;

  int? get getFileIndex => fileIndex;
  set setFileIndex(int? value) => fileIndex = value;

  String? get getFileName => fileName;
  set setFileName(String? value) => fileName = value;

  int? get getFileSize => fileSize;
  set setFileSize(int? value) => fileSize = value;

  String? get getFilePath => filePath;
  set setFilePath(String? value) => filePath = value;

  int? get getUpdateType => updateType;
  set setUpdateType(int? value) => updateType = value;

  int? get getTransferResult => transferResult;
  set setTransferResult(int? value) => transferResult = value;

  int? get getDuration => duration;
  set setDuration(int? value) => duration = value;

  VideoInfoFilePost({
    this.fileId,
    this.uploadId,
    this.userId,
    this.videoId,
    this.fileIndex,
    this.fileName,
    this.fileSize,
    this.filePath,
    this.updateType,
    this.transferResult,
    this.duration,
  });
  VideoInfoFilePost.fromJson(Map<String, dynamic> json) {
    fileId = json['fileId'];
    uploadId = json['uploadId'];
    userId = json['userId'];
    videoId = json['videoId'];
    fileIndex = json['fileIndex'];
    fileName = json['fileName'];
    fileSize = json['fileSize'];
    filePath = json['filePath'];
    updateType = json['updateType'];
    transferResult = json['transferResult'];
    duration = json['duration'];
  }
  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'uploadId': uploadId,
      'userId': userId,
      'videoId': videoId,
      'fileIndex': fileIndex,
      'fileName': fileName,
      'fileSize': fileSize,
      'filePath': filePath,
      'updateType': updateType,
      'transferResult': transferResult,
      'duration': duration,
    };
  }
}

class VideoInfoFilePostController extends GetxController {
  var process = 0.0.obs;
  var isUploading = true.obs;
  var uploadInfo = ''.obs;
  Uint8List? videoData;
  int chunkIndex = 0;
  int chunkSize = 0;
  int chunks = 0;
  int totalsize = 0;
  bool stop = false;
  late TextEditingController videoNameController;
  TextEditingController get getVideoNameController => videoNameController;
  Future<void> cancelUpload() async {
    stop = true;
    await ApiService.fileDelUploadVideo(uploadId);
  }

  String uploadid = '';
  String filename = '';
  String get uploadId => uploadid;
  set uploadId(String value) {
    uploadid = value;
  }

  String get fileName => filename;
  set fileName(String value) {
    filename = value;
  }

  void creatAFinishedVideoInfoFilePost(String fileName) {
    isUploading.value = false;
    uploadInfo.value = '上传完成';
    chunkIndex = 0;
    process.value = 100.0;
    filename = fileName;
  }

  Future<String> preUploadVideo(Uint8List videoData, String fileName) async {
    this.videoData = videoData;
    this.fileName = fileName;
    totalsize = videoData.lengthInBytes;
    chunkSize = (0.5 * 1024 * 1024).toInt(); // 0.5MB per chunk
    chunks = (totalsize / chunkSize).ceil();
    var res =
        await ApiService.filePreUploadVideo(fileName: fileName, chunks: chunks);
    if (res['code'] == 200) {
      uploadId = res['data'];
      uploadVideo();
      videoNameController = TextEditingController(text: fileName);
      return uploadId;
    } else {
      throw Exception('预上传视频失败: ${res['info']}');
    }
  }

  Future<void> uploadVideo() async {
    if (videoData == null || uploadId.isEmpty) {
      throw Exception('视频数据或上传ID未设置');
    }
    isUploading.value = true;
    try {
      while (chunkIndex < chunks && !stop) {
        int start = chunkIndex * chunkSize;
        int end = (start + chunkSize).clamp(0, totalsize);
        Uint8List chunkData = videoData!.sublist(start, end);
        var res = await ApiService.fileUploadVideo(
          chunkFile: chunkData,
          chunkIndex: chunkIndex,
          uploadId: uploadId,
        );
        if (res['code'] == 200) {
          process.value = ((chunkIndex + 1) / chunks) * 100;
          uploadInfo.value = '上传进度: ${process.value.toStringAsFixed(2)}%';
          chunkIndex++;
        } else {
          throw Exception('上传视频分片失败: ${res['info']}');
        }
      }
      isUploading.value = false;
      uploadInfo.value = '上传完成';
    } catch (e) {
      isUploading.value = false;
      throw e;
    }
  }

  void updateFileName() {
    if (videoNameController.text.isNotEmpty) {
      filename = videoNameController.text;
    } else {
      throw Exception('文件名不能为空');
    }
  }
}

class PlatformPageSubmitController extends GetxController {
  var uploadFileList = <VideoInfoFilePost>[].obs;
  var videoId = ''.obs;
  var videoCover = ''.obs;
  var videoName = ''.obs;
  var pCategoryId = 0.obs;
  var categoryId = 0.obs;
  var postType = 0.obs;
  var tags = [].obs;
  var introduction = ''.obs;
  var origin_info = ''.obs;
  // var interaction = ''.obs;
  var interaction = [].obs;
  var isUploading = false.obs;
  var videoPcountLimit = 0.obs;
  var prePage = false.obs;
  var disableComment = false.obs;
  var disableDanmaku = false.obs;

  final tagsFocusNode = FocusNode();
  late TextEditingController videoNameController;
  late TextEditingController tagsController;
  late TextEditingController introductionController;
  late TextEditingController origin_infoController;
  PlatformPageSubmitController() {
    videoNameController = TextEditingController();
    tagsController = TextEditingController();
    introductionController = TextEditingController();
    origin_infoController = TextEditingController();
    pCategoryId.value =
        Get.find<CategoryLoadAllCategoryController>().categories.isNotEmpty
            ? Get.find<CategoryLoadAllCategoryController>().categories[0]
                ['categoryId']
            : 0;
  }
  void removeTag(String tag) {
    tags.remove(tag);
  }

  void addTag(String tag) {
    if (tag.isNotEmpty && !tags.contains(tag)) {
      tags.add(tag);
    }
  }

  void addUploadFile(VideoInfoFilePost file) {
    uploadFileList.add(file);
  }

  void removeUploadFile(VideoInfoFilePost file) {
    uploadFileList.remove(file);
  }

  void updateUploadFileName(VideoInfoFilePost file, String newName) {
    int index = uploadFileList.indexOf(file);
    if (index != -1) {
      uploadFileList[index].fileName = newName;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getVideoPcountLimit();
  }

  void getVideoPcountLimit() async {
    var settingController = Get.find<SysSettingGetSettingController>();
    await settingController.getSetting();
    videoPcountLimit.value = settingController.videoPcount.value;
  }

  Future<void> submitVideoInfo() async {
    videoName.value = videoNameController.text.trim();
    introduction.value = introductionController.text.trim();
    origin_info.value = origin_infoController.text.trim();
    if (videoName.value.isEmpty) {
      throw Exception('视频名称不能为空');
    }
    if (uploadFileList.isEmpty) {
      throw Exception('请上传视频文件');
    }
    if (pCategoryId.value == 0) {
      throw Exception('请选择一级分类');
    }
    if (uploadFileList.length > videoPcountLimit.value) {
      throw Exception('上传的视频数量超过限制: ${videoPcountLimit.value}');
    }
    if (videoCover.value.isEmpty) {
      throw Exception('视频封面不能为空');
    }
    interaction.value = [];
    if (disableComment.value) {
      interaction.add('0'); // 禁用评论
    }
    if (disableDanmaku.value) {
      interaction.add('1'); // 禁用弹幕
    }
    var res = await ApiService.ucenterPostVideo(
        videoId: videoId.value,
        videoCover: videoCover.value,
        videoName: videoName.value,
        pCategoryId: pCategoryId.value,
        categoryId: categoryId.value == 0 ? null : categoryId.value,
        postType: postType.value,
        tags: tags.join(','),
        introduction: introduction.value,
        interaction: interaction.join(','),
        origin_info: origin_info.value,
        uploadFileList: uploadFileList);
    if (res['code'] == 200) {
    } else {
      throw Exception('提交视频信息失败: ${res['info']}');
    }
  }
}

class SysSettingGetSettingController extends GetxController {
  var registerCoinCount = 0.obs;
  var postVideoCoinCount = 0.obs;
  var videoSize = 0.obs;
  var videoPcount = 0.obs;
  var videoCount = 0.obs;
  var commentCount = 0.obs;
  var danmuCount = 0.obs;
  @override
  void onInit() {
    super.onInit();
    getSetting();
  }

  Future<void> getSetting() async {
    try {
      var res = await ApiService.sysSettingGetSetting();
      if (res['code'] == 200) {
        registerCoinCount.value = res['data']['registerCoinCount'] ?? 0;
        postVideoCoinCount.value = res['data']['postVideoCoinCount'] ?? 0;
        videoSize.value = res['data']['videoSize'] ?? 0;
        videoPcount.value = res['data']['videoPcount'] ?? 0;
        videoCount.value = res['data']['videoCount'] ?? 0;
        commentCount.value = res['data']['commentCount'] ?? 0;
        danmuCount.value = res['data']['danmuCount'] ?? 0;
      } else {
        throw Exception('获取系统设置失败: ${res['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }
}

class CategoryLoadAllCategoryController extends GetxController {
//   {
//   "status": "success",
//   "code": 200,
//   "info": "请求成功",
//   "data": [
//     {
//       "categoryId": 1,
//       "categoryCode": "p1",
//       "categoryName": "分类5",
//       "pCategoryId": 0,
//       "icon": "cover/202505\\\\OVCjRrfxWsBSwwmx0XMiSDr6tHcwcx.webp",
//       "background": "213213421",
//       "sort": 1,
//       "children": []
//     },
//     {
//       "categoryId": 37,
//       "categoryCode": "p4",
//       "categoryName": "分类3",
//       "pCategoryId": 0,
//       "icon": "2",
//       "background": "213213421",
//       "sort": 2,
//       "children": [
//         {
//           "categoryId": 38,
//           "categoryCode": "sss",
//           "categoryName": "分类3-1",
//           "pCategoryId": 37,
//           "icon": "cover/202505\\\\OVCjRrfxWsBSwwmx0XMiSDr6tHcwcx.webp",
//           "background": "213213421",
//           "sort": 1,
//           "children": []
//         }
//       ]
//     }
//   ]
// }

  var categories = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAllCategories();
  }

  Future<void> loadAllCategories() async {
    try {
      var res = await ApiService.categoryLoadAllCategory();
      if (res['code'] == 200) {
        categories.value = List<Map<String, dynamic>>.from(res['data']);
      } else {
        throw Exception('加载分类失败: ${res['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }
}
