import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/app_localizations.dart';
import 'snackbar_utils.dart';

/// On web, copies [url] and shows a snackbar. Elsewhere opens the platform share sheet.
Future<void> shareTetrisLink(BuildContext context, String url) async {
  if (kIsWeb) {
    await Clipboard.setData(ClipboardData(text: url));
    if (!context.mounted) return;
    showAppSnackBar(context, AppLocalizations.of(context)!.tetrisLinkCopied);
    return;
  }

  await SharePlus.instance.share(ShareParams(uri: Uri.parse(url)));
}
