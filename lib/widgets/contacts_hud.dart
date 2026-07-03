import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'icons/favorites_icon.dart';
import 'icons/lava_icon.dart';
import 'icons/help_icon.dart';
import 'icons/plasma_icon.dart';
import 'icons/settings_icon.dart';
import 'icons/tetris_icon.dart';

const _kHudIconSize = 20.0;
const _kHudButtonExtent = 36.0;

/// Top HUD for the contacts page.
///
/// [expanded] is toggled by the chevron (icon row in/out). Parent controls
/// whether the whole HUD is shown (e.g. hide on contact-pane tap).
class ContactsHud extends StatelessWidget {
  final bool expanded;
  final bool allowCollapse;
  final VoidCallback? onToggle;
  final bool favoritesMode;
  final VoidCallback onSettings;
  final VoidCallback onToggleFavorites;
  final VoidCallback onAbout;
  final VoidCallback onTetris;
  final VoidCallback onPlasma;
  final VoidCallback onLava;

  const ContactsHud({
    super.key,
    required this.expanded,
    required this.allowCollapse,
    this.onToggle,
    required this.favoritesMode,
    required this.onSettings,
    required this.onToggleFavorites,
    required this.onAbout,
    required this.onTetris,
    required this.onPlasma,
    required this.onLava,
  });

  bool get _showIcons => expanded || !allowCollapse;

  double _maxExpandedWidth(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    const edgePadding = 4.0;
    final chevronWidth = allowCollapse ? _kHudButtonExtent : 0.0;
    return math.max(0, screenWidth - chevronWidth - edgePadding);
  }

  Widget _hudIconButton({
    required Widget icon,
    VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: icon,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: _kHudButtonExtent,
        minHeight: _kHudButtonExtent,
      ),
      style: IconButton.styleFrom(
        backgroundColor: Colors.transparent,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxExpandedWidth = _maxExpandedWidth(context);

    return Positioned(
      top: 0,
      left: 0,
      child: SafeArea(
        bottom: false,
        right: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (allowCollapse)
                _hudIconButton(
                  icon: Icon(
                    _showIcons ? Icons.chevron_left : Icons.chevron_right,
                    color: Colors.white,
                    size: _kHudIconSize,
                  ),
                  onPressed: onToggle,
                ),
              ClipRect(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.centerLeft,
                  widthFactor: _showIcons ? 1.0 : 0.0,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxExpandedWidth),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _hudIconButton(
                            icon: const SettingsIcon(size: _kHudIconSize),
                            onPressed: onSettings,
                          ),
                          _hudIconButton(
                            icon: FavoritesIcon(
                              filled: favoritesMode,
                              size: _kHudIconSize,
                            ),
                            onPressed: onToggleFavorites,
                          ),
                          _hudIconButton(
                            icon: const HelpIcon(size: _kHudIconSize),
                            onPressed: onAbout,
                          ),
                          _hudIconButton(
                            icon: const TetrisIcon(size: _kHudIconSize),
                            onPressed: onTetris,
                          ),
                          _hudIconButton(
                            icon: const PlasmaIcon(size: _kHudIconSize),
                            onPressed: onPlasma,
                          ),
                          _hudIconButton(
                            icon: const LavaIcon(size: _kHudIconSize),
                            onPressed: onLava,
                          ),
                        ],
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
