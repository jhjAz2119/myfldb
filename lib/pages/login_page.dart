import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../utils/api_service.dart';
import '../user_provider.dart';
import '../theme/theme_config.dart';
import '../widgets/common_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _accountCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _rememberAccount = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAccount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSavedAccount();
  }

  @override
  void dispose() {
    _accountCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSavedAccount() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAccount = prefs.getString('saved_account') ?? '';
    if (mounted) {
      setState(() {
        _accountCtrl.text = savedAccount;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (_accountCtrl.text.isEmpty || _pwdCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请输入账号和密码")),
      );
      return;
    }

    final result = await ApiService.login(
      _accountCtrl.text.trim(),
      _pwdCtrl.text.trim(),
    );

    if (!mounted) return;

    if (result['code'] == 200 && mounted) {
      final user = context.read<UserProvider>();

      // ✅ 用 setUserInfo 替代逐个赋值 + notifyListeners
      user.setUserInfo(
        account: result['account'] as String?,
        nickname: result['nickname'] as String?,
        avatar: result['avatar'],
        gender: result['gender'],
        birthday: result['birthday'],
        userId: result['user_id'],
      );

      // ✅ 保存到本地
      final prefs = await SharedPreferences.getInstance();
      if (_rememberAccount) {
        await prefs.setString('saved_account', _accountCtrl.text.trim());
      } else {
        await prefs.remove('saved_account');
      }
      await prefs.setString('account', user.account ?? '');
      await prefs.setString('nickname', user.nickname ?? '');
      await prefs.setString('gender', user.gender ?? "未设置");
      if (user.userId != null) await prefs.setString('user_id', user.userId!);

      // ✅ 提示 + 跳转
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? result['msg'] ?? '登录成功')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? result['msg'] ?? '登录失败')),
      );
    }
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
                color: AppTheme.focus.withValues(alpha: 0.05),
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
              constraints: const BoxConstraints(maxWidth: maxWidth),
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
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: AppTheme.focus,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text("用户登录", style: AppTheme.title),
                        const SizedBox(height: 6),
                        Text(
                          "欢迎回来，请登录您的账号",
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
                        const SizedBox(height: 36),
                        TextField(
                          controller: _accountCtrl,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: "请输入账号",
                            hintStyle:
                                const TextStyle(color: AppTheme.textHint),
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
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _handleLogin(),
                          decoration: InputDecoration(
                            hintText: "请输入密码",
                            hintStyle:
                                const TextStyle(color: AppTheme.textHint),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberAccount,
                                  onChanged: (val) {
                                    setState(
                                      () => _rememberAccount = val ?? true,
                                    );
                                  },
                                  activeColor: AppTheme.focus,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                const Text("记住账号", style: AppTheme.label),
                              ],
                            ),
                            Text(
                              "忘记密码？",
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.buttonBg,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusMd),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "登 录",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
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
                              child: Text(
                                "还没有账号",
                                style: TextStyle(
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
                            Navigator.pushNamed(context, '/register');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(120, 40),
                          ),
                          child: Text(
                            "立即注册",
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
