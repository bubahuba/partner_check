import 'package:flutter/foundation.dart';
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
import '../utils/pro_gate.dart';
import '../utils/self_contact_gradient.dart';
import '../services/pro_subscription_service.dart';
import '../widgets/self_contact_animated_background.dart';
import 'package:provider/provider.dart';
import 'contacts_page.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback? onClose;
  /// Called after bulk import saves contacts, while the loading overlay is still
  /// visible, so the contacts page can refresh before the panel slides away.
  final Future<void> Function()? onPrepareClose;
  final int? selfContactColor;

  const SettingsScreen({
    super.key,
    this.onClose,
    this.onPrepareClose,
    this.selfContactColor,
  });

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  int _loadProgress = 0;
  int _loadTotal = 0;
  bool _vibrationsEnabled = true;
  bool _wasPro = false;
  ProSubscriptionService? _proService;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
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

    _loadVibrationsSetting();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _proService = context.read<ProSubscriptionService>();
      _wasPro = _proService!.isPro;
      _proService!.addListener(_onProStatusChanged);
    });
  }

  void _onProStatusChanged() {
    if (!mounted || _proService == null) return;
    if (_proService!.isPro && !_wasPro) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.purchaseSuccess)),
      );
    }
    _wasPro = _proService!.isPro;
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
    _proService?.removeListener(_onProStatusChanged);
    _slideController.dispose();
    super.dispose();
  }

  Color get _accentColor => widget.selfContactColor != null
      ? SelfContactGradientPalette.fromColorValue(widget.selfContactColor!)
          .inner
      : SelfContactGradientPalette.defaultInner;

  void _openContactsPage() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ContactsPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return buildHorizontalSlideTransition(context, animation, child);
        },
      ),
    );
  }

  void _handleClose() {
    if (widget.onClose != null) {
      _slideController.reverse().then((_) {
        widget.onClose!();
      });
    } else {
      _openContactsPage();
    }
  }

  Future<void> _purchasePro() async {
    final proService = context.read<ProSubscriptionService>();
    final l10n = AppLocalizations.of(context)!;

    if (proService.isPro) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.alreadyPro)),
      );
      return;
    }

    await showUpgradeSheet(context);
  }

  Future<void> _restorePurchases() async {
    final proService = context.read<ProSubscriptionService>();
    final l10n = AppLocalizations.of(context)!;

    await proService.restorePurchases();
    if (!mounted) return;

    if (proService.isPro) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.purchaseSuccess)),
      );
    }
  }

  Widget _buildProSection(double buttonFontSize) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ProSubscriptionService>(
      builder: (context, proService, _) {
        final price = proService.proProduct?.price;
        final upgradeLabel = price != null
            ? '${l10n.upgradeToPro} ($price)'
            : l10n.upgradeToPro;

        return Column(
          children: [
            GestureDetector(
              onLongPress: kDebugMode
                  ? () => proService.debugTogglePro()
                  : null,
              child: Text(
                proService.isPro ? l10n.proVersion : l10n.partnerCheckFree,
                style: TextStyle(
                  fontSize: buttonFontSize * 0.9,
                  color: Colors.white,
                  fontWeight:
                      proService.isPro ? FontWeight.bold : FontWeight.normal,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            if (!proService.isPro) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: proService.isLoading ? null : _purchasePro,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: _accentColor,
                  padding: EdgeInsets.symmetric(
                    horizontal: buttonFontSize * 2,
                    vertical: buttonFontSize * 0.6,
                  ),
                ),
                child: proService.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _accentColor,
                        ),
                      )
                    : Text(
                        upgradeLabel,
                        style: TextStyle(fontSize: buttonFontSize * 0.9),
                      ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: proService.isLoading ? null : _restorePurchases,
                child: Text(
                  l10n.restorePurchases,
                  style: TextStyle(
                    fontSize: buttonFontSize * 0.85,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
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
            final self = storedContacts[index];
            await _storageService.saveSelfContact(
              StoredSelfContact(name: self.name, color: self.color),
            );
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
    final isPro = context.read<ProSubscriptionService>().isPro;
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
                leading: Icon(
                  isPro ? Icons.download : Icons.lock,
                  color: isPro ? Colors.white : Colors.white54,
                ),
                title: Text(
                  l10n.loadAllContacts,
                  style: TextStyle(
                    color: isPro ? Colors.white : Colors.white54,
                  ),
                ),
                subtitle: isPro
                    ? null
                    : Text(
                        l10n.proVersion,
                        style: const TextStyle(color: Colors.white38),
                      ),
                onTap: () async {
                  Navigator.of(context).pop();
                  if (!isPro) {
                    await ensureProForBulkImport(this.context);
                    return;
                  }
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
    final contactCount = (await _storageService.loadContacts()).length;
    if (!mounted) return;
    if (!await ensureCanAddContact(context, contactCount)) {
      return;
    }

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
    final contactCount = (await _storageService.loadContacts()).length;
    if (!mounted) return;
    if (!await ensureCanAddContact(context, contactCount)) {
      return;
    }
    if (!mounted) return;

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
    await _storageService.clearSelfContact();

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
    if (!await ensureProForBulkImport(context)) {
      return;
    }

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

      if (mounted && widget.onPrepareClose != null) {
        await widget.onPrepareClose!();
      }

      if (!mounted) return;

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
    final accent = _accentColor;

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
        body: SelfContactAnimatedBackground(
          selfContactColor: widget.selfContactColor,
          child: SafeArea(
            child: Stack(
              children: [
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
                                foregroundColor: accent,
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
                            _buildProSection(buttonFontSize),
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
                                  _openContactsPage();
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
                                  child: LayoutBuilder(
                                    builder: (context, innerConstraints) {
                                      return SingleChildScrollView(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight:
                                                innerConstraints.maxHeight,
                                          ),
                                          child: Center(
                                            child: textAndButton,
                                          ),
                                        ),
                                      );
                                    },
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
                                  child: SingleChildScrollView(
                                    child: Center(child: textAndButton),
                                  ),
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
            ),
          ),
    );
  }
}
