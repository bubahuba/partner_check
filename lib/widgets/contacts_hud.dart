import 'package:flutter/material.dart';

/// HUD (Heads-Up Display) widget for contacts page
class ContactsHud extends StatelessWidget {
  final bool favoritesMode;
  final VoidCallback onSettings;
  final VoidCallback onToggleFavorites;
  final VoidCallback onAbout;

  const ContactsHud({
    super.key,
    required this.favoritesMode,
    required this.onSettings,
    required this.onToggleFavorites,
    required this.onAbout,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      left: 0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: onSettings,
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
          ),
          IconButton(
            icon: Icon(
              favoritesMode ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: onToggleFavorites,
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              color: Colors.white,
            ),
            onPressed: onAbout,
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}

