import 'package:flutter/material.dart';

class GoldFoilText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  const GoldFoilText({
    super.key,
    required this.text,
    required this.style,
    this.textAlign = TextAlign.center,
  });

  @override
  State<GoldFoilText> createState() => _GoldFoilTextState();
}

class _GoldFoilTextState extends State<GoldFoilText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Premium metallic gold gradient colors
    final goldColors = [
      const Color(0xFFC5A059), // Classic metallic gold
      const Color(0xFFE2C98F), // Light golden luster
      const Color(0xFFF7E7C4), // Golden champagne light reflection
      const Color(0xFFC5A059), // Classic metallic gold
      const Color(0xFF9E7B3B), // Soft shadow bronze gold
    ];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            // Shifts the gradient linear points to simulate a light sweep reflecting off metallic foil
            final double slide = _controller.value;
            return LinearGradient(
              begin: Alignment(-2.0 + (slide * 4.0), -1.0),
              end: Alignment(0.0 + (slide * 4.0), 1.0),
              colors: goldColors,
              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Text(
            widget.text,
            style: widget.style.copyWith(color: Colors.white), // Color is overridden by ShaderMask
            textAlign: widget.textAlign,
          ),
        );
      },
    );
  }
}
