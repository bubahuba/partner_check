import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models.dart';

Future<int?> showStoredContactPickerDialog(
  BuildContext context,
  List<StoredContact> contacts,
) {
  return showDialog<int>(
    context: context,
    useRootNavigator: true,
    builder: (context) => StoredContactPickerDialog(contacts: contacts),
  );
}

class StoredContactPickerDialog extends StatefulWidget {
  const StoredContactPickerDialog({super.key, required this.contacts});

  final List<StoredContact> contacts;

  @override
  State<StoredContactPickerDialog> createState() =>
      _StoredContactPickerDialogState();
}

class _StoredContactPickerDialogState extends State<StoredContactPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  late List<StoredContact> _filteredContacts;

  @override
  void initState() {
    super.initState();
    _filteredContacts = List<StoredContact>.from(widget.contacts);
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_applyFilter)
      ..dispose();
    super.dispose();
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredContacts = List<StoredContact>.from(widget.contacts);
        return;
      }

      _filteredContacts = widget.contacts.where((contact) {
        if (contact.name.toLowerCase().contains(query)) {
          return true;
        }
        return false;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.pickYourselfButton),
      content: SizedBox(
        width: 420,
        height: 480,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchContacts,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: _filteredContacts.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final contact = _filteredContacts[index];
                  final originalIndex = widget.contacts.indexOf(contact);
                  return ListTile(
                    title: Text(contact.name),
                    onTap: () => Navigator.of(context).pop(originalIndex),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
      ],
    );
  }
}
