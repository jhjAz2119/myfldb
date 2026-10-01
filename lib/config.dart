import 'dart:io';
import 'package:flutter/foundation.dart';

class Config {
  static const String appName = "测试app";

  /// 接口基础地址 —— 全平台自动适配
  static String get baseUrl {
    // ✅ 线上部署地址（所有平台通用）
    const String production = "https://myfldb.onrender.com";

    // 网页端 → 直接用线上
    if (kIsWeb) {
      return production;
    }

    // Android 模拟器 → 优先线上
    if (Platform.isAndroid) {
      return production;
    }

    // iOS 模拟器 / 桌面端 → 优先线上
    if (Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isWindows ||
        Platform.isLinux) {
      return production;
    }

    // 其他情况 → 线上
    return production;
  }

  /// 备用：本地调试地址（仅电脑本机）
  static const String localUrl = "http://127.0.0.1:8000";

  /// 备用：手机真机直连（同一局域网时用）
  static const String phoneUrl = "http://172.20.10.2:8000";
}
