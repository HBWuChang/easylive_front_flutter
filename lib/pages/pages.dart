import 'package:easylive/Funcs.dart';
import 'package:easylive/settings.dart';
import 'package:easylive/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import '../controllers/controllers-class.dart';
import '../api_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginPage extends StatefulWidget {
  final double? areaWidth;
  final double? areaHeight;
  const LoginPage({Key? key, this.areaWidth, this.areaHeight})
      : super(key: key);
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LoginController loginController = Get.find<LoginController>();
  final AccountController accountController = Get.find<AccountController>();
  late TextEditingController emailController;
  late TextEditingController nickNameController;
  late TextEditingController passwordController;
  late TextEditingController captchaController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: loginController.email.value);
    nickNameController = TextEditingController();
    passwordController = TextEditingController();
    captchaController = TextEditingController();
    loginController.freshCaptcha();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    captchaController.dispose();
    super.dispose();
  }

  void checkValid() {
    final email = emailController.text;
    final password = passwordController.text;
    final regex = RegExp(Constants.REGEX_PASSWORD);
    final emailRegex =
        RegExp('^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\$');
    if (!emailRegex.hasMatch(email)) throw Exception(Texts.emailFormatError);

    if (!regex.hasMatch(password)) {
      throw Exception(Texts.passwordFormatError);
    }
    if (captchaController.text.isEmpty) {
      throw Exception(Texts.captchaRequired);
    }
  }

  void tryLogin() async {
    try {
      checkValid();
      var ret = await ApiService.accountLogin(
        email: emailController.text,
        password: passwordController.text,
        checkCodeKey: loginController.checkCodeKey.value,
        checkCode: captchaController.text,
      );
      print('登录结果: \\${ret}');
      if (ret['code'] != 200) {
        loginController.freshCaptcha();
        throw Exception(ret['info'] ?? Texts.loginFailed);
      } else {
        loginController.email.value = emailController.text;
        await accountController.saveAccountInfo(ret['data']);
        Get.back();
        Get.closeAllSnackbars();
        Get.snackbar(
          Texts.welcomeBack,
          '${ret['data']['nickName'] ?? emailController.text}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(milliseconds: Constants.errorMsgDuration),
          instantInit: true,
        );
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }

  void tryRegister() async {
    try {
      checkValid();
      if (nickNameController.text.isEmpty ||
          nickNameController.text.length > 20)
        throw Exception(Texts.userNameHelperText);

      var ret = await ApiService.accountRegister(
        email: emailController.text,
        nickName: nickNameController.text,
        password: passwordController.text,
        checkCodeKey: loginController.checkCodeKey.value,
        checkCode: captchaController.text,
      );
      if (ret['code'] != 200) {
        loginController.freshCaptcha();
        throw Exception(ret['info'] ?? Texts.loginFailed);
      } else {
        Get.back(id: Routes.loginPageNavId);
        loginController.freshCaptcha();
        Get.closeAllSnackbars();
        Get.snackbar(
          Texts.success,
          Texts.registerSuccess,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
          duration: Duration(milliseconds: Constants.errorMsgDuration),
          instantInit: true,
        );
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final double formWidth = widget.areaWidth ?? context.width;
    return Scaffold(
      body: Stack(
        children: [
          // 背景网络图片
          Positioned.fill(
            child: ExtendedImage.network(
              ApiService.baseUrl +
                  ApiAddr.fileGetResourcet +
                  ApiAddr.LoginBackGround,
              fit: BoxFit.cover,
            ),
          ),
          // 登录表单内容
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                SizedBox(
                  width: (formWidth / 2 - 16).w,
                ),
                SizedBox(
                    width: (formWidth / 2 - 16).w,
                    child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.w),
                        child: Card(
                            color: const Color.fromARGB(131, 255, 255, 255),
                            child: Padding(
                                padding: EdgeInsets.all(16.w),
                                child: HeroControllerScope(
                                    controller: MaterialApp
                                        .createMaterialHeroController(),
                                    child: Navigator(
                                        key: Get.nestedKey(
                                            Routes.loginPageNavId),
                                        initialRoute:
                                            Routes.loginPageLoginRouteName,
                                        onGenerateRoute: (settings) {
                                          if (settings.name ==
                                              Routes.loginPageLoginRouteName) {
                                            return PageRouteBuilder(
                                              opaque: false,
                                              barrierColor: Colors.transparent,
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  SingleChildScrollView(
                                                      child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Hero(
                                                          tag: Routes
                                                              .heroTagLoginPageSwitchBtn,
                                                          child: Tooltip(
                                                              message: Texts
                                                                  .toRegister,
                                                              child: TextButton
                                                                  .icon(
                                                                      onPressed:
                                                                          () =>
                                                                              Get
                                                                                  .toNamed(
                                                                                Routes.loginPageRegisterRouteName,
                                                                                id: Routes.loginPageNavId,
                                                                              ),
                                                                      label: Text(
                                                                          Texts
                                                                              .register),
                                                                      icon:
                                                                          Icon(
                                                                        Icons
                                                                            .app_registration,
                                                                        size: 16
                                                                            .sp,
                                                                      )))),
                                                    ],
                                                  ),
                                                  Hero(
                                                      tag: Routes
                                                          .heroTagLoginPageEmail,
                                                      child: TextField(
                                                        controller:
                                                            emailController,
                                                        decoration:
                                                            InputDecoration(
                                                                labelText: Texts
                                                                    .email),
                                                        onChanged: (value) =>
                                                            loginController
                                                                .email
                                                                .value = value,
                                                        onSubmitted: (value) =>
                                                            tryLogin(),
                                                      )),
                                                  SizedBox(height: 16.w),
                                                  Hero(
                                                      tag: Routes
                                                          .heroTagLoginPagePassword,
                                                      child: TextField(
                                                        controller:
                                                            passwordController,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              Texts.password,
                                                          helperText: Texts
                                                              .passwordHelperText,
                                                        ),
                                                        obscureText: true,
                                                        onSubmitted: (value) =>
                                                            tryLogin(),
                                                      )),
                                                  SizedBox(height: 16.w),
                                                  Hero(
                                                      tag: Routes
                                                          .heroTagLoginPageCaptcha,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: TextField(
                                                            controller:
                                                                captchaController,
                                                            decoration:
                                                                InputDecoration(
                                                                    labelText: Texts
                                                                        .captcha),
                                                            onSubmitted:
                                                                (value) =>
                                                                    tryLogin(),
                                                          )),
                                                          SizedBox(
                                                            width: 100.w,
                                                            child: Obx(() {
                                                              final base64 =
                                                                  loginController
                                                                      .checkCode
                                                                      .value;
                                                              if (base64
                                                                  .isEmpty) {
                                                                return SizedBox
                                                                    .shrink();
                                                              }
                                                              try {
                                                                final bytes = Uri
                                                                        .parse(
                                                                            base64)
                                                                    .data
                                                                    ?.contentAsBytes();
                                                                if (bytes ==
                                                                    null)
                                                                  return Text(Texts
                                                                      .decodeCaptchaFailed);
                                                                return GestureDetector(
                                                                  onTap: () =>
                                                                      loginController
                                                                          .freshCaptcha(),
                                                                  child: Image
                                                                      .memory(
                                                                    bytes,
                                                                    height:
                                                                        40.w,
                                                                    errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) =>
                                                                        Text(Texts
                                                                            .loadCaptchaFailed),
                                                                  ),
                                                                );
                                                              } catch (e) {
                                                                return Text(Texts
                                                                    .decodeCaptchaFailed);
                                                              }
                                                            }),
                                                          ),
                                                        ],
                                                      )),
                                                  SizedBox(height: 16.w),
                                                  SizedBox(height: 32.w),
                                                  Hero(
                                                      tag: Routes
                                                          .heroTagLoginPageActionBtn,
                                                      child: ElevatedButton(
                                                        onPressed: () =>
                                                            tryLogin(),
                                                        child:
                                                            Text(Texts.login),
                                                      )),
                                                ],
                                              )),
                                              settings: settings,
                                            );
                                          } else if (settings.name ==
                                              Routes
                                                  .loginPageRegisterRouteName) {
                                            return PageRouteBuilder(
                                              opaque: false,
                                              barrierColor: Colors.transparent,
                                              transitionDuration:
                                                  Duration(milliseconds: 300),
                                              reverseTransitionDuration:
                                                  Duration(milliseconds: 300),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                return FadeTransition(
                                                  opacity: animation,
                                                  child: child,
                                                );
                                              },
                                              pageBuilder: (context, animation,
                                                      secondaryAnimation) =>
                                                  SingleChildScrollView(
                                                      child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Hero(
                                                        tag: Routes
                                                            .heroTagLoginPageSwitchBtn,
                                                        child: Tooltip(
                                                            message:
                                                                Texts.toLogin,
                                                            child:
                                                                TextButton.icon(
                                                                    onPressed:
                                                                        () =>
                                                                            Get
                                                                                .back(
                                                                              id: Routes.loginPageNavId,
                                                                            ),
                                                                    label: Text(
                                                                        Texts
                                                                            .login),
                                                                    icon: Icon(
                                                                      Icons
                                                                          .login,
                                                                      size: 16,
                                                                    ))),
                                                      )
                                                    ],
                                                  ),
                                                  Hero(
                                                      tag: Routes
                                                          .heroTagLoginPageEmail,
                                                      child: TextField(
                                                        controller:
                                                            emailController,
                                                        decoration:
                                                            InputDecoration(
                                                                labelText: Texts
                                                                    .email),
                                                        onChanged: (value) =>
                                                            loginController
                                                                .email
                                                                .value = value,
                                                        onSubmitted: (value) =>
                                                            tryRegister(),
                                                      )),
                                                  SizedBox(height: 16.w),
                                                  TextField(
                                                    controller:
                                                        nickNameController,
                                                    decoration: InputDecoration(
                                                        labelText:
                                                            Texts.userName,
                                                        helperText: Texts
                                                            .userNameHelperText),
                                                    onSubmitted: (value) =>
                                                        tryRegister(),
                                                  ),
                                                  SizedBox(height: 16.w),
                                                  Hero(
                                                    tag: Routes
                                                        .heroTagLoginPagePassword,
                                                    child: TextField(
                                                      controller:
                                                          passwordController,
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            Texts.password,
                                                        helperText: Texts
                                                            .passwordHelperText,
                                                      ),
                                                      obscureText: true,
                                                      onSubmitted: (value) =>
                                                          tryRegister(),
                                                    ),
                                                  ),
                                                  SizedBox(height: 16.w),
                                                  Hero(
                                                      tag: Routes
                                                          .heroTagLoginPageCaptcha,
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              child: TextField(
                                                            controller:
                                                                captchaController,
                                                            decoration:
                                                                InputDecoration(
                                                                    labelText: Texts
                                                                        .captcha),
                                                            onSubmitted:
                                                                (value) =>
                                                                    tryRegister(),
                                                          )),
                                                          SizedBox(
                                                            width: 100.w,
                                                            child: Obx(() {
                                                              final base64 =
                                                                  loginController
                                                                      .checkCode
                                                                      .value;
                                                              if (base64
                                                                  .isEmpty) {
                                                                return SizedBox
                                                                    .shrink();
                                                              }
                                                              try {
                                                                final bytes = Uri
                                                                        .parse(
                                                                            base64)
                                                                    .data
                                                                    ?.contentAsBytes();
                                                                if (bytes ==
                                                                    null)
                                                                  return Text(Texts
                                                                      .decodeCaptchaFailed);
                                                                return GestureDetector(
                                                                  onTap: () =>
                                                                      loginController
                                                                          .freshCaptcha(),
                                                                  child: Image
                                                                      .memory(
                                                                    bytes,
                                                                    height:
                                                                        40.w,
                                                                    errorBuilder: (context,
                                                                            error,
                                                                            stackTrace) =>
                                                                        Text(Texts
                                                                            .loadCaptchaFailed),
                                                                  ),
                                                                );
                                                              } catch (e) {
                                                                return Text(Texts
                                                                    .decodeCaptchaFailed);
                                                              }
                                                            }),
                                                          ),
                                                        ],
                                                      )),
                                                  SizedBox(height: 16.w),
                                                  Hero(
                                                      tag: Routes
                                                          .heroTagLoginPageActionBtn,
                                                      child: ElevatedButton(
                                                        onPressed: () =>
                                                            tryRegister(),
                                                        child: Text(
                                                            Texts.register),
                                                      )),
                                                ],
                                              )),
                                              settings: settings,
                                            );
                                          }
                                        }))))))
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoginInfoDialog extends StatelessWidget {
  final VoidCallback onClose;
  const LoginInfoDialog({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onExit: (_) {
          onClose();
        },
        child: AlertDialog(
          title: Text(Texts.unLogin),
          content: TextButton(
              onPressed: () {
                openLoginDialog();
              },
              child: Text(Texts.login)),
        ));
  }
}

