class Constants {
  static const String baseUrl = 'http://39.105.203.95:7071';
  static const double dialogResizeRate = 0.75;
  static const double loginDialogResizeRate = 0.6;
  static const double loginDialogMinWidth = 590;
  static const double loginDialogMinHeight = 415;
  static const double updateUserInfoCardWidth = 350;
  static const double updateUserInfoCardHeight = 550;
  static const double uploadImageCardWidth = 450;
  static const double uploadImageCardHeight = 550;
  static const String REGEX_PASSWORD =
      "^(?![0-9]+\$)(?![a-zA-Z]+\$)[0-9A-Za-z]{6,18}\$";
  static const int errorMsgDuration = 2000; // 错误消息持续时间，单位毫秒
  static const String defaultAvatar = 'assets/images/user-avatar.png';
  static const String DISABLE_DANMU = "1"; // 禁用弹幕
  static const String DISABLE_COMMENT = "0"; // 禁用评论
  static const String Coin_svg =
      '<svg width="28" height="28" viewBox="0 0 28 28" xmlns="http://www.w3.org/2000/svg" class="video-coin-icon video-toolbar-item-icon" data-v-b72e4a72=""><path fill-rule="evenodd" clip-rule="evenodd" d="M14.045 25.5454C7.69377 25.5454 2.54504 20.3967 2.54504 14.0454C2.54504 7.69413 7.69377 2.54541 14.045 2.54541C20.3963 2.54541 25.545 7.69413 25.545 14.0454C25.545 17.0954 24.3334 20.0205 22.1768 22.1771C20.0201 24.3338 17.095 25.5454 14.045 25.5454ZM9.66202 6.81624H18.2761C18.825 6.81624 19.27 7.22183 19.27 7.72216C19.27 8.22248 18.825 8.62807 18.2761 8.62807H14.95V10.2903C17.989 10.4444 20.3766 12.9487 20.3855 15.9916V17.1995C20.3854 17.6997 19.9799 18.1052 19.4796 18.1052C18.9793 18.1052 18.5738 17.6997 18.5737 17.1995V15.9916C18.5667 13.9478 16.9882 12.2535 14.95 12.1022V20.5574C14.95 21.0577 14.5444 21.4633 14.0441 21.4633C13.5437 21.4633 13.1382 21.0577 13.1382 20.5574V12.1022C11.1 12.2535 9.52148 13.9478 9.51448 15.9916V17.1995C9.5144 17.6997 9.10883 18.1052 8.60856 18.1052C8.1083 18.1052 7.70273 17.6997 7.70265 17.1995V15.9916C7.71158 12.9487 10.0992 10.4444 13.1382 10.2903V8.62807H9.66202C9.11309 8.62807 8.66809 8.22248 8.66809 7.72216C8.66809 7.22183 9.11309 6.81624 9.66202 6.81624Z" fill="currentColor"></path></svg>';
}

class Routes {
  static const String heroTagAvatar = 'heroTagAvatar';
  static const String heroTagLoginPageEmail = 'heroTagLoginPageEmail';
  static const String heroTagLoginPagePassword = 'heroTagLoginPagePassword';
  static const String heroTagLoginPageCaptcha = 'heroTagLoginPageCaptcha';
  static const String heroTagLoginPageActionBtn = 'heroTagLoginPageActionBtn';
  static const String heroTagLoginPageSwitchBtn = 'heroTagLoginPageSwitchBtn';

  static const int mainGetId = 1000;
  static const int accountInfoDialogStateNavId = 1001;
  static const int loginPageNavId = 1002;
  static const int platformPageNavId = 1003;
  static const String loginPageLoginRouteName = '/loginPageLogin';
  static const String loginPageRegisterRouteName = '/loginPageRegister';
  static const String homePage = '/home';
  static const String loginPage = '/login';
  static const String platformPage = '/platform';
  static const String videoPlayPage = '/videoPlayPage';
}

