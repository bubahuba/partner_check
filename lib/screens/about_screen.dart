import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/directionality_utils.dart';
import '../widgets/icons/back_hand_icon.dart';
import '../widgets/icons/back_icon.dart';
import '../widgets/icons/chart_icon.dart';
import '../widgets/icons/favorites_icon.dart';
import '../widgets/icons/tetris_icon.dart';
import '../widgets/icons/touch_app_icon.dart';
import '../widgets/icons/trash_icon.dart';
import '../widgets/self_contact_animated_background.dart';

class AboutScreen extends StatefulWidget {
  final VoidCallback? onClose;
  final int? selfContactColor;
  final Color? gradientInner;
  final Color? gradientOuter;

  const AboutScreen({
    super.key,
    this.onClose,
    this.selfContactColor,
    this.gradientInner,
    this.gradientOuter,
  });

  @override
  AboutScreenState createState() => AboutScreenState();
}

class AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

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
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
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
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: horizontalPanelSlideOffset(context, _slideAnimation.value),
          child: child,
        );
      },
      child: Scaffold(
        body: SelfContactAnimatedBackground(
          selfContactColor: widget.selfContactColor,
          gradientInner: widget.gradientInner,
          gradientOuter: widget.gradientOuter,
          child: Stack(
            children: [
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isPortrait =
                        constraints.maxHeight > constraints.maxWidth;
                    final screenWidth = constraints.maxWidth;
                    final screenHeight = constraints.maxHeight;
                    final minDimension =
                        screenWidth < screenHeight ? screenWidth : screenHeight;

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
                            Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context)!;
                                final iconDescriptionFontSize = isPortrait
                                    ? (screenWidth * 0.035).clamp(12.0, 16.0)
                                    : (screenHeight * 0.03).clamp(12.0, 14.0);
                                final descriptionStyle = TextStyle(
                                  fontSize: iconDescriptionFontSize,
                                  color: Colors.white,
                                  height: 1.4,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                    ),
                                  ],
                                );

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
                                      _AboutIconRow(
                                        icon: const FavoritesIcon(
                                          filled: false,
                                        ),
                                        text: l10n.heartIconDescription,
                                        style: descriptionStyle,
                                      ),
                                      SizedBox(height: spacing),
                                      _AboutIconRow(
                                        icon: const ChartIcon(),
                                        text: l10n.chartIconDescription,
                                        style: descriptionStyle,
                                      ),
                                      SizedBox(height: spacing),
                                      _AboutIconRow(
                                        icon: const TrashIcon(),
                                        text: l10n.trashIconDescription,
                                        style: descriptionStyle,
                                      ),
                                      SizedBox(height: spacing),
                                      _AboutIconRow(
                                        icon: const TetrisIcon(),
                                        text: l10n.tetrisIconDescription,
                                        style: descriptionStyle,
                                      ),
                                      SizedBox(height: spacing),
                                      _AboutIconRow(
                                        icon: const TouchAppIcon(),
                                        text: l10n.doubleTapSelfDescription,
                                        style: descriptionStyle,
                                      ),
                                      SizedBox(height: spacing),
                                      _AboutIconRow(
                                        icon: const BackHandIcon(),
                                        text: l10n.longPressSelfDescription,
                                        style: descriptionStyle,
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
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  bottom: false,
                  right: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: IconButton(
                      icon: const BackIcon(),
                      onPressed: _handleClose,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutIconRow extends StatelessWidget {
  final Widget icon;
  final String text;
  final TextStyle style;

  const _AboutIconRow({
    required this.icon,
    required this.text,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon,
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: style),
        ),
      ],
    );
  }
}
