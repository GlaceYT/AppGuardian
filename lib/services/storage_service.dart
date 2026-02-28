import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) throw Exception('StorageService not initialized');
    return _prefs!;
  }

  // PIN Management
  static Future<void> setPin(String pin) async {
    await prefs.setString('user_pin', pin);
  }

  static String? getPin() {
    return prefs.getString('user_pin');
  }

  static bool hasPin() {
    return prefs.getString('user_pin') != null;
  }

  // Blocked Apps Management
  static Future<void> setBlockedApps(List<String> packages) async {
    // Save as comma-separated for native side to read
    await prefs.setString('blocked_apps', packages.join(','));
    // Also save as string list for Dart side
    await prefs.setStringList('blocked_apps_list', packages);
  }

  static List<String> getBlockedApps() {
    return prefs.getStringList('blocked_apps_list') ?? [];
  }

  // Blocking enabled/disabled
  static Future<void> setBlockingEnabled(bool enabled) async {
    await prefs.setBool('blocking_enabled', enabled);
  }

  static bool isBlockingEnabled() {
    return prefs.getBool('blocking_enabled') ?? false;
  }

  // First launch
  static bool isFirstLaunch() {
    return prefs.getBool('setup_completed') != true;
  }

  static Future<void> setSetupCompleted() async {
    await prefs.setBool('setup_completed', true);
  }

  // Blocked app names (for display)
  static Future<void> setBlockedAppNames(Map<String, String> names) async {
    final entries = names.entries.map((e) => '${e.key}::${e.value}').toList();
    await prefs.setStringList('blocked_app_names', entries);
  }

  static Map<String, String> getBlockedAppNames() {
    final entries = prefs.getStringList('blocked_app_names') ?? [];
    final map = <String, String>{};
    for (final entry in entries) {
      final parts = entry.split('::');
      if (parts.length == 2) {
        map[parts[0]] = parts[1];
      }
    }
    return map;
  }
}
