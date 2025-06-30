import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../api_service.dart';
import '../enums.dart';
import '../Funcs.dart';

class MessageController extends GetxController {
  // 总未读消息数量
  var totalUnreadCount = 0.obs;

  // 各类消息未读数量
  var sysUnreadCount = 0.obs; // 系统消息
  var likeUnreadCount = 0.obs; // 点赞消息
  var collectUnreadCount = 0.obs; // 收藏消息
  var commentUnreadCount = 0.obs; // 评论消息

  // 加载状态
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 初始化时加载未读消息数量
    loadUnreadCounts();

    // 每30秒自动刷新一次未读消息数量
    _startPeriodicRefresh();
  }

  /// 加载总未读消息数量
  Future<void> loadTotalUnreadCount() async {
    try {
      final response = await ApiService.messageGetNoReadCount();
      if (response['code'] == 200) {
        totalUnreadCount.value = response['data'] ?? 0;
      }
    } catch (e) {
      print('加载总未读消息数量失败: $e');
    }
  }

  /// 加载各类消息未读数量
  Future<void> loadGroupUnreadCounts() async {
    try {
      final response = await ApiService.messageGetNoReadCountGroup();
      if (response['code'] == 200) {
        // final data = response['data'] as Map<String, dynamic>? ?? {};
        var data = response['data'] as List<dynamic>? ?? [];
        for (var item in data) {
          var messageCountDto = UserMessageCountDto.fromJson(item);
          if (messageCountDto.messageType == MessageTypeEnum.SYS.type) {
            sysUnreadCount.value = messageCountDto.messageCount;
          } else if (messageCountDto.messageType == MessageTypeEnum.LIKE.type) {
            likeUnreadCount.value = messageCountDto.messageCount;
          } else if (messageCountDto.messageType ==
              MessageTypeEnum.COLLECT.type) {
            collectUnreadCount.value = messageCountDto.messageCount;
          } else if (messageCountDto.messageType ==
              MessageTypeEnum.COMMENT.type) {
            commentUnreadCount.value = messageCountDto.messageCount;
          }
        }
      }
    } catch (e) {
      print('加载分组未读消息数量失败: $e');
    }
  }

  /// 同时加载总数和分组数量
  Future<void> loadUnreadCounts() async {
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      await Future.wait([
        loadTotalUnreadCount(),
        loadGroupUnreadCounts(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  /// 标记某类消息为已读
  Future<void> markAsRead(MessageTypeEnum messageType) async {
    try {
      final response = await ApiService.messageReadAll(messageType.type);
      if (response['code'] == 200) {
        // 成功标记为已读后，重新加载未读数量
        await loadUnreadCounts();
      } else {
        showErrorSnackbar('标记已读失败: ${response['info']}');
      }
    } catch (e) {
      showErrorSnackbar('标记已读失败: $e');
    }
  }

  /// 获取消息类型对应的未读数量
  int getUnreadCountByType(MessageTypeEnum messageType) {
    switch (messageType) {
      case MessageTypeEnum.SYS:
        return sysUnreadCount.value;
      case MessageTypeEnum.LIKE:
        return likeUnreadCount.value;
      case MessageTypeEnum.COLLECT:
        return collectUnreadCount.value;
      case MessageTypeEnum.COMMENT:
        return commentUnreadCount.value;
    }
  }

  /// 获取消息类型对应的图标和颜色
  Map<String, dynamic> getMessageTypeInfo(MessageTypeEnum messageType) {
    switch (messageType) {
      case MessageTypeEnum.SYS:
        return {
          'icon': Icons.notifications,
          'color': Colors.orange,
          'title': '系统消息',
        };
      case MessageTypeEnum.LIKE:
        return {
          'icon': Icons.thumb_up,
          'color': Colors.blue,
          'title': '点赞消息',
        };
      case MessageTypeEnum.COLLECT:
        return {
          'icon': Icons.bookmark,
          'color': Colors.green,
          'title': '收藏消息',
        };
      case MessageTypeEnum.COMMENT:
        return {
          'icon': Icons.comment,
          'color': Colors.purple,
          'title': '评论消息',
        };
    }
  }

  // 消息列表相关变量
  var messages = <UserMessage>[].obs;
  var currentMessageType = MessageTypeEnum.SYS.obs;
  var pageNo = 1.obs;
  var pageTotal = 1.obs;
  var totalCount = 0.obs;
  var isLoadingMessages = false.obs;

  /// 加载指定类型的消息列表
  Future<void> loadMessages({
    required MessageTypeEnum messageType,
    int? pageNo,
    bool refresh = false
  }) async {
    if (isLoadingMessages.value && !refresh) return;

    isLoadingMessages.value = true;

    try {
      if (refresh) {
        this.pageNo.value = 1;
        messages.clear();
      }

      final targetPageNo = pageNo ?? this.pageNo.value;
      currentMessageType.value = messageType;

      final response = await ApiService.messageLoadMessage(
        messageType: messageType.type,
        pageNo: targetPageNo,
      );

      if (response['code'] == 200) {
        final data = response['data'];
        this.pageNo.value = data['pageNo'] ?? 1;
        pageTotal.value = data['pageTotal'] ?? 1;
        totalCount.value = data['totalCount'] ?? 0;

        final messageList = (data['list'] as List<dynamic>? ?? [])
            .map((item) => UserMessage.fromJson(item))
            .toList();

        if (refresh || targetPageNo == 1) {
          messages.value = messageList;
        } else {
          messages.addAll(messageList);
        }

      } else {
        throw Exception('加载消息失败: ${response['info']}');
      }
    } catch (e) {
      showErrorSnackbar('加载消息失败: $e');
    } finally {
      isLoadingMessages.value = false;
    }
  }

  /// 加载更多消息
  Future<void> loadMoreMessages() async {
    if (pageNo.value < pageTotal.value && !isLoadingMessages.value) {
      await loadMessages(
        messageType: currentMessageType.value,
        pageNo: pageNo.value + 1,
      );
    }
  }

  /// 删除指定消息
  Future<void> deleteMessage(int messageId) async {
    try {
      final response = await ApiService.messageDelMessage(messageId);
      if (response['code'] == 200) {
        messages.removeWhere((msg) => msg.messageId == messageId);
        showResSnackbar({'code': 200, 'info': '消息删除成功'});

        // 重新加载未读数量
        await loadUnreadCounts();
      } else {
        throw Exception('删除消息失败: ${response['info']}');
      }
    } catch (e) {
      showErrorSnackbar('删除消息失败: $e');
    }
  }

  /// 切换消息类型
  void switchMessageType(MessageTypeEnum messageType) {
    currentMessageType.value = messageType;
    loadMessages(messageType: messageType, refresh: true);
  }

  /// 定时刷新未读消息数量
  void _startPeriodicRefresh() {
    // 每30秒刷新一次
    Stream.periodic(Duration(seconds: 30)).listen((_) {
      loadUnreadCounts();
    });
  }

  @override
  void onClose() {
    super.onClose();
  }
}

class UserMessageCountDto {
// public class UserMessageCountDto {
//     public Integer messageType;
//     private Integer messageCount;
  final int messageType;
  final int messageCount;

  UserMessageCountDto({
    required this.messageType,
    required this.messageCount,
  });

  factory UserMessageCountDto.fromJson(Map<String, dynamic> json) {
    return UserMessageCountDto(
      messageType: json['messageType'] as int,
      messageCount: json['messageCount'] as int,
    );
  }
}

class UserMessage {
// /**
//  * 用户消息表
//  */
// public class UserMessage implements Serializable {

// 	/**
// 	 * 消息ID自增
// 	 */
// 	private Integer messageId;

// 	/**
// 	 * 用户ID
// 	 */
// 	private String userId;

// 	/**
// 	 * 主体ID
// 	 */
// 	private String videoId;

// 	/**
// 	 * 消息类型
// 	 */
// 	private Integer messageType;

// 	/**
// 	 * 发送人ID
// 	 */
// 	private String sendUserId;

// 	/**
// 	 * 0:未读1：已读
// 	 */
// 	private Integer readType;

// 	/**
// 	 * 创建时间
// 	 */
// 	@JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
// 	@DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
// 	private Date createTime;

// 	/**
// 	 * 扩展信息
// 	 */
// 	private String extendJson;

// 	private String sendUserAvatar;
// 	private String sendUserName;
// 	private String videoName;
// 	private String videoCover;
// 	private UserMessageExtendDto extendDto;

  final int messageId;
  final String userId;
  final String videoId;
  final int messageType;
  final String sendUserId;
  final int readType;
  final DateTime createTime;
  final String extendJson;

  // 扩展信息
  final UserMessageExtendDto extendDto;

  // 发送人信息
  final String sendUserAvatar;
  final String sendUserName;
  final String videoName;
  final String videoCover;

  UserMessage({
    required this.messageId,
    required this.userId,
    required this.videoId,
    required this.messageType,
    required this.sendUserId,
    required this.readType,
    required this.createTime,
    required this.extendJson,
    required this.extendDto,
    required this.sendUserAvatar,
    required this.sendUserName,
    required this.videoName,
    required this.videoCover,
  });

  factory UserMessage.fromJson(Map<String, dynamic> json) {
    return UserMessage(
      messageId: json['messageId'] as int,
      userId: json['userId'] as String,
      videoId: json['videoId'] as String? ?? '',
      messageType: json['messageType'] as int,
      sendUserId: json['sendUserId'] as String? ?? '',
      readType: json['readType'] as int,
      createTime: DateTime.parse(json['createTime']),
      extendJson: json['extendJson'] as String? ?? '',
      extendDto: json['extendDto'] != null 
          ? UserMessageExtendDto.fromJson(json['extendDto'])
          : UserMessageExtendDto(messageContent: '', messageReplyContent: '', auditStatus: 0),
      sendUserAvatar: json['sendUserAvatar'] as String? ?? '',
      sendUserName: json['sendUserName'] as String? ?? '',
      videoName: json['videoName'] as String? ?? '',
      videoCover: json['videoCover'] as String? ?? '',
    );
  }
}

class UserMessageExtendDto {
// public class UserMessageExtendDto {
  // private String messageContent;
  // private String messageReplyContent;

  // private Integer auditStatus;
  final String messageContent;
  final String messageReplyContent;
  final int auditStatus;
  UserMessageExtendDto({
    required this.messageContent,
    required this.messageReplyContent,
    required this.auditStatus,
  });
  factory UserMessageExtendDto.fromJson(Map<String, dynamic> json) {
    return UserMessageExtendDto(
      messageContent: json['messageContent'] as String? ?? '',
      messageReplyContent: json['messageReplyContent'] as String? ?? '',
      auditStatus: json['auditStatus'] as int? ?? 0,
    );
  }
}
