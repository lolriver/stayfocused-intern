import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import '../services/storage_service.dart';

class BlockedAppsScreen extends StatefulWidget {
  const BlockedAppsScreen({super.key});

  @override
  State<BlockedAppsScreen> createState() => _BlockedAppsScreenState();
}

class _BlockedAppsScreenState extends State<BlockedAppsScreen> {
  List<Map<String, dynamic>> _allApps = [];
  List<String> _blockedPackages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final allApps = await PermissionService.getInstalledApps();
    final blocked = await StorageService.getBlockedApps();
    if (!mounted) return;
    setState(() {
      _allApps = allApps;
      _blockedPackages = List<String>.from(blocked);
      _loading = false;
    });
  }

  Map<String, dynamic>? _findAppInfo(String packageName) {
    try {
      return _allApps.firstWhere((app) => app['packageName'] == packageName);
    } catch (_) {
      return null;
    }
  }

  Future<void> _unblockApp(String packageName) async {
    await StorageService.removeBlockedApp(packageName);
    if (!mounted) return;
    // Instant live update
    setState(() {
      _blockedPackages.remove(packageName);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Unblocked: ${_findAppInfo(packageName)?['name'] ?? packageName}',
        ),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () async {
            await StorageService.addBlockedApp(packageName);
            if (!mounted) return;
            setState(() {
              _blockedPackages.add(packageName);
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blocked Apps'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _blockedPackages.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No apps are currently blocked.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Block Apps'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              itemCount: _blockedPackages.length,
              itemBuilder: (context, index) {
                final packageName = _blockedPackages[index];
                final appInfo = _findAppInfo(packageName);
                final name = appInfo?['name'] as String? ?? packageName;
                final iconBase64 = appInfo?['icon'] as String?;

                return Dismissible(
                  key: Key(packageName),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    color: Colors.red,
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _unblockApp(packageName),
                  child: ListTile(
                    leading: iconBase64 != null && iconBase64.isNotEmpty
                        ? Image.memory(
                            base64Decode(iconBase64),
                            width: 40,
                            height: 40,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.android, size: 40),
                          )
                        : const Icon(Icons.android, size: 40),
                    title: Text(name),
                    subtitle: Text(
                      packageName,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.lock_open, color: Colors.red),
                      tooltip: 'Unblock',
                      onPressed: () => _unblockApp(packageName),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
