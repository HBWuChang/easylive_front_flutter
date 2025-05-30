import 'dart:convert';
import 'dart:io';

import 'package:easylive/Funcs.dart';
import 'package:easylive/controllers-class.dart';
import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
import 'package:rhttp/rhttp.dart';
import 'dart:typed_data';

/// 全局API服务，所有网络请求通过此类实现
class ApiService {
  static RhttpClient? _client;
  static String _baseUrl = 'http://127.0.0.1:7071';
  static String get baseUrl => _baseUrl;

  /// 初始化rhttp，需在main函数启动时调用
  static Future<void> init({String? baseUrl}) async {
    _baseUrl = baseUrl ?? 'http://127.0.0.1:7071';
    await Rhttp.init();
    _client = await RhttpClient.create(
      settings: baseUrl != null
          ? ClientSettings(baseUrl: baseUrl)
          : const ClientSettings(),
    );
  }

  /// GET请求
  static Future<HttpTextResponse> get(String path,
      {Map<String, String>? query,
      Map<HttpHeaderName, String>? headers,
      bool useToken = false}) async {
    assert(_client != null, 'ApiService未初始化，请先调用ApiService.init()');
    final response = await _client!.get(
      path,
      query: query,
      headers: useToken
          ? HttpHeaders.rawMap(
              {'token-xuan': Get.find<AccountController>().token ?? ''})
          : (headers != null ? HttpHeaders.map(headers) : null),
    );
    if (response.statusCode == 901) {
      openLoginDialog();
    }
    return response;
  }

  static Future<HttpBytesResponse> getBytes(String path,
      {Map<String, String>? query,
      Map<HttpHeaderName, String>? headers,
      bool useToken = false}) async {
    assert(_client != null, 'ApiService未初始化，请先调用ApiService.init()');
    final response = await _client!.getBytes(
      path,
      query: query,
      headers: useToken
          ? HttpHeaders.rawMap(
              {'token-xuan': Get.find<AccountController>().token ?? ''})
          : (headers != null ? HttpHeaders.map(headers) : null),
    );
    if (response.statusCode == 901) {
      openLoginDialog();
    }
    return response;
  }

  /// POST请求（支持json、form等多种body）
  static Future<HttpTextResponse> post(String path,
      {Object? data,
      Map<HttpHeaderName, String>? headers,
      bool isJson = true,
      bool ismultipart = false,
      bool useToken = false}) async {
    assert(_client != null, 'ApiService未初始化，请先调用ApiService.init()');
    final body = data == null
        ? null
        : isJson
            ? HttpBody.json(data)
            : ismultipart
                ? HttpBody.multipart(data as Map<String, MultipartItem>)
                : HttpBody.form((data as Map<String, String>));
    final response = await _client!.post(
      path,
      body: body,
      headers: useToken
          ? HttpHeaders.rawMap(
              {'token-xuan': Get.find<AccountController>().token ?? ''})
          : (headers != null ? HttpHeaders.map(headers) : null),
    );
    return response as HttpTextResponse;
  }

