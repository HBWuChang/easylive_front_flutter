import 'package:easylive/pages/MainPage/VideoInfoWidget.dart';
import 'package:easylive/settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/HotPageController.dart';
import '../../controllers/controllers-class.dart';
import '../../api_service.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../enums.dart';

class HotPage extends StatefulWidget {
  HotPage({Key? key}) : super(key: key);
  @override
  State<HotPage> createState() => _HotPageState();
}

class _HotPageState extends State<HotPage> {
  final AppBarController appBarController = Get.find<AppBarController>();
  late ScrollController _scrollController;
  late HotPageController hotPageController;
  bool _isLoadingMore = false; // 防止重复加载

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

    // 检测是否接近底部，加载更多内容
    _checkScrollToBottom();
  }

  void _checkScrollToBottom() {
    if (!_isLoadingMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      // 距离底部200像素时开始加载更多
      _loadMoreVideos();
    }
  }

  Future<void> _loadMoreVideos() async {
    if (_isLoadingMore) return;

    _isLoadingMore = true;
    bool success = await hotPageController.loadMoreHotVideoList();
    _isLoadingMore = false;

    // 如果加载成功且还有更多数据，可以考虑预加载下一页
    if (success && hotPageController.pageNo < hotPageController.pageTotal) {
      // 这里可以添加预加载逻辑，但目前保持简单
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    hotPageController = Get.put(HotPageController());
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
        // 顶部背景图片
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
        // 热门视频列表
        SliverList(
          delegate: SliverChildListDelegate([
            _HotVideoList(),
          ]),
        ),
      ],
    );
  }
}

// 热门视频列表组件
class _HotVideoList extends StatelessWidget {
  _HotVideoList({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HotPageController>(
      builder: (hotPageController) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 114.w),
          child: Column(
            children: [
              // 分类筛选栏
              Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    // 热门标题
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.red.shade400, Colors.red.shade600],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8.r,
                            spreadRadius: 2.r,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            '热门推荐',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 2,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Spacer(),
                  ],
                ),
              ),
              // 视频列表和加载更多指示器
              Obx(() => Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12.w,
                          crossAxisSpacing: 12.w,
                          childAspectRatio: AspectRatioEnum.HotPageVideo.ratio,
                        ),
                        itemCount: hotPageController.videos.length,
                        itemBuilder: (context, index) {
                          return VideoInfoWidgetHorizon(
                            video: hotPageController.videos[index],
                            big: true,
                          );
                        },
                      ),
                      // 加载更多指示器
                      if (hotPageController.loadingMore.value)
                        Container(
                          padding: EdgeInsets.all(20.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.red.shade500,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                '加载更多中...',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // 已经到底的提示
                      if (!hotPageController.loadingMore.value &&
                          hotPageController.pageNo >=
                              hotPageController.pageTotal &&
                          hotPageController.videos.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(20.w),
                          child: Text(
                            '已经到底了~',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                    ],
                  )),
            ],
          ),
        );
      },
    );
  }
}
