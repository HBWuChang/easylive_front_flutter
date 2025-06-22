import 'dart:async';
import 'package:easylive/Funcs.dart';
import 'package:easylive/settings.dart';
import 'package:easylive/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/LocalSettingsController.dart';
import '../../controllers/UhomeSeriesController.dart';
import '../../controllers/controllers-class.dart';
import '../../api_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/gestures.dart';
// import 'package:iconify_flutter_plus/iconify_flutter_plus.dart'; // For Iconify Widget
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/tabler.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'UhomeWidgets.dart';
import 'VideoListPage.dart';
import 'VideoSeriesPage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      // 切换到视频页面，先执行退出动画，再隐藏按钮
      _buttonAnimationController.reverse().then((_) {
        showuhomeVideoListType.value = false;
      });
    } else {
      // 切换到合集页面，先显示按钮，再执行进入动画
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
    var userId =
        getLastPath(routeName!) ?? Get.find<AccountController>().userId;

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
          tag: '${userId}UserInfoController', permanent: true);
    }
    if (!Get.isRegistered<UhomeSeriesController>(
        tag: '${userId}UhomeSeriesController')) {
      Get.put(UhomeSeriesController(userId: userId),
          tag: '${userId}UhomeSeriesController', permanent: true);
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
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
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
                      height: 100.w, // 改回原来的高度
                      clipBehavior: Clip.none,
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 头像占位，实际头像通过Positioned绝对定位
                          SizedBox(width: 120.w, height: 120.w), // 给头像留出空间
                          SizedBox(width: 48.w),
                          // 名称及简介
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.start, // 改为上对齐
                              children: [
                                SizedBox(height: 12.w), // 添加上边距
                                Obx(() => Text(
                                      userInfoController.nickName,
                                      style: TextStyle(
                                          fontSize: 22.sp,
                                          fontWeight: FontWeight.bold),
                                    )),
                                SizedBox(height: 6.w),
                                // 简介和详情按钮的行
                                Row(
                                  children: [
                                    Expanded(
                                      child: Obx(() => ExpandableText(
                                            text: userInfoController
                                                    .personIntroduction
                                                    .isNotEmpty
                                                ? userInfoController
                                                    .personIntroduction
                                                : '这个人很神秘，什么都没写',
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.grey[700]),
                                            maxLines: 1, // 简介始终只显示一行
                                          )),
                                    ),
                                    SizedBox(width: 8.w),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          showDetailedInfo = !showDetailedInfo;
                                        });
                                      },
                                      child: Text(
                                        showDetailedInfo ? '收起' : '详情',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                // 详细信息（UserId、学校、生日）在一行显示
                                if (showDetailedInfo) ...[
                                  SizedBox(height: 8.w),
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
                          SizedBox(width: 48.w),
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
                                    width: 65.w,
                                    height: 32.w,
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
                                    width: 65.w,
                                    height: 32.w,
                                    child: DividerWithPaddingVertical(
                                      padding: 0,
                                      color: Colors.grey[300],
                                    ),
                                  ),
                                  Obx(() => _buildCount(
                                      '获赞',
                                      userInfoController
                                          .userInfo['likeCount'])),
                                  SizedBox(width: 64.w),
                                  // 关注按钮放在数据右侧
                                  Obx(() =>
                                      _buildFollowButton(userInfoController)),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(width: 20.w),
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
                      radius: 60.r, avatarValue: userInfoController.avatar,showOnTap: true)),
                ),
              ],
            ),
          ),
          // 切换按钮行
          SliverToBoxAdapter(
            child: Container(
              height: 50.w,
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  SizedBox(width: 48.w), // 留出头像空间
                  SizedBox(
                      width: 200.w,
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
                  // 使用 AnimatedBuilder 来统一管理动画
                  AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return SizeTransition(
                        sizeFactor: _slideAnimation,
                        axis: Axis.horizontal,
                        axisAlignment: 1.0, // 从右侧开始动画
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0), // 从右侧滑入
                            end: Offset.zero,
                          ).animate(_slideAnimation),
                          child: Obx(() => showuhomeVideoListType.value
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (userInfoController.userId ==
                                        Get.find<AccountController>().userId)
                                    IconButton(
                                      tooltip: '编辑合集列表',
                                      icon: Icon(Icons.edit,
                                          size: 24,
                                          color:
                                              Theme.of(context).primaryColor),
                                      onPressed: () =>
                                          _showEditSeriesListDialog(
                                              context, userId),
                                    ),
                                    IconButton(
                                      icon: Iconify(
                                        localSettingsController.getSetting(
                                                'uhomeVideoListType')
                                            ? Tabler.layout_grid
                                            : Tabler.layout_list,
                                        size: 24,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      onPressed: () {
                                        localSettingsController.setSetting(
                                            'uhomeVideoListType',
                                            !localSettingsController.getSetting(
                                                'uhomeVideoListType'));
                                      },
                                    ),
                                  ],
                                )
                              : const SizedBox.shrink()),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 24.w), // 留出右侧空间
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

  // 显示编辑合集列表的弹窗
  Future<void> _showEditSeriesListDialog(
      BuildContext context, String userId) async {
    await Get.dialog(
      EditSeriesListDialog(userId: userId),
    );
  }

  Widget _buildCount(String label, dynamic value) {
    return Column(
      children: [
        Text(
          value?.toString() ?? '0',
          style:
              TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold), // 从20增加到24
        ),
        SizedBox(height: 2),
        Text(label,
            style:
                TextStyle(fontSize: 16.sp, color: Colors.grey[600])), // 从14增加到16
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
            borderRadius: BorderRadius.circular(12.r)), // 从20改为12，更适合矩形
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
            TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500), // 增加字体大小和权重
      ),
    );
  }
}

