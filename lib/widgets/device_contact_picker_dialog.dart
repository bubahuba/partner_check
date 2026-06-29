import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../l10n/app_localizations.dart';
import '../services/contacts_permission.dart';

Future<Contact?> showDeviceContactPickerDialog(BuildContext context) {
  return showDialog<Contact>(
    context: context,
    useRootNavigator: true,
    builder: (context) => const DeviceContactPickerDialog(),
  );
}

class DeviceContactPickerDialog extends StatefulWidget {
  const DeviceContactPickerDialog({super.key});

  @override
  State<DeviceContactPickerDialog> createState() =>
      _DeviceContactPickerDialogState();
}

class _DeviceContactPickerDialogState extends State<DeviceContactPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_applyFilter)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      final contacts = await FlutterContacts.getAll(
        properties: contactsNameAndPhoneProperties,
      );
      if (!mounted) return;

      final usable = contacts
          .where((contact) => (contact.displayName ?? '').trim().isNotEmpty)
          .toList()
        ..sort(
          (a, b) => (a.displayName ?? '')
              .toLowerCase()
              .compareTo((b.displayName ?? '').toLowerCase()),
        );

      setState(() {
        _allContacts = usable;
        _filteredContacts = usable;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _filteredContacts = _allContacts);
      return;
    }

    setState(() {
      _filteredContacts = _allContacts.where((contact) {
        final name = (contact.displayName ?? '').toLowerCase();
        if (name.contains(query)) return true;
        for (final phone in contact.phones) {
          if (phone.number.toLowerCase().contains(query)) {
            return true;
          }
        }
        return false;
      }).toList();
    });
  }

  String? _phoneSubtitle(Contact contact) {
    if (contact.phones.isEmpty) return null;
    return contact.phones.first.number;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.pickYourselfButton),
      content: SizedBox(
        width: 420,
        height: 480,
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.loadingContactsFromDevice),
                  ],
                ),
              )
            : Column(
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
                  Expanded(child: _buildContactList(l10n)),
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

  Widget _buildContactList(AppLocalizations l10n) {
    if (_errorMessage != null) {
      return Center(
        child: Text(l10n.errorLoadingContacts(_errorMessage!)),
      );
    }

    if (_filteredContacts.isEmpty) {
      return Center(child: Text(l10n.noDeviceContactsFound));
    }

    return ListView.separated(
      itemCount: _filteredContacts.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        final subtitle = _phoneSubtitle(contact);
        return ListTile(
          title: Text(contact.displayName ?? ''),
          subtitle: subtitle == null ? null : Text(subtitle),
          onTap: () => Navigator.of(context).pop(contact),
        );
      },
    );
  }
}
