import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/cosmic_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Timer _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _navigationTimer = Timer(const Duration(milliseconds: 1700), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _navigationTimer.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splash,
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (_, _) =>
                CustomPaint(painter: _SpacePainter(_controller.value)),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                const CosmicLogo(size: 128),
                const SizedBox(height: 24),
                Text.rich(
                  const TextSpan(
                    style: TextStyle(
                      fontSize: 43,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -.8,
                    ),
                    children: [
                      TextSpan(
                        text: 'Qeon ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'AI',
                        style: TextStyle(color: Color(0xFFFFC24F)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your Personal AI Companion',
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Intelligent. Personalized. Limitless.',
                  style: TextStyle(color: Color(0xFFB8B9CC)),
                ),
                const Spacer(),
                const Text(
                  'Built for clarity.\nDesigned for you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFCACBDD), height: 1.5),
                ),
                const SizedBox(height: 44),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpacePainter extends CustomPainter {
  _SpacePainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .5, size.height * .72);
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFF8F3E).withValues(alpha: .7),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * .55));
    canvas.drawCircle(center, size.width * .55, glow);

    final orbit = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFAB45), Color(0xFF7A3BFF), Colors.transparent],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (var i = 0; i < 4; i++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(progress * math.pi * 2 + i * .55);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: size.width * (1.15 - i * .12),
          height: size.height * (.22 + i * .03),
        ),
        orbit,
      );
      canvas.restore();
    }

    final random = math.Random(8);
    final star = Paint()..color = Colors.white;
    for (var i = 0; i < 70; i++) {
      final p = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      canvas.drawCircle(
        p,
        random.nextDouble() * 1.2,
        star
          ..color = Colors.white.withValues(
            alpha: .25 + random.nextDouble() * .55,
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SpacePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
