import 'dart:io';
import 'package:flutter/foundation.dart';

class Config {
  static const String appName = "测试app";

  /// ✅ 新服务器：腾讯云公网地址
  static const String production = "http://42.194.129.247";

  static String get baseUrl {
    // 所有平台统一用新服务器
    return production;
  }

  /// 备用：本地调试（仅开发时用）
  static const String localUrl = "http://127.0.0.1:8000";
}
