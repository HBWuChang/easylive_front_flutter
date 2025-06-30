import 'dart:async';
import 'package:easylive/enums.dart';
import 'package:easylive/pages/MainPage/VideoInfoWidget.dart';
import 'package:easylive/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controllers-class.dart';
import '../../api_service.dart';
import 'package:extended_image/extended_image.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 推荐视频区域组件
class RecommendVideoArea extends StatelessWidget {
  const RecommendVideoArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VideoLoadRecommendVideoController videoLoadRecommendVideoController =
        Get.find<VideoLoadRecommendVideoController>();

    return GetBuilder<VideoLoadRecommendVideoController>(
      init: videoLoadRecommendVideoController, // 保证 controller 不为 null
      builder: (videoController) {
        final List<VideoInfo> videos = videoController.recommendVideos;
        final List<VideoInfo> carouselVideos = videos.take(5).toList();
        final List<VideoInfo> recommendVideos = videos.skip(5).take(6).toList();
        return Column(children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.w),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 设定整体宽高比，例如 16:5
                double aspectRatio =
                    AspectRatioEnum.MainPageRecommendVideoArea.ratio;
                double width = constraints.maxWidth - 228.w;
                double height = width / aspectRatio;
                return SizedBox(
                  width: width,
                  height: height,
                  child: AspectRatio(
                    aspectRatio: aspectRatio,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 左侧轮播区
                        Expanded(
                          flex: 2,
                          child: AspectRatio(
                            aspectRatio: AspectRatioEnum
                                .MainPageRecommendVideoLeft.ratio,
                            child: carouselVideos.isEmpty
                                ? Center(child: SelectableText('暂无推荐'))
                                : CarouselVideoWidget(videos: carouselVideos),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // 右侧2x3推荐区
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: double.infinity,
                            child: GridView.builder(
                              padding: EdgeInsets.zero, // 保证顶部无额外间距
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 12.w,
                                crossAxisSpacing: 12.w,
                                childAspectRatio: AspectRatioEnum
                                    .MainPageRecommendVideoRightchild.ratio,
                              ),
                              itemCount: recommendVideos.length,
                              itemBuilder: (context, idx) {
                                return VideoInfoWidget(
                                    video: recommendVideos[idx]);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ), // 占位控件
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 114.w),
              child: Obx(() {
                return GridView.builder(
                  padding: EdgeInsets.zero, // 保证顶部无额外间距
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12.w,
                    crossAxisSpacing: 12.w,
                    childAspectRatio:
                        AspectRatioEnum.MainPageRecommendVideoRightchild.ratio,
                  ),
                  itemCount:
                      videoLoadRecommendVideoController.mainPageVideos.length,
                  itemBuilder: (context, index) {
                    final video =
                        videoLoadRecommendVideoController.mainPageVideos[index];
                    return VideoInfoWidget(
                      video: video,
                    );
                  },
                );
              })),
        ]);
      },
    );
  }
}

// 轮播区自动轮播组件
class CarouselVideoWidget extends StatefulWidget {
  final List<VideoInfo> videos;
  const CarouselVideoWidget({required this.videos, Key? key}) : super(key: key);
  @override
  State<CarouselVideoWidget> createState() => _CarouselVideoWidgetState();
}

