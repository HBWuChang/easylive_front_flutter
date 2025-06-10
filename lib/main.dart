import 'dart:math';

import 'package:easylive/Funcs.dart';
import 'package:easylive/pages/MainPage/MainPage.dart';
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
import 'controllers-class.dart';
import 'api_service.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

import 'pages/PlatformPage/PlatformPage.dart';

import 'package:media_kit/media_kit.dart';

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
  await Get.find<VideoLoadRecommendVideoController>().loadRecommendVideos();
  await Get.find<LocalSettingsController>().loadSettings();
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
  final GlobalKey _avatarKey = GlobalKey();
  OverlayEntry? _overlayInfoEntry;
  final AppBarController appBarController = Get.find<AppBarController>();

  @override
  void initState() {
    super.initState();
    appBarController.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // 当图片完全不可见时，AppBar变为不透明
    final threshold = appBarController.imgHeight;
    if (appBarController.scrollController.offset >= threshold &&
        !appBarController.appBarOpaque.value) {
      appBarController.appBarOpaque.value = true;
    } else if (appBarController.scrollController.offset < threshold &&
        appBarController.appBarOpaque.value) {
      appBarController.appBarOpaque.value = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget appBarContent = Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              tooltip: "${c.count}",
              onPressed: () {
                Get.find<AppBarController>().extendBodyBehindAppBar.value =
                    true;
                Get.back(id: Routes.mainGetId);
              },
              icon: Icon(
                Icons.arrow_back_ios_new,
                size: 13,
              )),
          Container(
            width: 200,
            child: Row(
              children: [
                MouseRegion(
                    onEnter: (_) {
                      if (accountController.userId == null) return;
                      final overlay = Overlay.of(context);
                      final renderBox = _avatarKey.currentContext
                          ?.findRenderObject() as RenderBox?;
                      final offset =
                          renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
                      final size = renderBox?.size ?? Size.zero;
                      if (_overlayInfoEntry != null) return;
                      _overlayInfoEntry = OverlayEntry(
                        builder: (context) => Positioned(
                          left: offset.dx + size.width / 2 - 150, // 300宽度一半
                          top: offset.dy,
                          child: AccountInfoDialog(
                            avatarKey: _avatarKey,
                            onClose: () {
                              _overlayInfoEntry?.remove();
                              _overlayInfoEntry = null;
                            },
                          ),
                        ),
                      );
                      overlay.insert(_overlayInfoEntry!);
                    },
                    child: accountController.userId == null
                        ? SizedBox(
                            width: 40,
                            height: 40,
                            child: IconButton(
                              tooltip: Texts.login,
                              iconSize: 40,
                              onPressed: () {
                                openLoginDialog();
                              },
                              icon: Obx(() {
                                return Avatar(
                                  key: _avatarKey,
                                  avatarValue: accountController.avatar,
                                );
                              }),
                            ))
                        : Obx(() {
                            return Avatar(
                              key: _avatarKey,
                              avatarValue: accountController.avatar,
                            );
                          })),
                IconButton(
                  tooltip: Texts.minimize,
                  icon: Icon(Icons.minimize, size: 13),
                  onPressed: () {
                    windowManager.minimize();
                    windowManager.setSkipTaskbar(false);
                  },
                ),
                IconButton(
                  tooltip: Texts.minimize,
                  icon: Icon(Icons.minimize, size: 13),
                  onPressed: () {
                    windowManager.minimize();
                    windowManager.setSkipTaskbar(false);
                  },
                ),
                IconButton(
                  tooltip: '创作中心',
                  icon: Icon(Icons.create, size: 13),
                  onPressed: () {
                    Get.find<AppBarController>().extendBodyBehindAppBar.value =
                        false;
                    Get.toNamed(Routes.platformPage, id: Routes.mainGetId);
                  },
                ),
                IconButton(
                  tooltip: Texts.close,
                  icon: Icon(
                    Icons.close,
                    size: 13,
                  ),
                  onPressed: () {
                    if (!kDebugMode) exit(0);
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
    return Obx(() => Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Obx(() => AppBar(
                backgroundColor: appBarController.appBarOpaque.value
                    ? Colors.white
                    : Colors.transparent,
                elevation: 0,
                title: GetPlatform.isDesktop
                    ? DragToMoveArea(child: appBarContent)
                    : appBarContent,
                toolbarHeight: kToolbarHeight,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
              )),
        ),
        extendBodyBehindAppBar: appBarController.extendBodyBehindAppBar.value,
        body: Navigator(
          key: Get.nestedKey(Routes.mainGetId),
          initialRoute: '/main',
          onGenerateRoute: (settings) {
            if (settings.name == '/main') {
              // 不要在build期间修改observable
              return GetPageRoute(
                settings: settings,
                page: () => MainPage(),
                transition: Transition.noTransition,
              );
            }
            if (settings.name == Routes.platformPage) {
              return GetPageRoute(
                settings: settings,
                page: () => PlatformPage(),
                transition: Transition.fadeIn,
              );
            }
            if (settings.name!.startsWith(Routes.videoPlayPage)) {
              return GetPageRoute(
                settings: settings,
                routeName: settings.name,
                page: () => VideoPlayPage(),
                transition: Transition.fadeIn,
              );
            }
            // 可扩展更多页面
            return null;
          },
        )));
  }
}
