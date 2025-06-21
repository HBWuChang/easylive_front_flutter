import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extended_image/extended_image.dart';
import '../../controllers/UhomeSeriesController.dart';
import '../../api_service.dart';
import '../../widgets.dart';
import 'UhomeWidgets.dart';
import 'VideoSeriesPage.dart';

class VideoSeriesDetailPage extends StatelessWidget {
  final UhomeSeriesController uhomeSeriesController;

  const VideoSeriesDetailPage({
    Key? key,
    required this.uhomeSeriesController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 顶部导航栏
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // 返回按钮
                IconButton(
                  onPressed: () =>
                      Get.back(id: int.parse(uhomeSeriesController.userId)),
                  icon: const Icon(Icons.arrow_back),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).hoverColor,
                  ),
                ),
                const SizedBox(width: 12),
                // 合集标题
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                          tag:
                              'videoSeries-${uhomeSeriesController.videoSeriesDetail.value.videoSeries!.seriesId}-Name',
                          child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(maxWidth: Get.width - 400),
                              child: Obx(() => ExpandableText(
                                    text: uhomeSeriesController
                                        .videoSeriesDetail
                                        .value
                                        .videoSeries!
                                        .seriesName,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                  )))),
                      // 合集描述（如果有）
                      if (uhomeSeriesController.videoSeriesDetail.value
                          .videoSeries!.seriesDescription.isNotEmpty)
                        ConstrainedBox(
                            constraints:
                                BoxConstraints(maxWidth: Get.width - 400),
                            child: Obx(() => Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: ExpandableText(
                                    text: uhomeSeriesController
                                        .videoSeriesDetail
                                        .value
                                        .videoSeries!
                                        .seriesDescription,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                    maxLines: 2,
                                  ),
                                ))),
                    ],
                  ),
                ),
                const Spacer(),
                // 编辑按钮
                IconButton(
                  onPressed: () => _showEditSeriesDialog(context),
                  tooltip: '编辑合集内容',
                  icon: const Icon(Icons.edit),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).hoverColor,
                  ),
                ),
                const SizedBox(width: 8),
                // 最新添加排序按钮
                Obx(() => TextButton.icon(
                      onPressed: () {
                        uhomeSeriesController.toggleSortOrder();
                      },
                      icon: const Icon(Icons.sort),
                      label: Text(uhomeSeriesController.sortOrderText),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                    )),
                // 视频数量和更新时间
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Obx(() => Text(
                          '${uhomeSeriesController.videoSeriesDetail.value.seriesVideoList!.length}个视频',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        )),
                    Hero(
                        tag:
                            'videoSeries-${uhomeSeriesController.videoSeriesDetail.value.videoSeries!.seriesId}-Time',
                        child: Obx(() => Text(
                              _formatDate(uhomeSeriesController
                                  .videoSeriesDetail
                                  .value
                                  .videoSeries!
                                  .updateTime),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ))),
                  ],
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),

          // 视频网格
          Expanded(
            child: Obx(() => GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 1500
                        ? 6
                        : 5, // 根据屏幕宽度调整列数
                    childAspectRatio: 16 / 12, // 宽高比
                    crossAxisSpacing: 12, // 横向间距
                    mainAxisSpacing: 12, // 纵向间距
                  ),
                  itemCount: uhomeSeriesController
                      .videoSeriesDetail.value.seriesVideoList!.length,
                  itemBuilder: (context, index) {
                    return Obx(() {
                      int index1 = uhomeSeriesController.isAscendingSort.value
                          ? index
                          : uhomeSeriesController.videoSeriesDetail.value
                                  .seriesVideoList!.length -
                              1 -
                              index;
                      final video = userVideoSeriesVideoToVideoInfo(
                          uhomeSeriesController.videoSeriesDetail.value
                              .seriesVideoList![index1]);
                      return VideoHorizontalItem(
                        video: video,
                        index: index1,
                        seriesId: uhomeSeriesController
                            .videoSeriesDetail.value.videoSeries!.seriesId,
                      );
                    });
                  },
                )),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '今天更新';
    } else if (difference.inDays == 1) {
      return '昨天更新';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}天前更新';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}个月前更新';
    } else {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}更新';
    }
  }

  // 显示编辑合集的弹窗
  Future<void> _showEditSeriesDialog(BuildContext context) async {
    await Get.dialog(
      EditSeriesDialog(
        uhomeSeriesController: uhomeSeriesController,
      ),
    );
  }
}

// 视频详细条目控件 - 适用于 UserVideoSeriesVideo
class VideoSeriesDetailItem extends StatefulWidget {
  final UserVideoSeriesVideo video;
  final int index;
  final VoidCallback? onTap;

