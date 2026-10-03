import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/theme_config.dart';
import 'admin_main.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _accountCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _obscurePwd = true;
  bool _isLoading = false;
  String? _errorMsg;

  // ========== 固定管理员账号密码 ==========
  static const String _adminAccount = "admin";
  static const String _adminPassword = "admin123"; // 可自行修改

  Future<void> _doLogin() async {
    final account = _accountCtrl.text.trim();
    final pwd = _pwdCtrl.text;

    if (account.isEmpty || pwd.isEmpty) {
      setState(() => _errorMsg = "请输入账号和密码");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    await Future.delayed(const Duration(milliseconds: 600)); // 模拟验证延时

    if (account == _adminAccount && pwd == _adminPassword) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/my_admin',
        arguments: 'admin_authorized',
      );
    } else {
      setState(() {
        _errorMsg = "管理员账号或密码错误";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgEnd,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 8,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 标题
                    const Icon(Icons.admin_panel_settings_rounded,
                        size: 64, color: AppTheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      "管理后台登录",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "仅管理员可访问",
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 32),

                    // 错误提示
                    if (_errorMsg != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: Text(
                          _errorMsg!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // 账号输入
                    TextField(
                      controller: _accountCtrl,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: "管理员账号",
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        filled: true,
                        fillColor: AppTheme.cardBg,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 密码输入
                    TextField(
                      controller: _pwdCtrl,
                      obscureText: _obscurePwd,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        labelText: "管理员密码",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePwd
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppTheme.textHint,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePwd = !_obscurePwd),
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        filled: true,
                        fillColor: AppTheme.cardBg,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 登录按钮
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _doLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMd),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                "登 录",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600),
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
    );
  }
}
