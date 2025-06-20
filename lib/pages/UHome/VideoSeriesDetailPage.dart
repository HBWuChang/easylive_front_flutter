import 'package:easylive/Funcs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extended_image/extended_image.dart';
import '../../controllers/UhomeSeriesController.dart';
import '../../controllers/controllers-class.dart';
import '../../api_service.dart';

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '合集',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.videocam,
                          color: Colors.orange,
                          size: 16,
                        ),
                      ],
                    ),
                    Hero(
                        tag:
                            'videoSeries-${uhomeSeriesController.videoSeriesDetail.value.videoSeries!.seriesId}-Name',
                        child: Text(
                          uhomeSeriesController
                              .videoSeriesDetail.value.videoSeries!.seriesName,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                ),
                const Spacer(),
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
                // 添加视频按钮
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: IconButton(
                    onPressed: () => _showAddVideoDialog(context),
                    icon: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),

          // 合集描述（如果有）
          if (uhomeSeriesController.videoSeriesDetail.value.videoSeries!
              .seriesDescription.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).cardColor,
              child: Text(
                uhomeSeriesController
                    .videoSeriesDetail.value.videoSeries!.seriesDescription,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),

          // 播放全部按钮
          Container(
            padding: const EdgeInsets.all(16),
            child:
                // 最新添加排序按钮
                TextButton.icon(
              onPressed: () {
                // TODO: 切换排序方式
              },
              icon: const Icon(Icons.sort),
              label: const Text('最新添加'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // 视频列表
          Expanded(
            child: Obx(() => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: uhomeSeriesController
                      .videoSeriesDetail.value.seriesVideoList!.length,
                  itemBuilder: (context, index) {
                    final video = uhomeSeriesController
                        .videoSeriesDetail.value.seriesVideoList![index];
                    return VideoSeriesDetailItem(
                      video: video,
                      index: index,
                      onTap: () {
                        // TODO: 播放指定视频
                      },
                    );
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

  // 显示添加视频的弹窗
  Future<void> _showAddVideoDialog(BuildContext context) async {
    final selectedVideoIds = await Get.dialog<List<String>>(
      VideoSelectionDialog(
        seriesId:
            uhomeSeriesController.videoSeriesDetail.value.videoSeries!.seriesId,
        uhomeSeriesController: uhomeSeriesController,
      ),
    );

    if (selectedVideoIds != null && selectedVideoIds.isNotEmpty) {
      // TODO: 处理选中的视频ID列表
      print('选中的视频ID: $selectedVideoIds');
      List<String> nowvideoIds = uhomeSeriesController
          .videoSeriesDetail.value.seriesVideoList!
          .map((video) => video.videoId)
          .toList();
      nowvideoIds.addAll(selectedVideoIds);
      try {
        var res = await ApiService.uhomeSeriesSaveSeriesVideo(
            seriesId: uhomeSeriesController
                .videoSeriesDetail.value.videoSeries!.seriesId,
            videoIds: nowvideoIds.join(','));
        if (showResSnackbar(res, notShowIfSuccess: true)) {
          // 成功后重新加载系列详情
          await uhomeSeriesController.loadVideoSeriesDetail();
        }
      } catch (e) {
        showErrorSnackbar(
          e.toString(),
        );
      }
    }
  }
}

// 视频选择弹窗
class VideoSelectionDialog extends StatefulWidget {
  final int seriesId;
  final UhomeSeriesController uhomeSeriesController;

  const VideoSelectionDialog({
    Key? key,
    required this.seriesId,
    required this.uhomeSeriesController,
  }) : super(key: key);

  @override
  State<VideoSelectionDialog> createState() => _VideoSelectionDialogState();
}

class _VideoSelectionDialogState extends State<VideoSelectionDialog> {
  List<VideoInfo> _allVideos = [];
  Set<String> _selectedVideoIds = <String>{};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllVideos();
  }

  Future<void> _loadAllVideos() async {
    setState(() => _isLoading = true);
    try {
      final videos = await widget.uhomeSeriesController
          .uhomeseriesloadAllVideo(widget.seriesId);
      setState(() {
        _allVideos = videos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 标题栏
            Row(
              children: [
                Text(
                  '选择要添加的视频',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(result: <String>[]),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 选择状态显示
            if (_selectedVideoIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '已选择 ${_selectedVideoIds.length} 个视频',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // 视频列表
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _allVideos.isEmpty
                      ? const Center(
                          child: Text(
                            '没有可选择的视频',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _allVideos.length,
                          itemBuilder: (context, index) {
                            final video = _allVideos[index];
                            final isSelected =
                                _selectedVideoIds.contains(video.videoId);

                            return VideoSelectionItem(
                              video: video,
                              isSelected: isSelected,
                              onSelectionChanged: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedVideoIds.add(video.videoId!);
                                  } else {
                                    _selectedVideoIds.remove(video.videoId!);
                                  }
                                });
                              },
                            );
                          },
                        ),
            ),

            const SizedBox(height: 16),

            // 底部按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(result: <String>[]),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedVideoIds.isEmpty
                        ? null
                        : () => Get.back(result: _selectedVideoIds.toList()),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('确定 (${_selectedVideoIds.length})'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 视频选择条目
class VideoSelectionItem extends StatefulWidget {
  final VideoInfo video;
  final bool isSelected;
  final ValueChanged<bool> onSelectionChanged;

  const VideoSelectionItem({
    Key? key,
    required this.video,
    required this.isSelected,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<VideoSelectionItem> createState() => _VideoSelectionItemState();
}

class _VideoSelectionItemState extends State<VideoSelectionItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => widget.onSelectionChanged(!widget.isSelected),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.05)
                : null,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? Theme.of(context).primaryColor
                  : _isHovered
                      ? Theme.of(context).primaryColor.withOpacity(0.5)
                      : Colors.transparent,
              width: widget.isSelected ? 2 : 1,
              style: widget.isSelected
                  ? BorderStyle.solid
                  : _isHovered
                      ? BorderStyle.solid
                      : BorderStyle.none,
            ),
          ),
          child: Row(
            children: [
              // 视频封面
              Container(
                width: 120,
                height: 68,
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

              const SizedBox(width: 16),

              // 视频信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 视频标题
                    Text(
                      widget.video.videoName ?? '未知视频',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // 播放量和发布时间
                    Row(
                      children: [
                        Icon(
                          Icons.play_circle_outline,
                          color: Colors.grey[500],
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatPlayCount(widget.video.playCount ?? 0)}次播放',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.access_time,
                          color: Colors.grey[500],
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(
                              widget.video.createTime ?? DateTime.now()),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // 选择指示器
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.transparent,
                  border: Border.all(
                    color: widget.isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.grey[400]!,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: widget.isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
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
