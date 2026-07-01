import 'package:flutter/material.dart';

import 'icons/favorites_icon.dart';
import 'icons/lava_icon.dart';
import 'icons/help_icon.dart';
import 'icons/plasma_icon.dart';
import 'icons/settings_icon.dart';
import 'icons/tetris_icon.dart';

/// Top HUD for the contacts page. A chevron toggles the action icons in/out.
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

  @override
  Widget build(BuildContext context) {
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
                IconButton(
                  icon: Icon(
                    _showIcons ? Icons.chevron_left : Icons.chevron_right,
                    color: Colors.white,
                  ),
                  onPressed: onToggle,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ClipRect(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.centerLeft,
                  widthFactor: _showIcons ? 1.0 : 0.0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const SettingsIcon(),
                        onPressed: onSettings,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      IconButton(
                        icon: FavoritesIcon(filled: favoritesMode),
                        onPressed: onToggleFavorites,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      IconButton(
                        icon: const HelpIcon(),
                        onPressed: onAbout,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      IconButton(
                        icon: const TetrisIcon(),
                        onPressed: onTetris,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      IconButton(
                        icon: const PlasmaIcon(),
                        onPressed: onPlasma,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                      IconButton(
                        icon: const LavaIcon(),
                        onPressed: onLava,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ],
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
