import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Contacts Phone Numbers',
      home: ContactsPage(),
    );
  }
}

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<Contact> _contacts = [];
  late final ScrollController _scrollController;

  static const Color _fallbackTileColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _fetchContacts();
  }

  Color _colorFromPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return _fallbackTileColor;
    }
    final hexDigits = digits.length >= 6
        ? digits.substring(digits.length - 6)
        : digits.padLeft(6, '0');
    final value = int.tryParse(hexDigits, radix: 16);
    if (value == null) {
      return _fallbackTileColor;
    }
    return Color(0xFF000000 | value);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchContacts() async {
    // Request permission
    final status = Permission.contacts.request();
    if (await status.isGranted) {
      // Load contacts
      Iterable<Contact> contacts =
          await ContactsService.getContacts(withThumbnails: false);
      setState(() {
        _contacts = contacts
            .where((contact) =>
                contact.phones != null && contact.phones!.isNotEmpty)
            .toList();
      });
    } else {
      // Handle permission denied
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Contacts permission denied'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _fetchContacts,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Contacts Phone Numbers')),
        body: LayoutBuilder(builder: (context, constraints) {
          final itemWidth = MediaQuery.of(context).size.width / 2;
          return ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const PageScrollPhysics(),
            itemExtent: itemWidth,
            itemCount: _contacts.length,
            itemBuilder: (context, index) {
              final contact = _contacts[index];
              final name = contact.displayName ?? 'No Name';
              final phone = contact.phones?.first.value ?? 'No Phone';
              return SizedBox(
                height: constraints.maxHeight,
                child: Card(
                  color: _colorFromPhone(phone),
                  margin: EdgeInsets.zero,
                  child: SizedBox.expand(
                    child: ListTile(
                      title: Text(name),
                      subtitle: Text(phone),
                      contentPadding: const EdgeInsets.all(24),
                    ),
                  ),
                ),
              );
            },
          );
        }));
  }
}
