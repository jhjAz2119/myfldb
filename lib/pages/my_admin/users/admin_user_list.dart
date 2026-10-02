import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../config.dart';
import '../../../utils/api_service.dart';
import '../shared/admin_theme.dart';
import '../shared/admin_sidebar.dart';
import '../shared/admin_app_bar.dart';

class AdminUserList extends StatefulWidget {
  const AdminUserList({super.key});
  @override
  State<AdminUserList> createState() => _AdminUserListState();
}

class _AdminUserListState extends State<AdminUserList> {
  List<dynamic> _userList = [];
  bool _isLoading = true;
  String? _errorMsg;
  final _searchCtrl = TextEditingController();
  List<dynamic> _filteredList = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final uri = Uri.parse('${Config.baseUrl}/admin/users');
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      // ✅ 改为调用公开方法
      final data = ApiService.parseResponse(res);
      if (data['success'] == true && mounted) {
        setState(() {
          _userList = data['data'] ?? data['list'] ?? [];
          _filteredList = _userList;
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

  void _onSearch() {
    final kw = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filteredList = _userList.where((u) {
        final account = (u['account'] ?? '').toString().toLowerCase();
        final nickname = (u['nickname'] ?? '').toString().toLowerCase();
        return kw.isEmpty || account.contains(kw) || nickname.contains(kw);
      }).toList();
    });
  }

  Future<void> _toggleStatus(dynamic user) async {
    final newStatus = user['status'] == '禁用' ? '正常' : '禁用';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('确认$newStatus'),
        content: Text('确定要将「${user['account']}」$newStatus吗？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text('确定', style: TextStyle(color: AdminTheme.error))),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      final uri = Uri.parse('${Config.baseUrl}/admin/user/set-status');
      final res = await http.post(
        uri,
        body: {'account': user['account'].toString(), 'status': newStatus},
      ).timeout(const Duration(seconds: 15));
      // ✅ 改为调用公开方法
      final data = ApiService.parseResponse(res);
      if (data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? '操作成功')),
          );
        }
        _loadUsers(); // 刷新列表
      } else {
        throw Exception(data['message'] ?? '操作失败');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('失败：${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AdminSidebar(selectedIndex: 1),
          Expanded(
            child: Column(
              children: [
                AdminAppBar(title: '用户列表', trailing: _buildSearchBar()),
                Expanded(
                  child: Container(
                    color: AdminTheme.bgPrimary,
                    padding: const EdgeInsets.all(24),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return SizedBox(
      width: 280,
      height: 36,
      child: TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: '搜索账号/昵称...',
          prefixIcon: const Icon(Icons.search, size: 18),
          filled: true,
          fillColor: const Color(0xFFF8FAFC),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
              borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMsg != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('读取失败：$_errorMsg', style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadUsers, child: const Text('重新加载')),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('共 ${_filteredList.length} 位用户',
            style: TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 16),
        _buildTableHeader(),
        const SizedBox(height: 8),
        Expanded(
          child: _filteredList.isEmpty
              ? const Center(child: Text('暂无数据'))
              : ListView.separated(
                  itemCount: _filteredList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) =>
                      _buildTableRow(_filteredList[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AdminTheme.radiusMd)),
      child: const Row(
        children: [
          Expanded(
              flex: 2,
              child: Text('账号', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text('昵称', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child:
                  Text('注册时间', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child: Text('状态', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 1,
              child: Text('认证', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
              flex: 2,
              child: Text('操作', style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildTableRow(dynamic user) {
    final status = (user['status'] ?? '正常').toString();
    final verify = (user['verify_status'] ?? '未提交').toString();
    Color statusColor = status == '正常' ? AdminTheme.success : AdminTheme.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1))
        ],
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(user['account']?.toString() ?? '-')),
          Expanded(flex: 2, child: Text(user['nickname']?.toString() ?? '-')),
          Expanded(
              flex: 2,
              child: Text(user['register_time']?.toString() ?? '-',
                  style: TextStyle(color: AdminTheme.textSecondary))),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Text(status,
                  style: TextStyle(color: statusColor, fontSize: 12)),
            ),
          ),
          Expanded(
              flex: 1,
              child: Text(verify, style: const TextStyle(fontSize: 12))),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                TextButton(onPressed: () {}, child: const Text('查看')),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _toggleStatus(user),
                  style: TextButton.styleFrom(
                      foregroundColor: status == '禁用'
                          ? AdminTheme.success
                          : AdminTheme.error),
                  child: Text(status == '禁用' ? '启用' : '禁用'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
