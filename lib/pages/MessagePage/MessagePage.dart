import 'package:easylive/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/MessageController.dart';
import '../../controllers/controllers-class.dart';
import '../../enums.dart';
import '../../settings.dart';
import '../../api_service.dart';
import 'package:extended_image/extended_image.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final MessageController messageController = Get.find<MessageController>();
  final AppBarController appBarController = Get.find<AppBarController>();
  late ScrollController _scrollController;

  final List<MessageTypeEnum> messageTypes = [
    MessageTypeEnum.SYS,
    MessageTypeEnum.LIKE,
    MessageTypeEnum.COMMENT,
    MessageTypeEnum.COLLECT,
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    // 获取路径参数中的消息类型
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 从路径中获取消息类型参数
      final routeName = ModalRoute.of(context)?.settings.name;

      // 路径格式: /messagePage/messageType
      final pathSegments = routeName!.split('/');
      if (pathSegments.length >= 3) {
        final messageTypeParam = pathSegments[2];

        final messageTypeInt = int.tryParse(messageTypeParam);
        if (messageTypeInt != null) {
          try {
            final targetType = MessageTypeEnum.values.firstWhere(
              (type) => type.type == messageTypeInt,
            );
            messageController.switchMessageType(targetType);
            return;
          } catch (e) {
            // 如果找不到对应的消息类型，使用默认类型
          }
        }
      }

      // 默认加载系统消息
      messageController.switchMessageType(MessageTypeEnum.SYS);
    });
  }

  void _scrollListener() {
    // 管理 AppBar 透明度状态
    if (_scrollController.offset > kToolbarHeight) {
      appBarController.extendBodyBehindAppBar.value = false;
    } else {
      appBarController.extendBodyBehindAppBar.value = true;
    }

    // 滚动到底部时加载更多
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      messageController.loadMoreMessages();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 背景图片和标题
          SliverAppBar(
            expandedHeight: 200.h,
            floating: false,
            pinned: false,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // 背景图片
                  Positioned.fill(
                    child: ExtendedImage.network(
                      ApiService.baseUrl +
                          ApiAddr.fileGetResourcet +
                          ApiAddr.LoginBackground,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // 渐变遮罩
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 标题
                  Positioned(
                    bottom: 60.h,
                    left: 24.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '消息中心',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 10,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Obx(() => Text(
                              '共 ${messageController.totalCount.value} 条消息',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 16.sp,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 5,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 主要内容区域
          SliverFillRemaining(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧消息类型选择器
                  Container(
                    width: 200.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '消息类型',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        ...messageTypes.map((messageType) {
                          final typeInfo =
                              messageController.getMessageTypeInfo(messageType);

                          return Obx(() {
                            final isSelected =
                                messageController.currentMessageType.value ==
                                    messageType;

                            return Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              child: InkWell(
                                onTap: () async {
                                  // 如果当前类型有未读消息，先标记为已读
                                  final unreadCount = messageController
                                      .getUnreadCountByType(messageType);
                                  if (unreadCount > 0) {
                                    await messageController.markAsRead(messageType);
                                  }
                                  
                                  // 切换消息类型
                                  messageController
                                      .switchMessageType(messageType);
                                },
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16.w, vertical: 12.h),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Colors.grey[300]!,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        typeInfo['icon'],
                                        size: 20.w,
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : typeInfo['color'],
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Text(
                                          typeInfo['title'],
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: isSelected
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                      // 未读数量标识
                                      if (messageController
                                              .getUnreadCountByType(
                                                  messageType) >
                                          0)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.w, vertical: 4.h),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                          ),
                                          child: Text(
                                            messageController
                                                        .getUnreadCountByType(
                                                            messageType) >
                                                    99
                                                ? '99+'
                                                : messageController
                                                    .getUnreadCountByType(
                                                        messageType)
                                                    .toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                        }).toList(),
                      ],
                    ),
                  ),

                  SizedBox(width: 24.w),

                  // 右侧消息列表区域
                  Expanded(
                    child: Obx(() => _buildMessageList(
                        messageController.currentMessageType.value)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(MessageTypeEnum messageType) {
    return Obx(() {
      if (messageController.isLoadingMessages.value &&
          messageController.messages.isEmpty) {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      }

      if (messageController.messages.isEmpty) {
        return _buildEmptyState(messageType);
      }

      return ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: messageController.messages.length +
            (messageController.isLoadingMessages.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= messageController.messages.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }

          final message = messageController.messages[index];
          return _buildMessageItem(message);
        },
      );
    });
  }

  Widget _buildEmptyState(MessageTypeEnum messageType) {
    final typeInfo = messageController.getMessageTypeInfo(messageType);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            typeInfo['icon'],
            size: 64.w,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无${typeInfo['title']}',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '当有新的${typeInfo['title']}时，会显示在这里',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(UserMessage message) {
    final messageType = MessageTypeEnum.values.firstWhere(
      (type) => type.type == message.messageType,
      orElse: () => MessageTypeEnum.SYS,
    );
    final typeInfo = messageController.getMessageTypeInfo(messageType);

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _handleMessageTap(message),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧头像或图标
              _buildMessageAvatar(message, messageType, typeInfo),
              SizedBox(width: 12.w),

              // 中间内容区域
              Expanded(
                child: _buildMessageContent(message, messageType),
              ),

              // 右侧视频封面
              if (message.videoCover.isNotEmpty) ...[
                SizedBox(width: 12.w),
                _buildVideoCover(message),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageContent(
      UserMessage message, MessageTypeEnum messageType) {
    switch (messageType) {
      case MessageTypeEnum.SYS:
        return _buildSystemMessageContent(message);
      case MessageTypeEnum.LIKE:
        return _buildLikeMessageContent(message);
      case MessageTypeEnum.COMMENT:
        return _buildCommentMessageContent(message);
      case MessageTypeEnum.COLLECT:
        return _buildCollectMessageContent(message);
    }
  }

  Widget _buildSystemMessageContent(UserMessage message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 消息标题和未读标识
        Row(
          children: [
            Expanded(
              child: Text(
                '系统消息',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight:
                      message.readType == 0 ? FontWeight.w600 : FontWeight.w500,
                  color:
                      message.readType == 0 ? Colors.black87 : Colors.grey[700],
                ),
              ),
            ),
            if (message.readType == 0)
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
          ],
        ),

        // 系统消息内容
        if (message.extendDto.messageContent.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            child: Text(
              message.extendDto.messageContent,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ),
        ],

        // 视频名称
        if (message.videoName.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Text(
            '视频：${message.videoName}',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        // 审核状态展示
        if (message.extendDto.auditStatus > 0) ...[
          SizedBox(height: 8.h),
          _buildAuditStatus(message.extendDto.auditStatus),
        ],

        SizedBox(height: 8.h),

        // 时间和删除按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatTime(message.createTime),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[500],
              ),
            ),
            TextButton.icon(
              onPressed: () => _showDeleteDialog(message),
              icon: Icon(
                Icons.delete,
                size: 14.w,
                color: Colors.grey[500],
              ),
              label: Text(
                '删除',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLikeMessageContent(UserMessage message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 消息标题和未读标识
        Row(
          children: [
            Expanded(
              child: Text(
                '点赞了',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight:
                      message.readType == 0 ? FontWeight.w600 : FontWeight.w500,
                  color:
                      message.readType == 0 ? Colors.black87 : Colors.grey[700],
                ),
              ),
            ),
            if (message.readType == 0)
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
          ],
        ),

        if (message.videoName.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            message.videoName,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        SizedBox(height: 8.h),

        // 时间和删除按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatTime(message.createTime),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[500],
              ),
            ),
            TextButton.icon(
              onPressed: () => _showDeleteDialog(message),
              icon: Icon(
                Icons.delete,
                size: 14.w,
                color: Colors.grey[500],
              ),
              label: Text(
                '删除',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentMessageContent(UserMessage message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 消息标题和未读标识
        Row(
          children: [
            Expanded(
              child: Text(
                '评论了',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight:
                      message.readType == 0 ? FontWeight.w600 : FontWeight.w500,
                  color:
                      message.readType == 0 ? Colors.black87 : Colors.grey[700],
                ),
              ),
            ),
            if (message.readType == 0)
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
          ],
        ),

        if (message.videoName.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            message.videoName,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        // 回复内容
        if (message.extendDto.messageReplyContent.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.green[200]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '回复：',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '"${message.extendDto.messageReplyContent}"',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],

        // 评论内容
        if (message.extendDto.messageContent.isNotEmpty) ...[
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.blue[200]!, width: 1),
            ),
            child: Text(
              '"${message.extendDto.messageContent}"',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
        ],

        SizedBox(height: 8.h),

        // 时间和删除按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatTime(message.createTime),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[500],
              ),
            ),
            TextButton.icon(
              onPressed: () => _showDeleteDialog(message),
              icon: Icon(
                Icons.delete,
                size: 14.w,
                color: Colors.grey[500],
              ),
              label: Text(
                '删除',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCollectMessageContent(UserMessage message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 消息标题和未读标识
        Row(
          children: [
            Expanded(
              child: Text(
                '收藏了',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight:
                      message.readType == 0 ? FontWeight.w600 : FontWeight.w500,
                  color:
                      message.readType == 0 ? Colors.black87 : Colors.grey[700],
                ),
              ),
            ),
            if (message.readType == 0)
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
          ],
        ),

        if (message.videoName.isNotEmpty) ...[
          SizedBox(height: 4.h),
          Text(
            message.videoName,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],

        SizedBox(height: 8.h),

        // 时间和删除按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatTime(message.createTime),
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[500],
              ),
            ),
            TextButton.icon(
              onPressed: () => _showDeleteDialog(message),
              icon: Icon(
                Icons.delete,
                size: 14.w,
                color: Colors.grey[500],
              ),
              label: Text(
                '删除',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[500],
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAuditStatus(int auditStatus) {
    final videoStatus = VideoStatusEnum.getByStatus(auditStatus);
    if (videoStatus == null) return SizedBox.shrink();

    Color statusColor;
    IconData statusIcon;

    switch (videoStatus) {
      case VideoStatusEnum.STATUS0: // 转码中
        statusColor = Colors.blue;
        statusIcon = Icons.hourglass_empty;
        break;
      case VideoStatusEnum.STATUS1: // 转码失败
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      case VideoStatusEnum.STATUS2: // 待审核
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
      case VideoStatusEnum.STATUS3: // 审核成功
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case VideoStatusEnum.STATUS4: // 审核不通过
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusIcon,
            size: 16.w,
            color: statusColor,
          ),
          SizedBox(width: 4.w),
          Text(
            videoStatus.desc,
            style: TextStyle(
              fontSize: 12.sp,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageAvatar(UserMessage message, MessageTypeEnum messageType,
      Map<String, dynamic> typeInfo) {
    // 如果是点赞、评论、收藏消息且有发送者头像，显示圆形头像
    if ((messageType == MessageTypeEnum.LIKE ||
        messageType == MessageTypeEnum.COMMENT ||
        messageType == MessageTypeEnum.COLLECT)) {
      return Avatar(
          avatarValue: message.sendUserAvatar,
          userId: message.userId,
          radius: 32.w);
    }

    // 默认显示消息类型图标
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: typeInfo['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Icon(
        typeInfo['icon'],
        size: 20.w,
        color: typeInfo['color'],
      ),
    );
  }

  Widget _buildVideoCover(UserMessage message) {
    return Container(
      width: 80.w,
      height: 60.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!, width: 0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: ExtendedImage.network(
          ApiService.baseUrl + ApiAddr.fileGetResourcet + message.videoCover,
          fit: BoxFit.cover,
          loadStateChanged: (state) {
            if (state.extendedImageLoadState == LoadState.failed) {
              return Container(
                color: Colors.grey[200],
                child: Icon(
                  Icons.video_library,
                  size: 24.w,
                  color: Colors.grey[400],
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  void _handleMessageTap(UserMessage message) {
    // 如果有视频ID，跳转到视频页面
    if (message.videoId.isNotEmpty) {
      Get.toNamed('${Routes.videoPlayPage}/${message.videoId}',
          id: Routes.mainGetId);
    }
  }

  void _showDeleteDialog(UserMessage message) {
    Get.dialog(
      AlertDialog(
        title: Text('删除消息'),
        content: Text('确定要删除这条消息吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              messageController.deleteMessage(message.messageId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text('删除'),
          ),
        ],
      ),
    );
  }
}
