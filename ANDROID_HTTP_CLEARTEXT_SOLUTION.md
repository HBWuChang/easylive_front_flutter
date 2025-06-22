# Android HTTP 明文传输配置解决方案

## 问题描述
在 Android 9 (API level 28) 及以上版本中，系统默认禁止应用程序使用明文 HTTP 连接，以提高安全性。当应用尝试访问 HTTP URL 时，会抛出 `net::ERR_CLEARTEXT_NOT_PERMITTED` 错误。

## 解决方案概述
我们通过以下几个步骤来解决这个问题：

### 1. AndroidManifest.xml 配置

在 `android/app/src/main/AndroidManifest.xml` 中添加：

```xml
<application
    android:usesCleartextTraffic="true"
    android:networkSecurityConfig="@xml/network_security_config"
    ...>
```

**参数说明:**
- `android:usesCleartextTraffic="true"`: 允许应用使用明文 HTTP 连接
- `android:networkSecurityConfig`: 指向网络安全配置文件

### 2. 网络安全配置文件

创建 `android/app/src/main/res/xml/network_security_config.xml`：

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">127.0.0.1</domain>
        <domain includeSubdomains="true">localhost</domain>
        <domain includeSubdomains="true">10.0.2.2</domain>
        <!-- 添加您的开发服务器域名 -->
        <domain includeSubdomains="true">192.168.1.100</domain>
    </domain-config>
    
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system"/>
        </trust-anchors>
    </base-config>
</network-security-config>
```

**配置说明:**
- `domain-config`: 为特定域名配置明文传输权限
- `base-config`: 全局默认配置，保持安全性
- `cleartextTrafficPermitted="true"`: 允许指定域名使用明文传输

### 3. 网络权限

在 AndroidManifest.xml 中添加必要的网络权限：

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 4. Cronet 引擎优化配置

在 ApiService 中为 Android 平台配置了增强的 Cronet 引擎：

```dart
final engine = cronet.CronetEngine.build(
  cacheMode: cronet.CacheMode.memory,
  cacheMaxSize: 2 * 1024 * 1024, // 2MB cache
  userAgent: 'EasyLive-Android',
  enableQuic: true, // 启用 QUIC 协议
  enableHttp2: true, // 启用 HTTP/2
  enableBrotli: true, // 启用 Brotli 压缩
);
```

## 安全考虑

### 开发环境 vs 生产环境

**开发环境:**
- 允许本地服务器 (127.0.0.1, localhost) 使用 HTTP
- 允许模拟器网络 (10.0.2.2) 使用 HTTP
- 可以添加开发服务器的 IP 地址

**生产环境建议:**
1. 使用 HTTPS 而不是 HTTP
2. 移除 `android:usesCleartextTraffic="true"`
3. 在网络安全配置中只允许必要的域名
4. 使用证书绑定 (Certificate Pinning)

### 最佳实践

1. **仅在开发阶段允许明文传输**
2. **生产环境必须使用 HTTPS**
3. **限制允许明文传输的域名范围**
4. **定期审查网络安全配置**

## 常见域名配置

```xml
<!-- 本地开发 -->
<domain includeSubdomains="true">127.0.0.1</domain>
<domain includeSubdomains="true">localhost</domain>

<!-- Android 模拟器 -->
<domain includeSubdomains="true">10.0.2.2</domain>

<!-- 局域网开发服务器 -->
<domain includeSubdomains="true">192.168.1.100</domain>
<domain includeSubdomains="true">192.168.0.100</domain>

<!-- 开发/测试服务器 -->
<domain includeSubdomains="true">dev.example.com</domain>
<domain includeSubdomains="true">test.example.com</domain>
```

## 故障排除

### 如果问题仍然存在：

1. **清理并重建项目:**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk
   ```

2. **检查配置文件路径:**
   - 确保 `network_security_config.xml` 位于正确位置
   - 验证 AndroidManifest.xml 中的引用路径

3. **检查目标 SDK 版本:**
   - 确保 `compileSdkVersion` 和 `targetSdkVersion` 配置正确

4. **验证域名配置:**
   - 确保您的服务器域名/IP 已添加到配置中
   - 检查是否包含了所有需要的子域名

### 调试技巧

1. **使用 ADB 查看日志:**
   ```bash
   adb logcat | grep -i cronet
   ```

2. **检查网络连接:**
   ```bash
   adb shell ping your-server-ip
   ```

3. **验证配置加载:**
   - 在应用启动时检查网络安全配置是否正确加载

## 版本兼容性

- **Android 9 (API 28)+**: 默认禁止明文传输
- **Android 6-8 (API 23-27)**: 默认允许明文传输
- **Android 6 以下**: 不受此限制影响

## 相关链接

- [Android 网络安全配置官方文档](https://developer.android.com/training/articles/security-config)
- [Cronet 官方文档](https://chromium.googlesource.com/chromium/src/+/master/components/cronet/)
- [Flutter HTTP 安全最佳实践](https://flutter.dev/docs/development/data-and-backend/networking)
