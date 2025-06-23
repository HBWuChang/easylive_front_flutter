# 平台特定库调试解决方案

## 问题描述
在不同平台调试 Flutter 应用时，导入不兼容的平台特定库（如在 Web 调试时导入 `cronet_http` 或 `window_manager`）会导致编译错误，无法进行调试。

## 解决方案
创建了"虚假的平台库"来解决这个问题：

### 虚假库文件
1. **fake_cronet_http.dart** - 虚假的 cronet_http 库，用于非 Android 平台
2. **fake_rhttp.dart** - 虚假的 rhttp 库，用于非 Desktop 平台  
3. **fake_fetch_client.dart** - 虚假的 fetch_client 库，用于非 Web 平台
4. **fake_window_manager.dart** - 虚假的 window_manager 库，用于非 Desktop 平台

### 条件导入策略

#### API Service 条件导入
在 `api_service.dart` 中使用条件导入：

```dart
// Web 平台使用 fetch_client，其他平台使用虚假的 fetch_client
import 'package:fetch_client/fetch_client.dart' as fetch
    if (dart.library.io) 'fake_fetch_client.dart';

// Android 平台使用 cronet_http，其他平台使用虚假的 cronet_http  
import 'package:cronet_http/cronet_http.dart' as cronet
    if (dart.library.html) 'fake_cronet_http.dart';

// Desktop 平台使用 rhttp，Web 平台使用虚假的 rhttp
import 'package:rhttp/rhttp.dart' as rhttp
    if (dart.library.html) 'fake_rhttp.dart';
```

#### Window Manager 条件导入
在 `main.dart` 和 `Appbar.dart` 中使用条件导入：

```dart
// Desktop 平台使用真实的 window_manager，Web 平台使用虚假的 window_manager
import 'fake_window_manager.dart' if (dart.library.io) 'package:window_manager/window_manager.dart';
```

### 工作原理
- **Web 平台调试**: 使用真实的 `fetch_client`，虚假的 `cronet_http`、`rhttp` 和 `window_manager`
- **Android 平台调试**: 使用真实的 `cronet_http` 和 `window_manager`，虚假的 `fetch_client` 和 `rhttp`
- **Desktop 平台调试**: 使用真实的 `rhttp` 和 `window_manager`，虚假的 `cronet_http` 和 `fetch_client`

### 虚假库特性
1. **完全兼容的 API**: 虚假库提供与真实库相同的类和方法签名
2. **运行时回退**: 虚假的 `CronetClient` 和 `FetchClient` 实现了 `http.Client` 接口，在非目标平台上会回退到标准 HTTP 客户端
3. **编译时安全**: 确保所有平台都能正常编译，不会出现导入错误
4. **无操作实现**: 虚假的 `window_manager` 在 Web 平台上不执行任何窗口操作，避免不支持的 API 调用

### 实现文件
#### 已修改的文件
1. **api_service.dart** - 使用条件导入替换所有平台特定的 HTTP 库
2. **main.dart** - 使用条件导入替换 window_manager
3. **Appbar.dart** - 使用条件导入替换 window_manager

#### 新创建的虚假库
1. **fake_cronet_http.dart** - 提供兼容 cronet_http 的虚假实现
2. **fake_rhttp.dart** - 提供兼容 rhttp 的虚假实现  
3. **fake_fetch_client.dart** - 提供兼容 fetch_client 的虚假实现
4. **fake_window_manager.dart** - 提供兼容 window_manager 的虚假实现

### 使用方法
1. 将虚假库文件放在 `lib` 目录下
2. 修改相关文件使用条件导入
3. 正常在各平台进行调试，不会再出现库导入错误

### 注意事项
- 虚假库只在调试时发挥作用，不影响生产环境的性能
- 在目标平台上仍然使用最优化的真实库
- 代码逻辑保持不变，只是解决了编译时的导入问题
- GetPlatform.isWindows 等平台判断在所有平台上都是安全的，不会在 Web 平台调用不支持的 window_manager 功能
