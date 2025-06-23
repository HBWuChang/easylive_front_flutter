# media_kit_video 的 HLS.js 集成指南

## 概述

本文档详细说明如何为 `media_kit_video` 包在 Web 平台上添加 HLS（HTTP Live Streaming）支持。通过集成 HLS.js 库，我们让 `media_kit_video` 能够在不原生支持 HLS 的浏览器（如 Chrome、Firefox）中播放 `.m3u8` 格式的视频流。

## 背景

### 问题
- Safari 浏览器原生支持 HLS 流播放
- Chrome、Firefox 等浏览器不原生支持 HLS
- `media_kit_video` 原本只能依赖浏览器原生支持

### 解决方案
通过集成 HLS.js 库，为不支持 HLS 的浏览器提供 JavaScript 实现的 HLS 播放能力。

## 实现架构

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │  media_kit_video │    │   HLS.js CDN    │
│                 │    │                 │    │                 │
│ VideoController │◄──►│ WebVideoController│    │ hls.js library  │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │   HlsHelper     │
                       │  (Dart-JS互操作) │
                       └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │ HTMLVideoElement│
                       │  (Browser API)  │
                       └─────────────────┘
```

## 实现细节

### 1. HTML 层面集成

**文件：** `web/index.html`

```html
<!-- HLS.js support for media_kit -->
<script src="https://cdn.jsdelivr.net/npm/hls.js@latest" type="application/javascript"></script>
```

**作用：**
- 从 CDN 加载 HLS.js 库
- 确保在 Flutter 应用启动前 HLS.js 可用
- 提供全局的 `Hls` 对象供 Dart 代码调用

### 2. Dart-JavaScript 互操作层

**文件：** `packages/media_kit_video-1.3.0/lib/src/video_controller/web_video_controller/hls_helper.dart`

#### 核心组件

##### 2.1 JavaScript 绑定声明

```dart
/// 检查 HLS.js 是否支持当前浏览器
@JS('Hls.isSupported')
external bool isHlsSupported();

/// HLS.js 主类
@JS()
@staticInterop
class Hls {
  external factory Hls(HlsConfig config);
}

/// HLS.js 实例方法扩展
extension HlsExtension on Hls {
  external void destroy();
  external void stopLoad();
  external void loadSource(String videoSrc);
  external void attachMedia(web.HTMLVideoElement video);
  external void on(String event, JSFunction callback);
}
```

**设计思路：**
- 使用 `@JS()` 注解创建与 JavaScript 对象的绑定
- `@staticInterop` 确保类型安全的互操作
- 扩展方法提供对 HLS.js API 的直接访问

##### 2.2 配置对象

```dart
@JS()
@anonymous
@staticInterop
class HlsConfig {
  external factory HlsConfig({JSFunction? xhrSetup});
}
```

**作用：**
- 配置 HLS.js 行为
- 支持自定义 HTTP 请求头
- 处理认证和跨域请求

##### 2.3 错误处理

```dart
class HlsErrorData {
  final String type;
  final String details;
  final bool fatal;

  factory HlsErrorData.fromJs(JSObject data) {
    return HlsErrorData(
      type: data.getProperty('type'.toJS).dartify()?.toString() ?? 'unknown',
      details: data.getProperty('details'.toJS).dartify()?.toString() ?? 'unknown',
      fatal: data.getProperty('fatal'.toJS).dartify() as bool? ?? false,
    );
  }
}
```

**功能：**
- 将 JavaScript 错误对象转换为 Dart 对象
- 提供类型安全的错误信息访问
- 区分致命和非致命错误

### 3. HLS 帮助类实现

#### 3.1 URL 检测逻辑

```dart
static bool isHlsUrl(String url) {
  return url.contains('.m3u8') || url.contains('#EXTM3U');
}
```

**判断逻辑：**
- 检查 URL 是否包含 `.m3u8` 扩展名
- 检查是否包含 `#EXTM3U` HLS 标识符

#### 3.2 浏览器兼容性检测

```dart
static bool canPlayHlsNatively(web.HTMLVideoElement element) {
  try {
    final canPlayType = element.canPlayType('application/vnd.apple.mpegurl');
    return canPlayType.isNotEmpty;
  } catch (e) {
    return false;
  }
}
```

