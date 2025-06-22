import 'dart:async';
import 'package:easylive/Funcs.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/pages/MainPage/VideoInfoWidget.dart';
import 'package:easylive/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/controllers-class.dart';
import '../../api_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'dart:ui' as ui;

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
  final VideoLoadRecommendVideoController videoLoadRecommendVideoController =
      Get.find<VideoLoadRecommendVideoController>();

  void _minScrollListener() {
    if (appBarController.scrollController.offset < kToolbarHeight) {
      appBarController.scrollController.jumpTo(kToolbarHeight);
    }
  }

  @override
  void initState() {
    super.initState();
    appBarController.scrollController.addListener(_minScrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appBarController.scrollController.hasClients &&
          appBarController.scrollController.offset < kToolbarHeight) {
        appBarController.scrollController.jumpTo(kToolbarHeight);
      }
    });
  }

  @override
  void dispose() {
    appBarController.scrollController.removeListener(_minScrollListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      clipBehavior: Clip.none,
      controller: appBarController.scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            children: [
              SizedBox(
                height: appBarController.imgHeight,
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
        SliverPersistentHeader(
          pinned: true,
          delegate: _SimpleHeaderDelegate(
            child: MouseRegion(
              onEnter: (_) => categoryViewStateController.showAll.value = true,
              onExit: (_) => categoryViewStateController.showAll.value = false,
              child: GetBuilder<CategoryLoadAllCategoryController>(
                init: categoryLoadAllCategoryController,
                builder: (_) {
                  final categories =
                      categoryLoadAllCategoryController.categories;
                  return Center(
                    child: _CategoryWrap(
                      categories: categories,
                      showAll: true, // 主页面分区默认全部显示
                      onSelect: (String displayName) {
                        categoryViewStateController.selectedCategoryName.value =
                            displayName;
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            // 轮播推荐视频区
            GetBuilder<VideoLoadRecommendVideoController>(
              init: videoLoadRecommendVideoController, // 保证 controller 不为 null
              builder: (videoController) {
                final List<VideoInfo> videos = videoController.recommendVideos;
                final List<VideoInfo> carouselVideos = videos.take(5).toList();
                final List<VideoInfo> recommendVideos =
                    videos.skip(5).take(6).toList();
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // 设定整体宽高比，例如 16:5
                      double aspectRatio =
                          AspectRatioEnum.MainPageRecommendVideoArea.ratio;
                      double width = constraints.maxWidth;
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
                                      ? Center(child: Text('暂无推荐'))
                                      : CarouselVideoWidget(
                                          videos: carouselVideos),
                                ),
                              ),
                              SizedBox(width: 16),
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
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      childAspectRatio: AspectRatioEnum
                                          .MainPageRecommendVideoRightchild
                                          .ratio,
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
                );
              },
            ),
            // 占位控件
            SizedBox(height: 24),
            Obx(() {
              final selected =
                  categoryViewStateController.selectedCategoryName.value;
              return Column(
                children: [
                  for (int i = 0; i < 20; i++)
                    Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        height: 80,
                        alignment: Alignment.center,
                        child: Text(
                          selected.isEmpty ? '占位内容 $i' : '$selected $i',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ]),
        ),
        // 新增的分区Overlay
        SliverToBoxAdapter(
          child: CategoryOverlayBar(
            categoryLoadAllCategoryController:
                categoryLoadAllCategoryController,
            categoryViewStateController: categoryViewStateController,
          ),
        ),
      ],
    );
  }
}

// 新增：Getx分区状态控制器
class CategoryViewStateController extends GetxController {
  var showAll = false.obs;
  var selectedCategoryName = ''.obs;
}

// 新增：分区按钮Wrap及弹窗组件
class _CategoryWrap extends StatelessWidget {
  final List categories;
  final void Function(String) onSelect;
  final bool showAll;
  final bool enableChildrenPopup;
  const _CategoryWrap({
    required this.categories,
    required this.onSelect,
    this.showAll = false,
    this.enableChildrenPopup = true,
  });
  @override
  Widget build(BuildContext context) {
    final WindowSizeController windowSizeController =
        Get.find<WindowSizeController>();
    // 监听窗口宽度变化
    WidgetsBinding.instance.addPostFrameCallback((_) {
      windowSizeController.updateWidth(MediaQuery.of(context).size.width);
    });
    return Obx(() {
      final cats = categories;
      final width = windowSizeController.width.value;
      int maxPerRow = ((width - 400) / 138).floor();
      if (maxPerRow < 1) maxPerRow = 1;
      final displayCats = showAll
          ? cats.take(maxPerRow * 2).toList()
          : cats.take(maxPerRow).toList();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(displayCats.length, (index) {
            final cat = displayCats[index];
            final hasChildren =
                cat['children'] != null && (cat['children'] as List).isNotEmpty;
            return _CategoryButton(
              cat: cat,
              hasChildren: hasChildren,
              onSelect: onSelect,
              index: index,
              enableChildrenPopup: enableChildrenPopup,
            );
          }),
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
  final bool enableChildrenPopup;
  const _CategoryButton(
      {required this.cat,
      required this.hasChildren,
      required this.onSelect,
      required this.index,
      this.enableChildrenPopup = true});
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
          bottom: MediaQuery.of(context).size.height -
              kToolbarHeight -
              rect.top +
              4,
          child: MouseRegion(
            onEnter: (_) => _cancelFadeTimer(),
            onExit: (_) => _startFadeTimer(),
            child: FadeTransition(
              opacity:
                  _fadeController!.drive(CurveTween(curve: Curves.easeInOut)),
              child: Material(
                color: Colors.white,
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: Column(
                    spacing: 8,
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
                            width: 120,
                            padding: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
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
        if (widget.hasChildren && widget.enableChildrenPopup)
          _showChildrenOverlay(context);
        setState(() {
          _hovered = true;
        });
        _cancelFadeTimer();
      },
      onExit: (event) {
        setState(() {
          _hovered = false;
        });
        if (widget.hasChildren && widget.enableChildrenPopup) _startFadeTimer();
      },
      child: GestureDetector(
        onTap: () {
          widget.onSelect(widget.cat['categoryName']);
          if (widget.hasChildren && widget.enableChildrenPopup)
            _removeChildrenOverlay();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 18),
          decoration: BoxDecoration(
            color: _hovered ? Colors.pink[50] : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.pink.shade200),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                        color: Colors.pink.withOpacity(0.08), blurRadius: 6)
                  ]
                : [],
          ),
          child: SizedBox(
              width: 100,
              height: 20,
              child: Center(
                child: Text(widget.cat['categoryName'],
                    style: TextStyle(fontSize: 15)),
              )),
        ),
      ),
    );
  }
}

// 吸顶header的delegate
class _SimpleHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SimpleHeaderDelegate({required this.child});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      // color: Colors.white, // 与SliverList背景一致，无阴影
      child: child,
    );
  }

  @override
  double get maxExtent => 40 + kToolbarHeight;
  @override
  double get minExtent => 40;
  @override
  bool shouldRebuild(covariant _SimpleHeaderDelegate oldDelegate) => true;
}

// ========== 新增AppBar下方分区Overlay ==========
class CategoryOverlayBar extends StatefulWidget {
  final CategoryLoadAllCategoryController categoryLoadAllCategoryController;
  final CategoryViewStateController categoryViewStateController;
  CategoryOverlayBar(
      {required this.categoryLoadAllCategoryController,
      required this.categoryViewStateController});
  @override
  State<CategoryOverlayBar> createState() => _CategoryOverlayBarState();
}

class _CategoryOverlayBarState extends State<CategoryOverlayBar> {
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    ever(widget.categoryViewStateController.showAll, (_) => _updateOverlay());
    ever(widget.categoryViewStateController.selectedCategoryName,
        (_) => _updateOverlay());
    ever(Get.find<AppBarController>().appBarOpaque, (v) => _updateOverlay());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateOverlay();
    });
  }

  void _updateOverlay() {
    if (!mounted) return;
    final appBarOpaque = Get.find<AppBarController>().appBarOpaque.value;
    if (!appBarOpaque) {
      _removeOverlay();
      return;
    }
    if (_overlayEntry != null) return;
    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          left: 0,
          top: kToolbarHeight,
          right: 0,
          child: Material(
            elevation: 0, // 无阴影
            child: MouseRegion(
              onEnter: (_) {
                if (!mounted) return;
                widget.categoryViewStateController.showAll.value = true;
                _rebuildOverlay();
              },
              onExit: (_) {
                if (!mounted) return;
                widget.categoryViewStateController.showAll.value = false;
                _rebuildOverlay();
              },
              child: GetBuilder<CategoryLoadAllCategoryController>(
                init: widget.categoryLoadAllCategoryController,
                builder: (_) {
                  final categories =
                      widget.categoryLoadAllCategoryController.categories;
                  return Center(
                    child: Obx(() => _CategoryWrap(
                          categories: categories,
                          showAll:
                              widget.categoryViewStateController.showAll.value,
                          onSelect: (String displayName) {
                            widget.categoryViewStateController
                                .selectedCategoryName.value = displayName;
                          },
                          enableChildrenPopup: false,
                        )),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
    if (mounted) {
      Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    }
  }

  void _rebuildOverlay() {
    if (!mounted) return;
    _overlayEntry?.markNeedsBuild();
  }

  void _removeOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}

// 新增：轮播区自动轮播组件
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

  void _stopAutoPlay() {
    _timer?.cancel();
  }

  // 跳转到视频详情页面
  void _navigateToVideo(VideoInfo video) {
    // 这里可以根据你的路由系统进行跳转
    // 例如使用 Get.to() 或者 Navigator.push()
    
    // 示例1: 使用Get路由 (如果你使用GetX)
    Get.toNamed('${Routes.videoPlayPage}/${video.videoId}',id: Routes.mainGetId);
    
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
            height: imageHeight + opaqueHeight,
            child: Stack(
              children: [
                // 图片滚动区域 - 严格16:9比例
                SizedBox(
                  height: imageHeight,
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
                        child: Stack(
                          children: [
                            // 图片本体
                            SizedBox(
                              width: constraints.maxWidth,
                              height: imageHeight,
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                child: video.videoCover != null && video.videoCover!.isNotEmpty
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
                                  final baseColor = snapshot.data ?? Colors.black;
                                  return Container(
                                    height: imageHeight * 0.25, // 减小渐变区域到图片高度的25%
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
                      );
                    },
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
                            bottom: Radius.circular(8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: baseColor.withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: _buildContentBar(context, widget.videos[_currentPage], _currentPage),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 左侧标题
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 400),
              child: Text(
                video.videoName ?? '',
                key: ValueKey('${video.videoName}_$idx'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),
            ),
          ),
          // 圆点指示器
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.videos.length, (dotIdx) {
              final bool isActive = dotIdx == _currentPage;
              return GestureDetector(
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
                  width: isActive ? 14 : 6,
                  height: isActive ? 14 : 6,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white54,
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [BoxShadow(color: Colors.black26, blurRadius: 4)]
                        : [],
                  ),
                ),
              );
            }),
          ),
          SizedBox(width: 8),
          // 右侧箭头按钮
          Row(
            children: [
              _buildArrowButton(context, false),
              SizedBox(width: 6),
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
      final luminance = (0.299 * enhancedR + 0.587 * enhancedG + 0.114 * enhancedB) / 255;
      if (luminance > 0.6) {
        // 如果亮度太高，进一步压暗
        final finalR = (enhancedR * 0.5).round().clamp(0, 255);
        final finalG = (enhancedG * 0.5).round().clamp(0, 255);
        final finalB = (enhancedB * 0.5).round().clamp(0, 255);
        _avgColorCache[idx] = Color.fromARGB(255, finalR, finalG, finalB);
      } else {
        _avgColorCache[idx] = Color.fromARGB(255, enhancedR, enhancedG, enhancedB);
      }
      
      return _avgColorCache[idx]!;
    } catch (e) {
      _avgColorCache[idx] = Colors.black.withOpacity(0.85);
      return _avgColorCache[idx]!;
    }
  }

  // 新增方法：构建箭头按钮
  Widget _buildArrowButton(BuildContext context, bool isRight) {
    return GestureDetector(
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
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          isRight ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
          color: Colors.white,
          size: 14,
        ),
      ),
    );
  }
}
