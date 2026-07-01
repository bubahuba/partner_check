import 'package:bokeh_lava_gradient/bokeh_lava_gradient.dart';
import 'package:flutter/material.dart';

import '../services/contact_storage_service.dart';
import '../utils/self_contact_gradient.dart';

/// Animated bokeh/lava background using the self-contact inner + overlay colors.
class SelfContactAnimatedBackground extends StatefulWidget {
  final Widget child;
  final int? selfContactColor;
  final Color? gradientInner;
  final Color? gradientOuter;

  const SelfContactAnimatedBackground({
    super.key,
    required this.child,
    this.selfContactColor,
    this.gradientInner,
    this.gradientOuter,
  });

  @override
  State<SelfContactAnimatedBackground> createState() =>
      _SelfContactAnimatedBackgroundState();
}

class _SelfContactAnimatedBackgroundState
    extends State<SelfContactAnimatedBackground> {
  SelfContactGradientPalette _palette = SelfContactGradientPalette.defaults;

  @override
  void didUpdateWidget(SelfContactAnimatedBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selfContactColor != widget.selfContactColor ||
        oldWidget.gradientInner != widget.gradientInner ||
        oldWidget.gradientOuter != widget.gradientOuter) {
      _resolvePalette();
    }
  }

  @override
  void initState() {
    super.initState();
    _resolvePalette();
  }

  Future<void> _resolvePalette() async {
    if (widget.gradientInner != null && widget.gradientOuter != null) {
      _applyExplicitPalette(widget.gradientInner!, widget.gradientOuter!);
      return;
    }

    if (widget.selfContactColor != null) {
      _applyPalette(widget.selfContactColor);
      return;
    }

    final self = await ContactStorageService().loadSelfContact();
    if (!mounted) return;
    _applyPalette(self?.color);
  }

  void _applyExplicitPalette(Color inner, Color outer) {
    setState(() {
      _palette = SelfContactGradientPalette(
        inner: inner,
        outer: outer,
        accent: Color.lerp(inner, outer, 0.5) ??
            SelfContactGradientPalette.defaultAccent,
      );
    });
  }

  void _applyPalette(int? colorValue) {
    setState(() {
      _palette = colorValue != null
          ? SelfContactGradientPalette.fromColorValue(colorValue)
          : SelfContactGradientPalette.defaults;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BokehLavaGradient(
      baseColor: bokehBaseFromColors([_palette.inner, _palette.outer]),
      colors: [_palette.inner, _palette.outer],
      speed: 0.6,
      child: widget.child,
    );
  }
}

/// Dark blended fill behind bokeh blobs.
Color bokehBaseFromColors(List<Color> colors) {
  if (colors.isEmpty) return Colors.black;
  var blended = colors.first;
  for (var i = 1; i < colors.length; i++) {
    blended = Color.lerp(blended, colors[i], 1 / (i + 1)) ?? blended;
  }
  return Color.lerp(blended, Colors.black, 0.45) ?? Colors.black;
}
