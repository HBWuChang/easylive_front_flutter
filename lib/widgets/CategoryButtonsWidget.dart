import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/controllers-class.dart';
import '../controllers/MainPageController.dart';
import '../settings.dart';
import 'HotButton.dart';

/// 通用分区按钮组件
/// 可以在MainPage和CategoryPage中复用
class CategoryButtonsWidget extends StatelessWidget {
  final List categories;
  final void Function(String) onSelect;
  final bool showAll;
  final bool isFloating;
  final EdgeInsetsGeometry? padding;

  const CategoryButtonsWidget({
    Key? key,
    required this.categories,
    required this.onSelect,
    this.showAll = false,
    this.isFloating = false,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.symmetric(vertical: 8, horizontal: 200.w),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 热门按钮
            HotButton(
              isFloating: isFloating,
              onTap: () {
                Get.toNamed(Routes.hotPage, id: Routes.mainGetId);
              },
            ),
            SizedBox(width: 8.w),
            // 分区按钮组
            Flexible(
              child: CategoryWrap(
                categories: categories,
                showAll: showAll,
                isFloating: isFloating,
                onSelect: onSelect,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 浮动分区组件（用于MainPage的浮动分区栏）
class FloatingCategoryExpansion extends StatelessWidget {
  final List categories;
  final void Function(String) onSelect;

  const FloatingCategoryExpansion({
    Key? key,
    required this.categories,
    required this.onSelect,
  }) : super(key: key);

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
                    return CategoryButton(
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
                        // 鼠标进入时展开
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
                                  return CategoryButton(
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
                      return CategoryButton(
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

/// 分区按钮包装组件
class CategoryWrap extends StatelessWidget {
  final List categories;
  final void Function(String) onSelect;
  final bool showAll;
  final bool isFloating;

  const CategoryWrap({
    Key? key,
    required this.categories,
    required this.onSelect,
    this.showAll = false,
    this.isFloating = false,
  }) : super(key: key);

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
          return CategoryButton(
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

/// 单个分区按钮组件
class CategoryButton extends StatefulWidget {
  final Map cat;
  final bool hasChildren;
  final void Function(String) onSelect;
  final int index;

  const CategoryButton({
    Key? key,
    required this.cat,
    required this.hasChildren,
    required this.onSelect,
    required this.index,
  }) : super(key: key);

  @override
  State<CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<CategoryButton>
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
                            print('点击子分区: ${widget.cat['categoryName']}-${child['categoryName']}');
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
          print('点击一级分区: ${widget.cat['categoryName']}');
          widget.onSelect(widget.cat['categoryName']);
          if (widget.hasChildren) _removeChildrenOverlay();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 18.w),
          decoration: BoxDecoration(
            color: _hovered ? Colors.grey[300] : Colors.grey[200],
            borderRadius: BorderRadius.circular(7.r),
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.15), blurRadius: 4.r)
                  ]
                : [],
          ),
          child: SizedBox(
              width: 80.w,
              height: 20.w,
              child: Center(
                child: Text(widget.cat['categoryName'],
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    )),
              )),
        ),
      ),
    );
  }
}

/// 浮动分区栏的SliverPersistentHeaderDelegate
class FloatingCategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final List categories;
  final void Function(String) onSelect;

  FloatingCategoryHeaderDelegate({
    required this.categories,
    required this.onSelect,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: 120.w,
      child: FloatingCategoryExpansion(
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
  bool shouldRebuild(covariant FloatingCategoryHeaderDelegate oldDelegate) =>
      categories != oldDelegate.categories;
}
