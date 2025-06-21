import 'dart:convert';
import 'dart:io';

import 'package:easylive/Funcs.dart';
import 'package:easylive/controllers/controllers-class.dart';
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
          ? ClientSettings(
              baseUrl: baseUrl,
              // proxySettings: ProxySettings.proxy('http://localhost:9000'),
              cookieSettings: CookieSettings(storeCookies: true),
            )
          : const ClientSettings(
              cookieSettings: CookieSettings(storeCookies: true),
            ),
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
    // return jsonDecode(httpTextResponse.body) as Map<String, dynamic>;
    return httpTextResponse.bodyToJson;
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

  static Future<dynamic> fileGetResource(String sourceName) async {
    return (await getBytes(
      ApiAddr.fileGetResource,
      query: {
        'sourceName': sourceName,
      },
    ))
        .body;
  }

  static Future<Map<String, dynamic>> filePreUploadVideo(
      {required String fileName, required int chunks}) async {
    return toJson(await get(
      ApiAddr.filePreUploadVideo,
      query: {
        'fileName': fileName,
        'chunks': chunks.toString(),
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
      String uploadId) async {
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
      String? origin_info,
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
          'originInfo': origin_info ?? '',
          'interaction': interaction ?? '',
          'uploadFileList': jsonEncode(
            uploadFileList.map((e) {
              return e.toJson();
            }).toList(),
          ),
        },
        useToken: true));
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
      {required String videoId, required String interaction}) async {
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
      {required String? videoId, required int? pageNo}) async {
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
      {required String videoId, required int? pageNo}) async {
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

  static Future<Map<String, dynamic>> videoLoadRecommendVideo() async {
    return toJson(await get(
      ApiAddr.videoLoadRecommendVideo,
    ));
  }

  static Future<Map<String, dynamic>> videoLoadVideo(
      {int? pCategoryId, int? categoryId, int? pageNo}) async {
    return toJson(await get(
      ApiAddr.videoLoadVideo,
      query: {
        'pCategoryId': pCategoryId?.toString() ?? '',
        'categoryId': categoryId?.toString() ?? '',
        'pageNo': pageNo?.toString() ?? '',
      },
    ));
  }

  static Future<Map<String, dynamic>> videoGetVideoInfo(String videoId) async {
    return toJson(await get(
      ApiAddr.videoGetVideoInfo,
      query: {'videoId': videoId},
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> videoLoadVideoPList(
      String videoId) async {
    return toJson(await get(
      ApiAddr.videoLoadVideoPList,
      query: {
        'videoId': videoId,
      },
    ));
  }

  static Future<Map<String, dynamic>> videoReportVideoPlayOnline(
      {required String fileId, required String deviceId}) async {
    return toJson(await get(
      ApiAddr.videoReportVideoPlayOnline,
      query: {
        'fileId': fileId,
        'deviceId': deviceId,
      },
    ));
  }

  static Future<Map<String, dynamic>> videoSearch(
      {required String keyword, int? orderType, int? pageNo}) async {
    return toJson(await get(
      ApiAddr.videoSearch,
      query: {
        'keyword': keyword,
        'orderType': orderType?.toString() ?? '',
        'pageNo': pageNo?.toString() ?? '',
      },
    ));
  }

  static Future<Map<String, dynamic>> videoGetVideoRecommend(
      {required String keyword, required String videoId}) async {
    return toJson(await get(
      ApiAddr.videoGetVideoRecommend,
      query: {
        'keyword': keyword,
        'videoId': videoId,
      },
    ));
  }

  static Future<Map<String, dynamic>> videoGetSearchKeywordTop() async {
    return toJson(await get(
      ApiAddr.videoGetSearchKeywordTop,
    ));
  }

  static Future<Map<String, dynamic>> danmuPostDanmu(
      // public ResponseVO postDanmu(@NotEmpty String videoId, @NotEmpty String fileId,
      // 	@NotEmpty @Size(max = 200) String text, @NotNull Integer mode, @NotEmpty String color,
      // 	@NotNull Integer time)
      {required String videoId,
      required String fileId,
      required String text,
      required int mode,
      required String color,
      required int time}) async {
    return toJson(await get(
      ApiAddr.danmuPostDanmu,
      query: {
        'videoId': videoId,
        'fileId': fileId,
        'text': text,
        'mode': mode.toString(),
        'color': color,
        'time': time.toString(),
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> danmuLoadDanmu(
      {required String videoId, required String fileId}) async {
    return toJson(await get(
      ApiAddr.danmuLoadDanmu,
      query: {
        'videoId': videoId,
        'fileId': fileId,
      },
    ));
  }

  static Future<Map<String, dynamic>> userActionDoAction(
      // public ResponseVO doAction(@NotEmpty String videoId, @NonNull Integer actionType,
      // @Max(2) @Min(1) Integer actionCount,
      // Integer commentId) {
      {required String videoId,
      required int actionType,
      int? actionCount,
      int? commentId}) async {
    return toJson(await get(
      ApiAddr.userActionDoAction,
      query: {
        'videoId': videoId,
        'actionType': actionType.toString(),
        'actionCount': actionCount?.toString() ?? '',
        'commentId': commentId?.toString() ?? '',
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> commentPostComment
      // public ResponseVO postComment(@NotEmpty String videoId,
      // 		@NotEmpty @Size(max = 500) String content, @Size(max = 50) String imgPath, Integer replyCommentId) {
      (
          {required String videoId,
          required String content,
          String? imgPath,
          int? replyCommentId}) async {
    return toJson(await get(
      ApiAddr.commentPostComment,
      query: {
        'videoId': videoId,
        'content': content,
        'imgPath': imgPath ?? '',
        'replyCommentId': replyCommentId?.toString() ?? '',
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> commentLoadComment(
      {required String videoId, int? pageNo, int? orderType}) async {
    return toJson(await get(
      ApiAddr.commentLoadComment,
      query: {
        'videoId': videoId,
        'pageNo': pageNo?.toString() ?? '',
        'orderType': orderType?.toString() ?? '',
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> commentTopComment(int commentId) async {
    return toJson(await get(
      ApiAddr.commentTopComment,
      query: {
        'commentId': commentId.toString(),
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> commentCancelTopComment(
      int commentId) async {
    return toJson(await get(
      ApiAddr.commentCancelTopComment,
      query: {
        'commentId': commentId.toString(),
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> commentUserDelComment(
      int commentId) async {
    return toJson(await get(
      ApiAddr.commentUserDelComment,
      query: {
        'commentId': commentId.toString(),
      },
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
      {required String nickName,
      required String avatar,
      required int sex,
      required String birthday,
      required String school,
      required String noticeInfo,
      required String personIntroduction}) async {
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

  static Future<Map<String, dynamic>> uhomeSaveTheme(String theme) async {
    return toJson(await get(
      ApiAddr.uhomeSaveTheme,
      query: {
        "theme": theme,
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> uhomeFocus(String focusUserId) async {
    return toJson(await get(
      ApiAddr.uhomeFocus,
      query: {
        "focusUserId": focusUserId,
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> uhomeCancelFocus(
      String focusUserId) async {
    return toJson(await get(
      ApiAddr.uhomeCancelFocus,
      query: {
        "focusUserId": focusUserId,
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> uhomeLoadFocusList(int? pageNo) async {
    return toJson(await get(
      ApiAddr.uhomeLoadFocusList,
      query: {
        "pageNo": pageNo?.toString() ?? '',
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> uhomeLoadFansList(int? pageNo) async {
    return toJson(await get(
      ApiAddr.uhomeLoadFansList,
      query: {
        "pageNo": pageNo?.toString() ?? '',
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> uhomeLoadVideoList(
      // (@NotEmpty String userId, Integer type, Integer pageNo, String videoName,
      // Integer orderType)
      {required String userId,
      int? type,
      int? pageNo,
      String? videoName,
      int? orderType}) async {
    return toJson(await get(
      ApiAddr.uhomeLoadVideoList,
      query: {
        'userId': userId,
        'type': type?.toString() ?? '',
        'pageNo': pageNo?.toString() ?? '',
        'videoName': videoName ?? '',
        'orderType': orderType?.toString() ?? '',
      },useToken: true
    ));
  }

  static Future<Map<String, dynamic>> uhomeLoadUserCollection(
      {required String userId, int? pageNo}) async {
    return toJson(await get(
      ApiAddr.uhomeLoadUserCollection,
      query: {
        'userId': userId,
        'pageNo': pageNo?.toString() ?? '',
      },
    ));
  }

  static Future<Map<String, dynamic>> uhomeSeriesLoadVideoSeries(
      String userId) async {
    return toJson(await get(
      ApiAddr.uhomeSeriesLoadVideoSeries,
      query: {
        'userId': userId,
      },
    ));
  }

  static Future<Map<String, dynamic>> uhomeSeriesSaveVideoSeries(
      // (Integer seriesId, @NotEmpty @Size(max = 100) String seriesName,
      //         @Size(max = 200) String seriesDesc, String videoIds)
      {int? seriesId,
      required String seriesName,
      String? seriesDesc,
      required String videoIds}) async {
    return toJson(await get(
      ApiAddr.uhomeSeriesSaveVideoSeries,
      query: {
        'seriesId': seriesId?.toString() ?? '',
        'seriesName': seriesName,
        'seriesDesc': seriesDesc ?? '',
        'videoIds': videoIds,
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> uhomeSeriesLoadAllVideo(
      int? seriesId) async {
    return toJson(await get(
      ApiAddr.uhomeSeriesLoadAllVideo,
      query: {
        'seriesId': seriesId?.toString() ?? '',
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> uhomeSeriesGetVideoSeriesDetail(
      int seriesId) async {
    return toJson(await get(
      ApiAddr.uhomeSeriesGetVideoSeriesDetail,
      query: {
        'seriesId': seriesId.toString(),
      },
    ));
  }

  static Future<Map<String, dynamic>> uhomeSeriesSaveSeriesVideo(
      {required int seriesId, required String videoIds}) async {
    return toJson(await get(
      ApiAddr.uhomeSeriesSaveSeriesVideo,
      query: {
        'seriesId': seriesId.toString(),
        'videoIds': videoIds,
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> uhomeSeriesDelSeriesVideo(
      {required int seriesId, required String videoId}) async {
    return toJson(await get(
      ApiAddr.uhomeSeriesDelSeriesVideo,
      query: {
        'seriesId': seriesId.toString(),
        'videoId': videoId,
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> uhomeSeriesDelVideoSeries(
      int seriesId) async {
    return toJson(await get(
      ApiAddr.uhomeSeriesDelVideoSeries,
      query: {
        'seriesId': seriesId.toString(),
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> uhomeSeriesChangeVideoSeriesSort(
      String seriesIds) async {
    return toJson(await get(
      ApiAddr.uhomeSeriesChangeVideoSeriesSort,
      query: {
        'seriesIds': seriesIds,
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> uhomeSeriesLoadVideoSeriesWithVideo(
      String userId) async {
    return toJson(await get(
      ApiAddr.uhomeSeriesLoadVideoSeriesWithVideo,
      query: {
        'userId': userId,
      },
    ));
  }

  static Future<Map<String, dynamic>> messageGetNoReadCount() async {
    return toJson(await get(
      ApiAddr.messageGetNoReadCount,
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> messageGetNoReadCountGroup() async {
    return toJson(await get(
      ApiAddr.messageGetNoReadCountGroup,
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> messageReadAll(int messageType) async {
    return toJson(await get(
      ApiAddr.messageReadAll,
      query: {
        'messageType': messageType.toString(),
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> messageLoadMessage(
      {required int messageType, int? pageNo}) async {
    return toJson(await get(
      ApiAddr.messageLoadMessage,
      query: {
        'messageType': messageType.toString(),
        'pageNo': pageNo?.toString() ?? '',
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> messageDelMessage(int messageId) async {
    return toJson(await get(
      ApiAddr.messageDelMessage,
      query: {
        'messageId': messageId.toString(),
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> historyLoadHistory(int? pageNo) async {
    return toJson(await get(
      ApiAddr.historyLoadHistory,
      query: {
        'pageNo': pageNo?.toString() ?? '',
      },
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> historyCleanHistory() async {
    return toJson(await get(
      ApiAddr.historyCleanHistory,
      useToken: true,
    ));
  }

  static Future<Map<String, dynamic>> historyDelHistory(String videoId) async {
    return toJson(await get(
      ApiAddr.historyDelHistory,
      query: {
        'videoId': videoId,
      },
      useToken: true,
    ));
  }
}

class ApiAddr {
  static const String LoginBackGround =
      'cover/202506/VrTlLrAokaMhyOk8rjqMuV2VCCkltH.webp';
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
  static const String ucenterGetVideoCountInfo = '/ucenter/getVideoCountInfo';
  static const String ucenterGetVideoByVideoId = '/ucenter/getVideoByVideoId';
  static const String ucenterSaveVideoInteraction =
      '/ucenter/saveVideoInteraction';
  static const String ucenterDeleteVideo = '/ucenter/deleteVideo';
  static const String ucenterLoadAllVideo = '/ucenter/loadAllVideo';
  static const String ucenterLoadComment = '/ucenter/loadComment';
  static const String ucenterDelComment = '/ucenter/delComment';
  static const String ucenterLoadDanmu = '/ucenter/loadDanmu';
  static const String ucenterDelDanmu = '/ucenter/delDanmu';
  static const String ucenterGetActualTimeStatisticsInfo =
      '/ucenter/getActualTimeStatisticsInfo';
  static const String ucenterGetWeekStatisticsInfo =
      '/ucenter/getWeekStatisticsInfo';
  static const String videoLoadRecommendVideo = '/video/loadRecommendVideo';
  static const String videoLoadVideo = '/video/loadVideo';
  static const String videoGetVideoInfo = '/video/getVideoInfo';
  static const String videoLoadVideoPList = '/video/loadVideoPList';
  static const String videoReportVideoPlayOnline =
      '/video/reportVideoPlayOnline';
  static const String videoSearch = '/video/search';
  static const String videoGetVideoRecommend = '/video/getVideoRecommend';
  static const String videoGetSearchKeywordTop = '/video/getSearchKeywordTop';
  static const String danmuPostDanmu = '/danmu/postDanmu';
  static const String danmuLoadDanmu = '/danmu/loadDanmu';
  static const String userActionDoAction = '/userAction/doAction';
  static const String commentPostComment = '/comment/postComment';
  static const String commentLoadComment = '/comment/loadComment';
  static const String commentTopComment = '/comment/topComment';
  static const String commentCancelTopComment = '/comment/cancelTopComment';
  static const String commentUserDelComment = '/comment/userDelComment';
  static const String uhomeGetUserInfo = '/uhome/getUserInfo';
  static const String uhomeUpdateUserInfo = '/uhome/updateUserInfo';
  static const String uhomeSaveTheme = '/uhome/saveTheme';
  static const String uhomeFocus = '/uhome/focus';
  static const String uhomeCancelFocus = '/uhome/cancelFocus';
  static const String uhomeLoadFocusList = '/uhome/loadFocusList';
  static const String uhomeLoadFansList = '/uhome/loadFansList';
  static const String uhomeLoadVideoList = '/uhome/loadVideoList';
  static const String uhomeLoadUserCollection = '/uhome/loadUserCollection';
  static const String uhomeSeriesLoadVideoSeries =
      '/uhome/series/loadVideoSeries';
  static const String uhomeSeriesSaveVideoSeries =
      '/uhome/series/saveVideoSeries';
  static const String uhomeSeriesLoadAllVideo = '/uhome/series/loadAllVideo';
  static const String uhomeSeriesGetVideoSeriesDetail =
      '/uhome/series/getVideoSeriesDetail';
  static const String uhomeSeriesSaveSeriesVideo =
      '/uhome/series/saveSeriesVideo';
  static const String uhomeSeriesDelSeriesVideo =
      '/uhome/series/delSeriesVideo';
  static const String uhomeSeriesDelVideoSeries =
      '/uhome/series/delVideoSeries';
  static const String uhomeSeriesChangeVideoSeriesSort =
      '/uhome/series/changeVideoSeriesSort';
  static const String uhomeSeriesLoadVideoSeriesWithVideo =
      '/uhome/series/loadVideoSeriesWithVideo';
  static const String messageGetNoReadCount = '/message/getNoReadCount';
  static const String messageGetNoReadCountGroup =
      '/message/getNoReadCountGroup';
  static const String messageReadAll = '/message/readAll';
  static const String messageLoadMessage = '/message/loadMessage';
  static const String messageDelMessage = '/message/delMessage';
  static const String historyLoadHistory = '/history/loadHistory';
  static const String historyCleanHistory = '/history/cleanHistory';
  static const String historyDelHistory = '/history/delHistory';
}
