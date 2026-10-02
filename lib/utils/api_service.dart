import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import '../config.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  // ✅ 新增：公开方法，外部文件调用这个
  static Map<String, dynamic> parseResponse(http.Response res) {
    return _parseRes(res);
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

  // 获取个人信息
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

  // 修改个人信息
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

  // 修改密码
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

  // 获取版本信息
  static Future<Map<String, dynamic>> getVersionInfo() async {
    try {
      final res = await http.get(
        Uri.parse("${Config.baseUrl}/version-info"),
        headers: {"Content-Type": "application/json"},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return {
          "success": true,
          "data": data,
          "message": "获取成功",
        };
      }
      return {
        "success": false,
        "message": "服务器异常",
      };
    } catch (e) {
      return {
        "success": false,
        "message": "连接失败",
      };
    }
  }

  // ✅ 上传头像 — 彻底修复：Web只用字节，手机用路径
  static Future<Map<String, dynamic>> uploadAvatar(
    String account,
    String imagePath,
  ) async {
    debugPrint('🔹 开始上传，account = [$account]');
    if (account.isEmpty) {
      return {"code": -1, "msg": "账号不能为空，请重新登录"};
    }
    try {
      // ✅ 强制带上 ?account= 参数，兼容 Render 旧版后端
      final base = Config.baseUrl.endsWith('/')
          ? Config.baseUrl.substring(0, Config.baseUrl.length - 1)
          : Config.baseUrl;
      final uri = Uri.parse(
          '$base/upload-avatar?account=${Uri.encodeComponent(account)}');
      debugPrint('🔹 最终请求地址 = $uri');
      final request = http.MultipartRequest("POST", uri);
      // ✅ form-data 也带上，兼容新版后端
      request.fields["account"] = account;
      if (kIsWeb) {
        final XFile file = XFile(imagePath);
        final bytes = await file.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            "file",
            bytes,
            filename: "avatar_${DateTime.now().millisecondsSinceEpoch}.jpg",
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath("file", imagePath),
        );
      }
      final res = await request.send().timeout(const Duration(seconds: 240));
      final body = await res.stream.bytesToString();
      debugPrint('🔹 响应 = $body');

      final Map<String, dynamic> data = jsonDecode(body);

      // ✅ 新增：上传成功 → 保存头像地址
      if (data['code'] == 200 && data['avatarUrl'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('avatar_url', data['avatarUrl']);
        debugPrint('✅ 头像地址已保存：${data['avatarUrl']}');
      }

      return data;
    } on TimeoutException {
      return {"code": -1, "msg": "请求超时"};
    } catch (e) {
      return {"code": -1, "msg": "上传失败：$e"};
    }
  }

  // 注销账号
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
