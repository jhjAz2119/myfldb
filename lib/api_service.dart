import 'dart:convert';
import 'package:http/http.dart' as http;
import 'config.dart';

class ApiService {
  static Future<Map<String, dynamic>> register(
    String account,
    String password,
  ) async {
    final url = Uri.parse("${Config.baseUrl}/register");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"account": account, "password": password}),
    );
    return _parseRes(res);
  }

  static Future<Map<String, dynamic>> login(
    String account,
    String password,
  ) async {
    final url = Uri.parse("${Config.baseUrl}/login");
    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"account": account, "password": password}),
    );
    return _parseRes(res);
  }

  static Future<Map<String, dynamic>> getProfile(String account) async {
    final url = Uri.parse("${Config.baseUrl}/profile?account=$account");
    final res = await http.get(url);
    return _parseRes(res);
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String account,
    String? nickname,
    String? gender,
    String? birthday,
    String? avatar,
  }) async {
    final url = Uri.parse("${Config.baseUrl}/profile");
    final body = <String, dynamic>{};
    if (nickname != null) body["nickname"] = nickname;
    if (gender != null) body["gender"] = gender;
    if (birthday != null) body["birthday"] = birthday;
    if (avatar != null) body["avatar"] = avatar;
    body["account"] = account;

    final res = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
    return _parseRes(res);
  }

  static Future<Map<String, dynamic>> changePassword({
    required String account,
    required String oldPassword,
    required String newPassword,
  }) async {
    final url = Uri.parse("${Config.baseUrl}/change-password");
    final res = await http.put(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "account": account,
        "old_password": oldPassword,
        "new_password": newPassword,
      }),
    );
    return _parseRes(res);
  }

  static Map<String, dynamic> _parseRes(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      return {
        "code": data["code"] ?? res.statusCode,
        "detail": data["detail"] ?? data["message"] ?? "请求完成",
        "data": data["data"],
      };
    } catch (e) {
      return {"code": -1, "detail": "数据解析失败：$e"};
    }
  }
}
