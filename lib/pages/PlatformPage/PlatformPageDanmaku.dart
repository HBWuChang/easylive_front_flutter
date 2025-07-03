import 'package:easylive/Funcs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/DanmuController.dart';
import '../../controllers/UhomeSeriesController.dart';
import '../../controllers/controllers-class.dart';
import '../UHome/UhomeWidgets.dart';
import '../../classes.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlatformPageDanmaku extends StatefulWidget {
  const PlatformPageDanmaku({Key? key}) : super(key: key);
  @override
  State<PlatformPageDanmaku> createState() => _PlatformPageDanmakuState();
}

class _PlatformPageDanmakuState extends State<PlatformPageDanmaku> {
  final DanmuController controller = Get.put(DanmuController());
  final ScrollController scrollController = ScrollController();
  late UhomeSeriesController _uhomeSeriesController;

  var selectedVideoId = ''.obs;
  var selectedVideoName = ''.obs;

  @override
  void initState() {
    super.initState();
    print('PlatformPageDanmaku initState');

    // 初始化控制器
    if (!Get.isRegistered<UhomeSeriesController>()) {
      Get.put(UhomeSeriesController(userId: "1"));
    }
    _uhomeSeriesController = Get.find<UhomeSeriesController>();

    // 监听滚动事件，实现无限滚动
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        controller.loadMoreDanmus();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          // 搜索区域
          _buildSearchArea(),
          // 统计信息
          _buildStatisticsArea(),
          // 弹幕列表
          Expanded(
            child: _buildDanmuList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchArea() {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: Theme.of(context).colorScheme.outline),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.video_library_outlined,
                          color: Theme.of(context).colorScheme.outline),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: Text(
                          selectedVideoName.value.isEmpty
                              ? '选择视频查看弹幕'
                              : selectedVideoName.value,
                          style: TextStyle(
                            color: selectedVideoName.value.isEmpty
                                ? Theme.of(context).colorScheme.outline
                                : Theme.of(context).colorScheme.onSurface,
                            fontSize: 14.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )),
          ),
          SizedBox(width: 12.sp),
          ElevatedButton(
            onPressed: () async {
              final selectedVideos = await Get.dialog<List<VideoInfo>>(
                VideoSelectionDialog(
                  excludeVideoIds: [],
                  seriesId: null,
                  uhomeSeriesController: _uhomeSeriesController,
                  singleSelection: true,
                  title: '选择要查看弹幕的视频',
                  selectButtonText: '确定',
                ),
              );

              if (selectedVideos != null && selectedVideos.isNotEmpty) {
                final video = selectedVideos.first;
                selectedVideoId.value = video.videoId ?? '';
                selectedVideoName.value = video.videoName ?? '';
                await controller.filterByVideoId(selectedVideoId.value);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 24.sp, vertical: 12.sp),
            ),
            child: Text('选择视频'),
          ),
          SizedBox(width: 8.sp),
          OutlinedButton(
            onPressed: () {
              _clearFilter();
            },
            child: Text('清空'),
          ),
          SizedBox(width: 8.sp),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.refreshDanmus(),
            tooltip: '刷新',
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsArea() {
    return Obx(() => Container(
          padding: EdgeInsets.all(16.sp),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Row(
            children: [
              Text(
                '总弹幕数: ${controller.totalCount.value}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Spacer(),
              if (selectedVideoName.value.isNotEmpty)
                Chip(
                  label: Text('视频: ${selectedVideoName.value}'),
                  onDeleted: () => _clearFilter(),
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
            ],
          ),
        ));
  }

  Widget _buildDanmuList() {
    return Obx(() {
      if (controller.isRefreshing.value && controller.danmus.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      if (controller.danmus.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline,
                  size: 64.sp, color: Theme.of(context).colorScheme.outline),
              SizedBox(height: 16.h),
              Text(
                '暂无弹幕数据',
                style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.outline),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshDanmus,
        child: ListView.builder(
          controller: scrollController,
          padding: EdgeInsets.all(16.w),
          itemCount:
              controller.danmus.length + (controller.hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.danmus.length) {
              return _buildLoadingItem();
            }
            return _buildDanmuItem(controller.danmus[index]);
          },
        ),
      );
    });
  }

  Widget _buildDanmuItem(VideoDanmu danmu) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频信息
            if (danmu.videoName != null && danmu.videoName!.isNotEmpty ||
                danmu.videoCover != null && danmu.videoCover!.isNotEmpty)
              _buildVideoInfo(danmu),

            // 弹幕内容和信息
            _buildDanmuContent(danmu),

            // 弹幕样式信息
            _buildDanmuStyle(danmu),

            // 操作按钮
            _buildDanmuActions(danmu),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo(VideoDanmu danmu) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          if (danmu.videoCover != null && danmu.videoCover!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: ExtendedImage.network(
                getFullImageUrl(danmu.videoCover!),
                width: 60.w,
                height: 40.h,
                fit: BoxFit.cover,
                loadStateChanged: (state) {
                  if (state.extendedImageLoadState == LoadState.failed) {
                    return Container(
                      width: 60.w,
                      height: 40.h,
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.3),
                      child: Icon(Icons.broken_image,
                          size: 16.sp,
                          color: Theme.of(context).colorScheme.outline),
                    );
                  }
                  return null;
                },
              ),
            ),
          if (danmu.videoCover != null && danmu.videoCover!.isNotEmpty)
            SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (danmu.videoName != null && danmu.videoName!.isNotEmpty)
                  Text(
                    danmu.videoName!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (danmu.videoId.isNotEmpty)
                  Text(
                    'ID: ${danmu.videoId}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 12.sp,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDanmuContent(VideoDanmu danmu) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 用户信息和发布时间
        Row(
          children: [
            Icon(Icons.person_outline,
                size: 16.sp, color: Theme.of(context).colorScheme.outline),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    danmu.nickName ?? '匿名用户',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    controller.formatDateTime(danmu.postTime),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            // 播放时间
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                controller.formatTime(danmu.time),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // 弹幕文本内容
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          child: Text(
            danmu.text,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDanmuStyle(VideoDanmu danmu) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      child: Row(
        children: [
          // 弹幕类型
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(
                  color:
                      Theme.of(context).colorScheme.primary.withOpacity(0.5)),
            ),
            child: Text(
              controller.getDanmuModeText(danmu.mode),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),

          // 颜色标识
          Container(
            width: 20.w,
            height: 20.h,
            decoration: BoxDecoration(
              color: _parseColor(danmu.color),
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            danmu.color,
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12.sp,
              fontFamily: 'monospace',
            ),
          ),

          Spacer(),

          // 文件ID
          if (danmu.fileId.isNotEmpty)
            Text(
              'File: ${danmu.fileId}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.7),
                fontSize: 11.sp,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDanmuActions(VideoDanmu danmu) {
    return Container(
      margin: EdgeInsets.only(top: 12.h),
      child: Row(
        children: [
          Text(
            'ID: ${danmu.danmuId}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.outline,
              fontSize: 12.sp,
            ),
          ),

          Spacer(),

          // 删除按钮
          TextButton.icon(
            onPressed: () => _showDeleteDialog(danmu),
            icon: Icon(Icons.delete_outline, size: 16.sp),
            label: Text('删除'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              padding: EdgeInsets.symmetric(horizontal: 8.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingItem() {
    return Obx(() {
      if (controller.isLoading.value) {
        return Container(
          padding: EdgeInsets.all(16.w),
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        );
      }
      return SizedBox.shrink();
    });
  }

  void _showDeleteDialog(VideoDanmu danmu) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认删除'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('确定要删除这条弹幕吗？此操作不可撤销。'),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  danmu.text,
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                controller.deleteDanmu(danmu.danmuId);
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error),
              child: Text('删除'),
            ),
          ],
        );
      },
    );
  }

  /// 清空筛选条件
  void _clearFilter() {
    selectedVideoId.value = '';
    selectedVideoName.value = '';
    controller.clearFilter();
  }

  Color _parseColor(String colorStr) {
    try {
      if (colorStr.startsWith('#')) {
        String hex = colorStr.substring(1);
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        }
      } else {
        String hex = colorStr;
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        }
      }
      return Theme.of(context).colorScheme.primary;
    } catch (e) {
      return Theme.of(context).colorScheme.primary;
    }
  }
}
