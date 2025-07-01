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
    likeCount = json['likeCount'] ?? 0;
    hateCount = json['hateCount'] ?? 0;
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

class VideoDanmu {
  // public class VideoDanmu implements Serializable {

  // /**
  //  * 自增ID
  //  */
  // private Integer danmuId;

  // /**
  //  * 视频ID
  //  */
  // private String videoId;

  // /**
  //  * 文件唯一ID
  //  */
  // private String fileId;

  // /**
  //  * 用户ID
  //  */
  // private String userId;

  // /**
  //  * 发布时间
  //  */
  // @JsonFormat(pattern = "yyyy-MM-dd HH:mm:ss", timezone = "GMT+8")
  // @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
  // private Date postTime;

  // /**
  //  * 内容
  //  */
  // private String text;

  // /**
  //  * 展示位置
  //  */
  // private Integer mode;

  // /**
  //  * 颜色
  //  */
  // private String color;

  // /**
  //  * 展示时间
  //  */
  // private Integer time;
  // private String videoName;
  // private String videoCover;
  // private String nickName;

  int danmuId = 0;
  String videoId = '';
  String fileId = '';
  String userId = '';
  DateTime postTime = DateTime.now();
  String text = '';
  int mode = 0; // Assuming mode is an integer
  String color = '';
  int time = 0;
  String? videoName = '';
  String? videoCover = '';
  String? nickName = '';
//  {
//       "danmuId": 1,
//       "videoId": "1Gm6o77fPt",
//       "fileId": "9jW8ebZVH7nXrZHWeJKx",
//       "userId": "0636309642",
//       "postTime": "2025-05-12 11:20:33",
//       "text": "测试弹幕123",
//       "mode": 0,
//       "color": "#66ccff",
//       "time": 12
//     }
  VideoDanmu(Map<String, dynamic> json) {
    danmuId = json['danmuId'] ?? 0;
    videoId = json['videoId'] ?? '';
    fileId = json['fileId'] ?? '';
    userId = json['userId'] ?? '';
    postTime =
        DateTime.parse(json['postTime'] ?? DateTime.now().toIso8601String());
    text = json['text'] ?? '';
    mode = json['mode'] ?? 0;
    color = json['color'] ?? '';
    time = json['time'] ?? 0;
    videoName = json['videoName'];
    videoCover = json['videoCover'];
    nickName = json['nickName'];
  }
}
class UserInfo {
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
  
  String? userId;
  String? nickName;
  String? email;
  String? avatar;
  int? sex; // 0女 1男 2未知
  String? personIntroduction;
  String? noticeInfo;
  String? grade;
  String? birthday;
  String? school;
  int? fansCount;
  int? focusCount;
  int? likeCount;
  int? playCount;
  bool? haveFocus;
  String? theme;
  DateTime? joinTime;
  DateTime? lastLoginTime;
  String? lastLoginIp;
  int? status; // 0禁用 1正常
  int? totalCoinCount;
  int? currentCoinCount;

  UserInfo(Map<String, dynamic> json) {
    userId = json['userId'];
    nickName = json['nickName'];
    email = json['email'];
    avatar = json['avatar'];
    sex = json['sex'];
    personIntroduction = json['personIntroduction'];
    noticeInfo = json['noticeInfo'];
    grade = json['grade'];
    birthday = json['birthday'];
    school = json['school'];
    fansCount = json['fansCount'] ?? 0;
    focusCount = json['focusCount'] ?? 0;
    likeCount = json['likeCount'] ?? 0;
    playCount = json['playCount'] ?? 0;
    haveFocus = json['haveFocus'] ?? false;
    theme = json['theme'];
    joinTime = json['joinTime'] != null ? DateTime.tryParse(json['joinTime']) : null;
    lastLoginTime = json['lastLoginTime'] != null ? DateTime.tryParse(json['lastLoginTime']) : null;
    lastLoginIp = json['lastLoginIp'];
    status = json['status'];
    totalCoinCount = json['totalCoinCount'];
    currentCoinCount = json['currentCoinCount'];
  }

  String getSexText() {
    switch (sex) {
      case 0:
        return '女';
      case 1:
        return '男';
      case 2:
        return '未知';
      default:
        return '未知';
    }
  }

