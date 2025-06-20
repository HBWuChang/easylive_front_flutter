import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:easylive/Funcs.dart';
import 'package:easylive/controllers/LocalSettingsController.dart';
import 'package:easylive/controllers/VideoCommentController.dart';
import 'package:easylive/controllers/VideoDamnuController.dart';
import 'package:easylive/enums.dart';
import 'package:easylive/pages/VideoPlayPage/VideoPlayPageComments.dart';
import 'package:easylive/pages/VideoPlayPage/VideoPlayPageInfo.dart';
import 'package:easylive/settings.dart';
import 'package:easylive/widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/UhomeSeriesController.dart';
import '../../controllers/controllers-class.dart';
import '../../api_service.dart';
import 'VideoSeriesDetailPage.dart';
import 'package:extended_image/extended_image.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dotted_decoration/dotted_decoration.dart';
import 'dart:ui' as ui;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
// import 'package:iconify_flutter_plus/iconify_flutter_plus.dart'; // For Iconify Widget
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter_plus/icons/zondicons.dart'; // for Non Colorful Icons
import 'package:iconify_flutter/icons/tabler.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../../controllers/UhomeController.dart';
import '../MainPage/VideoInfoWidget.dart';

class VideoSeriesPage extends StatelessWidget {
  final userId;
  // 构建视频页面
  const VideoSeriesPage({Key? key, this.userId}) : super(key: key);
  
  // 使用 Get 进行嵌套路由跳转的方法
  void navigateToDetail(UserVideoSeries videoSeries) {
    final navigatorId = userId as int; // userId 必须是 int 类型
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
        
    return Navigator(
      key: GlobalKey<NavigatorState>(),
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/detail':
            final videoSeries = settings.arguments as UserVideoSeries;
            page = VideoSeriesDetailPage(videoSeries: videoSeries);
            break;
          default:
            page = _buildMainPage(uhomeSeriesController, localSettingsController);
        }
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.ease;

            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      },
    );
  }

  Widget _buildMainPage(UhomeSeriesController uhomeSeriesController, LocalSettingsController localSettingsController) {
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
                bool isCardMode = localSettingsController.getSetting('uhomeVideoListType') ?? true;
                
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
                              bottom: 32,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[400],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),

                            // 合集效果 - 浅灰色背景层（中间层）
                            Positioned(
                              top: 12,
                              left: 8,
                              right: 8,
                              bottom: 28,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[600],
                                  borderRadius: BorderRadius.circular(11),
                                ),
                              ),
                            ),

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
                                    ? ExtendedImage.network(
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
                                                            Color>(Colors.grey),
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
                                      )
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

                            // 视频数量标签（右上角）
                            if (widget.videoSeries.videoInfoList.isNotEmpty)
                              Positioned(
                                top: 36,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '${widget.videoSeries.videoInfoList.length}个内容',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
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
              Text(
                widget.videoSeries.seriesName,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // 最后更新日期
              Text(
                _formatDate(widget.videoSeries.updateTime),
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                ),
              ),
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
              Expanded(
                child: Text(
                  widget.videoSeries.seriesName,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 视频数量
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.videoSeries.videoInfoList.length}个视频',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
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
          
          // 视频列表
          if (widget.videoSeries.videoInfoList.isNotEmpty)
            Column(
              children: widget.videoSeries.videoInfoList.take(3).map((video) {
                return VideoListItemTile(video: video);
              }).toList(),
            ),
          
          // 如果有更多视频，显示"查看全部"
          if (widget.videoSeries.videoInfoList.length > 3)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: TextButton(
                onPressed: widget.onTap,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue[600],
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  '查看全部 ${widget.videoSeries.videoInfoList.length} 个视频',
                  style: const TextStyle(fontSize: 14),
                ),
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
          color: _isHovered ? Colors.grey[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _isHovered ? Colors.grey[300]! : Colors.transparent,
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
                      ApiService.baseUrl + ApiAddr.fileGetResourcet + widget.video.videoCover!,
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
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
    final duration = _formatDuration(Duration(seconds: widget.video.duration ?? 0));
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
