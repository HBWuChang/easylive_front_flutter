import 'package:easylive/pages/MainPage/RecommendVideoArea.dart';
import 'package:easylive/settings.dart';
import 'package:easylive/widgets/CategoryButtonsWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/MainPageController.dart';
import '../../controllers/controllers-class.dart';
import '../../api_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainPage extends StatefulWidget {
  MainPage({Key? key}) : super(key: key);
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final AppBarController appBarController = Get.find<AppBarController>();
  final CategoryLoadAllCategoryController categoryLoadAllCategoryController =
      Get.find<CategoryLoadAllCategoryController>();
  final CategoryViewStateController categoryViewStateController =
      Get.put(CategoryViewStateController());
  late ScrollController _scrollController;

  void _minScrollListener() {
    if (_scrollController.offset < kToolbarHeight) {
      _scrollController.jumpTo(kToolbarHeight);
    }
    
    // 管理 AppBar 透明度状态
    final threshold = appBarController.imgHeight;
    if (_scrollController.offset >= threshold &&
        !appBarController.appBarOpaque.value) {
      appBarController.appBarOpaque.value = true;
    } else if (_scrollController.offset < threshold &&
        appBarController.appBarOpaque.value) {
      appBarController.appBarOpaque.value = false;
    }
    
    // 更新浮动分区栏显示状态
    final shouldShowFloating = _scrollController.offset > appBarController.imgHeight+100;
    if (appBarController.showFloatingCate.value != shouldShowFloating) {
      appBarController.showFloatingCate.value = shouldShowFloating;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_minScrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients &&
          _scrollController.offset < kToolbarHeight) {
        _scrollController.jumpTo(kToolbarHeight);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_minScrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      clipBehavior: Clip.none,
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            children: [
              SizedBox(
                height: appBarController.imgHeight.w,
                width: double.infinity,
                child: ExtendedImage.network(
                  Constants.baseUrl +
                      ApiAddr.fileGetResourcet +
                      ApiAddr.MainPageHeadImage,
                  fit: BoxFit.cover,
                  cache: true,
                  enableLoadState: true,
                  loadStateChanged: (state) {
                    if (state.extendedImageLoadState == LoadState.loading) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state.extendedImageLoadState ==
                        LoadState.completed) {
                      return null; // 图片加载完成
                    } else {
                      return Center(child: Text('加载失败'));
                    }
                  },
                ),
              ),
              // 渐变遮罩
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 原始分区栏（默认状态，显示所有分区）
        SliverToBoxAdapter(
          child: GetBuilder<CategoryLoadAllCategoryController>(
            init: categoryLoadAllCategoryController,
            builder: (_) {
              final categories = categoryLoadAllCategoryController.categories;
              return CategoryButtonsWidget(
                categories: categories,
                showAll: true,
                isFloating: false,
                onSelect: (String displayName) {
                  print('MainPage onSelect 被调用，displayName: $displayName');
                  // 跳转到CategoryPage，使用URL参数传递
                  if (displayName.contains('-')) {
                    // 二级分区：格式为 "一级分区名-二级分区名"
                    final firstDashIndex = displayName.indexOf('-');
                    if (firstDashIndex > 0 && firstDashIndex < displayName.length - 1) {
                      final pCategoryName = displayName.substring(0, firstDashIndex);
                      final categoryName = displayName.substring(firstDashIndex + 1);
                      print('跳转到二级分区: $pCategoryName - $categoryName');
                      // 需要找到对应的分区ID
                      final categories = categoryLoadAllCategoryController.categories;
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
                          final url = '${Routes.categoryPage}?pCategoryId=${parentCategory['categoryId']}&categoryId=${childCategory['categoryId']}';
                          print('跳转URL: $url');
                          Get.toNamed(url, id: Routes.mainGetId);
                        } else {
                          print('未找到子分区: $categoryName');
                        }
                      } else {
                        print('未找到父分区: $pCategoryName');
                      }
                    }
                  } else {
                    // 一级分区
                    print('跳转到一级分区: $displayName');
                    final categories = categoryLoadAllCategoryController.categories;
                    final category = categories.firstWhere(
                      (cat) => cat['categoryName'] == displayName,
                      orElse: () => <String, dynamic>{},
                    );
                    if (category.isNotEmpty) {
                      final url = '${Routes.categoryPage}?pCategoryId=${category['categoryId']}';
                      print('跳转URL: $url');
                      Get.toNamed(url, id: Routes.mainGetId);
                    }
                  }
                },
              );
            },
          ),
        ),
        // 浮动分区栏（滚动后在顶部显示）
        Obx(() {
          final showFloatingCate = appBarController.showFloatingCate.value;

          // 简化显示逻辑：当顶部栏变不透明时就显示浮动分区栏
          final shouldShowFloating = showFloatingCate;

          if (!shouldShowFloating) {
            return SliverToBoxAdapter(child: SizedBox.shrink());
          }

          return SliverPersistentHeader(
            pinned: true, // 固定在顶部，不随滚动移动
            delegate: FloatingCategoryHeaderDelegate(
              categories: categoryLoadAllCategoryController.categories,
              onSelect: (String displayName) {
                print('浮动分区栏 onSelect 被调用，displayName: $displayName');
                // 浮动分区栏同样跳转到CategoryPage，使用URL参数传递
                if (displayName.contains('-')) {
                  // 二级分区
                  final parts = displayName.split('-');
                  if (parts.length == 2) {
                    print('浮动分区栏跳转到二级分区: ${parts[0]} - ${parts[1]}');
                    // 需要找到对应的分区ID
                    final categories = categoryLoadAllCategoryController.categories;
                    final parentCategory = categories.firstWhere(
                      (cat) => cat['categoryName'] == parts[0],
                      orElse: () => <String, dynamic>{},
                    );
                    if (parentCategory.isNotEmpty) {
                      final children = List<Map<String, dynamic>>.from(parentCategory['children'] ?? []);
                      final childCategory = children.firstWhere(
                        (child) => child['categoryName'] == parts[1],
                        orElse: () => <String, dynamic>{},
                      );
                      if (childCategory.isNotEmpty) {
                        final url = '${Routes.categoryPage}?pCategoryId=${parentCategory['categoryId']}&categoryId=${childCategory['categoryId']}';
                        print('浮动分区栏跳转URL: $url');
                        Get.toNamed(url, id: Routes.mainGetId);
                      }
                    }
                  }
                } else {
                  // 一级分区
                  print('浮动分区栏跳转到一级分区: $displayName');
                  final categories = categoryLoadAllCategoryController.categories;
                  final category = categories.firstWhere(
                    (cat) => cat['categoryName'] == displayName,
                    orElse: () => <String, dynamic>{},
                  );
                  if (category.isNotEmpty) {
                    final url = '${Routes.categoryPage}?pCategoryId=${category['categoryId']}';
                    print('浮动分区栏跳转URL: $url');
                    Get.toNamed(url, id: Routes.mainGetId);
                  }
                }
              },
            ),
          );
        }),
        SliverList(
          delegate: SliverChildListDelegate([
            // 轮播推荐视频区
            RecommendVideoArea(),
          ]),
        ),
      ],
    );
  }
}