class Texts {
  static String Texts_mode = "zh-CN";
  static String Texts_Default_mode = "zh-CN";
  static String get email =>
      texts[Texts_mode]["email"] ?? texts[Texts_Default_mode]["email"];
  static String get password =>
      texts[Texts_mode]["password"] ?? texts[Texts_Default_mode]["password"];
  static String get captcha =>
      texts[Texts_mode]["captcha"] ?? texts[Texts_Default_mode]["captcha"];
  static String get login =>
      texts[Texts_mode]["login"] ?? texts[Texts_Default_mode]["login"];
  static String get logout =>
      texts[Texts_mode]["logout"] ?? texts[Texts_Default_mode]["logout"];
  static String get register =>
      texts[Texts_mode]["register"] ?? texts[Texts_Default_mode]["register"];
  static String get forgotPassword =>
      texts[Texts_mode]["forgot_password"] ??
      texts[Texts_Default_mode]["forgot_password"];
  static String get welcomeBack =>
      texts[Texts_mode]["welcome_back"] ??
      texts[Texts_Default_mode]["welcome_back"];
  static String get decodeCaptchaFailed =>
      texts[Texts_mode]["decode_captcha_failed"] ??
      texts[Texts_Default_mode]["decode_captcha_failed"];
  static String get loadCaptchaFailed =>
      texts[Texts_mode]["load_captcha_failed"] ??
      texts[Texts_Default_mode]["load_captcha_failed"];
  static String get minimize =>
      texts[Texts_mode]["minimize"] ?? texts[Texts_Default_mode]["minimize"];
  static String get close =>
      texts[Texts_mode]["close"] ?? texts[Texts_Default_mode]["close"];
  static String get error =>
      texts[Texts_mode]["error"] ?? texts[Texts_Default_mode]["error"];
  static String get loginFailed =>
      texts[Texts_mode]["login_failed"] ??
      texts[Texts_Default_mode]["login_failed"];
  static String get emailFormatError =>
      texts[Texts_mode]["email_format_error"] ??
      texts[Texts_Default_mode]["email_format_error"];
  static String get passwordFormatError =>
      texts[Texts_mode]["password_format_error"] ??
      texts[Texts_Default_mode]["password_format_error"];
  static String get passwordHelperText =>
      texts[Texts_mode]["password_helperText"] ??
      texts[Texts_Default_mode]["password_helperText"];
  static String get unLogin =>
      texts[Texts_mode]["unLogin"] ?? texts[Texts_Default_mode]["unLogin"];
  static String get focus =>
      texts[Texts_mode]["focus"] ?? texts[Texts_Default_mode]["focus"];
  static String get fans =>
      texts[Texts_mode]["fans"] ?? texts[Texts_Default_mode]["fans"];
  static String get coin =>
      texts[Texts_mode]["coin"] ?? texts[Texts_Default_mode]["coin"];
  static String get success =>
      texts[Texts_mode]["success"] ?? texts[Texts_Default_mode]["success"];
  static String get userName =>
      texts[Texts_mode]["user_name"] ?? texts[Texts_Default_mode]["user_name"];
  static String get toRegister =>
      texts[Texts_mode]["to_register"] ??
      texts[Texts_Default_mode]["to_register"];
  static String get toLogin =>
      texts[Texts_mode]["to_login"] ?? texts[Texts_Default_mode]["to_login"];
  static String get userNameHelperText =>
      texts[Texts_mode]["userName_helperText"] ??
      texts[Texts_Default_mode]["userName_helperText"];
  static String get registerSuccess =>
      texts[Texts_mode]["register_success"] ??
      texts[Texts_Default_mode]["register_success"];
  static String get captchaRequired =>
      texts[Texts_mode]["captchaRequired"] ??
      texts[Texts_Default_mode]["captchaRequired"];
  static String get getUserInfoFailed =>
      texts[Texts_mode]["getUserInfoFailed"] ??
      texts[Texts_Default_mode]["getUserInfoFailed"];
  static String get updateUserInfo =>
      texts[Texts_mode]["updateUserInfo"] ??
      texts[Texts_Default_mode]["updateUserInfo"];
  static String get personIntroduction =>
      texts[Texts_mode]["personIntroduction"] ??
      texts[Texts_Default_mode]["personIntroduction"];
  static String get noticeInfo =>
      texts[Texts_mode]["noticeInfo"] ??
      texts[Texts_Default_mode]["noticeInfo"];
  static String get school =>
      texts[Texts_mode]["school"] ?? texts[Texts_Default_mode]["school"];
  static String get updateFailed =>
      texts[Texts_mode]["updateFailed"] ??
      texts[Texts_Default_mode]["updateFailed"];
  static String get update =>
      texts[Texts_mode]["update"] ?? texts[Texts_Default_mode]["update"];
  static String get noImageSelected =>
      texts[Texts_mode]["noImageSelected"] ??
      texts[Texts_Default_mode]["noImageSelected"];
  static String get selectImage =>
      texts[Texts_mode]["selectImage"] ??
      texts[Texts_Default_mode]["selectImage"];
  static String get reset =>
      texts[Texts_mode]["reset"] ?? texts[Texts_Default_mode]["reset"];
  static String get enter =>
      texts[Texts_mode]["enter"] ?? texts[Texts_Default_mode]["enter"];
  static String get unLimit =>
      texts[Texts_mode]["unLimit"] ?? texts[Texts_Default_mode]["unLimit"];
  static String get originalRatio =>
      texts[Texts_mode]["originalRatio"] ??
      texts[Texts_Default_mode]["originalRatio"];
  static String get imageProcessingError =>
      texts[Texts_mode]["imageProcessingError"] ??
      texts[Texts_Default_mode]["imageProcessingError"];
  static String get changeAvatar =>
      texts[Texts_mode]["changeAvatar"] ??
      texts[Texts_Default_mode]["changeAvatar"];
  static Map<String, dynamic> get texts => {
        "zh-CN": {
          "email": "邮箱",
          "password": "密码",
          "captcha": "验证码",
          "login": "登录",
          "logout": "退出登录",
          "register": "注册",
          "forgot_password": "忘记密码？",
          "welcome_back": "欢迎回来！",
          "decode_captcha_failed": "验证码解析失败",
          "load_captcha_failed": "验证码加载失败",
          'minimize': '最小化',
          'close': '关闭',
          'error': '错误',
          'login_failed': '登录失败',
          'email_format_error': '请输入正确的邮箱格式',
          'password_format_error': '密码格式不正确',
          'password_helperText': '6-18位字母和数字组合，不能全为字母或数字',
          'unLogin': '未登录',
          // 关注、粉丝、硬币
          'focus': '关注',
          'fans': '粉丝',
          'coin': '硬币',
          'success': '成功',
          'user_name': '用户名',
          'to_register': '还没有账号？去注册',
          'to_login': '已有账号？去登录',
          'userName_helperText': '最长20个字符',
          'register_success': '注册成功,请登录',
          'captchaRequired': '验证码不能为空',
          'getUserInfoFailed': '获取用户信息失败',
          'updateUserInfo': '更新用户信息',
          'personIntroduction': '个人介绍',
          'noticeInfo': '空间公告',
          'school': '学校',
          'updateFailed': '更新失败',
          'update': '更新',
          'noImageSelected': '未选择图片',
          'selectImage': '选择图片',
          'reset': '重置',
          'enter': '确定',
          'unLimit': '无限制',
          'originalRatio': '原图比例',
          'imageProcessingError': '图片处理错误',
          'changeAvatar': '更换头像',
        },
        "en-US": {
          "email": "Email",
          "password": "Password",
          "captcha": "Captcha",
          "login": "Login",
          "logout": "Logout",
          "register": "Register",
          "forgot_password": "Forgot password?",
          "welcome_back": "Welcome back!",
          "decode_captcha_failed": "Failed to decode captcha",
          "load_captcha_failed": "Failed to load captcha",
          'minimize': 'Minimize',
          'close': 'Close',
        },
      };
}
