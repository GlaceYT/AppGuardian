import 'package:flutter/material.dart';
import '../models/app_info.dart';
import '../services/native_bridge.dart';
import '../services/storage_service.dart';
import '../widgets/app_tile.dart';
import '../widgets/gradient_button.dart';

class AppSelectionScreen extends StatefulWidget {
  final bool isSetup;

  const AppSelectionScreen({super.key, this.isSetup = false});

  @override
  State<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends State<AppSelectionScreen> {
  List<AppInfo> _allApps = [];
  List<AppInfo> _filteredApps = [];
  Set<String> _selectedPackages = {};
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  bool _showSystemApps = false;

  // Known gambling app package patterns
  static const _gamblingKeywords = [
    'teenpatti',
    'teen_patti',
    'rummy',
    'poker',
    'casino',
    'betting',
    'gambl',
    'slots',
    'satta',
    'matka',
    'dream11',
    'stake',
    'betway',
    'winzo',
    'mpl',
    'zupee',
    'ludo',
    'paytm first games',
    'getmega',
    'adda52',
    'pokerbaazi',
    'junglee',
    'spartan',
    'a23',
  ];

  @override
  void initState() {
    super.initState();
    _loadApps();
    _selectedPackages = StorageService.getBlockedApps().toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadApps() async {
    final apps = await NativeBridge.getInstalledApps();
    if (mounted) {
      setState(() {
        _allApps = apps;
        _filterApps();
        _isLoading = false;
      });
    }
  }

  void _filterApps() {
    final query = _searchController.text.toLowerCase();
    _filteredApps = _allApps.where((app) {
      if (!_showSystemApps && app.isSystemApp) return false;
      if (query.isEmpty) return true;
      return app.appName.toLowerCase().contains(query) ||
          app.packageName.toLowerCase().contains(query);
    }).toList();
  }

  bool _isLikelyGamblingApp(AppInfo app) {
    final name = app.appName.toLowerCase();
    final pkg = app.packageName.toLowerCase();
    return _gamblingKeywords.any((kw) => name.contains(kw) || pkg.contains(kw));
  }

  void _toggleApp(String packageName) {
    setState(() {
      if (_selectedPackages.contains(packageName)) {
        _selectedPackages.remove(packageName);
      } else {
        _selectedPackages.add(packageName);
      }
    });
  }

  Future<void> _saveSelection() async {
    final selectedApps = _selectedPackages.toList();
    await StorageService.setBlockedApps(selectedApps);

    // Save app names for display
    final nameMap = <String, String>{};
    for (final pkg in selectedApps) {
      final app = _allApps.firstWhere(
        (a) => a.packageName == pkg,
        orElse: () => AppInfo(packageName: pkg, appName: pkg, isSystemApp: false),
      );
      nameMap[pkg] = app.appName;
    }
    await StorageService.setBlockedAppNames(nameMap);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gambling = _filteredApps.where(_isLikelyGamblingApp).toList();
    final others = _filteredApps.where((a) => !_isLikelyGamblingApp(a)).toList();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0A0A),
              Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    if (!widget.isSetup)
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white70, size: 20),
                      ),
                    const Expanded(
                      child: Text(
                        'Select Apps to Block',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF3B3B).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_selectedPackages.length} selected',
                        style: const TextStyle(
                          color: Color(0xFFFF3B3B),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Search bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.08),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() => _filterApps()),
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Search apps...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close,
                                  color: Colors.white.withOpacity(0.3)),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _filterApps());
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // System apps toggle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Show system apps',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 28,
                      child: Switch(
                        value: _showSystemApps,
                        onChanged: (v) {
                          setState(() {
                            _showSystemApps = v;
                            _filterApps();
                          });
                        },
                        activeColor: const Color(0xFFFF3B3B),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // App list
              Expanded(
                child: _isLoading
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              color: Color(0xFFFF3B3B),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Loading installed apps...',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'This may take a moment',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.25),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : _filteredApps.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off,
                                    size: 48,
                                    color: Colors.white.withOpacity(0.2)),
                                const SizedBox(height: 12),
                                Text(
                                  'No apps found',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: const EdgeInsets.only(bottom: 100),
                            children: [
                              // Suggested gambling apps section
                              if (gambling.isNotEmpty &&
                                  _searchController.text.isEmpty) ...[
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      20, 8, 20, 4),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF6B35)
                                              .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.warning_amber,
                                                size: 14,
                                                color: Color(0xFFFF6B35)),
                                            SizedBox(width: 6),
                                            Text(
                                              'SUGGESTED TO BLOCK',
                                              style: TextStyle(
                                                color: Color(0xFFFF6B35),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...gambling.map((app) => AppTile(
                                      appName: app.appName,
                                      packageName: app.packageName,
                                      icon: app.iconBytes != null
                                          ? Image.memory(app.iconBytes!,
                                              fit: BoxFit.cover)
                                          : null,
                                      isSelected: _selectedPackages
                                          .contains(app.packageName),
                                      onTap: () =>
                                          _toggleApp(app.packageName),
                                    )),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      20, 8, 20, 4),
                                  child: Text(
                                    'ALL APPS',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.3),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ],
                              // All other apps
                              ...others.map((app) => AppTile(
                                    appName: app.appName,
                                    packageName: app.packageName,
                                    icon: app.iconBytes != null
                                        ? Image.memory(app.iconBytes!,
                                            fit: BoxFit.cover)
                                        : null,
                                    isSelected: _selectedPackages
                                        .contains(app.packageName),
                                    onTap: () =>
                                        _toggleApp(app.packageName),
                                  )),
                            ],
                          ),
              ),
              // Bottom save button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0D0D0D).withOpacity(0),
                      const Color(0xFF0D0D0D),
                    ],
                  ),
                ),
                child: GradientButton(
                  text: _selectedPackages.isEmpty
                      ? 'Select apps to continue'
                      : 'Block ${_selectedPackages.length} App${_selectedPackages.length > 1 ? 's' : ''}',
                  icon: Icons.shield,
                  onPressed: _selectedPackages.isEmpty
                      ? () {}
                      : _saveSelection,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