  String getStatusText() {
    switch (status) {
      case 0:
        return '禁用';
      case 1:
        return '正常';
      default:
        return '未知';
    }
  }
}

class UserInfoQuery {
  String? userId;
  String? userIdFuzzy;
  String? nickName;
  String? nickNameFuzzy;
  String? email;
  String? emailFuzzy;
  String? password;
  String? passwordFuzzy;
  int? sex; // 0女 1男 2未知
  String? birthday;
  String? birthdayFuzzy;
  String? school;
  String? schoolFuzzy;
  String? personIntroduction;
  String? personIntroductionFuzzy;
  String? joinTime;
  String? joinTimeStart;
  String? joinTimeEnd;
  String? lastLoginTime;
  String? lastLoginTimeStart;
  String? lastLoginTimeEnd;
  String? lastLoginIp;
  String? lastLoginIpFuzzy;
  int? status; // 0禁用 1正常
  String? noticeInfo;
  String? noticeInfoFuzzy;
  int? totalCoinCount;
  int? currentCoinCount;
  String? theme;
  String? themeFuzzy;
  String? avatar;
  String? avatarFuzzy;
  List<String>? userIdList;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    if (userId != null && userId!.isNotEmpty) json['userId'] = userId;
    if (userIdFuzzy != null && userIdFuzzy!.isNotEmpty) json['userIdFuzzy'] = userIdFuzzy;
    if (nickName != null && nickName!.isNotEmpty) json['nickName'] = nickName;
    if (nickNameFuzzy != null && nickNameFuzzy!.isNotEmpty) json['nickNameFuzzy'] = nickNameFuzzy;
    if (email != null && email!.isNotEmpty) json['email'] = email;
    if (emailFuzzy != null && emailFuzzy!.isNotEmpty) json['emailFuzzy'] = emailFuzzy;
    if (password != null && password!.isNotEmpty) json['password'] = password;
    if (passwordFuzzy != null && passwordFuzzy!.isNotEmpty) json['passwordFuzzy'] = passwordFuzzy;
    if (sex != null) json['sex'] = sex;
    if (birthday != null && birthday!.isNotEmpty) json['birthday'] = birthday;
    if (birthdayFuzzy != null && birthdayFuzzy!.isNotEmpty) json['birthdayFuzzy'] = birthdayFuzzy;
    if (school != null && school!.isNotEmpty) json['school'] = school;
    if (schoolFuzzy != null && schoolFuzzy!.isNotEmpty) json['schoolFuzzy'] = schoolFuzzy;
    if (personIntroduction != null && personIntroduction!.isNotEmpty) json['personIntroduction'] = personIntroduction;
    if (personIntroductionFuzzy != null && personIntroductionFuzzy!.isNotEmpty) json['personIntroductionFuzzy'] = personIntroductionFuzzy;
    if (joinTime != null && joinTime!.isNotEmpty) json['joinTime'] = joinTime;
    if (joinTimeStart != null && joinTimeStart!.isNotEmpty) json['joinTimeStart'] = joinTimeStart;
    if (joinTimeEnd != null && joinTimeEnd!.isNotEmpty) json['joinTimeEnd'] = joinTimeEnd;
    if (lastLoginTime != null && lastLoginTime!.isNotEmpty) json['lastLoginTime'] = lastLoginTime;
    if (lastLoginTimeStart != null && lastLoginTimeStart!.isNotEmpty) json['lastLoginTimeStart'] = lastLoginTimeStart;
    if (lastLoginTimeEnd != null && lastLoginTimeEnd!.isNotEmpty) json['lastLoginTimeEnd'] = lastLoginTimeEnd;
    if (lastLoginIp != null && lastLoginIp!.isNotEmpty) json['lastLoginIp'] = lastLoginIp;
    if (lastLoginIpFuzzy != null && lastLoginIpFuzzy!.isNotEmpty) json['lastLoginIpFuzzy'] = lastLoginIpFuzzy;
    if (status != null) json['status'] = status;
    if (noticeInfo != null && noticeInfo!.isNotEmpty) json['noticeInfo'] = noticeInfo;
    if (noticeInfoFuzzy != null && noticeInfoFuzzy!.isNotEmpty) json['noticeInfoFuzzy'] = noticeInfoFuzzy;
    if (totalCoinCount != null) json['totalCoinCount'] = totalCoinCount;
    if (currentCoinCount != null) json['currentCoinCount'] = currentCoinCount;
    if (theme != null && theme!.isNotEmpty) json['theme'] = theme;
    if (themeFuzzy != null && themeFuzzy!.isNotEmpty) json['themeFuzzy'] = themeFuzzy;
    if (avatar != null && avatar!.isNotEmpty) json['avatar'] = avatar;
    if (avatarFuzzy != null && avatarFuzzy!.isNotEmpty) json['avatarFuzzy'] = avatarFuzzy;
    if (userIdList != null && userIdList!.isNotEmpty) json['userIdList'] = userIdList;
    return json;
  }
}
class SysSettingDto {
  // 注册奖励硬币数
  int registerCoinCount;
  // 发布视频奖励硬币数
  int postVideoCoinCount;
  // 视频大小限制(MB)
  int videoSize;
  // 视频P数限制
  int videoPcount;
  // 视频数量限制
  int videoCount;
  // 评论数量限制
  int commentCount;
  // 弹幕数量限制
  int danmuCount;

