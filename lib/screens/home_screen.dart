import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/native_bridge.dart';
import '../services/storage_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import 'app_selection_screen.dart';
import 'pin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  bool _blockingEnabled = false;
  List<String> _blockedApps = [];
  Map<String, String> _blockedAppNames = {};
  Map<String, bool> _serviceStatus = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final status = await NativeBridge.getServiceStatus();
    if (mounted) {
      setState(() {
        _blockingEnabled = StorageService.isBlockingEnabled();
        _blockedApps = StorageService.getBlockedApps();
        _blockedAppNames = StorageService.getBlockedAppNames();
        _serviceStatus = status;
      });
    }
  }

  void _toggleBlocking(bool enabled) async {
    HapticFeedback.mediumImpact();
    await StorageService.setBlockingEnabled(enabled);
    setState(() {
      _blockingEnabled = enabled;
    });
  }

  Future<void> _navigateToAppSelection() async {
    // Show loading overlay
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFFFF3B3B),
                strokeWidth: 3,
              ),
              const SizedBox(height: 18),
              const Text(
                'Loading apps...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Small delay to let the dialog show, then navigate
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    Navigator.pop(context); // dismiss loading dialog

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AppSelectionScreen(),
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final allPermsGranted = _serviceStatus.values.every((v) => v);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A0A0A),
              Color(0xFF0D0D0D),
              Color(0xFF0D0D0D),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            color: const Color(0xFFFF3B3B),
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: [
                const SizedBox(height: 8),
                // App header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.shield, size: 28, color: Color(0xFFFF3B3B)),
                      const SizedBox(width: 12),
                      const Text(
                        'Device Hub',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _showSettingsMenu,
                        icon: const Icon(Icons.more_vert,
                            color: Colors.white54, size: 24),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Main status card
                GlassCard(
                  borderColor: _blockingEnabled
                      ? const Color(0xFFFF3B3B).withOpacity(0.3)
                      : Colors.white.withOpacity(0.1),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Status indicator
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _blockingEnabled
                                  ? const Color(0xFFFF3B3B).withOpacity(0.15)
                                  : Colors.white.withOpacity(0.05),
                              boxShadow: _blockingEnabled
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFFF3B3B)
                                            .withOpacity(0.2),
                                        blurRadius: 20,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              _blockingEnabled
                                  ? Icons.shield
                                  : Icons.shield_outlined,
                              color: _blockingEnabled
                                  ? const Color(0xFFFF3B3B)
                                  : Colors.white30,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _blockingEnabled
                                      ? 'Protection Active'
                                      : 'Protection Disabled',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: _blockingEnabled
                                        ? Colors.white
                                        : Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _blockingEnabled
                                      ? '${_blockedApps.length} app${_blockedApps.length != 1 ? 's' : ''} being blocked'
                                      : 'Tap to enable app blocking',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.white.withOpacity(0.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Toggle switch
                          Switch(
                            value: _blockingEnabled,
                            onChanged: _toggleBlocking,
                            activeColor: const Color(0xFFFF3B3B),
                            activeTrackColor:
                                const Color(0xFFFF3B3B).withOpacity(0.3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Service status warnings
                if (!allPermsGranted) ...[
                  GlassCard(
                    borderColor: const Color(0xFFFF6B35).withOpacity(0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.warning_amber,
                                color: Color(0xFFFF6B35), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Setup Required',
                              style: TextStyle(
                                color: Color(0xFFFF6B35),
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPermissionStatus(
                          'Accessibility Service',
                          _serviceStatus['accessibility'] ?? false,
                          () => NativeBridge.openAccessibilitySettings(),
                        ),
                        _buildPermissionStatus(
                          'Device Admin',
                          _serviceStatus['deviceAdmin'] ?? false,
                          () => NativeBridge.requestDeviceAdmin(),
                        ),
                      ],
                    ),
                  ),
                ],

                // Blocked apps list
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    children: [
                      Text(
                        'BLOCKED APPS',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _navigateToAppSelection(),
                        child: const Row(
                          children: [
                            Icon(Icons.edit,
                                color: Color(0xFFFF3B3B), size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Edit',
                              style: TextStyle(
                                color: Color(0xFFFF3B3B),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (_blockedApps.isEmpty)
                  GlassCard(
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.apps,
                              size: 40,
                              color: Colors.white.withOpacity(0.15)),
                          const SizedBox(height: 12),
                          Text(
                            'No apps blocked yet',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GradientButton(
                            text: 'Select Apps',
                            icon: Icons.add,
                            width: 180,
                            onPressed: () => _navigateToAppSelection(),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._blockedApps.map((pkg) {
                    final name = _blockedAppNames[pkg] ?? pkg;
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: const Color(0xFFFF3B3B).withOpacity(0.15),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 2),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3B3B).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.block,
                            color: Color(0xFFFF3B3B),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          pkg,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.25),
                            fontSize: 11,
                          ),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF3B3B).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'BLOCKED',
                            style: TextStyle(
                              color: Color(0xFFFF3B3B),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionStatus(
      String name, bool isGranted, VoidCallback onFix) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isGranted ? Icons.check_circle : Icons.cancel_outlined,
            size: 18,
            color: isGranted ? const Color(0xFF4CAF50) : const Color(0xFFFF3B3B),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ),
          if (!isGranted)
            GestureDetector(
              onTap: onFix,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Fix',
                  style: TextStyle(
                    color: Color(0xFFFF6B35),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            _buildSettingsItem(
              Icons.lock_outline,
              'Change PIN',
              'Update your security PIN',
              () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PinScreen(mode: PinMode.change),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              Icons.apps,
              'Manage Blocked Apps',
              'Add or remove apps from the block list',
              () {
                Navigator.pop(context);
                _navigateToAppSelection();
              },
            ),
            _buildSettingsItem(
              Icons.accessibility_new,
              'Check Permissions',
              'Verify all permissions are active',
              () {
                Navigator.pop(context);
                _loadData();
              },
            ),
            const SizedBox(height: 20),
            // ── GlaceYT Branding ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF7C3AED).withOpacity(0.15),
                    const Color(0xFF3B82F6).withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF7C3AED).withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Made with ❤️ by',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'GlaceYT | SHIVA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        Icons.play_circle_filled,
                        'YouTube',
                        const Color(0xFFFF0000),
                        'https://www.youtube.com/@GlaceYT',
                      ),
                      const SizedBox(width: 12),
                      _buildSocialButton(
                        Icons.discord,
                        'Discord',
                        const Color(0xFF5865F2),
                        'https://discord.gg/xQF9f9yUEM',
                      ),
                      const SizedBox(width: 12),
                      _buildSocialButton(
                        Icons.payment,
                        'Support',
                        const Color(0xFF0070BA),
                        'https://paypal.me/GlaceYT',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Device Hub v1.0',
              style: TextStyle(
                color: Colors.white.withOpacity(0.2),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsItem(
      IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white70, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 12,
        ),
      ),
      trailing: Icon(Icons.chevron_right,
          color: Colors.white.withOpacity(0.3), size: 20),
    );
  }

  Widget _buildSocialButton(
      IconData icon, String label, Color color, String url) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
