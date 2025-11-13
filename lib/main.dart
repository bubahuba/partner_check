import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

class StoredContact {
  final String name;
  final int color;

  StoredContact({required this.name, required this.color});

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color,
      };

  factory StoredContact.fromJson(Map<String, dynamic> json) => StoredContact(
        name: json['name'],
        color: json['color'],
      );
}

class _ContactsPageState extends State<ContactsPage> {
  List<StoredContact> _contacts = [];
  late final ScrollController _scrollController1;
  late final ScrollController _scrollController2;
  bool _isHudVisible = false;
  double _overlayHeight = 0.2; // Initial height: 20%

  static const Color _fallbackTileColor = Color(0xFFE0E0E0);
  static const String _storageKey = 'stored_contacts';

  @override
  void initState() {
    super.initState();
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
    _loadContacts();
  }

  Color _colorFromValue(int colorValue) {
    return Color(0xFF000000 | colorValue);
  }

  Color _overlayColorFromValue(int colorValue) {
    // Reverse the color value by reversing the RGB bytes
    final r = (colorValue >> 16) & 0xFF;
    final g = (colorValue >> 8) & 0xFF;
    final b = colorValue & 0xFF;
    // Reverse: swap R and B, keep G
    final reversed = (b << 16) | (g << 8) | r;
    // Apply with some transparency (0x80 = ~50% opacity)
    return Color(0x80000000 | reversed);
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    // Try to load from storage first
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString(_storageKey);
    
    if (storedData != null) {
      // Load from storage
      final List<dynamic> jsonList = json.decode(storedData);
      setState(() {
        _contacts = jsonList
            .map((json) => StoredContact.fromJson(json))
            .toList();
      });
    } else {
      // No stored data, fetch from contacts
      await _fetchContacts();
    }
  }

  Future<void> _saveContacts(List<StoredContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = contacts.map((contact) => contact.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  Future<void> _fetchContacts() async {
    // Request permission
    final status = Permission.contacts.request();
    if (await status.isGranted) {
      // Load contacts
      Iterable<Contact> contacts =
          await ContactsService.getContacts(withThumbnails: false);
      
      // Convert to StoredContact and calculate colors
      final List<StoredContact> storedContacts = contacts
          .where((contact) =>
              contact.phones != null && contact.phones!.isNotEmpty)
          .map((contact) {
        final phone = contact.phones!.first.value ?? '';
        final digits = phone.replaceAll(RegExp(r'\D'), '');
        int colorValue = 0;
        if (digits.isNotEmpty) {
          final hexDigits = digits.length >= 6
              ? digits.substring(digits.length - 6)
              : digits.padLeft(6, '0');
          colorValue = int.tryParse(hexDigits, radix: 16) ?? 0;
        }
        return StoredContact(
          name: contact.displayName ?? 'No Name',
          color: colorValue,
        );
      }).toList();
      
      // Save to storage
      await _saveContacts(storedContacts);
      
      setState(() {
        _contacts = storedContacts;
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

  void _toggleHudVisibility() {
    setState(() {
      _isHudVisible = !_isHudVisible;
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
        return GestureDetector(
          onTap: _toggleHudVisibility,
          onVerticalDragUpdate: (details) {
            _updateOverlayHeight(details.delta.dy, height);
          },
          child: SizedBox(
            height: height,
            child: Card(
              color: _colorFromValue(contact.color),
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
                      color: _overlayColorFromValue(contact.color),
                    ),
                  ),
                  SizedBox.expand(
                    child: _isHudVisible
                        ? Center(
                            child: Text(
                              contact.name,
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
          return Stack(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildListView(_scrollController1, constraints.maxHeight, halfWidth),
                  ),
                  Expanded(
                    child: _buildListView(_scrollController2, constraints.maxHeight, halfWidth),
                  ),
                ],
              ),
              if (_isHudVisible)
                Positioned(
                  top: 0,
                  left: 0,
                  child: IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                    onPressed: () {},
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
            ],
          );
        }));
  }
}
