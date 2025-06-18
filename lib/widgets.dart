import 'package:easylive/Funcs.dart';
import 'package:easylive/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'api_service.dart';
import 'package:extended_image/extended_image.dart';
import 'dart:math' as math;

Widget Avatar({String? avatarValue, double? radius = 16, Key? key}) {
  // 如果avatarValue为空或null，显示默认头像
  // 否则显示网络头像
  if (avatarValue == null || avatarValue.isEmpty) {
    return CircleAvatar(
      key: key,
      radius: radius!,
      backgroundImage: AssetImage(Constants.defaultAvatar),
    );
  } else {
    return CircleAvatar(
      key: key,
      radius: radius!,
      backgroundImage: ExtendedNetworkImageProvider(
        ApiService.baseUrl + ApiAddr.fileGetResourcet + avatarValue,
      ),
    );
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
            style: TextStyle(fontSize: 20, color: Colors.black87),
          ),
        ),
        Text(
          info,
          style: TextStyle(fontSize: 12, color: Colors.black54),
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

class _HoverFollowWidgetState extends State<HoverFollowWidget> with TickerProviderStateMixin {
  Offset _offset = Offset.zero;
  Offset _targetOffset = Offset.zero;
  Offset? _lastPointer;
  late Ticker _ticker;
  final double _spring = 0.12; // 回中速度
  final double _follow = 0.5;  // 跟随鼠标的速度

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
