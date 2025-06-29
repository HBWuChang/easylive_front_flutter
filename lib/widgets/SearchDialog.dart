import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/SearchController.dart' as AppSearchController;

class SearchDialog extends StatefulWidget {
  const SearchDialog({Key? key}) : super(key: key);

  @override
  State<SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  late TextEditingController _textController;
  late AppSearchController.SearchController searchController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    searchController = Get.put(AppSearchController.SearchController());
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 600.w,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '搜索',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close, size: 20.w),
                ),
              ],
            ),
            
            SizedBox(height: 16.h),
            
            // 搜索框
            TextField(
              controller: _textController,
              autofocus: true,
              enableInteractiveSelection: true, // 启用交互选择
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: '请输入搜索关键词',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 清除按钮
                    if (_textController.text.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _textController.clear();
                          });
                        },
                        icon: Icon(Icons.clear, size: 18.w),
                      ),
                    // 搜索按钮
                    IconButton(
                      onPressed: () => _performSearch(),
                      icon: Icon(Icons.search, size: 20.w),
                    ),
                  ],
                ),
              ),
              onChanged: (value) {
                setState(() {}); // 触发重建以显示/隐藏清除按钮
              },
              onSubmitted: (value) => _performSearch(),
            ),
            
            SizedBox(height: 24.h),
            
            // 热门搜索标题
            Text(
              '热门搜索',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // 热门搜索关键词
            Obx(() {
              if (searchController.isLoading.value) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              
              if (searchController.hotKeywords.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Center(
                    child: Text(
                      '暂无热门搜索',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                );
              }
              
              return Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: searchController.hotKeywords.map((keyword) {
                  return GestureDetector(
                    onTap: () => _selectKeyword(keyword),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        keyword,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            }),
            
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  void _performSearch() {
    final keyword = _textController.text.trim();
    if (keyword.isNotEmpty) {
      searchController.search(keyword);
      Get.back();
    }
  }

  void _selectKeyword(String keyword) {
    _textController.text = keyword;
    _performSearch();
  }
}
