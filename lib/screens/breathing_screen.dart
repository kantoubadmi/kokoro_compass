import 'package:flutter/material.dart';
import 'dart:async';

class BreathingScreen extends StatefulWidget {
  const BreathingScreen({super.key});

  @override
  State<BreathingScreen> createState() => _BreathingScreenState();
}

class _BreathingScreenState extends State<BreathingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isActive = false;
  String _phase = '準備';
  int _cycleCount = 0;
  Timer? _phaseTimer;

  // Breathing pattern: inhale 4s, hold 4s, exhale 4s, hold 2s
  final int _inhaleSeconds = 4;
  final int _holdAfterInhaleSeconds = 4;
  final int _exhaleSeconds = 4;
  final int _holdAfterExhaleSeconds = 2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: _inhaleSeconds),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _phaseTimer?.cancel();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _cycleCount = 0;
    });
    _runBreathingCycle();
  }

  void _stopBreathing() {
    _phaseTimer?.cancel();
    _controller.stop();
    _controller.reset();
    setState(() {
      _isActive = false;
      _phase = '準備';
    });
  }

  void _runBreathingCycle() {
    // Phase 1: Inhale
    setState(() => _phase = '吸う');
    _controller.duration = Duration(seconds: _inhaleSeconds);
    _controller.forward(from: 0);

    _phaseTimer = Timer(Duration(seconds: _inhaleSeconds), () {
      if (!_isActive) return;

      // Phase 2: Hold after inhale
      setState(() => _phase = '止める');
      _phaseTimer = Timer(Duration(seconds: _holdAfterInhaleSeconds), () {
        if (!_isActive) return;

        // Phase 3: Exhale
        setState(() => _phase = '吐く');
        _controller.duration = Duration(seconds: _exhaleSeconds);
        _controller.reverse(from: 1);

        _phaseTimer = Timer(Duration(seconds: _exhaleSeconds), () {
          if (!_isActive) return;

          // Phase 4: Hold after exhale
          setState(() => _phase = '止める');
          _phaseTimer = Timer(Duration(seconds: _holdAfterExhaleSeconds), () {
            if (!_isActive) return;

            setState(() => _cycleCount++);
            _runBreathingCycle(); // Repeat
          });
        });
      });
    });
  }

  Color _getPhaseColor() {
    switch (_phase) {
      case '吸う':
        return const Color(0xFF7B9E89);
      case '吐く':
        return const Color(0xFFA8C5B0);
      case '止める':
        return const Color(0xFF9EADC5);
      default:
        return const Color(0xFFD4A5A5);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('呼吸エクササイズ'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Instructions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        '4-4-4-2 呼吸法',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '吸う(4秒) → 止める(4秒) → 吐く(4秒) → 止める(2秒)',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Breathing animation
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Phase text
                    Text(
                      _phase,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _getPhaseColor(),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Animated circle
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Container(
                          width: 200 * _scaleAnimation.value,
                          height: 200 * _scaleAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getPhaseColor()
                                .withValues(alpha: _opacityAnimation.value),
                            boxShadow: [
                              BoxShadow(
                                color: _getPhaseColor().withValues(alpha: 0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                              child: Icon(
                                _phase == '吸う'
                                    ? Icons.arrow_downward
                                    : _phase == '吐く'
                                        ? Icons.arrow_upward
                                        : Icons.pause,
                                size: 40,
                                color: _getPhaseColor(),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Cycle count
                    if (_isActive)
                      Text(
                        'サイクル: $_cycleCount',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Control button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isActive ? _stopBreathing : _startBreathing,
                  icon: Icon(_isActive ? Icons.stop : Icons.play_arrow),
                  label: Text(_isActive ? '停止' : '開始'),
                  style: FilledButton.styleFrom(
                    backgroundColor:
                        _isActive ? Colors.red.shade400 : const Color(0xFF7B9E89),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
