import 'package:get/get.dart';
import '../api_service.dart';
import '../settings.dart';

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
    
    // 跳转到搜索结果页面
    final url = '${Routes.searchPage}?keyword=${Uri.encodeQueryComponent(keyword.trim())}';
    Get.toNamed(url, id: Routes.mainGetId);
  }
  
  /// 清空搜索关键词
  void clearSearch() {
    searchKeyword.value = '';
  }
}
