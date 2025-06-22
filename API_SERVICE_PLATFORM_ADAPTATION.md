# ApiService 平台适配说明

## 概述

本次修改对 `ApiService` 类进行了重构，使其能够根据不同平台自动选择合适的 HTTP 客户端实现：

- **Windows、iOS、macOS、Linux**: 使用 `rhttp` (高性能的 Rust HTTP 客户端)
- **Android**: 使用 `cronet_http` (基于 Chromium 网络栈的 HTTP 客户端)
- **Web**: 使用 `fetch_client` (基于浏览器 Fetch API 的 HTTP 客户端)

## 主要修改

### 1. 平台检测与客户端初始化

```dart
static Future<void> init({String? baseUrl}) async {
  _baseUrl = baseUrl ?? 'http://127.0.0.1:7071';
  
  if (kIsWeb) {
    // Web平台使用 fetch_client
    _client = fetch.FetchClient(mode: fetch.RequestMode.cors);
  } else if (Platform.isAndroid) {
    // Android平台使用 cronet_http
    final engine = cronet.CronetEngine.build(
      cacheMode: cronet.CacheMode.memory,
      cacheMaxSize: 2 * 1024 * 1024, // 2MB cache
      userAgent: 'EasyLive-Android',
    );
    _client = cronet.CronetClient.fromCronetEngine(engine);
  } else {
    // Windows、iOS、macOS、Linux 使用 rhttp
    await rhttp.Rhttp.init();
    _client = await rhttp.RhttpClient.create(
      settings: baseUrl != null
          ? rhttp.ClientSettings(
              baseUrl: baseUrl,
              cookieSettings: rhttp.CookieSettings(storeCookies: true),
            )
          : const rhttp.ClientSettings(
              cookieSettings: rhttp.CookieSettings(storeCookies: true),
            ),
    );
  }
}
```

### 2. 统一的请求接口

#### GET 请求
- 自动检测客户端类型
- 统一的错误处理 (状态码 901 时打开登录对话框)
- 返回统一的 `Map<String, dynamic>` 格式

#### POST 请求
- 支持 JSON、表单、多部分数据上传
- 跨平台兼容的 multipart 处理
- 统一的请求头管理

#### GET Bytes 请求
- 用于文件下载和资源获取
- 返回 `Uint8List` 类型

### 3. 自定义 MultipartItem 类

为了在不同平台间保持一致的多部分数据接口，创建了 `CustomMultipartItem` 类：

```dart
class CustomMultipartItem {
  final Uint8List? bytes;
  final String? text;
  final String? fileName;

  // 静态工厂方法
  static CustomMultipartItem createBytes({required Uint8List bytes, String? fileName});
  static CustomMultipartItem createText({required String text});
  
  // 转换为 rhttp 的 MultipartItem
  rhttp.MultipartItem toRhttpMultipartItem();
}
```

### 4. 依赖管理

在 `pubspec.yaml` 中添加了必要的依赖：

```yaml
dependencies:
  rhttp: ^0.12.0          # Windows、iOS、macOS、Linux
  cronet_http: ^1.3.4     # Android
  fetch_client: ^1.1.4    # Web
  http: ^1.2.2            # 通用 HTTP 功能
```

## 使用方法

### 初始化
```dart
// 在 main() 函数中初始化
await ApiService.init(baseUrl: 'http://your-api-server.com');
```

### 发起请求
所有现有的 API 调用保持不变，因为底层实现已经自动适配：

```dart
// GET 请求
final response = await ApiService.accountLogin(
  email: 'user@example.com',
  password: 'password',
  checkCodeKey: 'key',
  checkCode: 'code',
);

// 文件上传
final result = await ApiService.fileUploadImage(
  file: imageBytes,
  createThumbnail: true,
);
```

## 平台优势

### Android (cronet_http)
- 基于 Chromium 网络栈，性能优秀
- 支持 HTTP/2、QUIC 协议
- 内置连接池和缓存管理
- 更好的网络异常处理

### Web (fetch_client)
- 使用浏览器原生 Fetch API
- 完全符合 Web 标准
- 自动处理 CORS
- 与浏览器网络栈完全集成

### Windows/Desktop (rhttp)
- 基于 Rust 的高性能实现
- 出色的内存管理
- 支持现代 HTTP 协议
- 跨平台一致性

## 向后兼容性

- 所有现有的 API 调用保持不变
- `toJson()` 方法继续支持旧的 `HttpTextResponse` 类型
- 现有的错误处理逻辑保持一致

## 注意事项

1. **初始化顺序**: 必须在使用任何 API 调用之前调用 `ApiService.init()`
2. **平台特定配置**: 
   - Android 需要在 `android/app/build.gradle` 中配置 minSdkVersion >= 21
   - Web 需要确保 CORS 配置正确
3. **错误处理**: 401 状态码会自动触发登录对话框
4. **性能优化**: 各平台客户端都启用了适当的缓存和连接池