// 编辑合集列表弹窗
class EditSeriesListDialog extends StatefulWidget {
  final String userId;

  const EditSeriesListDialog({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<EditSeriesListDialog> createState() => _EditSeriesListDialogState();
}

class _EditSeriesListDialogState extends State<EditSeriesListDialog> {
  late UhomeSeriesController _uhomeSeriesController;
  List<UserVideoSeries> _sortableSeriesList = [];
  bool operating = false; // 用于防止重复操作
  @override
  void initState() {
    super.initState();
    _uhomeSeriesController = Get.find<UhomeSeriesController>(
      tag: '${widget.userId}UhomeSeriesController',
    );
    _sortableSeriesListInit();
  }

  Future<void> _sortableSeriesListInit() async {
    try {
      var res =
          await _uhomeSeriesController.loadUserVideoSeries(lasttype: true);
      setState(() {
        _sortableSeriesList = res;
      });
    } catch (e) {
      showErrorSnackbar(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: (MediaQuery.of(context).size.width * 0.6).w,
        height: (MediaQuery.of(context).size.height * 0.7).w,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 标题栏
            Row(
              children: [
                Text(
                  '编辑合集列表',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
             SizedBox(height: 24.w),

            // 添加合集按钮
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12.r),
                color: Theme.of(context).primaryColor.withOpacity(0.05),
              ),
              child: InkWell(
                onTap: () async {
                  _uhomeSeriesController.nowSelectSeriesId.value =
                      0; // 重置当前选择的合集ID
                  var res = await Get.dialog(EditSeriesDialog(
                    uhomeSeriesController: _uhomeSeriesController,
                  ));
                  if (res != null && res)
                    await _sortableSeriesListInit(); // 重新加载合集列表
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Column(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 48,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '添加新合集',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '点击创建一个新的视频合集',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

             SizedBox(height: 24.w),

            // 合集列表标题
            Row(
              children: [
                const Icon(Icons.sort, size: 20),
                 SizedBox(width: 8.w),
                Text(
                  '合集排序',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const Spacer(),
                Text(
                  '拖动调整顺序',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 可拖动合集列表
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: _sortableSeriesList.isEmpty
                    ?  Center(
                        child: Text(
                          '暂无合集',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _sortableSeriesList.length,
                        onReorder: (oldIndex, newIndex) async {
                          try {
                            if (operating) return; // 防止重复操作
                            operating = true;
                            if (newIndex > oldIndex) {
                              newIndex -= 1; // 调整索引
                            }
                            final movedItem =
                                _sortableSeriesList.removeAt(oldIndex);
                            _sortableSeriesList.insert(newIndex, movedItem);
                            showResSnackbar(
                                (await ApiService
                                    .uhomeSeriesChangeVideoSeriesSort(
                                        _sortableSeriesList
                                            .map((e) => e.seriesId)
                                            .toList()
                                            .join(','))),
                                notShowIfSuccess: true);
                            await _sortableSeriesListInit();
                            _uhomeSeriesController.loadUserVideoSeries();
                          } catch (e) {
                            showErrorSnackbar(e.toString());
                          } finally {
                            operating = false;
                          }
                        },
                        itemBuilder: (context, index) {
                          final series = _sortableSeriesList[index];
                          return DraggableSeriesItem(
                            key: ValueKey(series.seriesId),
                            series: series,
                            index: index,
                            onDelete: () async {
                              if (operating) return; // 防止重复操作
                              operating = true;
                              try {
                                final confirm = await showConfirmDialog(
                                  '确认删除合集 "${series.seriesName}" 吗？',
                                );
                                if (confirm) {
                                  showResSnackbar(
                                      (await ApiService
                                          .uhomeSeriesDelVideoSeries(
                                              series.seriesId)),
                                      notShowIfSuccess: true);
                                  // 重新加载合集列表
                                  await _sortableSeriesListInit();
                                }
                              } catch (e) {
                                showErrorSnackbar(e.toString());
                              } finally {
                                operating = false;
                              }
                            },
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 可拖动的合集条目
class DraggableSeriesItem extends StatelessWidget {
  final UserVideoSeries series;
  final int index;
  final VoidCallback? onDelete;

  const DraggableSeriesItem({
    Key? key,
    required this.series,
    required this.index,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),

          // 序号
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 合集封面
          Container(
            width: 80.w,
            height: 45.w,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(6.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: series.cover.isNotEmpty
                ? ExtendedImage.network(
                    ApiService.baseUrl +
                        ApiAddr.fileGetResourcet +
                        series.cover,
                    fit: BoxFit.cover,
                    loadStateChanged: (ExtendedImageState state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                          return Container(
                            color: Colors.grey[300],
                            child:  Center(
                              child: SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey),
                                ),
                              ),
                            ),
                          );
                        case LoadState.failed:
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.video_library,
                              color: Colors.grey,
                              size: 20,
                            ),
                          );
                        case LoadState.completed:
                          return state.completedWidget;
                      }
                    },
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Icon(
                      Icons.video_library,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
          ),
          const SizedBox(width: 16),

          // 合集信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExpandableText(
                  text: series.seriesName,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.grey[500],
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(series.updateTime),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 删除按钮
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red[400],
                size: 20,
              ),
              tooltip: '删除合集',
              constraints: BoxConstraints(
                minWidth: 32.w,
                minHeight: 32.w,
              ),
              padding: const EdgeInsets.all(4),
            ),
          SizedBox(width: 24.w),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}个月前';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}