class AccountInfoDialog extends StatefulWidget {
  final GlobalKey avatarKey;
  final VoidCallback onClose;
  const AccountInfoDialog(
      {Key? key, required this.avatarKey, required this.onClose})
      : super(key: key);
  @override
  State<AccountInfoDialog> createState() => _AccountInfoDialogState();
}

class _AccountInfoDialogState extends State<AccountInfoDialog> {
  final AccountController accountController = Get.find<AccountController>();

  @override
  void initState() {
    super.initState();
    accountController.getUserCountInfo();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.toNamed('/info',
          id: Routes.accountInfoDialogStateNavId, preventDuplicates: true);
    });
  }

  void _handleExit(PointerExitEvent event) async {
    final navKey = Get.nestedKey(Routes.accountInfoDialogStateNavId);
    final navState = navKey != null ? navKey.currentState : null;
    if (navState != null && navState.canPop()) {
      Get.back(id: Routes.accountInfoDialogStateNavId);
      await Future.delayed(Duration(milliseconds: 150));
    }
    widget.onClose();
  }

  SizedBox btns(
      double widthInCard, VoidCallback onPressed, IconData icon, String label) {
    return SizedBox(
      width: widthInCard.w,
      height: 40.w,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onExit: _handleExit,
      child: SizedBox(
        width: 300.w,
        height: 400.w,
        child: HeroControllerScope(
            controller: MaterialApp.createMaterialHeroController(),
            child: Navigator(
              key: Get.nestedKey(Routes.accountInfoDialogStateNavId),
              initialRoute: '/avatar',
              onGenerateRoute: (settings) {
                if (settings.name == '/avatar') {
                  return PageRouteBuilder(
                    opaque: false,
                    barrierColor: Colors.transparent,
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: 300.w,
                        height: 400.w,
                        child: Stack(
                          children: [
                            Positioned(
                                top: 0,
                                left: 134.w,
                                child: SizedBox(
                                    width: 32.w,
                                    height: 32.w,
                                    child: Hero(
                                      createRectTween: (begin, end) =>
                                          RectTween(begin: begin, end: end),
                                      tag: Routes.heroTagAvatar,
                                      child: Avatar(
                                        avatarValue: accountController.avatar,
                                        radius: 16.r,
                                      ),
                                    ))),
                          ],
                        ),
                      ),
                    ),
                    settings: settings,
                  );
                } else if (settings.name == '/info') {
                  double widthCard = 300;
                  double widthInCard = widthCard - 30;
                  return PageRouteBuilder(
                    opaque: false,
                    barrierColor: Colors.transparent,
                    transitionDuration: Duration(milliseconds: 300),
                    reverseTransitionDuration: Duration(milliseconds: 300),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        width: widthCard.w,
                        height: 400.w,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 40.w,
                              left: 0,
                              child: SizedBox(
                                  width: widthCard.w,
                                  height: 360.w,
                                  child: Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.r)),
                                      margin: EdgeInsets.all(8),
                                      child: SizedBox(
                                          width: widthInCard.w,
                                          height: 360.w,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(height: 50.w),
                                              Text(
                                                  accountController.nickName ??
                                                      Texts.unLogin,
                                                  style: TextStyle(
                                                      fontSize: 20.sp,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              SizedBox(height: 8.w),
                                              // 关注、粉丝、硬币
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  accountDialogNumWidget(
                                                      Texts.focus,
                                                      count: accountController
                                                          .focusCount),
                                                  accountDialogNumWidget(
                                                      Texts.fans,
                                                      count: accountController
                                                          .fansCount),
                                                  accountDialogNumWidget(
                                                      Texts.coin,
                                                      count: accountController
                                                          .currentCoinCount),
                                                ],
                                              ),
                                              SizedBox(height: 8.w),

                                              btns(widthInCard, () async {
                                                showUpdateUserInfoCard();
                                              }, Icons.edit_document,
                                                  Texts.updateUserInfo),
                                              Divider(
                                                height: 1,
                                                color: Colors.grey[300],
                                              ),
                                              btns(widthInCard, () async {
                                                Get.closeAllSnackbars();
                                                var res = await ApiService
                                                    .accountLogout();
                                                if (showResSnackbar(res)) {
                                                  accountController
                                                      .saveAccountInfo({});
                                                  widget.onClose();
                                                }
                                              }, Icons.logout, Texts.logout),
                                            ],
                                          )))),
                            ),
                            Positioned(
                                top: 0,
                                left: 100.w,
                                child: SizedBox(
                                  width: 100.w,
                                  height: 100.w,
                                  child: Hero(
                                    createRectTween: (begin, end) =>
                                        RectTween(begin: begin, end: end),
                                    tag: Routes.heroTagAvatar,
                                    child: Avatar(
                                      avatarValue: accountController.avatar,
                                      radius: 60.r,
                                      userId: accountController.userId,
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                    settings: settings,
                  );
                }
                return null;
              },
            )),
      ),
    );
  }
}
