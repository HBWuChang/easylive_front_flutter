import 'dart:async';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:easylive/Funcs.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/settings.dart';
import 'package:easylive/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers-class.dart';
import '../../api_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:cross_file/cross_file.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

// 投币弹窗
Future<Map<String, dynamic>?> showCoinDialog() async {
  return await Get.dialog<Map<String, dynamic>>(
    _CoinDialogWidget(),
    barrierDismissible: true,
  );
}

class _CoinDialogWidget extends StatefulWidget {
  @override
  State<_CoinDialogWidget> createState() => _CoinDialogWidgetState();
}

class _CoinDialogWidgetState extends State<_CoinDialogWidget> {
  bool _hover1 = false;
  bool _hover2 = false;
  bool _checked = true;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('请选择投币数量',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(
                      width: 150,
                      child: Row(
                        children: [
                          Checkbox(
                              value: _checked,
                              onChanged: (value) {
                                setState(() {
                                  _checked = value ?? true;
                                });
                              }),
                          Text('同时点赞', style: TextStyle(fontSize: 16)),
                        ],
                      ))
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () =>
                        Get.back(result: {'coins': 1, 'like': _checked}),
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hover1 = true),
                      onExit: (_) => setState(() => _hover1 = false),
                      child: Container(
                        decoration: DottedDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: Shape.box,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          strokeWidth: 2,
                          dash: _hover1 ? [1, 0] : [6, 4], // 实线/虚线
                        ),
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            CoinSpriteAnimationWidget(
                              imagePath: 'assets/images/coin/22-coin-ani.png',
                              startFrame: 0,
                              frameCount: 24,
                              totalFrames: 24,
                              frameWidth: 187,
                              frameHeight: 300,
                              duration: Duration(milliseconds: 1200),
                              scale: 1,
                            ),
                            SizedBox(height: 8),
                            Text('投1个', style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 40),
                  GestureDetector(
                    onTap: () =>
                        Get.back(result: {'coins': 2, 'like': _checked}),
                    child: MouseRegion(
                      onEnter: (_) => setState(() => _hover2 = true),
                      onExit: (_) => setState(() => _hover2 = false),
                      child: Container(
                        decoration: DottedDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: Shape.box,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          strokeWidth: 2,
                          dash: _hover2 ? [1, 0] : [6, 4],
                        ),
                        padding: EdgeInsets.all(8),
                        child: Column(
                          children: [
                            CoinSpriteAnimationWidget(
                              imagePath: 'assets/images/coin/33-coin-ani.png',
                              startFrame: 0,
                              frameCount: 24,
                              totalFrames: 24,
                              frameWidth: 187,
                              frameHeight: 300,
                              duration: Duration(milliseconds: 1200),
                              scale: 1,
                            ),
                            SizedBox(height: 8),
                            Text('投2个', style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Get.back(result: null),
                child: Text('取消'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 投币精灵帧动画组件
class CoinSpriteAnimationWidget extends StatefulWidget {
  final String imagePath;
  final int startFrame;
  final int frameCount;
  final int totalFrames;
  final double frameWidth;
  final double frameHeight;
  final Duration duration;
  final double scale;
  const CoinSpriteAnimationWidget({
    required this.imagePath,
    required this.startFrame,
    required this.frameCount,
    this.totalFrames = 24,
    this.frameWidth = 187,
    this.frameHeight = 300,
    this.duration = const Duration(milliseconds: 800),
    this.scale = 0.3,
    Key? key,
  }) : super(key: key);
  @override
  State<CoinSpriteAnimationWidget> createState() =>
      _CoinSpriteAnimationWidgetState();
}

class _CoinSpriteAnimationWidgetState extends State<CoinSpriteAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _currentFrame;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..addListener(() {
        setState(() {
          _currentFrame = widget.startFrame +
              ((widget.frameCount * _controller.value)
                  .floor()
                  .clamp(0, widget.frameCount - 1));
        });
      });
    _currentFrame = widget.startFrame;
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.frameWidth * widget.scale,
      height: widget.frameHeight * widget.scale,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              left: -_currentFrame * widget.frameWidth * widget.scale,
              top: 0,
              child: Image.asset(
                widget.imagePath,
                width: widget.frameWidth * widget.totalFrames * widget.scale,
                height: widget.frameHeight * widget.scale,
                fit: BoxFit.none,
                filterQuality: FilterQuality.high,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 通用粒子动画按钮组件
class ParticleIconButton extends StatefulWidget {
  final bool isActive;
  final VoidCallback onPressed;
  final Widget icon;
  final Color particleColor;
  final bool disableRepeatEffect; // true: 已激活时不再播放动画
  const ParticleIconButton({
    required this.isActive,
    required this.onPressed,
    required this.icon,
    this.particleColor = Colors.pinkAccent,
    this.disableRepeatEffect = true,
    Key? key,
  }) : super(key: key);
  @override
  State<ParticleIconButton> createState() => _ParticleIconButtonState();
}

class _ParticleIconButtonState extends State<ParticleIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;
  bool _showParticles = false;
  static const int particleCount = 16;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showParticles = false);
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePressed() {
    if (widget.disableRepeatEffect && widget.isActive) {
      widget.onPressed();
      return;
    }
    setState(() => _showParticles = true);
    _controller.forward();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: widget.icon,
          onPressed: _handlePressed,
        ),
        if (_showParticles)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _anim,
                builder: (context, child) {
                  final particles = List.generate(particleCount, (i) {
                    final angle = (2 * 3.1415926 / particleCount) * i;
                    final radius = 0.0 + 28.0 * _anim.value;
                    final dx = radius * math.cos(angle);
                    final dy = radius * math.sin(angle);
                    final opacity = (1 - _anim.value).clamp(0.0, 1.0);
                    return Positioned(
                      left: 16 + dx,
                      top: 16 + dy,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: widget.particleColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  });
                  return Stack(children: particles);
                },
              ),
            ),
          ),
      ],
    );
  }
}

// 图片预览弹窗
class _ImagePreviewDialog extends StatefulWidget {
  final String imgUrl;
  const _ImagePreviewDialog({required this.imgUrl});

