import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models.dart';
import '../l10n/app_localizations.dart';
import 'contacts_page.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onClose;
  
  const SettingsScreen({super.key, this.onClose});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _vibrationsEnabled = true;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  static const String _vibrationsKey = 'vibrations_enabled';
  static const int _maxContacts = 10;

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
    super.dispose();
  }

  void _handleClose() {
    _slideController.reverse().then((_) {
      if (widget.onClose != null) {
        widget.onClose!();
      }
    });
  }

  Future<void> _addContact() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load existing contacts to check limit
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString('stored_contacts');
      List<StoredContact> existingContacts = [];
      
      if (storedData != null) {
        final List<dynamic> jsonList = json.decode(storedData);
        existingContacts = jsonList.map((json) => StoredContact.fromJson(json)).toList();
      }

      // Check contact limit
      if (existingContacts.length >= _maxContacts) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.contactLimitReached),
              content: SingleChildScrollView(
                child: Text(l10n.contactLimitMessage),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.ok),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Request permission if needed
      if (!await FlutterContacts.requestPermission(readonly: true)) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.contactsPermissionRequired),
            ),
          );
        }
        return;
      }

      // Open native contact picker
      final Contact? contact = await FlutterContacts.openExternalPick();
      
      if (contact == null) {
        // User cancelled
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get the contact name
      final contactName = contact.displayName;
      
      if (contactName.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.selectedContactNoName),
            ),
          );
        }
        return;
      }

      // Get phone number (use first available)
      String phoneNumber = '';
      if (contact.phones.isNotEmpty) {
        phoneNumber = contact.phones.first.number;
      }

      // Check if contact has a phone number
      if (contact.phones.isEmpty || phoneNumber.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.noPhoneNumber),
              content: Text(l10n.noPhoneNumberMessage(contactName)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.ok),
                ),
              ],
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

      // Use existing contacts list (already loaded above)
      List<StoredContact> storedContacts = existingContacts;

      // Check for duplicates
      if (storedContacts.any((c) => c.name == contactName)) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.contactAlreadyInList(contactName)),
            ),
          );
        }
        return;
      }

      // Create new contact
      final newContact = StoredContact(
        name: contactName,
        color: colorValue,
      );

      // Add to existing contacts
      storedContacts.add(newContact);

      // Save to storage
      final jsonList = storedContacts.map((contact) => contact.toJson()).toList();
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
            content: Text(l10n.errorAddingContact(e.toString())),
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
          offset: Offset(_slideAnimation.value * MediaQuery.of(context).size.width, 0),
          child: child,
        );
      },
      child: Scaffold(
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
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isPortrait =
                      constraints.maxHeight > constraints.maxWidth;
                  final screenWidth = constraints.maxWidth;
                  final screenHeight = constraints.maxHeight;
                  final minDimension =
                      screenWidth < screenHeight ? screenWidth : screenHeight;

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
                          horizontal: (screenWidth * 0.08).clamp(24.0, 32.0),
                          vertical: (screenHeight * 0.02).clamp(12.0, 16.0),
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

                  Widget textAndButton = Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;
                          return Text(
                            l10n.partnerCheckFree,
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
                          );
                        },
                      ),
                      SizedBox(height: isPortrait ? 32 : 24),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _addContact,
                        icon: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Icon(Icons.person_add, size: 24),
                        label: Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Text(
                              _isLoading ? l10n.adding : l10n.addContact,
                              style: TextStyle(fontSize: buttonFontSize),
                            );
                          },
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: indigo,
                          padding: buttonPadding,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                          shadowColor: Colors.black.withValues(alpha: 0.3),
                        ),
                      ),
                      SizedBox(height: isPortrait ? 24 : 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return Text(
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
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Switch(
                            value: _vibrationsEnabled,
                            onChanged: _toggleVibrations,
                            activeThumbColor: Colors.white,
                            activeTrackColor: Colors.white.withValues(alpha: 0.7),
                            inactiveThumbColor: Colors.white.withValues(alpha: 0.5),
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.3),
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
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const ContactsPage(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
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
                        },
                        child: Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Text(
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
                            );
                          },
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
                          SizedBox(width: isPortrait ? spacing : spacing * 0.5),
                          Expanded(
                            child: textAndButton,
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
