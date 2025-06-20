import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:easylive/Funcs.dart';
import 'package:easylive/controllers/VideoCommentController.dart';
import 'package:easylive/controllers/VideoDamnuController.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/pages/UHome/VideoSeriesPage.dart';
import 'package:easylive/pages/VideoPlayPage/VideoPlayPageComments.dart';
import 'package:easylive/pages/VideoPlayPage/VideoPlayPageInfo.dart';
import 'package:easylive/settings.dart';
import 'package:easylive/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import '../../controllers/LocalSettingsController.dart';
import '../../controllers/UhomeSeriesController.dart';
import '../../controllers/controllers-class.dart';
import '../../api_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
// import 'package:iconify_flutter_plus/iconify_flutter_plus.dart'; // For Iconify Widget
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter_plus/icons/zondicons.dart'; // for Non Colorful Icons
import 'package:iconify_flutter/icons/tabler.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'VideoListPage.dart';

class Uhome extends StatefulWidget {
  Uhome({Key? key}) : super(key: key);

  @override
  _UhomeState createState() => _UhomeState();
}

class _UhomeState extends State<Uhome> with TickerProviderStateMixin {
  late UserInfoController userInfoController;
  bool showDetailedInfo = false; // 控制详细信息显示
  late PageController pageController; // 页面控制器
  var showuhomeVideoListType = false.obs; // 控制视频列表类型
  late AnimationController _buttonAnimationController;
  late Animation<double> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    pageController = PageController();
    pageController.addListener(() {
      // debugPrint('当前页面索引: ${pageController.page?.round()}'); // 打印当前页面索引
      changeShowuhomeVideoListType(pageController.page?.round() ?? 0);
    });
    
    // 初始化动画控制器
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  void changeShowuhomeVideoListType(int index) {
    if (index == 0) {
      // 切换到视频页面，隐藏按钮
      _buttonAnimationController.reverse();
      showuhomeVideoListType.value = false;
    } else {
      // 切换到合集页面，显示按钮
      showuhomeVideoListType.value = true;
      _buttonAnimationController.forward();
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)?.settings.name;
    print('当前路由名称: $routeName');
    var userId = toParameters(routeName!)?['userId'] ??
        Get.find<AccountController>().userId;

    if (userId == null) {
      openLoginDialog();
      return Scaffold(
        body: Center(
          child: Text('雑鱼~404'),
        ),
      );
    }
    if (Get.isRegistered(tag: '${userId}UserInfoController')) {
      userInfoController =
          Get.find<UserInfoController>(tag: '${userId}UserInfoController');
      userInfoController.getUserInfo(null);
    } else {
      userInfoController = Get.put(UserInfoController(userId: userId),
          tag: '${userId}UserInfoController',permanent: true);
    }
    if (!Get.isRegistered<UhomeSeriesController>(
        tag: '${userId}UhomeSeriesController')) {
      Get.put(UhomeSeriesController(userId: userId),
          tag: '${userId}UhomeSeriesController',permanent: true);
    }
    Obx s1(Widget icon, String text) {
      return Obx(() {
        if (userInfoController.userInfo[text] == null ||
            userInfoController.userInfo[text].isEmpty) {
          return SizedBox.shrink();
        }
        return Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              SizedBox(width: 4),
              Text(
                '${userInfoController.userInfo[text] ?? '未知'}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              )
            ]);
      });
    }

