import 'dart:async';
import 'package:easylive/Funcs.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/pages2.dart';
import 'package:easylive/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers-class.dart';
import '../../api_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'dart:ui' as ui;

class MainPage extends StatelessWidget {
  MainPage({Key? key}) : super(key: key);
  final AppBarController appBarController = Get.find<AppBarController>();
  final CategoryLoadAllCategoryController categoryLoadAllCategoryController =
      Get.find<CategoryLoadAllCategoryController>();
  final CategoryViewStateController categoryViewStateController =
      Get.put(CategoryViewStateController());
  final VideoLoadRecommendVideoController videoLoadRecommendVideoController =
      Get.find<VideoLoadRecommendVideoController>();
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
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
          bottom: MediaQuery.of(context).size.height - rect.top + 4,
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

// 视频信息展示组件
class VideoInfoWidget extends StatelessWidget {
  final VideoInfo video;
  const VideoInfoWidget({required this.video, Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                final videoId = video.videoId;
                if (videoId != null) {
                  Get.find<AppBarController>().extendBodyBehindAppBar.value =
                      false;
                  Get.toNamed('${Routes.videoPlayPage}?videoId=$videoId',
                      id: Routes.mainGetId);
                }
              },
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      video.videoCover != null && video.videoCover!.isNotEmpty
                          ? ExtendedImage.network(
                              Constants.baseUrl +
                                  ApiAddr.fileGetResourcet +
                                  video.videoCover!,
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.grey[200]),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(8)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 8,
              bottom: 8,
              child: Row(
                children: [
                  Icon(Icons.play_arrow, color: Colors.white, size: 16),
                  SizedBox(width: 2),
                  Text(
                    (video.playCount ?? 0).toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.subtitles, color: Colors.white, size: 16),
                  SizedBox(width: 2),
                  Text(
                    (video.danmuCount ?? 0).toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Text(
          video.videoName ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.person, size: 14, color: Colors.grey),
            SizedBox(width: 3),
            Text(video.nickName ?? '',
                style: TextStyle(fontSize: 13, color: Colors.grey[700])),
            SizedBox(width: 10),
            Icon(Icons.access_time, size: 14, color: Colors.grey),
            SizedBox(width: 3),
            Text(
              video.createTime != null ? _formatDate(video.createTime!) : '',
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    ever(widget.categoryViewStateController.showAll, (_) => _updateOverlay());
    ever(widget.categoryViewStateController.selectedCategoryName,
        (_) => _updateOverlay());
    ever(Get.find<AppBarController>().appBarOpaque, (v) => _updateOverlay());
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateOverlay());
  }

  void _updateOverlay() {
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
            // color: Colors.white,
            elevation: 0, // 无阴影
            child: MouseRegion(
              onEnter: (_) {
                widget.categoryViewStateController.showAll.value = true;
                _rebuildOverlay();
              },
              onExit: (_) {
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
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _rebuildOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
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

  @override
  void dispose() {
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
          return Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      video.videoCover != null && video.videoCover!.isNotEmpty
                          ? ExtendedImage.network(
                              Constants.baseUrl +
                                  ApiAddr.fileGetResourcet +
                                  video.videoCover!,
                              fit: BoxFit.cover,
                            )
                          : Container(color: Colors.grey[200]),
                ),
              ),
              // 阴影与内容区域
              Positioned(
                left: 0,
                right: 0,
                bottom: 0, // 向下延伸到图片外
                child: FutureBuilder<Color>(
                  future: _getBottomAverageColor(idx),
                  builder: (context, snapshot) {
                    final avgColor =
                        snapshot.data ?? Colors.black.withOpacity(0.55);
                    return _buildShadowBar(context, video, idx, avgColor);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 新增：底部均值色提取
  Future<Color> _getBottomAverageColor(int idx) async {
    if (_avgColorCache.containsKey(idx)) return _avgColorCache[idx]!;
    final video = widget.videos[idx];
    if (video.videoCover == null || video.videoCover!.isEmpty) {
      _avgColorCache[idx] = Colors.black.withOpacity(0.55);
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
      final int bottomH = (height * 0.15).toInt();
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
      final avg = Color.fromARGB(255, r ~/ count, g ~/ count, b ~/ count);
      _avgColorCache[idx] = avg.withOpacity(0.7);
      return _avgColorCache[idx]!;
    } catch (e) {
      _avgColorCache[idx] = Colors.black.withOpacity(0.55);
      return _avgColorCache[idx]!;
    }
  }

  // 修改：_buildShadowBar 增加 avgColor 参数
  Widget _buildShadowBar(
      BuildContext context, VideoInfo video, int idx, Color shadowColor) {
    // 计算图片高度，保证阴影高度和渐变区域成比例缩放
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final double imageHeight = box?.size.width ?? 260; // 兜底值
    final double shadowHeight = imageHeight * 0.24; // 阴影高度为图片高度的28%
    final double borderRadius = imageHeight * 0.08; // 圆角为图片高度的8%
    // 渐变区域占阴影高度的比例
    final double gradStop1 = 0.0;
    final double gradStop2 = 0.65;
    final double gradStop3 = 0.78;
    final double gradStop4 = 1.0;
    return Container(
      height: shadowHeight,
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.vertical(bottom: Radius.circular(borderRadius)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent, // 图片区域上方完全透明
            shadowColor, // 图片底部渐变到均值色
            shadowColor, // 图片下方完全不透明
            shadowColor, // 下方延伸区域完全不透明
          ],
          stops: [gradStop1, gradStop2, gradStop3, gradStop4],
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 64 * (shadowHeight / 130), // 阴影模糊度也随比例缩放
            spreadRadius: 0,
            offset: Offset(0, 16 * (shadowHeight / 130)),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 左上标题
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, top: 12, bottom: 16),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  video.videoName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ),
          // 圆点指示器
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
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
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 16 : 8,
                    height: isActive ? 16 : 8,
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
          ),
          // 右侧箭头按钮
          Padding(
            padding: const EdgeInsets.only(right: 12, bottom: 12),
            child: Row(
              children: [
                _buildArrowButton(context, false),
                SizedBox(width: 8),
                _buildArrowButton(context, true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 新增方法：构建底部阴影与内容
  Widget _buildArrowButton(BuildContext context, bool isRight) {
    return GestureDetector(
      onTap: () {
        int next = isRight ? _currentPage + 1 : _currentPage - 1;
        if (next >= 0 && next < widget.videos.length) {
          _pageController.animateToPage(
            next,
            duration: Duration(milliseconds: 400),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          isRight ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }
}
