import 'dart:math';

import 'package:easylive/Funcs.dart';
import 'package:easylive/pages.dart';
import 'package:easylive/settings.dart';
import 'package:easylive/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'controllers-class.dart';
import 'api_service.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 确保在使用Get之前初始化SharedPreferences
  if (GetPlatform.isWindows) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = WindowOptions(
      size: Size(1000, 700),
      minimumSize: Size(1000, 700),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
    });
  }
  Get.put(LoginController());
  Get.put(AccountController());
  await ApiService.init(baseUrl: Constants.baseUrl);
  await Get.find<AccountController>().autoLogin();
  
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

  @override
  Widget build(BuildContext context) {
    Widget appBar = Obx(
      () => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              tooltip: "${c.count}",
              onPressed: () {},
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
                  tooltip: Texts.minimize,
                  icon: Icon(Icons.minimize, size: 13),
                  onPressed: () {
                    windowManager.minimize();
                    windowManager.setSkipTaskbar(false);
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
    return Scaffold(
        // 使用Obx(()=>每当改变计数时，就更新Text()。
        appBar: AppBar(
            title:
                GetPlatform.isDesktop ? DragToMoveArea(child: appBar) : appBar,
            clipBehavior: Clip.none),

        // 用一个简单的Get.to()即可代替Navigator.push那8行，无需上下文！
        body: Center(
            child: ElevatedButton(
                child: Text("Go to Other"),
                onPressed: () {
                  openLoginDialog();
                })),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add), onPressed: c.increment));
  }
}
