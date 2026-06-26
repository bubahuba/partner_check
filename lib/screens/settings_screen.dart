import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/contacts_permission.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import 'dart:convert';
import '../models.dart';
import '../services/contact_storage_service.dart';
import '../utils/directionality_utils.dart';
import '../utils/self_contact_finder.dart';
import '../utils/phone_utils.dart';
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
  int _loadProgress = 0;
  int _loadTotal = 0;
  bool _vibrationsEnabled = true;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  late AnimationController _gradientController;
  static const String _vibrationsKey = 'vibrations_enabled';
  final ContactStorageService _storageService = ContactStorageService();

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
    return Color.lerp(a, b, t)!;
  }

  void _handleClose() {
    _slideController.reverse().then((_) {
      if (widget.onClose != null) {
        widget.onClose!();
      }
    });
  }

  // Process a single device contact into stored form, or null if no phone.
  static StoredContact? _storedContactFromDeviceContact(Contact contact) {
    if (contact.phones.isEmpty) return null;
    final name = contact.displayName ?? '';
    return StoredContact(
      name: name.isNotEmpty ? name : 'No Name',
      color: PhoneUtils.colorFromPhoneNumber(contact.phones.first.number),
    );
  }

  void _resetLoadProgress() {
    _loadProgress = 0;
    _loadTotal = 0;
  }

  void _updateLoadProgress(int current, int total) {
    if (!mounted) return;
    setState(() {
      _loadProgress = current;
      _loadTotal = total;
    });
  }

  Future<void> _applyInitialSelfContactScroll(
      List<StoredContact> storedContacts) async {
    var page1All = 0;

    if (Platform.isAndroid) {
      try {
        final me = await FlutterContacts.profile.get(
          properties: contactsNameAndPhoneProperties,
        );
        if (me != null) {
          final index = SelfContactFinder.findIndexForContact(
            storedContacts,
            me,
          );
          if (index != null) {
            page1All = index;
          }
        }
      } catch (_) {
        // Profile unavailable on this device; keep default scroll.
      }
      await _storageService.savePendingSelfContactPick(false);
    } else if (Platform.isIOS) {
      await _storageService.savePendingSelfContactPick(true);
    }

    await _storageService.saveScrollPositions(ScrollPositions(
      page1All: page1All,
      page2All: 0,
      page1Favorites: 0,
      page2Favorites: 0,
    ));
    await _storageService.markContactsBulkLoaded();
  }

  Widget _buildLoadContactsOverlay() {
    final l10n = AppLocalizations.of(context)!;
    final hasTotal = _loadTotal > 0;
    final progressValue =
        hasTotal ? (_loadProgress / _loadTotal).clamp(0.0, 1.0) : null;

    return AbsorbPointer(
      child: Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 280,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasTotal)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 8,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  const SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  hasTotal
                      ? l10n.loadingContactsProgress(
                          _loadProgress, _loadTotal)
                      : l10n.loadingContactsFromDevice,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      if (!await ensureContactsReadPermission()) {
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
      final Contact? contact = await pickContactWithNameAndPhone();

      if (contact == null) {
        // User cancelled
        return;
      }

      // Get the contact name
      final contactName = contact.displayName ?? '';

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
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return buildHorizontalSlideTransition(
                    context, animation, child);
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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.addContactManually,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
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
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return buildHorizontalSlideTransition(
                  context, animation, child);
            },
          ),
        );
      }
    }
  }

  Future<void> _deleteAllContacts() async {
    final l10n = AppLocalizations.of(context)!;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deleteAllContacts,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(l10n.deleteAllContactsConfirm),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    // Clear all contacts and related data
    await _storageService.saveContacts([]);
    await _storageService.saveFavorites({});
    await _storageService.saveScrollPositions(ScrollPositions(
      page1All: 0,
      page2All: 0,
      page1Favorites: 0,
      page2Favorites: 0,
    ));
    await _storageService.saveLockedPane(null);
    await _storageService.saveOrderingContact(null);
    await _storageService.clearOriginalContactOrder();
    await _storageService.savePendingSelfContactPick(false);

    // Close settings screen and navigate to contacts page
    if (mounted) {
      if (widget.onClose != null) {
        _handleClose();
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const ContactsPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return buildHorizontalSlideTransition(
                  context, animation, child);
            },
          ),
        );
      }
    }
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _resetLoadProgress();
    });

    try {
      // Request permission using flutter_contacts (works on both iOS and Android)
      if (!await ensureContactsReadPermission()) {
        setState(() {
          _isLoading = false;
          _resetLoadProgress();
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

      // Load contacts from device (no count available until complete)
      final contacts = await FlutterContacts.getAll(
        properties: contactsNameAndPhoneProperties,
      );

      final total = contacts.length;
      _updateLoadProgress(0, total);

      final storedContacts = <StoredContact>[];
      const batchSize = 50;
      for (var i = 0; i < contacts.length; i++) {
        final stored = _storedContactFromDeviceContact(contacts[i]);
        if (stored != null) {
          storedContacts.add(stored);
        }

        final processed = i + 1;
        if (processed % batchSize == 0 || processed == total) {
          _updateLoadProgress(processed, total);
          await Future<void>.delayed(Duration.zero);
        }
      }

      // Save to storage
      await _storageService.saveContacts(storedContacts);
      await _applyInitialSelfContactScroll(storedContacts);

      setState(() {
        _isLoading = false;
        _resetLoadProgress();
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
                return buildHorizontalSlideTransition(
                    context, animation, child);
              },
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _resetLoadProgress();
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
          offset: horizontalPanelSlideOffset(context, _slideAnimation.value),
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
                            SizedBox(height: isPortrait ? 32 : 24),
                            ElevatedButton.icon(
                              onPressed:
                                  _isLoading ? null : _showAddContactMenu,
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
                            ElevatedButton.icon(
                              onPressed: _deleteAllContacts,
                              icon: const Icon(Icons.delete, color: Colors.white),
                              label: Text(
                                l10n.deleteAllContacts,
                                style: TextStyle(
                                  fontSize: buttonFontSize * 0.9,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
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
                                        return buildHorizontalSlideTransition(
                                            context, animation, child);
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
                    if (_isLoading) _buildLoadContactsOverlay(),
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
