import 'package:flutter/material.dart';
import 'api_service.dart';
import 'widgets/common_widgets.dart'; // 引入统一组件

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _accountCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _pwd2Ctrl = TextEditingController();
  bool _loading = false;

  Future<void> _doRegister() async {
    final account = _accountCtrl.text.trim();
    if (account.isEmpty || _pwdCtrl.text.isEmpty) {
      _msg("请填写完整信息");
      return;
    }
    if (_pwdCtrl.text != _pwd2Ctrl.text) {
      _msg("两次输入的密码不一致");
      return;
    }
    if (_pwdCtrl.text.length < 6) {
      _msg("密码长度至少6位");
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await ApiService.register(account, _pwdCtrl.text);
      if (res["code"] == 200 && mounted) {
        _msg("注册成功！请登录");
        Navigator.pop(context); // 返回登录页
      } else {
        _msg(res["detail"] ?? "注册失败");
      }
    } catch (e) {
      _msg("网络错误：$e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _msg(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "用户注册",
      showBackButton: true, // 显示返回箭头，可回登录页
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            const Text(
              "用户注册",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            AppInput(
              label: "账号",
              hint: "请输入账号",
              controller: _accountCtrl,
              enabled: !_loading,
            ),
            const SizedBox(height: 16),
            AppInput(
              label: "密码",
              hint: "至少6位",
              controller: _pwdCtrl,
              obscureText: true,
              enabled: !_loading,
            ),
            const SizedBox(height: 16),
            AppInput(
              label: "确认密码",
              hint: "请再次输入密码",
              controller: _pwd2Ctrl,
              obscureText: true,
              enabled: !_loading,
            ),
            const SizedBox(height: 24),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : AppButton(
                    text: "注册",
                    onTap: _doRegister,
                  ),
          ],
        ),
      ),
    );
  }
}
