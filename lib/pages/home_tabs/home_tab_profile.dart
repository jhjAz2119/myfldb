import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../../user_provider.dart';
import '../../utils/api_service.dart';
import '../../theme/theme_config.dart';

class HomeTabProfile extends StatefulWidget {
  const HomeTabProfile({super.key});
  @override
  State<HomeTabProfile> createState() => _HomeTabProfileState();
}

class _HomeTabProfileState extends State<HomeTabProfile> {
  String? _avatarUrl;
  Timer? _checkTimer;
  bool _isDataReady = false;
  int _checkCount = 0;
  static const int _maxCheckCount = 24;

  @override
  void initState() {
    super.initState();
    _loadSavedAvatar();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startCheckLoop();
    });
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSavedAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _avatarUrl = prefs.getString('avatar');
      });
    }
  }

  void _startCheckLoop() {
    debugPrint('🔍 自动检测器已启动，最多检测2分钟');
    _checkAndSync();
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkAndSync();
    });
  }

  Future<void> _checkAndSync() async {
    if (!mounted) return;
    if (_isDataReady) return;

    _checkCount++;

    if (_checkCount > _maxCheckCount) {
      _checkTimer?.cancel();
      debugPrint('⏹️ 已达2分钟上限，停止检测');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据加载超时，请退出重新登录')),
        );
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final user = context.read<UserProvider>();

    final savedAccount = prefs.getString('account');
    final savedNickname = prefs.getString('nickname');
    final savedUserId = prefs.getString('user_id');
    final savedAvatar = prefs.getString('avatar');
    final savedGender = prefs.getString('gender');
    final savedBirthday = prefs.getString('birthday');

    debugPrint('🔍 第$_checkCount/$_maxCheckCount次检测: '
        'account=$savedAccount, userId=$savedUserId');

    if (savedAccount != null && savedAccount.isNotEmpty) {
      user.setUserInfo(
        account: savedAccount,
        nickname: savedNickname,
        userId: savedUserId,
        avatar: savedAvatar,
        gender: savedGender,
        birthday: savedBirthday,
      );

      if (savedAvatar != null && savedAvatar.isNotEmpty) {
        _avatarUrl = savedAvatar;
      }
      setState(() {});
    }

    final hasComplete = user.account != null && user.account!.isNotEmpty;
    if (hasComplete) {
      _isDataReady = true;
      _checkTimer?.cancel();
      debugPrint('✅ 数据已就绪，停止检测（共$_checkCount次）');
      setState(() {});
    }
  }

  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickAndUploadAvatar() async {
    if (_isUploading) return;
    if (mounted) setState(() => _isUploading = true);
    try {
      final XFile? image = await _picker
          .pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
            maxWidth: 400,
          )
          .timeout(const Duration(seconds: 120));
      if (image == null) {
        if (mounted) setState(() => _isUploading = false);
        return;
      }
      if (!mounted) return;

      final user = context.read<UserProvider>();
      final account = user.account;
      if (account == null || account.isEmpty) {
        _showMsg("请先登录");
        if (mounted) setState(() => _isUploading = false);
        return;
      }

      final res = await ApiService.uploadAvatar(account, image.path)
          .timeout(const Duration(seconds: 120));
      if (!mounted) return;

      if (res["code"] == 200) {
        final avatarUrl = res["avatarUrl"] as String?;
        if (avatarUrl != null && avatarUrl.isNotEmpty) {
          user.avatar = avatarUrl;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('avatar', avatarUrl);
          setState(() {
            _avatarUrl = avatarUrl;
          });
        }
        _showMsg("头像更新成功");
      } else {
        _showMsg(res["msg"] ?? "上传失败");
      }
    } on TimeoutException {
      _showMsg("操作超时，请重试");
    } catch (e) {
      _showMsg("出错：${e.toString().substring(0, 50)}");
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showMsg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), duration: const Duration(seconds: 2)),
    );
  }

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
      if (mounted) Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    final displayName = user.nickname ?? user.account ?? "用户";
    final displayId = user.userId ?? '暂无';
    final displayAvatar = _avatarUrl ?? user.avatar;
    final fullAvatarUrl = displayAvatar != null && displayAvatar.isNotEmpty
        ? "https://myfldb.onrender.com$displayAvatar"
        : null;

    return Center(
      child: SingleChildScrollView(
        padding: AppTheme.pagePadding,
        child: Column(
          children: [
            // ✅ 已去掉页面上的"正在加载数据..."提示，保留控制台日志
            GestureDetector(
              onTap: _isUploading ? null : _pickAndUploadAvatar,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.focus.withOpacity(0.08),
                      shape: BoxShape.circle,
                      image: fullAvatarUrl != null
                          ? DecorationImage(
                              image: NetworkImage(fullAvatarUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: fullAvatarUrl == null
                        ? const Icon(Icons.person,
                            size: 50, color: AppTheme.focus)
                        : null,
                  ),
                  if (_isUploading)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black26,
                        child: const CircularProgressIndicator(strokeWidth: 3),
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
                    child: const Icon(Icons.camera_alt,
                        size: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              displayName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "ID: $displayId",
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Container(
                width: 40, height: 3, color: AppTheme.focus.withOpacity(0.5)),
            const SizedBox(height: 24),
            _buildMenuItem(Icons.person_outline, "账号信息",
                () => Navigator.pushNamed(context, '/profile/account')),
            const SizedBox(height: 12),
            _buildMenuItem(Icons.security, "安全中心",
                () => Navigator.pushNamed(context, '/profile/security')),
            const SizedBox(height: 12),
            _buildMenuItem(Icons.info_outline, "关于我们",
                () => Navigator.pushNamed(context, '/profile/about')),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isUploading ? null : _logout,
                child: const Text("退出登录", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Icon(icon, color: AppTheme.focus),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: _isUploading ? null : onTap,
      ),
    );
  }
}
