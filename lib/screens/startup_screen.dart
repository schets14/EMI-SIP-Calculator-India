import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF101735),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF101735), Color(0xFF171B48), Color(0xFF101735)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -100,
                right: -90,
                child: _glow(const Color(0xFF5B5FEF), 260),
              ),
              Positioned(
                bottom: -120,
                left: -100,
                child: _glow(const Color(0xFF10B981), 280),
              ),
              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 190,
                        height: 190,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            RotationTransition(
                              turns: _controller,
                              child: CustomPaint(
                                size: const Size.square(184),
                                painter: _OrbitPainter(),
                              ),
                            ),
                            ScaleTransition(
                              scale: Tween<double>(begin: .94, end: 1.04).animate(
                                CurvedAnimation(
                                  parent: _controller,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                              child: Container(
                                width: 118,
                                height: 118,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(36),
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Color(0xFF676BFF), Color(0xFF793DF0)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6865FF).withValues(alpha: .38),
                                      blurRadius: 38,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.calculate_rounded,
                                  color: Colors.white,
                                  size: 62,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 8,
                              bottom: 27,
                              child: _floatingBadge(
                                Icons.trending_up_rounded,
                                const Color(0xFF10D7A0),
                              ),
                            ),
                            Positioned(
                              left: 10,
                              top: 28,
                              child: _floatingBadge(
                                Icons.currency_rupee_rounded,
                                const Color(0xFFFFC857),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 34),
                      const Text(
                        'FinCalc',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.7,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Your money, planned smarter',
                        style: TextStyle(
                          color: Color(0xFFB8BED9),
                          fontSize: 14,
                          letterSpacing: .2,
                        ),
                      ),
                      const SizedBox(height: 34),
                      _LoadingDots(controller: _controller),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glow(Color color, double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: .13), blurRadius: 100, spreadRadius: 35),
          ],
        ),
      );

  Widget _floatingBadge(IconData icon, Color color) => Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF20264E),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withValues(alpha: .16)),
          boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 15)],
        ),
        child: Icon(icon, color: color, size: 22),
      );
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.controller});

  final Animation<double> controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          final wave = math.sin((controller.value * math.pi * 2) - index * .8);
          return Container(
            width: 7 + (wave + 1) * 2,
            height: 7 + (wave + 1) * 2,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .35 + ((wave + 1) * .3)),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0x006E77FF),
          Color(0xAA6E77FF),
          Color(0xFF36DDB5),
          Color(0x006E77FF),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(size.center(Offset.zero), size.width / 2 - 5, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) => false;
}