  static Map<String, dynamic> toJson(HttpTextResponse httpTextResponse) {
    return jsonDecode(httpTextResponse.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> accountCheckCode() async {
    return toJson(await get(
      ApiAddr.accountCheckCode,
    ));
  }

  static Future<Map<String, dynamic>> accountRegister({
    required String email,
    required String nickName,
    required String password,
    required String checkCodeKey,
    required String checkCode,
  }) async {
    return toJson(await get(
      ApiAddr.accountRegister,
      query: {
        "email": email,
        "nickName": nickName,
        "password": password,
        "checkCodeKey": checkCodeKey,
        "checkCode": checkCode,
      },
    ));
  }

  static Future<Map<String, dynamic>> accountLogin({
    required String email,
    required String password,
    required String checkCodeKey,
    required String checkCode,
  }) async {
    // 对密码进行MD5加密
    final passwordMd5 = md5.convert(utf8.encode(password)).toString();

    return toJson(await get(
      ApiAddr.accountLogin,
      query: {
        "email": email,
        "password": passwordMd5,
        "checkCodeKey": checkCodeKey,
        "checkCode": checkCode,
      },
    ));
  }

  static Future<Map<String, dynamic>> accountAutologin() async {
    return toJson(await get(
      ApiAddr.accountAutologin,
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> accountLogout() async {
    return toJson(await get(
      ApiAddr.accountLogout,
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> accountGetUserCountInfo() async {
    return toJson(await get(
      ApiAddr.accountGetUserCountInfo,
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> categoryLoadAllCategory() async {
    return toJson(await get(
      ApiAddr.categoryLoadAllCategory,
    ));
  }

  static Future<dynamic> fileGetResource({required String sourceName}) async {
    return (await getBytes(
      ApiAddr.fileGetResource,
      query: {
        'sourceName': sourceName,
      },
    ))
        .body;
  }

  static Future<Map<String, dynamic>> filePreUploadVideo(
      {required String fileName, required String chunks}) async {
    return toJson(await get(
      ApiAddr.fileGetResourcet,
      query: {
        'sourceName': fileName,
        'chunks': chunks,
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> fileUploadVideo(
      {required Uint8List chunkFile,
      required int chunkIndex,
      required String uploadId}) async {
    return toJson(await post(
      ApiAddr.fileUploadVideo,
      data: {
        'chunkFile':
            MultipartItem.bytes(bytes: chunkFile, fileName: 'video.mp4'),
        'chunkIndex': MultipartItem.text(text: chunkIndex.toString()),
        'uploadId': MultipartItem.text(text: uploadId),
      },
      ismultipart: true,
      isJson: false,
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> fileDelUploadVideo(
      {required String uploadId}) async {
    return toJson(await get(
      ApiAddr.fileDelUploadVideo,
      query: {'uploadId': uploadId},
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> fileUploadImage(
      {bool createThumbnail = false, required Uint8List file}) async {
    return toJson(await post(
      ApiAddr.fileUploadImage,
      data: {
        'file': MultipartItem.bytes(bytes: file, fileName: 'image.png'),
        'createThumbnail': MultipartItem.text(text: createThumbnail.toString()),
      },
      ismultipart: true,
      isJson: false,
      useToken: true,
    ));
  }

  static Future<dynamic> fileVideoResource(
      {required String fileId, String? ts}) async {
    return (await getBytes(
      '${ApiAddr.fileVideoResource}/$fileId${ts != null ? '/$ts' : ''}',
      useToken: true,
    ))
        .body;
  }

  static Future<Map<String, dynamic>> sysSettingGetSetting() async {
    return toJson(await get(
      ApiAddr.sysSettingGetSetting,
    ));
  }

  static Future<Map<String, dynamic>> ucenterPostVideo(
      // ucenterPostVideo
//   {
//   "videoId": "",
//   "videoCover": "cover/202505\\\\nMXv5kAw0Qu7gLgWHccEKSJLrra5tp.webp",
//   "videoName": "改4反恐精英：全球攻势23x24",
//   "pCategoryId": "37",
//   "categoryId": "",
//   "postType": "0",
//   "tags": "12",
//   "introduction": "简介123改",
//   "interaction": "",
//   "uploadFileList": "[{\n        \"uploadId\": \"Nld77MhqWfN4oMfb\",\n        \"fileName\": \"文件名2\"\n      }]"
// }
// public ResponseVO postVideo(String videoId,
// 			@NotEmpty String videoCover,
// 			@NotEmpty @Size(max = 100) String videoName,
// 			@NotNull Integer pCategoryId,
// 			Integer categoryId,
// 			@NotNull Integer postType,
// 			@NotEmpty @Size(max = 300) String tags,
// 			@Size(max = 2000) String introduction,
// 			@Size(max = 3) String interaction,
// 			@NotEmpty String uploadFileList) {
      {String? videoId,
      required String videoCover,
      required String videoName,
      required int pCategoryId,
      int? categoryId,
      required int postType,
      required String tags,
      String? introduction,
      String? interaction,
      required List<VideoInfoFilePost> uploadFileList}) async {
    return toJson(await post(ApiAddr.ucenterPostVideo,
        isJson: false,
        ismultipart: false,
        data: {
          'videoId': videoId ?? '',
          'videoCover': videoCover,
          'videoName': videoName,
          'pCategoryId': pCategoryId.toString(),
          'categoryId': categoryId?.toString() ?? '',
          'postType': postType.toString(),
          'tags': tags,
          'introduction': introduction ?? '',
          'interaction': interaction ?? '',
          'uploadFileList': jsonEncode(
            uploadFileList.map((e) {
              return e.toJson();
            }).toList(),
          ),
        }));
  }

  static Future<Map<String, dynamic>> ucenterLoadVideoList(
      {int? status, int? pageNo, String? videoNameFuzzy}) async {
    return toJson(await get(
      ApiAddr.ucenterLoadVideoList,
      query: {
        'status': status?.toString() ?? '',
        'pageNo': pageNo?.toString() ?? '',
        'videoNameFuzzy': videoNameFuzzy ?? '',
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> ucenterGetVideoCountInfo() async {
    return toJson(await get(
      ApiAddr.ucenterGetVideoCountInfo,
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> ucenterGetVideoByVideoId(
      String videoId) async {
    return toJson(await get(
      ApiAddr.ucenterGetVideoByVideoId,
      query: {'videoId': videoId},
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> ucenterDeleteVideo(String videoId) async {
    return toJson(await get(
      ApiAddr.ucenterDeleteVideo,
      query: {'videoId': videoId},
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> ucenterSaveVideoInteraction(
      String videoId, String interaction) async {
    return toJson(await get(
      ApiAddr.ucenterSaveVideoInteraction,
      query: {'videoId': videoId, 'interaction': interaction},
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> ucenterLoadAllVideo() async {
    return toJson(await get(
      ApiAddr.ucenterLoadAllVideo,
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> ucenterLoadComment(
      String? videoId, int? pageNo) async {
    return toJson(await get(
      ApiAddr.ucenterLoadComment,
      query: {'videoId': videoId ?? '', 'pageNo': pageNo?.toString() ?? ''},
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> ucenterDelComment(int commentId) async {
    return toJson(await get(
      ApiAddr.ucenterDelComment,
      query: {'commentId': commentId.toString()},
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> ucenterLoadDanmu(
      String videoId, int? pageNo) async {
    return toJson(await get(
      ApiAddr.ucenterLoadDanmu,
      query: {'videoId': videoId, 'pageNo': pageNo?.toString() ?? ''},
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> ucenterDelDanmu(int danmuId) async {
    return toJson(await get(
      ApiAddr.ucenterDelDanmu,
      query: {'danmuId': danmuId.toString()},
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>>
      ucenterGetActualTimeStatisticsInfo() async {
    return toJson(await get(
      ApiAddr.ucenterGetActualTimeStatisticsInfo,
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> ucenterGetWeekStatisticsInfo(
      int? dataType) async {
    return toJson(await get(
      ApiAddr.ucenterGetWeekStatisticsInfo,
      query: {'dataType': dataType?.toString() ?? ''},
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> uhomeGetUserInfo(String userId) async {
    return toJson(await get(
      ApiAddr.uhomeGetUserInfo,
      query: {'userId': userId},
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> uhomeUpdateUserInfo(
      String nickName,
      String avatar,
      int sex,
      String birthday,
      String school,
      String noticeInfo,
      String personIntroduction) async {
    return toJson(await get(
      ApiAddr.uhomeUpdateUserInfo,
      query: {
        "nickName": nickName,
        "avatar": avatar,
        "sex": sex.toString(),
        "birthday": birthday,
        "school": school,
        "noticeInfo": noticeInfo,
        "personIntroduction": personIntroduction,
      },
      useToken: true,
    ));
  }
}

class ApiAddr {
  static const String LoginBackGround =
      'cover/202505\\qHVupu9Jk8YNMgg5N9ovtPnu6DXAhg.webp';
  static const String accountLogin = '/account/login';
  static const String accountCheckCode = '/account/checkCode';
  static const String accountRegister = '/account/register';
  static const String accountAutologin = '/account/autologin';
  static const String accountLogout = '/account/logout';
  static const String accountGetUserCountInfo = '/account/getUserCountInfo';
  static const String categoryLoadAllCategory = '/category/loadAllCategory';
  static const String fileGetResource = '/file/getResource';
  static const String fileGetResourcet = '/file/getResource?sourceName=';
  static const String filePreUploadVideo = '/file/preUploadVideo';
  static const String fileUploadVideo = '/file/uploadVideo';
  static const String fileDelUploadVideo = '/file/delUploadVideo';
  static const String fileUploadImage = '/file/uploadImage';
  static const String fileVideoResource = '/file/videoResource';
  static const String sysSettingGetSetting = '/sysSetting/getSetting';
  static const String ucenterPostVideo = '/ucenter/postVideo';
  static const String ucenterLoadVideoList = '/ucenter/loadVideoList';
  // /ucenter/getVideoCountInfo
  static const String ucenterGetVideoCountInfo = '/ucenter/getVideoCountInfo';
  // /ucenter/getVideoByVideoId
  static const String ucenterGetVideoByVideoId = '/ucenter/getVideoByVideoId';
  // /ucenter/saveVideoInteraction
  static const String ucenterSaveVideoInteraction =
      '/ucenter/saveVideoInteraction';
  // /ucenter/deleteVideo
  static const String ucenterDeleteVideo = '/ucenter/deleteVideo';
  // /ucenter/loadAllVideo
  static const String ucenterLoadAllVideo = '/ucenter/loadAllVideo';
  // /ucenter/loadComment
  static const String ucenterLoadComment = '/ucenter/loadComment';
  // /ucenter/delComment
  static const String ucenterDelComment = '/ucenter/delComment';
  // /ucenter/loadDanmu
  static const String ucenterLoadDanmu = '/ucenter/loadDanmu';
  // /ucenter/delDanmu
  static const String ucenterDelDanmu = '/ucenter/delDanmu';
  // /ucenter/getActualTimeStatisticsInfo
  static const String ucenterGetActualTimeStatisticsInfo =
      '/ucenter/getActualTimeStatisticsInfo';
  // /ucenter/getWeekStatisticsInfo
  static const String ucenterGetWeekStatisticsInfo =
      '/ucenter/getWeekStatisticsInfo';
  static const String uhomeGetUserInfo = '/uhome/getUserInfo';
  static const String uhomeUpdateUserInfo = '/uhome/updateUserInfo';
}
