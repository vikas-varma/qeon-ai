import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  bool listening = true;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splash,
      appBar: AppBar(
        foregroundColor: Colors.white,
        leading: const BackButton(),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 28),
            Text(
              listening ? 'Listening...' : 'Paused',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Speak naturally to Qeon AI',
              style: TextStyle(color: Color(0xFFAEB1C7)),
            ),
            const Spacer(),
            AnimatedBuilder(
              animation: controller,
              builder: (_, _) => CustomPaint(
                size: const Size.square(270),
                painter: _VoiceOrbPainter(controller.value, listening),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 42,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(25, (index) {
                  final value = math
                      .sin((index * .7) + controller.value * math.pi * 8)
                      .abs();
                  return Container(
                    width: 3,
                    height: 8 + value * 27,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBright,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    minimumSize: const Size.square(58),
                  ),
                ),
                const SizedBox(width: 28),
                IconButton.filled(
                  onPressed: () => setState(() => listening = !listening),
                  icon: Icon(
                    listening ? Icons.stop_rounded : Icons.mic_rounded,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size.square(78),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 42),
          ],
        ),
      ),
    );
  }
}

class _VoiceOrbPainter extends CustomPainter {
  _VoiceOrbPainter(this.progress, this.active);
  final double progress;
  final bool active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width * .35;
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF9D65FF).withValues(alpha: active ? .75 : .3),
          const Color(0xFF375CFF).withValues(alpha: .18),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * .52));
    canvas.drawCircle(center, size.width * .52, glow);
    final orb = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-.3, -.35),
        colors: [Color(0xFFC99BFF), Color(0xFF7044F7), Color(0xFF172857)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, orb);
    final line = Paint()
      ..color = Colors.white.withValues(alpha: .82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final path = Path();
    for (var i = 0; i <= 120; i++) {
      final t = i / 120 * math.pi * 2;
      final r = radius * (.72 + math.sin(t * 2 + progress * math.pi * 2) * .11);
      final p = center + Offset(math.cos(t) * r, math.sin(t) * r);
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant _VoiceOrbPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.active != active;
}
