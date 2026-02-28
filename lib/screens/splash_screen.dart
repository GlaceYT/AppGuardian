import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import 'pin_screen.dart';
import 'setup_screen.dart';
import 'home_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DECOY: Professional device performance tips screen
// The real app opens when the user LONG-PRESSES the "Device Hub" header
// or taps the logo 5 times quickly
// ─────────────────────────────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;
  bool _initialized = false;

  // Secret tap counter
  int _secretTapCount = 0;
  DateTime? _lastTap;

  bool _isLoading = true;
  int _currentTipPage = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _initApp();
  }

  Future<void> _initApp() async {
    await StorageService.init();
    setState(() => _initialized = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() => _isLoading = false);
      _fadeCtrl.forward();
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ── Secret: long press on the header ──
  void _onLogoLongPress() {
    HapticFeedback.heavyImpact();
    _navigateToRealApp();
  }

  // ── Secondary secret: tap logo 5 times quickly ──
  void _onLogoTap() {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!).inSeconds > 2) {
      _secretTapCount = 0;
    }
    _lastTap = now;
    _secretTapCount++;
    if (_secretTapCount >= 5) {
      _secretTapCount = 0;
      HapticFeedback.heavyImpact();
      _navigateToRealApp();
    }
  }

  void _navigateToRealApp() {
    Widget destination;
    if (StorageService.isFirstLaunch()) {
      destination = const SetupScreen();
    } else if (StorageService.hasPin()) {
      destination = const PinScreen(mode: PinMode.verify);
    } else {
      destination = const HomeScreen();
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => destination,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? _buildLoadingScreen()
          : FadeTransition(opacity: _fadeAnim, child: _buildMainUI()),
    );
  }

  // ── Loading screen ──
  Widget _buildLoadingScreen() {
    return Container(
      color: const Color(0xFFF5F7FA),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _onLogoTap,
              onLongPress: _onLogoLongPress,
              child: Image.asset('assets/logo.png', width: 80, height: 80),
            ),
            const SizedBox(height: 24),
            const Text(
              'Device Hub',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                    AlwaysStoppedAnimation<Color>(Color(0xFF4A90D9)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main tips UI ──
  Widget _buildMainUI() {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const ClampingScrollPhysics(),
              children: [
                const SizedBox(height: 8),
                _buildHealthCard(),
                const SizedBox(height: 16),
                _buildQuickActions(),
                const SizedBox(height: 20),
                _buildTipsSection(),
                const SizedBox(height: 20),
                _buildStorageCard(),
                const SizedBox(height: 20),
                _buildBatteryTips(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Header with secret tap zone ──
  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7FA),
      ),
      child: Row(
        children: [
          // SECRET TAP ZONE
          GestureDetector(
            onTap: _onLogoTap,
            onLongPress: _onLogoLongPress,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Image.asset('assets/logo.png', width: 36, height: 36),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Hub',
                      style: TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Smart tips for your device',
                      style: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.notifications_outlined,
                color: Color(0xFF757575), size: 22),
          ),
        ],
      ),
    );
  }

  // ── Device health summary card ──
  Widget _buildHealthCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4A90D9), Color(0xFF357ABD)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4A90D9).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Device Status',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Your device is running smoothly',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatPill('CPU', '12%', Icons.memory),
              const SizedBox(width: 10),
              _buildStatPill('RAM', '3.2 GB', Icons.storage),
              const SizedBox(width: 10),
              _buildStatPill('Temp', '32°C', Icons.thermostat),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick action buttons ──
  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.cleaning_services_outlined, 'label': 'Clean', 'color': const Color(0xFF4CAF50)},
      {'icon': Icons.speed, 'label': 'Boost', 'color': const Color(0xFFFF9800)},
      {'icon': Icons.battery_charging_full, 'label': 'Battery', 'color': const Color(0xFF2196F3)},
      {'icon': Icons.security, 'label': 'Scan', 'color': const Color(0xFF9C27B0)},
    ];

    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: (a['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(a['icon'] as IconData,
                      color: a['color'] as Color, size: 26),
                ),
                const SizedBox(height: 8),
                Text(
                  a['label'] as String,
                  style: const TextStyle(
                    color: Color(0xFF616161),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Performance tips ──
  Widget _buildTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Performance Tips',
            style: TextStyle(
              color: Color(0xFF1A1A2E),
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        ..._tips.map((tip) => _buildTipCard(tip)),
      ],
    );
  }

  Widget _buildTipCard(_Tip tip) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: tip.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(tip.icon, color: tip.color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tip.title,
                  style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tip.subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right,
              color: Color(0xFFBDBDBD), size: 20),
        ],
      ),
    );
  }

  // ── Storage card ──
  Widget _buildStorageCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.folder_outlined, color: Color(0xFF4A90D9), size: 22),
              SizedBox(width: 10),
              Text(
                'Storage Overview',
                style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.62,
              minHeight: 8,
              backgroundColor: const Color(0xFFE8E8E8),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF4A90D9)),
            ),
          ),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Used: 79.4 GB',
                  style: TextStyle(color: Color(0xFF757575), fontSize: 12)),
              Text('Total: 128 GB',
                  style: TextStyle(color: Color(0xFF757575), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Battery tips ──
  Widget _buildBatteryTips() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.battery_std, color: Color(0xFF4CAF50), size: 22),
              SizedBox(width: 10),
              Text(
                'Battery Tips',
                style: TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildBatteryTip(
              'Reduce screen brightness to save up to 30% battery'),
          _buildBatteryTip(
              'Turn off Wi-Fi and Bluetooth when not in use'),
          _buildBatteryTip(
              'Close unused background apps regularly'),
          _buildBatteryTip(
              'Enable power saving mode for extended usage'),
        ],
      ),
    );
  }

  Widget _buildBatteryTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.circle, color: Color(0xFF4CAF50), size: 6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF616161),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Tip data ──
  static final _tips = [
    _Tip(
      'Clear Cache Regularly',
      'Free up space by clearing app cache data',
      Icons.cached,
      const Color(0xFF4CAF50),
    ),
    _Tip(
      'Update Your Apps',
      'Keep apps updated for best performance',
      Icons.system_update,
      const Color(0xFF2196F3),
    ),
    _Tip(
      'Manage Notifications',
      'Disable unnecessary notifications to save battery',
      Icons.notifications_off_outlined,
      const Color(0xFFFF9800),
    ),
    _Tip(
      'Restart Weekly',
      'A weekly restart helps clear memory leaks',
      Icons.restart_alt,
      const Color(0xFF9C27B0),
    ),
    _Tip(
      'Use Dark Mode',
      'Dark mode saves battery on OLED displays',
      Icons.dark_mode_outlined,
      const Color(0xFF607D8B),
    ),
  ];
}

class _Tip {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _Tip(this.title, this.subtitle, this.icon, this.color);
}
