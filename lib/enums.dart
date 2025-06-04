// ignore_for_file: constant_identifier_names

enum CommentTopTypeEnum {
  NO_TOP(0, "未置顶"),
  TOP(1, "已置顶");

  final int type;
  final String desc;

  const CommentTopTypeEnum(this.type, this.desc);

  static CommentTopTypeEnum? getByType(int type) {
    for (var actionType in CommentTopTypeEnum.values) {
      if (actionType.type == type) {
        return actionType;
      }
    }
    return null;
  }
}

enum MessageReadTypeEnum {
  UNREAD(0, "未读"),
  READ(1, "已读");

  final int type;
  final String desc;

  const MessageReadTypeEnum(this.type, this.desc);

  static MessageReadTypeEnum? getByType(int type) {
    for (var actionType in MessageReadTypeEnum.values) {
      if (actionType.type == type) {
        return actionType;
      }
    }
    return null;
  }
}

enum MessageTypeEnum {
  SYS(1, "系统消息"),
  LIKE(2, "点赞"),
  COLLECT(3, "收藏"),
  COMMENT(4, "评论");

  final int type;
  final String desc;

  const MessageTypeEnum(this.type, this.desc);

  static MessageTypeEnum? getByType(int type) {
    for (var actionType in MessageTypeEnum.values) {
      if (actionType.type == type) {
        return actionType;
      }
    }
    return null;
  }
}

enum SearchOrderTypeEnum {
  VIDEO_PLAY(0, "playCount", "视频播放数"),
  VIDEO_TIME(1, "createTime", "视频时间"),
  VIDEO_DANMU(2, "danmuCount", "视频弹幕数"),
  VIDEO_COLLECT(3, "collectCount", "视频收藏");

  final int type;
  final String field;
  final String desc;

  const SearchOrderTypeEnum(this.type, this.field, this.desc);

  static SearchOrderTypeEnum? getByType(int type) {
    for (var actionType in SearchOrderTypeEnum.values) {
      if (actionType.type == type) {
        return actionType;
      }
    }
    return null;
  }
}

enum StatisticsTypeEnum {
  PLAY(0, "播放量"),
  FANS(1, "粉丝数"),
  LIKE(2, "点赞数"),
  COLLECT(3, "收藏数"),
  COIN(4, "硬币数"),
  COMMENT(5, "评论数"),
  DANMU(6, "弹幕数");

  final int type;
  final String desc;

  const StatisticsTypeEnum(this.type, this.desc);

  static StatisticsTypeEnum? getByType(int type) {
    for (var actionType in StatisticsTypeEnum.values) {
      if (actionType.type == type) {
        return actionType;
      }
    }
    return null;
  }
}

enum UserActionTypeEnum {
  COMMENT_LIKE(0, "like_count", "评论点赞"),
  COMMENT_HATE(1, "hate_count", "评论点踩"),
  VIDEO_LIKE(2, "like_count", "视频点赞"),
  VIDEO_COLLECT(3, "collect_count", "视频收藏"),
  VIDEO_COIN(4, "coin_count", "视频投币数"),
  VIDEO_COMMENT(5, "comment_count", "视频评论数"),
  VIDEO_DANMU(6, "danmu_count", "视频弹幕数"),
  VIDEO_PLAY(7, "play_count", "视频播放数");

  final int type;
  final String field;
  final String desc;

  const UserActionTypeEnum(this.type, this.field, this.desc);

  static UserActionTypeEnum? getByType(int type) {
    for (var actionType in UserActionTypeEnum.values) {
      if (actionType.type == type) {
        return actionType;
      }
    }
    return null;
  }
}

enum UserSexEnum {
  WOMAN(0, "女"),
  MAN(1, "男"),
  SECRECY(2, "保密");

  final int type;
  final String desc;

  const UserSexEnum(this.type, this.desc);

  static UserSexEnum? getByType(int type) {
    for (var sexType in UserSexEnum.values) {
      if (sexType.type == type) {
        return sexType;
      }
    }
    return null;
  }
}

enum UserStatusEnum {
  DISABLE(0, "禁用"),
  ENABLE(1, "启用");

  final int status;
  final String desc;

  const UserStatusEnum(this.status, this.desc);

  static UserStatusEnum? getByStatus(int status) {
    for (var userStatus in UserStatusEnum.values) {
      if (userStatus.status == status) {
        return userStatus;
      }
    }
    return null;
  }
}

enum VideoOrderTypeEnum {
  CREATE_TIME(0, "create_time", "最新发布"),
  PLAY_COUNT(1, "play_count", "最多播放"),
  COLLECT_COUNT(2, "collect_count", "最多收藏");

  final int type;
  final String field;
  final String desc;

  const VideoOrderTypeEnum(this.type, this.field, this.desc);

  static VideoOrderTypeEnum? getByType(int type) {
    for (var orderType in VideoOrderTypeEnum.values) {
      if (orderType.type == type) {
        return orderType;
      }
    }
    return null;
  }
}

// String DISABLE_DANMU = "1"; // 禁用弹幕
//     String DISABLE_COMMENT = "0"; // 禁用评论
enum InteractionTypeEnum {
  NONE('', '不设置'),
  DISABLE_DANMU('1', '禁用弹幕'),
  DISABLE_COMMENT('0', '禁用评论'),
  DISABLE_DANMU_COMMENT('0,1', '禁用弹幕和评论');

  final String type;
  final String desc;
  const InteractionTypeEnum(this.type, this.desc);
  static InteractionTypeEnum? getByType(String type) {
    for (var interactionType in InteractionTypeEnum.values) {
      if (interactionType.type == type) {
        return interactionType;
      }
    }
    return null;
  }
}

enum VideoStatusEnum {
  STATUS0(0, "转码中"),
  STATUS1(1, "转码失败"),
  STATUS2(2, "待审核"),
  STATUS3(3, "审核成功"),
  STATUS4(4, "审核不通过");

  final int status;
  final String desc;

  const VideoStatusEnum(this.status, this.desc);

  static VideoStatusEnum? getByStatus(int status) {
    for (var videoStatus in VideoStatusEnum.values) {
      if (videoStatus.status == status) {
        return videoStatus;
      }
    }
    return null;
  }
}

enum CropAspectRatioEnum {
  VIDEO_COVER('cover', 16 / 9);

  final String type;
  final double ratio;
  const CropAspectRatioEnum(this.type, this.ratio);
}
