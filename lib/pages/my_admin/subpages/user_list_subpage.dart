//用户列表
import 'package:flutter/material.dart';
import '../admin_theme.dart';
import '../admin_data_service.dart';

class UserListSubpage extends StatefulWidget {
  const UserListSubpage({super.key});

  @override
  State<UserListSubpage> createState() => _UserListSubpageState();
}

class _UserListSubpageState extends State<UserListSubpage> {
  bool _loading = true;
  List _userList = [];
  int _total = 0;
  int _currentPage = 1;
  final int _limit = 20;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadUserList();
  }

  Future<void> _loadUserList() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });

    try {
      final res =
          await AdminDataService.getUserList(page: _currentPage, limit: _limit);
      if (res['success'] == true && mounted) {
        final data =
            res['data'] is Map ? res['data'] as Map<String, dynamic> : {};
        setState(() {
          _userList = data['list'] is List ? data['list'] as List : [];
          _total = data['total'] is int ? data['total'] : 0;
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

  Future<void> _deleteUser(dynamic userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除该用户吗？此操作不可恢复！'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('删除', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final res = await AdminDataService.deleteUser(userId);
    if (res['success'] == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('删除成功')));
      _loadUserList();
    } else if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res['message'] ?? '删除失败')));
    }
  }

  Future<void> _toggleFreeze(dynamic userId, bool isFrozen) async {
    final res = await AdminDataService.toggleUserStatus(userId, !isFrozen);
    if (res['success'] == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(isFrozen ? '已解冻' : '已冻结')));
      _loadUserList();
    } else if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res['message'] ?? '操作失败')));
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
                        onPressed: _loadUserList,
                        style: AdminTheme.primaryButton,
                        child: const Text('重新加载'),
                      ),
                    ],
                  ),
                )
              : _buildTable(),
    );
  }

  Widget _buildTable() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 顶部信息
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            '共 $_total 位用户',
            style: TextStyle(color: AdminTheme.textSecondary, fontSize: 14),
          ),
        ),
        // 表格
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AdminTheme.bgSecondary,
                borderRadius: BorderRadius.circular(AdminTheme.radiusMd),
              ),
              child: DataTable(
                columnSpacing: 24,
                horizontalMargin: 20,
                columns: const [
                  DataColumn(label: Text('账号')),
                  DataColumn(label: Text('昵称')),
                  DataColumn(label: Text('认证状态')),
                  DataColumn(label: Text('余额')),
                  DataColumn(label: Text('注册时间')),
                  DataColumn(label: Text('操作')),
                ],
                rows: _userList.map((user) {
                  final userId = user['id'];
                  final account = user['account']?.toString() ?? '-';
                  final nickname = user['nickname']?.toString() ?? '-';
                  final verified = user['id_verified'] == true; // 数据库字段
                  final balance = user['balance']?.toString() ?? '0';
                  final createdAt =
                      user['created_at']?.toString().substring(0, 10) ?? '-';
                  final isFrozen = false; // 后续扩展冻结字段

                  return DataRow(cells: [
                    DataCell(Text(account)),
                    DataCell(Text(nickname)),
                    DataCell(Text(
                      verified ? '已认证' : '未认证',
                      style: TextStyle(
                        color:
                            verified ? AdminTheme.success : AdminTheme.textHint,
                      ),
                    )),
                    DataCell(Text('¥$balance')),
                    DataCell(Text(createdAt)),
                    DataCell(Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _toggleFreeze(userId, isFrozen),
                          style: AdminTheme.outlineButton,
                          child: const Text('冻结'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _deleteUser(userId),
                          style: AdminTheme.dangerButton,
                          child: const Text('删除'),
                        ),
                      ],
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ),
        ),
        // 分页
        if (_total > _limit)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() => _currentPage--);
                          _loadUserList();
                        }
                      : null,
                  child: const Text('上一页'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text('第 $_currentPage 页'),
                ),
                ElevatedButton(
                  onPressed: _currentPage * _limit < _total
                      ? () {
                          setState(() => _currentPage++);
                          _loadUserList();
                        }
                      : null,
                  child: const Text('下一页'),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
