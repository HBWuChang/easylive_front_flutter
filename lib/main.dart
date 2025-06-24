import 'dart:math';
import 'dart:ui' show PointerScrollEvent;
import 'package:easylive/Funcs.dart';
import 'package:easylive/controllers/LocalSettingsController.dart';
import 'package:easylive/pages/MainPage/MainPage.dart';
import 'package:easylive/pages/HotPage/HotPage.dart';
import 'package:easylive/pages/UHome/Uhome.dart';
import 'package:easylive/pages/VideoPlayPage/VideoPlayPage.dart';
import 'package:easylive/pages/pages.dart';
import 'package:easylive/pages/PlatformPage/PlatformPageSubmit.dart';
import 'package:easylive/settings.dart';
import 'package:easylive/widgets.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'controllers/controllers-class.dart';
import 'api_service.dart';
import 'fakePackages/fake_window_manager.dart'
    if (dart.library.io) 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'pages/PlatformPage/PlatformPage.dart';
import 'package:media_kit/media_kit.dart';
import 'package:flutter/gestures.dart';
import 'Appbar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  // 确保在使用Get之前初始化SharedPreferences
  if (GetPlatform.isWindows) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: Size(1312, 800),
      minimumSize: Size(1312, 800),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.maximize();
    });
  }
  await ApiService.init(baseUrl: Constants.baseUrl);
  Get.put(ControllersInitController());

  Get.find<ControllersInitController>().initNeedControllers();
  await Get.find<CategoryLoadAllCategoryController>().loadAllCategories();
  // await Get.find<VideoLoadRecommendVideoController>().loadRecommendVideos();
  await Get.find<LocalSettingsController>().loadSettings();
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1920, 1080),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return GetMaterialApp(
            home: Home(),
            theme: ThemeData(
              colorSchemeSeed: Colors.pink,
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.system,
            getPages: [
              // 你可以在这里定义路由
              GetPage(name: Routes.homePage, page: () => Home()),
              GetPage(name: Routes.platformPage, page: () => PlatformPage()),
            ],
            supportedLocales: [
              const Locale('zh', 'CN'), // 中文简体
              // 其他支持的语言
            ],
            locale: const Locale('zh', 'CN'), // 设置默认语言为中文
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          );
        });
  }
}

class Controller extends GetxController {
  var count = 0.obs;
  increment() => count++;
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Controller c = Get.put(Controller());
  final AccountController accountController = Get.find<AccountController>();
  final AppBarController appBarController = Get.find<AppBarController>();
  final AppBarContent appBarContent = AppBarContent();  @override
  void initState() {
    super.initState();
    // ScrollController 监听已移至各个页面自行管理
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 页面内容
          Positioned.fill(
            top: kToolbarHeight.w,
            child: Navigator(
              key: Get.nestedKey(Routes.mainGetId),
              initialRoute: Routes.mainPage,
              clipBehavior: Clip.none,
              onGenerateRoute: (settings) {
                if (settings.name!.startsWith(Routes.mainPage)) {
                  var route = GetPageRoute(
                      settings: settings,
                      page: () => MainPage(),
                      transition: Transition.noTransition,
                      middlewares: [appBarController.listenPopMiddleware]);
                  appBarController.addAndCleanReapeatRoute(
                      route, settings.name!,
                      title: "狩叶");                  return route;
                }
                if (settings.name == Routes.hotPage) {
                  var route = GetPageRoute(
                      settings: settings,
                      page: () => HotPage(),
                      transition: Transition.fadeIn,
                      middlewares: [appBarController.listenPopMiddleware]);
                  appBarController.addAndCleanReapeatRoute(
                      route, settings.name!,
                      title: "热门推荐");
                  return route;
                }
                if (settings.name == Routes.platformPage) {
                  var route = GetPageRoute(
                      settings: settings,
                      page: () => PlatformPage(),
                      transition: Transition.fadeIn,
                      middlewares: [appBarController.listenPopMiddleware]);
                  appBarController.addAndCleanReapeatRoute(
                      route, settings.name!,
                      title: "创作中心");
                  return route;
                }
                if (settings.name!.startsWith(Routes.videoPlayPage)) {
                  var route = GetPageRoute(
                      settings: settings,
                      routeName: settings.name,
                      page: () => VideoPlayPage(),
                      transition: Transition.fadeIn,
                      middlewares: [appBarController.listenPopMiddleware]);
                  appBarController.addAndCleanReapeatRoute(
                      route, settings.name!);
                  return route;
                }
                if (settings.name!.startsWith(Routes.uhome)) {
                  var route = GetPageRoute(
                      settings: settings,
                      routeName: settings.name,
                      page: () => Uhome(),
                      transition: Transition.fadeIn,
                      middlewares: [appBarController.listenPopMiddleware]);
                  appBarController.addAndCleanReapeatRoute(
                      route, settings.name!);
                  return route;
                }
                // 可扩展更多页面
                return null;
              },
            ),
          ),
          // 顶部悬浮AppBar
          Obx(() => Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: kToolbarHeight.w + 1,
                child: Material(
                  color: appBarController.appBarOpaque.value
                      ? Colors.white
                      : Colors.transparent,
                  elevation: 0,
                  child: GetPlatform.isDesktop
                      ? DragToMoveArea(child: appBarContent)
                      : appBarContent,
                ),
              )),
        ],
      ),
    );
  }
}
