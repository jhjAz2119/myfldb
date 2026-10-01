import 'package:flutter/material.dart';
import '../theme/theme_config.dart';
import '../widgets/common_widgets.dart';
import 'home_tabs/home_tab_index.dart';
import 'home_tabs/home_tab_discover.dart';
import 'home_tabs/home_tab_recommend.dart';
import 'home_tabs/home_tab_profile.dart';
import '../config.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<Widget> _tabs = const [
    HomeTabIndex(),
    HomeTabDiscover(),
    HomeTabRecommend(),
    HomeTabProfile(),
  ];

  @override
  Widget build(BuildContext context) {
    return PageBackground(
      child: Stack(
        children: [
          // 背景装饰圆 —— 原样保留
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
          // 统一用 AppScaffold，导航栏正常显示
          Center(
            child: AppScaffold(
              title: Config.appName,
              showBackButton: false,
              body: _tabs[_selectedIndex],
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                selectedItemColor: AppTheme.focus,
                unselectedItemColor: AppTheme.textLight,
                showUnselectedLabels: true,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: '首页',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.explore),
                    label: '发现',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.thumb_up),
                    label: '推荐',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person),
                    label: '个人信息',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
