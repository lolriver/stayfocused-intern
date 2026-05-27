import 'package:flutter/material.dart';
import '../services/permission_service.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with WidgetsBindingObserver {
  bool _usageStatsGranted = false;
  bool _accessibilityEnabled = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check permissions when the user comes back from settings.
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    final usageStats = await PermissionService.checkUsageStatsPermission();
    final accessibility =
        await PermissionService.checkAccessibilityPermission();
    if (!mounted) return;
    setState(() {
      _usageStatsGranted = usageStats;
      _accessibilityEnabled = accessibility;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permission Setup')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'The following permissions are required for the app to work.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 32),

                  // --- Usage Stats ---
                  _PermissionTile(
                    title: 'Usage Access Permission',
                    description:
                        'Allows the app to view which apps are in use.',
                    granted: _usageStatsGranted,
                    onEnable: () async {
                      await PermissionService.openUsageAccessSettings();
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- Accessibility ---
                  _PermissionTile(
                    title: 'Accessibility Service',
                    description:
                        'Allows the app to detect the foreground app and show the blocking screen.',
                    granted: _accessibilityEnabled,
                    onEnable: () async {
                      await PermissionService.openAccessibilitySettings();
                    },
                  ),
                  const Spacer(),

                  // --- Continue ---
                  ElevatedButton(
                    onPressed: (_usageStatsGranted && _accessibilityEnabled)
                        ? () {
                            Navigator.pushNamed(context, '/app_list');
                          }
                        : null,
                    child: const Text('Continue'),
                  ),
                  const SizedBox(height: 12),

                  // --- Manage Blocked Apps ---
                  OutlinedButton(
                    onPressed: (_usageStatsGranted && _accessibilityEnabled)
                        ? () {
                            Navigator.pushNamed(context, '/blocked_apps');
                          }
                        : null,
                    child: const Text('Manage Blocked Apps'),
                  ),
                ],
              ),
            ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final String title;
  final String description;
  final bool granted;
  final VoidCallback onEnable;

  const _PermissionTile({
    required this.title,
    required this.description,
    required this.granted,
    required this.onEnable,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          granted ? Icons.check_circle : Icons.error,
          color: granted ? Colors.green : Colors.red,
          size: 32,
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: granted
            ? const Text('Enabled', style: TextStyle(color: Colors.green))
            : ElevatedButton(onPressed: onEnable, child: const Text('Enable')),
      ),
    );
  }
}
