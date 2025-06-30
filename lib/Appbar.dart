import 'package:easylive/Funcs.dart';
import 'package:easylive/pages/pages.dart';
import 'package:easylive/settings.dart';
import 'package:easylive/widgets.dart';
import 'package:easylive/widgets/SearchDialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'controllers/controllers-class.dart';
import 'controllers/MessageController.dart';
import 'enums.dart';
import 'fakePackages/fake_window_manager.dart'
    if (dart.library.io) 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
                                              size: 16.w,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary),
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
          // 搜索框
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                barrierColor: Colors.transparent, // 去掉全屏阴影
                builder: (context) => Stack(
                  children: [
                    Positioned(
                      top: MediaQuery.of(context).size.height *
                          0.15, // 在屏幕上部15%的位置
                      left: (MediaQuery.of(context).size.width - 600.w) /
                          2, // 水平居中
                      child: SearchDialog(),
                    ),
                  ],
                ),
              );
            },
            child: Container(
              width: 200.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.3), // 主题色半透明背景
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.5), // 主题色半透明边框
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(width: 12.w),
                  Icon(
                    Icons.search,
                    size: 18.w,
                    color: Colors.white.withOpacity(0.9), // 图标保持白色以确保可见性
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '搜索',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9), // 文字保持白色以确保可见性
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Container(
            width: 400.w,
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
                SizedBox(width: 16.w),

                // 消息按钮
                _MessageButton(),

                SizedBox(width: 16.w),
                HoverFollowWidget(
                    child: TextButton.icon(
                  style: TextButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer),
                  label: Text('创作中心',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                  icon: Icon(Icons.create, size: 13.sp),
                  onPressed: () {
                    Get.find<AppBarController>().extendBodyBehindAppBar.value =
                        false;
                    Get.toNamed(Routes.platformPage, id: Routes.mainGetId);
                  },
                )),
                if (GetPlatform.isWindows)
                  IconButton(
                    tooltip: Texts.minimize,
                    icon: Icon(Icons.minimize, size: 13.sp),
                    onPressed: () {
                      windowManager.minimize();
                      windowManager.setSkipTaskbar(false);
                    },
                  ),
                if (GetPlatform.isWindows)
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

// 消息按钮组件
class _MessageButton extends StatefulWidget {
  @override
  State<_MessageButton> createState() => _MessageButtonState();
}

class _MessageButtonState extends State<_MessageButton>
    with TickerProviderStateMixin {
  final GlobalKey _messageKey = GlobalKey();
  OverlayEntry? _messageOverlay;
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late MessageController _messageController;

  @override
  void initState() {
    super.initState();

    // 初始化或获取MessageController
    if (Get.isRegistered<MessageController>()) {
      _messageController = Get.find<MessageController>();
    } else {
      _messageController = Get.put(MessageController(), permanent: true);
    }

    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  void _showMessageDropdown() {
    if (_messageOverlay != null) return;

    final overlay = Overlay.of(context);
    final renderBox =
        _messageKey.currentContext?.findRenderObject() as RenderBox?;
    final offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final size = renderBox?.size ?? Size.zero;

    _messageOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + size.width / 2 - 150.w, // 居中对齐
        top: offset.dy + size.height + 8.h, // 在按钮下方
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Material(
                color: Colors.transparent,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => _hideMessageDropdown(),
                  child: Container(
                    width: 300.w,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).shadowColor.withOpacity(0.1),
                          blurRadius: 20.r,
                          offset: Offset(0, 8.h),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 消息头部
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                  width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.notifications,
                                  size: 20.w,
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              SizedBox(width: 8.w),
                              Text(
                                '消息通知',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              Spacer(),
                              // 使用Obx显示实时总未读数量
                              Obx(() {
                                final totalCount =
                                    _messageController.totalUnreadCount.value;
                                if (totalCount == 0) return SizedBox.shrink();

                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.w, vertical: 2.h),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Text(
                                    totalCount > 99
                                        ? '99+'
                                        : totalCount.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),

                        // 消息列表 - 使用Obx显示实时消息数据
                        Container(
                          constraints: BoxConstraints(maxHeight: 300.h),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: 4, // 固定4种消息类型
                            itemBuilder: (context, index) {
                              // 构建消息类型列表
                              final messageTypes = [
                                MessageTypeEnum.SYS,
                                MessageTypeEnum.LIKE,
                                MessageTypeEnum.COMMENT,
                                MessageTypeEnum.COLLECT,
                              ];

                              final messageType = messageTypes[index];
                              final typeInfo = _messageController
                                  .getMessageTypeInfo(messageType);

                              return Obx(() {
                                final unreadCount = _messageController
                                    .getUnreadCountByType(messageType);

                                return _buildMessageTypeItem(
                                  icon: typeInfo['icon'],
                                  iconColor: typeInfo['color'],
                                  title: typeInfo['title'],
                                  unreadCount: unreadCount,
                                  onTap: () {
                                    _hideMessageDropdown();
                                    // 跳转到对应消息类型页面
                                    Get.toNamed(
                                      '${Routes.messagePage}/${messageType.type}',
                                      id: Routes.mainGetId,
                                    );
                                  },
                                );
                              });
                            },
                          ),
                        ),

                        // 查看全部按钮
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                  color: Theme.of(context).dividerColor,
                                  width: 1),
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              _hideMessageDropdown();
                              // 跳转到消息页面（默认显示系统消息）
                              Get.toNamed(
                                '${Routes.messagePage}/1',
                                id: Routes.mainGetId,
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              foregroundColor: Theme.of(context).primaryColor,
                            ),
                            child: Text(
                              '查看全部消息',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                // backgroundColor: ,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_messageOverlay!);
    _animationController.forward();
  }

  Widget _buildMessageTypeItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int unreadCount,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: unreadCount > 0
              ? Theme.of(context).primaryColor.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(icon, size: 16.w, color: iconColor),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight:
                      unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            if (unreadCount > 0) ...[
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  unreadCount > 99 ? '99+' : unreadCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ] else ...[
              SizedBox(width: 8.w),
              Icon(Icons.chevron_right,
                  size: 16.w, color: Theme.of(context).colorScheme.secondary),
            ],
          ],
        ),
      ),
    );
  }

  void _hideMessageDropdown() async {
    if (_messageOverlay == null) return;

    await _animationController.reverse();
    _messageOverlay?.remove();
    _messageOverlay = null;
    setState(() => _isHovered = false);
  }

  @override
  void dispose() {
    _hideMessageDropdown();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      key: _messageKey,
      onEnter: (_) {
        setState(() => _isHovered = true);
        _showMessageDropdown();
      },
      onExit: (_) {
        // 延迟隐藏，给用户时间移动到弹窗
        Future.delayed(Duration(milliseconds: 150), () {
          if (!_isHovered) {
            _hideMessageDropdown();
          }
        });
      },
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: _isHovered
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Stack(
          children: [
            Center(
              child: Icon(
                Icons.notifications_outlined,
                size: 20.w,
                color: _isHovered
                    ? Theme.of(context).primaryColor
                    : Colors.grey[600],
              ),
            ),
            // 消息数量小红点 - 使用Obx监听数据变化
            Obx(() {
              final totalCount = _messageController.totalUnreadCount.value;
              if (totalCount == 0) return SizedBox.shrink();

              return Positioned(
                top: 6.h,
                right: 6.w,
                child: Container(
                  constraints: BoxConstraints(
                    minWidth: 12.w,
                    minHeight: 12.w,
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Center(
                    child: Text(
                      totalCount > 99 ? '99+' : totalCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
