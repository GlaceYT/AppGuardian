import 'package:flutter/services.dart';
import '../models/app_info.dart';

class NativeBridge {
  static const _channel = MethodChannel('com.predator.app_guardian/native');

  /// Get list of installed apps with launcher activities
  static Future<List<AppInfo>> getInstalledApps() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getInstalledApps');
      return result
          .map((e) => AppInfo.fromMap(e as Map<dynamic, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if our accessibility service is enabled
  static Future<bool> isAccessibilityServiceEnabled() async {
    try {
      return await _channel.invokeMethod('isAccessibilityServiceEnabled') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Open accessibility settings
  static Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  /// Check usage stats permission
  static Future<bool> isUsageStatsPermissionGranted() async {
    try {
      return await _channel.invokeMethod('isUsageStatsPermissionGranted') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Open usage stats settings
  static Future<void> openUsageStatsSettings() async {
    try {
      await _channel.invokeMethod('openUsageStatsSettings');
    } catch (_) {}
  }

  /// Check if device admin is active
  static Future<bool> isDeviceAdminActive() async {
    try {
      return await _channel.invokeMethod('isDeviceAdminActive') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Request device admin
  static Future<void> requestDeviceAdmin() async {
    try {
      await _channel.invokeMethod('requestDeviceAdmin');
    } catch (_) {}
  }

  /// Check overlay permission
  static Future<bool> isOverlayPermissionGranted() async {
    try {
      return await _channel.invokeMethod('isOverlayPermissionGranted') ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Request overlay permission
  static Future<void> requestOverlayPermission() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (_) {}
  }

  /// Get all service statuses at once
  static Future<Map<String, bool>> getServiceStatus() async {
    try {
      final result = await _channel.invokeMethod('getServiceStatus');
      return Map<String, bool>.from(result as Map);
    } catch (e) {
      return {
        'accessibility': false,
        'usageStats': false,
        'deviceAdmin': false,
        'overlay': false,
      };
    }
  }
}
