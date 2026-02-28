import 'package:flutter/material.dart';
import '../services/native_bridge.dart';
import '../services/storage_service.dart';
import '../widgets/gradient_button.dart';
import '../widgets/glass_card.dart';
import 'pin_screen.dart';
import 'app_selection_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _currentStep = 0;
  Map<String, bool> _permissions = {
    'accessibility': false,
    'usageStats': false,
    'deviceAdmin': false,
    'overlay': false,
  };

  final List<_SetupStep> _steps = [
    _SetupStep(
      icon: Icons.shield_outlined,
      title: 'Welcome to Device Hub',
      description:
          'This app helps you block access to harmful apps like gambling apps. '
          'Let\'s set up the required permissions.',
      buttonText: 'Get Started',
    ),
    _SetupStep(
      icon: Icons.accessibility_new,
      title: 'Accessibility Service',
      description:
          'This is the core engine. It detects when a blocked app is opened '
          'and instantly shows a blocking screen.\n\n'
          'Find "Device Hub" in the list and enable it.',
      buttonText: 'Open Settings',
      permissionKey: 'accessibility',
    ),
    _SetupStep(
      icon: Icons.admin_panel_settings,
      title: 'Device Admin',
      description:
          'This prevents the app from being easily uninstalled. '
          'The person you\'re protecting won\'t be able to remove the app without the PIN.',
      buttonText: 'Activate Admin',
      permissionKey: 'deviceAdmin',
    ),
    _SetupStep(
      icon: Icons.lock_outline,
      title: 'Set Your PIN',
      description:
          'Create a 4-digit PIN to protect the app settings. '
          'Only you will be able to change blocked apps or disable the blocker.',
      buttonText: 'Create PIN',
    ),
    _SetupStep(
      icon: Icons.apps,
      title: 'Select Apps to Block',
      description:
          'Choose which apps to block. You can search for gambling apps '
          'like TeenPatti, Rummy, Poker, etc.',
      buttonText: 'Select Apps',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _refreshPermissions();
  }

  Future<void> _refreshPermissions() async {
    final status = await NativeBridge.getServiceStatus();
    if (mounted) {
      setState(() {
        _permissions = status;
      });
    }
  }

  Future<void> _handleStepAction() async {
    switch (_currentStep) {
      case 0: // Welcome
        _nextStep();
        break;
      case 1: // Accessibility
        await NativeBridge.openAccessibilitySettings();
        // Wait for user to come back
        await Future.delayed(const Duration(seconds: 1));
        _waitForPermission('accessibility');
        break;
      case 2: // Device Admin
        await NativeBridge.requestDeviceAdmin();
        await Future.delayed(const Duration(seconds: 1));
        _waitForPermission('deviceAdmin');
        break;
      case 3: // PIN
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const PinScreen(mode: PinMode.create),
          ),
        );
        // If PIN was created, move to next step
        if (StorageService.hasPin()) {
          _nextStep();
        }
        break;
      case 4: // App Selection
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const AppSelectionScreen(isSetup: true),
          ),
        );
        // Complete setup
        if (StorageService.getBlockedApps().isNotEmpty) {
          await StorageService.setBlockingEnabled(true);
          await StorageService.setSetupCompleted();
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const PinScreen(mode: PinMode.verify),
            ),
          );
        }
        break;
    }
  }

  void _waitForPermission(String key) {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 500));
      await _refreshPermissions();
      if (_permissions[key] == true) {
        _nextStep();
        return false;
      }
      return mounted;
    });
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];

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
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Step indicator
                Row(
                  children: List.generate(_steps.length, (index) {
                    final isActive = index == _currentStep;
                    final isDone = index < _currentStep;
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: isDone
                              ? const Color(0xFFFF3B3B)
                              : isActive
                                  ? const Color(0xFFFF3B3B).withOpacity(0.6)
                                  : Colors.white.withOpacity(0.1),
                        ),
                      ),
                    );
                  }),
                ),
                const Spacer(flex: 2),
                // Step icon
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    key: ValueKey(_currentStep),
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFFF3B3B).withOpacity(0.2),
                          const Color(0xFFFF3B3B).withOpacity(0.05),
                        ],
                      ),
                    ),
                    child: Icon(
                      step.icon,
                      size: 48,
                      color: const Color(0xFFFF3B3B),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Title
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    step.title,
                    key: ValueKey('title_$_currentStep'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    step.description,
                    key: ValueKey('desc_$_currentStep'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.55),
                      height: 1.5,
                    ),
                  ),
                ),
                const Spacer(flex: 2),
                // Permission status (if applicable)
                if (step.permissionKey != null) ...[
                  GlassCard(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    borderColor: _permissions[step.permissionKey] == true
                        ? const Color(0xFF4CAF50).withOpacity(0.5)
                        : null,
                    child: Row(
                      children: [
                        Icon(
                          _permissions[step.permissionKey] == true
                              ? Icons.check_circle
                              : Icons.pending,
                          color: _permissions[step.permissionKey] == true
                              ? const Color(0xFF4CAF50)
                              : Colors.white38,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _permissions[step.permissionKey] == true
                              ? 'Permission granted ✓'
                              : 'Waiting for permission...',
                          style: TextStyle(
                            color: _permissions[step.permissionKey] == true
                                ? const Color(0xFF4CAF50)
                                : Colors.white54,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // Action button
                GradientButton(
                  text: _permissions[step.permissionKey] == true
                      ? 'Continue'
                      : step.buttonText,
                  icon: _currentStep == 0 ? Icons.arrow_forward : null,
                  onPressed: () {
                    if (_permissions[step.permissionKey] == true) {
                      _nextStep();
                    } else {
                      _handleStepAction();
                    }
                  },
                ),
                const SizedBox(height: 16),
                // Skip button (for optional permissions)
                if (_currentStep == 2)
                  TextButton(
                    onPressed: _nextStep,
                    child: Text(
                      'Skip for now',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SetupStep {
  final IconData icon;
  final String title;
  final String description;
  final String buttonText;
  final String? permissionKey;

  const _SetupStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonText,
    this.permissionKey,
  });
}
