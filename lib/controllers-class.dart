import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:easylive/controllers-class2.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/settings.dart';
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
  ScrollController scrollController = ScrollController();
  double imgHeight = 180.0;
  var extendBodyBehindAppBar = true.obs;
  var top_routeWithName = List.empty(growable: true).obs;
  ListenPopMiddleware listenPopMiddleware = ListenPopMiddleware();
  int disposedByClean = 0;
  String? selectedRouteName = '/main';
  ScrollController tabScrollController = ScrollController();
  var tabWidth = 180.0.obs;
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

  void addAndCleanReapeatRoute(Route route, String name, {String? title}) {
    if (top_routeWithName.isNotEmpty) {
      // 清除重复的路由
      top_routeWithName.removeWhere((r) {
        if (r.route.settings.name == route.settings.name) {
          disposedByClean++;
          Get.removeRoute(r.route, id: Routes.mainGetId);
          return true;
        }
        return false;
      });
    }
    top_routeWithName.add(RouteWithName(route, name, title: title));
  }

  void onPageDispose() {
    print("onPageDispose: ${Get.currentRoute}");
    if (disposedByClean > 0) {
      disposedByClean--;
    } else {
      top_routeWithName.removeLast();
    }
    
  }
}

class ListenPopMiddleware extends GetMiddleware {
  @override
  void onPageDispose() {
    // 当页面被销毁时，调用AppBarController的onPageDispose方法
    Get.find<AppBarController>().onPageDispose();
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
  var isLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
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

class VideoLoadVideoPListController extends GetxController {
  var videoPList = <VideoInfoFile>[].obs;
  var isLoading = false.obs;
  var selectFileId = ''.obs;
  int get selectFileIndex {
    return videoPList.indexWhere((file) => file.fileId == selectFileId.value);
  }

  bool get multi => videoPList.length > 1;
  VideoLoadVideoPListController(String videoId) {
    loadVideoPList(videoId);
  }

  Future<void> loadVideoPList(String videoId) async {
    isLoading.value = true;
    try {
      var res = await ApiService.videoLoadVideoPList(videoId);
      if (res['code'] == 200) {
        videoPList.value = (res['data'] as List)
            .map((item) => VideoInfoFile(item as Map<String, dynamic>))
            .toList();
        selectFileId.value =
            videoPList.isNotEmpty ? videoPList[0].fileId ?? '' : '';
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

class PostComment {
  String? content;
  String? imgPath;
  int? replyCommentId;
  PostComment({
    this.content,
    this.imgPath,
    this.replyCommentId,
  });
}

class CommentController extends GetxController {
  var commentDataList = <VideoComment>[].obs;
  var commentDataTotalCount = 0.obs;
  var commentDataPageNo = 1.obs;
  var commentDataPageTotal = 1.obs;
  var userActionList = <UserAction>[].obs;

  var isLoading = false.obs;
  var sendingComment = false.obs;
  String videoId = '';
  var orderType = 0.obs; // 0:最热, 1:最新
  var inInnerPage = false.obs; // 是否在内页
  bool isLoadingMore = false;
  void setVideoId(String videoId) {
    this.videoId = videoId;
  }

  var nowSelectCommentId = 0.obs;
  int lastSelectCommentId = 0;
  var innerNowSelectCommentId = 0.obs;
  int innerLastSelectCommentId = 0;
  Map<int, PostComment> postCommentMap = {};
  var mainImgPath = ''.obs;
  TextEditingController mainCommentController = TextEditingController();
  var outterImgPath = ''.obs;
  TextEditingController outterCommentController = TextEditingController();
  var innerOutterImgPath = ''.obs;
  TextEditingController innerOutterCommentController = TextEditingController();
  @override
  void onInit() {
    super.onInit();
    ever(nowSelectCommentId, (value) {
      if (value != lastSelectCommentId) {
        postCommentMap[lastSelectCommentId] = PostComment(
            content: mainCommentController.text.trim(),
            imgPath: mainImgPath.value,
            replyCommentId:
                lastSelectCommentId == 0 ? null : lastSelectCommentId);
        mainCommentController.clear();
        mainImgPath.value = '';
        lastSelectCommentId = value;
        mainCommentController.text = postCommentMap[value]?.content ?? '';
        mainImgPath.value = postCommentMap[value]?.imgPath ?? '';
      }
    });
    ever(inInnerPage, (value) {
      if (value == true) {
        var innerComment = postCommentMap[nowSelectCommentId.value];
        if (innerComment != null) {
          innerOutterCommentController.text = innerComment.content ?? '';
          innerOutterImgPath.value = innerComment.imgPath ?? '';
        }
      } else {
        postCommentMap[nowSelectCommentId.value] = PostComment(
            content: innerOutterCommentController.text.trim(),
            imgPath: innerOutterImgPath.value,
            replyCommentId: nowSelectCommentId.value == 0
                ? null
                : nowSelectCommentId.value);
        innerOutterCommentController.clear();
        innerOutterImgPath.value = '';
      }
    });
    ever(innerNowSelectCommentId, (value) {
      if (value != innerLastSelectCommentId) {
        postCommentMap[innerLastSelectCommentId] = PostComment(
            content: mainCommentController.text.trim(),
            imgPath: mainImgPath.value,
            replyCommentId: innerLastSelectCommentId == 0
                ? null
                : innerLastSelectCommentId);
        mainCommentController.clear();
        mainImgPath.value = '';
        lastSelectCommentId = value;
        mainCommentController.text = postCommentMap[value]?.content ?? '';
        mainImgPath.value = postCommentMap[value]?.imgPath ?? '';
      }
    });
  }

  Future<void> postCommentMain() async {
    sendingComment.value = true;
    try {
      if (mainCommentController.text.trim().isEmpty) {
        throw Exception('评论内容不能为空');
      }
      var res = await ApiService.commentPostComment(
          videoId: videoId,
          content: mainCommentController.text.trim(),
          imgPath: mainImgPath.value == '' ? null : mainImgPath.value,
          replyCommentId:
              nowSelectCommentId.value == 0 ? null : nowSelectCommentId.value);
      if (res['code'] == 200) {
        // 清空输入框
        mainCommentController.clear();
        mainImgPath.value = '';
        nowSelectCommentId.value = 0;
        // 刷新评论列表
        await loadComments();
      } else {
        throw Exception('发布评论失败: ${res['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    } finally {
      sendingComment.value = false;
    }
  }

  Future<void> postCommentOutter() async {
    sendingComment.value = true;
    try {
      if (outterCommentController.text.trim().isEmpty) {
        throw Exception('评论内容不能为空');
      }
      if (outterCommentController.text.trim().length > 500) {
        throw Exception('评论内容不能超过500个字符');
      }
      var res = await ApiService.commentPostComment(
          videoId: videoId,
          content: outterCommentController.text.trim(),
          imgPath: outterImgPath.value == '' ? null : outterImgPath.value);
      if (res['code'] == 200) {
        // 清空输入框
        outterCommentController.clear();
        outterImgPath.value = '';
        // 刷新评论列表
        await loadComments();
      } else {
        throw Exception('发布评论失败: ${res['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    } finally {
      sendingComment.value = false;
    }
  }

  bool isLike(int commentId) {
    return userActionList.any((action) =>
        action.actionType == UserActionEnum.COMMENT_LIKE.type &&
        action.commentId == commentId &&
        action.userId == Get.find<AccountController>().userId);
  }

  bool isHate(int commentId) {
    return userActionList.any((action) =>
        action.actionType == UserActionEnum.COMMENT_HATE.type &&
        action.commentId == commentId &&
        action.userId == Get.find<AccountController>().userId);
  }

  Future<void> likeComment(int commentId) async {
    try {
      var res = await ApiService.userActionDoAction(
          videoId: videoId,
          commentId: commentId,
          actionType: UserActionEnum.COMMENT_LIKE.type);
      if (res['code'] == 200) {
        // 更新本地数据
        if (isLike(commentId)) {
          // 已经点赞，取消点赞
          removeLike(commentId);
        } else {
          addLike(commentId);
          if (isHate(commentId)) {
            // 如果已经讨厌，取消讨厌
            removeHate(commentId);
          }
        }
        update();
      } else {
        throw Exception('点赞评论失败: ${res['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }

  Future<void> hateComment(int commentId) async {
    try {
      var res = await ApiService.userActionDoAction(
          videoId: videoId,
          commentId: commentId,
          actionType: UserActionEnum.COMMENT_HATE.type);
      if (res['code'] == 200) {
        // 更新本地数据
        if (isHate(commentId)) {
          // 已经讨厌，取消讨厌
          removeHate(commentId);
        } else {
          addHate(commentId);
          if (isLike(commentId)) {
            // 如果已经点赞，取消点赞
            removeLike(commentId);
          }
        }
        update();
      } else {
        throw Exception('讨厌评论失败: ${res['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }

  void addLike(int commentId) {
    var action = UserAction({
      'actionType': UserActionEnum.COMMENT_LIKE.type,
      'commentId': commentId,
      'userId': Get.find<AccountController>().userId,
    });
    userActionList.add(action);
    var comment = commentDataList.firstWhere((c) => c.commentId == commentId,
        orElse: () => VideoComment({}));
    if (comment.commentId != null) {
      comment.likeCount = (comment.likeCount ?? 0) + 1;
    }
  }

  void addHate(int commentId) {
    var action = UserAction({
      'actionType': UserActionEnum.COMMENT_HATE.type,
      'commentId': commentId,
      'userId': Get.find<AccountController>().userId,
    });
    userActionList.add(action);
    var comment = commentDataList.firstWhere((c) => c.commentId == commentId,
        orElse: () => VideoComment({}));
    if (comment.commentId != null) {
      comment.hateCount = (comment.hateCount ?? 0) + 1;
    }
  }

  void removeLike(int commentId) {
    userActionList.removeWhere((action) =>
        action.actionType == UserActionEnum.COMMENT_LIKE.type &&
        action.commentId == commentId &&
        action.userId == Get.find<AccountController>().userId);
    var comment = commentDataList.firstWhere((c) => c.commentId == commentId,
        orElse: () => VideoComment({}));
    if (comment.commentId != null && comment.likeCount != null) {
      comment.likeCount = (comment.likeCount ?? 0) - 1;
    }
  }

  void removeHate(int commentId) {
    userActionList.removeWhere((action) =>
        action.actionType == UserActionEnum.COMMENT_HATE.type &&
        action.commentId == commentId &&
        action.userId == Get.find<AccountController>().userId);
    var comment = commentDataList.firstWhere((c) => c.commentId == commentId,
        orElse: () => VideoComment({}));
    if (comment.commentId != null && comment.hateCount != null) {
      comment.hateCount = (comment.hateCount ?? 0) - 1;
    }
  }

  Future<void> loadComments() async {
    isLoading.value = true;
    try {
      var res = await ApiService.commentLoadComment(
          videoId: videoId, orderType: orderType.value);
      if (res['code'] == 200) {
        commentDataList.value = (res['data']['commentData']['list'] as List)
            .map((item) => VideoComment(item as Map<String, dynamic>))
            .toList();
        commentDataTotalCount.value =
            res['data']['commentData']['totalCount'] ?? 0;
        commentDataPageNo.value = res['data']['commentData']['pageNo'] ?? 1;
        commentDataPageTotal.value =
            res['data']['commentData']['pageTotal'] ?? 1;
        userActionList.value = (res['data']['userActionList'] as List)
            .map((item) => UserAction(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('加载评论失败: ${res['info']}');
      }
    } catch (e) {
      // showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore ||
        commentDataPageNo.value >= commentDataPageTotal.value) {
      return; // 已经在加载或没有更多数据
    }
    isLoadingMore = true;
    try {
      var res = await ApiService.commentLoadComment(
        videoId: videoId,
        pageNo: commentDataPageNo.value + 1,
      );
      if (res['code'] == 200) {
        var newComments = (res['data']['commentData']['list'] as List)
            .map((item) => VideoComment(item as Map<String, dynamic>))
            .toList();
        commentDataList.addAll(newComments);
        commentDataTotalCount.value =
            res['data']['commentData']['totalCount'] ?? 0;
        commentDataPageNo.value = res['data']['commentData']['pageNo'] ?? 1;
        commentDataPageTotal.value =
            res['data']['commentData']['pageTotal'] ?? 1;
        userActionList.addAll((res['data']['userActionList'] as List)
            .map((item) => UserAction(item as Map<String, dynamic>))
            .toList());
      } else {
        throw Exception('加载更多评论失败: ${res['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    } finally {
      isLoadingMore = false;
    }
    update();
  }
}

class VideoComment {
  int? commentId;
  int? pCommentId;
  String? videoId;
  String? videoUserId;
  String? content;
  String? imgPath;
  String? userId;
  String? replyUserId;
  int? topType;
  DateTime? postTime;
  int? likeCount;
  int? hateCount;
  String? avatar;
  String? nickName;
  String? replyAvatar;
  String? replyNickName;
  List<VideoComment> children = [];
  String? videoCover;
  String? videoName;

  VideoComment(Map<String, dynamic> json) {
    commentId = json['commentId'];
    pCommentId = json['pCommentId'];
    videoId = json['videoId'];
    videoUserId = json['videoUserId'];
    content = json['content'];
    imgPath = json['imgPath'];
    userId = json['userId'];
    replyUserId = json['replyUserId'];
    topType = json['topType'];
    postTime = DateTime.tryParse(json['postTime'] ?? '');
    likeCount = json['likeCount'];
    hateCount = json['hateCount'];
    avatar = json['avatar'];
    nickName = json['nickName'];
    replyAvatar = json['replyAvatar'];
    replyNickName = json['replyNickName'];
    if (json['children'] != null) {
      children =
          (json['children'] as List).map((item) => VideoComment(item)).toList();
    }
    videoCover = json['videoCover'];
    videoName = json['videoName'];
  }
}

class UserAction {
  int? actionId;
  String? videoId;
  String? videoUserId;
  int? commentId;
  int? actionType; // 0:评论喜欢点赞, 1:讨厌评论, 2:视频点赞, 3:视频收藏, 4:视频投币
  int? actionCount;
  String? userId;
  DateTime? actionTime;
  String? videoCover;
  String? videoName;

  UserAction(Map<String, dynamic> json) {
    actionId = json['actionId'];
    videoId = json['videoId'];
    videoUserId = json['videoUserId'];
    commentId = json['commentId'];
    actionType = json['actionType'];
    actionCount = json['actionCount'];
    userId = json['userId'];
    actionTime = DateTime.tryParse(json['actionTime'] ?? '');
    videoCover = json['videoCover'];
    videoName = json['videoName'];
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

class LocalSettingsController extends GetxController {
  var settings = <String, dynamic>{}.obs;
  void setSetting(String key, dynamic value) {
    settings[key] = value;
  }

  @override
  void onInit() {
    super.onInit();
    ever(settings, (_) {
      saveSettings();
    });
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('localSettings', jsonEncode(settings.value));
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    settings.value = prefs.getString('localSettings') != null
        ? Map<String, dynamic>.from(
            jsonDecode(prefs.getString('localSettings')!))
        : {};
    Map<String, dynamic> defaultSettings = {
      'listOrGrid': true,
    };
    defaultSettings.addAll(settings);
    settings.value = defaultSettings;
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
