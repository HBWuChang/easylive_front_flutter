import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:easylive/controllers/LocalSettingsController.dart';
import 'package:easylive/controllers/controllers-class2.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/settings.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../api_service.dart';
import '../Funcs.dart';
import 'package:media_kit/media_kit.dart';
import '../pages/MainPage/MainPage.dart';
import 'MainPageController.dart';
import 'VideoCommentController.dart';
import 'dart:async';

class ControllersInitController extends GetxController {
  var isLoginControllerInitialized = false.obs;
  var isAccountControllerInitialized = false.obs;
  var isPlatformPageSubmitControllerInitialized = false.obs;
  var isSysSettingGetSettingControllerInitialized = false.obs;
  var isCategoryLoadAllCategoryControllerInitialized = false.obs;
  var isAppBarControllerInitialized = false.obs;
  var isWindowSizeControllerInitialized = false.obs;
  var isLocalSettingsControllerInitialized = false.obs;
  void initNeedControllers() {
    initLoginController();
    initAccountController();
    // initPlatformPageSubmitController();
    initSysSettingGetSettingController();
    initCategoryLoadAllCategoryController();
    initAppBarController();
    initWindowSizeController();
    initVideoLoadRecommendVideoController();
    initLocalSettingsControllerController();
    initVideoNowWatchingCountController();
    if (!Get.isRegistered<CategoryViewStateController>()) {
      Get.put(CategoryViewStateController(), permanent: true);
    }
    if (!Get.isRegistered<WindowSizeController>()) {
      Get.put(WindowSizeController(), permanent: true);
    }
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

  void initAppBarController() {
    if (!isAppBarControllerInitialized.value) {
      Get.put(AppBarController());
      isAppBarControllerInitialized.value = true;
    }
  }

  void initWindowSizeController() {
    if (!isWindowSizeControllerInitialized.value) {
      Get.put(WindowSizeController());
      isWindowSizeControllerInitialized.value = true;
    }
  }

  void initVideoLoadRecommendVideoController() {
    if (!Get.isRegistered<VideoLoadRecommendVideoController>()) {
      Get.put(VideoLoadRecommendVideoController());
    }
  }

  void initLocalSettingsControllerController() {
    if (!isLocalSettingsControllerInitialized.value) {
      Get.put(LocalSettingsController());
      isLocalSettingsControllerInitialized.value = true;
    }
  }

  void initVideoNowWatchingCountController() {
    if (!Get.isRegistered<VideoNowWatchingCountController>()) {
      Get.put(VideoNowWatchingCountController());
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
      autoLogin();
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
  late String _userId;
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
  UserInfoController({String? userId}) {
    if (userId != null && userId.isNotEmpty) {
      _userId = userId;
      getUserInfo(null);
    }
  }
  String get userId => _userId;
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

  Future<Map<String, dynamic>> getUserInfo(String? userId) async {
    if (userId != null && userId.isNotEmpty) {
      _userId = userId;
    } else if (_userId.isEmpty) {
      _userId = Get.find<AccountController>().userId ?? '';
    }
    try {
      var res = await ApiService.uhomeGetUserInfo(_userId);
      if (res['code'] == 200) {
        userInfo.value = res['data'];
        if (userInfo['nickName'] != null && userInfo['nickName'].isNotEmpty) {
          Get.find<AppBarController>().updateTitleByRouteName(
              name: '${Routes.uhome}/$_userId', title: userInfo['nickName']);
        }
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
  late PageController pageController;
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

  Future<void> setVideoDataFromVideoId(String videoId) async {
    final videoInfo = await ApiService.ucenterGetVideoByVideoId(videoId);
    if (videoInfo['code'] == 200) {
      var data = videoInfo['data']['videoInfo'];
      this.videoId.value = data['videoId'] ?? '';
      videoCover.value = data['videoCover'] ?? '';
      videoNameController.text = data['videoName'] ?? '';
      tagsController.text = '';
      introductionController.text = data['introduction'] ?? '';
      origin_infoController.text = data['originInfo'] ?? '';
      pCategoryId.value = data['pCategoryId'] ?? 0;
      categoryId.value = data['categoryId'] ?? 0;
      postType.value = data['postType'] ?? 0;
      disableComment.value = data['interaction']?.contains('0') ?? false;
      disableDanmaku.value = data['interaction']?.contains('1') ?? false;
      tags.value = data['tags']?.split(',') ?? [];
      for (var uploadFile in uploadFileList) {
        var uploadId = uploadFile.uploadId;
        Get.delete<VideoInfoFilePostController>(tag: uploadId);
      }
      uploadFileList.clear();
      if (videoInfo['data']['videoInfoFilePostList'] != null) {
        for (var file in videoInfo['data']['videoInfoFilePostList']) {
          var videoInfoFilePostController = VideoInfoFilePostController();
          videoInfoFilePostController.uploadId = file['uploadId'];
          videoInfoFilePostController
              .creatAFinishedVideoInfoFilePost(file['fileName'] ?? '');
          Get.put(videoInfoFilePostController, tag: file['uploadId']);
          uploadFileList.add(VideoInfoFilePost.fromJson(file));
        }
      }
    } else {
      throw Exception('获取视频信息失败: ${videoInfo['info']}');
    }
  }

  @override
  void onClose() {
    for (var file in uploadFileList) {
      var uploadId = file.uploadId;
      Get.delete<VideoInfoFilePostController>(tag: uploadId);
    }
    super.onClose();
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

  // @override
  // void onInit() {
  //   super.onInit();
  //   loadAllCategories();
  // }

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

class AppBarController extends GetxController {
  var opacity = 0.0.obs;
  var appBarOpaque = false.obs;
  var showFloatingCate = false.obs;
  ScrollController scrollController = ScrollController();
  double imgHeight = 180.0;
  var extendBodyBehindAppBar = true.obs;
  var top_routeWithName = List.empty(growable: true).obs;
  List<String> logRoutes = List.empty(growable: true);
  ListenPopMiddleware listenPopMiddleware = ListenPopMiddleware();
  int disposedByClean = 0;
  var selectedRouteName = Routes.mainPage.obs;
  ScrollController tabScrollController = ScrollController();
  var tabWidth = 180.0.obs;
  int needRemove = 0;
  List<Player> playerList = [];
  @override
  void onInit() {
    super.onInit();
    extendBodyBehindAppBar.firstRebuild = false;
  }

  void updateTitleByRouteName({required String name, required String title}) {
    for (var r in top_routeWithName) {
      if (r.name == name) {
        r.title.value = title;
      }
    }
  }

  Future<void> stopAllVideo() async {
    for (int index = playerList.length - 1; index >= 0; index--) {
      bool flag = false;
      try {
        await playerList[index].pause();
      } catch (e) {
        flag = true;
      }
      if (flag) {
        playerList.removeAt(index);
      }
    }
  }

  void addAndCleanReapeatRoute(Route route, String name, {String? title}) {
    if (needRemove > 0) {
      needRemove--;
      removeRouteByName(selectedRouteName.value);
    }
    if (name.startsWith(Routes.videoPlayPage)) {
      stopAllVideo();
    }
    logRoutes.remove(name);
    logRoutes.add(name);
    int index = top_routeWithName.indexWhere((r) => r.name == name);
    String? tTitle;
    if (top_routeWithName.isNotEmpty) {
      // 清除重复的路由
      top_routeWithName.removeWhere((r) {
        if (r.route.settings.name == route.settings.name) {
          disposedByClean++;
          tTitle = r.title.value;
          Get.removeRoute(r.route, id: Routes.mainGetId);
          return true;
        }
        return false;
      });
    }
    selectedRouteName.value = name;
    // top_routeWithName.add(RouteWithName(route, name, title: title));
    if (index == -1) {
      // 如果没有重复的路由，则添加新的路由
      top_routeWithName.add(RouteWithName(route, name, title: title));
    } else {
      // 如果有重复的路由，则更新现有路由的title
      top_routeWithName.insert(
          index, RouteWithName(route, name, title: title ?? tTitle));
    }
  }

  void removeRouteByName(String name) {
    if (top_routeWithName.length < 2) {
      // 如果只剩下一个路由，则不允许删除
      return;
    }
    top_routeWithName.removeWhere((r) {
      if (r.name == name) {
        disposedByClean++;
        Get.removeRoute(r.route, id: Routes.mainGetId);
        return true;
      }
      return false;
    });
  }

  void onPageDispose(String name) {
    print("onPageDispose: ${name}");
    if (disposedByClean > 0) {
      disposedByClean--;
    } else {
      top_routeWithName.removeLast();
    }

    logRoutes.removeWhere((r) {
      bool flag = true;
      for (var route in top_routeWithName) {
        if (route.name == r) {
          flag = false;
          break;
        }
      }
      return flag;
    });

    if (logRoutes.indexOf(selectedRouteName.value) == -1) {
      selectedRouteName.value = top_routeWithName.isNotEmpty
          ? top_routeWithName.last.name
          : Routes.mainPage;
    }
  }
}

class ListenPopMiddleware extends GetMiddleware {
  @override
  void onPageDispose() {
    // 当页面被销毁时，调用AppBarController的onPageDispose方法
    Get.find<AppBarController>()
        .onPageDispose(Get.currentRoute); // 获取当前路由名称并传递给onPageDispose
  }
}

class RouteWithName {
  final Route route;
  final String name;
  RxString title;
  RouteWithName(this.route, this.name, {String? title})
      : title = (title ?? '').obs;
}

// 新增：窗口宽度响应式控制器
class WindowSizeController extends GetxController {
  var width = 0.0.obs;
  void updateWidth(double w) {
    if (width.value != w) width.value = w;
  }
}

class VideoLoadRecommendVideoController extends GetxController {
  var recommendVideos = <VideoInfo>[].obs;
  var mainPageVideos = <VideoInfo>[].obs;
  int mainPageVideosPageNo = 1;
  int mainPageVideosPageTotal = 1;
  var isLoading = false.obs;
  var loadingMore = false.obs;
  @override
  void onInit() {
    super.onInit();
    loadRecommendVideos();
    loadMainPageVideo();
  }

  Future<void> loadRecommendVideos() async {
    isLoading.value = true;
    try {
      var res = await ApiService.videoLoadRecommendVideo();
      if (res['code'] == 200) {
        recommendVideos.value = (res['data'] as List)
            .map((item) => VideoInfo(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('加载推荐视频失败: ${res['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMainPageVideo() async {
    try {
      var res = await ApiService.videoLoadVideo();
      if (showResSnackbar(res, notShowIfSuccess: true)) {
        mainPageVideosPageNo = res['data']['pageNo'] ?? 1;
        mainPageVideosPageTotal = res['data']['pageTotal'] ?? 1;
        mainPageVideos.value = (res['data']['list'] as List)
            .map((item) => VideoInfo(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('加载主页视频失败: ${res['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }

  Future<bool> loadMoreMainPageVideo() async {
    if (loadingMore.value || mainPageVideosPageNo >= mainPageVideosPageTotal) {
      return false; // 如果正在加载或已经是最后一页，直接返回
    }
    loadingMore.value = true;
    try {
      var res = await ApiService.videoLoadVideo(pageNo: ++mainPageVideosPageNo);
      if (showResSnackbar(res, notShowIfSuccess: true)) {
        var newVideos = (res['data']['list'] as List)
            .map((item) => VideoInfo(item as Map<String, dynamic>))
            .toList();
        mainPageVideos.addAll(newVideos);
        return true; // 成功加载更多视频
      } else {
        throw Exception('加载更多主页视频失败: ${res['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
      return false; // 加载失败
    } finally {
      loadingMore.value = false;
    }
  }
}

class VideoInfo {
// public class VideoInfo implements Serializable {

// 	/**
// 	 * 视频ID
// 	 */
// 	private String videoId;

// 	/**
// 	 * 视频封面
// 	 */
// 	private String videoCover;

// 	/**
// 	 * 视频名称
// 	 */
// 	private String videoName;

// 	/**
// 	 * 用户ID
// 	 */
// 	private String userId;

// 	/**
// 	 * 创建时间
// 	 */
// 	@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
// 	@DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
// 	private Date createTime;

// 	/**
// 	 * 最后更新时间
// 	 */
// 	@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
// 	@DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
// 	private Date lastUpdateTime;

// 	/**
// 	 * 父级分类ID
// 	 */
// 	private Integer pCategoryId;

// 	/**
// 	 * 分类ID
// 	 */
// 	private Integer categoryId;

// 	/**
// 	 * 0:自制作 1:转载
// 	 */
// 	private Integer postType;

// 	/**
// 	 * 原资源说明
// 	 */
// 	private String originInfo;

// 	/**
// 	 * 标签
// 	 */
// 	private String tags;

// 	/**
// 	 * 简介
// 	 */
// 	private String introduction;

// 	/**
// 	 * 互动设置
// 	 */
// 	private String interaction;

// 	/**
// 	 * 持续时间（秒）
// 	 */
// 	private Integer duration;

// 	/**
// 	 * 播放数量
// 	 */
// 	private Integer playCount;

// 	/**
// 	 * 点赞数量
// 	 */
// 	private Integer likeCount;

// 	/**
// 	 * 弹幕数量
// 	 */
// 	private Integer danmuCount;

// 	/**
// 	 * 评论数量
// 	 */
// 	private Integer commentCount;

// 	/**
// 	 * 投币数量
// 	 */
// 	private Integer coinCount;

// 	/**
// 	 * 收藏数量
// 	 */
// 	private Integer collectCount;

// 	/**
// 	 * 是否推荐0：未推荐1：已推荐
// 	 */
// 	private Integer recommendType;

// 	/**
// 	 * 最后播放时间
// 	 */
// 	@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
// 	@DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
// 	private Date lastPlayTime;

// 	private String nickName;
// 	private String avatar;
  String? videoId;
  String? videoCover;
  String? videoName;
  String? userId;
  DateTime? createTime;
  DateTime? lastUpdateTime;
  int? pCategoryId;
  int? categoryId;
  int? postType;
  String? originInfo;
  String? tags;
  String? introduction;
  String? interaction;
  int? duration;
  int? playCount;
  int? likeCount;
  int? danmuCount;
  int? commentCount;
  int? coinCount;
  int? collectCount;
  int? recommendType;
  DateTime? lastPlayTime;
  String? nickName;
  String? avatar;
  VideoInfo(Map<String, dynamic> json) {
    videoId = json['videoId'];
    videoCover = json['videoCover'];
    videoName = json['videoName'];
    userId = json['userId'];
    createTime = DateTime.tryParse(json['createTime'] ?? '');
    lastUpdateTime = DateTime.tryParse(json['lastUpdateTime'] ?? '');
    pCategoryId = json['pCategoryId'];
    categoryId = json['categoryId'];
    postType = json['postType'];
    originInfo = json['originInfo'];
    tags = json['tags'];
    introduction = json['introduction'];
    interaction = json['interaction'];
    duration = json['duration'];
    playCount = json['playCount'];
    likeCount = json['likeCount'];
    danmuCount = json['danmuCount'];
    commentCount = json['commentCount'];
    coinCount = json['coinCount'];
    collectCount = json['collectCount'];
    recommendType = json['recommendType'];
    lastPlayTime = DateTime.tryParse(json['lastPlayTime'] ?? '');
    nickName = json['nickName'];
    avatar = json['avatar'];
  }
}

class VideoGetVideoInfoController extends GetxController {
  var videoInfo = VideoInfo({}).obs;
  var isLoading = true.obs;
  var userActionList = <UserAction>[].obs;
  bool get hasLike => userActionList.any((action) =>
      (action.actionType == UserActionEnum.VIDEO_LIKE.type &&
          action.userId == Get.find<AccountController>().userId));
  bool get hasCollect => userActionList.any((action) =>
      action.actionType == UserActionEnum.VIDEO_COLLECT.type &&
      action.userId == Get.find<AccountController>().userId);
  bool get hasCoin => userActionList.any((action) =>
      action.actionType == UserActionEnum.VIDEO_COIN.type &&
      action.userId == Get.find<AccountController>().userId);
  Future<void> loadVideoInfo(String videoId, {String? routeName}) async {
    try {
      var res = await ApiService.videoGetVideoInfo(videoId);
      if (res['code'] == 200) {
        videoInfo.value = VideoInfo(res['data']['videoInfo']);
        userActionList.value = (res['data']['userActionList'] as List)
            .map((item) => UserAction(item as Map<String, dynamic>))
            .toList();
        if (routeName != null) {
          Get.find<AppBarController>().updateTitleByRouteName(
              name: routeName, title: videoInfo.value.videoName ?? '');
        }
        VideoGetVideoRecommendController videoGetVideoRecommendController;
        if (Get.isRegistered<VideoGetVideoRecommendController>(
            tag: '${videoId}VideoGetVideoRecommendController')) {
          videoGetVideoRecommendController =
              Get.find<VideoGetVideoRecommendController>(
                  tag: '${videoId}VideoGetVideoRecommendController');
        } else {
          videoGetVideoRecommendController = Get.put(
              VideoGetVideoRecommendController(),
              tag: '${videoId}VideoGetVideoRecommendController');
        }
        videoGetVideoRecommendController.loadVideoRecommend(
            (videoInfo.value.videoName ?? '') +
                ' ' +
                (videoInfo.value.tags ?? ''),
            videoInfo.value.videoId ?? '');
      } else {
        throw Exception('加载视频信息失败: ${res['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}

class VideoNowWatchingCountController extends GetxController {
  Map<String, int> nowWatchingCountMap = <String, int>{}.obs;
}

class VideoLoadVideoPListController extends GetxController {
  var videoPList = <VideoInfoFile>[].obs;
  var isLoading = false.obs;
  var selectFileId = ''.obs;
  Timer? _reportTimer;
  String videoId = '';
  int get selectFileIndex {
    return videoPList.indexWhere((file) => file.fileId == selectFileId.value);
  }

  bool get multi => videoPList.length > 1;
  VideoLoadVideoPListController(String videoId) {
    this.videoId = videoId;
    loadVideoPList(videoId);
    ever(selectFileId, (id) {
      Get.find<LocalSettingsController>()
          .setSetting('videoPListSelectFileId${this.videoId}', id);
      _reportTimer?.cancel();
      if (id != null && id.toString().isNotEmpty) {
        _reportTimer = Timer.periodic(Duration(seconds: 5), (_) {
          reportPlayInfo();
        });
      }
    });
  }

  @override
  void onClose() {
    _reportTimer?.cancel();
    super.onClose();
  }

  void reportPlayInfo() async {
    String deviceId = Get.find<LocalSettingsController>().deviceId;
    try {
      var res = await ApiService.videoReportVideoPlayOnline(
        fileId: selectFileId.value,
        deviceId: deviceId,
      );
      if (res['code'] == 200) {
        Get.find<VideoNowWatchingCountController>()
            .nowWatchingCountMap[selectFileId.value] = res['data'] ?? 1;
      }
    } catch (e) {
      showErrorSnackbar('上报播放信息失败: ${e.toString()}');
    }
  }

  Future<void> loadVideoPList(String videoId) async {
    isLoading.value = true;
    try {
      var res = await ApiService.videoLoadVideoPList(videoId);
      if (res['code'] == 200) {
        videoPList.value = (res['data'] as List)
            .map((item) => VideoInfoFile(item as Map<String, dynamic>))
            .toList();
        // selectFileId.value =
        //     videoPList.isNotEmpty ? videoPList[0].fileId ?? '' : '';
        selectFileId.value =
            Get.find<LocalSettingsController>().getLastPlayFileId(videoId);
        if ((selectFileId.value.isEmpty && videoPList.isNotEmpty) ||
            !videoPList.any((file) => file.fileId == selectFileId.value)) {
          selectFileId.value = videoPList[0].fileId ?? '';
        }
        if (videoPList.isEmpty) {
          throw Exception('视频分片列表为空');
        }
      } else {
        throw Exception('加载视频列表失败: ${res['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
      update();
    }
  }
}

class VideoInfoFile {
  String? fileId;
  String? userId;
  String? videoId;
  String? fileName;
  int? fileIndex;
  int? fileSize;
  String? filePath;
  int? duration;
  VideoInfoFile(Map<String, dynamic> json) {
    fileId = json['fileId'];
    userId = json['userId'];
    videoId = json['videoId'];
    fileName = json['fileName'];
    fileIndex = json['fileIndex'];
    fileSize = json['fileSize'];
    filePath = json['filePath'];
    duration = json['duration'];
  }
}

class UhomeGetUserInfoController extends GetxController {
  var userInfo = UserInfo({}).obs;

  Future<void> getUserInfo(String userId) async {
    try {
      var res = await ApiService.uhomeGetUserInfo(userId);
      if (res['code'] == 200) {
        userInfo.value = UserInfo(res['data']);
      } else {
        throw Exception(res['info']);
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }
}

class VideoGetVideoRecommendController extends GetxController {
  var videoRecommendList = <VideoInfo>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadVideoRecommend(String keyword, String videoId) async {
    isLoading.value = true;
    try {
      var res = await ApiService.videoGetVideoRecommend(
          keyword: keyword, videoId: videoId);
      if (res['code'] == 200) {
        videoRecommendList.value = (res['data'] as List)
            .map((item) => VideoInfo(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('加载推荐视频失败: ${res['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
