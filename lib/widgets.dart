import 'package:easylive/Funcs.dart';
import 'package:easylive/pages/VideoPlayPage/VideoPlayPageInfoWidgets.dart';
import 'package:easylive/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'api_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget Avatar(
    {String? avatarValue,
    double? radius = 16,
    Key? key,
    bool showOnTap = false,
    String? userId}) {
  // 如果avatarValue为空或null，显示默认头像
  // 否则显示网络头像
  avatarValue = avatarValue ?? '';
  Widget t = CircleAvatar(
      key: key,
      radius: radius!.r,
      backgroundImage: ExtendedNetworkImageProvider(
        ApiService.baseUrl + ApiAddr.fileGetResourcet + avatarValue,
      ));
  if (avatarValue.isEmpty) {
    return CircleAvatar(
      key: key,
      radius: radius.r,
      backgroundImage: AssetImage(Constants.defaultAvatar),
    );
  } else {
    if ((showOnTap) || (userId != null)) {
      return GestureDetector(
          onTap: () {
            if (showOnTap) {
              final imgUrl =
                  ApiService.baseUrl + ApiAddr.fileGetResourcet + avatarValue!;
              Get.dialog(ImagePreviewDialog(imgUrl: imgUrl));
            }
            if (userId != null) {
              Get.toNamed('${Routes.uhome}/$userId', id: Routes.mainGetId);
            }
          },
          child: t);
    }
    return t;
  }
}

Widget accountDialogNumWidget(String info, {int? count}) {
  int showCount = count ?? 0;
  String showText = toShowNumText(showCount);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: '$showCount',
          child: Text(
            showText,
            style: TextStyle(fontSize: 20.sp, color: Colors.black87),
          ),
        ),
        Text(
          info,
          style: TextStyle(fontSize: 12.sp, color: Colors.black54),
        ),
      ],
    ),
  );
}

Widget DividerWithPaddingHorizontal({
  double padding = 32.0,
  Color? color,
}) {
  final Color effectiveColor = color ?? Colors.grey[300]!;
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: padding),
    child: Divider(
      color: effectiveColor,
      height: 1,
    ),
  );
}

Widget DividerWithPaddingVertical({
  double padding = 32.0,
  Color? color,
}) {
  final Color effectiveColor = color ?? Colors.grey[300]!;
  return Padding(
    padding: EdgeInsets.symmetric(vertical: padding),
    child: VerticalDivider(
      color: effectiveColor,
      width: 1,
    ),
  );
}

class HoverFollowWidget extends StatefulWidget {
  final Widget child;
  final double maxOffset;
  final double sensitivity;
  final Duration duration;

  /// sensitivity 控制控件移动的灵敏度，1.0为等距，2.0为2倍，0.5为一半
  const HoverFollowWidget({
    Key? key,
    required this.child,
    this.maxOffset = 8.0,
    this.sensitivity = 0.5,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  State<HoverFollowWidget> createState() => _HoverFollowWidgetState();
}

class _HoverFollowWidgetState extends State<HoverFollowWidget>
    with TickerProviderStateMixin {
  Offset _offset = Offset.zero;
  Offset _targetOffset = Offset.zero;
  Offset? _lastPointer;
  late Ticker _ticker;
  final double _spring = 0.12; // 回中速度
  final double _follow = 0.5; // 跟随鼠标的速度

  @override
  void initState() {
    super.initState();
    _ticker = this.createTicker(_tick)..start();
  }

  void _tick(Duration _) {
    _targetOffset = Offset.lerp(_targetOffset, Offset.zero, _spring)!;
    setState(() {
      _offset = Offset.lerp(_offset, _targetOffset, _follow)!;
      if (_offset.distance < 0.1) _offset = Offset.zero;
      if (_targetOffset.distance < 0.1) _targetOffset = Offset.zero;
    });
  }

  void _onEnter(PointerEnterEvent event) {
    _lastPointer = event.localPosition;
  }

  void _onHover(PointerHoverEvent event, BoxConstraints constraints) {
    if (_lastPointer == null) {
      _lastPointer = event.localPosition;
      return;
    }
    Offset delta = (event.localPosition - _lastPointer!) * widget.sensitivity;
    Offset newTarget = _targetOffset + delta;
    if (newTarget.distance > widget.maxOffset) {
      newTarget = Offset.fromDirection(newTarget.direction, widget.maxOffset);
    }
    _targetOffset = newTarget;
    _lastPointer = event.localPosition;
  }

  void _onExit(PointerExitEvent event) {
    _lastPointer = null;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => MouseRegion(
        onEnter: _onEnter,
        onHover: (e) => _onHover(e, constraints),
        onExit: _onExit,
        child: Transform.translate(
          offset: _offset,
          child: widget.child,
        ),
      ),
    );
  }
}

/// 带动画横条的页面切换标签栏 Widget
class AnimatedTabBarWidget extends StatelessWidget {
  final dynamic pageController; // 支持 PageController 和 PreloadPageController
  final List<TextSpan> tabLabels;
  final double? barHeight;
  final double? barWidthMultiplier;
  final double? spacing;
  final double? containerHeight;