class _CarouselVideoWidgetState extends State<CarouselVideoWidget> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  bool _hovering = false;
  final Map<int, Color> _avgColorCache = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 3), (_) {
      if (!_hovering && widget.videos.length > 1) {
        setState(() {
          _currentPage = (_currentPage + 1) % widget.videos.length;
        });
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // 跳转到视频详情页面
  void _navigateToVideo(VideoInfo video) {
    // 这里可以根据你的路由系统进行跳转
    // 例如使用 Get.to() 或者 Navigator.push()

    // 示例1: 使用Get路由 (如果你使用GetX)
    Get.toNamed('${Routes.videoPlayPage}/${video.videoId}',
        id: Routes.mainGetId);

    // 示例2: 使用Navigator (Flutter标准路由)
    // Navigator.pushNamed(context, '/video-detail', arguments: video);

    // 示例3: 打印视频信息 (临时调试用)
    print('点击了视频: ${video.videoName} (ID: ${video.videoId})');

    // 请根据你的具体需求修改这里的跳转逻辑
    // 你可能需要导航到播放页面或详情页面
  }

  @override
  dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hovering = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovering = false;
        });
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 计算16:9的图片高度
          final double imageHeight = constraints.maxWidth / (16 / 9);
          // 计算额外的不透明区域高度（用于放置标题和按钮）
          final double opaqueHeight = imageHeight * 0.18; // 图片高度的15%

          return SizedBox(
            height: (imageHeight + opaqueHeight),
            child: Stack(
              children: [
                // 图片滚动区域 - 严格16:9比例
                SizedBox(
                  height: imageHeight,
                  child: ExcludeSemantics(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.videos.length,
                      onPageChanged: (idx) {
                        setState(() {
                          _currentPage = idx;
                        });
                      },
                      itemBuilder: (context, idx) {
                        final video = widget.videos[idx];
                        return GestureDetector(
                          onTap: () {
                            // 跳转到视频详情页面
                            _navigateToVideo(video);
                          },
                          child: Semantics(
                            label: '视频: ${video.videoName ?? "未知标题"}',
                            button: true,
                            child: Stack(
                              key: ValueKey('carousel_item_$idx'),
                              children: [
                                // 图片本体
                                SizedBox(
                                  width: constraints.maxWidth,
                                  height: imageHeight,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(8.r),
                                    ),
                                    child: video.videoCover != null &&
                                            video.videoCover!.isNotEmpty
                                        ? ExtendedImage.network(
                                            Constants.baseUrl +
                                                ApiAddr.fileGetResourcet +
                                                video.videoCover!,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(color: Colors.grey[200]),
                                  ),
                                ),
                                // 图片内部的渐变阴影
                                Positioned(
                                  left: 0,
                                  right: 0,
                                  bottom: 0,
                                  child: FutureBuilder<Color>(
                                    future: _getBottomAverageColor(idx),
                                    builder: (context, snapshot) {
                                      final baseColor =
                                          snapshot.data ?? Colors.black;
                                      return Container(
                                        height: (imageHeight *
                                            0.25), // 减小渐变区域到图片高度的25%
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              baseColor.withOpacity(0.3),
                                              baseColor, // 完全不透明
                                            ],
                                            stops: [0.0, 0.3, 1.0], // 加快变深速度
                                          ),
                                        ),
                                      );
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
                ),
                // 固定的不透明区域（放置标题和按钮）
                Positioned(
                  left: 0,
                  right: 0,
                  top: imageHeight,
                  height: opaqueHeight,
                  child: FutureBuilder<Color>(
                    future: _getBottomAverageColor(_currentPage),
                    builder: (context, snapshot) {
                      final baseColor = snapshot.data ?? Colors.black;
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 400),
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(8.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: baseColor.withOpacity(0.4),
                              blurRadius: 20.r,
                              spreadRadius: 2.r,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _buildContentBar(
                            context, widget.videos[_currentPage], _currentPage),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 新增：构建不透明区域的内容（标题和按钮）
  Widget _buildContentBar(BuildContext context, VideoInfo video, int idx) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左侧标题
          Expanded(
            child: Semantics(
              label: '当前视频标题',
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
                child: Text(
                  video.videoName ?? '',
                  key: ValueKey('title_$idx'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ),
          // 圆点指示器
          Semantics(
            label: '轮播指示器',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.videos.length, (dotIdx) {
                final bool isActive = dotIdx == _currentPage;
                return Semantics(
                  label: '第${dotIdx + 1}个视频${isActive ? "，当前选中" : ""}',
                  button: true,
                  child: GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        dotIdx,
                        duration: Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      margin: EdgeInsets.symmetric(horizontal: 3),
                      width: (isActive ? 14 : 6).w,
                      height: (isActive ? 14 : 6).w,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.white54,
                        shape: BoxShape.circle,
                        boxShadow: isActive
                            ? [BoxShadow(color: Colors.black26, blurRadius: 4)]
                            : [],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          SizedBox(width: 8.w),
          // 右侧箭头按钮
          Row(
            children: [
              _buildArrowButton(context, false),
              SizedBox(width: 6.w),
              _buildArrowButton(context, true),
            ],
          ),
        ],
      ),
    );
  }

  Future<Color> _getBottomAverageColor(int idx) async {
    if (_avgColorCache.containsKey(idx)) return _avgColorCache[idx]!;
    final video = widget.videos[idx];
    if (video.videoCover == null || video.videoCover!.isEmpty) {
      _avgColorCache[idx] = Colors.black.withOpacity(0.85);
      return _avgColorCache[idx]!;
    }
    final imageProvider = ExtendedNetworkImageProvider(
      Constants.baseUrl + ApiAddr.fileGetResourcet + video.videoCover!,
    );
    final Completer<ui.Image> completer = Completer();
    final stream = imageProvider.resolve(ImageConfiguration());
    late ImageStreamListener listener;
    listener = ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info.image);
      stream.removeListener(listener);
    }, onError: (dynamic _, __) {
      completer.completeError('error');
      stream.removeListener(listener);
    });
    stream.addListener(listener);
    try {
      final ui.Image img = await completer.future;
      final int width = img.width;
      final int height = img.height;
      final int bottomH = (height * 0.2).toInt(); // 增加采样区域到20%
      final ByteData? data =
          await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) throw Exception('no data');
      int r = 0, g = 0, b = 0, count = 0;
      for (int y = height - bottomH; y < height; y++) {
        for (int x = 0; x < width; x++) {
          int i = (y * width + x) * 4;
          r += data.getUint8(i);
          g += data.getUint8(i + 1);
          b += data.getUint8(i + 2);
          count++;
        }
      }
      // 计算平均颜色并增强饱和度
      final avgR = r ~/ count;
      final avgG = g ~/ count;
      final avgB = b ~/ count;

      // 增强颜色深度，避免过于浅色
      final enhancedR = (avgR * 0.8).round().clamp(0, 255);
      final enhancedG = (avgG * 0.8).round().clamp(0, 255);
      final enhancedB = (avgB * 0.8).round().clamp(0, 255);

      // 如果颜色太浅，强制使用较深的版本
      final luminance =
          (0.299 * enhancedR + 0.587 * enhancedG + 0.114 * enhancedB) / 255;
      if (luminance > 0.6) {
        // 如果亮度太高，进一步压暗
        final finalR = (enhancedR * 0.5).round().clamp(0, 255);
        final finalG = (enhancedG * 0.5).round().clamp(0, 255);
        final finalB = (enhancedB * 0.5).round().clamp(0, 255);
        _avgColorCache[idx] = Color.fromARGB(255, finalR, finalG, finalB);
      } else {
        _avgColorCache[idx] =
            Color.fromARGB(255, enhancedR, enhancedG, enhancedB);
      }

      return _avgColorCache[idx]!;
    } catch (e) {
      _avgColorCache[idx] = Colors.black.withOpacity(0.85);
      return _avgColorCache[idx]!;
    }
  }

  // 新增方法：构建箭头按钮
  Widget _buildArrowButton(BuildContext context, bool isRight) {
    return Semantics(
      label: isRight ? '下一个视频' : '上一个视频',
      button: true,
      child: GestureDetector(
        onTap: () {
          int next = isRight ? _currentPage + 1 : _currentPage - 1;
          if (isRight && next < widget.videos.length) {
            _pageController.animateToPage(
              next,
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          } else if (!isRight && next >= 0) {
            _pageController.animateToPage(
              next,
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          } else if (isRight && next >= widget.videos.length) {
            // 循环到第一页
            _pageController.animateToPage(
              0,
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          } else if (!isRight && next < 0) {
            // 循环到最后一页
            _pageController.animateToPage(
              widget.videos.length - 1,
              duration: Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            );
          }
        },
        child: Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(14.w),
          ),
          child: Icon(
            isRight ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
            color: Colors.white,
            size: 14.w,
          ),
        ),
      ),
    );
  }
}
