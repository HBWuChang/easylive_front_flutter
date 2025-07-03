import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../api_service.dart';
import '../classes.dart';
import '../Funcs.dart';

class DanmuController extends GetxController {
  // 弹幕列表
  var danmus = <VideoDanmu>[].obs;
  
  // 分页相关
  var currentPage = 1.obs;
  var totalCount = 0.obs;
  var pageSize = 15.obs;
  var hasMoreData = true.obs;
  
  // 视频筛选条件
  var selectedVideoId = ''.obs;
  
  // 加载状态
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadDanmus();
  }
  
  /// 加载弹幕列表
  Future<void> loadDanmus({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
      hasMoreData.value = true;
      isRefreshing.value = true;
    } else {
      if (!hasMoreData.value || isLoading.value) return;
      isLoading.value = true;
    }
    
    try {
      final response = await ApiService.ucenterLoadDanmu(
        videoId: selectedVideoId.value, // 使用选中的视频ID
        pageNo: currentPage.value,
      );
      
      if (response['code'] == 200) {
        final data = response['data'];
        final List<dynamic> danmuList = data['list'] ?? [];
        
        // 转换为VideoDanmu对象
        final List<VideoDanmu> newDanmus = danmuList
            .map((item) => VideoDanmu(item as Map<String, dynamic>))
            .toList();
        
        // 更新数据
        if (isRefresh) {
          danmus.value = newDanmus;
        } else {
          danmus.addAll(newDanmus);
        }
        
        // 更新分页信息
        totalCount.value = data['totalCount'] ?? 0;
        hasMoreData.value = newDanmus.length >= pageSize.value;
        
        if (!isRefresh) {
          currentPage.value++;
        }
      } else {
        showErrorSnackbar(response['info'] ?? '加载弹幕失败');
      }
    } catch (e) {
      showErrorSnackbar('加载弹幕失败: ${e.toString()}');
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }
  
  /// 删除弹幕
  Future<void> deleteDanmu(int danmuId) async {
    try {
      final response = await ApiService.ucenterDelDanmu(danmuId);
      
      if (response['code'] == 200) {
        // 从列表中移除弹幕
        danmus.removeWhere((danmu) => danmu.danmuId == danmuId);
        totalCount.value--;
        Get.snackbar(
          '成功',
          '删除弹幕成功',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.withOpacity(0.8),
          colorText: Colors.white,
        );
      } else {
        showErrorSnackbar(response['info'] ?? '删除弹幕失败');
      }
    } catch (e) {
      showErrorSnackbar('删除弹幕失败: ${e.toString()}');
    }
  }
  
  /// 搜索弹幕
  /// 按视频ID筛选弹幕
  Future<void> filterByVideoId(String videoId) async {
    selectedVideoId.value = videoId;
    await loadDanmus(isRefresh: true);
  }
  
  /// 刷新弹幕列表
  Future<void> refreshDanmus() async {
    await loadDanmus(isRefresh: true);
  }
  
  /// 加载更多弹幕
  Future<void> loadMoreDanmus() async {
    await loadDanmus();
  }
  
  /// 清空筛选条件
  void clearFilter() {
    selectedVideoId.value = '';
    loadDanmus(isRefresh: true);
  }
  
  /// 获取弹幕模式显示文本
  String getDanmuModeText(int mode) {
    switch (mode) {
      case 0:
        return '滚动弹幕';
      case 1:
        return '顶部弹幕';
      case 2:
        return '底部弹幕';
      default:
        return '未知类型';
    }
  }
  
  /// 格式化时间显示
  String formatTime(int timeInSeconds) {
    final minutes = timeInSeconds ~/ 60;
    final seconds = timeInSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// 格式化日期时间
  String formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
