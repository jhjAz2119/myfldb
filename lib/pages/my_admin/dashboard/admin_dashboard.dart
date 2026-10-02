import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart';
import '../../../utils/api_service.dart';
import '../shared/admin_theme.dart';
import '../shared/admin_sidebar.dart';
import '../shared/admin_app_bar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  String? _errorMsg;
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final uri = Uri.parse('${Config.baseUrl}/admin/statistics');
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      // ✅ 关键修复：调用公开方法 parseResponse
      final data = ApiService.parseResponse(res);
      if (data['success'] == true && mounted) {
        setState(() {
          _stats = data['data'] ?? {};
          _isLoading = false;
        });
      } else {
        throw Exception(data['message'] ?? '获取失败');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AdminTheme.buildFullScreen(
        child: Row(
          children: [
            // 左侧固定侧边栏
            AdminTheme.buildSidebar(
              child: const AdminSidebar(selectedIndex: 0),
            ),

            // 右侧内容区
            AdminTheme.buildContentArea(
              child: AdminTheme.buildContentWithBar(
                appBar: const AdminAppBar(title: '数据统计'),
                body: Container(
                  padding: AdminTheme.contentPadding,
                  child: _buildContent(), // 你原来的内容直接保留
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMsg != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('读取失败：$_errorMsg', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStatistics,
              child: const Text('重新加载'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '欢迎回到管理后台',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '以下是系统概览，数据实时更新',
          style: TextStyle(color: AdminTheme.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 32),
        Expanded(
          child: GridView.count(
            crossAxisCount: 4,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            children: [
              _StatCard(
                title: '总用户数',
                value: _stats['total_users']?.toString() ?? '0',
                icon: Icons.people,
                color: const Color(0xFF4DB6AC),
              ),
              _StatCard(
                title: '今日新增',
                value: _stats['today_new']?.toString() ?? '0',
                icon: Icons.person_add,
                color: const Color(0xFF3B82F6),
              ),
              _StatCard(
                title: '待审核',
                value: _stats['pending_verify']?.toString() ?? '0',
                icon: Icons.pending,
                color: const Color(0xFFFF9800),
              ),
              _StatCard(
                title: '系统状态',
                value: _stats['system_status']?.toString() ?? '正常',
                icon: Icons.check_circle,
                color: const Color(0xFF10B981),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style:
                      TextStyle(color: AdminTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
