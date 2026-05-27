import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class IslamicPatternBackground extends StatelessWidget {
  final Widget child;
  final bool showStarsOnly;

  const IslamicPatternBackground({
    super.key,
    required this.child,
    this.showStarsOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        // Geometric Custom Paint Pattern
        Positioned.fill(
          child: CustomPaint(
            painter: IslamicPatternPainter(
              isDark: isDark,
              showStarsOnly: showStarsOnly,
            ),
          ),
        ),
        // Glassmorphic Gradient Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.transparent,
                  (isDark ? AppColors.backgroundDark : AppColors.backgroundLight).withOpacity(0.35),
                ],
              ),
            ),
          ),
        ),
        // Child Content
        child,
      ],
    );
  }
}

class IslamicPatternPainter extends CustomPainter {
  final bool isDark;
  final bool showStarsOnly;

  IslamicPatternPainter({
    required this.isDark,
    required this.showStarsOnly,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark 
          ? AppColors.accentGold.withOpacity(0.04) 
          : AppColors.primaryEmerald.withOpacity(0.035)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final double gridWidth = 120.0;
    final double gridHeight = 120.0;

    final int cols = (size.width / gridWidth).ceil() + 1;
    final int rows = (size.height / gridHeight).ceil() + 1;

    for (int i = 0; i < cols; i++) {
      for (int j = 0; j < rows; j++) {
        final double x = i * gridWidth;
        final double y = j * gridHeight;

        // Draw 8-Point Geometric Star (Rub el Hizb)
        _drawEightPointStar(canvas, Offset(x, y), 24.0, paint);

        if (!showStarsOnly) {
          // Draw intersecting arabesque lattice lines connecting stars
          canvas.drawLine(Offset(x - gridWidth / 2, y), Offset(x + gridWidth / 2, y), paint);
          canvas.drawLine(Offset(x, y - gridHeight / 2), Offset(x, y + gridHeight / 2), paint);
          
          // Diagonal links
          canvas.drawLine(Offset(x - gridWidth / 2, y - gridHeight / 2), Offset(x + gridWidth / 2, y + gridHeight / 2), paint);
          canvas.drawLine(Offset(x + gridWidth / 2, y - gridHeight / 2), Offset(x - gridWidth / 2, y + gridHeight / 2), paint);
        }
      }
    }
  }

  void _drawEightPointStar(Canvas canvas, Offset center, double radius, Paint paint) {
    // 8-point star is formed by drawing two overlapping squares rotated at 45 degrees
    final Path path1 = Path();
    final Path path2 = Path();

    // First Square
    for (int i = 0; i < 4; i++) {
      final double angle = (i * 90) * math.pi / 180;
      final double px = center.dx + radius * math.cos(angle);
      final double py = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path1.moveTo(px, py);
      } else {
        path1.lineTo(px, py);
      }
    }
    path1.close();

    // Second Square (Rotated by 45 degrees)
    for (int i = 0; i < 4; i++) {
      final double angle = (i * 90 + 45) * math.pi / 180;
      final double px = center.dx + radius * math.cos(angle);
      final double py = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path2.moveTo(px, py);
      } else {
        path2.lineTo(px, py);
      }
    }
    path2.close();

    // Render both squares to form the star
    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