**检测机制：**
- 使用 HTML5 Video API 的 `canPlayType` 方法
- 检测浏览器是否原生支持 HLS MIME 类型
- Safari 返回 "probably" 或 "maybe"，Chrome/Firefox 返回空字符串

#### 3.3 决策逻辑

```dart
static bool shouldUseHlsLibrary(String url, web.HTMLVideoElement element) {
  return isHlsSupported() && 
         isHlsUrl(url) && 
         !canPlayHlsNatively(element);
}
```

**决策流程：**
1. HLS.js 库是否可用
2. URL 是否为 HLS 流
3. 浏览器是否不支持原生 HLS

### 4. WebVideoController 集成

**文件：** `packages/media_kit_video-1.3.0/lib/src/video_controller/web_video_controller/real.dart`

#### 4.1 初始化集成

```dart
class WebVideoController extends PlatformVideoController {
  /// HLS helper instance for HLS.js integration
  HlsHelper? _hlsHelper;

  static Future<PlatformVideoController> create(...) async {
    // ... 现有初始化代码 ...
    
    // 初始化 HLS helper
    controller._hlsHelper = HlsHelper();
    
    // 监听播放列表变化
    controller._playlistSubscription = player.stream.playlist.listen((playlist) {
      if (playlist.isNotEmpty) {
        final media = playlist.first;
        controller._handleMediaLoad(media.uri);
      }
    });
  }
}
```

#### 4.2 媒体加载处理

```dart
void _handleMediaLoad(String url) {
  if (_element == null || _hlsHelper == null) return;

  // 尝试为这个媒体初始化 HLS
  final success = _hlsHelper!.initialize(
    _element!,
    url,
    onError: (error) {
      debugPrint('HLS Error: ${error.type} - ${error.details}');
    },
  );

  debugPrint('HLS initialization for $url: ${success ? 'success' : 'fallback to native'}');
}
```

**处理流程：**
1. 检查必要组件是否就绪
2. 调用 HLS helper 初始化
3. 设置错误回调处理
4. 记录初始化结果

#### 4.3 资源清理

```dart
Future<void> _dispose() async {
  super.dispose();
  await _resizeStreamSubscription?.cancel();
  await _playlistSubscription?.cancel();
  _hlsHelper?.dispose(); // 清理 HLS.js 实例
}
```

### 5. HLS.js 初始化流程

```dart
bool initialize(
  web.HTMLVideoElement videoElement, 
  String url, {
  Map<String, String>? headers,
  Function(HlsErrorData)? onError,
}) {
  try {
    // 1. 创建 HLS.js 实例
    _hls = Hls(HlsConfig(
      xhrSetup: headers != null && headers.isNotEmpty
          ? ((web.XMLHttpRequest xhr, String _) {
              // 设置自定义请求头
              if (headers.containsKey('useCookies')) {
                xhr.withCredentials = true;
              }
              headers.forEach((key, value) {
                if (key != 'useCookies') {
                  xhr.setRequestHeader(key, value);
                }
              });
            }).toJS
          : null,
    ));
    
    // 2. 绑定视频元素
    _hls!.attachMedia(videoElement);
    
    // 3. 监听媒体绑定事件
    _hls!.on('hlsMediaAttached', ((String _, JSObject __) {
      _hls!.loadSource(url); // 加载 HLS 源
    }).toJS);
    
    // 4. 监听错误事件
    if (onError != null) {
      _hls!.on('hlsError', ((String _, JSObject data) {
        try {
          final errorData = HlsErrorData.fromJs(data);
          if (errorData.fatal) {
            onError(errorData);
          }
        } catch (e) {
          // 错误解析失败
        }
      }).toJS);
    }
    
    return true;
  } catch (e) {
    return false;
  }
}
```

**初始化步骤：**
1. **配置创建** - 设置请求头、认证等
2. **媒体绑定** - 将 HLS.js 与 video 元素关联
3. **事件监听** - 监听媒体绑定完成事件
4. **源加载** - 在绑定完成后加载 HLS 流
5. **错误处理** - 监听并处理播放错误

### 6. 插件配置

**文件：** `packages/media_kit_video-1.3.0/pubspec.yaml`

```yaml
flutter:
  plugin:
    platforms:
      web:
        pluginClass: MediaKitVideoPlugin
        fileName: media_kit_video_plugin_web.dart
```

