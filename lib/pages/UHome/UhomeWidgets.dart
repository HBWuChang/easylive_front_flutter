import 'package:easylive/Funcs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:extended_image/extended_image.dart';
import '../../controllers/UhomeSeriesController.dart';
import '../../controllers/controllers-class.dart';
import '../../api_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 视频选择弹窗
class VideoSelectionDialog extends StatefulWidget {
  final int? seriesId;
  final List<String> excludeVideoIds;
  final UhomeSeriesController uhomeSeriesController;
  final bool singleSelection; // 新增：是否单选模式
  final String? title; // 新增：自定义标题
  final String? selectButtonText; // 新增：自定义选择按钮文字

  const VideoSelectionDialog({
    Key? key,
    required this.seriesId,
    required this.excludeVideoIds,
    required this.uhomeSeriesController,
    this.singleSelection = false,
    this.title,
    this.selectButtonText,
  }) : super(key: key);

  @override
  State<VideoSelectionDialog> createState() => _VideoSelectionDialogState();
}

class _VideoSelectionDialogState extends State<VideoSelectionDialog> {
  List<VideoInfo> _allVideos = [];
  List<VideoInfo> _filteredVideos = [];
  Set<String> _selectedVideoIds = <String>{};
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllVideos();
    _searchController.addListener(_filterVideos);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllVideos() async {
    setState(() => _isLoading = true);
    try {
      final videos = await widget.uhomeSeriesController
          .uhomeseriesloadAllVideo(widget.seriesId);
      setState(() {
        _allVideos = videos
            .where((video) => !widget.excludeVideoIds.contains(video.videoId))
            .toList();
        _filteredVideos = List.from(_allVideos);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterVideos() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredVideos = List.from(_allVideos);
      } else {
        _filteredVideos = _allVideos.where((video) {
          final videoName = (video.videoName ?? '').toLowerCase();
          final videoTags = (video.tags ?? '').toLowerCase();
          final introduction = (video.introduction ?? '').toLowerCase();
          return videoName.contains(query) || 
                 videoTags.contains(query) || 
                 introduction.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: (MediaQuery.of(context).size.width * 0.8).w,
        height: (MediaQuery.of(context).size.height * 0.8).w,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 标题栏
            Row(
              children: [
                Text(
                  widget.title ?? '选择要添加的视频',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(result: <VideoInfo>[]),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 搜索框
            StatefulBuilder(
              builder: (context, setSearchState) {
                _searchController.addListener(() => setSearchState(() {}));
                return TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '搜索视频标题、标签或简介...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setSearchState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                );
              },
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
                      widget.singleSelection 
                          ? '已选择 1 个视频'
                          : '已选择 ${_selectedVideoIds.length} 个视频',
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
                  : _filteredVideos.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isNotEmpty
                                ? '没有找到匹配的视频'
                                : '没有可选择的视频',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredVideos.length,
                          itemBuilder: (context, index) {
                            final video = _filteredVideos[index];
                            final isSelected =
                                _selectedVideoIds.contains(video.videoId);

                            return VideoSelectionItem(
                              video: video,
                              isSelected: isSelected,
                              singleSelection: widget.singleSelection,
                              onSelectionChanged: (selected) {
                                setState(() {
                                  if (widget.singleSelection) {
                                    // 单选模式：清空之前的选择，只保留当前选择
                                    if (selected) {
                                      _selectedVideoIds.clear();
                                      _selectedVideoIds.add(video.videoId!);
                                    } else {
                                      _selectedVideoIds.clear();
                                    }
                                  } else {
                                    // 多选模式：原有逻辑
                                    if (selected) {
                                      _selectedVideoIds.add(video.videoId!);
                                    } else {
                                      _selectedVideoIds.remove(video.videoId!);
                                    }
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
                    onPressed: () => Get.back(result: <VideoInfo>[]),
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
                        : () => Get.back(
                            result: _allVideos
                                .where((video) =>
                                    _selectedVideoIds.contains(video.videoId!))
                                .toList()),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(widget.selectButtonText ?? '确定 (${_selectedVideoIds.length})'),
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
  final bool singleSelection; // 新增：是否单选模式
  final ValueChanged<bool> onSelectionChanged;

  const VideoSelectionItem({
    Key? key,
    required this.video,
    required this.isSelected,
    required this.onSelectionChanged,
    this.singleSelection = false,
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
                width: 120.w,
                height: 68.w,
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
                                child:  Center(
                                  child: SizedBox(
                                    width: 16.w,
                                    height: 16.w,
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
                        fontSize: 15.sp,
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
                            fontSize: 12.sp,
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
                            fontSize: 12.sp,
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
                width: 24.w,
                height: 24.w,
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
                  borderRadius: widget.singleSelection 
                      ? BorderRadius.circular(12.r) // 单选时圆形
                      : BorderRadius.circular(4.r), // 多选时方形
                ),
                child: widget.isSelected
                    ? Icon(
                        widget.singleSelection ? Icons.circle : Icons.check,
                        color: Colors.white,
                        size: widget.singleSelection ? 12 : 16,
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

// 编辑合集弹窗
class EditSeriesDialog extends StatefulWidget {
  final UhomeSeriesController uhomeSeriesController;
  const EditSeriesDialog({
    Key? key,
    required this.uhomeSeriesController,
  }) : super(key: key);

  @override
  State<EditSeriesDialog> createState() => _EditSeriesDialogState();
}

class _EditSeriesDialogState extends State<EditSeriesDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  List<UserVideoSeriesVideo> _sortableVideos = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.uhomeSeriesController.videoSeriesDetail.value.videoSeries
              ?.seriesName ??
          '',
    );
    _descriptionController = TextEditingController(
      text: widget.uhomeSeriesController.videoSeriesDetail.value.videoSeries
              ?.seriesDescription ??
          '',
    );
    _sortableVideos = List.from(
      widget.uhomeSeriesController.videoSeriesDetail.value.seriesVideoList ??
          [],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool saving = false; // 添加保存状态变量
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width:( MediaQuery.of(context).size.width * 0.8).w,
        height: (MediaQuery.of(context).size.height * 0.8).w,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 标题栏
            Row(
              children: [
                Text(
                  widget.uhomeSeriesController.nowSelectSeriesId.value == 0
                      ? '新建合集'
                      : '编辑合集',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 标题输入框
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '合集标题',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              maxLength: 100,
            ),
            const SizedBox(height: 16),

            // 描述输入框
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '合集描述',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              maxLength: 200,
            ),
            const SizedBox(height: 24),

            // 视频排序标题
            Row(
              children: [
                const Icon(Icons.sort, size: 20),
                const SizedBox(width: 8),
                Text(
                  '视频排序',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const Spacer(),
                Text(
                  '拖动调整顺序',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 8),
                // 添加视频按钮
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: IconButton(
                    tooltip: '添加视频',
                    onPressed: () async {
                      final selectedVideos = await Get.dialog<List<VideoInfo>>(
                        VideoSelectionDialog(
                          excludeVideoIds: [
                            ..._sortableVideos.map((video) => video.videoId),
                          ],
                          seriesId: widget
                                      .uhomeSeriesController
                                      .videoSeriesDetail
                                      .value
                                      .videoSeries
                                      ?.seriesId ==
                                  0
                              ? null
                              : widget.uhomeSeriesController.videoSeriesDetail
                                  .value.videoSeries?.seriesId,
                          uhomeSeriesController: widget.uhomeSeriesController,
                        ),
                      );
                      if (selectedVideos != null && selectedVideos.isNotEmpty) {
                        setState(() {
                          // 将选择的视频添加到可排序列表中
                          _sortableVideos.addAll(
                            selectedVideos.map((video) {
                              return videoInfoToUserVideoSeriesVideo(video, 0);
                            }),
                          );
                        });
                      }
                    },
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
            const SizedBox(height: 12),

            // 可拖动视频列表
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _sortableVideos.length,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      if (newIndex > oldIndex) newIndex--;
                      final item = _sortableVideos.removeAt(oldIndex);
                      _sortableVideos.insert(newIndex, item);
                    });
                  },
                  itemBuilder: (context, index) {
                    final video = _sortableVideos[index];
                    return DraggableVideoItem(
                      key: ValueKey(video.videoId),
                      video: video,
                      index: index,
                      onDelete: () {
                        setState(() {
                          _sortableVideos.removeAt(index);
                        });
                      },
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 底部按钮
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        if (saving) return; // 如果正在保存则不重复提交
                        if (_sortableVideos.isEmpty) {
                          throw Exception('合集视频不能为空');
                        }
                        saving = true; // 设置保存状态为正在保存
                        var res = await ApiService.uhomeSeriesSaveVideoSeries(
                            seriesId: widget
                                        .uhomeSeriesController
                                        .videoSeriesDetail
                                        .value
                                        .videoSeries
                                        ?.seriesId ==
                                    0
                                ? null
                                : widget.uhomeSeriesController.videoSeriesDetail
                                    .value.videoSeries?.seriesId,
                            seriesName: _titleController.text.trim(),
                            seriesDesc: _descriptionController.text.trim(),
                            videoIds: _sortableVideos
                                .map((e) => e.videoId)
                                .toList()
                                .join(','));
                        if (res['code'] == 200) {
                          final videoSeries = widget.uhomeSeriesController
                              .videoSeriesDetail.value.videoSeries;
                          if (videoSeries == null ||
                              videoSeries.seriesId == 0) {
                            widget.uhomeSeriesController.loadUserVideoSeries();
                            Get.back(result: true);
                            showResSnackbar(res);
                          }
                          var toDeleteVideos = widget.uhomeSeriesController
                              .videoSeriesDetail.value.seriesVideoList!
                              .where((video) => !_sortableVideos
                                  .any((v) => v.videoId == video.videoId))
                              .toList();
                          for (var video in toDeleteVideos) {
                            var res1 =
                                await ApiService.uhomeSeriesDelSeriesVideo(
                                    seriesId: widget
                                        .uhomeSeriesController
                                        .videoSeriesDetail
                                        .value
                                        .videoSeries!
                                        .seriesId,
                                    videoId: video.videoId);
                            if (res1['code'] != 200) {
                              throw Exception(res1['info']);
                            }
                          }

                          var res2 =
                              await ApiService.uhomeSeriesSaveSeriesVideo(
                                  seriesId: widget
                                      .uhomeSeriesController
                                      .videoSeriesDetail
                                      .value
                                      .videoSeries!
                                      .seriesId,
                                  videoIds: _sortableVideos
                                      .map((e) => e.videoId)
                                      .toList()
                                      .join(','));
                          if (res2['code'] == 200) {
                            widget.uhomeSeriesController
                                .loadVideoSeriesDetail();
                            widget.uhomeSeriesController.loadUserVideoSeries();
                            Get.back(result: true);
                            showResSnackbar(res2);
                          } else {
                            throw Exception(res2['info']);
                          }
                        } else {
                          throw Exception(res['info']);
                        }
                      } catch (e) {
                        showErrorSnackbar(
                          e.toString(),
                        );
                      } finally {
                        saving = false; // 重置保存状态
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('确定'),
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

// 可拖动的视频条目
class DraggableVideoItem extends StatelessWidget {
  final UserVideoSeriesVideo video;
  final int index;
  final VoidCallback? onDelete;

  const DraggableVideoItem({
    Key? key,
    required this.video,
    required this.index,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),

          // 序号
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 视频封面
          Container(
            width: 80.w,
            height: 45.w,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(6),
            ),
            clipBehavior: Clip.antiAlias,
            child: video.videoCover.isNotEmpty
                ? ExtendedImage.network(
                    ApiService.baseUrl +
                        ApiAddr.fileGetResourcet +
                        video.videoCover,
                    fit: BoxFit.cover,
                    loadStateChanged: (ExtendedImageState state) {
                      switch (state.extendedImageLoadState) {
                        case LoadState.loading:
                          return Container(
                            color: Colors.grey[300],
                            child:  Center(
                              child: SizedBox(
                                width: 16.w,
                                height: 16.w,
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
                              size: 20,
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
                      size: 20,
                    ),
                  ),
          ),
          const SizedBox(width: 16),

          // 视频信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.videoName,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.play_circle_outline,
                      color: Colors.grey[500],
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_formatPlayCount(video.playCount)}次播放',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 删除按钮
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red[400],
                size: 20,
              ),
              tooltip: '删除视频',
              constraints:  BoxConstraints(
                minWidth: 32.w,
                minHeight: 32.w,
              ),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            ),
          const SizedBox(width: 16),
        ],
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
}
