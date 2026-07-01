import 'package:flutter/material.dart';

import '../utils/color_utils.dart';

/// Miniature contact color card with inner base and outer overlay strip.
class TetrisPairMiniature extends StatelessWidget {
  final String name;
  final int color;
  final double width;
  final double height;
  final bool showName;

  const TetrisPairMiniature({
    super.key,
    required this.name,
    required this.color,
    required this.width,
    required this.height,
    this.showName = false,
  });

  static const double overlayHeightRatio = 0.2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: ColorUtils.colorFromValue(color)),
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: overlayHeightRatio,
              widthFactor: 1,
              child: ColoredBox(
                color: ColorUtils.overlayColorFromValue(color),
              ),
            ),
          ),
          if (showName) ...[
            ColoredBox(color: Colors.black.withValues(alpha: 0.35)),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                    shadows: const [
                      Shadow(blurRadius: 4, color: Colors.black54),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Two contact miniatures flush side by side for a Tetris pair record.
class TetrisPairRowMiniatures extends StatefulWidget {
  final String contact1Name;
  final int contact1Color;
  final String contact2Name;
  final int contact2Color;

  const TetrisPairRowMiniatures({
    super.key,
    required this.contact1Name,
    required this.contact1Color,
    required this.contact2Name,
    required this.contact2Color,
  });

  @override
  State<TetrisPairRowMiniatures> createState() =>
      _TetrisPairRowMiniaturesState();
}

class _TetrisPairRowMiniaturesState extends State<TetrisPairRowMiniatures> {
  bool _namesVisible = false;

  static const double _tileHeightRatio = 0.28;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = constraints.maxWidth / 2;
        final tileHeight = tileWidth * _tileHeightRatio;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _namesVisible = !_namesVisible),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              TetrisPairMiniature(
                name: widget.contact1Name,
                color: widget.contact1Color,
                width: tileWidth,
                height: tileHeight,
                showName: _namesVisible,
              ),
              TetrisPairMiniature(
                name: widget.contact2Name,
                color: widget.contact2Color,
                width: tileWidth,
                height: tileHeight,
                showName: _namesVisible,
              ),
            ],
          ),
        );
      },
    );
  }
}
