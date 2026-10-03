//数据统计
import 'package:flutter/material.dart';
import '../admin_theme.dart';
import '../admin_data_service.dart';

class DashboardSubpage extends StatefulWidget {
  const DashboardSubpage({super.key});

  @override
  State<DashboardSubpage> createState() => _DashboardSubpageState();
}

class _DashboardSubpageState extends State<DashboardSubpage> {
  bool _loading = true;
  Map<String, dynamic> _data = {};
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    try {
      final res = await AdminDataService.getStatistics();
      if (res['success'] == true && mounted) {
        // ✅ 正确：只取 data 部分
        setState(() {
          _data = res['data'] is Map ? res['data'] as Map<String, dynamic> : {};
          _loading = false;
        });
      } else {
        setState(() {
          _errorMsg = res['message'] ?? '加载失败';
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = '请求异常：${e.toString()}';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AdminTheme.bgPrimary,
      padding: AdminTheme.contentPadding,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMsg != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMsg!,
                        style: TextStyle(color: AdminTheme.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStatistics,
                        style: AdminTheme.primaryButton,
                        child: const Text('重新加载'),
                      ),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      children: [
        _buildCard('用户总数', _data['total_users']?.toString() ?? '0'),
        _buildCard('已认证', _data['verified_users']?.toString() ?? '0'),
        _buildCard('未认证', _data['unverified_users']?.toString() ?? '0'),
        _buildCard('资金总额', _data['total_balance']?.toString() ?? '0'),
      ],
    );
  }

  Widget _buildCard(String title, String value) {
    return Container(
      padding: AdminTheme.cardPadding,
      decoration: BoxDecoration(
        color: AdminTheme.bgSecondary,
        borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: AdminTheme.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
