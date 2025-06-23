// 虚假的 window_manager 库实现
// 用于在 web 平台上避免导入不兼容的库而产生编译错误

import 'dart:async';
import 'package:flutter/material.dart';

// 虚假的 WindowManager 类
class WindowManager {
  // 确保初始化方法
  Future<void> ensureInitialized() async {
    // 在 web 平台上什么都不做
  }

  // 等待窗口准备就绪
  Future<void> waitUntilReadyToShow(
    WindowOptions? windowOptions,
    VoidCallback? callback,
  ) async {
    // 在 web 平台上直接调用回调
    if (callback != null) {
      callback();
    }
  }

  // 显示窗口
  Future<void> show() async {
    // 在 web 平台上什么都不做
  }

  // 最大化窗口
  Future<void> maximize() async {
    // 在 web 平台上什么都不做
  }

  // 最小化窗口
  Future<void> minimize() async {
    // 在 web 平台上什么都不做
  }

  // 设置是否跳过任务栏
  Future<void> setSkipTaskbar(bool skipTaskbar) async {
    // 在 web 平台上什么都不做
  }

  // 隐藏窗口
  Future<void> hide() async {
    // 在 web 平台上什么都不做
  }

  // 关闭窗口
  Future<void> close() async {
    // 在 web 平台上什么都不做
  }

  // 设置窗口大小
  Future<void> setSize(Size size) async {
    // 在 web 平台上什么都不做
  }

  // 获取窗口大小
  Future<Size> getSize() async {
    return Size(1312, 800); // 返回默认大小
  }

  // 设置最小窗口大小
  Future<void> setMinimumSize(Size size) async {
    // 在 web 平台上什么都不做
  }

  // 设置窗口位置
  Future<void> setPosition(Offset position) async {
    // 在 web 平台上什么都不做
  }

  // 获取窗口位置
  Future<Offset> getPosition() async {
    return Offset.zero; // 返回默认位置
  }

  // 居中窗口
  Future<void> center() async {
    // 在 web 平台上什么都不做
  }

  // 设置窗口标题
  Future<void> setTitle(String title) async {
    // 在 web 平台上什么都不做
  }

  // 检查窗口是否可见
  Future<bool> isVisible() async {
    return true; // 在 web 平台上始终返回 true
  }

  // 检查窗口是否最大化
  Future<bool> isMaximized() async {
    return false; // 在 web 平台上始终返回 false
  }

  // 检查窗口是否最小化
  Future<bool> isMinimized() async {
    return false; // 在 web 平台上始终返回 false
  }
}

// 虚假的 WindowOptions 类
class WindowOptions {
  final Size? size;
  final Size? minimumSize;
  final Size? maximumSize;
  final bool? center;
  final Offset? position;
  final Color? backgroundColor;
  final bool? skipTaskbar;
  final TitleBarStyle? titleBarStyle;
  final bool? alwaysOnTop;
  final bool? fullScreen;
  final String? title;

  const WindowOptions({
    this.size,
    this.minimumSize,
    this.maximumSize,
    this.center,
    this.position,
    this.backgroundColor,
    this.skipTaskbar,
    this.titleBarStyle,
    this.alwaysOnTop,
    this.fullScreen,
    this.title,
  });
}

// 虚假的 TitleBarStyle 枚举
enum TitleBarStyle {
  normal,
  hidden,
}

// 虚假的全局 windowManager 实例
final WindowManager windowManager = WindowManager();

// 虚假的 DragToMoveArea 组件
class DragToMoveArea extends StatelessWidget {
  final Widget child;

  const DragToMoveArea({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 在 web 平台上直接返回子组件
    return child;
  }
}
