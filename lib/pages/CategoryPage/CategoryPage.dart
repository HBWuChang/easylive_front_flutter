import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/CategoryPageController.dart';
import '../../controllers/controllers-class.dart';
import '../../enums.dart';
import '../../settings.dart';
import '../../api_service.dart';
import '../../widgets/HotButton.dart';
import '../MainPage/VideoInfoWidget.dart';
import 'package:extended_image/extended_image.dart';
import 'dart:async';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final CategoryPageController controller = Get.put(CategoryPageController());
  final CategoryLoadAllCategoryController categoryController =
      Get.find<CategoryLoadAllCategoryController>();
  final AppBarController appBarController = Get.find<AppBarController>();
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    // 获取路由参数
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 确保初始滚动位置（与MainPage一致）
      if (_scrollController.hasClients &&
          _scrollController.offset < kToolbarHeight) {
        _scrollController.jumpTo(kToolbarHeight);
      }

      final route = ModalRoute.of(context);
      if (route != null && route.settings.name != null) {
        final uri = Uri.parse(route.settings.name!);
        final pCategoryId = uri.queryParameters['pCategoryId'];
        final categoryId = uri.queryParameters['categoryId'];

        print(
            'CategoryPage 接收到的URL参数: pCategoryId=$pCategoryId, categoryId=$categoryId');

        if (pCategoryId != null) {
          final pCategoryIdInt = int.tryParse(pCategoryId);
          final categoryIdInt =
              categoryId != null ? int.tryParse(categoryId) : null;

          if (pCategoryIdInt != null) {
            print(
                '初始化分区: pCategoryId=$pCategoryIdInt, categoryId=$categoryIdInt');
            controller.initWithIds(pCategoryIdInt, categoryIdInt);
          }
        }
      } else {
        print('没有接收到分区参数');
      }
    });
  }

  void _scrollListener() {
    // 确保最小滚动高度（与MainPage一致）
    if (_scrollController.offset < kToolbarHeight) {
      _scrollController.jumpTo(kToolbarHeight);
    }
    debugPrint(
        'CategoryPage 滚动监听: offset=${_scrollController.offset}, imgHeight=${appBarController.imgHeight}');
    // 管理 AppBar 透明度状态
    final threshold = appBarController.imgHeight;
    if (_scrollController.offset >= threshold &&
        !appBarController.appBarOpaque.value) {
      appBarController.appBarOpaque.value = true;
    } else if (_scrollController.offset < threshold &&
        appBarController.appBarOpaque.value) {
      appBarController.appBarOpaque.value = false;
    }
    // 检查是否需要加载更多
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMoreVideos();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        clipBehavior: Clip.none,
        controller: _scrollController,
        slivers: [
          // 顶部背景图（与MainPage相同）
          SliverToBoxAdapter(
            child: _buildTopHeader(),
          ),

          // 分区按钮区域（与MainPage相同样式）
          SliverToBoxAdapter(
            child: _buildCategoryButtons(),
          ),

          // 当前分区选择 Row 区域
          SliverToBoxAdapter(
            child: Obx(() => _buildCategorySelectRow()),
          ),

          // 主展示区 - 视频列表（使用MainPage非推荐视频区样式）
          SliverToBoxAdapter(
            child: Obx(() => _buildVideoGrid()),
          ),

          // 底部占位控件，确保可滚动高度大于kToolbarHeight
          SliverToBoxAdapter(
            child: Container(
              height: 1.sh,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建顶部背景图（与MainPage相同）
  Widget _buildTopHeader() {
    return Stack(
      children: [
        SizedBox(
          height: appBarController.imgHeight.w,
          width: double.infinity,
          child: ExtendedImage.network(
            Constants.baseUrl +
                ApiAddr.fileGetResourcet +
                ApiAddr.LoginBackGround,
            fit: BoxFit.cover,
            cache: true,
            enableLoadState: true,
            loadStateChanged: (state) {
              if (state.extendedImageLoadState == LoadState.loading) {
                return Center(child: CircularProgressIndicator());
              } else if (state.extendedImageLoadState == LoadState.completed) {
                return null; // 图片加载完成
              } else {
                return Center(child: Text('加载失败'));
              }
            },
          ),
        ),
        // 渐变遮罩
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建分区按钮区域（与MainPage相同样式）
  Widget _buildCategoryButtons() {
    return GetBuilder<CategoryLoadAllCategoryController>(
      init: categoryController,
      builder: (_) {
        final categories = categoryController.categories;
        return Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 热门按钮（与MainPage一致）
                HotButton(
                  onTap: () {
                    Get.toNamed(Routes.hotPage, id: Routes.mainGetId);
                  },
                ),
                SizedBox(width: 8.w),
                // 分区按钮组
                Flexible(
                  child: _CategoryWrap(
                    categories: categories,
                    onSelect: (String displayName) {
                      // 在CategoryPage中只更新数据，不跳转
                      print('CategoryPage分区按钮点击: $displayName');
                      controller.setCategoryAndLoadVideos(displayName);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 构建分区选择 Row 区域
  Widget _buildCategorySelectRow() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      child: Row(
        children: [
          // 分区名
          Text(
            controller.selectedPCategoryName.value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 16.w),

          // 首页按钮
          _buildTabButton(
            text: '首页',
            isSelected: controller.selectedCategoryId.value == 0,
            onTap: () => controller.selectHomePage(),
          ),

          // 子分区按钮列表
          ...controller.currentCategoryChildren.map((child) {
            final isSelected =
                controller.selectedCategoryId.value == child['categoryId'];
            return Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: _buildTabButton(
                text: child['categoryName'],
                isSelected: isSelected,
                onTap: () => controller.selectChildCategory(child),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  /// 构建选项卡按钮
  Widget _buildTabButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
        decoration: BoxDecoration(
          color:
              isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color:
                isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 构建视频网格（使用MainPage非推荐视频区样式）
  Widget _buildVideoGrid() {
    if (controller.isLoading.value && controller.videos.isEmpty) {
      return Container(
        height: 200.h,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.videos.isEmpty) {
      return Container(
        height: 200.h,
        child: Center(
          child: Text(
            '暂无数据',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 114.w),
      child: Column(
        children: [
          // 视频网格（使用MainPage非推荐视频区的5列布局）
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12.w,
              crossAxisSpacing: 12.w,
              childAspectRatio: AspectRatioEnum
                  .MainPageRecommendVideoRightchild.ratio, // 与MainPage相同的宽高比
            ),
            itemCount: controller.videos.length,
            itemBuilder: (context, index) {
              final video = controller.videos[index];
              return VideoInfoWidget(video: video);
            },
          ),

          // 加载更多指示器
          if (controller.loadingMore.value)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32.w),
              child: Center(child: CircularProgressIndicator()),
            ),

          // 没有更多数据提示
          if (!controller.loadingMore.value &&
              controller.pageNo >= controller.pageTotal)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32.w),
              child: Center(
                child: Text(
                  '没有更多视频了',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// 分区按钮组件（从MainPage复制过来）
class _CategoryWrap extends StatelessWidget {
  final List categories;
  final void Function(String) onSelect;

  const _CategoryWrap({
    required this.categories,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cats = categories;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.w, horizontal: 4.w),
      child: Wrap(
        spacing: 4.w,
        runSpacing: 4.w,
        children: List.generate(cats.length, (index) {
          final cat = cats[index];
          final hasChildren =
              cat['children'] != null && (cat['children'] as List).isNotEmpty;
          return _CategoryButton(
            cat: cat,
            hasChildren: hasChildren,
            onSelect: onSelect,
            index: index,
          );
        }),
      ),
    );
  }
}

// 分区按钮组件（从MainPage复制过来）
class _CategoryButton extends StatefulWidget {
  final Map cat;
  final bool hasChildren;
  final void Function(String) onSelect;
  final int index;

  const _CategoryButton({
    required this.cat,
    required this.hasChildren,
    required this.onSelect,
    required this.index,
  });

  @override
  State<_CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<_CategoryButton>
    with TickerProviderStateMixin {
  OverlayEntry? _childrenOverlay;
  AnimationController? _fadeController;
  Timer? _fadeTimer;
  bool _hovered = false;

  void _showChildrenOverlay(BuildContext context) {
    _cancelFadeTimer();
    if (_childrenOverlay != null) return;
    final overlayState = Overlay.of(context);
    _fadeController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    final renderBox = context.findRenderObject() as RenderBox?;
    final overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox?;
    if (renderBox == null || overlay == null) return;
    final target = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final rect = Rect.fromLTWH(
        target.dx, target.dy, renderBox.size.width, renderBox.size.height);
    _childrenOverlay = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: rect.left,
          top: rect.bottom + 4, // 在按钮下方显示，添加4像素间距
          child: MouseRegion(
            onEnter: (_) => _cancelFadeTimer(),
            onExit: (_) => _startFadeTimer(),
            child: FadeTransition(
              opacity:
                  _fadeController!.drive(CurveTween(curve: Curves.easeInOut)),
              child: Material(
                color: Colors.white,
                elevation: 4,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4.w, horizontal: 8.w),
                  child: Column(
                    spacing: 8.w,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var child in widget.cat['children'])
                        GestureDetector(
                          onTap: () {
                            print(
                                'CategoryPage 点击子分区: ${widget.cat['categoryName']}-${child['categoryName']}');
                            widget.onSelect(
                                '${widget.cat['categoryName']}-${child['categoryName']}');
                            _removeChildrenOverlay();
                          },
                          child: Container(
                            width: 120.w,
                            padding: EdgeInsets.symmetric(
                                vertical: 6.w, horizontal: 16.w),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(child['categoryName']),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    overlayState.insert(_childrenOverlay!);
    _fadeController!.forward();
  }

  void _removeChildrenOverlay({bool immediate = false}) {
    _cancelFadeTimer();
    if (_childrenOverlay != null && _fadeController != null) {
      if (immediate) {
        _fadeController!.dispose();
        _childrenOverlay!.remove();
      } else {
        if (_fadeController!.status == AnimationStatus.dismissed ||
            _fadeController!.status == AnimationStatus.reverse) return;
        _fadeController!.reverse().then((_) {
          if (mounted && _childrenOverlay != null) {
            _fadeController!.dispose();
            _childrenOverlay!.remove();
            _childrenOverlay = null;
            _fadeController = null;
            _fadeTimer = null;
          }
        });
        return;
      }
    }
    _childrenOverlay = null;
    _fadeController = null;
    _fadeTimer = null;
  }

  void _startFadeTimer() {
    _cancelFadeTimer();
    _fadeTimer = Timer(Duration(milliseconds: 100), () {
      if (mounted) _removeChildrenOverlay();
    });
  }

  void _cancelFadeTimer() {
    _fadeTimer?.cancel();
    _fadeTimer = null;
  }

  @override
  void dispose() {
    _removeChildrenOverlay(immediate: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        if (widget.hasChildren) _showChildrenOverlay(context);
        setState(() {
          _hovered = true;
        });
        _cancelFadeTimer();
      },
      onExit: (event) {
        setState(() {
          _hovered = false;
        });
        if (widget.hasChildren) _startFadeTimer();
      },
      child: GestureDetector(
        onTap: () {
          print('CategoryPage 点击一级分区: ${widget.cat['categoryName']}');
          widget.onSelect(widget.cat['categoryName']);
          if (widget.hasChildren) _removeChildrenOverlay();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 18.w),
          decoration: BoxDecoration(
            color: _hovered ? Colors.pink[50] : Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.pink.shade200),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                        color: Colors.pink.withOpacity(0.08), blurRadius: 6.r)
                  ]
                : [],
          ),
          child: SizedBox(
              width: 100.w,
              height: 20.w,
              child: Center(
                child: Text(widget.cat['categoryName'],
                    style: TextStyle(fontSize: 15.sp)),
              )),
        ),
      ),
    );
  }
}
