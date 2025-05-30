import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'Funcs.dart';

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
      Get.snackbar('获取用户信息错误', response['msg'],
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
