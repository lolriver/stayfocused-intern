import 'package:flutter/services.dart';

class StorageService {
  static const _channel = MethodChannel('com.stayfocus/app_blocker');

  /// Add an app to the blocked list.
  static Future<void> addBlockedApp(String packageName) async {
    try {
      await _channel.invokeMethod('addBlockedApp', {
        'packageName': packageName,
      });
    } on PlatformException catch (e) {
      print('Failed to add blocked app: $e');
    }
  }

  /// Remove an app from the blocked list.
  static Future<void> removeBlockedApp(String packageName) async {
    try {
      await _channel.invokeMethod('removeBlockedApp', {
        'packageName': packageName,
      });
    } on PlatformException catch (e) {
      print('Failed to remove blocked app: $e');
    }
  }

  /// Get the list of all blocked app package names.
  static Future<List<String>> getBlockedApps() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod(
        'getBlockedApps',
      );
      return result.cast<String>();
    } on PlatformException {
      return [];
    }
  }
}
