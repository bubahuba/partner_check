import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import 'dart:convert';
import '../models.dart';
import 'contacts_page.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onClose;

  const SettingsScreen({super.key, this.onClose});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  bool _vibrationsEnabled = true;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  late AnimationController _gradientController;
  static const String _vibrationsKey = 'vibrations_enabled';

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.ease),
    );
    // Animate in from the right when first shown
    _slideController.forward();

    // Gradient animation controller - loops infinitely back and forth
    _gradientController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat(reverse: true);

    _loadVibrationsSetting();
  }

  Future<void> _loadVibrationsSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibrationsEnabled = prefs.getBool(_vibrationsKey) ?? true;
    });
  }

  Future<void> _toggleVibrations(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationsKey, value);
    setState(() {
      _vibrationsEnabled = value;
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  Color _interpolateColor(Color a, Color b, double t) {
    return Color.fromRGBO(
      (a.red + (b.red - a.red) * t).round(),
      (a.green + (b.green - a.green) * t).round(),
      (a.blue + (b.blue - a.blue) * t).round(),
      (a.opacity + (b.opacity - a.opacity) * t),
    );
  }

  void _handleClose() {
    _slideController.reverse().then((_) {
      if (widget.onClose != null) {
        widget.onClose!();
      }
    });
  }

  // Process contacts in background isolate
  static List<Map<String, dynamic>> _processContacts(
      List<Map<String, dynamic>> contactsData) {
    return contactsData
        .where((data) =>
            data['phones'] != null && (data['phones'] as List).isNotEmpty)
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

  void _showAddContactMenu() {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.contacts, color: Colors.white),
                title: Text(l10n.addFromDevice,
                    style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickAndAddContactFromDevice();
                },
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: Text(l10n.addManually,
                    style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _addContactManually();
                },
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.download, color: Colors.white),
                title: Text(l10n.loadAllContacts,
                    style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _loadContacts();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndAddContactFromDevice() async {
    try {
      // Request permission if needed
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.contactsPermissionRequired),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: l10n.settings,
                textColor: Colors.black,
                onPressed: () async {
                  await openAppSettings();
                },
              ),
            ),
          );
        }
        return;
      }

      // Open native contact picker
      final Contact? contact = await FlutterContacts.openExternalPick();

      if (contact == null) {
        // User cancelled
        return;
      }

      // Get the contact name
      final contactName = contact.displayName;

      if (contactName.isEmpty) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.selectedContactNoName),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Get phone number
      if (contact.phones.isEmpty) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.noPhoneNumberMessage(contactName)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      final phoneNumber = contact.phones.first.number;

      // Load existing contacts
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('stored_contacts');
      List<StoredContact> existingContacts = [];
      if (storedData != null) {
        final List<dynamic> jsonList = json.decode(storedData);
        existingContacts =
            jsonList.map((json) => StoredContact.fromJson(json)).toList();
      }

      // Check for duplicates
      if (existingContacts.any((c) => c.name == contactName)) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.contactAlreadyInList(contactName)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
      }

      // Calculate color from phone number
      final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
      int colorValue = 0;
      if (digits.isNotEmpty) {
        final hexDigits = digits.length >= 6
            ? digits.substring(digits.length - 6)
            : digits.padLeft(6, '0');
        colorValue = int.tryParse(hexDigits, radix: 16) ?? 0;
      }

      // Create new contact
      final newContact = StoredContact(
        name: contactName,
        color: colorValue,
      );

      // Add to existing contacts
      existingContacts.add(newContact);

      // Save to storage
      final jsonList =
          existingContacts.map((contact) => contact.toJson()).toList();
      await prefs.setString('stored_contacts', json.encode(jsonList));

      // Close settings screen
      if (mounted) {
        if (widget.onClose != null) {
          _handleClose();
        } else {
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
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorPickingContact(e.toString())),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _addContactManually() async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.addContactManually),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.name,
                hintText: l10n.enterContactName,
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                labelText: l10n.phoneNumber,
                hintText: l10n.enterPhoneNumber,
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();
              if (name.isNotEmpty && phone.isNotEmpty) {
                Navigator.of(context).pop({'name': name, 'phone': phone});
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );

    if (result == null) return;

    final contactName = result['name']!;
    final phoneNumber = result['phone']!;

    // Load existing contacts
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString('stored_contacts');
    List<StoredContact> existingContacts = [];
    if (storedData != null) {
      final List<dynamic> jsonList = json.decode(storedData);
      existingContacts =
          jsonList.map((json) => StoredContact.fromJson(json)).toList();
    }

    // Check for duplicates
    if (existingContacts.any((c) => c.name == contactName)) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.contactAlreadyInList(contactName)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Calculate color from phone number
    final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
    int colorValue = 0;
    if (digits.isNotEmpty) {
      final hexDigits = digits.length >= 6
          ? digits.substring(digits.length - 6)
          : digits.padLeft(6, '0');
      colorValue = int.tryParse(hexDigits, radix: 16) ?? 0;
    }

    // Create new contact
    final newContact = StoredContact(
      name: contactName,
      color: colorValue,
    );

    // Add to existing contacts
    existingContacts.add(newContact);

    // Save to storage
    final jsonList =
        existingContacts.map((contact) => contact.toJson()).toList();
    await prefs.setString('stored_contacts', json.encode(jsonList));

    // Close settings screen
    if (mounted) {
      if (widget.onClose != null) {
        _handleClose();
      } else {
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
    }
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Request permission using flutter_contacts (works on both iOS and Android)
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.contactsPermissionRequired),
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: l10n.settings,
                textColor: Colors.black,
                onPressed: () async {
                  // Open app settings to allow user to enable permission
                  await openAppSettings();
                },
              ),
            ),
          );
        }
        return;
      }

      // Load contacts on background thread
      final contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withThumbnail: false,
      );

      // Convert to serializable format for isolate
      final contactsData = contacts
          .map((contact) => {
                'displayName': contact.displayName,
                'phones': contact.phones
                    .map((phone) => {'value': phone.number})
                    .toList(),
              })
          .toList();

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
      final jsonList =
          storedContacts.map((contact) => contact.toJson()).toList();
      await prefs.setString('stored_contacts', json.encode(jsonList));

      setState(() {
        _isLoading = false;
      });

      // Close settings screen and reload contacts in ContactsPage
      if (mounted) {
        if (widget.onClose != null) {
          _handleClose();
        } else {
          // Fallback to navigation if onClose is not provided (for InitialScreen)
          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const ContactsPage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
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
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorLoadingContacts(e.toString())),
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

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
              _slideAnimation.value * MediaQuery.of(context).size.width, 0),
          child: child,
        );
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: AnimatedBuilder(
          animation: _gradientController,
          builder: (context, child) {
            // Calculate animated colors based on gradient animation
            final t = _gradientController.value;
            // Cycle through: indigo -> pink -> blue -> indigo
            Color color1, color2, color3;
            if (t < 0.33) {
              // Transition from indigo to pink
              final localT = t / 0.33;
              color1 = _interpolateColor(indigo, pink, localT);
              color2 = pink;
              color3 = blue;
            } else if (t < 0.66) {
              // Transition from pink to blue
              final localT = (t - 0.33) / 0.33;
              color1 = pink;
              color2 = _interpolateColor(pink, blue, localT);
              color3 = blue;
            } else {
              // Transition from blue back to indigo
              final localT = (t - 0.66) / 0.34;
              color1 = pink;
              color2 = blue;
              color3 = _interpolateColor(blue, indigo, localT);
            }

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color1, color2, color3],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Smooth color overlay for blur effect
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.1),
                            Colors.transparent,
                            Colors.white.withValues(alpha: 0.05),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                    // Back arrow button at the same position as HUD settings button
                    Positioned(
                      top: 10,
                      left: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: _handleClose,
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                    // Content
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isPortrait =
                            constraints.maxHeight > constraints.maxWidth;
                        final screenWidth = constraints.maxWidth;
                        final screenHeight = constraints.maxHeight;
                        final minDimension = screenWidth < screenHeight
                            ? screenWidth
                            : screenHeight;

                        // Responsive sizing based on screen dimensions
                        final padding = isPortrait
                            ? (minDimension * 0.04).clamp(16.0, 24.0)
                            : (minDimension * 0.04).clamp(16.0, 24.0);
                        final iconSize = isPortrait
                            ? (minDimension * 0.3).clamp(100.0, 150.0)
                            : (minDimension * 0.2).clamp(80.0, 120.0);
                        final fontSize = isPortrait
                            ? (screenWidth * 0.08).clamp(20.0, 32.0)
                            : (screenHeight * 0.05).clamp(18.0, 24.0);
                        final spacing = isPortrait
                            ? (screenHeight * 0.04).clamp(16.0, 32.0)
                            : (screenWidth * 0.04).clamp(16.0, 32.0);
                        final buttonPadding = isPortrait
                            ? EdgeInsets.symmetric(
                                horizontal:
                                    (screenWidth * 0.08).clamp(24.0, 32.0),
                                vertical:
                                    (screenHeight * 0.02).clamp(12.0, 16.0),
                              )
                            : const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10);
                        final buttonFontSize = isPortrait
                            ? (screenWidth * 0.035).clamp(14.0, 16.0)
                            : (screenHeight * 0.025).clamp(16.0, 18.0);

                        Widget iconWidget = Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/app_icon.png',
                              width: iconSize,
                              height: iconSize,
                              fit: BoxFit.cover,
                            ),
                          ),
                        );

                        final l10n = AppLocalizations.of(context)!;
                        Widget textAndButton = Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              l10n.appTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                                shadows: const [
                                  Shadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: isPortrait ? 52 : 24),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _showAddContactMenu,
                              icon: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.contacts, size: 24),
                              label: Text(
                                _isLoading ? l10n.loading : l10n.addContact,
                                style: TextStyle(fontSize: buttonFontSize),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: indigo,
                                padding: buttonPadding,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 8,
                                shadowColor:
                                    Colors.black.withValues(alpha: 0.3),
                              ),
                            ),
                            SizedBox(height: isPortrait ? 24 : 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.vibrations,
                                  style: TextStyle(
                                    fontSize: buttonFontSize * 0.9,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Switch(
                                  value: _vibrationsEnabled,
                                  onChanged: _toggleVibrations,
                                  activeThumbColor: Colors.white,
                                  activeTrackColor:
                                      Colors.white.withValues(alpha: 0.7),
                                  inactiveThumbColor:
                                      Colors.white.withValues(alpha: 0.5),
                                  inactiveTrackColor:
                                      Colors.white.withValues(alpha: 0.3),
                                ),
                              ],
                            ),
                            SizedBox(height: isPortrait ? 24 : 16),
                            TextButton(
                              onPressed: () {
                                if (widget.onClose != null) {
                                  _handleClose();
                                } else {
                                  // Fallback to navigation if onClose is not provided (for InitialScreen)
                                  Navigator.of(context).pushReplacement(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                              secondaryAnimation) =>
                                          const ContactsPage(),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        const begin = Offset(1.0, 0.0);
                                        const end = Offset.zero;
                                        const curve = Curves.ease;

                                        var tween =
                                            Tween(begin: begin, end: end).chain(
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
                              },
                              child: Text(
                                l10n.close,
                                style: TextStyle(
                                  fontSize: buttonFontSize * 0.9,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  decoration: TextDecoration.underline,
                                  shadows: const [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );

                        if (isPortrait) {
                          // Portrait layout: Column
                          return Padding(
                            padding: EdgeInsets.all(padding),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 40),
                                iconWidget,
                                SizedBox(height: spacing),
                                Expanded(
                                  child: Center(
                                    child: textAndButton,
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          // Landscape layout: Row
                          return Padding(
                            padding: EdgeInsets.all(padding),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Center(child: iconWidget),
                                ),
                                SizedBox(
                                    width:
                                        isPortrait ? spacing : spacing * 0.5),
                                Expanded(
                                  child: textAndButton,
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
