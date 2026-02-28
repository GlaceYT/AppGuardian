import 'dart:typed_data';
import 'dart:convert';

class AppInfo {
  final String packageName;
  final String appName;
  final bool isSystemApp;
  final Uint8List? iconBytes;

  AppInfo({
    required this.packageName,
    required this.appName,
    required this.isSystemApp,
    this.iconBytes,
  });

  factory AppInfo.fromMap(Map<dynamic, dynamic> map) {
    Uint8List? icon;
    if (map['icon'] != null) {
      try {
        icon = base64Decode(map['icon'] as String);
      } catch (_) {}
    }
    return AppInfo(
      packageName: map['packageName'] as String,
      appName: map['appName'] as String,
      isSystemApp: map['isSystemApp'] as bool? ?? false,
      iconBytes: icon,
    );
  }
}
