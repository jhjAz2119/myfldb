import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/register_page.dart';
import 'pages/home_tabs/profile_pages/about_page.dart';
import 'pages/home_tabs/profile_pages/account_info_page.dart';
import 'pages/home_tabs/profile_pages/security_page.dart';
import 'pages/my_admin/dashboard/admin_dashboard.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColor: const Color(0xFF4DB6AC),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      locale: const Locale('zh', 'CN'),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/profile/account': (context) => const AccountInfoPage(),
        '/profile/security': (context) => const SecurityPage(),
        '/profile/about': (context) => const AboutPage(),
        '/my_admin': (context) => const AdminDashboard(), // 后台专属地址
      },
    );
  }
}
