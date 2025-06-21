import 'dart:math' as math;
import 'package:easylive/Funcs.dart';
import 'package:easylive/controllers/LocalSettingsController.dart';
import 'package:easylive/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/UhomeSeriesController.dart';
import '../../controllers/controllers-class.dart';
import '../../api_service.dart';
import 'VideoSeriesDetailPage.dart';
import 'package:extended_image/extended_image.dart';

class VideoSeriesPage extends StatelessWidget {
  final userId;
  // 构建视频页面
  const VideoSeriesPage({Key? key, this.userId}) : super(key: key);

  // 使用 Get 进行嵌套路由跳转的方法
  void navigateToDetail(UserVideoSeries videoSeries) {
    final navigatorId = int.parse(userId);
    Get.toNamed('/detail', arguments: videoSeries, id: navigatorId);
  }

  @override
  Widget build(BuildContext context) {
    // 检查 userId 是否为空
    if (userId == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '404 - 页面不存在',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '用户ID不能为空',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    UhomeSeriesController uhomeSeriesController =
        Get.find<UhomeSeriesController>(tag: '${userId}UhomeSeriesController');
    LocalSettingsController localSettingsController =
        Get.find<LocalSettingsController>();

    // 注册嵌套路由
    Get.routing.args = {};

    return HeroControllerScope(
        controller: MaterialApp.createMaterialHeroController(),
        child: Navigator(
          key: Get.nestedKey(int.parse(userId)),
          onGenerateRoute: (settings) {
            Widget page;
            switch (settings.name) {
              case '/detail':
                uhomeSeriesController.nowSelectSeriesId.value =
                    (settings.arguments as UserVideoSeries).seriesId;
                page = VideoSeriesDetailPage(
                    uhomeSeriesController: uhomeSeriesController);
                break;
              default:
                page = _buildMainPage(
                    uhomeSeriesController, localSettingsController);
            }
            return PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => page,
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.ease;

                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));

                return SlideTransition(
                  position: animation.drive(tween),
                  child: child,
                );
              },
            );
          },
        ));
  }

  Widget _buildMainPage(UhomeSeriesController uhomeSeriesController,
      LocalSettingsController localSettingsController) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              double spacing = 16; // 水平间距
              double runSpacing = 16; // 垂直间距
              // 计算每行能显示多少个 Widget
              double availableWidth = constraints.maxWidth;
              int itemsPerRow = (availableWidth / 320).floor(); // 280 是期望的最小宽度
              if (itemsPerRow < 1) itemsPerRow = 1;

              // 计算每个 Widget 的实际宽度
              double itemWidth =
                  (availableWidth - (itemsPerRow - 1) * spacing) /
                      itemsPerRow; // 8是间距

              return Obx(() {
                // 检查设置值，决定使用卡片模式还是列表模式
                bool isCardMode =
                    localSettingsController.getSetting('uhomeVideoListType') ??
                        true;

                if (isCardMode) {
                  // 卡片模式（原有的 Wrap 布局）
                  return Wrap(
                    spacing: spacing, // 水平间距
                    runSpacing: runSpacing, // 垂直间距
                    children: [
                      for (var videoSeries
                          in uhomeSeriesController.userVideoSeries)
                        Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: SizedBox(
                                width: itemWidth,
                                child: VideoSeriesWidget(
                                  videoSeries: videoSeries,
                                  onTap: () {
                                    navigateToDetail(videoSeries);
                                  },
                                )))
                    ],
                  );
                } else {
                  // 列表模式
                  return Column(
                    children: [
                      for (var videoSeries
                          in uhomeSeriesController.userVideoSeries)
                        VideoSeriesListItem(
                          videoSeries: videoSeries,
                          onTap: () {
                            navigateToDetail(videoSeries);
                          },
                        )
                    ],
                  );
                }
              });
            },
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class VideoSeriesWidget extends StatefulWidget {
  final UserVideoSeries videoSeries;
  final VoidCallback? onTap;

  const VideoSeriesWidget({
    Key? key,
    required this.videoSeries,
    this.onTap,
  }) : super(key: key);

  @override
  State<VideoSeriesWidget> createState() => _VideoSeriesWidgetState();
}

