class Constants {
  static const String baseUrl = 'http://127.0.0.1:7071';
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
}

class Routes {
  static const String heroTagAvatar = 'heroTagAvatar';
  static const String heroTagLoginPageEmail = 'heroTagLoginPageEmail';
  static const String heroTagLoginPagePassword = 'heroTagLoginPagePassword';
  static const String heroTagLoginPageCaptcha = 'heroTagLoginPageCaptcha';
  static const String heroTagLoginPageActionBtn = 'heroTagLoginPageActionBtn';
  static const String heroTagLoginPageSwitchBtn = 'heroTagLoginPageSwitchBtn';

  static const int accountInfoDialogStateNavId = 1001;
  static const int loginPageNavId = 1002;
  static const String loginPageLoginRouteName = '/loginPageLogin';
  static const String loginPageRegisterRouteName = '/loginPageRegister';
  static const String homePage = '/home';
  static const String loginPage = '/login';
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
