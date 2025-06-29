import 'dart:async';
import 'package:easylive/controllers/controllers-class.dart';
import 'package:easylive/enums.dart';
import 'package:get/get.dart';
import '../api_service.dart';
import '../Funcs.dart';

class CategoryPageController extends GetxController {
  var videos = <VideoInfo>[].obs;
  var isLoading = true.obs;
  var loadingMore = false.obs;
  
  // 分页相关
  int pageNo = 1;
  int pageTotal = 1;
  
  // 分区相关
  var selectedPCategoryId = 0.obs;  // 当前选择的一级分区ID
  var selectedCategoryId = 0.obs;   // 当前选择的二级分区ID（0表示选择首页即一级分区）
  var selectedPCategoryName = ''.obs;  // 当前选择的一级分区名称
  var selectedCategoryName = ''.obs;   // 当前选择的二级分区名称
  var currentCategoryChildren = <Map<String, dynamic>>[].obs; // 当前一级分区的子分区列表

  @override
  void onInit() {
    super.onInit();
  }

  /// 使用分区ID初始化（从URL参数获取）
  void initWithIds(int pCategoryId, int? categoryId) {
    print('initWithIds 被调用: pCategoryId=$pCategoryId, categoryId=$categoryId');
    
    // 从已加载的分类中查找对应的分区信息
    final categories = Get.find<CategoryLoadAllCategoryController>().categories;
    final category = categories.firstWhere(
      (cat) => cat['categoryId'] == pCategoryId,
      orElse: () => <String, dynamic>{},
    );
    
    if (category.isNotEmpty) {
      selectedPCategoryId.value = pCategoryId;
      selectedPCategoryName.value = category['categoryName'];
      
      // 设置子分区列表
      currentCategoryChildren.value = List<Map<String, dynamic>>.from(
        category['children'] ?? []
      );
      
      if (categoryId != null && categoryId != 0) {
        // 二级分区
        final children = currentCategoryChildren;
        final childCategory = children.firstWhere(
          (child) => child['categoryId'] == categoryId,
          orElse: () => <String, dynamic>{},
        );
        
        if (childCategory.isNotEmpty) {
          selectedCategoryId.value = categoryId;
          selectedCategoryName.value = childCategory['categoryName'];
          print('初始化二级分区: ${selectedPCategoryName.value}-${selectedCategoryName.value}');
        }
      } else {
        // 一级分区（首页）
        selectedCategoryId.value = 0;
        selectedCategoryName.value = '';
        print('初始化一级分区: ${selectedPCategoryName.value}');
      }
      
      loadVideos(reset: true);
    } else {
      print('未找到分区ID: $pCategoryId');
    }
  }

  /// 设置当前分区并加载视频
  void setCategoryAndLoadVideos(String categoryDisplayName) {
    print('setCategoryAndLoadVideos 被调用: $categoryDisplayName');
    // 解析分区显示名称
    // 格式：一级分区名 或 一级分区名-二级分区名
    if (categoryDisplayName.contains('-')) {
      // 二级分区：使用第一个-作为分隔符
      final firstDashIndex = categoryDisplayName.indexOf('-');
      if (firstDashIndex > 0 && firstDashIndex < categoryDisplayName.length - 1) {
        final pCategoryName = categoryDisplayName.substring(0, firstDashIndex);
        final categoryName = categoryDisplayName.substring(firstDashIndex + 1);
        print('解析二级分区: $pCategoryName - $categoryName');
        _selectSecondaryCategory(pCategoryName, categoryName);
      }
    } else {
      // 选择的是一级分区
      print('解析一级分区: $categoryDisplayName');
      _selectPrimaryCategory(categoryDisplayName);
    }
  }

  /// 选择一级分区
  void _selectPrimaryCategory(String pCategoryName) {
    print('选择一级分区: $pCategoryName');
    // 从已加载的分类中查找对应的分区信息
    final categories = Get.find<CategoryLoadAllCategoryController>().categories;
    final category = categories.firstWhere(
      (cat) => cat['categoryName'] == pCategoryName,
      orElse: () => <String, dynamic>{},
    );
    
    if (category.isNotEmpty) {
      selectedPCategoryId.value = category['categoryId'];
      selectedCategoryId.value = 0; // 0表示首页（一级分区）
      selectedPCategoryName.value = pCategoryName;
      selectedCategoryName.value = '';
      
      print('设置一级分区ID: ${category['categoryId']}, 名称: $pCategoryName');
      
      // 设置子分区列表
      currentCategoryChildren.value = List<Map<String, dynamic>>.from(
        category['children'] ?? []
      );
      
      loadVideos(reset: true);
    } else {
      print('未找到分区: $pCategoryName');
    }
  }

