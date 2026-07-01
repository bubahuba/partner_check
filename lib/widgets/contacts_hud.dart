import 'package:flutter/material.dart';

import 'icons/favorites_icon.dart';
import 'icons/help_icon.dart';
import 'icons/settings_icon.dart';
import 'icons/tetris_icon.dart';

/// HUD (Heads-Up Display) widget for contacts page
class ContactsHud extends StatelessWidget {
  final bool favoritesMode;
  final VoidCallback onSettings;
  final VoidCallback onToggleFavorites;
  final VoidCallback onAbout;
  final VoidCallback onTetris;

  const ContactsHud({
    super.key,
    required this.favoritesMode,
    required this.onSettings,
    required this.onToggleFavorites,
    required this.onAbout,
    required this.onTetris,
  });

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
            ],
          ),
        ),
      ),
    );
  }
}