  SysSettingDto({
    this.registerCoinCount = 10,
    this.postVideoCoinCount = 5,
    this.videoSize = 100,
    this.videoPcount = 10,
    this.videoCount = 10,
    this.commentCount = 20,
    this.danmuCount = 20,
  });

  SysSettingDto.fromJson(Map<String, dynamic> json)
      : registerCoinCount = json['registerCoinCount'] ?? 10,
        postVideoCoinCount = json['postVideoCoinCount'] ?? 5,
        videoSize = json['videoSize'] ?? 100,
        videoPcount = json['videoPcount'] ?? 10,
        videoCount = json['videoCount'] ?? 10,
        commentCount = json['commentCount'] ?? 20,
        danmuCount = json['danmuCount'] ?? 20;

  Map<String, dynamic> toJson() {
    return {
      'registerCoinCount': registerCoinCount,
      'postVideoCoinCount': postVideoCoinCount,
      'videoSize': videoSize,
      'videoPcount': videoPcount,
      'videoCount': videoCount,
      'commentCount': commentCount,
      'danmuCount': danmuCount,
    };
  }
}
class GetActualTimeStatisticsInfo {
  TotalCountInfo totalCountInfo;
  PreDayData preDayData;

  GetActualTimeStatisticsInfo({
    required this.totalCountInfo,
    required this.preDayData,
  });

  GetActualTimeStatisticsInfo.fromJson(Map<String, dynamic> json)
      : totalCountInfo = TotalCountInfo.fromJson(json['totalCountInfo'] ?? {}),
        preDayData = PreDayData.fromJson(json['preDayData'] ?? {});

  Map<String, dynamic> toJson() {
    return {
      'totalCountInfo': totalCountInfo.toJson(),
      'preDayData': preDayData.toJson(),
    };
  }
}

class TotalCountInfo {
  // 播放数量
  int playCount;
  // 弹幕数量  
  int danmuCount;
  // 用户数量
  int userCount;
  // 收藏数量
  int collectCount;
  // 点赞数量
  int likeCount;
  // 硬币数量
  int coinCount;
  // 评论数量
  int commentCount;

  TotalCountInfo({
    this.playCount = 0,
    this.danmuCount = 0,
    this.userCount = 0,
    this.collectCount = 0,
    this.likeCount = 0,
    this.coinCount = 0,
    this.commentCount = 0,
  });

  TotalCountInfo.fromJson(Map<String, dynamic> json)
      : playCount = json['playCount'] ?? 0,
        danmuCount = json['danmuCount'] ?? 0,
        userCount = json['userCount'] ?? 0,
        collectCount = json['collectCount'] ?? 0,
        likeCount = json['likeCount'] ?? 0,
        coinCount = json['coinCount'] ?? 0,
        commentCount = json['commentCount'] ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'playCount': playCount,
      'danmuCount': danmuCount,
      'userCount': userCount,
      'collectCount': collectCount,
      'likeCount': likeCount,
      'coinCount': coinCount,
      'commentCount': commentCount,
    };
  }
}

