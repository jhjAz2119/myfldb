import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../user_provider.dart';
import '../utils/api_service.dart';
import '../widgets/common_widgets.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  final _oldPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();
  final _deletePwdCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPwdCtrl.dispose();
    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    _deletePwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    final user = context.read<UserProvider>();
    if (user.account == null) return;

    final oldPwd = _oldPwdCtrl.text.trim();
    final newPwd = _newPwdCtrl.text.trim();
    final confirmPwd = _confirmPwdCtrl.text.trim();

    if (oldPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
      _showMsg("请填写完整信息");
      return;
    }
    if (newPwd != confirmPwd) {
      _showMsg("两次输入的新密码不一致");
      return;
    }
    if (newPwd.length < 6) {
      _showMsg("新密码至少6位");
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.changePassword(
        account: user.account!,
        oldPassword: oldPwd,
        newPassword: newPwd,
      );

      if (res["success"] == true) {
        if (mounted) {
          _showMsg("密码修改成功！请重新登录");
          await _logoutAndBack();
        }
      } else {
        _showMsg(res["message"] ?? "密码修改失败");
      }
    } catch (e) {
      _showMsg("网络错误：$e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDeleteAccount() async {
    final user = context.read<UserProvider>();
    if (user.account == null) return;

    final pwd = _deletePwdCtrl.text.trim();
    if (pwd.isEmpty) {
      _showMsg("请输入当前密码");
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("⚠️ 确认注销"),
        content: const Text("注销后账号数据将无法恢复，确定要注销吗？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("确认注销"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.deleteAccount(
        account: user.account!,
        password: pwd,
      );

      if (res["success"] == true) {
        if (mounted) {
          _showMsg("账号已注销");
          await _logoutAndBack();
        }
      } else {
        _showMsg(res["message"] ?? "注销失败");
      }
    } catch (e) {
      _showMsg("网络错误：$e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logoutAndBack() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (mounted) {
      context.read<UserProvider>().account = null;
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _showMsg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "安全中心",
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "修改密码",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            AppInput(
              label: "当前密码",
              controller: _oldPwdCtrl,
              obscureText: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            AppInput(
              label: "新密码（至少6位）",
              controller: _newPwdCtrl,
              obscureText: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),
            AppInput(
              label: "确认新密码",
              controller: _confirmPwdCtrl,
              obscureText: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: "保存新密码",
              onTap: _isLoading ? () {} : _handleChangePassword,
            ),
            const SizedBox(height: 32),
            const Divider(height: 1),
            const SizedBox(height: 32),
            const Text(
              "注销账号",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "注销后您的所有信息将被删除，此操作不可恢复",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),
            AppInput(
              label: "请输入当前密码确认",
              controller: _deletePwdCtrl,
              obscureText: true,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: "确认注销我的账号",
              onTap: _isLoading ? () {} : _handleDeleteAccount,
              bgColor: Colors.red,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
