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
  bool _isTextVisible = false;
  double _overlayHeight = 0.2; // Initial height: 20%

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

  Color _overlayColorFromPhone(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return const Color(0x80000000); // Semi-transparent black fallback
    }
    final lastSix = digits.length >= 6
        ? digits.substring(digits.length - 6)
        : digits.padLeft(6, '0');
    // Reverse the digits
    final reversedDigits = lastSix.split('').reversed.join();
    final value = int.tryParse(reversedDigits, radix: 16);
    if (value == null) {
      return const Color(0x80000000); // Semi-transparent black fallback
    }
    // Apply with some transparency (0x80 = ~50% opacity)
    return Color(0x80000000 | value);
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

  void _toggleTextVisibility() {
    setState(() {
      _isTextVisible = !_isTextVisible;
    });
  }

  void _updateOverlayHeight(double delta, double cardHeight) {
    setState(() {
      // delta is negative when dragging up, positive when dragging down
      // We want dragging up to increase overlay height, down to decrease
      final heightChange = -delta / cardHeight;
      _overlayHeight = (_overlayHeight + heightChange).clamp(0.0, 1.0);
    });
  }

  Widget _buildListView(ScrollController controller, double height, double width) {
    return ListView.builder(
      controller: controller,
      scrollDirection: Axis.horizontal,
      physics: const PageScrollPhysics(),
      itemExtent: width,
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        final name = contact.displayName ?? 'No Name';
        final phone = contact.phones?.first.value ?? 'No Phone';
        return GestureDetector(
          onTap: _toggleTextVisibility,
          onVerticalDragUpdate: (details) {
            _updateOverlayHeight(details.delta.dy, height);
          },
          child: SizedBox(
            height: height,
            child: Card(
              color: _colorFromPhone(phone),
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: height * _overlayHeight,
                    child: Container(
                      color: _overlayColorFromPhone(phone),
                    ),
                  ),
                  SizedBox.expand(
                    child: _isTextVisible
                        ? Center(
                            child: Text(
                              name,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
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
          final halfWidth = constraints.maxWidth / 2;
          return Row(
            children: [
              Expanded(
                child: _buildListView(_scrollController1, constraints.maxHeight, halfWidth),
              ),
              Expanded(
                child: _buildListView(_scrollController2, constraints.maxHeight, halfWidth),
              ),
            ],
          );
        }));
  }
}
