import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/theme_config.dart';
import '../../../widgets/common_widgets.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final String _currentVersion = "1.0.0";
  final String _latestVersion = "1.0.0";
  final String _downloadUrl =
      "https://github.com/jhjAz2119/myfldb/releases/latest/download/app-release.apk";
  final String _updateNote = "1. 优化个人信息页面\n2. 修复生日选择问题";

  bool _isChecking = false;
  bool _hasNewVersion = false;

  Future<void> _checkVersion() async {
    if (kIsWeb) return;
    if (!mounted) return;

    setState(() => _isChecking = true);
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      List<int> parseVersion(String v) {
        return v.split('.').map((part) {
          final n = int.tryParse(part);
          return n ?? 0;
        }).toList();
      }

      final current = parseVersion(_currentVersion);
      final latest = parseVersion(_latestVersion);
      _hasNewVersion = latest.join('.') != current.join('.');
    } catch (_) {
      _hasNewVersion = false;
    }

    if (mounted) setState(() => _isChecking = false);
  }

  Future<void> _openDownloadLink() async {
    final url = _downloadUrl.trim();
    if (url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("暂无下载地址")),
        );
      }
      return;
    }

    try {
      final uri = Uri.parse(url);

      // 网页端：直接创建下载链接，避免浏览器拦截
      if (kIsWeb) {
        // 简单直接：在新标签页打开链接，浏览器自动处理下载
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
          webOnlyWindowName: '_blank',
        );
      } else {
        // 手机端：用外部应用打开，最稳定
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          throw "无法打开";
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("无法打开下载链接，请稍后重试")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: "关于我们",
      body: SingleChildScrollView(
        padding: AppTheme.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 版本信息区块
            const Text(
              "版本信息",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppTheme.spacingMd),

            Center(
              child: Column(
                children: [
                  const Icon(Icons.info_outline,
                      size: 64, color: Color(0xFF4ECDC4)),
                  SizedBox(height: AppTheme.spacingMd),
                  Text(
                    "Flutter App",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingSm),
                  Text(
                    "当前版本 $_currentVersion",
                    style:
                        TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                  if (kIsWeb) ...[
                    SizedBox(height: AppTheme.spacingSm),
                    Text(
                      "网页版",
                      style: TextStyle(fontSize: 13, color: AppTheme.textLight),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacingLg),

            // 版本检测 / 下载区
            if (!kIsWeb) ...[
              AppButton(
                text: _isChecking ? "正在检测..." : "检测新版本",
                onTap: _isChecking ? () {} : _checkVersion,
              ),
              SizedBox(height: AppTheme.spacingLg),
              if (_hasNewVersion) ...[
                const Text(
                  "发现新版本",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: AppTheme.spacingSm),
                Text(
                  "更新内容：\n$_updateNote",
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
                ),
                SizedBox(height: AppTheme.spacingLg),
              ] else ...[
                const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Text(
                        "当前已是最新版本",
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppTheme.spacingLg),
              ],
            ],

            // 下载按钮（始终显示）
            AppButton(
              text: "下载安装",
              onTap: _openDownloadLink,
            ),
            const SizedBox(height: 40), // 底部留白与个人信息页统一
          ],
        ),
      ),
    );
  }
}
