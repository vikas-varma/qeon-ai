import 'dart:math' as math;
import 'package:flutter/material.dart';

class CosmicLogo extends StatelessWidget {
  const CosmicLogo({super.key, this.size = 100});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _CosmicLogoPainter());
  }
}

class _CosmicLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * .28;
    final glow = Paint()
      ..color = const Color(0xFFFFB744).withValues(alpha: .32)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    canvas.drawCircle(center, radius, glow);

    for (var ring = 0; ring < 4; ring++) {
      final paint = Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFD66B), Color(0xFFFF8C35)],
        ).createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;
      final points = <Offset>[];
      for (var i = 0; i <= 120; i++) {
        final t = (i / 120) * math.pi * 2;
        final wave = math.sin((t * 4) + ring) * size.shortestSide * .025;
        final r = radius + wave + ring * 1.8;
        points.add(
          center +
              Offset(
                math.cos(t + ring * .35) * r,
                math.sin(t + ring * .35) * r,
              ),
        );
      }
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
