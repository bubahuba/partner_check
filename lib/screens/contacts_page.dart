import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../l10n/app_localizations.dart';
import 'dart:convert';
import '../models.dart';
import '../utils/color_utils.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  ContactsPageState createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage>
    with TickerProviderStateMixin {
  List<StoredContact> _contacts = [];
  late final ScrollController _scrollController1;
  late final ScrollController _scrollController2;
  bool _isHudVisible = true; // Show HUD by default
  double _overlayHeight = 0.2; // Initial height: 20%
  int _currentPage1 = 0;
  int _currentPage2 = 0;
  // Separate scroll positions for each mode
  int _currentPage1All = 0;
  int _currentPage2All = 0;
  int _currentPage1Favorites = 0;
  int _currentPage2Favorites = 0;
  double? _lastWidth1;
  double? _lastWidth2;
  bool _showSettings = false;
  bool _showAbout = false;
  bool _favoritesMode = false;
  Set<String> _favoriteNames = {};
  late AnimationController _heartAnimationController;
  late AnimationController _flashAnimationController1;
  late AnimationController _flashAnimationController2;
  bool _isMatch = false;
  bool _baseMatch1 = false;
  bool _overlayMatch1 = false;
  bool _baseMatch2 = false;
  bool _overlayMatch2 = false;
  // Track which specific match type is currently flashing for each card
  String? _activeFlashType1; // 'base', 'overlay', 'cross1', 'cross2', or null
  String? _activeFlashType2;
  // Track if name should be shown for flash (when match detected)
  bool _showNameFlash1 = false;
  bool _showNameFlash2 = false;
  // Track which pane was last scrolled
  ScrollController? _lastScrolledController;

  static const String _storageKey = 'stored_contacts';
  static const String _favoritesKey = 'favorite_contacts';
  static const String _vibrationsKey = 'vibrations_enabled';
  static const String _hudVisibleKey = 'hud_visible';
  static const String _scrollPos1AllKey = 'scroll_pos_1_all';
  static const String _scrollPos2AllKey = 'scroll_pos_2_all';
  static const String _scrollPos1FavoritesKey = 'scroll_pos_1_favorites';
  static const String _scrollPos2FavoritesKey = 'scroll_pos_2_favorites';
  bool _vibrationsEnabled = true;

  @override
  void initState() {
    super.initState();
    // Initialize scroll controllers with initial offset of 0 to ensure ListView renders
    _scrollController1 = ScrollController(initialScrollOffset: 0.0);
    _scrollController2 = ScrollController(initialScrollOffset: 0.0);
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _flashAnimationController1 = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flashAnimationController2 = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _addScrollListeners();
    _initializeData();
    // Check for initial match after everything is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForMatch();
      // Ensure ListView is visible on initial launch with no contacts
      if (_contacts.isEmpty) {
        // Add multiple callbacks to ensure ListView renders
        Future.delayed(const Duration(milliseconds: 50), () {
          if (mounted) {
            if (_scrollController1.hasClients) {
              _scrollController1.jumpTo(0);
            }
            if (_scrollController2.hasClients) {
              _scrollController2.jumpTo(0);
            }
            setState(() {
              // Force rebuild to ensure ListView renders
            });
          }
        });
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && _contacts.isEmpty) {
            if (_scrollController1.hasClients) {
              _scrollController1.jumpTo(0);
            }
            if (_scrollController2.hasClients) {
              _scrollController2.jumpTo(0);
            }
            setState(() {
              // Force another rebuild to ensure ListView renders
            });
          }
        });
      }
    });
  }

  void _addScrollListeners() {
    _scrollController1.addListener(() {
      if (_scrollController1.hasClients) {
        final width = _scrollController1.position.viewportDimension;
        if (width > 0) {
          final displayedContacts = _displayedContacts;
          final totalItems = displayedContacts.length +
              2; // +2 for plus buttons at start and end
          final page = (_scrollController1.offset / width)
              .round()
              .clamp(0, totalItems - 1);
          // Skip plus button at index 0, convert to contact index
          if (page > 0 && page <= displayedContacts.length) {
            final contactIndex = page - 1;
            if (contactIndex != _currentPage1) {
              setState(() {
                _currentPage1 = contactIndex;
                // Save to mode-specific position
                if (_favoritesMode) {
                  _currentPage1Favorites = contactIndex;
                } else {
                  _currentPage1All = contactIndex;
                }
                // Track that this pane was scrolled
                _lastScrolledController = _scrollController1;
              });
              _saveScrollPositions();
              _checkForMatch();
            }
          }
        }
      }
    });

    _scrollController2.addListener(() {
      if (_scrollController2.hasClients) {
        final width = _scrollController2.position.viewportDimension;
        if (width > 0) {
          final displayedContacts = _displayedContacts;
          final totalItems = displayedContacts.length +
              2; // +2 for plus buttons at start and end
          final page = (_scrollController2.offset / width)
              .round()
              .clamp(0, totalItems - 1);
          // Skip plus button at index 0, convert to contact index
          if (page > 0 && page <= displayedContacts.length) {
            final contactIndex = page - 1;
            if (contactIndex != _currentPage2) {
              setState(() {
                _currentPage2 = contactIndex;
                // Save to mode-specific position
                if (_favoritesMode) {
                  _currentPage2Favorites = contactIndex;
                } else {
                  _currentPage2All = contactIndex;
                }
                // Track that this pane was scrolled
                _lastScrolledController = _scrollController2;
              });
              _saveScrollPositions();
              _checkForMatch();
            }
          }
        }
      }
    });
  }

  // Check if a scroll controller is currently on a plus button card
  bool _isOnPlusButton(
      ScrollController controller, List<StoredContact> displayedContacts) {
    if (!controller.hasClients) return false;
    final width = controller.position.viewportDimension;
    if (width <= 0) return false;
    final page = (controller.offset / width).round();
    // Plus buttons are at index 0 (start) and index displayedContacts.length + 1 (end)
    return page == 0 || page == displayedContacts.length + 1;
  }

  // Flash a specific match type with delay
  void _flashMatchType(String matchType, int delayMs) {
    Future.delayed(Duration(milliseconds: delayMs), () {
      if (!mounted) return;

      setState(() {
        // Determine which areas to flash based on match type
        switch (matchType) {
          case 'base':
            // Flash base areas of both cards
            _activeFlashType1 = 'base';
            _activeFlashType2 = 'base';
            break;
          case 'overlay':
            // Flash overlay areas of both cards
            _activeFlashType1 = 'overlay';
            _activeFlashType2 = 'overlay';
            break;
          case 'cross1':
            // Flash overlay of card1 and base of card2
            _activeFlashType1 = 'overlay';
            _activeFlashType2 = 'base';
            break;
          case 'cross2':
            // Flash base of card1 and overlay of card2
            _activeFlashType1 = 'base';
            _activeFlashType2 = 'overlay';
            break;
        }
      });

      // Trigger flash animations
      _flashAnimationController1.forward().then((_) {
        _flashAnimationController1.reverse().then((_) {
          if (mounted) {
            setState(() {
              _activeFlashType1 = null;
            });
          }
        });
      });
      _flashAnimationController2.forward().then((_) {
        _flashAnimationController2.reverse().then((_) {
          if (mounted) {
            setState(() {
              _activeFlashType2 = null;
            });
          }
        });
      });
    });
  }

  // Check for match between current pair and trigger animation
  void _checkForMatch() {
    final displayedContacts = _displayedContacts;

    // Check if either ListView is on a plus button card
    if (_isOnPlusButton(_scrollController1, displayedContacts) ||
        _isOnPlusButton(_scrollController2, displayedContacts)) {
      if (_isMatch) {
        setState(() {
          _isMatch = false;
        });
        _heartAnimationController.stop();
        _heartAnimationController.reset();
      }
      return;
    }

    if (displayedContacts.isEmpty ||
        _currentPage1 >= displayedContacts.length ||
        _currentPage2 >= displayedContacts.length) {
      if (_isMatch) {
        setState(() {
          _isMatch = false;
        });
        _heartAnimationController.stop();
        _heartAnimationController.reset();
      }
      return;
    }

    final contact1 =
        displayedContacts[_currentPage1.clamp(0, displayedContacts.length - 1)];
    final contact2 =
        displayedContacts[_currentPage2.clamp(0, displayedContacts.length - 1)];

    // If same contact, always match
    bool newMatch = false;
    bool baseMatch = false;
    bool overlayMatch = false;
    bool crossMatch1 = false;
    bool crossMatch2 = false;

    if (contact1.color == contact2.color) {
      newMatch = false;
    } else {
      final color1 = ColorUtils.colorFromValue(contact1.color);
      final color2 = ColorUtils.colorFromValue(contact2.color);
      final overlay1 = ColorUtils.overlayColorFromValue(contact1.color);
      final overlay2 = ColorUtils.overlayColorFromValue(contact2.color);

      // Check if base colors match or overlay colors match
      baseMatch = ColorUtils.areColorsMatching(color1, color2).$1;
      overlayMatch = ColorUtils.areColorsMatching(overlay1, overlay2).$1;

      // Cross-match: overlay of one contact with base of the other
      crossMatch1 = ColorUtils.areColorsMatching(overlay1, color2).$1;
      crossMatch2 = ColorUtils.areColorsMatching(color1, overlay2).$1;

      newMatch = baseMatch || overlayMatch || crossMatch1 || crossMatch2;
    }

    // Determine which areas to highlight for each card
    // Card 1: base matches if baseMatch or crossMatch2, overlay matches if overlayMatch or crossMatch1
    final baseMatch1 = baseMatch || crossMatch2;
    final overlayMatch1 = overlayMatch || crossMatch1;
    // Card 2: base matches if baseMatch or crossMatch1, overlay matches if overlayMatch or crossMatch2
    final baseMatch2 = baseMatch || crossMatch1;
    final overlayMatch2 = overlayMatch || crossMatch2;

    // Stop any existing animations
    if (_heartAnimationController.isAnimating) {
      _heartAnimationController.stop();
    }
    _heartAnimationController.reset();

    setState(() {
      _isMatch = newMatch;
      _baseMatch1 = baseMatch1;
      _overlayMatch1 = overlayMatch1;
      _baseMatch2 = baseMatch2;
      _overlayMatch2 = overlayMatch2;

      // Show name flash only in the pane that was last scrolled when match is detected
      if (newMatch) {
        // Only flash in the pane that was last scrolled, or default to pane 1 if none tracked
        if (_lastScrolledController == _scrollController1) {
          _showNameFlash1 = true;
          _showNameFlash2 = false;
        } else if (_lastScrolledController == _scrollController2) {
          _showNameFlash1 = false;
          _showNameFlash2 = true;
        } else {
          // Default to pane 1 if no scroll has been tracked yet
          _showNameFlash1 = true;
          _showNameFlash2 = false;
        }
        // Hide after 0.5 seconds
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() {
              _showNameFlash1 = false;
              _showNameFlash2 = false;
            });
          }
        });
      } else {
        _showNameFlash1 = false;
        _showNameFlash2 = false;
      }
    });

    if (newMatch) {
      // Trigger animation and haptic feedback
      _heartAnimationController.repeat(reverse: true);

      // Count number of matches and collect match types in order
      List<String> matchTypes = [];
      if (baseMatch) matchTypes.add('base');
      if (overlayMatch) matchTypes.add('overlay');
      if (crossMatch1) matchTypes.add('cross1');
      if (crossMatch2) matchTypes.add('cross2');

      int matchCount = matchTypes.length;

      // Flash matches in sequence with the same delays as vibrations
      if (matchCount == 1) {
        // Single match - flash immediately
        _flashMatchType(matchTypes[0], 0);
        if (_vibrationsEnabled) {
          HapticFeedback.vibrate();
        }
      } else if (matchCount >= 2) {
        // Multiple matches - flash in sequence
        _flashMatchType(matchTypes[0], 0);
        if (_vibrationsEnabled) {
          HapticFeedback.vibrate();
        }

        _flashMatchType(matchTypes[1], 600);
        if (_vibrationsEnabled) {
          Future.delayed(const Duration(milliseconds: 600), () {
            HapticFeedback.vibrate();
          });
        }

        if (matchCount >= 3) {
          _flashMatchType(matchTypes[2], 1200);
          if (_vibrationsEnabled) {
            Future.delayed(const Duration(milliseconds: 1200), () {
              HapticFeedback.vibrate();
            });
          }
        }

        if (matchCount >= 4) {
          _flashMatchType(matchTypes[3], 1800);
          if (_vibrationsEnabled) {
            Future.delayed(const Duration(milliseconds: 1800), () {
              HapticFeedback.vibrate();
            });
          }
        }
      }
    } else {
      // Reset flash animations
      _flashAnimationController1.reset();
      _flashAnimationController2.reset();
      setState(() {
        _activeFlashType1 = null;
        _activeFlashType2 = null;
      });
    }
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    _heartAnimationController.dispose();
    _flashAnimationController1.dispose();
    _flashAnimationController2.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    // Load favorites first, then contacts (so contacts can be updated with favorite status)
    await _loadFavorites();
    await _loadScrollPositions();
    await _loadHudState();
    await _loadContacts();
  }

  Future<void> _loadContacts() async {
    // Load from storage
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString(_storageKey);

    if (storedData != null) {
      final List<dynamic> jsonList = json.decode(storedData);
      setState(() {
        _contacts =
            jsonList.map((json) => StoredContact.fromJson(json)).toList();
        // Update favorites from loaded contacts
        _updateFavoritesFromContacts();
      });
      // Restore scroll positions from storage
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final displayedContacts = _displayedContacts;
        if (displayedContacts.isNotEmpty) {
          // Restore scroll positions based on current mode
          final targetPage1 =
              _favoritesMode ? _currentPage1Favorites : _currentPage1All;
          final targetPage2 =
              _favoritesMode ? _currentPage2Favorites : _currentPage2All;

          // Clamp to valid range
          final maxIndex = displayedContacts.length - 1;
          final clampedPage1 = targetPage1.clamp(0, maxIndex);
          final clampedPage2 = targetPage2.clamp(0, maxIndex);

          if (_scrollController1.hasClients) {
            final width = _scrollController1.position.viewportDimension;
            if (width > 0) {
              // Convert contact index to page index (add 1 for plus button at index 0)
              final targetPage = clampedPage1 + 1;
              _scrollController1.jumpTo(targetPage * width);
              setState(() {
                _currentPage1 = clampedPage1;
              });
            }
          }
          if (_scrollController2.hasClients) {
            final width = _scrollController2.position.viewportDimension;
            if (width > 0) {
              // Convert contact index to page index (add 1 for plus button at index 0)
              final targetPage = clampedPage2 + 1;
              _scrollController2.jumpTo(targetPage * width);
              setState(() {
                _currentPage2 = clampedPage2;
              });
            }
          }
        } else {
          // No contacts, scroll to plus button (index 0)
          if (_scrollController1.hasClients) {
            _scrollController1.jumpTo(0);
          }
          if (_scrollController2.hasClients) {
            _scrollController2.jumpTo(0);
          }
        }
        _checkForMatch();
      });
    } else {
      // No stored data - first launch, ensure scroll controllers are at position 0
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController1.hasClients) {
          _scrollController1.jumpTo(0);
        }
        if (_scrollController2.hasClients) {
          _scrollController2.jumpTo(0);
        }
      });
    }

    // Load vibrations setting
    setState(() {
      _vibrationsEnabled = prefs.getBool(_vibrationsKey) ?? true;
    });
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesList = prefs.getStringList(_favoritesKey);
    if (favoritesList != null) {
      setState(() {
        _favoriteNames = favoritesList.toSet();
      });
    }
  }

  Future<void> _loadVibrationsSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _vibrationsEnabled = prefs.getBool(_vibrationsKey) ?? true;
    });
  }

  Future<void> _loadHudState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isHudVisible = prefs.getBool(_hudVisibleKey) ?? true; // Default to visible
    });
  }

  Future<void> _saveHudState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hudVisibleKey, _isHudVisible);
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favoriteNames.toList());
  }

  Future<void> _saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _contacts.map((contact) => contact.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  Future<void> _saveScrollPositions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scrollPos1AllKey, _currentPage1All);
    await prefs.setInt(_scrollPos2AllKey, _currentPage2All);
    await prefs.setInt(_scrollPos1FavoritesKey, _currentPage1Favorites);
    await prefs.setInt(_scrollPos2FavoritesKey, _currentPage2Favorites);
  }

  Future<void> _loadScrollPositions() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentPage1All = prefs.getInt(_scrollPos1AllKey) ?? 0;
      _currentPage2All = prefs.getInt(_scrollPos2AllKey) ?? 0;
      _currentPage1Favorites = prefs.getInt(_scrollPos1FavoritesKey) ?? 0;
      _currentPage2Favorites = prefs.getInt(_scrollPos2FavoritesKey) ?? 0;
    });
  }

  Future<void> _pickAndAddContactFromDevice(
      {required ScrollController targetController,
      bool addAtStart = false}) async {
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
                textColor: Colors.white,
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

      // Check for duplicates
      if (_contacts.any((c) => c.name == contactName)) {
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.contactAlreadyInList(contactName)),
              duration: const Duration(seconds: 2),
            ),
          );

          // Scroll to the duplicate contact in the target ListView
          final displayedContacts = _displayedContacts;
          final duplicateIndex =
              displayedContacts.indexWhere((c) => c.name == contactName);
          if (duplicateIndex != -1 && targetController.hasClients) {
            final width = targetController.position.viewportDimension;
            if (width > 0) {
              // Convert contact index to page index (add 1 for plus button at index 0)
              final targetPage = duplicateIndex + 1;
              targetController.animateTo(
                targetPage * width,
                duration: const Duration(milliseconds: 300),
                curve: Curves.ease,
              );

              // Update current page state
              if (targetController == _scrollController1) {
                setState(() {
                  _currentPage1 = duplicateIndex;
                  if (_favoritesMode) {
                    _currentPage1Favorites = duplicateIndex;
                  } else {
                    _currentPage1All = duplicateIndex;
                  }
                });
              } else if (targetController == _scrollController2) {
                setState(() {
                  _currentPage2 = duplicateIndex;
                  if (_favoritesMode) {
                    _currentPage2Favorites = duplicateIndex;
                  } else {
                    _currentPage2All = duplicateIndex;
                  }
                });
              }

              // Save scroll positions
              _saveScrollPositions();
            }
          }
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

      // Create new contact
      final newContact = StoredContact(
        name: contactName,
        color: colorValue,
        isFavorite: _favoriteNames.contains(contactName),
      );

      // Add to contacts list at the beginning or end
      setState(() {
        if (addAtStart) {
          _contacts.insert(0, newContact);
        } else {
          _contacts.add(newContact);
        }
        _updateFavoritesFromContacts();
      });

      // Save to storage
      await _saveContacts();

      // Scroll to the new contact only in the target ListView
      final displayedContacts = _displayedContacts;
      final newIndex = addAtStart ? 0 : displayedContacts.length - 1;

      if (targetController == _scrollController1) {
        if (_scrollController1.hasClients && newIndex >= 0) {
          final width = _scrollController1.position.viewportDimension;
          if (width > 0) {
            _scrollController1.animateTo(
              (newIndex + 1) * width, // +1 because index 0 is plus button
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
            setState(() {
              _currentPage1 = newIndex;
              // Update mode-specific position
              if (_favoritesMode) {
                _currentPage1Favorites = newIndex;
              } else {
                _currentPage1All = newIndex;
              }
            });
          }
        }
      } else if (targetController == _scrollController2) {
        if (_scrollController2.hasClients && newIndex >= 0) {
          final width = _scrollController2.position.viewportDimension;
          if (width > 0) {
            _scrollController2.animateTo(
              (newIndex + 1) * width, // +1 because index 0 is plus button
              duration: const Duration(milliseconds: 300),
              curve: Curves.ease,
            );
            setState(() {
              _currentPage2 = newIndex;
              // Update mode-specific position
              if (_favoritesMode) {
                _currentPage2Favorites = newIndex;
              } else {
                _currentPage2All = newIndex;
              }
            });
          }
        }
      }

      // Check for match after adding
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForMatch();
      });
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

  Future<void> _editContact(StoredContact contact) async {
    final nameController = TextEditingController(text: contact.name);
    final phoneController = TextEditingController();

    // We need to reverse-engineer the phone number from the color
    // Since we don't store the phone number, we'll just show an empty field
    // and let the user enter a new one if they want to change the color

    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.editContact),
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
                labelText: l10n.phoneNumberOptional,
                hintText: l10n.enterPhoneNumberToChangeColor,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.leavePhoneEmptyKeepColor,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
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
              if (name.isNotEmpty) {
                Navigator.of(context).pop({
                  'name': name,
                  'phone': phoneController.text.trim(),
                });
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (result == null) return;

    final newName = result['name']!;
    final phoneNumber = result['phone']!;

    // Check for duplicates (excluding the current contact)
    if (_contacts.any((c) => c.name == newName && c.name != contact.name)) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.contactAlreadyInList(newName)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Calculate new color if phone number is provided, otherwise keep the old one
    int newColorValue = contact.color;
    if (phoneNumber.isNotEmpty) {
      final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (digits.isNotEmpty) {
        final hexDigits = digits.length >= 6
            ? digits.substring(digits.length - 6)
            : digits.padLeft(6, '0');
        newColorValue = int.tryParse(hexDigits, radix: 16) ?? contact.color;
      }
    }

    // Update contact in the list
    setState(() {
      final index = _contacts.indexWhere((c) => c.name == contact.name);
      if (index != -1) {
        // Update favorite name if the name changed
        if (contact.name != newName && _favoriteNames.contains(contact.name)) {
          _favoriteNames.remove(contact.name);
          _favoriteNames.add(newName);
          _saveFavorites();
        }

        _contacts[index] = StoredContact(
          name: newName,
          color: newColorValue,
          isFavorite: _favoriteNames.contains(newName),
        );
        _updateFavoritesFromContacts();
      }
    });

    // Save to storage
    await _saveContacts();

    // Check for match after editing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForMatch();
    });
  }

  Future<void> _addContactManually(
      {required ScrollController targetController,
      bool addAtStart = false}) async {
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

    // Check for duplicates
    if (_contacts.any((c) => c.name == contactName)) {
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
      isFavorite: _favoriteNames.contains(contactName),
    );

    // Add to contacts list at the beginning or end
    setState(() {
      if (addAtStart) {
        _contacts.insert(0, newContact);
      } else {
        _contacts.add(newContact);
      }
      _updateFavoritesFromContacts();
    });

    // Save to storage
    await _saveContacts();

    // Scroll to the new contact only in the target ListView
    final displayedContacts = _displayedContacts;
    final newIndex = addAtStart ? 0 : displayedContacts.length - 1;

    if (targetController == _scrollController1) {
      if (_scrollController1.hasClients && newIndex >= 0) {
        final width = _scrollController1.position.viewportDimension;
        if (width > 0) {
          _scrollController1.animateTo(
            (newIndex + 1) * width, // +1 because index 0 is plus button
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
          setState(() {
            _currentPage1 = newIndex;
            // Update mode-specific position
            if (_favoritesMode) {
              _currentPage1Favorites = newIndex;
            } else {
              _currentPage1All = newIndex;
            }
          });
        }
      }
    } else if (targetController == _scrollController2) {
      if (_scrollController2.hasClients && newIndex >= 0) {
        final width = _scrollController2.position.viewportDimension;
        if (width > 0) {
          _scrollController2.animateTo(
            (newIndex + 1) * width, // +1 because index 0 is plus button
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
          setState(() {
            _currentPage2 = newIndex;
            // Update mode-specific position
            if (_favoritesMode) {
              _currentPage2Favorites = newIndex;
            } else {
              _currentPage2All = newIndex;
            }
          });
        }
      }
    }

    // Check for match after adding
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForMatch();
    });
  }

  void _updateFavoritesFromContacts() {
    // Update contacts with favorite status
    _contacts = _contacts.map((contact) {
      return contact.copyWith(
          isFavorite: _favoriteNames.contains(contact.name));
    }).toList();
  }

  // Calculate match score between two contacts with granularity based on diff
  // Returns a score where higher values indicate better matches
  // Uses the diff value (0-36) to create granular scoring within the match range
  num _calculateMatchCount(StoredContact contact1, StoredContact contact2) {
    if (contact1.color == contact2.color) {
      return 0; // Same color means no match
    }

    final color1 = ColorUtils.colorFromValue(contact1.color);
    final color2 = ColorUtils.colorFromValue(contact2.color);
    final overlay1 = ColorUtils.overlayColorFromValue(contact1.color);
    final overlay2 = ColorUtils.overlayColorFromValue(contact2.color);

    num matchScore = 0;

    // Check base match - score based on how close the match is (diff 0 = perfect, diff 36 = threshold)
    final baseMatch = ColorUtils.areColorsMatching(color1, color2);
    if (baseMatch.$1) {
      // Score: 1.0 for perfect match (diff=0), decreasing to ~0.0 at diff=30
      // Using inverse relationship: smaller diff = higher score
      matchScore += 2.0 - (baseMatch.$2 / 30.0);
    }

    // Check overlay match
    final overlayMatch = ColorUtils.areColorsMatching(overlay1, overlay2);
    if (overlayMatch.$1) {
      matchScore += 1.5 - (overlayMatch.$2 / 30.0);
    }

    // Check cross matches
    final crossMatch1 = ColorUtils.areColorsMatching(overlay1, color2);
    if (crossMatch1.$1) {
      matchScore += 1.3 - (crossMatch1.$2 / 30.0);
    }

    final crossMatch2 = ColorUtils.areColorsMatching(color1, overlay2);
    if (crossMatch2.$1) {
      matchScore += 1.3 - (crossMatch2.$2 / 30.0);
    }

    return matchScore;
  }

  // Reorder contacts by match count with the current contact
  void _reorderContactsByMatch(
      StoredContact currentContact, ScrollController controller) {
    // Create list of all contacts with their match counts
    final contactsWithMatches = _contacts.map((contact) {
      final matchCount = _calculateMatchCount(currentContact, contact);
      return {'contact': contact, 'matchCount': matchCount};
    }).toList();

    // Sort by match count (descending), keeping current contact first
    contactsWithMatches.sort((a, b) {
      final contactA = a['contact'] as StoredContact;
      final contactB = b['contact'] as StoredContact;

      // Keep current contact at the top
      if (contactA.name == currentContact.name) return -1;
      if (contactB.name == currentContact.name) return 1;

      // Sort by match score descending (higher score = better match)
      final countA = a['matchCount'] as num;
      final countB = b['matchCount'] as num;
      return countB.compareTo(countA);
    });

    // Extract reordered contacts
    final reorderedContacts = contactsWithMatches
        .map((item) => item['contact'] as StoredContact)
        .toList();

    // Find new index of current contact after reordering
    final newIndex =
        reorderedContacts.indexWhere((c) => c.name == currentContact.name);
    if (newIndex == -1) return;

    // Update contacts list
    setState(() {
      _contacts = reorderedContacts;
      _updateFavoritesFromContacts();
    });

    // Save to storage
    _saveContacts();

    // Find the new displayed index after reordering
    final newDisplayedIndex =
        _displayedContacts.indexWhere((c) => c.name == currentContact.name);

    // Maintain scroll position on the current contact in the clicked pane
    if (controller.hasClients && newDisplayedIndex >= 0) {
      final width = controller.position.viewportDimension;
      if (width > 0) {
        // Convert contact index to page index (add 1 for plus button at index 0)
        final targetPage = newDisplayedIndex + 1;
        controller.animateTo(
          targetPage * width,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );

        // Update current page state for the clicked pane
        if (controller == _scrollController1) {
          setState(() {
            _currentPage1 = newDisplayedIndex;
            if (_favoritesMode) {
              _currentPage1Favorites = newDisplayedIndex;
            } else {
              _currentPage1All = newDisplayedIndex;
            }
          });
        } else if (controller == _scrollController2) {
          setState(() {
            _currentPage2 = newDisplayedIndex;
            if (_favoritesMode) {
              _currentPage2Favorites = newDisplayedIndex;
            } else {
              _currentPage2All = newDisplayedIndex;
            }
          });
        }
      }
    }

    // Scroll the OTHER pane to the best matched contact
    final otherController = controller == _scrollController1
        ? _scrollController2
        : _scrollController1;

    // Find the best matched contact (highest match score, excluding current contact)
    StoredContact? bestMatchContact;
    num bestMatchCount = -1;

    for (final contact in _contacts) {
      if (contact.name == currentContact.name) continue; // Skip current contact

      final matchCount = _calculateMatchCount(currentContact, contact);
      if (matchCount > bestMatchCount) {
        bestMatchCount = matchCount;
        bestMatchContact = contact;
      }
    }

    // Find the best match contact's index in displayed contacts
    int? bestMatchIndex;
    if (bestMatchContact != null) {
      bestMatchIndex = _displayedContacts
          .indexWhere((c) => c.name == bestMatchContact!.name);
      if (bestMatchIndex == -1) {
        bestMatchIndex = null; // Not in displayed contacts
      }
    }

    // Scroll to best match if found and valid
    if (bestMatchIndex != null &&
        otherController.hasClients &&
        bestMatchIndex < _displayedContacts.length) {
      final width = otherController.position.viewportDimension;
      if (width > 0) {
        // Convert contact index to page index (add 1 for plus button at index 0)
        final targetPage = bestMatchIndex + 1;
        otherController.animateTo(
          targetPage * width,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );

        // Update current page state for the other pane
        if (otherController == _scrollController1) {
          setState(() {
            _currentPage1 = bestMatchIndex!;
            if (_favoritesMode) {
              _currentPage1Favorites = bestMatchIndex;
            } else {
              _currentPage1All = bestMatchIndex;
            }
          });
        } else if (otherController == _scrollController2) {
          setState(() {
            _currentPage2 = bestMatchIndex!;
            if (_favoritesMode) {
              _currentPage2Favorites = bestMatchIndex;
            } else {
              _currentPage2All = bestMatchIndex;
            }
          });
        }
      }
    }

    // Save scroll positions
    _saveScrollPositions();

    // Check for match after reordering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForMatch();
    });
  }

  void _toggleFavorite(String contactName) {
    setState(() {
      if (_favoriteNames.contains(contactName)) {
        _favoriteNames.remove(contactName);
      } else {
        _favoriteNames.add(contactName);
      }
      _updateFavoritesFromContacts();
      _saveFavorites();
    });
  }

  Future<void> _confirmDeleteContact(String contactName) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteContact),
        content: Text(l10n.deleteContactConfirm(contactName)),
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

    if (confirmed == true) {
      await _deleteContact(contactName);
    }
  }

  Future<void> _deleteContact(String contactName) async {
    // Remove from favorites if it's favorited
    if (_favoriteNames.contains(contactName)) {
      _favoriteNames.remove(contactName);
      await _saveFavorites();
    }

    // Remove from contacts list
    setState(() {
      _contacts.removeWhere((contact) => contact.name == contactName);
      _updateFavoritesFromContacts();
    });

    // Save updated contacts
    await _saveContacts();

    // Update scroll positions if needed
    final displayedContacts = _displayedContacts;
    if (_currentPage1 >= displayedContacts.length &&
        displayedContacts.isNotEmpty) {
      final newPage1 = displayedContacts.length - 1;
      setState(() {
        _currentPage1 = newPage1;
        // Update mode-specific position
        if (_favoritesMode) {
          _currentPage1Favorites = newPage1;
        } else {
          _currentPage1All = newPage1;
        }
      });
      if (_scrollController1.hasClients) {
        final width = _scrollController1.position.viewportDimension;
        if (width > 0) {
          // Convert contact index to page index (add 1 for plus button at index 0)
          _scrollController1.jumpTo((newPage1 + 1) * width);
        }
      }
    }
    if (_currentPage2 >= displayedContacts.length &&
        displayedContacts.isNotEmpty) {
      final newPage2 = displayedContacts.length - 1;
      setState(() {
        _currentPage2 = newPage2;
        // Update mode-specific position
        if (_favoritesMode) {
          _currentPage2Favorites = newPage2;
        } else {
          _currentPage2All = newPage2;
        }
      });
      if (_scrollController2.hasClients) {
        final width = _scrollController2.position.viewportDimension;
        if (width > 0) {
          // Convert contact index to page index (add 1 for plus button at index 0)
          _scrollController2.jumpTo((newPage2 + 1) * width);
        }
      }
    }

    // Save scroll positions after deletion
    _saveScrollPositions();

    // Check for match after deletion
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForMatch();
    });
  }

  void _toggleFavoritesMode() {
    // Save current scroll positions before switching modes
    if (_favoritesMode) {
      // Currently in favorites mode, save favorites positions
      _currentPage1Favorites = _currentPage1;
      _currentPage2Favorites = _currentPage2;
    } else {
      // Currently in all contacts mode, save all contacts positions
      _currentPage1All = _currentPage1;
      _currentPage2All = _currentPage2;
    }
    _saveScrollPositions();

    setState(() {
      _favoritesMode = !_favoritesMode;

      // Restore scroll positions for the new mode
      if (_favoritesMode) {
        // Switching to favorites mode, restore favorites positions
        _currentPage1 = _currentPage1Favorites;
        _currentPage2 = _currentPage2Favorites;
      } else {
        // Switching to all contacts mode, restore all contacts positions
        _currentPage1 = _currentPage1All;
        _currentPage2 = _currentPage2All;
      }
    });

    // Restore scroll positions after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final displayedContacts = _displayedContacts;
      final halfWidth = MediaQuery.of(context).size.width / 2;

      // Clamp positions to valid range
      final maxIndex =
          displayedContacts.isNotEmpty ? displayedContacts.length - 1 : 0;
      final targetPage1 = _currentPage1.clamp(0, maxIndex);
      final targetPage2 = _currentPage2.clamp(0, maxIndex);

      if (_scrollController1.hasClients && halfWidth > 0) {
        // Convert contact index to page index (add 1 for plus button at index 0)
        final targetPage = targetPage1 + 1;
        _scrollController1.jumpTo(targetPage * halfWidth);
        setState(() {
          _currentPage1 = targetPage1;
        });
      }

      if (_scrollController2.hasClients && halfWidth > 0) {
        // Convert contact index to page index (add 1 for plus button at index 0)
        final targetPage = targetPage2 + 1;
        _scrollController2.jumpTo(targetPage * halfWidth);
        setState(() {
          _currentPage2 = targetPage2;
        });
      }

      _checkForMatch();
    });
  }

  List<StoredContact> get _displayedContacts {
    if (_favoritesMode) {
      return _contacts.where((contact) => contact.isFavorite).toList();
    }
    return _contacts;
  }

  void _toggleHudVisibility() {
    setState(() {
      _isHudVisible = !_isHudVisible;
    });
    _saveHudState();
  }

  void _updateOverlayHeight(double delta, double cardHeight) {
    setState(() {
      // delta is negative when dragging up, positive when dragging down
      // We want dragging up to increase overlay height, down to decrease
      final heightChange = -delta / cardHeight;
      _overlayHeight = (_overlayHeight + heightChange).clamp(0.0, 1.0);
    });
  }

  Widget _buildAddContactCard(double height, ScrollController controller,
      {bool isStartCard = false}) {
    return GestureDetector(
      onTap: () => _showAddContactMenu(controller, isStartCard: isStartCard),
      child: SizedBox(
        height: height,
        child: Card(
          margin: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          color: Colors.black,
          child: Center(
            child: IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white.withValues(alpha: 0.5),
                size: 48,
              ),
              onPressed: () =>
                  _showAddContactMenu(controller, isStartCard: isStartCard),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAddContactMenu(ScrollController controller,
      {bool isStartCard = false}) {
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
                  _pickAndAddContactFromDevice(
                      targetController: controller, addAtStart: isStartCard);
                },
              ),
              const Divider(color: Colors.grey),
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.white),
                title: Text(l10n.addManually,
                    style: const TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.of(context).pop();
                  _addContactManually(
                      targetController: controller, addAtStart: isStartCard);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListView(
      ScrollController controller,
      double height,
      double width,
      int currentPage,
      bool needsRestore,
      AnimationController heartAnimationController,
      AnimationController flashAnimationController,
      bool baseMatch,
      bool overlayMatch) {
    final displayedContacts = _displayedContacts;
    // Ensure at least 2 items (one add contact card on each side) even when no contacts
    final itemCount = displayedContacts.isEmpty
        ? 2 // Two add contact cards (one on each side)
        : displayedContacts.length + 2; // +2 for add contact cards (first and last)
    
    // If width is 0 or invalid, return a placeholder to prevent blank screen
    if (width <= 0) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    
    return ListView.builder(
      key: ValueKey('listview_${controller.hashCode}_${itemCount}'),
      controller: controller,
      scrollDirection: Axis.horizontal,
      physics: const PageScrollPhysics(),
      itemExtent: width,
      itemCount: itemCount,
      cacheExtent: width * 2, // Cache at least 2 items to ensure rendering
      addAutomaticKeepAlives: true, // Keep items alive to ensure rendering
      addRepaintBoundaries: true, // Add repaint boundaries for better rendering
      itemBuilder: (context, index) {
        // First item is always the add contact card
        if (index == 0) {
          return _buildAddContactCard(height, controller, isStartCard: true);
        }

        // Last item is also the add contact card (only if there are contacts)
        if (!displayedContacts.isEmpty && index == displayedContacts.length + 1) {
          return _buildAddContactCard(height, controller, isStartCard: false);
        }
        
        // When no contacts, index 1 should also be the add contact card
        if (displayedContacts.isEmpty && index == 1) {
          return _buildAddContactCard(height, controller, isStartCard: false);
        }

        // Adjust index for displayed contacts (subtract 1 because first item is plus button)
        final contactIndex = index - 1;
        if (contactIndex < 0 || contactIndex >= displayedContacts.length) {
          // Should not happen, but return add contact card as fallback
          return _buildAddContactCard(height, controller, isStartCard: false);
        }
        final contact = displayedContacts[contactIndex];
        final isCurrentPage = (controller == _scrollController1 &&
                contactIndex == _currentPage1) ||
            (controller == _scrollController2 && contactIndex == _currentPage2);
        return GestureDetector(
          onTap: _toggleHudVisibility,
          onVerticalDragUpdate: (details) {
            _updateOverlayHeight(details.delta.dy, height);
          },
          child: SizedBox(
            height: height,
            child: Card(
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: Stack(
                children: [
                  // Base color area with flash highlight
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: flashAnimationController,
                      builder: (context, child) {
                        // Check if this card should flash base area
                        final shouldFlashBase = isCurrentPage &&
                            ((controller == _scrollController1 &&
                                    _activeFlashType1 == 'base') ||
                                (controller == _scrollController2 &&
                                    _activeFlashType2 == 'base'));
                        final flashOpacity = shouldFlashBase
                            ? flashAnimationController.value * 0.6
                            : 0.0;
                        return Stack(
                          children: [
                            Container(
                              color: ColorUtils.colorFromValue(contact.color),
                            ),
                            if (flashOpacity > 0)
                              Container(
                                color: Colors.white
                                    .withValues(alpha: flashOpacity),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  // Overlay color area with flash highlight
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: height * _overlayHeight,
                    child: AnimatedBuilder(
                      animation: flashAnimationController,
                      builder: (context, child) {
                        // Check if this card should flash overlay area
                        final shouldFlashOverlay = isCurrentPage &&
                            ((controller == _scrollController1 &&
                                    _activeFlashType1 == 'overlay') ||
                                (controller == _scrollController2 &&
                                    _activeFlashType2 == 'overlay'));
                        final flashOpacity = shouldFlashOverlay
                            ? flashAnimationController.value * 0.6
                            : 0.0;
                        return Stack(
                          children: [
                            Container(
                              color: ColorUtils.overlayColorFromValue(
                                  contact.color),
                            ),
                            if (flashOpacity > 0)
                              Container(
                                color: Colors.white
                                    .withValues(alpha: flashOpacity),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox.expand(
                    child: (_isHudVisible ||
                            (isCurrentPage &&
                                ((controller == _scrollController1 &&
                                        _showNameFlash1) ||
                                    (controller == _scrollController2 &&
                                        _showNameFlash2))))
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Show contact name with flash animation when there's a match
                              AnimatedBuilder(
                                animation: isCurrentPage && _isMatch
                                    ? heartAnimationController
                                    : const AlwaysStoppedAnimation(0.0),
                                builder: (context, child) {
                                  final shouldFlash = isCurrentPage &&
                                      _isMatch &&
                                      ((controller == _scrollController1 &&
                                              _showNameFlash1) ||
                                          (controller == _scrollController2 &&
                                              _showNameFlash2));
                                  final flashOpacity = shouldFlash
                                      ? (heartAnimationController.value * 0.3 +
                                          0.7)
                                      : 1.0;
                                  return Opacity(
                                    opacity: flashOpacity,
                                    child: GestureDetector(
                                      onTap: _isHudVisible
                                          ? () => _editContact(contact)
                                          : null,
                                      child: Text(
                                        contact.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black54,
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              if (_isHudVisible) ...[
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    isCurrentPage && _isMatch
                                        ? AnimatedBuilder(
                                            animation: heartAnimationController,
                                            builder: (context, child) {
                                              // Scale from 1.0 to 1.2 when there's a match
                                              final scale = 1.0 +
                                                  (heartAnimationController
                                                          .value *
                                                      0.2);
                                              return Transform.scale(
                                                scale: scale,
                                                child: IconButton(
                                                  icon: Icon(
                                                    contact.isFavorite
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: Colors.white,
                                                    size: 32,
                                                  ),
                                                  onPressed: () {
                                                    _toggleFavorite(
                                                        contact.name);
                                                  },
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                ),
                                              );
                                            },
                                          )
                                        : IconButton(
                                            icon: Icon(
                                              contact.isFavorite
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                            onPressed: () {
                                              _toggleFavorite(contact.name);
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            visualDensity:
                                                VisualDensity.compact,
                                          ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.bar_chart,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      onPressed: () {
                                        _reorderContactsByMatch(
                                            contact, controller);
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                      onPressed: () {
                                        _confirmDeleteContact(contact.name);
                                      },
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ],
                                ),
                              ],
                            ],
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
        backgroundColor: Colors.black,
        body: LayoutBuilder(builder: (context, constraints) {
          final halfWidth = constraints.maxWidth / 2;

          // Check if width changed (orientation change)
          bool widthChanged1 = false;
          bool widthChanged2 = false;
          int savedPage1 = _currentPage1;
          int savedPage2 = _currentPage2;

          final displayedContacts = _displayedContacts;
          if (_lastWidth1 != null && (_lastWidth1! - halfWidth).abs() > 1.0) {
            // Capture current page from scroll controller BEFORE width changes
            if (_scrollController1.hasClients) {
              final oldWidth = _scrollController1.position.viewportDimension;
              if (oldWidth > 0) {
                final page = (_scrollController1.offset / oldWidth).round();
                // Convert page index to contact index (accounting for plus button at index 0)
                if (page > 0 && page <= displayedContacts.length) {
                  savedPage1 = page - 1;
                } else {
                  savedPage1 = 0;
                }
                _currentPage1 = savedPage1;
              }
            }
            widthChanged1 = true;
            _lastWidth1 = halfWidth;
          } else {
            _lastWidth1 ??= halfWidth;
          }

          if (_lastWidth2 != null && (_lastWidth2! - halfWidth).abs() > 1.0) {
            // Capture current page from scroll controller BEFORE width changes
            if (_scrollController2.hasClients) {
              final oldWidth = _scrollController2.position.viewportDimension;
              if (oldWidth > 0) {
                final page = (_scrollController2.offset / oldWidth).round();
                // Convert page index to contact index (accounting for plus button at index 0)
                if (page > 0 && page <= displayedContacts.length) {
                  savedPage2 = page - 1;
                } else {
                  savedPage2 = 0;
                }
                _currentPage2 = savedPage2;
              }
            }
            widthChanged2 = true;
            _lastWidth2 = halfWidth;
          } else {
            _lastWidth2 ??= halfWidth;
          }

          // Restore scroll positions after orientation change
          if (widthChanged1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController1.hasClients && halfWidth > 0) {
                // Convert contact index back to page index (add 1 for plus button at index 0)
                final targetPage = savedPage1 + 1;
                final targetOffset = targetPage * halfWidth;
                _scrollController1.jumpTo(targetOffset);
                setState(() {
                  _currentPage1 = savedPage1;
                  // Update mode-specific position
                  if (_favoritesMode) {
                    _currentPage1Favorites = savedPage1;
                  } else {
                    _currentPage1All = savedPage1;
                  }
                });
              }
            });
          }

          if (widthChanged2) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController2.hasClients && halfWidth > 0) {
                // Convert contact index back to page index (add 1 for plus button at index 0)
                final targetPage = savedPage2 + 1;
                final targetOffset = targetPage * halfWidth;
                _scrollController2.jumpTo(targetOffset);
                setState(() {
                  _currentPage2 = savedPage2;
                  // Update mode-specific position
                  if (_favoritesMode) {
                    _currentPage2Favorites = savedPage2;
                  } else {
                    _currentPage2All = savedPage2;
                  }
                });
              }
            });
          }

          // Ensure ListView is visible on initial build when no contacts
          if (displayedContacts.isEmpty && halfWidth > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                // Ensure scroll controllers are at position 0 when no contacts
                if (_scrollController1.hasClients) {
                  _scrollController1.jumpTo(0);
                }
                if (_scrollController2.hasClients) {
                  _scrollController2.jumpTo(0);
                }
              }
            });
          }

          return SafeArea(
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildListView(
                          _scrollController1,
                          constraints.maxHeight,
                          halfWidth,
                          _currentPage1,
                          false,
                          _heartAnimationController,
                          _flashAnimationController1,
                          _baseMatch1,
                          _overlayMatch1),
                    ),
                    Expanded(
                      child: _buildListView(
                          _scrollController2,
                          constraints.maxHeight,
                          halfWidth,
                          _currentPage2,
                          false,
                          _heartAnimationController,
                          _flashAnimationController2,
                          _baseMatch2,
                          _overlayMatch2),
                    ),
                  ],
                ),
                if (_isHudVisible)
                  Positioned(
                    top: 10,
                    left: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _showSettings = true;
                            });
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _favoritesMode
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.white,
                          ),
                          onPressed: _toggleFavoritesMode,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.help_outline,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _showAbout = true;
                            });
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_showSettings)
                  Positioned.fill(
                    child: SettingsScreen(
                      onClose: () {
                        setState(() {
                          _showSettings = false;
                        });
                        // Reload contacts in case they were loaded from settings
                        _loadContacts();
                        // Also reload vibrations setting
                        _loadVibrationsSetting();
                      },
                    ),
                  ),
                if (_showAbout)
                  Positioned.fill(
                    child: AboutScreen(
                      onClose: () {
                        setState(() {
                          _showAbout = false;
                        });
                      },
                    ),
                  ),
              ],
            ),
          );
        }));
  }
}