  const AnimatedTabBarWidget({
    Key? key,
    required this.pageController,
    required this.tabLabels,
    this.barHeight = 4.0,
    this.barWidthMultiplier = 0.7,
    this.spacing = 8.0,
    this.containerHeight = 38.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: containerHeight!.w,
      child: Column(
        children: [
          SizedBox(
            height: (containerHeight! - barHeight! - spacing!).w,
            child: Row(
              children: List.generate(tabLabels.length, (index) {
                return Expanded(
                  child: AnimatedBuilder(
                    animation: pageController,
                    builder: (context, child) {
                      double page = 0.0;
                      try {
                        page = pageController.hasClients &&
                                pageController.page != null
                            ? pageController.page!
                            : pageController.initialPage.toDouble();
                      } catch (_) {}

                      // 判断当前标签是否为选中状态
                      bool isSelected = (page.round() == index);

                      return TextButton(
                        onPressed: () {
                          pageController.animateToPage(
                            index,
                            duration: Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                        child: HoverFollowWidget(
                          child: Text.rich(
                            tabLabels[index],
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: spacing!.w),
          SizedBox(
            height: barHeight!.w,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedBuilder(
                  animation: pageController,
                  builder: (context, child) {
                    double page = 0.0;
                    try {
                      page = pageController.hasClients &&
                              pageController.page != null
                          ? pageController.page!
                          : pageController.initialPage.toDouble();
                    } catch (_) {}

                    double tabWidth = constraints.maxWidth / tabLabels.length;
                    double minLine = tabWidth * barWidthMultiplier!;
                    double maxLine = tabWidth * (barWidthMultiplier! + 0.7);

                    double progress = (page - page.floor()).abs();
                    double dist = (progress > 0.5) ? 1 - progress : progress;
                    double lineWidth =
                        minLine + (maxLine - minLine) * (dist * 2);
                    double left = page * tabWidth + (tabWidth - lineWidth) / 2;

                    return Stack(
                      children: [
                        Positioned(
                          left: left,
                          width: lineWidth.w,
                          top: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            height: barHeight!.w,
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 可点击查看全文的文本组件
class ExpandableText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int maxLines;
  final TextAlign textAlign;

  const ExpandableText({
    Key? key,
    required this.text,
    this.style,
    this.maxLines = 1,
    this.textAlign = TextAlign.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth.w);

        final isOverflowing = textPainter.didExceedMaxLines;

        return GestureDetector(
          onTap: isOverflowing ? () => _showFullTextDialog(context) : null,
          child: Text(
            text,
            style: style?.copyWith(
                    // color: isOverflowing
                    // ? Theme.of(context).primaryColor
                    // : style?.color,
                    ) ??
                TextStyle(
                    // color: isOverflowing ? Theme.of(context).primaryColor : null,
                    ),
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            textAlign: textAlign,
          ),
        );
      },
    );
  }

  void _showFullTextDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Container(
          width: (MediaQuery.of(context).size.width * 0.6).w,
          constraints: BoxConstraints(
            maxHeight: (MediaQuery.of(context).size.height * 0.6).w,
          ),
          padding: const EdgeInsets.all(24),
          child: Flexible(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
              child: SelectableText(
                text,
                style: style ??  TextStyle(fontSize: 14.sp),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// 可点击跳转用户主页的昵称文本组件
class NickNameTextWidget extends StatelessWidget {
  final String text;
  final String? userId;
  final TextStyle? style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final double? textScaleFactor;
  final String? semanticsLabel;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;

  const NickNameTextWidget(
    this.text, {
    Key? key,
    this.userId,
    this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.textScaleFactor,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style?.copyWith(
          color: style?.color,
        ) ??
        TextStyle();

    return GestureDetector(
      onTap: userId != null ? () => _onTap() : null,
      child: MouseRegion(
        cursor: userId != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: Text(
          text,
          style: effectiveStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          softWrap: softWrap,
          textScaleFactor: textScaleFactor,
          semanticsLabel: semanticsLabel,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
        ),
      ),
    );
  }

  void _onTap() {
    if (userId == null || userId!.isEmpty) return;
    Get.toNamed('${Routes.uhome}/$userId', id: Routes.mainGetId);

    debugPrint('点击了用户昵称: $text, userId: $userId');
  }
}
