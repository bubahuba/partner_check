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
  late final ScrollController _scrollController1;
  late final ScrollController _scrollController2;
  final Set<int> _hiddenTextIndices = {};

  static const Color _fallbackTileColor = Color(0xFFE0E0E0);

  @override
  void initState() {
    super.initState();
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
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
    _scrollController1.dispose();
    _scrollController2.dispose();
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

  void _toggleTextVisibility(int index) {
    setState(() {
      if (_hiddenTextIndices.contains(index)) {
        _hiddenTextIndices.remove(index);
      } else {
        _hiddenTextIndices.add(index);
      }
    });
  }

  Widget _buildListView(ScrollController controller, double height) {
    final itemWidth = MediaQuery.of(context).size.width / 2;
    return ListView.builder(
      controller: controller,
      scrollDirection: Axis.horizontal,
      physics: const PageScrollPhysics(),
      itemExtent: itemWidth,
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        final name = contact.displayName ?? 'No Name';
        final phone = contact.phones?.first.value ?? 'No Phone';
        final isTextVisible = !_hiddenTextIndices.contains(index);
        return GestureDetector(
          onTap: () => _toggleTextVisibility(index),
          child: SizedBox(
            height: height,
            child: Card(
              color: _colorFromPhone(phone),
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: SizedBox.expand(
                child: isTextVisible
                    ? ListTile(
                        title: Text(
                          name,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          phone,
                          style: const TextStyle(color: Colors.white),
                        ),
                        contentPadding: const EdgeInsets.all(24),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: LayoutBuilder(builder: (context, constraints) {
          final halfHeight = constraints.maxHeight / 2;
          return Column(
            children: [
              Expanded(
                child: _buildListView(_scrollController1, halfHeight),
              ),
              Expanded(
                child: _buildListView(_scrollController2, halfHeight),
              ),
            ],
          );
        }));
  }
}
