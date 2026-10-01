import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String? account;
  String? nickname;
  String? avatar;
  String? gender;
  String? birthday;
  String? userId;

  bool get isLoggedIn => account != null;

  void update() {
    notifyListeners();
  }

  void setUserInfo({
    String? account,
    String? nickname,
    dynamic avatar,
    dynamic gender,
    dynamic birthday,
    dynamic userId,
  }) {
    if (account != null) this.account = account;
    if (nickname != null) this.nickname = nickname;
    this.avatar = avatar?.toString();
    this.gender = gender?.toString() ?? "未设置";
    this.birthday = birthday?.toString();
    this.userId = userId?.toString();
    notifyListeners();
  }

  UserProvider() {
    loadFromPrefs();
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    account = prefs.getString("account");
    nickname = prefs.getString("nickname") ?? account;
    avatar = prefs.getString("avatar");
    gender = prefs.getString("gender") ?? "未设置";
    birthday = prefs.getString("birthday");
    userId = prefs.getString("user_id");
    notifyListeners();
  }

  Future<void> saveProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();

    // 先更新内存状态
    setUserInfo(
      account: data["account"],
      nickname: data["nickname"],
      avatar: data["avatar"],
      gender: data["gender"],
      birthday: data["birthday"],
      userId: data["user_id"] ?? data["id"],
    );

    // ✅ 确保先更新变量再保存，避免空值
    if (account != null) await prefs.setString("account", account!);
    if (nickname != null) await prefs.setString("nickname", nickname!);
    if (avatar != null) await prefs.setString("avatar", avatar!);
    if (gender != null) await prefs.setString("gender", gender!);
    if (birthday != null && birthday!.isNotEmpty) {
      await prefs.setString("birthday", birthday!);
    }
    if (userId != null) await prefs.setString("user_id", userId!);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('account');
    await prefs.remove('nickname');
    await prefs.remove('avatar');
    await prefs.remove('gender');
    await prefs.remove('birthday');
    await prefs.remove('user_id');

    account = null;
    nickname = null;
    avatar = null;
    gender = null;
    birthday = null;
    userId = null;

    notifyListeners();
  }
}
