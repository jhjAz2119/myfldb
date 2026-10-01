import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile_page.dart';
import '../user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 3;

  final List<Widget> _pages = const [
    _PlaceholderPage(title: "首页"),
    _PlaceholderPage(title: "发现"),
    _PlaceholderPage(title: "推荐"),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(user.nickname ?? user.account ?? "用户"),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "首页"),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: "发现"),
          BottomNavigationBarItem(icon: Icon(Icons.recommend), label: "推荐"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "个人信息"),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text(
          "开发中...",
          style: TextStyle(fontSize: 20, color: Colors.grey),
        ),
      ),
    );
  }
}
