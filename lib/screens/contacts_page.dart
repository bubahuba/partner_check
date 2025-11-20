import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../utils/color_utils.dart';
import '../utils/match_calculator.dart';
import '../utils/phone_utils.dart';
import '../services/contact_storage_service.dart';
import '../widgets/contact_card.dart';
import '../widgets/add_contact_card.dart';
import '../widgets/contacts_hud.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  ContactsPageState createState() => ContactsPageState();
}

class ContactsPageState extends State<ContactsPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
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

  // Storage service
  final ContactStorageService _storageService = ContactStorageService();
  bool _vibrationsEnabled = true;

  // Match ordering state
  ScrollController? _lockedPaneController;
  StoredContact? _orderingContact;
  List<StoredContact>? _originalContactOrder;
  bool _isRestoringLockedState = false;
  
  // Debounce timers for saving scroll positions
  Timer? _scrollSaveTimer1;
  Timer? _scrollSaveTimer2;
  
  // Saved scroll positions for restoring after closing settings/about
  double? _savedScrollOffset1;
  double? _savedScrollOffset2;

  @override
  void initState() {
    super.initState();
    // Add lifecycle observer to save scroll positions when app goes to background
    WidgetsBinding.instance.addObserver(this);
    // Initialize scroll controllers - we'll restore positions after loading
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
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
    // Ensure ListView is visible on initial launch with no contacts
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
          
          // Debounce save after scroll ends (after swipe completes)
          _scrollSaveTimer1?.cancel();
          _scrollSaveTimer1 = Timer(const Duration(milliseconds: 300), () {
            // Update current page from scroll position and save
            if (_scrollController1.hasClients) {
              final width = _scrollController1.position.viewportDimension;
              if (width > 0) {
                final displayedContacts = _displayedContacts;
                final totalItems = displayedContacts.length + 2;
                final currentPage = (_scrollController1.offset / width)
                    .round()
                    .clamp(0, totalItems - 1);
                if (currentPage > 0 && currentPage <= displayedContacts.length) {
                  final contactIndex = currentPage - 1;
                  if (contactIndex != _currentPage1) {
                    setState(() {
                      _currentPage1 = contactIndex;
                      if (_favoritesMode) {
                        _currentPage1Favorites = contactIndex;
                      } else {
                        _currentPage1All = contactIndex;
                      }
                    });
                  }
                  _saveScrollPositions();
                }
              }
            }
          });
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
          
          // Debounce save after scroll ends (after swipe completes)
          _scrollSaveTimer2?.cancel();
          _scrollSaveTimer2 = Timer(const Duration(milliseconds: 300), () {
            // Update current page from scroll position and save
            if (_scrollController2.hasClients) {
              final width = _scrollController2.position.viewportDimension;
              if (width > 0) {
                final displayedContacts = _displayedContacts;
                final totalItems = displayedContacts.length + 2;
                final currentPage = (_scrollController2.offset / width)
                    .round()
                    .clamp(0, totalItems - 1);
                if (currentPage > 0 && currentPage <= displayedContacts.length) {
                  final contactIndex = currentPage - 1;
                  if (contactIndex != _currentPage2) {
                    setState(() {
                      _currentPage2 = contactIndex;
                      if (_favoritesMode) {
                        _currentPage2Favorites = contactIndex;
                      } else {
                        _currentPage2All = contactIndex;
                      }
                    });
                  }
                  _saveScrollPositions();
                }
              }
            }
          });
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

    // Check for match using MatchCalculator
    final (matchResult, matchDetails) =
        MatchCalculator.checkForMatch(contact1, contact2);
    final newMatch = matchResult;

    // Stop any existing animations
    if (_heartAnimationController.isAnimating) {
      _heartAnimationController.stop();
    }
    _heartAnimationController.reset();

    setState(() {
      _isMatch = newMatch;
      _baseMatch1 = matchDetails.baseMatch1;
      _overlayMatch1 = matchDetails.overlayMatch1;
      _baseMatch2 = matchDetails.baseMatch2;
      _overlayMatch2 = matchDetails.overlayMatch2;

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

      // Get match types from match details
      final matchTypes = matchDetails.matchTypes;
      final matchCount = matchTypes.length;

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
    // Cancel any pending save timers
    _scrollSaveTimer1?.cancel();
    _scrollSaveTimer2?.cancel();
    // Save scroll positions before disposing
    _saveScrollPositions();
    // Remove lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    _scrollController1.dispose();
    _scrollController2.dispose();
    _heartAnimationController.dispose();
    _flashAnimationController1.dispose();
    _flashAnimationController2.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Save scroll positions when app goes to background or is paused
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      // Update current page positions from scroll controllers before saving
      _updateCurrentPagesFromScrollControllers();
      _saveScrollPositions();
    }
  }

  /// Update current page positions from scroll controllers
  void _updateCurrentPagesFromScrollControllers() {
    if (_scrollController1.hasClients) {
      final width = _scrollController1.position.viewportDimension;
      if (width > 0) {
        final displayedContacts = _displayedContacts;
        final totalItems = displayedContacts.length + 2;
        final page = (_scrollController1.offset / width)
            .round()
            .clamp(0, totalItems - 1);
        if (page > 0 && page <= displayedContacts.length) {
          final contactIndex = page - 1;
          _currentPage1 = contactIndex;
          if (_favoritesMode) {
            _currentPage1Favorites = contactIndex;
          } else {
            _currentPage1All = contactIndex;
          }
        }
      }
    }
    if (_scrollController2.hasClients) {
      final width = _scrollController2.position.viewportDimension;
      if (width > 0) {
        final displayedContacts = _displayedContacts;
        final totalItems = displayedContacts.length + 2;
        final page = (_scrollController2.offset / width)
            .round()
            .clamp(0, totalItems - 1);
        if (page > 0 && page <= displayedContacts.length) {
          final contactIndex = page - 1;
          _currentPage2 = contactIndex;
          if (_favoritesMode) {
            _currentPage2Favorites = contactIndex;
          } else {
            _currentPage2All = contactIndex;
          }
        }
      }
    }
  }

  Future<void> _initializeData() async {
    // Load favorites first, then contacts (so contacts can be updated with favorite status)
    _favoriteNames = await _storageService.loadFavorites();
    final positions = await _storageService.loadScrollPositions();
    _currentPage1All = positions.page1All;
    _currentPage2All = positions.page2All;
    _currentPage1Favorites = positions.page1Favorites;
    _currentPage2Favorites = positions.page2Favorites;
    _isHudVisible = await _storageService.loadHudVisible();
    _vibrationsEnabled = await _storageService.loadVibrationsEnabled();
    await _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await _storageService.loadContacts();
    setState(() {
      _contacts = contacts;
      _updateFavoritesFromContacts();
    });

    // Restore locked state first (which may reorder contacts)
    await _restoreLockedState();

    // Then restore scroll positions from storage after locked state is restored
    // Use multiple callbacks to ensure layout is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollPositions();
      });
    });
  }

  /// Load contacts without restoring scroll positions (used when closing settings)
  Future<void> _loadContactsWithoutRestoringScroll() async {
    final contacts = await _storageService.loadContacts();
    setState(() {
      _contacts = contacts;
      _updateFavoritesFromContacts();
    });

    // Don't restore locked state when closing settings - it might interfere with scroll restoration
    // The locked state should already be preserved in the current state
    // Only reload contacts to pick up any changes from settings
  }

  /// Save current scroll positions from scroll controllers
  void _saveCurrentScrollPositions() {
    if (_scrollController1.hasClients) {
      _savedScrollOffset1 = _scrollController1.offset;
    }
    if (_scrollController2.hasClients) {
      _savedScrollOffset2 = _scrollController2.offset;
    }
  }

  /// Restore saved scroll positions to scroll controllers
  void _restoreCurrentScrollPositions() {
    // Check if controllers are ready
    if (!_scrollController1.hasClients || !_scrollController2.hasClients) {
      // Wait for next frame if controllers aren't ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreCurrentScrollPositions();
      });
      return;
    }

    final width1 = _scrollController1.position.viewportDimension;
    final width2 = _scrollController2.position.viewportDimension;

    if (width1 <= 0 || width2 <= 0) {
      // Wait for next frame if dimensions aren't ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreCurrentScrollPositions();
      });
      return;
    }

    if (_savedScrollOffset1 != null) {
      _scrollController1.jumpTo(_savedScrollOffset1!);
      // Update page index from scroll position
      final displayedContacts = _displayedContacts;
      final totalItems = displayedContacts.length + 2;
      final page = (_savedScrollOffset1! / width1).round().clamp(0, totalItems - 1);
      if (page > 0 && page <= displayedContacts.length) {
        final contactIndex = page - 1;
        setState(() {
          _currentPage1 = contactIndex;
          if (_favoritesMode) {
            _currentPage1Favorites = contactIndex;
          } else {
            _currentPage1All = contactIndex;
          }
        });
      }
    }
    if (_savedScrollOffset2 != null) {
      _scrollController2.jumpTo(_savedScrollOffset2!);
      // Update page index from scroll position
      final displayedContacts = _displayedContacts;
      final totalItems = displayedContacts.length + 2;
      final page = (_savedScrollOffset2! / width2).round().clamp(0, totalItems - 1);
      if (page > 0 && page <= displayedContacts.length) {
        final contactIndex = page - 1;
        setState(() {
          _currentPage2 = contactIndex;
          if (_favoritesMode) {
            _currentPage2Favorites = contactIndex;
          } else {
            _currentPage2All = contactIndex;
          }
        });
      }
    }
    // Save the restored positions to storage
    _saveScrollPositions();
  }

  void _restoreScrollPositions() {
    final displayedContacts = _displayedContacts;
    
    // Check if scroll controllers are ready
    if (!_scrollController1.hasClients || !_scrollController2.hasClients) {
      // Wait for next frame if controllers aren't ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollPositions();
      });
      return;
    }

    final width1 = _scrollController1.position.viewportDimension;
    final width2 = _scrollController2.position.viewportDimension;

    if (width1 <= 0 || width2 <= 0) {
      // Wait for next frame if dimensions aren't ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollPositions();
      });
      return;
    }

    if (displayedContacts.isEmpty) {
      // If no contacts, jump to position 0 (add contact card)
      _scrollController1.jumpTo(0);
      _scrollController2.jumpTo(0);
      setState(() {
        _currentPage1 = 0;
        _currentPage2 = 0;
      });
      return;
    }

    // Restore scroll positions based on current mode from saved values
    final targetPage1 =
        _favoritesMode ? _currentPage1Favorites : _currentPage1All;
    final targetPage2 =
        _favoritesMode ? _currentPage2Favorites : _currentPage2All;

    // Only restore if we have valid saved positions (not 0, or 0 is valid if contacts exist)
    // If both are 0 and we have contacts, it means we're at the first contact (index 0)
    final maxIndex = displayedContacts.length - 1;
    final clampedPage1 = targetPage1.clamp(0, maxIndex);
    final clampedPage2 = targetPage2.clamp(0, maxIndex);

    // Restore scroll positions - convert contact index to page index (add 1 for plus button at index 0)
    final targetPage1Value = clampedPage1 + 1;
    final targetPage2Value = clampedPage2 + 1;
    _scrollController1.jumpTo(targetPage1Value * width1);
    _scrollController2.jumpTo(targetPage2Value * width2);

    // Update current page state
    setState(() {
      _currentPage1 = clampedPage1;
      _currentPage2 = clampedPage2;
    });

    // Wait for scroll position to be fully applied before checking for matches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Verify scroll positions are correct before checking matches
      if (_scrollController1.hasClients && _scrollController2.hasClients) {
        final width1 = _scrollController1.position.viewportDimension;
        final width2 = _scrollController2.position.viewportDimension;
        if (width1 > 0 && width2 > 0) {
          final page1 = (_scrollController1.offset / width1).round();
          final page2 = (_scrollController2.offset / width2).round();
          // Only check for match if we're not on the add contact cards (page 0)
          if (page1 > 0 &&
              page1 <= displayedContacts.length &&
              page2 > 0 &&
              page2 <= displayedContacts.length) {
            _checkForMatch();
          }
        }
      }
    });
  }

  Future<void> _loadVibrationsSetting() async {
    _vibrationsEnabled = await _storageService.loadVibrationsEnabled();
    setState(() {});
  }

  Future<void> _saveHudState() async {
    await _storageService.saveHudVisible(_isHudVisible);
  }

  Future<void> _saveFavorites() async {
    await _storageService.saveFavorites(_favoriteNames);
  }

  Future<void> _saveContacts() async {
    await _storageService.saveContacts(_contacts);
  }

  Future<void> _saveScrollPositions() async {
    await _storageService.saveScrollPositions(ScrollPositions(
      page1All: _currentPage1All,
      page2All: _currentPage2All,
      page1Favorites: _currentPage1Favorites,
      page2Favorites: _currentPage2Favorites,
    ));
  }

  Future<void> _saveLockedState() async {
    int? lockedPane;
    if (_lockedPaneController == _scrollController1) {
      lockedPane = 1;
    } else if (_lockedPaneController == _scrollController2) {
      lockedPane = 2;
    }
    await _storageService.saveLockedPane(lockedPane);
    await _storageService.saveOrderingContact(_orderingContact?.name);
    
    // Save original order if locked, clear it if unlocked
    if (_lockedPaneController != null && _originalContactOrder != null) {
      await _storageService.saveOriginalContactOrder(_originalContactOrder!);
    } else {
      await _storageService.clearOriginalContactOrder();
    }
  }

  Future<void> _restoreLockedState() async {
    final lockedPane = await _storageService.loadLockedPane();
    final orderingContactName = await _storageService.loadOrderingContact();
    final originalOrder = await _storageService.loadOriginalContactOrder();
    
    if (lockedPane != null && 
        orderingContactName != null && 
        orderingContactName.isNotEmpty &&
        originalOrder.isNotEmpty &&
        _contacts.isNotEmpty) {
      
      // Find the ordering contact in the loaded contacts
      final orderingContact = _contacts.firstWhere(
        (contact) => contact.name == orderingContactName,
        orElse: () => _contacts[0],
      );
      
      // Only restore if the contact exists
      if (_contacts.any((c) => c.name == orderingContactName)) {
        // Restore original order first
        setState(() {
          _originalContactOrder = originalOrder;
          // If contacts are already in the correct reordered state, keep them
          // Otherwise, restore original order and reorder
          final currentOrderNames = _contacts.map((c) => c.name).toList();
          final originalOrderNames = originalOrder.map((c) => c.name).toList();
          
          // If current order doesn't match original, restore original first
          if (currentOrderNames.toString() != originalOrderNames.toString()) {
            _contacts = List.from(originalOrder);
            _updateFavoritesFromContacts();
          }
        });
        
        // Determine which controller to lock
        final controller = lockedPane == 1 ? _scrollController1 : _scrollController2;
        
        // Restore the ordering state by calling _reorderContactsByMatch
        // Use a delayed callback to ensure layout is ready
        // But DON'T restore scroll positions here - let _loadContacts handle that
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (mounted && _contacts.isNotEmpty) {
              // Save a flag to indicate we're restoring, so _reorderContactsByMatch
              // doesn't overwrite scroll positions
              _isRestoringLockedState = true;
              _reorderContactsByMatch(orderingContact, controller).then((_) {
                _isRestoringLockedState = false;
                // After reordering, restore scroll positions again
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _restoreScrollPositions();
                });
              });
            }
          });
        });
      }
    } else {
      // Clear locked state if contact doesn't exist or no locked state saved
      setState(() {
        _lockedPaneController = null;
        _orderingContact = null;
        _originalContactOrder = null;
      });
      await _storageService.clearOriginalContactOrder();
      await _storageService.saveLockedPane(null);
      await _storageService.saveOrderingContact(null);
    }
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
      final colorValue = PhoneUtils.colorFromPhoneNumber(phoneNumber);

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
      newColorValue = PhoneUtils.colorFromPhoneNumber(phoneNumber);
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
    final colorValue = PhoneUtils.colorFromPhoneNumber(phoneNumber);

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
  num _calculateMatchCount(StoredContact contact1, StoredContact contact2) {
    return MatchCalculator.calculateMatchCount(contact1, contact2);
  }

  // Reorder contacts by match count with the current contact
  Future<void> _reorderContactsByMatch(
      StoredContact currentContact, ScrollController controller) async {
    // Check if the same contact is already being used for ordering (toggle off)
    if (_lockedPaneController == controller &&
        _orderingContact?.name == currentContact.name) {
      // Unlock without changing contact order or scroll positions
      setState(() {
        _lockedPaneController = null;
        _orderingContact = null;
        // Keep _originalContactOrder in memory but don't restore it
        // This allows us to restore it later if needed, but for now just unlock
      });
      _saveLockedState();
      // Don't save contacts - keep the current order
      // Don't touch scroll positions - keep them as they are
      // Just check for match
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForMatch();
      });
      return;
    }

    // If switching to a different contact, restore original order first
    if (_originalContactOrder != null &&
        _orderingContact?.name != currentContact.name) {
      setState(() {
        _contacts = List.from(_originalContactOrder!);
        _updateFavoritesFromContacts();
      });
    }

    // Store original order if not already stored
    if (_originalContactOrder == null) {
      _originalContactOrder = List.from(_contacts);
      // Save original order to storage
      await _storageService.saveOriginalContactOrder(_originalContactOrder!);
    }

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

    // Update contacts list and lock the pane
    setState(() {
      _contacts = reorderedContacts;
      _updateFavoritesFromContacts();
      _lockedPaneController = controller;
      _orderingContact = currentContact;
    });

    // Save to storage
    _saveContacts();
    _saveLockedState();

    // Only scroll if we're not restoring locked state (to preserve saved scroll positions)
    if (!_isRestoringLockedState) {
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
    }

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
    // Get displayed contacts BEFORE deletion to find the deleted contact's index
    final displayedContactsBefore = _displayedContacts;
    final deletedIndex = displayedContactsBefore
        .indexWhere((contact) => contact.name == contactName);

    // Capture current scroll offsets BEFORE deletion
    double? savedOffset1;
    double? savedOffset2;
    double? width1;
    double? width2;
    
    if (_scrollController1.hasClients) {
      width1 = _scrollController1.position.viewportDimension;
      if (width1 > 0) {
        savedOffset1 = _scrollController1.offset;
      }
    }
    if (_scrollController2.hasClients) {
      width2 = _scrollController2.position.viewportDimension;
      if (width2 > 0) {
        savedOffset2 = _scrollController2.offset;
      }
    }

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

    // Get displayed contacts AFTER deletion
    final displayedContacts = _displayedContacts;

    // Restore scroll offsets after deletion, adjusting if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (deletedIndex != -1) {
        // Adjust pane 1 scroll offset
        if (savedOffset1 != null && width1 != null && width1 > 0) {
          // Calculate which page we were on
          final oldPage = (savedOffset1 / width1).round();
          // If the deleted contact was before our current position, adjust offset
          if (oldPage > deletedIndex + 1) {
            // We were after the deleted contact, so subtract one page width
            final newOffset = savedOffset1 - width1;
            if (_scrollController1.hasClients) {
              _scrollController1.jumpTo(newOffset.clamp(0.0, double.infinity));
            }
            // Update page index
            final newPage = oldPage - 1;
            if (newPage > 0 && newPage <= displayedContacts.length) {
              final contactIndex = newPage - 1;
              setState(() {
                _currentPage1 = contactIndex;
                if (_favoritesMode) {
                  _currentPage1Favorites = contactIndex;
                } else {
                  _currentPage1All = contactIndex;
                }
              });
            }
          } else if (oldPage == deletedIndex + 1) {
            // We were on the deleted contact, keep the same offset (will show next contact)
            if (_scrollController1.hasClients) {
              _scrollController1.jumpTo(savedOffset1);
            }
            // Update page index to the next contact (or previous if at end)
            if (deletedIndex < displayedContacts.length) {
              final contactIndex = deletedIndex;
              setState(() {
                _currentPage1 = contactIndex;
                if (_favoritesMode) {
                  _currentPage1Favorites = contactIndex;
                } else {
                  _currentPage1All = contactIndex;
                }
              });
            } else if (displayedContacts.isNotEmpty) {
              final contactIndex = displayedContacts.length - 1;
              setState(() {
                _currentPage1 = contactIndex;
                if (_favoritesMode) {
                  _currentPage1Favorites = contactIndex;
                } else {
                  _currentPage1All = contactIndex;
                }
              });
            }
          } else {
            // We were before the deleted contact, keep the same offset
            if (_scrollController1.hasClients) {
              _scrollController1.jumpTo(savedOffset1);
            }
          }
        }

        // Adjust pane 2 scroll offset
        if (savedOffset2 != null && width2 != null && width2 > 0) {
          // Calculate which page we were on
          final oldPage = (savedOffset2 / width2).round();
          // If the deleted contact was before our current position, adjust offset
          if (oldPage > deletedIndex + 1) {
            // We were after the deleted contact, so subtract one page width
            final newOffset = savedOffset2 - width2;
            if (_scrollController2.hasClients) {
              _scrollController2.jumpTo(newOffset.clamp(0.0, double.infinity));
            }
            // Update page index
            final newPage = oldPage - 1;
            if (newPage > 0 && newPage <= displayedContacts.length) {
              final contactIndex = newPage - 1;
              setState(() {
                _currentPage2 = contactIndex;
                if (_favoritesMode) {
                  _currentPage2Favorites = contactIndex;
                } else {
                  _currentPage2All = contactIndex;
                }
              });
            }
          } else if (oldPage == deletedIndex + 1) {
            // We were on the deleted contact, keep the same offset (will show next contact)
            if (_scrollController2.hasClients) {
              _scrollController2.jumpTo(savedOffset2);
            }
            // Update page index to the next contact (or previous if at end)
            if (deletedIndex < displayedContacts.length) {
              final contactIndex = deletedIndex;
              setState(() {
                _currentPage2 = contactIndex;
                if (_favoritesMode) {
                  _currentPage2Favorites = contactIndex;
                } else {
                  _currentPage2All = contactIndex;
                }
              });
            } else if (displayedContacts.isNotEmpty) {
              final contactIndex = displayedContacts.length - 1;
              setState(() {
                _currentPage2 = contactIndex;
                if (_favoritesMode) {
                  _currentPage2Favorites = contactIndex;
                } else {
                  _currentPage2All = contactIndex;
                }
              });
            }
          } else {
            // We were before the deleted contact, keep the same offset
            if (_scrollController2.hasClients) {
              _scrollController2.jumpTo(savedOffset2);
            }
          }
        }
      }

      // Save scroll positions after deletion
      _saveScrollPositions();

      // Check for match after deletion
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

  void _showAddContactMenu(ScrollController controller,
      {bool isStartCard = false}) {
    showAddContactMenu(
      context,
      onAddFromDevice: () {
        _pickAndAddContactFromDevice(
            targetController: controller, addAtStart: isStartCard);
      },
      onAddManually: () {
        _addContactManually(
            targetController: controller, addAtStart: isStartCard);
      },
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
        : displayedContacts.length +
            2; // +2 for add contact cards (first and last)

    // If width is 0 or invalid, return a placeholder to prevent blank screen
    if (width <= 0) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // Check if this pane is locked
    final isLocked = _lockedPaneController == controller;

    return ListView.builder(
      key: ValueKey('listview_${controller.hashCode}_${itemCount}'),
      controller: controller,
      scrollDirection: Axis.horizontal,
      physics: isLocked
          ? const NeverScrollableScrollPhysics()
          : const PageScrollPhysics(),
      itemExtent: width,
      itemCount: itemCount,
      cacheExtent: width * 2, // Cache at least 2 items to ensure rendering
      addAutomaticKeepAlives: true, // Keep items alive to ensure rendering
      addRepaintBoundaries: true, // Add repaint boundaries for better rendering
      itemBuilder: (context, index) {
        // First item is always the add contact card
        if (index == 0) {
          return AddContactCard(
            height: height,
            onTap: () => _showAddContactMenu(controller, isStartCard: true),
          );
        }

        // Last item is also the add contact card (only if there are contacts)
        if (!displayedContacts.isEmpty &&
            index == displayedContacts.length + 1) {
          return AddContactCard(
            height: height,
            onTap: () => _showAddContactMenu(controller, isStartCard: false),
          );
        }

        // When no contacts, index 1 should also be the add contact card
        if (displayedContacts.isEmpty && index == 1) {
          return AddContactCard(
            height: height,
            onTap: () => _showAddContactMenu(controller, isStartCard: false),
          );
        }

        // Adjust index for displayed contacts (subtract 1 because first item is plus button)
        final contactIndex = index - 1;
        if (contactIndex < 0 || contactIndex >= displayedContacts.length) {
          // Should not happen, but return add contact card as fallback
          return AddContactCard(
            height: height,
            onTap: () => _showAddContactMenu(controller, isStartCard: false),
          );
        }
        final contact = displayedContacts[contactIndex];
        final isCurrentPage = (controller == _scrollController1 &&
                contactIndex == _currentPage1) ||
            (controller == _scrollController2 && contactIndex == _currentPage2);

        // Determine active flash type for this card
        String? activeFlashType;
        if (controller == _scrollController1) {
          activeFlashType = _activeFlashType1;
        } else {
          activeFlashType = _activeFlashType2;
        }

        // Determine if name should flash
        bool showNameFlash = false;
        if (controller == _scrollController1) {
          showNameFlash = _showNameFlash1;
        } else {
          showNameFlash = _showNameFlash2;
        }

        // Check if this contact is being used for ordering
        final isOrderingActive = _orderingContact?.name == contact.name &&
            _lockedPaneController == controller;

        return ContactCard(
          contact: contact,
          height: height,
          overlayHeight: _overlayHeight,
          isCurrentPage: isCurrentPage,
          isMatch: _isMatch,
          isHudVisible: _isHudVisible,
          showNameFlash: showNameFlash,
          activeFlashType: activeFlashType,
          heartAnimationController: heartAnimationController,
          flashAnimationController: flashAnimationController,
          onTap: _toggleHudVisibility,
          onVerticalDragUpdate: (delta) => _updateOverlayHeight(delta, height),
          onEdit: _isHudVisible ? () => _editContact(contact) : null,
          onToggleFavorite: () => _toggleFavorite(contact.name),
          onReorder: () => _reorderContactsByMatch(contact, controller),
          onDelete: () => _confirmDeleteContact(contact.name),
          isOrderingActive: isOrderingActive,
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
                  ContactsHud(
                    favoritesMode: _favoritesMode,
                    onSettings: () {
                      // Save current scroll positions before opening settings
                      _saveCurrentScrollPositions();
                      setState(() {
                        _showSettings = true;
                      });
                    },
                    onToggleFavorites: _toggleFavoritesMode,
                    onAbout: () {
                      // Save current scroll positions before opening about
                      _saveCurrentScrollPositions();
                      setState(() {
                        _showAbout = true;
                      });
                    },
                  ),
                if (_showSettings)
                  Positioned.fill(
                    child: SettingsScreen(
                      onClose: () async {
                        setState(() {
                          _showSettings = false;
                        });
                        // Reload contacts in case they were loaded from settings
                        await _loadContactsWithoutRestoringScroll();
                        // Also reload vibrations setting
                        _loadVibrationsSetting();
                        // Restore the saved scroll positions after layout and locked state restoration
                        // Use multiple nested callbacks to ensure everything is ready
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _restoreCurrentScrollPositions();
                            });
                          });
                        });
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
                        // Restore the saved scroll positions after layout
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _restoreCurrentScrollPositions();
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
