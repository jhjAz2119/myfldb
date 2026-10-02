//✅ 数据处理文件放在这里
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart';

class AdminDataService {
  // ===== 基础地址 =====
  static String get _baseUrl =>
      Config.baseUrl.endsWith('/') ? Config.baseUrl : '${Config.baseUrl}/';

  // ===== 通用响应解析 =====
  static Map<String, dynamic> _parseRes(http.Response res) {
    try {
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) {
        return {
          'code': data['code'] ?? -1,
          'success': data['code'] == 200,
          'message': data['detail'] ?? data['msg'] ?? '',
          ...data,
        };
      }
      return {'code': -1, 'success': false, 'message': '数据格式错误'};
    } catch (e) {
      return {'code': -1, 'success': false, 'message': '解析失败：$e'};
    }
  }

  // ===== 数据统计 =====
  static Future<Map<String, dynamic>> getStatistics() async {
    try {
      final uri = Uri.parse('${_baseUrl}admin/statistics');
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      return _parseRes(res);
    } catch (e) {
      return {'code': -1, 'success': false, 'message': '网络错误：$e'};
    }
  }

  // ===== 用户列表 =====
  static Future<Map<String, dynamic>> getUserList(
      {int page = 1, int limit = 20}) async {
    try {
      final uri = Uri.parse('${_baseUrl}admin/users?page=$page&limit=$limit');
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      return _parseRes(res);
    } catch (e) {
      return {'code': -1, 'success': false, 'message': '网络错误：$e'};
    }
  }

  // ===== 删除用户 =====
  static Future<Map<String, dynamic>> deleteUser(dynamic userId) async {
    try {
      final uri = Uri.parse('${_baseUrl}admin/users/$userId/delete');
      final res = await http.post(uri).timeout(const Duration(seconds: 15));
      return _parseRes(res);
    } catch (e) {
      return {'code': -1, 'success': false, 'message': '网络错误：$e'};
    }
  }

  // ===== 冻结/解冻用户 =====
  static Future<Map<String, dynamic>> toggleUserStatus(
      dynamic userId, bool freeze) async {
    try {
      final uri = Uri.parse('${_baseUrl}admin/users/$userId/status');
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'frozen': freeze}),
          )
          .timeout(const Duration(seconds: 15));
      return _parseRes(res);
    } catch (e) {
      return {'code': -1, 'success': false, 'message': '网络错误：$e'};
    }
  }

  // ===== 审核用户 =====
  static Future<Map<String, dynamic>> verifyUser(
      dynamic userId, bool pass, String? remark) async {
    try {
      final uri = Uri.parse('${_baseUrl}admin/users/$userId/verify');
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'pass': pass, 'remark': remark}),
          )
          .timeout(const Duration(seconds: 15));
      return _parseRes(res);
    } catch (e) {
      return {'code': -1, 'success': false, 'message': '网络错误：$e'};
    }
  }
}
