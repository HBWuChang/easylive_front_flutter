import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:easylive/controllers/controllers-class2.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/settings.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';
import '../Funcs.dart';
import 'package:media_kit/media_kit.dart';
import 'controllers-class.dart';

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
  ScrollController outterScrollController = ScrollController();
  var showFAB = false.obs;
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
    outterScrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (outterScrollController.offset > 100 && !showFAB.value) {
      showFAB.value = true;
    } else if (outterScrollController.offset <= 100 && showFAB.value) {
      showFAB.value = false;
    }
    if (outterScrollController.offset >=
        outterScrollController.position.maxScrollExtent) {
      // 到达底部时加载更多评论
      loadMore();
    }
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
          replyCommentId: inInnerPage.value
              ? innerNowSelectCommentId.value
              : nowSelectCommentId.value == 0
                  ? null
                  : nowSelectCommentId.value);
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
      if (inInnerPage.value) {
        if (innerOutterCommentController.text.trim().isEmpty) {
          throw Exception('评论内容不能为空');
        }
        if (innerOutterCommentController.text.trim().length > 500) {
          throw Exception('评论内容不能超过500个字符');
        }
      } else {
        if (outterCommentController.text.trim().isEmpty) {
          throw Exception('评论内容不能为空');
        }
        if (outterCommentController.text.trim().length > 500) {
          throw Exception('评论内容不能超过500个字符');
        }
      }
      var res = await ApiService.commentPostComment(
          videoId: videoId,
          content: inInnerPage.value
              ? innerOutterCommentController.text.trim()
              : outterCommentController.text.trim(),
          imgPath: inInnerPage.value
              ? (innerOutterImgPath.value == ''
                  ? null
                  : innerOutterImgPath.value)
              : (outterImgPath.value == '' ? null : outterImgPath.value),
          replyCommentId: inInnerPage.value ? nowSelectCommentId.value : 0);
      if (res['code'] == 200) {
        // 清空输入框
        if (inInnerPage.value) {
          innerOutterCommentController.clear();
          innerOutterImgPath.value = '';
        } else {
          outterCommentController.clear();
          outterImgPath.value = '';
        }
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
    } else {
      // 子评论
      var parentComment = commentDataList.firstWhere(
          (c) => c.commentId == nowSelectCommentId.value,
          orElse: () => VideoComment({}));
      if (parentComment.commentId != null) {
        var comment = parentComment.children.firstWhere(
            (c) => c.commentId == commentId,
            orElse: () => VideoComment({}));
        if (comment.commentId != null) {
          comment.likeCount = (comment.likeCount ?? 0) + 1;
        }
      }
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
    } else {
      // 子评论
      var parentComment = commentDataList.firstWhere(
          (c) => c.commentId == nowSelectCommentId.value,
          orElse: () => VideoComment({}));
      if (parentComment.commentId != null) {
        var comment = parentComment.children.firstWhere(
            (c) => c.commentId == commentId,
            orElse: () => VideoComment({}));
        if (comment.commentId != null) {
          comment.hateCount = (comment.hateCount ?? 0) + 1;
        }
      }
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
    } else {
      // 子评论
      var parentComment = commentDataList.firstWhere(
          (c) => c.commentId == nowSelectCommentId.value,
          orElse: () => VideoComment({}));
      if (parentComment.commentId != null) {
        var comment = parentComment.children.firstWhere(
            (c) => c.commentId == commentId,
            orElse: () => VideoComment({}));
        if (comment.commentId != null && comment.likeCount != null) {
          comment.likeCount = (comment.likeCount ?? 0) - 1;
        }
      }
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
    } else {
      // 子评论
      var parentComment = commentDataList.firstWhere(
          (c) => c.commentId == nowSelectCommentId.value,
          orElse: () => VideoComment({}));
      if (parentComment.commentId != null) {
        var comment = parentComment.children.firstWhere(
            (c) => c.commentId == commentId,
            orElse: () => VideoComment({}));
        if (comment.commentId != null && comment.hateCount != null) {
          comment.hateCount = (comment.hateCount ?? 0) - 1;
        }
      }
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
        orderType: orderType.value,
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
