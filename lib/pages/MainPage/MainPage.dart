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

class MainPage extends StatelessWidget {
  MainPage({Key? key}) : super(key: key);
  final AppBarController appBarController = Get.find<AppBarController>();
  final CategoryLoadAllCategoryController categoryLoadAllCategoryController =
      Get.find<CategoryLoadAllCategoryController>();
  final CategoryViewStateController categoryViewStateController =
      Get.put(CategoryViewStateController());
  final VideoLoadRecommendVideoController videoLoadRecommendVideoController = Get.find<VideoLoadRecommendVideoController>();
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
                final List<VideoInfo> recommendVideos = videos.skip(5).take(6).toList();
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // 设定整体宽高比，例如 16:5
                      double aspectRatio = CropAspectRatioEnum.VIDEO_COVER.ratio;
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
                                child: SizedBox(
                                  height: double.infinity,
                                  child: carouselVideos.isEmpty
                                      ? Center(child: Text('暂无推荐'))
                                      : CarouselVideoWidget(videos: carouselVideos),
                                ),
                              ),
                              SizedBox(width: 16),
                              // 右侧2x3推荐区
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: double.infinity,
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                      childAspectRatio: 16 / 11,
                                    ),
                                    itemCount: recommendVideos.length,
                                    itemBuilder: (context, idx) {
                                      return VideoInfoWidget(video: recommendVideos[idx]);
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
    final WindowSizeController windowSizeController = Get.find<WindowSizeController>();
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
            final hasChildren = cat['children'] != null && (cat['children'] as List).isNotEmpty;
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
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: video.videoCover != null && video.videoCover!.isNotEmpty
                    ? ExtendedImage.network(
                        Constants.baseUrl + ApiAddr.fileGetResourcet + video.videoCover!,
                        fit: BoxFit.cover,
                      )
                    : Container(color: Colors.grey[200]),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
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
                    style: TextStyle(color: Colors.white, fontSize: 13, shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.forum, color: Colors.white, size: 16),
                  SizedBox(width: 2),
                  Text(
                    (video.danmuCount ?? 0).toString(),
                    style: TextStyle(color: Colors.white, fontSize: 13, shadows: [Shadow(color: Colors.black, blurRadius: 2)]),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Text(
          video.videoName ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        SizedBox(height: 2),
        Row(
          children: [
            Icon(Icons.person, size: 14, color: Colors.grey),
            SizedBox(width: 3),
            Text(video.nickName ?? '', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
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
        _currentPage = (_currentPage + 1) % widget.videos.length;
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
          _currentPage = idx;
        },
        itemBuilder: (context, idx) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: VideoInfoWidget(video: widget.videos[idx]),
          );
        },
      ),
    );
  }
}