    LocalSettingsController localSettingsController =
        Get.find<LocalSettingsController>();
    return Scaffold(
      body: CustomScrollView(
        shrinkWrap: true,
        slivers: [
          // 背景图+个人信息行合并，防止头像被遮挡
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 背景图和个人信息Row的组合
                Column(
                  children: [
                    // 背景图
                    AspectRatio(
                      aspectRatio: 3840 / 400,
                      child: Obx(() => ExtendedImage.network(
                            userInfoController.theme!,
                            fit: BoxFit.cover,
                            cache: true,
                            cacheRawData: true,
                            clearMemoryCacheIfFailed: true,
                            loadStateChanged: (state) {
                              if (state.extendedImageLoadState ==
                                  LoadState.completed) {
                                return null;
                              }
                              return ExtendedImage.asset(
                                Constants.defaultUHomeBg,
                                fit: BoxFit.cover,
                              );
                            },
                          )),
                    ),
                    // 个人信息Row
                    Container(
                      height: 100, // 改回原来的高度
                      clipBehavior: Clip.none,
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 头像占位，实际头像通过Positioned绝对定位
                          SizedBox(width: 120, height: 120), // 给头像留出空间
                          SizedBox(width: 48),
                          // 名称及简介
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.start, // 改为上对齐
                              children: [
                                SizedBox(height: 12), // 添加上边距
                                Obx(() => Text(
                                      userInfoController.nickName,
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold),
                                    )),
                                SizedBox(height: 6),
                                // 简介和详情按钮的行
                                Row(
                                  children: [
                                    Expanded(
                                      child: Obx(() => Text(
                                            userInfoController
                                                    .personIntroduction
                                                    .isNotEmpty
                                                ? userInfoController
                                                    .personIntroduction
                                                : '这个人很神秘，什么都没写',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700]),
                                            maxLines: 1, // 简介始终只显示一行
                                            overflow: TextOverflow.ellipsis,
                                          )),
                                    ),
                                    SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showDetailedInfo = !showDetailedInfo;
                                        });
                                      },
                                      child: Text(
                                        showDetailedInfo ? '收起' : '详情',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // 详细信息（UserId、学校、生日）在一行显示
                                if (showDetailedInfo) ...[
                                  SizedBox(height: 8),
                                  Wrap(
                                    spacing: 16,
                                    children: [
                                      s1(
                                          Iconify(
                                            Ph.identification_badge,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          'userId'),
                                      s1(
                                          Icon(Icons.school,
                                              size: 16,
                                              color: Colors.grey[600]),
                                          'school'),
                                      s1(
                                          Icon(Icons.cake,
                                              size: 16,
                                              color: Colors.grey[600]),
                                          'birthday'),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          SizedBox(width: 48),
                          // 关注/粉丝/获赞
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Obx(() => _buildCount(
                                      '关注',
                                      userInfoController
                                          .userInfo['focusCount'])),
                                  SizedBox(
                                    width: 65,
                                    height: 32,
                                    child: DividerWithPaddingVertical(
                                      padding: 0,
                                      color: Colors.grey[300],
                                    ),
                                  ),

                                  Obx(() => _buildCount(
                                      '粉丝',
                                      userInfoController
                                          .userInfo['fansCount'])),
                                  SizedBox(
                                    width: 65,
                                    height: 32,
                                    child: DividerWithPaddingVertical(
                                      padding: 0,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  Obx(() => _buildCount(
                                      '获赞',
                                      userInfoController
                                          .userInfo['likeCount'])),
                                  SizedBox(width: 64),
                                  // 关注按钮放在数据右侧
                                  Obx(() =>
                                      _buildFollowButton(userInfoController)),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ],
                ),
                // 头像绝对定位，跨越背景图和个人信息Row
                Positioned(
                  left: 48,
                  bottom: 0, // 从个人信息Row底部向上90像素
                  child: Obx(() => Avatar(
                      radius: 60, avatarValue: userInfoController.avatar)),
                ),
              ],
            ),
          ),
          // 切换按钮行
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  SizedBox(width: 48), // 留出头像空间
                  SizedBox(
                      width: 200,
                      child: AnimatedTabBarWidget(
                        pageController: pageController,
                        tabLabels: [
                          TextSpan(text: '视频'),
                          TextSpan(text: '合集'),
                        ],
                        barHeight: 3,
                        barWidthMultiplier: 0.5,
                        spacing: 0,
                      )),
                  Spacer(),
                  Obx(() {
                    if (!showuhomeVideoListType.value) {
                      return SizeTransition(
                        sizeFactor: _slideAnimation,
                        axis: Axis.horizontal,
                        axisAlignment: 1.0, // 从右侧开始动画
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0), // 从右侧滑入
                            end: Offset.zero,
                          ).animate(_slideAnimation),
                          child: const SizedBox.shrink(),
                        ),
                      );
                    }
                    return SizeTransition(
                      sizeFactor: _slideAnimation,
                      axis: Axis.horizontal,
                      axisAlignment: 1.0, // 从右侧开始动画
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1.0, 0.0), // 从右侧滑入
                          end: Offset.zero,
                        ).animate(_slideAnimation),
                        child: IconButton(
                          icon: Iconify(
                            localSettingsController.getSetting('uhomeVideoListType')
                                ? Tabler.layout_grid
                                : Tabler.layout_list,
                            size: 24,
                            color: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            localSettingsController.setSetting(
                                'uhomeVideoListType',
                                !localSettingsController
                                    .getSetting('uhomeVideoListType'));
                          },
                        ),
                      ),
                    );
                  }),
                  SizedBox(width: 24), // 留出右侧空间
                ],
              ),
            ),
          ),
          // 分隔线
          SliverToBoxAdapter(
            child: DividerWithPaddingHorizontal(padding: 24),
          ),
          // 页面内容
          SliverFillRemaining(
            fillOverscroll: true,
            child: PageView(
              controller: pageController,
              children: [
                GetBuilder<UserInfoController>(
                  tag: routeName,
                  init: userInfoController,
                  builder: (controller) {
                    if (controller.userId.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return VideoListPage(
                      userId: controller.userId,
                    );
                  },
                ),
                GetBuilder<UserInfoController>(
                  tag: routeName,
                  init: userInfoController,
                  builder: (controller) {
                    if (controller.userId.isEmpty) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return VideoSeriesPage(
                      userId: controller.userId,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCount(String label, dynamic value) {
    return Column(
      children: [
        Text(
          value?.toString() ?? '0',
          style:
              TextStyle(fontSize: 24, fontWeight: FontWeight.bold), // 从20增加到24
        ),
        SizedBox(height: 2),
        Text(label,
            style:
                TextStyle(fontSize: 16, color: Colors.grey[600])), // 从14增加到16
      ],
    );
  }

  Widget _buildFollowButton(UserInfoController controller) {
    final isFollowed = controller.userInfo['haveFocus'] == true;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isFollowed ? Colors.grey[300] : Theme.of(context).primaryColor,
        foregroundColor: isFollowed ? Colors.black87 : Colors.white,
        minimumSize: Size(110, 44),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)), // 从20改为12，更适合矩形
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // 添加内边距
      ),
      onPressed: () async {
        if (isFollowed) {
          // 取消关注
          var res =
              await ApiService.uhomeCancelFocus(controller.userInfo['userId']!);
          showResSnackbar(res);
        } else {
          // 关注
          var res = await ApiService.uhomeFocus(controller.userInfo['userId']!);
          showResSnackbar(res);
        }
        controller.getUserInfo(null);
      },
      child: Text(
        isFollowed ? '已关注' : '+ 关注',
        style:
            TextStyle(fontSize: 16, fontWeight: FontWeight.w500), // 增加字体大小和权重
      ),
    );
  }
}
