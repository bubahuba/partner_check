import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/directionality_utils.dart';

class AboutScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const AboutScreen({super.key, this.onClose});

  @override
  AboutScreenState createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.ease),
    );
    // Animate in from the right when first shown
    _slideController.forward();

    // Gradient animation controller - loops infinitely back and forth
    _gradientController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _slideController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  Color _interpolateColor(Color a, Color b, double t) {
    return Color.lerp(a, b, t)!;
  }

  void _handleClose() {
    _slideController.reverse().then((_) {
      if (widget.onClose != null) {
        widget.onClose!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // App icon colors: indigo (#6366F1), pink (#EC4899), blue (#3B82F6)
    const Color indigo = Color(0xFF6366F1);
    const Color pink = Color(0xFFEC4899);
    const Color blue = Color(0xFF3B82F6);

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: horizontalPanelSlideOffset(context, _slideAnimation.value),
          child: child,
        );
      },
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _gradientController,
          builder: (context, child) {
            // Calculate animated colors based on gradient animation
            final t = _gradientController.value;
            // Cycle through: indigo -> pink -> blue -> indigo
            Color color1, color2, color3;
            if (t < 0.33) {
              // Transition from indigo to pink
              final localT = t / 0.33;
              color1 = _interpolateColor(indigo, pink, localT);
              color2 = pink;
              color3 = blue;
            } else if (t < 0.66) {
              // Transition from pink to blue
              final localT = (t - 0.33) / 0.33;
              color1 = pink;
              color2 = _interpolateColor(pink, blue, localT);
              color3 = blue;
            } else {
              // Transition from blue back to indigo
              final localT = (t - 0.66) / 0.34;
              color1 = pink;
              color2 = blue;
              color3 = _interpolateColor(blue, indigo, localT);
            }

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
                  // Smooth color overlay for blur effect
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
                  // Content
                  SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isPortrait =
                            constraints.maxHeight > constraints.maxWidth;
                        final screenWidth = constraints.maxWidth;
                        final screenHeight = constraints.maxHeight;
                        final minDimension = screenWidth < screenHeight
                            ? screenWidth
                            : screenHeight;

                        // Responsive sizing based on screen dimensions
                        final padding = isPortrait
                            ? (minDimension * 0.04).clamp(16.0, 24.0)
                            : (minDimension * 0.04).clamp(16.0, 24.0);
                        final fontSize = isPortrait
                            ? (screenWidth * 0.045).clamp(16.0, 20.0)
                            : (screenHeight * 0.035).clamp(14.0, 18.0);
                        final titleFontSize = isPortrait
                            ? (screenWidth * 0.08).clamp(24.0, 32.0)
                            : (screenHeight * 0.06).clamp(20.0, 28.0);
                        final spacing = isPortrait
                            ? (screenHeight * 0.03).clamp(12.0, 24.0)
                            : (screenWidth * 0.03).clamp(12.0, 20.0);

                        return Padding(
                          padding: EdgeInsets.all(padding),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: spacing * 2),
                                Builder(
                                  builder: (context) {
                                    final l10n = AppLocalizations.of(context)!;
                                    return Text(
                                      l10n.aboutTitle,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.2,
                                        shadows: const [
                                          Shadow(
                                            color: Colors.black26,
                                            blurRadius: 10,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: spacing * 2),
                                Builder(
                                  builder: (context) {
                                    final l10n = AppLocalizations.of(context)!;
                                    return Text(
                                      l10n.aboutText,
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: fontSize,
                                        color: Colors.white,
                                        height: 1.6,
                                        shadows: const [
                                          Shadow(
                                            color: Colors.black26,
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: spacing * 2),
                                // Icons with descriptions
                                Builder(
                                  builder: (context) {
                                    final l10n = AppLocalizations.of(context)!;
                                    final iconDescriptionFontSize = isPortrait
                                        ? (screenWidth * 0.035)
                                            .clamp(12.0, 16.0)
                                        : (screenHeight * 0.03)
                                            .clamp(12.0, 14.0);

                                    return Container(
                                      padding: EdgeInsets.all(spacing),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Heart icon
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.favorite_border,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  l10n.heartIconDescription,
                                                  style: TextStyle(
                                                    fontSize:
                                                        iconDescriptionFontSize,
                                                    color: Colors.white,
                                                    height: 1.4,
                                                    shadows: const [
                                                      Shadow(
                                                        color: Colors.black26,
                                                        blurRadius: 8,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: spacing),
                                          // Chart icon
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.bar_chart,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  l10n.chartIconDescription,
                                                  style: TextStyle(
                                                    fontSize:
                                                        iconDescriptionFontSize,
                                                    color: Colors.white,
                                                    height: 1.4,
                                                    shadows: const [
                                                      Shadow(
                                                        color: Colors.black26,
                                                        blurRadius: 8,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: spacing),
                                          // Trash icon
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Icon(
                                                Icons.delete_outline,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  l10n.trashIconDescription,
                                                  style: TextStyle(
                                                    fontSize:
                                                        iconDescriptionFontSize,
                                                    color: Colors.white,
                                                    height: 1.4,
                                                    shadows: const [
                                                      Shadow(
                                                        color: Colors.black26,
                                                        blurRadius: 8,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(height: spacing * 2),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Back arrow button at the same position as HUD settings button (on top)
                  Positioned(
                    top: 10,
                    left: 0,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: _handleClose,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