  @override
  State<_ImagePreviewDialog> createState() => _ImagePreviewDialogState();
}

class _ImagePreviewDialogState extends State<_ImagePreviewDialog> {
  double rotation = 0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(), // 点击图片外关闭
      child: Material(
        color: Colors.black54, // 半透明背景
        type: MaterialType.transparency,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Transform.rotate(
                      angle: rotation,
                      child: ExtendedImage.network(
                        widget.imgUrl,
                        fit: BoxFit.contain,
                        width: constraints.maxWidth * 0.95,
                        height: constraints.maxHeight * 0.95,
                        mode: ExtendedImageMode.gesture,
                        initGestureConfigHandler: (_) => GestureConfig(
                          minScale: 0.5,
                          maxScale: 5.0,
                          animationMinScale: 0.5,
                          animationMaxScale: 5.0,
                          speed: 1.0,
                          inertialSpeed: 100.0,
                          initialScale: 1.0,
                          inPageView: false,
                          initialAlignment: InitialAlignment.center,
                        ),
                      ));
                },
              ),
              Positioned(
                top: 24,
                right: 24,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Get.back(),
                ),
              ),
              Positioned(
                bottom: 32,
                right: 32,
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(Icons.rotate_right),
                      label: Text('旋转'),
                      onPressed: () {
                        setState(() {
                          rotation += 0.5 * 3.1415926; // 90度
                        });
                      },
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(Icons.download),
                      label: Text('保存到本地'),
                      onPressed: () async {
                        try {
                          final response =
                              await ExtendedNetworkImageProvider(widget.imgUrl)
                                  .getNetworkImageData();
                          final bytes = response;
                          final downloadsDir = await getDownloadDirectory();
                          final fileName = widget.imgUrl.split('/').last;
                          final file = await saveBytesToFile(
                              bytes!, downloadsDir, fileName);
                          Get.back();
                          Get.snackbar('提示', '图片已保存到: ${file.path}');
                        } catch (e) {
                          Get.snackbar('错误', '保存失败: $e');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 图片预览弹窗
class ImagePreviewDialog extends StatefulWidget {
  final String imgUrl;
  const ImagePreviewDialog({required this.imgUrl});

  @override
  State<ImagePreviewDialog> createState() => ImagePreviewDialogState();
}

class ImagePreviewDialogState extends State<ImagePreviewDialog> {
  double rotation = 0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.back(), // 点击图片外关闭
      child: Material(
        color: Colors.black54, // 半透明背景
        type: MaterialType.transparency,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  return Transform.rotate(
                      angle: rotation,
                      child: ExtendedImage.network(
                        widget.imgUrl,
                        fit: BoxFit.contain,
                        width: constraints.maxWidth * 0.95,
                        height: constraints.maxHeight * 0.95,
                        mode: ExtendedImageMode.gesture,
                        initGestureConfigHandler: (_) => GestureConfig(
                          minScale: 0.5,
                          maxScale: 5.0,
                          animationMinScale: 0.5,
                          animationMaxScale: 5.0,
                          speed: 1.0,
                          inertialSpeed: 100.0,
                          initialScale: 1.0,
                          inPageView: false,
                          initialAlignment: InitialAlignment.center,
                        ),
                      ));
                },
              ),
              Positioned(
                top: 24,
                right: 24,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Get.back(),
                ),
              ),
              Positioned(
                bottom: 32,
                right: 32,
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(Icons.rotate_right),
                      label: Text('旋转'),
                      onPressed: () {
                        setState(() {
                          rotation += 0.5 * 3.1415926; // 90度
                        });
                      },
                    ),
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black54,
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(Icons.download),
                      label: Text('保存到本地'),
                      onPressed: () async {
                        try {
                          final response =
                              await ExtendedNetworkImageProvider(widget.imgUrl)
                                  .getNetworkImageData();
                          final bytes = response;
                          final downloadsDir = await getDownloadDirectory();
                          final fileName = widget.imgUrl.split('/').last;
                          final file = await saveBytesToFile(
                              bytes!, downloadsDir, fileName);
                          Get.back();
                          Get.snackbar('提示', '图片已保存到: ${file.path}');
                        } catch (e) {
                          Get.snackbar('错误', '保存失败: $e');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 新增可展开/收起的评论内容组件
class ExpandableCommentContent extends StatefulWidget {
  final String content;
  final String? replyNickName;
  const ExpandableCommentContent(
      {required this.content, this.replyNickName, Key? key})
      : super(key: key);

  @override
  State<ExpandableCommentContent> createState() =>
      ExpandableCommentContentState();
}

class ExpandableCommentContentState extends State<ExpandableCommentContent> {
  bool expanded = false;
  bool needExpand = false;
  final int maxLines = 5;
  @override
  Widget build(BuildContext context) {
    final text = widget.content;
    final textStyle =
        TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface);
    return LayoutBuilder(
      builder: (context, constraints) {
        double realMaxWidth = 300;
        // 先用TextPainter判断是否超出maxLines
        final span = TextSpan(text: text, style: textStyle);
        final tp = TextPainter(
          text: span,
          maxLines: maxLines,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: realMaxWidth);
        needExpand = tp.didExceedMaxLines;
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: realMaxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    if (widget.replyNickName != null)
                      TextSpan(
                        text: '回复 ',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                          fontSize: 16,
                        ),
                      ),
                    if (widget.replyNickName != null)
                      TextSpan(
                        text: '${widget.replyNickName}：',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    TextSpan(
                      text: text,
                      style: textStyle,
                    ),
                  ],
                ),
                maxLines: expanded ? null : maxLines,
                overflow:
                    expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                softWrap: true,
              ),
              if (needExpand)
                TextButton(
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.zero, minimumSize: Size(40, 24)),
                  onPressed: () => setState(() => expanded = !expanded),
                  child: Text(expanded ? '收起' : '展开',
                      style: TextStyle(fontSize: 14)),
                ),
            ],
          ),
        );
      },
    );
  }
}

// 子评论展示组件
class ChildCommentItemWidget extends StatelessWidget {
  final String userName;
  final String? replyNickName;
  final String content;
  const ChildCommentItemWidget(
      {required this.userName,
      this.replyNickName,
      required this.content,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: "$userName：",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (replyNickName != null)
              TextSpan(
                text: '回复 ',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontSize: 15,
                ),
              ),
            if (replyNickName != null)
              TextSpan(
                text: '${replyNickName}：',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            TextSpan(
              text: content,
              style: TextStyle(
                  fontSize: 15, color: Theme.of(context).colorScheme.onSurface),
            ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.start,
        softWrap: true,
      ),
    );
  }
}
