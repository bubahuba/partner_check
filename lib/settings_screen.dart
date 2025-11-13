import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models.dart';
import 'main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = false;

  // Process contacts in background isolate
  static List<Map<String, dynamic>> _processContacts(List<Map<String, dynamic>> contactsData) {
    return contactsData
        .where((data) => data['phones'] != null && (data['phones'] as List).isNotEmpty)
        .map((data) {
      final phone = (data['phones'] as List).first['value'] ?? '';
      final digits = phone.replaceAll(RegExp(r'\D'), '');
      int colorValue = 0;
      if (digits.isNotEmpty) {
        final hexDigits = digits.length >= 6
            ? digits.substring(digits.length - 6)
            : digits.padLeft(6, '0');
        colorValue = int.tryParse(hexDigits, radix: 16) ?? 0;
      }
      return {
        'name': data['displayName'] ?? 'No Name',
        'color': colorValue,
      };
    }).toList();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final status = await Permission.contacts.request();
      if (status.isGranted) {
        // Request permission for flutter_contacts
        if (await FlutterContacts.requestPermission()) {
          // Load contacts on background thread
          final contacts = await FlutterContacts.getContacts(
            withProperties: true,
            withThumbnail: false,
          );
          
          // Convert to serializable format for isolate
          final contactsData = contacts.map((contact) => {
            'displayName': contact.displayName,
            'phones': contact.phones.map((phone) => {'value': phone.number}).toList(),
          }).toList();

          // Process contacts in background isolate
          final processedData = await compute(_processContacts, contactsData);

          // Convert to StoredContact
          final storedContacts = processedData
              .map((data) => StoredContact(
                    name: data['name'] as String,
                    color: data['color'] as int,
                  ))
              .toList();

          // Save to storage
          final prefs = await SharedPreferences.getInstance();
          final jsonList = storedContacts.map((contact) => contact.toJson()).toList();
          await prefs.setString('stored_contacts', json.encode(jsonList));

          // Navigate to contacts page
          if (mounted) {
            Navigator.of(context).pushReplacement(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const ContactsPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.ease;

                  var tween = Tween(begin: begin, end: end).chain(
                    CurveTween(curve: curve),
                  );

                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          }
        } else {
          setState(() {
            _isLoading = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Contacts permission denied'),
              ),
            );
          }
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contacts permission denied'),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading contacts: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // App icon colors: indigo (#6366F1), pink (#EC4899), blue (#3B82F6)
    const Color indigo = Color(0xFF6366F1);
    const Color pink = Color(0xFFEC4899);
    const Color blue = Color(0xFF3B82F6);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              indigo,
              pink,
              blue,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Smooth color overlay for blur effect
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.transparent,
                    Colors.white.withOpacity(0.05),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left side - App icon
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [indigo, pink, blue],
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Two overlapping circles (partners)
                              Positioned(
                                left: 40,
                                top: 40,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: pink,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 40,
                                top: 40,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: blue,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 3,
                                    ),
                                  ),
                                ),
                              ),
                              // Checkmark
                              const Center(
                                child: Icon(
                                  Icons.check,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 64),
                  // Right side - Text and button
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome to\nPartner Check',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Load your contacts to get started',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white.withOpacity(0.9),
                            shadows: const [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 48),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _loadContacts,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.contacts, size: 24),
                          label: Text(
                            _isLoading ? 'Loading...' : 'Load Contacts',
                            style: const TextStyle(fontSize: 18),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: indigo,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 8,
                            shadowColor: Colors.black.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

