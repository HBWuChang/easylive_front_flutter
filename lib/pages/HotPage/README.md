# HotPage 热门页面

## 概述
HotPage 是参考 MainPage 创建的热门推荐页面，主要特点：

1. **保留上方背景图片** - 与 MainPage 相同的背景图片和渐变遮罩效果
2. **确保默认滚动高度** - 与 MainPage 相同的滚动控制逻辑
3. **热门推荐内容** - 包含排行榜和热门视频列表

## 文件结构
```
lib/pages/HotPage/
├── HotPage.dart           # 主页面组件
└── HotPageTestWidget.dart # 测试导航组件
```

## 主要组件

### HotPage
主要的热门页面组件，包含：
- 顶部背景图片（复用 MainPage 的图片资源）
- 热门标题标签
- 排行榜筛选器（今日/本周/本月）
- 热门视频列表（占位数据）

### 组件层次结构
```
HotPage
├── CustomScrollView
    ├── SliverToBoxAdapter (背景图片)
    └── SliverList
        └── _HotVideoList
            ├── 筛选栏
            └── ListView.builder (视频列表)
                └── _HotVideoItem (单个视频项)
```

## 路由配置

### 1. 路由定义
在 `lib/settings.dart` 中添加了：
```dart
static const String hotPage = '/hot';
```

### 2. 路由配置
在 `lib/main.dart` 中添加了路由处理：
```dart
if (settings.name == Routes.hotPage) {
  var route = GetPageRoute(
      settings: settings,
      page: () => HotPage(),
      transition: Transition.fadeIn,
      middlewares: [appBarController.listenPopMiddleware]);
  appBarController.addAndCleanReapeatRoute(
      route, settings.name!,
      title: "热门推荐");
  return route;
}
```

## 使用方法

### 导航到热门页面
```dart
import 'package:get/get.dart';
import '../../settings.dart';

// 导航到热门页面
Get.toNamed(Routes.hotPage, id: Routes.mainGetId);
```

### 使用测试组件
```dart
import 'package:easylive/pages/HotPage/HotPageTestWidget.dart';

// 在任何页面中添加测试按钮
HotPageTestWidget()
```

## 占位数据
当前页面使用占位数据，包括：
- 20个模拟热门视频项目
- 随机生成的标题、作者、播放量等信息
- 使用 picsum.photos 提供的占位图片

## 功能特点

### 1. 滚动控制
- 继承 MainPage 的滚动控制逻辑
- 确保默认滚动位置在 kToolbarHeight
- 监听滚动事件，防止过度滚动
- **新增：滚动到底部自动加载更多** - 距离底部200像素时自动触发加载

### 2. 自动加载更多
- **防抖机制**：使用 `_isLoadingMore` 标志防止重复加载
- **智能触发**：距离底部200像素时开始加载
- **加载状态显示**：显示"加载更多中..."指示器
- **到底提示**：当所有数据加载完成时显示"已经到底了~"

### 3. 视觉设计
- 与 MainPage 保持一致的视觉风格
- 红色主题配色，突出"热门"概念
- 排名徽章设计（前三名红色，其他灰色）
- 卡片式布局，提升用户体验
- **加载状态指示器**：美观的加载动画和提示文字

### 4. 交互功能
- 筛选时间范围（今日/本周/本月）
- 视频项点击事件（当前为占位）
- 播放按钮交互
- 悬停效果
- **无限滚动**：自动加载更多热门视频
- **智能防抖**：避免重复请求API

## 滚动加载更多实现

### 核心逻辑
```dart
void _checkScrollToBottom() {
  if (!_isLoadingMore && 
      _scrollController.position.pixels >= 
      _scrollController.position.maxScrollExtent - 200) {
    _loadMoreVideos();
  }
}

Future<void> _loadMoreVideos() async {
  if (_isLoadingMore) return;
  
  _isLoadingMore = true;
  bool success = await hotPageController.loadMoreHotVideoList();
  _isLoadingMore = false;
}
```

### 特性
- **触发距离**：距离底部200像素时开始加载
- **防抖机制**：`_isLoadingMore` 标志防止重复加载
- **状态管理**：使用 HotPageController 管理分页和加载状态
- **用户体验**：显示加载指示器和到底提示

## 待实现功能

1. **数据集成**
   - 连接真实的热门视频API
   - 实现时间筛选逻辑
   - 添加数据刷新功能

2. **视频播放**
   - 集成视频播放器
   - 实现播放页面跳转

3. **用户交互**
   - 添加点赞、收藏功能
   - 用户头像点击跳转

4. **性能优化**
   - 图片懒加载
   - 列表虚拟化
   - 缓存机制

## 依赖
- flutter_screenutil: 屏幕适配
- extended_image: 图片加载和缓存
- get: 状态管理和路由
- 现有的控制器和API服务
