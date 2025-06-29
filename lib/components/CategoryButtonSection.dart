import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 分区按钮组件，可复用于 MainPage 和 CategoryPage
class CategoryButtonSection extends StatelessWidget {
  final List categories;
  final void Function(String) onSelect;
  final bool showHotButton;
  final VoidCallback? onHotTap;
  
  const CategoryButtonSection({
    Key? key,
    required this.categories,
    required this.onSelect,
    this.showHotButton = true,
    this.onHotTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 热门按钮（两行高）
            if (showHotButton) ...[
              _HotButton(onTap: onHotTap),
              SizedBox(width: 8.w),
            ],
            // 分区按钮组
            Flexible(
              child: _CategoryWrap(
                categories: categories,
                onSelect: onSelect,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 热门按钮组件
class _HotButton extends StatelessWidget {
  final VoidCallback? onTap;
  
  const _HotButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80.w,
        height: 48.w, // 两行高
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B6B),
              Color(0xFFFF8E8E),
            ],
          ),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '热门',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// 分区按钮组
class _CategoryWrap extends StatelessWidget {
  final List categories;
  final void Function(String) onSelect;

  const _CategoryWrap({
    required this.categories,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.w, horizontal: 4.w),
      child: Wrap(
        spacing: 4.w,
        runSpacing: 4.w,
        children: List.generate(categories.length, (index) {
          final cat = categories[index];
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

/// 分区按钮
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var child in widget.cat['children'])
                        GestureDetector(
                          onTap: () {
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
                            child: Text(
                              child['categoryName'],
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.black87,
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
        );
      },
    );
    overlayState.insert(_childrenOverlay!);
    _fadeController!.forward();
  }

  void _removeChildrenOverlay() {
    _fadeController?.reverse().then((_) {
      _childrenOverlay?.remove();
      _childrenOverlay = null;
      _fadeController?.dispose();
      _fadeController = null;
    });
  }

  void _startFadeTimer() {
    _fadeTimer?.cancel();
    _fadeTimer = Timer(Duration(milliseconds: 300), () {
      _removeChildrenOverlay();
      _hovered = false;
    });
  }

  void _cancelFadeTimer() {
    _fadeTimer?.cancel();
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _removeChildrenOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = widget.cat['categoryName'] ?? '';
    
    return MouseRegion(
      onEnter: (_) {
        _hovered = true;
        if (widget.hasChildren) {
          _showChildrenOverlay(context);
        }
      },
      onExit: (_) {
        if (widget.hasChildren) {
          _startFadeTimer();
        }
        _hovered = false;
      },
      child: GestureDetector(
        onTap: () {
          if (widget.hasChildren) {
            // 如果有子分区，不直接选择，显示子分区
            if (_childrenOverlay == null) {
              _showChildrenOverlay(context);
            }
          } else {
            // 如果没有子分区，直接选择
            widget.onSelect(categoryName);
          }
        },
        child: Container(
          height: 22.w,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.w),
          decoration: BoxDecoration(
            color: _hovered ? Colors.grey[200] : Colors.grey[100],
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: Colors.grey[300]!,
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              categoryName,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
