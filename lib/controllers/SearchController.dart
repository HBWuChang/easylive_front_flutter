import 'package:get/get.dart';
import '../api_service.dart';

class SearchController extends GetxController {
  // 搜索关键词
  final searchKeyword = ''.obs;
  
  // 热门搜索关键词列表
  final hotKeywords = <String>[].obs;
  
  // 加载状态
  final isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadHotKeywords();
  }
  
  /// 加载热门搜索关键词
  Future<void> loadHotKeywords() async {
    try {
      isLoading.value = true;
      final response = await ApiService.videoGetSearchKeywordTop();
      
      if (response['code'] == 200 && response['data'] != null) {
        final keywords = List<String>.from(response['data'] ?? []);
        hotKeywords.assignAll(keywords);
      }
    } catch (e) {
      print('加载热门搜索关键词失败: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 执行搜索
  void search(String keyword) {
    if (keyword.trim().isEmpty) return;
    
    searchKeyword.value = keyword.trim();
    print('搜索关键词: ${searchKeyword.value}');
    
    // TODO: 实现搜索逻辑
    // 这里可以跳转到搜索结果页面或执行其他搜索操作
  }
  
  /// 清空搜索关键词
  void clearSearch() {
    searchKeyword.value = '';
  }
}
