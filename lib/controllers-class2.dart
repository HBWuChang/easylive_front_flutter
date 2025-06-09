import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'Funcs.dart';

class UserInfo {
  String? userId;
  String? nickName;
  String? avatar;
  int? sex;
  String? personIntroduction;
  String? noticeInfo;
  int? grade;
  String? birthday;
  String? school;
  int? fansCount;
  int? focusCount;
  int? likeCount;
  int? playCount;
  bool haveFocus = false;
  String? theme;
  UserInfo(Map<String, dynamic> json) {
    userId = json['userId'];
    nickName = json['nickName'];
    avatar = json['avatar'];
    sex = json['sex'];
    personIntroduction = json['personIntroduction'];
    noticeInfo = json['noticeInfo'];
    grade = json['grade'];
    birthday = json['birthday'];
    school = json['school'];
    fansCount = json['fansCount'];
    focusCount = json['focusCount'];
    likeCount = json['likeCount'];
    playCount = json['playCount'];
    haveFocus = json['haveFocus'] ?? false;
    theme = json['theme'];
  }
}
