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
        showResSnackbar({'code': 200, 'info': '已标记为已读'});
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
