import 'package:easylive/Funcs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/DanmuController.dart';
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
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print('PlatformPageDanmaku initState');
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
    searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('弹幕管理'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.refreshDanmus(),
          ),
        ],
      ),
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: '请输入视频名称进行搜索',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
              onSubmitted: (value) => controller.searchDanmus(value),
            ),
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            onPressed: () => controller.searchDanmus(searchController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
            child: Text('搜索'),
          ),
          SizedBox(width: 8.w),
          OutlinedButton(
            onPressed: () {
              searchController.clear();
              controller.clearSearch();
            },
            child: Text('清空'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsArea() {
    return Obx(() => Container(
          padding: EdgeInsets.all(16.w),
          color: Colors.grey[50],
          child: Row(
            children: [
              Text(
                '总弹幕数: ${controller.totalCount.value}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              Spacer(),
              if (controller.videoNameFuzzy.value.isNotEmpty)
                Chip(
                  label: Text('搜索: ${controller.videoNameFuzzy.value}'),
                  onDeleted: () => controller.clearSearch(),
                  backgroundColor: Colors.blue[50],
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
              Icon(Icons.chat_bubble_outline, size: 64.sp, color: Colors.grey),
              SizedBox(height: 16.h),
              Text(
                '暂无弹幕数据',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey),
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
        color: Colors.grey[50],
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
                      color: Colors.grey[300],
                      child: Icon(Icons.broken_image, size: 16.sp),
                    );
                  }
                  return null;
                },
              ),
            ),
          if (danmu.videoCover != null && danmu.videoCover!.isNotEmpty) SizedBox(width: 12.w),
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
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (danmu.videoId.isNotEmpty)
                  Text(
                    'ID: ${danmu.videoId}',
                    style: TextStyle(
                      color: Colors.grey[600],
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
            Icon(Icons.person_outline, size: 16.sp, color: Colors.grey[600]),
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
                    ),
                  ),
                  Text(
                    controller.formatDateTime(danmu.postTime),
                    style: TextStyle(
                      color: Colors.grey[600],
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
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                controller.formatTime(danmu.time),
                style: TextStyle(
                  color: Colors.blue[700],
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
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            danmu.text,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              height: 1.4,
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
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(4.r),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Text(
              controller.getDanmuModeText(danmu.mode),
              style: TextStyle(
                color: Colors.green[700],
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
              border: Border.all(color: Colors.grey[300]!),
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            danmu.color,
            style: TextStyle(
              color: Colors.grey[600],
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
                color: Colors.grey[500],
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
              color: Colors.grey[600],
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
              foregroundColor: Colors.red,
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
                  color: Colors.grey[100],
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
                Navigator.of(context).pop();
                controller.deleteDanmu(danmu.danmuId);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('删除'),
            ),
          ],
        );
      },
    );
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
      return Colors.blue[600]!;
    } catch (e) {
      return Colors.blue[600]!;
    }
  }
}