  const VideoSeriesDetailItem({
    Key? key,
    required this.video,
    required this.index,
    this.onTap,
  }) : super(key: key);

  @override
  State<VideoSeriesDetailItem> createState() => _VideoSeriesDetailItemState();
}

class _VideoSeriesDetailItemState extends State<VideoSeriesDetailItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered ? Theme.of(context).hoverColor : null,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _isHovered
                  ? Theme.of(context).dividerColor
                  : Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // 序号
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Theme.of(context).dividerColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${widget.index + 1}',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // 视频封面
              Container(
                width: 160,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: widget.video.videoCover.isNotEmpty
                    ? Hero(
                        tag:
                            'videoSeries-${widget.video.seriesId}-${widget.index}',
                        child: ExtendedImage.network(
                          ApiService.baseUrl +
                              ApiAddr.fileGetResourcet +
                              widget.video.videoCover,
                          fit: BoxFit.cover,
                          loadStateChanged: (ExtendedImageState state) {
                            switch (state.extendedImageLoadState) {
                              case LoadState.loading:
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                                    size: 32,
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
                          Icons.video_file,
                          color: Colors.grey,
                          size: 32,
                        ),
                      ),
              ),

              const SizedBox(width: 16),

              // 视频信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 视频标题
                    Hero(
                        tag:
                            'videoSeriesName-${widget.video.seriesId}-${widget.index}',
                        child: Text(
                          widget.video.videoName,
                          style: TextStyle(
                            color:
                                Theme.of(context).textTheme.titleMedium?.color,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )),
                    const SizedBox(height: 8),
                    // 播放量和上传时间
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          color: Colors.grey[500],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatPlayCount(widget.video.playCount)}次播放',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          color: Colors.grey[500],
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Hero(
                            tag:
                                'videoSeriesTime-${widget.video.seriesId}-${widget.index}',
                            child: Text(
                              _formatDate(widget.video.createTime),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // 播放按钮
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _isHovered
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPlayCount(int playCount) {
    if (playCount >= 10000) {
      return '${(playCount / 10000).toStringAsFixed(1)}万';
    } else if (playCount >= 1000) {
      return '${(playCount / 1000).toStringAsFixed(1)}千';
    } else {
      return playCount.toString();
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

// 视频网格条目控件 - 适用于网格展示的 UserVideoSeriesVideo
class VideoSeriesGridItem extends StatefulWidget {
  final UserVideoSeriesVideo video;
  final int index;
  final VoidCallback? onTap;

  const VideoSeriesGridItem({
    Key? key,
    required this.video,
    required this.index,
    this.onTap,
  }) : super(key: key);

  @override
  State<VideoSeriesGridItem> createState() => _VideoSeriesGridItemState();
}

class _VideoSeriesGridItemState extends State<VideoSeriesGridItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: _isHovered ? Theme.of(context).hoverColor : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isHovered
                  ? Theme.of(context).dividerColor
                  : Theme.of(context).dividerColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 视频封面容器
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    // 视频封面
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: widget.video.videoCover.isNotEmpty
                          ? Hero(
                              tag:
                                  'videoSeries-${widget.video.seriesId}-${widget.index}',
                              child: ExtendedImage.network(
                                ApiService.baseUrl +
                                    ApiAddr.fileGetResourcet +
                                    widget.video.videoCover,
                                fit: BoxFit.cover,
                                loadStateChanged: (ExtendedImageState state) {
                                  switch (state.extendedImageLoadState) {
                                    case LoadState.loading:
                                      return Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
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
                                          size: 32,
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
                                Icons.video_file,
                                color: Colors.grey,
                                size: 32,
                              ),
                            ),
                    ),

                    // 序号标识
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    // 播放按钮
                    if (_isHovered)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 视频信息
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 视频标题
                      Expanded(
                        child: Hero(
                          tag:
                              'videoSeriesName-${widget.video.seriesId}-${widget.index}',
                          child: Text(
                            widget.video.videoName,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 播放量和时间
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.play_circle_outline,
                                  color: Colors.grey[500],
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${_formatPlayCount(widget.video.playCount)}次播放',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Hero(
                            tag:
                                'videoSeriesTime-${widget.video.seriesId}-${widget.index}',
                            child: Text(
                              _formatDate(widget.video.createTime),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPlayCount(int playCount) {
    if (playCount >= 10000) {
      return '${(playCount / 10000).toStringAsFixed(1)}万';
    } else if (playCount >= 1000) {
      return '${(playCount / 1000).toStringAsFixed(1)}千';
    } else {
      return playCount.toString();
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
