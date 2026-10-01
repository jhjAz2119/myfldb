import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../user_provider.dart';
import '../../theme/theme_config.dart';
import '../security_page.dart';

class HomeTabProfile extends StatefulWidget {
  const HomeTabProfile({super.key});

  @override
  State<HomeTabProfile> createState() => _HomeTabProfileState();
}

class _HomeTabProfileState extends State<HomeTabProfile> {
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("确认退出"),
        content: const Text("确定要退出登录吗？"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("取消"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("确定"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!mounted) return;
      await context.read<UserProvider>().logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    UserProvider? user;
    try {
      user = context.watch<UserProvider>();
    } catch (e) {
      debugPrint('获取用户信息失败: $e');
    }

    if (user == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("加载中..."),
          ],
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          children: [
            // 头像
            GestureDetector(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.focus.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.focus,
                    ),
                  ),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.focus,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 昵称 + ID
            Text(
              user.nickname ?? user.account ?? "用户",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "ID: ${user.userId ?? '暂无'}",
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 28),

            // 分割线
            Container(
              width: 40,
              height: 3,
              decoration: BoxDecoration(
                color: AppTheme.focus.withOpacity(0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),

            // 账号信息入口
            _buildMenuItem(
              Icons.person_outline,
              "账号信息",
              () => Navigator.pushNamed(context, '/account_info'),
            ),
            const SizedBox(height: 8),

            // 安全中心入口
            _buildMenuItem(
              Icons.security,
              "安全中心",
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SecurityPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),

            // 退出登录
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                onPressed: _logout,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "退出登录",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.logout_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFCFB),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Material(
        // 关键：用 Material 包裹，提供可靠的渲染层
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: AppTheme.focus, size: 20),
          title: Text(title, style: const TextStyle(fontSize: 15)),
          trailing: const Icon(Icons.chevron_right, color: AppTheme.textLight),
          onTap: onTap,
          // 👇 给个极淡的波纹色，几乎看不见但能消除警告
          splashColor: const Color(0x08000000),
        ),
      ),
    );
  }
}
