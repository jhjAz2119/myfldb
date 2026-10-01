import 'package:flutter/material.dart';
import 'api_service.dart';
import 'user_provider.dart';
import 'package:provider/provider.dart';
import 'widgets/common_widgets.dart'; // 统一组件

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _accountCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _doLogin() async {
    final account = _accountCtrl.text.trim();
    if (account.isEmpty || _pwdCtrl.text.isEmpty) {
      _msg("请输入账号和密码");
      return;
    }

    setState(() => _loading = true);
    try {
      final res = await ApiService.login(account, _pwdCtrl.text);
      if (res["code"] == 200 && mounted) {
        final user = context.read<UserProvider>();
        await user.saveProfile(res["data"]);
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        _msg(res["detail"] ?? "登录失败");
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
      title: "", // 登录页不要顶部标题
      showBackButton: false, // 不显示返回箭头
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),
            const Text(
              "用户登录",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            AppInput(
              label: "账号",
              hint: "请输入账号",
              controller: _accountCtrl,
            ),
            const SizedBox(height: 16),
            AppInput(
              label: "密码",
              hint: "请输入密码",
              controller: _pwdCtrl,
              obscureText: true,
              enabled: !_loading,
            ),
            const SizedBox(height: 24),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : AppButton(
                    text: "登录",
                    onTap: _doLogin,
                  ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, "/register"),
              child: const Text("没有账号？去注册"),
            ),
          ],
        ),
      ),
    );
  }
}