class _VideoSeriesWidgetState extends State<VideoSeriesWidget>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05, // 减小放大倍数，避免裁剪
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 封面部分
        AspectRatio(
          aspectRatio: 16 / 10, // 16:9宽高比
          child: MouseRegion(
            onEnter: (_) {
              setState(() {
                _isHovered = true;
              });
              _animationController.forward();
            },
            onExit: (_) {
              setState(() {
                _isHovered = false;
              });
              _animationController.reverse();
            },
            child: Tooltip(
              message: widget.videoSeries.seriesDescription.isNotEmpty
                  ? widget.videoSeries.seriesDescription
                  : widget.videoSeries.seriesName,
              child: GestureDetector(
                onTap: widget.onTap,
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _isHovered
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  )
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                        ),
                        child: Stack(
                          children: [
                            // 合集效果 - 深灰色背景层（最下层）
                            Positioned(
                                top: 0,
                                left: 24,
                                right: 24,
                                bottom: 190,
                                child: Hero(
                                  tag:
                                      'videoSeries-${widget.videoSeries.seriesId}-2',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[400],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                )),

                            // 合集效果 - 浅灰色背景层（中间层）
                            Positioned(
                                top: 12,
                                left: 8,
                                right: 8,
                                bottom: 175,
                                child: Hero(
                                  tag:
                                      'videoSeries-${widget.videoSeries.seriesId}-1',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey[600],
                                      borderRadius: BorderRadius.circular(11),
                                    ),
                                  ),
                                )),

                            // 背景封面图片容器（最上层）
                            Positioned(
                              top: 24,
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey[300],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: widget.videoSeries.cover.isNotEmpty
                                    ? Hero(
                                        tag:
                                            'videoSeries-${widget.videoSeries.seriesId}-0',
                                        child: ExtendedImage.network(
                                          ApiService.baseUrl +
                                              ApiAddr.fileGetResourcet +
                                              widget.videoSeries.cover,
                                          fit: BoxFit.cover,
                                          loadStateChanged:
                                              (ExtendedImageState state) {
                                            switch (
                                                state.extendedImageLoadState) {
                                              case LoadState.loading:
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                                  Color>(
                                                              Colors.grey),
                                                    ),
                                                  ),
                                                );
                                              case LoadState.failed:
                                                return Container(
                                                  color: Colors.grey[300],
                                                  child: const Icon(
                                                    Icons.video_library,
                                                    color: Colors.grey,
                                                    size: 50,
                                                  ),
                                                );
                                              case LoadState.completed:
                                                return state.completedWidget;
                                            }
                                          },
                                        ))
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Icon(
                                          Icons.video_library,
                                          color: Colors.grey,
                                          size: 50,
                                        ),
                                      ),
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
          ),
        ),

        // 标题和时间信息（封面下方）
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 合集名称
              Hero(
                  tag: 'videoSeries-${widget.videoSeries.seriesId}-Name',
                  child: Text(
                    widget.videoSeries.seriesName,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )),
              const SizedBox(height: 4),
              // 最后更新日期
              Hero(
                  tag: 'videoSeries-${widget.videoSeries.seriesId}-Time',
                  child: Text(
                    _formatDate(widget.videoSeries.updateTime),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}个月前';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}

// 列表模式控件
class VideoSeriesListItem extends StatefulWidget {
  final UserVideoSeries videoSeries;
  final VoidCallback? onTap;

  const VideoSeriesListItem({
    Key? key,
    required this.videoSeries,
    this.onTap,
  }) : super(key: key);

  @override
  State<VideoSeriesListItem> createState() => _VideoSeriesListItemState();
}

class _VideoSeriesListItemState extends State<VideoSeriesListItem> {
  bool _isHovered = false;
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}个月前';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 合集标题行
            Row(
              children: [
                // 合集图标
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.blue[600],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.video_library,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                // 合集名称

                Hero(
                    tag: 'videoSeries-${widget.videoSeries.seriesId}-Name',
                    child: Text(
                      widget.videoSeries.seriesName,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                SizedBox(width: 8),
                // 最后更新日期
                Hero(
                    tag: 'videoSeries-${widget.videoSeries.seriesId}-Time',
                    child: Text(
                      _formatDate(widget.videoSeries.updateTime),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    )),
                Spacer(),
                TextButton(
                  onPressed: widget.onTap,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue[600],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text(
                    '查看全部视频',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),

                const SizedBox(width: 8),
                // 操作按钮
                MouseRegion(
                  onEnter: (_) => setState(() => _isHovered = true),
                  onExit: (_) => setState(() => _isHovered = false),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _isHovered ? Colors.grey[100] : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.more_vert,
                      color: Colors.grey,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            // 视频横向列表
            if (widget.videoSeries.videoInfoList.isNotEmpty)
              SizedBox(
                height: 180, // 调整高度以适应16:11比例
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 计算可变容器宽度
                    final availableWidth = constraints.maxWidth;
                    final itemCount =
                        math.min(widget.videoSeries.videoInfoList.length, 5);
                    final totalMargin = (itemCount - 1) * 12; // 间距总和
                    final containerPadding = 32; // 左右内边距
                    final itemWidth = math.max(
                        140,
                        (availableWidth - totalMargin - containerPadding) /
                            itemCount);

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        final video = widget.videoSeries.videoInfoList[index];
                        return ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 140.0,
                            maxWidth: double.infinity, // 最大无限制
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 12, // 整体比例16:11
                            child: Container(
                                width: itemWidth
                                    .clamp(140.0, double.infinity)
                                    .toDouble(),
                                margin: EdgeInsets.only(
                                    right: index < itemCount - 1 ? 12 : 0),
                                child: VideoHorizontalItem(
                                    video: video,
                                    seriesId: widget.videoSeries.seriesId,
                                    index: index)),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// 视频条目控件
class VideoListItemTile extends StatefulWidget {
  final VideoInfo video;

  const VideoListItemTile({
    Key? key,
    required this.video,
  }) : super(key: key);

  @override
  State<VideoListItemTile> createState() => _VideoListItemTileState();
}

class _VideoListItemTileState extends State<VideoListItemTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _isHovered ? Theme.of(context).hoverColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovered
                ? Theme.of(context).dividerColor
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // 视频封面
            Container(
              width: 100,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(6),
              ),
              clipBehavior: Clip.antiAlias,
              child: widget.video.videoCover?.isNotEmpty == true
                  ? ExtendedImage.network(
                      ApiService.baseUrl +
                          ApiAddr.fileGetResourcet +
                          widget.video.videoCover!,
                      fit: BoxFit.cover,
                      loadStateChanged: (ExtendedImageState state) {
                        switch (state.extendedImageLoadState) {
                          case LoadState.loading:
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey),
                                  ),
                                ),
                              ),
                            );
                          case LoadState.failed:
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.video_file,
                                color: Colors.grey,
                                size: 24,
                              ),
                            );
                          case LoadState.completed:
                            return state.completedWidget;
                        }
                      },
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.video_file,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
            ),

            const SizedBox(width: 12),

            // 视频信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 视频标题
                  Text(
                    widget.video.videoName ?? '未知视频',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // 视频信息（时长、上传时间等）
                  Text(
                    _formatVideoInfo(),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // 播放按钮
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _isHovered ? Colors.blue[600] : Colors.grey[400],
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatVideoInfo() {
    final duration =
        _formatDuration(Duration(seconds: widget.video.duration ?? 0));
    final date = _formatDate(widget.video.createTime ?? DateTime.now());
    return '$duration • $date';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}天前';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}个月前';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }
}

// 横向视频项组件（用于合集列表展示）
class VideoHorizontalItem extends StatefulWidget {
  final VideoInfo video;
  final int seriesId;
  final int index;
  const VideoHorizontalItem({
    Key? key,
    required this.video,
    required this.seriesId,
    required this.index,
  }) : super(key: key);

  @override
  State<VideoHorizontalItem> createState() => _VideoHorizontalItemState();
}

class _VideoHorizontalItemState extends State<VideoHorizontalItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          final videoId = widget.video.videoId;
          if (videoId != null) {
            Get.find<AppBarController>().extendBodyBehindAppBar.value = false;
            Get.toNamed(
              '${Routes.videoPlayPage}?videoId=$videoId',
              id: Routes.mainGetId,
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _isHovered
                ? Theme.of(context).colorScheme.primary.withOpacity(0.06)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // 根据容器宽度计算响应式字体大小
              final containerWidth = constraints.maxWidth;
              final baseFontSize =
                  (containerWidth / 140 * 12).clamp(10.0, 16.0);
              final playCountFontSize =
                  (containerWidth / 140 * 10).clamp(8.0, 12.0);
              final timeFontSize = (containerWidth / 140 * 10).clamp(8.0, 12.0);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 视频封面 (占总高度的16/11部分)
                  Expanded(
                    flex: 9, // 封面占9份
                    child: AspectRatio(
                      aspectRatio: 16 / 9, // 确保16:9比例
                      child: AnimatedScale(
                        scale: _isHovered ? 1.03 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        child: Hero(
                            tag:
                                'videoSeries-${widget.seriesId}-${widget.index}',
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Stack(
                                children: [
                                  Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    child: widget.video.videoCover != null &&
                                            widget.video.videoCover!.isNotEmpty
                                        ? ExtendedImage.network(
                                            Constants.baseUrl +
                                                ApiAddr.fileGetResourcet +
                                                widget.video.videoCover!,
                                            fit: BoxFit.cover,
                                            cache: true,
                                          )
                                        : Container(
                                            color: Colors.grey[200],
                                            child: Center(
                                              child: Icon(
                                                Icons.videocam_outlined,
                                                color: Colors.grey,
                                                size: containerWidth * 0.15,
                                              ),
                                            ),
                                          ),
                                  ),
                                  // 渐变遮罩
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 0,
                                    height: 30,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          bottom: Radius.circular(6),
                                        ),
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  // 播放量 (左下角)
                                  Positioned(
                                    left: 6,
                                    bottom: 6,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.play_arrow,
                                          size: playCountFontSize + 2,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          _formatPlayCount(
                                              widget.video.playCount ?? 0),
                                          style: TextStyle(
                                            fontSize: playCountFontSize,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                            shadows: [
                                              Shadow(
                                                offset: const Offset(0.5, 0.5),
                                                blurRadius: 1.0,
                                                color: Colors.black
                                                    .withOpacity(0.8),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ),
                    ),
                  ),

                  // 标题和时间信息区域 (占2份)
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 视频标题
                          Expanded(
                            child: Hero(
                                tag:
                                    'videoSeriesName-${widget.seriesId}-${widget.index}',
                                child: Text(
                                  widget.video.videoName ?? '未知视频',
                                  maxLines: 1, // 确保标题只有一行
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: baseFontSize,
                                    fontWeight: FontWeight.w500,
                                    color: _isHovered
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.black87,
                                    height: 1.2,
                                  ),
                                )),
                          ),

                          // 发布时间
                          if (widget.video.createTime != null)
                            Hero(
                                tag:
                                    'videoSeriesTime-${widget.seriesId}-${widget.index}',
                                child: Text(
                                  _formatDate(widget.video.createTime!),
                                  style: TextStyle(
                                    fontSize: timeFontSize,
                                    color: Colors.grey,
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _formatPlayCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    }
    return count.toString();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}年前';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}个月前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
