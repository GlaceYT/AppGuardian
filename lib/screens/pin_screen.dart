import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import 'home_screen.dart';

enum PinMode { create, verify, change }

class PinScreen extends StatefulWidget {
  final PinMode mode;

  const PinScreen({super.key, required this.mode});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> with TickerProviderStateMixin {
  String _pin = '';
  String _confirmPin = '';
  bool _isConfirming = false;
  String _error = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.mode) {
      case PinMode.create:
        return _isConfirming ? 'Confirm PIN' : 'Create PIN';
      case PinMode.verify:
        return 'Enter PIN';
      case PinMode.change:
        return _isConfirming ? 'Confirm New PIN' : 'Enter New PIN';
    }
  }

  String get _subtitle {
    switch (widget.mode) {
      case PinMode.create:
        return _isConfirming
            ? 'Re-enter your 4-digit PIN'
            : 'Set a 4-digit PIN to protect settings';
      case PinMode.verify:
        return 'Enter your PIN to access Device Hub';
      case PinMode.change:
        return _isConfirming
            ? 'Re-enter your new PIN'
            : 'Enter a new 4-digit PIN';
    }
  }

  void _onDigitPressed(String digit) {
    HapticFeedback.lightImpact();
    if (_pin.length >= 4) return;

    setState(() {
      _pin += digit;
      _error = '';
    });

    if (_pin.length == 4) {
      _handlePinComplete();
    }
  }

  void _onBackspace() {
    HapticFeedback.lightImpact();
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _error = '';
    });
  }

  void _handlePinComplete() {
    switch (widget.mode) {
      case PinMode.create:
      case PinMode.change:
        if (!_isConfirming) {
          _confirmPin = _pin;
          setState(() {
            _isConfirming = true;
            _pin = '';
          });
        } else {
          if (_pin == _confirmPin) {
            StorageService.setPin(_pin);
            if (widget.mode == PinMode.change) {
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PIN changed successfully'),
                  backgroundColor: Color(0xFF2E7D32),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            }
          } else {
            _triggerError('PINs do not match. Try again.');
            setState(() {
              _isConfirming = false;
              _confirmPin = '';
            });
          }
        }
        break;
      case PinMode.verify:
        if (_pin == StorageService.getPin()) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const HomeScreen(),
              transitionsBuilder: (_, anim, __, child) {
                return FadeTransition(opacity: anim, child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        } else {
          _triggerError('Wrong PIN. Try again.');
        }
        break;
    }
  }

  void _triggerError(String message) {
    HapticFeedback.heavyImpact();
    _shakeController.forward(from: 0);
    setState(() {
      _error = message;
      _pin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              const Spacer(flex: 2),
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF3B3B).withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: Color(0xFFFF3B3B),
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                _title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 40),
              // PIN dots
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  final shake = _shakeAnimation.value;
                  return Transform.translate(
                    offset: Offset(
                      shake * 20 * (shake > 0.5 ? -1 : 1) * (1 - shake),
                      0,
                    ),
                    child: child,
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isFilled = index < _pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
                      width: isFilled ? 20 : 16,
                      height: isFilled ? 20 : 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled
                            ? const Color(0xFFFF3B3B)
                            : Colors.transparent,
                        border: Border.all(
                          color: isFilled
                              ? const Color(0xFFFF3B3B)
                              : Colors.white24,
                          width: 2,
                        ),
                        boxShadow: isFilled
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFFFF3B3B).withOpacity(0.4),
                                  blurRadius: 8,
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),
              // Error text
              AnimatedOpacity(
                opacity: _error.isNotEmpty ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _error,
                  style: const TextStyle(
                    color: Color(0xFFFF3B3B),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(flex: 1),
              // Number pad
              _buildNumberPad(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPad() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['1', '2', '3'].map(_buildKey).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['4', '5', '6'].map(_buildKey).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['7', '8', '9'].map(_buildKey).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(width: 72, height: 72),
              _buildKey('0'),
              _buildBackspaceKey(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String digit) {
    return GestureDetector(
      onTap: () => _onDigitPressed(digit),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.06),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        child: Center(
          child: Text(
            digit,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return GestureDetector(
      onTap: _onBackspace,
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.white.withOpacity(0.5),
            size: 26,
          ),
        ),
      ),
    );
  }
}
