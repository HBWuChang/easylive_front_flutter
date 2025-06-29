import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../api_service.dart';
import '../enums.dart';
import 'controllers-class.dart';

class SearchPageController extends GetxController {
  // 搜索关键词
  final searchKeyword = ''.obs;
  
  // 当前选中的排序方式
  final selectedOrderType = VideoOrderTypeEnum.CREATE_TIME.obs;
  
  // 搜索结果视频列表
  final videos = <VideoInfo>[].obs;
  
  // 分页相关
  var pageNo = 1;
  var pageTotal = 1;
  
  // 加载状态
  final isLoading = false.obs;
  final loadingMore = false.obs;
  
  // 滚动控制器
  late ScrollController scrollController;
  
  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
  }
  
  @override
  void onClose() {
    scrollController.removeListener(_scrollListener);
    scrollController.dispose();
    super.onClose();
  }
  
  void _scrollListener() {
    // 检查是否需要加载更多
    if (scrollController.position.pixels >= 
        scrollController.position.maxScrollExtent - 200) {
      loadMoreVideos();
    }
  }
  
  /// 初始化搜索页面
  void initWithKeyword(String keyword) {
    searchKeyword.value = keyword;
    searchVideos(isRefresh: true);
  }
  
  /// 执行搜索
  Future<void> searchVideos({bool isRefresh = false}) async {
    if (searchKeyword.value.trim().isEmpty) return;
    
    try {
      if (isRefresh) {
        isLoading.value = true;
        pageNo = 1;
        videos.clear();
      } else {
        loadingMore.value = true;
      }
      
      final response = await ApiService.videoSearch(
        keyword: searchKeyword.value,
        orderType: selectedOrderType.value.type,
        pageNo: pageNo,
      );
      
      if (response['code'] == 200 && response['data'] != null) {
        final data = response['data'];
        final videoList = List<Map<String, dynamic>>.from(data['list'] ?? []);
        final videoInfoList = videoList.map((videoData) => VideoInfo(videoData)).toList();
        
        if (isRefresh) {
          videos.assignAll(videoInfoList);
        } else {
          videos.addAll(videoInfoList);
        }
        
        pageTotal = data['total'] ?? 1;
        pageNo++;
      }
    } catch (e) {
      print('搜索视频失败: $e');
    } finally {
      isLoading.value = false;
      loadingMore.value = false;
    }
  }
  
  /// 加载更多视频
  void loadMoreVideos() {
    if (!loadingMore.value && pageNo <= pageTotal) {
      searchVideos(isRefresh: false);
    }
  }
  
  /// 更改排序方式
  void changeOrderType(VideoOrderTypeEnum orderType) {
    if (selectedOrderType.value != orderType) {
      selectedOrderType.value = orderType;
      searchVideos(isRefresh: true);
    }
  }
  
  /// 更新搜索关键词并搜索
  void updateKeywordAndSearch(String keyword) {
    if (keyword.trim().isNotEmpty && keyword != searchKeyword.value) {
      searchKeyword.value = keyword;
      searchVideos(isRefresh: true);
    }
  }
}
