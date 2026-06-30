import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/phone_utils.dart';
import '../utils/snackbar_utils.dart';

enum ContactInputDialogMode { add, edit }

/// Shows a name + phone form dialog. Enter on the phone field submits.
Future<Map<String, String>?> showContactInputDialog(
  BuildContext context, {
  required ContactInputDialogMode mode,
  String initialName = '',
}) {
  return showDialog<Map<String, String>>(
    context: context,
    builder: (context) => ContactInputDialog(
      mode: mode,
      initialName: initialName,
    ),
  );
}

class ContactInputDialog extends StatefulWidget {
  final ContactInputDialogMode mode;
  final String initialName;

  const ContactInputDialog({
    super.key,
    required this.mode,
    this.initialName = '',
  });

  @override
  State<ContactInputDialog> createState() => _ContactInputDialogState();
}

class _ContactInputDialogState extends State<ContactInputDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final rawPhone = _phoneController.text.trim();

    if (name.isEmpty) {
      return;
    }

    if (widget.mode == ContactInputDialogMode.add) {
      if (!PhoneUtils.hasMinimumDigits(rawPhone)) {
        showAppSnackBar(context, l10n.phoneNumberMinDigits);
        return;
      }
    } else if (rawPhone.isNotEmpty && !PhoneUtils.hasMinimumDigits(rawPhone)) {
      showAppSnackBar(context, l10n.phoneNumberMinDigits);
      return;
    }

    Navigator.of(context).pop({
      'name': name,
      'phone': PhoneUtils.sanitizePhoneNumber(rawPhone),
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.mode == ContactInputDialogMode.edit;
    final title = isEdit ? l10n.editContact : l10n.addContactManually;
    final confirmLabel = isEdit ? l10n.save : l10n.add;
    final mediaQuery = MediaQuery.of(context);

    return AlertDialog(
      content: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: mediaQuery.size.height * 0.8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                focusNode: _nameFocus,
                decoration: InputDecoration(
                  labelText: l10n.name,
                  hintText: l10n.enterContactName,
                ),
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _phoneFocus.requestFocus(),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                focusNode: _phoneFocus,
                decoration: InputDecoration(
                  labelText:
                      isEdit ? l10n.phoneNumberOptional : l10n.phoneNumber,
                  hintText: isEdit
                      ? l10n.enterPhoneNumberToChangeColor
                      : l10n.enterPhoneNumber,
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.phoneNumberMinDigits,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (isEdit) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.leavePhoneEmptyKeepColor,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}
