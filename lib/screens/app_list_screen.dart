import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';

class AppListScreen extends StatefulWidget {
  const AppListScreen({super.key});

  @override
  State<AppListScreen> createState() => _AppListScreenState();
}

class _AppListScreenState extends State<AppListScreen> with RouteAware {
  List<Map<String, dynamic>> _apps = [];
  Set<String> _blockedPackages = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final apps = await PermissionService.getInstalledApps();
    final blocked = await StorageService.getBlockedApps();
    if (!mounted) return;
    setState(() {
      _apps = apps;
      _blockedPackages = blocked.toSet();
      _loading = false;
    });
  }

  Future<void> _toggleBlock(String packageName, String appName) async {
    if (_blockedPackages.contains(packageName)) {
      // Already blocked — offer to unblock
      await StorageService.removeBlockedApp(packageName);
      if (!mounted) return;
      setState(() {
        _blockedPackages.remove(packageName);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unblocked: $appName')));
    } else {
      // Block the app
      await StorageService.addBlockedApp(packageName);
      if (!mounted) return;
      setState(() {
        _blockedPackages.add(packageName);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Blocked: $appName')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Apps to Block'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Manage Blocked Apps',
            onPressed: () async {
              await Navigator.pushNamed(context, '/blocked_apps');
              // Refresh state when returning from blocked apps screen
              _loadData();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _apps.isEmpty
          ? const Center(child: Text('No apps found.'))
          : ListView.builder(
              itemCount: _apps.length,
              itemBuilder: (context, index) {
                final app = _apps[index];
                final name = app['name'] as String? ?? '';
                final packageName = app['packageName'] as String? ?? '';
                final iconBase64 = app['icon'] as String?;
                final isBlocked = _blockedPackages.contains(packageName);

                return ListTile(
                  leading: iconBase64 != null && iconBase64.isNotEmpty
                      ? Image.memory(
                          base64Decode(iconBase64),
                          width: 40,
                          height: 40,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.android, size: 40),
                        )
                      : const Icon(Icons.android, size: 40),
                  title: Text(
                    name,
                    style: TextStyle(
                      fontWeight: isBlocked
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(
                    packageName,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: isBlocked
                      ? const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 28,
                        )
                      : const Icon(
                          Icons.add_circle_outline,
                          color: Colors.grey,
                          size: 28,
                        ),
                  onTap: () => _toggleBlock(packageName, name),
                );
              },
            ),
    );
  }
}
