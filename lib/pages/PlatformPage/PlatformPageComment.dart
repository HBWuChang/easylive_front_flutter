import 'package:easylive/Funcs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../classes.dart';
import '../../controllers/controllers-class.dart';
import '../../controllers/UhomeSeriesController.dart';
import '../UHome/UhomeWidgets.dart';

class PlatformPageComment extends StatefulWidget {
  const PlatformPageComment({Key? key}) : super(key: key);
  @override
  State<PlatformPageComment> createState() => _PlatformPageCommentState();
}

class _PlatformPageCommentState extends State<PlatformPageComment> {
  final ScrollController _scrollController = ScrollController();
  late UhomeSeriesController _uhomeSeriesController; // 添加控制器

  var comments = <VideoComment>[].obs;
  var currentPage = 1.obs;
  var totalCount = 0.obs;
  var pageSize = 15.obs;
  var hasMoreData = true.obs;
  var selectedVideoId = ''.obs; // 替换原来的 videoNameFuzzy
  var selectedVideoName = ''.obs; // 添加选中视频名称
  var isLoading = false.obs;
  var isRefreshing = false.obs;  @override
  void initState() {
    super.initState();
    print('PlatformPageComment initState');
    
    // 初始化控制器
    if (!Get.isRegistered<UhomeSeriesController>()) {
      Get.put(UhomeSeriesController(userId: "1"));
    }
    _uhomeSeriesController = Get.find<UhomeSeriesController>();

    // 监听滚动事件，实现无限滚动
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreComments();
      }
    });
    
    // 初始加载评论
    _loadComments(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 加载评论列表
  Future<void> _loadComments({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      isRefreshing.value = true;
    } else {
      if (!hasMoreData.value || isLoading.value) return;
      isLoading.value = true;
    }

    try {
      // 由于当前API需要videoId参数，我们传入选中的视频ID
      final response = await ApiService.ucenterLoadComment(
        videoId: selectedVideoId.value.isEmpty ? '' : selectedVideoId.value,
        pageNo: currentPage.value,
      );

      if (response['code'] == 200) {
        final data = response['data'];
        final List<dynamic> commentList = data['list'] ?? [];

        // 转换为VideoComment对象
        final List<VideoComment> newComments = commentList
            .map((item) => VideoComment(item as Map<String, dynamic>))
            .toList();

        // 更新数据
        if (isRefresh) {
          comments.value = newComments;
        } else {
          comments.addAll(newComments);
        }

        // 更新分页信息
        totalCount.value = data['totalCount'] ?? 0;
        hasMoreData.value = newComments.length >= pageSize.value;

        if (!isRefresh) {
          currentPage.value++;
        }
      } else {
        showErrorSnackbar(response['info'] ?? '加载评论失败');
      }
    } catch (e) {
      showErrorSnackbar('加载评论失败: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  /// 显示成功消息
  void _showSuccessSnackbar(String message) {
    Get.snackbar(
      '成功',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor:
          Theme.of(Get.context!).colorScheme.primary.withOpacity(0.8),
      colorText: Theme.of(Get.context!).colorScheme.onPrimary,
      duration: Duration(milliseconds: 2000),
    );
  }

  /// 删除评论
  Future<void> _deleteComment(int commentId) async {
    try {
      final response = await ApiService.ucenterDelComment(commentId);

      if (response['code'] == 200) {
        // 从列表中移除评论
        comments.removeWhere((comment) => comment.commentId == commentId);
        totalCount.value--;
        _showSuccessSnackbar('删除评论成功');
      } else {
        showErrorSnackbar(response['info'] ?? '删除评论失败');
      }
    } catch (e) {
      showErrorSnackbar('删除评论失败: ${e.toString()}');
    }
  }

  /// 刷新评论列表
  Future<void> _refreshComments() async {
    await _loadComments(isRefresh: true);
  }

  /// 加载更多评论
  Future<void> _loadMoreComments() async {
    await _loadComments();
  }

  /// 清空搜索条件
  void _clearSearch() {
    selectedVideoId.value = '';
    selectedVideoName.value = '';
    _loadComments(isRefresh: true);
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
          // 评论列表
          Expanded(
            child: _buildCommentList(),
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
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(8.sp),
              ),
              child: Row(
                children: [
                  Icon(Icons.video_library_outlined, 
                       color: Theme.of(context).colorScheme.outline),
                  SizedBox(width: 8.sp),
                  Expanded(
                    child: Text(
                      selectedVideoName.value.isEmpty 
                          ? '选择视频查看评论' 
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
                  title: '选择要查看评论的视频',
                  selectButtonText: '确定',
                ),
              );
              
              if (selectedVideos != null && selectedVideos.isNotEmpty) {
                final video = selectedVideos.first;
                selectedVideoId.value = video.videoId ?? '';
                selectedVideoName.value = video.videoName ?? '';
                _loadComments(isRefresh: true);
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
              _clearSearch();
            },
            child: Text('清空'),
          ),
          SizedBox(width: 8.sp),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _refreshComments(),
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
                '总评论数: ${totalCount.value}',
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
                  onDeleted: () => _clearSearch(),
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

  Widget _buildCommentList() {
    return Obx(() {
      if (isRefreshing.value && comments.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      if (comments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.comment_outlined,
                  size: 64.sp, color: Theme.of(context).colorScheme.outline),
              SizedBox(height: 16.sp),
              Text(
                '暂无评论数据',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: _refreshComments,
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.all(16.sp),
          itemCount: comments.length + (hasMoreData.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= comments.length) {
              return _buildLoadingItem();
            }
            return _buildCommentItem(comments[index]);
          },
        ),
      );
    });
  }

  Widget _buildCommentItem(VideoComment comment) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.sp),
      elevation: 2,
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 视频信息
            if (comment.videoName != null || comment.videoCover != null)
              _buildVideoInfo(comment),

            // 用户信息和评论内容
            _buildCommentContent(comment),

            // 回复信息
            if (comment.replyUserId != null && comment.replyNickName != null)
              _buildReplyInfo(comment),

            // 统计信息和操作按钮
            _buildCommentActions(comment),

            // 子评论
            if (comment.children.isNotEmpty)
              _buildChildComments(comment.children),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoInfo(VideoComment comment) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8.sp),
      ),
      child: Row(
        children: [
          if (comment.videoCover != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(6.sp),
              child: ExtendedImage.network(
                getFullImageUrl(comment.videoCover!),
                width: 60.sp,
                height: 40.sp,
                fit: BoxFit.cover,
                loadStateChanged: (state) {
                  if (state.extendedImageLoadState == LoadState.failed) {
                    return Container(
                      width: 60.sp,
                      height: 40.sp,
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
          if (comment.videoCover != null) SizedBox(width: 12.sp),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (comment.videoName != null)
                  Text(
                    comment.videoName!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (comment.videoId != null)
                  Text(
                    'ID: ${comment.videoId}',
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

  Widget _buildCommentContent(VideoComment comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 用户信息
        Row(
          children: [
            CircleAvatar(
              radius: 16.sp,
              backgroundImage: comment.avatar != null
                  ? ExtendedNetworkImageProvider(
                      getFullImageUrl(comment.avatar!),
                    )
                  : null,
              child: comment.avatar == null
                  ? Icon(Icons.person, size: 16.sp)
                  : null,
            ),
            SizedBox(width: 8.sp),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.nickName ?? '匿名用户',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  if (comment.postTime != null)
                    Text(
                      _formatDateTime(comment.postTime!),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 12.sp,
                      ),
                    ),
                ],
              ),
            ),
            if (comment.topType == 1)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.sp, vertical: 2.sp),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(4.sp),
                ),
                child: Text(
                  '置顶',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onError,
                    fontSize: 10.sp,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 8.sp),

        // 评论内容
        if (comment.content != null)
          Text(
            comment.content!,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

        // 评论图片
        if (comment.imgPath != null && comment.imgPath!.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8.sp),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.sp),
              child: ExtendedImage.network(
                getFullImageUrl(comment.imgPath!),
                width: 200.sp,
                fit: BoxFit.cover,
                loadStateChanged: (state) {
                  if (state.extendedImageLoadState == LoadState.failed) {
                    return Container(
                      width: 200.sp,
                      height: 150.sp,
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.3),
                      child: Icon(Icons.broken_image,
                          color: Theme.of(context).colorScheme.outline),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildReplyInfo(VideoComment comment) {
    return Container(
      margin: EdgeInsets.only(top: 8.sp),
      padding: EdgeInsets.all(8.sp),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(6.sp),
        border: Border.all(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.reply,
              size: 16.sp, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 4.sp),
          Text(
            '回复 ',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12.sp,
            ),
          ),
          if (comment.replyAvatar != null)
            CircleAvatar(
              radius: 10.sp,
              backgroundImage: ExtendedNetworkImageProvider(
                getFullImageUrl(comment.replyAvatar!),
              ),
            ),
          if (comment.replyAvatar != null) SizedBox(width: 4.sp),
          Text(
            comment.replyNickName!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentActions(VideoComment comment) {
    return Container(
      margin: EdgeInsets.only(top: 12.sp),
      child: Row(
        children: [
          // 点赞数
          Row(
            children: [
              Icon(Icons.thumb_up_outlined,
                  size: 16.sp, color: Theme.of(context).colorScheme.outline),
              SizedBox(width: 4.sp),
              Text(
                '${comment.likeCount ?? 0}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          SizedBox(width: 16.sp),

          // 踩数
          Row(
            children: [
              Icon(Icons.thumb_down_outlined,
                  size: 16.sp, color: Theme.of(context).colorScheme.outline),
              SizedBox(width: 4.sp),
              Text(
                '${comment.hateCount ?? 0}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),

          Spacer(),

          // 删除按钮
          TextButton.icon(
            onPressed: () => _showDeleteDialog(comment),
            icon: Icon(Icons.delete_outline, size: 16.sp),
            label: Text('删除'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              padding: EdgeInsets.symmetric(horizontal: 8.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildComments(List<VideoComment> children) {
    return Container(
      margin: EdgeInsets.only(top: 12.sp, left: 20.sp),
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8.sp),
        border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '回复 (${children.length})',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.sp),
          ...children.map((child) => Container(
                margin: EdgeInsets.only(bottom: 8.sp),
                child: _buildCommentContent(child),
              )),
        ],
      ),
    );
  }

  Widget _buildLoadingItem() {
    return Obx(() {
      if (isLoading.value) {
        return Container(
          padding: EdgeInsets.all(16.sp),
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        );
      }
      return SizedBox.shrink();
    });
  }

  void _showDeleteDialog(VideoComment comment) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('确认删除'),
          content: Text('确定要删除这条评论吗？此操作不可撤销。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (comment.commentId != null) {
                  _deleteComment(comment.commentId!);
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text('删除'),
            ),
          ],
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
