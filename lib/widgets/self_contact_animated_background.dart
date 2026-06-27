import 'package:flutter/material.dart';

import '../services/contact_storage_service.dart';
import '../utils/self_contact_gradient.dart';

/// Animated background gradient using the saved "me" contact colors (overlay-dominant).
class SelfContactAnimatedBackground extends StatefulWidget {
  final Widget child;
  final int? selfContactColor;

  const SelfContactAnimatedBackground({
    super.key,
    required this.child,
    this.selfContactColor,
  });

  @override
  State<SelfContactAnimatedBackground> createState() =>
      _SelfContactAnimatedBackgroundState();
}

class _SelfContactAnimatedBackgroundState
    extends State<SelfContactAnimatedBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gradientController;
  SelfContactGradientPalette _palette = SelfContactGradientPalette.defaults;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    _loadPalette();
  }

  @override
  void didUpdateWidget(SelfContactAnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selfContactColor != widget.selfContactColor) {
      _applyPalette(widget.selfContactColor);
    }
  }

  Future<void> _loadPalette() async {
    if (widget.selfContactColor != null) {
      _applyPalette(widget.selfContactColor);
      return;
    }

    final self = await ContactStorageService().loadSelfContact();
    if (!mounted) return;
    _applyPalette(self?.color);
  }

  void _applyPalette(int? colorValue) {
    setState(() {
      _palette = colorValue != null
          ? SelfContactGradientPalette.fromColorValue(colorValue)
          : SelfContactGradientPalette.defaults;
    });
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
            children: [
              Container(
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
              child!,
            ],
          ),
        );
      },
      child: widget.child,
    );
  }
}
