import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_service.dart';
import '../theme/theme_config.dart';
import '../widgets/common_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _accountCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _doRegister() async {
    String account = _accountCtrl.text.trim();
    String pwd = _pwdCtrl.text.trim();
    String confirmPwd = _confirmPwdCtrl.text.trim();

    if (account.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请输入账号")),
      );
      return;
    }
    if (pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请输入密码")),
      );
      return;
    }
    if (pwd != confirmPwd) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("两次密码不一致")),
      );
      return;
    }
    if (pwd.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("密码长度至少6位")),
      );
      return;
    }

    setState(() => _loading = true);
    final result = await ApiService.register(account, pwd);

    if (!mounted) return;

    if (result['code'] == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_account', account);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("注册成功！请登录")),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['msg'] ?? '注册失败')),
      );
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    const aspectRatio = kIsWeb ? 9 / 16 : 9 / 20;
    const maxWidth = kIsWeb ? 420.0 : double.infinity;

    return PageBackground(
      child: Stack(
        children: [
          Positioned(
            top: -60,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: AppTheme.focus.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: Container(
              margin: kIsWeb ? const EdgeInsets.all(20) : EdgeInsets.zero,
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: AppCard(
                  decoration: kIsWeb
                      ? BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusLg),
                          border: Border.all(
                            color: AppTheme.border.withValues(alpha: 0.4),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.focus.withValues(alpha: 0.06),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        )
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: AppTheme.focus.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.person_add_alt_rounded,
                            color: AppTheme.focus,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text("用户注册", style: AppTheme.title),
                        const SizedBox(height: 6),
                        Text(
                          "创建您的新账号",
                          style: TextStyle(
                            fontSize: 13,
                            color:
                                AppTheme.textSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 40,
                          height: 3,
                          decoration: BoxDecoration(
                            color: AppTheme.focus.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextField(
                          controller: _accountCtrl,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: "请设置账号",
                            hintStyle: TextStyle(color: AppTheme.textHint),
                            prefixIcon: Icon(
                              Icons.account_circle_outlined,
                              color:
                                  AppTheme.textSecondary.withValues(alpha: 0.6),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFFAFCFB),
                            border: _inputBorder(AppTheme.border),
                            enabledBorder: _inputBorder(AppTheme.border),
                            focusedBorder:
                                _inputBorder(AppTheme.focus, width: 1.5),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _pwdCtrl,
                          obscureText: true,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: "请设置密码",
                            hintStyle: TextStyle(color: AppTheme.textHint),
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color:
                                  AppTheme.textSecondary.withValues(alpha: 0.6),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFFAFCFB),
                            border: _inputBorder(AppTheme.border),
                            enabledBorder: _inputBorder(AppTheme.border),
                            focusedBorder:
                                _inputBorder(AppTheme.focus, width: 1.5),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirmPwdCtrl,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _doRegister(),
                          decoration: InputDecoration(
                            hintText: "请再次输入密码",
                            hintStyle: TextStyle(color: AppTheme.textHint),
                            prefixIcon: Icon(
                              Icons.lock_outline_rounded,
                              color:
                                  AppTheme.textSecondary.withValues(alpha: 0.6),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFFAFCFB),
                            border: _inputBorder(AppTheme.border),
                            enabledBorder: _inputBorder(AppTheme.border),
                            focusedBorder:
                                _inputBorder(AppTheme.focus, width: 1.5),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _doRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.buttonBg,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusMd),
                              ),
                            ),
                            child: _loading
                                ? const CircularProgressIndicator(
                                    color: Colors.white)
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "注 册",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 2,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(Icons.how_to_reg_rounded, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppTheme.border.withValues(alpha: 0.3),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: const Text(
                                // ← 这里也加上 const
                                "已有账号",
                                style: TextStyle(
                                  // ← TextStyle 前面可以不加了，Text 加了就够
                                  fontSize: 12,
                                  color: AppTheme.textHint,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppTheme.border.withValues(alpha: 0.3),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(120, 40),
                          ),
                          child: Text(
                            "立即登录",
                            style: TextStyle(
                              color: AppTheme.focus,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor:
                                  AppTheme.focus.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
