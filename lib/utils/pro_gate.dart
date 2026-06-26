import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/pro_subscription_service.dart';

Future<bool> ensureCanAddContact(BuildContext context, int currentCount) async {
  final proService = context.read<ProSubscriptionService>();
  if (proService.canAddContact(currentCount)) {
    return true;
  }

  final l10n = AppLocalizations.of(context)!;
  final upgrade = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.contactLimitReached),
      content: Text(l10n.contactLimitMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.upgradeToPro),
        ),
      ],
    ),
  );

  if (upgrade == true && context.mounted) {
    await showUpgradeSheet(context);
  }
  return false;
}

Future<bool> ensureProForBulkImport(BuildContext context) async {
  final proService = context.read<ProSubscriptionService>();
  if (proService.isPro) {
    return true;
  }

  final l10n = AppLocalizations.of(context)!;
  final upgrade = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.proVersion),
      content: Text(l10n.proFeatureLoadAllContacts),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.upgradeToPro),
        ),
      ],
    ),
  );

  if (upgrade == true && context.mounted) {
    await showUpgradeSheet(context);
  }
  return false;
}

Future<void> showUpgradeSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => _UpgradeSheet(parentContext: context),
  );
}

class _UpgradeSheet extends StatelessWidget {
  const _UpgradeSheet({required this.parentContext});

  final BuildContext parentContext;

  Future<void> _purchase(BuildContext context) async {
    final proService = context.read<ProSubscriptionService>();
    final l10n = AppLocalizations.of(context)!;

    if (proService.isPro) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text(l10n.alreadyPro)),
      );
      Navigator.of(context).pop();
      return;
    }

    await proService.purchasePro();
  }

  Future<void> _restore(BuildContext context) async {
    final proService = context.read<ProSubscriptionService>();
    final l10n = AppLocalizations.of(context)!;

    await proService.restorePurchases();
    if (!context.mounted) return;

    if (proService.isPro) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        SnackBar(content: Text(l10n.purchaseSuccess)),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ProSubscriptionService>(
      builder: (context, proService, _) {
        final price = proService.proProduct?.price;
        final upgradeLabel = price != null
            ? '${l10n.upgradeToPro} ($price)'
            : l10n.upgradeToPro;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.proVersion,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.proFeatureLoadAllContacts,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (proService.isPro)
                    Text(
                      l10n.alreadyPro,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    )
                  else ...[
                    ElevatedButton(
                      onPressed: proService.isLoading
                          ? null
                          : () => _purchase(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: proService.isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(upgradeLabel),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: proService.isLoading
                          ? null
                          : () => _restore(context),
                      child: Text(
                        l10n.restorePurchases,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