  /// 选择二级分区
  void _selectSecondaryCategory(String pCategoryName, String categoryName) {
    // 从已加载的分类中查找对应的分区信息
    final categories = Get.find<CategoryLoadAllCategoryController>().categories;
    final parentCategory = categories.firstWhere(
      (cat) => cat['categoryName'] == pCategoryName,
      orElse: () => <String, dynamic>{},
    );
    
    if (parentCategory.isNotEmpty) {
      final children = List<Map<String, dynamic>>.from(parentCategory['children'] ?? []);
      final childCategory = children.firstWhere(
        (child) => child['categoryName'] == categoryName,
        orElse: () => <String, dynamic>{},
      );
      
      if (childCategory.isNotEmpty) {
        selectedPCategoryId.value = parentCategory['categoryId'];
        selectedCategoryId.value = childCategory['categoryId'];
        selectedPCategoryName.value = pCategoryName;
        selectedCategoryName.value = categoryName;
        
        // 设置子分区列表（当前一级分区的所有子分区）
        currentCategoryChildren.value = children;
        
        loadVideos(reset: true);
      }
    }
  }

  /// 选择首页（一级分区）
  void selectHomePage() {
    selectedCategoryId.value = 0;
    selectedCategoryName.value = '';
    loadVideos(reset: true);
  }

  /// 选择子分区
  void selectChildCategory(Map<String, dynamic> childCategory) {
    selectedCategoryId.value = childCategory['categoryId'];
    selectedCategoryName.value = childCategory['categoryName'];
    loadVideos(reset: true);
  }

  /// 加载分区视频
  Future<void> loadVideos({bool reset = false}) async {
    if (reset) {
      pageNo = 1;
      isLoading.value = true;
    }

    try {
      print('开始加载视频 - pCategoryId: ${selectedPCategoryId.value}, categoryId: ${selectedCategoryId.value}, pageNo: $pageNo');
      
      final response = await ApiService.videoLoadVideo(
        pCategoryId: selectedPCategoryId.value,
        categoryId: selectedCategoryId.value == 0 ? null : selectedCategoryId.value,
        pageNo: pageNo,
      );

      print('API响应: ${response['code']}, 数据: ${response['data']}');

      if (response['code'] == 200) {
        final data = response['data'];
        pageNo = data['pageNo'] ?? 1;
        pageTotal = data['pageTotal'] ?? 1;
        
        final newVideos = (data['list'] as List)
            .map((item) => VideoInfo(item as Map<String, dynamic>))
            .toList();

        if (reset) {
          videos.value = newVideos;
        } else {
          videos.addAll(newVideos);
        }
        
        print('加载分区视频成功: ${newVideos.length}个视频');
      } else {
        throw Exception('加载分区视频失败: ${response['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
    } finally {
      isLoading.value = false;
      loadingMore.value = false;
    }
  }

  /// 加载更多视频
  Future<bool> loadMoreVideos() async {
    if (loadingMore.value || pageNo >= pageTotal) {
      return false; // 如果正在加载或已经是最后一页，直接返回
    }
    
    loadingMore.value = true;
    try {
      final response = await ApiService.videoLoadVideo(
        pCategoryId: selectedPCategoryId.value,
        categoryId: selectedCategoryId.value == 0 ? null : selectedCategoryId.value,
        pageNo: pageNo + 1,
      );

      if (response['code'] == 200) {
        final data = response['data'];
        pageNo = data['pageNo'] ?? pageNo + 1;
        pageTotal = data['pageTotal'] ?? pageTotal;
        
        final newVideos = (data['list'] as List)
            .map((item) => VideoInfo(item as Map<String, dynamic>))
            .toList();

        videos.addAll(newVideos);
        print('加载更多分区视频成功: ${newVideos.length}个新视频');
        return true; // 成功加载更多视频
      } else {
        throw Exception('加载更多分区视频失败: ${response['info']}');
      }
    } catch (e) {
      showErrorSnackbar(e.toString());
      return false; // 加载失败
    } finally {
      loadingMore.value = false;
    }
  }

  /// 获取当前分区的显示名称
  String get currentCategoryDisplayName {
    if (selectedCategoryName.value.isEmpty) {
      return selectedPCategoryName.value;
    } else {
      return '${selectedPCategoryName.value}-${selectedCategoryName.value}';
    }
  }

  /// 获取当前选择的分区类型（用于显示）
  String get currentSelectionText {
    if (selectedCategoryName.value.isEmpty) {
      return '首页'; // 一级分区
    } else {
      return selectedCategoryName.value; // 二级分区
    }
  }
}
