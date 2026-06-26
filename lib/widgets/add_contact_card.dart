import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

/// Widget for displaying an add contact card
class AddContactCard extends StatelessWidget {
  final double height;
  final VoidCallback onTap;

  const AddContactCard({
    super.key,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: Card(
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          color: const Color(0xFF1A1A1A),
          child: Center(
            child: IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white.withValues(alpha: 0.85),
                size: 48,
              ),
              onPressed: onTap,
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Helper function to show add contact menu
void showAddContactMenu(
  BuildContext context, {
  required VoidCallback onAddFromDevice,
  required VoidCallback onAddManually,
}) {
  final l10n = AppLocalizations.of(context)!;
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      decoration: const BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.contacts, color: Colors.white),
              title: Text(
                l10n.addFromDevice,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onAddFromDevice();
              },
            ),
            const Divider(color: Colors.grey),
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: Text(
                l10n.addManually,
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onAddManually();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

