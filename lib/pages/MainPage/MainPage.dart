import 'dart:async';
import 'package:easylive/pages/MainPage/RecommendVideoArea.dart';
import 'package:easylive/settings.dart';
import 'package:easylive/widgets/HotButton.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/MainPageController.dart';
import '../../controllers/controllers-class.dart';
import '../../api_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final AppBarController appBarController = Get.find<AppBarController>();
  final CategoryLoadAllCategoryController categoryLoadAllCategoryController =
      Get.find<CategoryLoadAllCategoryController>();
  final CategoryViewStateController categoryViewStateController =
      Get.put(CategoryViewStateController());
  late ScrollController _scrollController;

  void _minScrollListener() {
    if (_scrollController.offset < kToolbarHeight) {
      _scrollController.jumpTo(kToolbarHeight);
    }
    
    // 管理 AppBar 透明度状态
    final threshold = appBarController.imgHeight;
    if (_scrollController.offset >= threshold &&
        !appBarController.appBarOpaque.value) {
      appBarController.appBarOpaque.value = true;
    } else if (_scrollController.offset < threshold &&
        appBarController.appBarOpaque.value) {
      appBarController.appBarOpaque.value = false;
    }
    
    // 更新浮动分区栏显示状态
    final shouldShowFloating = _scrollController.offset > appBarController.imgHeight;
    if (appBarController.showFloatingCate.value != shouldShowFloating) {
      appBarController.showFloatingCate.value = shouldShowFloating;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_minScrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.offset < kToolbarHeight) {
        _scrollController.jumpTo(kToolbarHeight);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_minScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      clipBehavior: Clip.none,
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
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
                    } else if (state.extendedImageLoadState ==
                        LoadState.completed) {
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
          ),
        ),
        // 原始分区栏（默认状态，显示所有分区）
        SliverToBoxAdapter(
          child: GetBuilder<CategoryLoadAllCategoryController>(
            init: categoryLoadAllCategoryController,
            builder: (_) {
              final categories = categoryLoadAllCategoryController.categories;
              return Container(
                color: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 热门按钮（两行高）
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
                          showAll: true, // 默认状态显示所有分区
                          isFloating: false, // 不是浮动状态
                          onSelect: (String displayName) {
                            print('MainPage onSelect 被调用，displayName: $displayName');
                            // 跳转到CategoryPage，使用URL参数传递
                            if (displayName.contains('-')) {
                              // 二级分区：格式为 "一级分区名-二级分区名"
                              final firstDashIndex = displayName.indexOf('-');
                              if (firstDashIndex > 0 && firstDashIndex < displayName.length - 1) {
                                final pCategoryName = displayName.substring(0, firstDashIndex);
                                final categoryName = displayName.substring(firstDashIndex + 1);
                                print('跳转到二级分区: $pCategoryName - $categoryName');
                                // 需要找到对应的分区ID
                                final categories = categoryLoadAllCategoryController.categories;
                                final parentCategory = categories.firstWhere(
                                  (cat) => cat['categoryName'] == pCategoryName,
                                  orElse: () => <String, dynamic>{},
                                );
                                if (parentCategory.isNotEmpty) {
                                  final children = List<Map<String, dynamic>>.from(parentCategory['children'] ?? []);
                                  final childCategory = children.firstWhere(
                                    (child) => child['categoryName'] == categoryName,
                                    orElse: () => <String, dynamic>{},
                                  );
                                  if (childCategory.isNotEmpty) {
                                    final url = '${Routes.categoryPage}?pCategoryId=${parentCategory['categoryId']}&categoryId=${childCategory['categoryId']}';
                                    print('跳转URL: $url');
                                    Get.toNamed(url, id: Routes.mainGetId);
                                  } else {
                                    print('未找到子分区: $categoryName');
                                  }
                                } else {
                                  print('未找到父分区: $pCategoryName');
                                }
                              }
                            } else {
                              // 一级分区
                              print('跳转到一级分区: $displayName');
                              final categories = categoryLoadAllCategoryController.categories;
                              final category = categories.firstWhere(
                                (cat) => cat['categoryName'] == displayName,
                                orElse: () => <String, dynamic>{},
                              );
                              if (category.isNotEmpty) {
                                final url = '${Routes.categoryPage}?pCategoryId=${category['categoryId']}';
                                print('跳转URL: $url');
                                Get.toNamed(url, id: Routes.mainGetId);
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // 浮动分区栏（滚动后在顶部显示）
        Obx(() {
          final showFloatingCate = appBarController.showFloatingCate.value;

          // 简化显示逻辑：当顶部栏变不透明时就显示浮动分区栏
          final shouldShowFloating = showFloatingCate;

          if (!shouldShowFloating) {
            return SliverToBoxAdapter(child: SizedBox.shrink());
          }

          return SliverPersistentHeader(
            pinned: true, // 固定在顶部，不随滚动移动
            delegate: _FloatingCategoryHeaderDelegate(
              categories: categoryLoadAllCategoryController.categories,
              onSelect: (String displayName) {
                print('浮动分区栏 onSelect 被调用，displayName: $displayName');
                // 浮动分区栏同样跳转到CategoryPage，使用URL参数传递
                if (displayName.contains('-')) {
                  // 二级分区
                  final parts = displayName.split('-');
                  if (parts.length == 2) {
                    print('浮动分区栏跳转到二级分区: ${parts[0]} - ${parts[1]}');
                    // 需要找到对应的分区ID
                    final categories = categoryLoadAllCategoryController.categories;
                    final parentCategory = categories.firstWhere(
                      (cat) => cat['categoryName'] == parts[0],
                      orElse: () => <String, dynamic>{},
                    );
                    if (parentCategory.isNotEmpty) {
                      final children = List<Map<String, dynamic>>.from(parentCategory['children'] ?? []);
                      final childCategory = children.firstWhere(
                        (child) => child['categoryName'] == parts[1],
                        orElse: () => <String, dynamic>{},
                      );
                      if (childCategory.isNotEmpty) {
                        final url = '${Routes.categoryPage}?pCategoryId=${parentCategory['categoryId']}&categoryId=${childCategory['categoryId']}';
                        print('浮动分区栏跳转URL: $url');
                        Get.toNamed(url, id: Routes.mainGetId);
                      }
                    }
                  }
                } else {
                  // 一级分区
                  print('浮动分区栏跳转到一级分区: $displayName');
                  final categories = categoryLoadAllCategoryController.categories;
                  final category = categories.firstWhere(
                    (cat) => cat['categoryName'] == displayName,
                    orElse: () => <String, dynamic>{},
                  );
                  if (category.isNotEmpty) {
                    final url = '${Routes.categoryPage}?pCategoryId=${category['categoryId']}';
                    print('浮动分区栏跳转URL: $url');
                    Get.toNamed(url, id: Routes.mainGetId);
                  }
                }
              },
            ),
          );
        }),
        SliverList(
          delegate: SliverChildListDelegate([
            // 轮播推荐视频区
            RecommendVideoArea(),
          ]),
        ),
      ],
    );
  }
}

// 使用ExpansionPanelList的浮动分区组件
class _FloatingCategoryExpansion extends StatelessWidget {
  final List categories;
  final void Function(String) onSelect;

  const _FloatingCategoryExpansion({
    required this.categories,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final CategoryViewStateController controller =
        Get.find<CategoryViewStateController>();
    final WindowSizeController windowSizeController =
        Get.find<WindowSizeController>();

    // 监听窗口宽度变化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      windowSizeController.updateWidth(MediaQuery.of(context).size.width);
    });

    return Obx(() {
      final cats = categories;
      int maxPerRow = 9;

      // 第一行始终显示的分区
      final firstRowCats = cats.take(maxPerRow).toList();
      // 剩余的分区用于展开显示
      final remainingCats = cats.skip(maxPerRow).toList();

      // 如果没有剩余分区，直接显示第一行内容
      if (remainingCats.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 热门按钮
              HotButton(
                isFloating: true,
                onTap: () {
                  Get.toNamed(Routes.hotPage, id: Routes.mainGetId);
                },
              ),
              SizedBox(width: 8.w),
              // 第一行分区按钮
              Flexible(
                child: Wrap(
                  spacing: 4.w,
                  runSpacing: 4.w,
                  children: List.generate(firstRowCats.length, (index) {
                    final cat = firstRowCats[index];
                    final hasChildren = cat['children'] != null &&
                        (cat['children'] as List).isNotEmpty;
                    return _CategoryButton(
                      cat: cat,
                      hasChildren: hasChildren,
                      onSelect: onSelect,
                      index: index,
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      }

      // 有剩余分区时使用ExpansionPanelList
      return MouseRegion(
        onExit: (_) {
          // 鼠标退出时收缩
          if (controller.isExpanded.value) {
            controller.setExpanded(false);
          }
        },
        child: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(), // 禁用滚动，让ExpansionPanel自己控制
          child: ExpansionPanelList(
            elevation: 0,
            dividerColor: Colors.transparent,
            animationDuration: Duration(milliseconds: 300),
            expandedHeaderPadding: EdgeInsets.zero,
            expansionCallback: (panelIndex, isExpanded) {
              controller.setExpanded(isExpanded);
            },
            children: [
              ExpansionPanel(
                headerBuilder: (context, isExpanded) {
                  // 将第一行内容作为header显示
                  return MouseRegion(
                      onEnter: (_) {
                        // 鼠标退出时收缩
                        if (!controller.isExpanded.value) {
                          controller.setExpanded(true);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            vertical: 8.w, horizontal: 16.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 热门按钮
                            HotButton(
                              isFloating: true,
                              onTap: () {
                                Get.toNamed(Routes.hotPage,
                                    id: Routes.mainGetId);
                              },
                            ),
                            SizedBox(width: 8.w),
                            // 第一行分区按钮
                            Flexible(
                              child: Wrap(
                                spacing: 4.w,
                                runSpacing: 4.w,
                                children:
                                    List.generate(firstRowCats.length, (index) {
                                  final cat = firstRowCats[index];
                                  final hasChildren = cat['children'] != null &&
                                      (cat['children'] as List).isNotEmpty;
                                  return _CategoryButton(
                                    cat: cat,
                                    hasChildren: hasChildren,
                                    onSelect: onSelect,
                                    index: index,
                                  );
                                }),
                              ),
                            ),
                            // 展开指示器
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 4.w, horizontal: 8.w),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '更多',
                                    style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey[600]),
                                  ),
                                  SizedBox(width: 2.w),
                                  AnimatedRotation(
                                    turns: isExpanded ? 0.5 : 0,
                                    duration: Duration(milliseconds: 200),
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 14.sp,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ));
                },
                body: Container(
                  padding:
                      EdgeInsets.only(left: 16.w, right: 16.w, bottom: 8.w),
                  child: Wrap(
                    spacing: 4.w,
                    runSpacing: 4.w,
                    children: List.generate(remainingCats.length, (index) {
                      final cat = remainingCats[index];
                      final hasChildren = cat['children'] != null &&
                          (cat['children'] as List).isNotEmpty;
                      return _CategoryButton(
                        cat: cat,
                        hasChildren: hasChildren,
                        onSelect: onSelect,
                        index: firstRowCats.length + index,
                      );
                    }),
                  ),
                ),
                isExpanded: controller.isExpanded.value,
                canTapOnHeader: false, // 禁用点击header展开，只使用鼠标悬停
              ),
            ],
          ),
        ),
      );
    });
  }
}

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
                            print('MainPage 点击子分区: ${widget.cat['categoryName']}-${child['categoryName']}');
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
          print('_CategoryButton onTap 被调用，分区名: ${widget.cat['categoryName']}');
          // 不管是否有子分区，点击都直接跳转到CategoryPage显示该一级分区
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

// 浮动分区栏的SliverPersistentHeaderDelegate
class _FloatingCategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List categories;
  final void Function(String) onSelect;

  _FloatingCategoryHeaderDelegate({
    required this.categories,
    required this.onSelect,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    // 计算当前高度：基于shrinkOffset在minExtent和maxExtent之间插值

    return Container(
      height: 120.w,
      child: _FloatingCategoryExpansion(
        categories: categories,
        onSelect: onSelect,
      ),
    );
  }

  @override
  double get maxExtent => 110.0.w; // 展开时的最大高度

  @override
  double get minExtent => 110.0.w; // 收缩时的最小高度

  @override
  bool shouldRebuild(covariant _FloatingCategoryHeaderDelegate oldDelegate) =>
      categories != oldDelegate.categories;
}

// 原始分区栏的Wrap组件（非浮动状态）
class _CategoryWrap extends StatelessWidget {
  final List categories;
  final void Function(String) onSelect;
  final bool showAll;
  final bool isFloating;

  const _CategoryWrap({
    required this.categories,
    required this.onSelect,
    this.showAll = false,
    this.isFloating = false,
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
