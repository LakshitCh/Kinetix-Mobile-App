import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Circular progress indicator — exact port of CircularProgress.tsx.
class CircularProgressWidget extends StatelessWidget {
  final double value; // 0 to 100
  final double size;
  final Widget? center;

  const CircularProgressWidget({
    super.key,
    required this.value,
    this.size = 60,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CircularProgressPainter(
          value: value,
          trackColor: AppColors.border.withValues(alpha: 0.2),
          progressColor: AppColors.primary,
        ),
        child: Center(
          child: center ??
              Text(
                '${value.round()}%',
                style: TextStyle(
                  fontSize: size * 0.17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.foreground,
                ),
              ),
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double value;
  final Color trackColor;
  final Color progressColor;

  _CircularProgressPainter({
    required this.value,
    required this.trackColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress gradient
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: 3 * pi / 2,
        colors: [AppColors.primary, const Color(0xFFEF4444)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    final sweepAngle = (value / 100) * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.value != value;
  }
}