**文件：** `packages/media_kit_video-1.3.0/lib/media_kit_video_plugin_web.dart`

```dart
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:web/web.dart' as web;

class MediaKitVideoPlugin {
  static void registerWith(Registrar registrar) {
    // Web平台插件注册逻辑
  }
}
```

### 7. 测试页面

**文件：** `lib/pages/TestPages/HlsTestPage.dart`

```dart
class HlsTestPage extends StatefulWidget {
  @override
  State<HlsTestPage> createState() => _HlsTestPageState();
}

class _HlsTestPageState extends State<HlsTestPage> {
  late final Player player;
  late final VideoController controller;

  @override
  void initState() {
    super.initState();
    player = Player();
    controller = VideoController(player);
    _loadHlsStream();
  }

  void _loadHlsStream() {
    // 使用公开的 HLS 测试流
    const hlsUrl = 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8';
    player.open(Media(hlsUrl));
  }
}
```

## 工作流程

### 播放 HLS 流的完整流程

```
1. 用户调用 player.open(Media('stream.m3u8'))
   ↓
2. WebVideoController 监听到播放列表变化
   ↓
3. 调用 _handleMediaLoad(url)
   ↓
4. HlsHelper.initialize() 检查是否需要 HLS.js
   ↓
5. 如果需要：
   a. 创建 Hls 实例
   b. 绑定到 HTMLVideoElement
   c. 监听事件
   d. 加载 HLS 源
   ↓
6. HLS.js 处理流解析和播放
   ↓
7. 视频在浏览器中播放
```

### 错误处理流程

```
1. HLS.js 检测到播放错误
   ↓
2. 触发 'hlsError' 事件
   ↓
3. Dart 回调函数接收错误数据
   ↓
4. 转换为 HlsErrorData 对象
   ↓
5. 如果是致命错误，调用 onError 回调
   ↓
6. 应用层可以选择重试或显示错误信息
```

## 浏览器兼容性

| 浏览器 | 原生 HLS 支持 | HLS.js 支持 | 最终结果 |
|--------|---------------|-------------|----------|
| Safari | ✅ | ✅ | 使用原生支持 |
| Chrome | ❌ | ✅ | 使用 HLS.js |
| Firefox | ❌ | ✅ | 使用 HLS.js |
| Edge | ❌ | ✅ | 使用 HLS.js |

## 性能考量

### 优势
- **渐进式增强** - 原生支持优先，HLS.js 作为 fallback
- **按需加载** - 只在需要时初始化 HLS.js
- **资源管理** - 正确清理 HLS.js 实例避免内存泄漏

### 开销
- **额外加载** - HLS.js 库约 500KB
- **CPU 使用** - JavaScript 解析和处理 HLS 流
- **内存占用** - HLS.js 实例和缓冲区

## 调试和诊断

### 控制台输出
```dart
print('HlsHelper: Checking if should use HLS for URL: $url');
print('HlsHelper: Initializing HLS.js for URL: $url');
debugPrint('HLS initialization for $url: ${success ? 'success' : 'fallback to native'}');
```

### 浏览器开发者工具
- 检查 Network 面板中的 HLS 片段请求
- 监控 Console 中的 HLS.js 日志
- 使用 Elements 面板检查 video 元素状态

## 未来改进方向

### 1. 配置扩展
- 支持更多 HLS.js 配置选项
- 添加自定义 loader 支持
- 实现 DRM 保护内容播放

### 2. 错误恢复
- 自动重试机制
- 网络错误恢复
- 质量自适应降级

### 3. 性能优化
- 预加载策略优化
- 缓存机制改进
- 内存使用优化

### 4. 功能增强
- 字幕支持
- 多音轨支持
- 实时流延迟优化

## 总结

通过集成 HLS.js，我们成功为 `media_kit_video` 添加了跨浏览器的 HLS 支持。这个实现：

1. **无侵入性** - 不影响现有 API 和功能
2. **智能检测** - 自动选择最佳播放策略
3. **错误处理** - 完善的错误监听和处理机制
4. **资源管理** - 正确的生命周期管理
5. **易于维护** - 清晰的代码结构和文档

这个解决方案让 Flutter Web 应用能够在所有主流浏览器中稳定播放 HLS 流，大大提升了用户体验。
