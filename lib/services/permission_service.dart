import 'package:flutter/services.dart';

class PermissionService {
  static const _channel = MethodChannel('com.stayfocus/app_blocker');

  /// Check if Usage Stats permission is granted.
  static Future<bool> checkUsageStatsPermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkUsageStatsPermission');
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Open Usage Access settings page.
  static Future<void> openUsageAccessSettings() async {
    try {
      await _channel.invokeMethod('openUsageAccessSettings');
    } on PlatformException catch (e) {
      print('Failed to open Usage Access settings: $e');
    }
  }

  /// Check if Accessibility Service is enabled.
  static Future<bool> checkAccessibilityPermission() async {
    try {
      final bool result =
          await _channel.invokeMethod('checkAccessibilityPermission');
      return result;
    } on PlatformException {
      return false;
    }
  }

  /// Open Accessibility settings page.
  static Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } on PlatformException catch (e) {
      print('Failed to open Accessibility settings: $e');
    }
  }

  /// Get list of installed apps from Android PackageManager.
  /// Returns a list of maps with keys: name, packageName, icon (base64).
  static Future<List<Map<String, dynamic>>> getInstalledApps() async {
    try {
      final List<dynamic> result =
          await _channel.invokeMethod('getInstalledApps');
      return result.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } on PlatformException {
      return [];
    }
  }
}
