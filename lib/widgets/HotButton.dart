import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 热门按钮组件
/// 支持默认状态和浮动状态，带有悬停效果
class HotButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isFloating;
  
  const HotButton({
    Key? key,
    required this.onTap,
    this.isFloating = false,
  }) : super(key: key);

  @override
  State<HotButton> createState() => _HotButtonState();
}

class _HotButtonState extends State<HotButton> {
  bool _hovered = false;
  
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 100.w,
          height: (widget.isFloating ? 44 : 48).w, // 浮动状态下稍小，原始状态下两行高度
          padding: EdgeInsets.symmetric(vertical: 8.w, horizontal: 18.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _hovered
                  ? [Colors.red.shade400, Colors.red.shade600]
                  : [Colors.red.shade300, Colors.red.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 8.r,
                      spreadRadius: 2.r,
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.2),
                      blurRadius: 4.r,
                      spreadRadius: 1.r,
                    )
                  ],
          ),
          child: Center(
            child: Text(
              '热门',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 2,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
