import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  // 统一解析响应格式
  static Map<String, dynamic> _parseRes(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) {
        return {
          "code": data["code"] ?? -1,
          "success": data["code"] == 200,
          "message": data["detail"] ?? data["msg"] ?? "",
          ...data,
        };
      }
      return {"code": -1, "success": false, "message": "数据格式错误"};
    } catch (e) {
      return {"code": -1, "success": false, "message": "解析失败：$e"};
    }
  }

  // 注册
  static Future<Map<String, dynamic>> register(
    String account,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"account": account, "password": password}),
      );
      return _parseRes(response);
    } catch (e) {
      return {"code": -1, "success": false, "message": "连接失败，请确认后端已启动"};
    }
  }

  // 登录
  static Future<Map<String, dynamic>> login(
    String account,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"account": account, "password": password}),
      );
      return _parseRes(response);
    } catch (e) {
      return {"code": -1, "success": false, "message": "连接失败，请确认后端已启动"};
    }
  }

  // 获取个人信息 —— 后端没有单独 /profile 接口，暂时保留兼容
  static Future<Map<String, dynamic>> getProfile(String account) async {
    try {
      final response = await http.get(
        Uri.parse("${Config.baseUrl}/profile?account=$account"),
      );
      return _parseRes(response);
    } catch (e) {
      return {"code": -1, "success": false, "message": "连接失败，请确认后端已启动"};
    }
  }

  // 修改个人信息 —— 匹配后端：POST /update_profile
  static Future<Map<String, dynamic>> updateProfile({
    required String account,
    String? nickname,
    String? gender,
    String? birthday,
    String? avatar,
  }) async {
    try {
      final body = <String, dynamic>{"account": account};
      if (nickname != null && nickname.isNotEmpty) body["nickname"] = nickname;
      if (gender != null) body["gender"] = gender;
      if (birthday != null && birthday.isNotEmpty) body["birthday"] = birthday;
      if (avatar != null && avatar.isNotEmpty) body["avatar"] = avatar;
      debugPrint('📤 发送数据: ${jsonEncode(body)}');

      final response = await http
          .post(
            Uri.parse("${Config.baseUrl}/update_profile"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('📥 响应状态: ${response.statusCode}');
      debugPrint('📥 响应内容: ${response.body}');
      return _parseRes(response);
    } catch (e) {
      debugPrint('❌ 请求异常: $e');
      return {"code": -1, "success": false, "message": "连接失败：$e"};
    }
  }

  // 修改密码 —— 匹配后端：POST /change_password
  static Future<Map<String, dynamic>> changePassword({
    required String account,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/change_password"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "account": account,
          "old_password": oldPassword,
          "new_password": newPassword,
        }),
      );
      return _parseRes(response);
    } catch (e) {
      return {"code": -1, "success": false, "message": "连接失败，请确认后端已启动"};
    }
  }

  // 注销账号 —— 匹配后端：POST /delete_account
  static Future<Map<String, dynamic>> deleteAccount({
    required String account,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/delete_account"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "account": account,
          "password": password,
        }),
      );
      return _parseRes(response);
    } catch (e) {
      return {"code": -1, "success": false, "message": "连接失败，请确认后端已启动"};
    }
  }
}
