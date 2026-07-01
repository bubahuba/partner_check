import 'package:flutter/material.dart';

import '../utils/self_contact_gradient.dart';

/// Animated gradient background using two session contact colors.
class TetrisSessionBackground extends StatefulWidget {
  final Color color1;
  final Color color2;
  final Widget child;

  const TetrisSessionBackground({
    super.key,
    required this.color1,
    required this.color2,
    required this.child,
  });

  @override
  State<TetrisSessionBackground> createState() =>
      _TetrisSessionBackgroundState();
}

class _TetrisSessionBackgroundState extends State<TetrisSessionBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _gradientController;
  late SelfContactGradientPalette _palette;

  @override
  void initState() {
    super.initState();
    _palette = _paletteFor(widget.color1, widget.color2);
    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant TetrisSessionBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color1 != widget.color1 ||
        oldWidget.color2 != widget.color2) {
      _palette = _paletteFor(widget.color1, widget.color2);
    }
  }

  SelfContactGradientPalette _paletteFor(Color a, Color b) {
    return SelfContactGradientPalette(
      inner: a,
      outer: b,
      accent: Color.lerp(a, b, 0.5) ?? a,
    );
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _gradientController,
      builder: (context, child) {
        final (color1, color2, color3) = SelfContactGradient.colorsAt(
          _gradientController.value,
          _palette,
        );

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color1, color2, color3],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.05),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned.fill(child: child!),
            ],
          ),
        );
      },
      child: widget.child,
    );
  }
}
