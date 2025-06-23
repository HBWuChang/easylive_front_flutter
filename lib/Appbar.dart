import 'dart:math';
import 'dart:ui' show PointerScrollEvent;

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
import 'controllers/controllers-class.dart';
import 'api_service.dart';
import 'fakePackages/fake_window_manager.dart'
    if (dart.library.io) 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'pages/PlatformPage/PlatformPage.dart';

import 'package:media_kit/media_kit.dart';
import 'package:flutter/gestures.dart';

class AppBarContent extends StatelessWidget {
  const AppBarContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final GlobalKey _avatarKey = GlobalKey();
    final GlobalKey tabBarKey = GlobalKey();
    OverlayEntry? overlayInfoEntry;
    final appBarController = Get.find<AppBarController>();
    final accountController = Get.find<AccountController>();
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () {
                Get.toNamed(
                  Routes.mainPage,
                  id: Routes.mainGetId,
                );
              },
              icon: Icon(
                Icons.home_rounded,
                size: 13.w,
              )),
          Expanded(
            key: tabBarKey,
            child: Obx(() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final ctx = tabBarKey.currentContext;
                if (ctx != null) {
                  final box = ctx.findRenderObject() as RenderBox?;
                  if (box != null) {
                    final totalWidth = box.size.width;
                    final routes = appBarController.top_routeWithName;
                    if (routes.isNotEmpty) {
                      double w = (totalWidth / routes.length)
                          .clamp(50, 200)
                          .toDouble();
                      if ((appBarController.tabWidth.value - w).abs() > 1) {
                        appBarController.tabWidth.value = w;
                      }
                    }
                  }
                }
              });
              final routes = appBarController.top_routeWithName;
              final selectedName = appBarController.selectedRouteName.value;
              return Container(
                height: kToolbarHeight.w,
                child: Listener(
                  onPointerSignal: (event) {
                    if (event is PointerScrollEvent) {
                      final controller = appBarController.tabScrollController;
                      controller.jumpTo(
                          (controller.offset + event.scrollDelta.dy * 2)
                              .clamp(0.0, controller.position.maxScrollExtent));
                    }
                  },
                  child: SingleChildScrollView(
                    controller: appBarController.tabScrollController,
                    scrollDirection: Axis.horizontal,
                    child: ReorderableListView(
                      scrollDirection: Axis.horizontal,
                      onReorder: (oldIndex, newIndex) {
                        if (oldIndex < newIndex) newIndex--;
                        final item = routes.removeAt(oldIndex);
                        routes.insert(newIndex, item);
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          appBarController.update();
                        });
                      },
                      buildDefaultDragHandles: false,
                      shrinkWrap: true,
                      children: [
                        for (int index = 0; index < routes.length; index++)
                          SizedBox(
                              width: appBarController.tabWidth.value.w,
                              key: ValueKey(routes[index].name),
                              child: GestureDetector(
                                key: ValueKey(routes[index].name),
                                onTap: () {
                                  if (routes[index].name != selectedName) {
                                    Get.toNamed(
                                      routes[index].name,
                                      id: Routes.mainGetId,
                                    );
                                  }
                                },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 150),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical:
                                          routes[index].name == selectedName
                                              ? 2
                                              : 6),
                                  constraints: BoxConstraints(
                                    minWidth: appBarController.tabWidth.value.w,
                                    maxWidth: appBarController.tabWidth.value.w,
                                  ),
                                  decoration: BoxDecoration(
                                    color: routes[index].name == selectedName
                                        ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withOpacity(0.12)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8.r),
                                    boxShadow:
                                        routes[index].name == selectedName
                                            ? [
                                                BoxShadow(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withOpacity(0.15),
                                                    blurRadius: 6.r,
                                                    offset: Offset(0, 2))
                                              ]
                                            : [],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Obx(() => Tooltip(
                                            message: routes[index]
                                                    .title
                                                    .value
                                                    .isNotEmpty
                                                ? routes[index].title.value
                                                : routes[index].name,
                                            waitDuration:
                                                Duration(milliseconds: 400),
                                            child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 8.w),
                                                child: Obx(
                                                  () => SizedBox(
                                                      width: (appBarController
                                                                  .tabWidth
                                                                  .value -
                                                              54)
                                                          .w, // 减去关闭按钮和间距
                                                      child: Obx(() => Text(
                                                            routes[index]
                                                                    .title
                                                                    .value
                                                                    .isNotEmpty
                                                                ? routes[index]
                                                                    .title
                                                                    .value
                                                                : routes[index]
                                                                    .name,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontWeight: routes[
                                                                              index]
                                                                          .name ==
                                                                      selectedName
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .normal,
                                                              color: routes[index]
                                                                          .name ==
                                                                      selectedName
                                                                  ? Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .primary
                                                                  : Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .onSurface,
                                                            ),
                                                          ))),
                                                )),
                                          )),
                                      InkWell(
                                        onTap: () =>
                                            appBarController.removeRouteByName(
                                                routes[index].name),
                                        child: Padding(
                                          padding: EdgeInsets.only(
                                              right: 6.w, left: 2.w),
                                          child: Icon(Icons.close,
                                              size: 16.w, color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
          Container(
            width: 200.w,
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
                      if (overlayInfoEntry != null) return;
                      overlayInfoEntry = OverlayEntry(
                        builder: (context) => Positioned(
                          left: offset.dx + size.width / 2 - 150.w, // 300宽度一半
                          top: offset.dy.w,
                          child: AccountInfoDialog(
                            avatarKey: _avatarKey,
                            onClose: () {
                              overlayInfoEntry?.remove();
                              overlayInfoEntry = null;
                            },
                          ),
                        ),
                      );
                      overlay.insert(overlayInfoEntry!);
                    },
                    child: accountController.userId == null
                        ? SizedBox(
                            width: 40.w,
                            height: 40.w,
                            child: IconButton(
                              tooltip: Texts.login,
                              iconSize: 40.sp,
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
                if (!GetPlatform.isWeb)
                  IconButton(
                    tooltip: Texts.minimize,
                    icon: Icon(Icons.minimize, size: 13.sp),
                    onPressed: () {
                      windowManager.minimize();
                      windowManager.setSkipTaskbar(false);
                    },
                  ),
                HoverFollowWidget(
                    child: IconButton(
                  tooltip: '创作中心',
                  icon: Icon(Icons.create, size: 13.sp),
                  onPressed: () {
                    Get.find<AppBarController>().extendBodyBehindAppBar.value =
                        false;
                    Get.toNamed(Routes.platformPage, id: Routes.mainGetId);
                  },
                )),
                if (!GetPlatform.isWeb)
                  IconButton(
                    tooltip: Texts.close,
                    icon: Icon(
                      Icons.close,
                      size: 13.sp,
                    ),
                    onPressed: () {
                      if (!kDebugMode) exit(0);
                    },
                  ),
              ],
            ),
          )
        ],
      );
    });
  }
}
