import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/SearchPageController.dart';
import '../../enums.dart';
import '../MainPage/VideoInfoWidget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final SearchPageController controller = Get.put(SearchPageController());

  @override
  void initState() {
    super.initState();

    // 获取路由参数
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final route = ModalRoute.of(context);
      if (route != null && route.settings.name != null) {
        final uri = Uri.parse(route.settings.name!);
        final keyword = uri.queryParameters['keyword'];

        if (keyword != null && keyword.isNotEmpty) {
          print('SearchPage 接收到的搜索关键词: $keyword');
          controller.initWithKeyword(keyword);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: controller.scrollController,
        slivers: [
          // 固定搜索框（会在滚动时pin在顶部）
          SliverPersistentHeader(
            pinned: true,
            delegate: _SearchHeaderDelegate(
              onSearchChanged: (keyword) =>
                  controller.updateKeywordAndSearch(keyword),
              currentKeyword: controller.searchKeyword,
            ),
          ),

          // 排序方式Row
          SliverToBoxAdapter(
            child: _buildOrderTypeRow(),
          ),

          // 搜索结果视频区域
          SliverToBoxAdapter(
            child: Obx(() => _buildVideoGrid()),
          ),

          // 底部占位控件
          SliverToBoxAdapter(
            child: Container(
              height: 100.h,
              color: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建排序方式Row
  Widget _buildOrderTypeRow() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      child: Row(
        children: [
          Text(
            '排序方式：',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 12.w),

          // 排序选项按钮
          ...VideoOrderTypeEnum.values.map((orderType) {
            return Obx(() {
              final isSelected =
                  controller.selectedOrderType.value == orderType;
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () => controller.changeOrderType(orderType),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.w),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      orderType.desc,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            });
          }).toList(),
        ],
      ),
    );
  }

  /// 构建视频网格（参考CategoryPage样式）
  Widget _buildVideoGrid() {
    if (controller.isLoading.value && controller.videos.isEmpty) {
      return Container(
        height: 300.h,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (controller.videos.isEmpty && !controller.isLoading.value) {
      return Container(
        height: 300.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64.w,
                color: Colors.grey[400],
              ),
              SizedBox(height: 16.h),
              Text(
                controller.searchKeyword.value.isEmpty ? '请输入搜索关键词' : '未找到相关视频',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 114.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索结果统计
          if (controller.videos.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.w),
              child: Text(
                '搜索"${controller.searchKeyword.value}"，找到${controller.videos.length}个视频',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ),

          // 视频网格（使用CategoryPage的5列布局）
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12.w,
              crossAxisSpacing: 12.w,
              childAspectRatio:
                  AspectRatioEnum.MainPageRecommendVideoRightchild.ratio,
            ),
            itemCount: controller.videos.length,
            itemBuilder: (context, index) {
              final video = controller.videos[index];
              return VideoInfoWidget(video: video);
            },
          ),

          // 加载更多指示器
          if (controller.loadingMore.value)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32.w),
              child: Center(child: CircularProgressIndicator()),
            ),

          // 没有更多数据提示
          if (!controller.loadingMore.value &&
              controller.pageNo > controller.pageTotal &&
              controller.videos.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 32.w),
              child: Center(
                child: Text(
                  '没有更多视频了',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
                ),
              ),
            ),
            SizedBox(height: 1.sh),
        ],
      ),
    );
  }
}

// 搜索头部的SliverPersistentHeaderDelegate
class _SearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final void Function(String) onSearchChanged;
  final RxString currentKeyword;

  _SearchHeaderDelegate({
    required this.onSearchChanged,
    required this.currentKeyword,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _SearchHeaderWidget(
      onSearchChanged: onSearchChanged,
      currentKeyword: currentKeyword,
    );
  }

  @override
  double get maxExtent => 80.0;

  @override
  double get minExtent => 80.0;

  @override
  bool shouldRebuild(covariant _SearchHeaderDelegate oldDelegate) =>
      currentKeyword != oldDelegate.currentKeyword;
}

// 搜索头部Widget
class _SearchHeaderWidget extends StatefulWidget {
  final void Function(String) onSearchChanged;
  final RxString currentKeyword;

  const _SearchHeaderWidget({
    required this.onSearchChanged,
    required this.currentKeyword,
  });

  @override
  State<_SearchHeaderWidget> createState() => _SearchHeaderWidgetState();
}

class _SearchHeaderWidgetState extends State<_SearchHeaderWidget> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.currentKeyword.value);

    // 监听外部keyword变化
    widget.currentKeyword.listen((keyword) {
      if (_textController.text != keyword) {
        _textController.text = keyword;
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.0,
      padding: EdgeInsets.symmetric(horizontal: 500.w, vertical: 12.w),
      child: Row(
        children: [
          // 搜索框
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.grey[200]!, width: 1),
              ),
              child: Row(
                children: [
                  // 搜索图标
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, right: 8.w),
                    child: Icon(
                      Icons.search,
                      size: 20.w,
                      color: Colors.grey[500],
                    ),
                  ),

                  // 搜索输入框
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: '搜索视频',
                        hintStyle: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[500],
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onSubmitted: widget.onSearchChanged,
                      onChanged: (value) {
                        setState(() {}); // 触发重建以显示/隐藏清除按钮
                      },
                    ),
                  ),

                  // 清除按钮
                  if (_textController.text.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: GestureDetector(
                        onTap: () {
                          _textController.clear();
                          setState(() {});
                        },
                        child: Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 12.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // 搜索按钮
          GestureDetector(
            onTap: () {
              final text = _textController.text.trim();
              if (text.isNotEmpty) {
                widget.onSearchChanged(text);
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '搜索',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