class PreDayData {
  // 前一天的统计数据，key为StatisticsTypeEnum的值，value为对应的数量
  Map<String, int> data;

  PreDayData({
    this.data = const {},
  });

  PreDayData.fromJson(Map<String, dynamic> json)
      : data = Map<String, int>.from(json.map((key, value) => MapEntry(key.toString(), value as int? ?? 0)));

  Map<String, dynamic> toJson() {
    return data;
  }

  // 获取特定类型的统计数据
  int getCount(String type) {
    return data[type] ?? 0;
  }

  // 获取所有统计数据条目，并转换为可读的类型名称
  List<MapEntry<String, int>> getEntries() {
    return data.entries.map((entry) {
      int typeInt = int.tryParse(entry.key) ?? -1;
      String typeName = '';
      switch (typeInt) {
        case 0:
          typeName = '播放量';
          break;
        case 1:
          typeName = '粉丝数';
          break;
        case 2:
          typeName = '点赞数';
          break;
        case 3:
          typeName = '收藏数';
          break;
        case 4:
          typeName = '硬币数';
          break;
        case 5:
          typeName = '评论数';
          break;
        case 6:
          typeName = '弹幕数';
          break;
        default:
          typeName = '未知类型';
      }
      return MapEntry(typeName, entry.value);
    }).toList();
  }

  // 根据类型获取类型名称
  String getTypeName(String type) {
    int typeInt = int.tryParse(type) ?? -1;
    switch (typeInt) {
      case 0:
        return '播放量';
      case 1:
        return '粉丝数';
      case 2:
        return '点赞数';
      case 3:
        return '收藏数';
      case 4:
        return '硬币数';
      case 5:
        return '评论数';
      case 6:
        return '弹幕数';
      default:
        return '未知类型';
    }
  }
}
class GetWeekStatisticsInfo {
  List<StatisticsInfo> data;

  GetWeekStatisticsInfo({
    this.data = const [],
  });

  GetWeekStatisticsInfo.fromJson(List<dynamic> json)
      : data = json.map((item) => StatisticsInfo.fromJson(item)).toList();

  List<Map<String, dynamic>> toJson() {
    return data.map((item) => item.toJson()).toList();
  }

  // 按日期分组统计数据
  Map<String, List<StatisticsInfo>> groupByDate() {
    Map<String, List<StatisticsInfo>> grouped = {};
    for (var item in data) {
      if (!grouped.containsKey(item.statisticsDate)) {
        grouped[item.statisticsDate] = [];
      }
      grouped[item.statisticsDate]!.add(item);
    }
    return grouped;
  }

  // 按数据类型过滤
  List<StatisticsInfo> filterByType(int dataType) {
    return data.where((item) => item.dataType == dataType).toList();
  }
}

class StatisticsInfo {
  String statisticsDate;
  String userId; // 暂时不显示
  int dataType;
  int statisticsCount;

  StatisticsInfo({
    required this.statisticsDate,
    required this.userId,
    required this.dataType,
    required this.statisticsCount,
  });

  StatisticsInfo.fromJson(Map<String, dynamic> json)
      : statisticsDate = json['statisticsDate'] ?? '',
        userId = json['userId'] ?? '',
        dataType = json['dataType'] ?? 0,
        statisticsCount = json['statisticsCount'] ?? 0;

  Map<String, dynamic> toJson() {
    return {
      'statisticsDate': statisticsDate,
      'userId': userId,
      'dataType': dataType,
      'statisticsCount': statisticsCount,
    };
  }

  // 获取数据类型描述
  String getDataTypeDesc() {
    switch (dataType) {
      case 0:
        return '播放量';
      case 1:
        return '粉丝数';
      case 2:
        return '点赞数';
      case 3:
        return '收藏数';
      case 4:
        return '硬币数';
      case 5:
        return '评论数';
      case 6:
        return '弹幕数';
      default:
        return '未知';
    }
  }
}