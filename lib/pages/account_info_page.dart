import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../user_provider.dart';
import '../theme/theme_config.dart';
import '../widgets/common_widgets.dart';
import '../utils/api_service.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  final _nicknameCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _monthCtrl = TextEditingController();
  final _dayCtrl = TextEditingController();
  String _selectedGender = "未设置";

  final _yearFocus = FocusNode();
  final _monthFocus = FocusNode();
  final _dayFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _yearFocus.dispose();
    _monthFocus.dispose();
    _dayFocus.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = context.read<UserProvider>();
    _nicknameCtrl.text = user.nickname ?? user.account ?? "";
    _selectedGender = user.gender ?? "未设置";
    final bday = user.birthday ?? "";
    if (bday.length >= 10) {
      _yearCtrl.text = bday.substring(0, 4);
      _monthCtrl.text = bday.substring(5, 7);
      _dayCtrl.text = bday.substring(8, 10);
    }
  }

  static int _daysInMonth(int year, int month) {
    if (month == 2) {
      final leap = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
      return leap ? 29 : 28;
    }
    return [4, 6, 9, 11].contains(month) ? 30 : 31;
  }

  String _formatBirthday() {
    final y = _yearCtrl.text.trim();
    final m = _monthCtrl.text.trim().padLeft(2, '0');
    final d = _dayCtrl.text.trim().padLeft(2, '0');
    if (y.length != 4 || m.length != 2 || d.length != 2) return "";
    return "$y-$m-$d";
  }

  Future<void> _saveProfile() async {
    final user = context.read<UserProvider>();
    if (user.account == null) return;

    final y = int.tryParse(_yearCtrl.text);
    final m = int.tryParse(_monthCtrl.text);
    final d = int.tryParse(_dayCtrl.text);
    final now = DateTime.now();

    if (_yearCtrl.text.length != 4 || y == null || y < 1940 || y > now.year) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("年份请输入 1940-${now.year} 之间的4位数字")),
        );
      }
      return;
    }
    if (m == null || m < 1 || m > 12) {
      if (mounted) {
        const SnackBar(content: Text("月份请输入 1-12"));
      }
      return;
    }
    final maxDay = _daysInMonth(y, m);
    if (d == null || d < 1 || d > maxDay) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("日期范围 1-$maxDay")),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("保存中..."), duration: Duration(seconds: 1)),
      );
    }

    final birthday = _formatBirthday();
    final res = await ApiService.updateProfile(
      account: user.account!,
      nickname: _nicknameCtrl.text.trim(),
      gender: _selectedGender,
      birthday: birthday,
    );

    if (!mounted) return;
    final code = res["code"];
    final msg = res["detail"] ?? res["msg"] ?? "未知错误";

    if (code == 200 || code == 0) {
      await user.saveProfile({
        "nickname": _nicknameCtrl.text.trim(),
        "gender": _selectedGender,
        "birthday": birthday,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("保存成功")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("保存失败：$msg")),
        );
      }
    }
  }

  void _showEditDialog() {
    final nickCtrl = TextEditingController(text: _nicknameCtrl.text);
    final yearCtrl = TextEditingController(text: _yearCtrl.text);
    final monthCtrl = TextEditingController(text: _monthCtrl.text);
    final dayCtrl = TextEditingController(text: _dayCtrl.text);
    String gender = _selectedGender;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) {
          return AlertDialog(
            title: const Text("编辑个人信息"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nickCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: "昵称"),
                    onSubmitted: (_) =>
                        FocusScope.of(ctx).requestFocus(_yearFocus),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: gender,
                    decoration: const InputDecoration(labelText: "性别"),
                    items: const [
                      DropdownMenuItem(value: "未设置", child: Text("未设置")),
                      DropdownMenuItem(value: "男", child: Text("男")),
                      DropdownMenuItem(value: "女", child: Text("女")),
                    ],
                    onChanged: (v) => setDialog(() => gender = v!),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: yearCtrl,
                          focusNode: _yearFocus,
                          keyboardType: TextInputType.number,
                          maxLength: 4,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: "年",
                            hintText: "如 1990",
                            counterText: "",
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          onSubmitted: (_) =>
                              FocusScope.of(ctx).requestFocus(_monthFocus),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: monthCtrl,
                          focusNode: _monthFocus,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: "月",
                            hintText: "1-12",
                            counterText: "",
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          onSubmitted: (_) =>
                              FocusScope.of(ctx).requestFocus(_dayFocus),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: dayCtrl,
                          focusNode: _dayFocus,
                          keyboardType: TextInputType.number,
                          maxLength: 2,
                          textInputAction: TextInputAction.done,
                          decoration: const InputDecoration(
                            labelText: "日",
                            hintText: "1-31",
                            counterText: "",
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                          onSubmitted: (_) async {
                            Navigator.pop(ctx);
                            setState(() {
                              _nicknameCtrl.text = nickCtrl.text;
                              _selectedGender = gender;
                              _yearCtrl.text = yearCtrl.text;
                              _monthCtrl.text = monthCtrl.text;
                              _dayCtrl.text = dayCtrl.text;
                            });
                            await _saveProfile();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("取消"),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  setState(() {
                    _nicknameCtrl.text = nickCtrl.text;
                    _selectedGender = gender;
                    _yearCtrl.text = yearCtrl.text;
                    _monthCtrl.text = monthCtrl.text;
                    _dayCtrl.text = dayCtrl.text;
                  });
                  await _saveProfile();
                },
                child: const Text("保存"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return AppScaffold(
      title: "账号信息",
      showBackButton: true,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _infoRow("账号", user.account ?? "未设置"),
          _infoRow("昵称", user.nickname ?? user.account ?? "未设置"),
          _infoRow("性别", user.gender ?? "未设置"),
          _infoRow(
            "生日",
            user.birthday?.isNotEmpty == true ? user.birthday! : "未设置",
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showEditDialog,
              child: const Text("编辑信息"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 15)),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
}
