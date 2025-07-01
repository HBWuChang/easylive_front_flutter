import 'package:get/get.dart';
import '../api_service.dart';
import '../classes.dart';
import '../Funcs.dart';

class HomeController extends GetxController {
  // 实时统计数据
  var statisticsInfo = Rxn<GetActualTimeStatisticsInfo>();
  
  // 周统计数据
  var weekStats = GetWeekStatisticsInfo().obs;
  
  // 当前选中的数据类型（用于图表显示）
  var selectedDataType = 0.obs;
  
  // 加载状态
  var isLoading = false.obs;
  var isLoadingWeekStats = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadStatisticsInfo();
    loadWeekStatistics(0); // 默认加载播放量数据
  }
  
  /// 加载统计数据
  Future<void> loadStatisticsInfo() async {
    isLoading.value = true;
    try {
      final response = await ApiService.ucenterGetActualTimeStatisticsInfo();
      
      if (response['code'] == 200) {
        final data = response['data'];
        if (data != null) {
          statisticsInfo.value = GetActualTimeStatisticsInfo.fromJson(data);
        }
      } else {
        showErrorSnackbar(response['info'] ?? '加载统计数据失败');
      }
    } catch (e) {
      showErrorSnackbar('加载统计数据失败: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }
  
  /// 加载周统计数据
  Future<void> loadWeekStatistics(int dataType) async {
    isLoadingWeekStats.value = true;
    selectedDataType.value = dataType;
    
    try {
      final response = await ApiService.ucenterGetWeekStatisticsInfo(dataType);

      if (response['code'] == 200) {
        final data = response['data'];
        if (data != null) {
          weekStats.value = GetWeekStatisticsInfo.fromJson(data);
        }
      } else {
        showErrorSnackbar(response['msg'] ?? '加载周统计失败');
      }
    } catch (e) {
      showErrorSnackbar('加载周统计失败: ${e.toString()}');
    } finally {
      isLoadingWeekStats.value = false;
    }
  }
  
  /// 切换数据类型
  void changeDataType(int dataType) {
    if (dataType != selectedDataType.value) {
      loadWeekStatistics(dataType);
    }
  }
  
  /// 刷新统计数据
  Future<void> refreshStatisticsInfo() async {
    await loadStatisticsInfo();
  }
  
  /// 刷新所有数据
  Future<void> refreshAll() async {
    await Future.wait([
      loadStatisticsInfo(),
      loadWeekStatistics(selectedDataType.value),
    ]);
  }
  
  /// 获取数据类型名称
  String getDataTypeName(int type) {
    switch (type) {
      case 0:
        return '播放量';
      case 1:
        return '粉丝数';
      case 2:
        return '点赞数';
      case 3:
        return '收藏数';
      case 4:
        return '硬币数';
      case 5:
        return '评论数';
      case 6:
        return '弹幕数';
      default:
        return '未知';
    }
  }
}
