import 'package:flutter/material.dart';
import 'screens/permission_screen.dart';
import 'screens/app_list_screen.dart';
import 'screens/blocked_screen.dart';
import 'screens/blocked_apps_screen.dart';

void main() {
  runApp(const StayFocusedApp());
}

class StayFocusedApp extends StatelessWidget {
  const StayFocusedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stay Focused',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const PermissionScreen(),
        '/app_list': (context) => const AppListScreen(),
        '/blocked': (context) => const BlockedScreen(),
        '/blocked_apps': (context) => const BlockedAppsScreen(),
      },
    );
  }
}
