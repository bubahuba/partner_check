import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:flutter_contacts/flutter_contacts.dart';
import '../services/contacts_permission.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../utils/match_calculator.dart';
import '../utils/phone_utils.dart';
import '../utils/self_contact_finder.dart';
import '../services/contact_storage_service.dart';
import '../widgets/contact_card.dart';
import '../widgets/add_contact_card.dart';
import '../widgets/contacts_hud.dart';
import '../widgets/self_contact_hold_detector.dart';
import 'settings_screen.dart';
import '../utils/pro_gate.dart';
import '../services/pro_subscription_service.dart';
import 'package:provider/provider.dart';
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
  Timer? _scrollSaveTimer1;
  Timer? _scrollSaveTimer2;

  // Saved scroll positions for restoring after closing settings/about
  double? _savedScrollOffset1;
  double? _savedScrollOffset2;
  bool _shouldPromptSelfContactPick = false;
  bool _isApplyingBulkLoad = false;
  StoredSelfContact? _selfContact;
  ScrollController? _selfContactHighlightPane;
  late final AnimationController _selfContactHighlightController;
  bool _suppressNextHudToggle = false;
  ProSubscriptionService? _proService;
  bool _wasPro = false;

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
    _selfContactHighlightController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _addScrollListeners();
    _initializeData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _proService = context.read<ProSubscriptionService>();
      _wasPro = _proService!.isPro;
      _proService!.addListener(_onProStatusChanged);
    });
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
                if (currentPage > 0 &&
                    currentPage <= displayedContacts.length) {
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
                if (currentPage > 0 &&
                    currentPage <= displayedContacts.length) {
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
    _proService?.removeListener(_onProStatusChanged);
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
    _selfContactHighlightController.dispose();
    super.dispose();
  }

  void _onProStatusChanged() {
    if (!mounted || _proService == null) return;
    if (_proService!.isPro && !_wasPro) {
      if (!_showSettings) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.purchaseSuccess)),
        );
      }
      _handleProUnlocked();
    }
    _wasPro = _proService!.isPro;
  }

  Future<void> _handleProUnlocked() async {
    await _loadContactsWithoutRestoringScroll();
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollPositions();
      });
    });
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
    _shouldPromptSelfContactPick =
        await _storageService.loadPendingSelfContactPick();
    _selfContact = await _storageService.loadSelfContact();
    await _clearLegacySortPersistence();
    await _loadContacts();
  }

  Future<void> _clearLegacySortPersistence() async {
    await _storageService.clearOriginalContactOrder();
    await _storageService.saveLockedPane(null);
    await _storageService.saveOrderingContact(null);
  }

  void _clearVirtualSortState() {
    _lockedPaneController = null;
    _orderingContact = null;
    _originalContactOrder = null;
  }

  List<StoredContact> get _contactsForStorage =>
      _originalContactOrder ?? _contacts;

  String? _contactNameAtPage(int pageIndex) {
    final displayed = _displayedContacts;
    if (pageIndex < 0 || pageIndex >= displayed.length) return null;
    return displayed[pageIndex].name;
  }

  void _scrollPaneToContactName(
    ScrollController controller,
    String? contactName, {
    VoidCallback? onComplete,
  }) {
    if (contactName == null) {
      onComplete?.call();
      return;
    }

    void attemptScroll() {
      if (!mounted) return;

      if (!controller.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) => attemptScroll());
        return;
      }

      final index = _displayedContacts
          .indexWhere((contact) => contact.name == contactName);
      if (index < 0) {
        onComplete?.call();
        return;
      }

      final width = controller.position.viewportDimension;
      if (width <= 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) => attemptScroll());
        return;
      }

      controller.jumpTo((index + 1) * width);

      if (controller == _scrollController1) {
        setState(() {
          _currentPage1 = index;
          if (_favoritesMode) {
            _currentPage1Favorites = index;
          } else {
            _currentPage1All = index;
          }
        });
      } else if (controller == _scrollController2) {
        setState(() {
          _currentPage2 = index;
          if (_favoritesMode) {
            _currentPage2Favorites = index;
          } else {
            _currentPage2All = index;
          }
        });
      }

      onComplete?.call();
    }

    attemptScroll();
  }

  Future<bool> _handleDuplicateContactName(
    String contactName,
    ScrollController targetController,
  ) async {
    if (!_contacts.any((contact) => contact.name == contactName)) {
      return false;
    }

    if (_favoritesMode && !_favoriteNames.contains(contactName)) {
      setState(() {
        _favoriteNames.add(contactName);
        _updateFavoritesFromContacts();
      });
      await _saveFavorites();
      await _saveContacts();
      _refreshPanesAfterContactListChange(
        targetController: targetController,
        anchorContactName: contactName,
      );
      return true;
    }

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.contactAlreadyInList(contactName)),
          duration: const Duration(seconds: 2),
        ),
      );
      if (_displayedContacts.any((contact) => contact.name == contactName)) {
        _refreshPanesAfterContactListChange(
          targetController: targetController,
          anchorContactName: contactName,
        );
      }
    }
    return true;
  }

  String? _bestDisplayedMatchName(String referenceName) {
    final referenceIndex =
        _contacts.indexWhere((contact) => contact.name == referenceName);
    if (referenceIndex == -1) return null;

    final reference = _contacts[referenceIndex];
    StoredContact? bestMatch;
    num bestScore = -1;

    for (final contact in _displayedContacts) {
      if (contact.name == referenceName) continue;
      final score = _calculateMatchCount(reference, contact);
      if (score > bestScore) {
        bestScore = score;
        bestMatch = contact;
      }
    }

    return bestMatch?.name;
  }

  void _refreshPanesAfterContactListChange({
    required ScrollController targetController,
    required String anchorContactName,
  }) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      void finishRefresh() {
        _saveScrollPositions();
        _checkForMatch();
      }

      void scrollOtherPane() {
        final otherController = targetController == _scrollController1
            ? _scrollController2
            : _scrollController1;
        final otherCurrentPage = otherController == _scrollController1
            ? _currentPage1
            : _currentPage2;
        final otherContactName = _contactNameAtPage(otherCurrentPage);

        String? otherTarget = otherContactName;
        if (otherTarget == null ||
            !_displayedContacts.any((contact) => contact.name == otherTarget)) {
          otherTarget =
              _bestDisplayedMatchName(anchorContactName) ?? anchorContactName;
        }

        if (_displayedContacts.any((contact) => contact.name == otherTarget)) {
          _scrollPaneToContactName(otherController, otherTarget,
              onComplete: finishRefresh);
        } else {
          finishRefresh();
        }
      }

      _scrollPaneToContactName(
        targetController,
        anchorContactName,
        onComplete: scrollOtherPane,
      );
    });
  }

  Future<void> _loadContacts() async {
    final contacts = await _storageService.loadContacts();
    setState(() {
      _contacts = contacts;
      _updateFavoritesFromContacts();
      _clearVirtualSortState();
    });

    // Restore scroll positions from storage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _restoreScrollPositions();
        _maybePromptPickSelfContact();
      });
    });
  }

  /// Load contacts without restoring scroll positions (used when closing settings)
  Future<void> _loadContactsWithoutRestoringScroll() async {
    final contacts = await _storageService.loadContacts();
    setState(() {
      _contacts = contacts;
      _updateFavoritesFromContacts();
      _clearVirtualSortState();
    });
  }

  /// Refresh contacts and scroll state while settings is still open (bulk import
  /// or delete-all).
  Future<void> _prepareForBulkLoadClose() async {
    final contacts = await _storageService.loadContacts();
    _favoriteNames = await _storageService.loadFavorites();
    final positions = await _storageService.loadScrollPositions();
    _shouldPromptSelfContactPick =
        await _storageService.loadPendingSelfContactPick();
    _selfContact = await _storageService.loadSelfContact();
    if (!mounted) return;
    setState(() {
      _isApplyingBulkLoad = true;
      _contacts = contacts;
      _updateFavoritesFromContacts();
      _clearVirtualSortState();
      _currentPage1All = positions.page1All;
      _currentPage2All = positions.page2All;
      _currentPage1Favorites = positions.page1Favorites;
      _currentPage2Favorites = positions.page2Favorites;
    });
  }

  void _finalizeAfterBulkLoad({int attemptsLeft = 40}) {
    if (!mounted) return;

    if (!_scrollController1.hasClients || !_scrollController2.hasClients) {
      if (attemptsLeft <= 0) {
        setState(() => _isApplyingBulkLoad = false);
        _maybePromptPickSelfContact();
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _finalizeAfterBulkLoad(attemptsLeft: attemptsLeft - 1);
      });
      return;
    }

    final width1 = _scrollController1.position.viewportDimension;
    final width2 = _scrollController2.position.viewportDimension;
    if (width1 <= 0 || width2 <= 0) {
      if (attemptsLeft <= 0) {
        setState(() => _isApplyingBulkLoad = false);
        _maybePromptPickSelfContact();
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _finalizeAfterBulkLoad(attemptsLeft: attemptsLeft - 1);
      });
      return;
    }

    final displayedContacts = _displayedContacts;
    if (displayedContacts.isEmpty) {
      setState(() => _isApplyingBulkLoad = false);
      _prepareEmptyContactsView();
      _maybePromptPickSelfContact();
      return;
    }

    final targetPage1 =
        _favoritesMode ? _currentPage1Favorites : _currentPage1All;
    final targetPage2 =
        _favoritesMode ? _currentPage2Favorites : _currentPage2All;
    final maxIndex = displayedContacts.length - 1;
    final clampedPage1 = targetPage1.clamp(0, maxIndex);
    final clampedPage2 = targetPage2.clamp(0, maxIndex);

    _scrollController1.jumpTo((clampedPage1 + 1) * width1);
    _scrollController2.jumpTo((clampedPage2 + 1) * width2);

    setState(() {
      _isApplyingBulkLoad = false;
      _currentPage1 = clampedPage1;
      _currentPage2 = clampedPage2;
    });

    _saveScrollPositions();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkForMatch();
      _maybePromptPickSelfContact();
    });
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
      final maxOffset1 = _scrollController1.position.maxScrollExtent;
      _scrollController1.jumpTo(_savedScrollOffset1!.clamp(0.0, maxOffset1));
      // Update page index from scroll position
      final displayedContacts = _displayedContacts;
      final totalItems = displayedContacts.length + 2;
      final page =
          (_savedScrollOffset1! / width1).round().clamp(0, totalItems - 1);
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
      final maxOffset2 = _scrollController2.position.maxScrollExtent;
      _scrollController2.jumpTo(_savedScrollOffset2!.clamp(0.0, maxOffset2));
      // Update page index from scroll position
      final displayedContacts = _displayedContacts;
      final totalItems = displayedContacts.length + 2;
      final page =
          (_savedScrollOffset2! / width2).round().clamp(0, totalItems - 1);
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

  /// Restore scroll + match state after closing Settings/About without reloading contacts.
  void _resumeContactsViewAfterOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _restoreCurrentScrollPositions();
      _checkForMatch();
    });
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
      _prepareEmptyContactsView();
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

  void _maybePromptPickSelfContact() {
    if (!_shouldPromptSelfContactPick || !Platform.isIOS) {
      return;
    }
    _shouldPromptSelfContactPick = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptPickSelfContact();
    });
  }

  void _scrollPaneToSelfIndex(ScrollController controller, int index) {
    final displayedContacts = _displayedContacts;
    final maxIndex =
        displayedContacts.isNotEmpty ? displayedContacts.length - 1 : 0;
    final clamped = index.clamp(0, maxIndex);

    setState(() {
      if (controller == _scrollController1) {
        _currentPage1 = clamped;
        if (_favoritesMode) {
          _currentPage1Favorites = clamped;
        } else {
          _currentPage1All = clamped;
        }
      } else {
        _currentPage2 = clamped;
        if (_favoritesMode) {
          _currentPage2Favorites = clamped;
        } else {
          _currentPage2All = clamped;
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!controller.hasClients) return;
      final width = controller.position.viewportDimension;
      if (width <= 0) return;
      controller.jumpTo((clamped + 1) * width);
      _saveScrollPositions();
      _checkForMatch();
    });
  }

  void _showSelfContactSelectedToast(String contactName) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.selfContactSelectedToast(contactName))),
    );
  }

  Future<void> _saveSelfContactAt(int index) async {
    if (index < 0 || index >= _contacts.length) return;
    final contact = _contacts[index];
    final self = StoredSelfContact(name: contact.name, color: contact.color);
    await _storageService.saveSelfContact(self);
    _selfContact = self;
  }

  void _onPaneDoubleTap(ScrollController controller) {
    _suppressNextHudToggle = true;
    if (_selfContact != null) {
      final index = SelfContactFinder.findIndexForStoredSelf(
        _displayedContacts,
        _selfContact!,
      );
      if (index != null) {
        _scrollPaneToSelfIndex(controller, index);
        return;
      }
    }
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.setMeWithLongPressHint)),
    );
  }

  Future<void> _setSelfContactFromPane(ScrollController controller) async {
    final contactIndex = _contactIndexForController(controller);
    if (contactIndex == null) {
      _cancelSelfContactHoldFlash();
      return;
    }

    final contact = _displayedContacts[contactIndex];
    final fullIndex = _contacts.indexWhere((c) => c.name == contact.name);
    if (fullIndex < 0) {
      _cancelSelfContactHoldFlash();
      return;
    }

    await _storageService.savePendingSelfContactPick(false);
    await _saveSelfContactAt(fullIndex);
    if (!mounted) return;
    _showSelfContactSelectedToast(contact.name);
    _suppressNextHudToggle = true;
    await _selfContactHighlightController.reverse();
    if (mounted) {
      setState(() => _selfContactHighlightPane = null);
    }
  }

  void _onSelfContactHoldReady(ScrollController controller) {
    if (_contactIndexForController(controller) == null) return;
    _beginSelfContactHoldFlash(controller);
  }

  void _beginSelfContactHoldFlash(ScrollController controller) {
    final savedOffset1 =
        _scrollController1.hasClients ? _scrollController1.offset : null;
    final savedOffset2 =
        _scrollController2.hasClients ? _scrollController2.offset : null;

    setState(() => _selfContactHighlightPane = controller);
    _restoreScrollOffsets(savedOffset1, savedOffset2);
    _selfContactHighlightController.forward(from: 0);
  }

  void _cancelSelfContactHoldFlash() {
    if (_selfContactHighlightPane == null) return;
    _selfContactHighlightController.reverse().then((_) {
      if (mounted) {
        setState(() => _selfContactHighlightPane = null);
      }
    });
  }

  int? _contactIndexForController(ScrollController controller) {
    if (!controller.hasClients) return null;
    final width = controller.position.viewportDimension;
    if (width <= 0) return null;

    final displayed = _displayedContacts;
    final page = (controller.offset / width).round();
    if (page <= 0 || page > displayed.length) return null;
    return page - 1;
  }

  void _restoreScrollOffsets(double? offset1, double? offset2) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (offset1 != null &&
          _scrollController1.hasClients &&
          _scrollController1.offset != offset1) {
        _scrollController1.jumpTo(offset1);
      }
      if (offset2 != null &&
          _scrollController2.hasClients &&
          _scrollController2.offset != offset2) {
        _scrollController2.jumpTo(offset2);
      }
    });
  }

  Future<void> _pickSelfContact({
    required bool showIntroDialog,
    ScrollController? targetController,
  }) async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;

    while (mounted) {
      if (showIntroDialog) {
        if (!mounted) return;
        final shouldPick = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Text(l10n.pickYourselfTitle),
            content: SingleChildScrollView(
              child: Text(l10n.pickYourselfMessage),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.notNow),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.pickYourselfButton),
              ),
            ],
          ),
        );

        if (!mounted) return;

        if (shouldPick != true) {
          await _storageService.savePendingSelfContactPick(false);
          return;
        }
      }

      if (!await ensureContactsReadPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.contactsPermissionRequired)),
          );
        }
        return;
      }

      final contact = await pickContactWithNameAndPhone();
      if (contact == null) {
        if (showIntroDialog) {
          continue;
        }
        return;
      }

      final contactName = contact.displayName ?? '';
      if (contactName.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.selectedContactNoName)),
          );
        }
        if (showIntroDialog) {
          continue;
        }
        return;
      }

      final index = SelfContactFinder.findIndexForContact(_contacts, contact);
      if (index == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.pickYourselfNotInList(contactName)),
            ),
          );
        }
        if (showIntroDialog) {
          continue;
        }
        return;
      }

      await _storageService.savePendingSelfContactPick(false);
      await _saveSelfContactAt(index);
      _scrollPaneToSelfIndex(
        targetController ?? _scrollController1,
        index,
      );
      if (mounted) {
        _showSelfContactSelectedToast(_contacts[index].name);
      }
      return;
    }
  }

  Future<void> _promptPickSelfContact() async {
    await _pickSelfContact(showIntroDialog: true);
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
    await _storageService.saveContacts(_contactsForStorage);
  }

  Future<void> _saveScrollPositions() async {
    await _storageService.saveScrollPositions(ScrollPositions(
      page1All: _currentPage1All,
      page2All: _currentPage2All,
      page1Favorites: _currentPage1Favorites,
      page2Favorites: _currentPage2Favorites,
    ));
  }

  Future<void> _pickAndAddContactFromDevice(
      {required ScrollController targetController,
      bool addAtStart = false}) async {
    if (!await ensureCanAddContact(context, _contacts.length)) {
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

      // Check for duplicates
      if (await _handleDuplicateContactName(contactName, targetController)) {
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
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.noPhoneNumber,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.noPhoneNumberMessage(contactName)),
                  ],
                ),
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
        if (_favoritesMode) {
          _favoriteNames.add(contactName);
        }
        _insertStoredContact(newContact, atStart: addAtStart);
        _updateFavoritesFromContacts();
      });

      // Save to storage
      if (_favoritesMode) {
        await _saveFavorites();
      }
      await _saveContacts();

      _refreshPanesAfterContactListChange(
        targetController: targetController,
        anchorContactName: contactName,
      );

      // Wait for scroll animation to complete, then lock and reorder
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          // Find the contact in displayed contacts to ensure we have the correct reference
          final displayedContactsAfter = _displayedContacts;
          final contactIndex =
              displayedContactsAfter.indexWhere((c) => c.name == contactName);
          if (contactIndex != -1 &&
              contactIndex < displayedContactsAfter.length) {
            final contactToLock = displayedContactsAfter[contactIndex];
            // Lock the pane with the newly added contact and reorder by match
            _reorderContactsByMatch(contactToLock, targetController);
          }
        }
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
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        return AlertDialog(
          content: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: mediaQuery.size.height,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.editContact,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
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
        );
      },
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

    // Check if the name changed and if this is the ordering contact
    final nameChanged = contact.name != newName;
    final isOrderingContact = _orderingContact?.name == contact.name;

    // Update contact in the list
    setState(() {
      final index = _contacts.indexWhere((c) => c.name == contact.name);
      if (index != -1) {
        // Update favorite name if the name changed
        if (nameChanged && _favoriteNames.contains(contact.name)) {
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

        // Update original contact order if it exists and name changed
        if (_originalContactOrder != null && nameChanged) {
          final originalIndex =
              _originalContactOrder!.indexWhere((c) => c.name == contact.name);
          if (originalIndex != -1) {
            _originalContactOrder![originalIndex] = StoredContact(
              name: newName,
              color: newColorValue,
              isFavorite: _favoriteNames.contains(newName),
            );
          }
        }

        // Update ordering contact if its name changed
        if (isOrderingContact && nameChanged) {
          _orderingContact = StoredContact(
            name: newName,
            color: newColorValue,
            isFavorite: _favoriteNames.contains(newName),
          );
        }
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
    if (!await ensureCanAddContact(context, _contacts.length)) {
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
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

    // Check for duplicates
    if (await _handleDuplicateContactName(contactName, targetController)) {
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
      if (_favoritesMode) {
        _favoriteNames.add(contactName);
      }
      _insertStoredContact(newContact, atStart: addAtStart);
      _updateFavoritesFromContacts();
    });

    // Save to storage
    if (_favoritesMode) {
      await _saveFavorites();
    }
    await _saveContacts();

    // Wait for ListView to rebuild before scrolling to the new contact
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final displayedContacts = _displayedContacts;
      final newIndex =
          displayedContacts.indexWhere((c) => c.name == contactName);

      if (newIndex == -1) {
        _checkForMatch();
        return;
      }

      _refreshPanesAfterContactListChange(
        targetController: targetController,
        anchorContactName: contactName,
      );

      // Wait for scroll animation to complete, then lock and reorder
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted && newIndex < displayedContacts.length) {
          final contactToLock = displayedContacts[newIndex];
          _reorderContactsByMatch(contactToLock, targetController);
        }
      });
    });
  }

  void _insertStoredContact(StoredContact contact, {required bool atStart}) {
    if (atStart) {
      _contacts.insert(0, contact);
      _originalContactOrder?.insert(0, contact);
    } else {
      _contacts.add(contact);
      _originalContactOrder?.add(contact);
    }
  }

  void _updateFavoritesFromContacts() {
    _contacts = _contacts.map((contact) {
      return contact.copyWith(
          isFavorite: _favoriteNames.contains(contact.name));
    }).toList();
    if (_originalContactOrder != null) {
      _originalContactOrder = _originalContactOrder!.map((contact) {
        return contact.copyWith(
            isFavorite: _favoriteNames.contains(contact.name));
      }).toList();
    }
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
      final pane1Name = _contactNameAtPage(_currentPage1);
      final pane2Name = _contactNameAtPage(_currentPage2);
      final baseOrder = _originalContactOrder;

      setState(() {
        if (baseOrder != null) {
          _contacts = List.from(baseOrder);
          _updateFavoritesFromContacts();
        }
        _lockedPaneController = null;
        _orderingContact = null;
        _originalContactOrder = null;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollPaneToContactName(_scrollController1, pane1Name);
        _scrollPaneToContactName(_scrollController2, pane2Name);
        _saveScrollPositions();
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

    // Store base order in memory if not already stored (never persisted)
    _originalContactOrder ??= List.from(_contacts);

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
      if (contact.name == currentContact.name) {
        continue; // Skip current contact
      }

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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deleteContact,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(l10n.deleteContactConfirm(contactName)),
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

    // Check if the deleted contact is the ordering contact
    final isOrderingContact = _orderingContact?.name == contactName;
    final isSelfContact = _selfContact != null &&
        _contacts.any(
          (c) =>
              c.name == contactName &&
              c.name == _selfContact!.name &&
              c.color == _selfContact!.color,
        );

    // Remove from contacts list and update base order used for virtual sorting
    setState(() {
      _contacts.removeWhere((contact) => contact.name == contactName);
      if (_originalContactOrder != null) {
        _originalContactOrder!
            .removeWhere((contact) => contact.name == contactName);
      }

      if (isOrderingContact) {
        if (_originalContactOrder != null &&
            _originalContactOrder!.isNotEmpty) {
          _contacts = List.from(_originalContactOrder!);
        }
        _clearVirtualSortState();
      }

      _updateFavoritesFromContacts();
    });

    // Save updated contacts
    await _saveContacts();

    if (isSelfContact) {
      await _storageService.clearSelfContact();
      _selfContact = null;
    }

    // Get displayed contacts AFTER deletion
    final displayedContacts = _displayedContacts;

    // Restore scroll offsets after deletion, adjusting if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (displayedContacts.isEmpty) {
        _prepareEmptyContactsView();
        _saveScrollPositions();
        _checkForMatch();
        return;
      }

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
      if (displayedContacts.isEmpty) {
        _prepareEmptyContactsView();
        return;
      }

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

  void _applyEmptyContactsState() {
    _isHudVisible = true;
    _currentPage1 = 0;
    _currentPage2 = 0;
    _currentPage1All = 0;
    _currentPage2All = 0;
    _currentPage1Favorites = 0;
    _currentPage2Favorites = 0;
    _clearVirtualSortState();
  }

  void _scrollPanesToEmptyStart() {
    void attemptScroll() {
      if (!mounted) return;

      if (!_scrollController1.hasClients || !_scrollController2.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) => attemptScroll());
        return;
      }

      _scrollController1.jumpTo(0);
      _scrollController2.jumpTo(0);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => attemptScroll());
  }

  void _prepareEmptyContactsView() {
    setState(_applyEmptyContactsState);
    _saveHudState();
    _scrollPanesToEmptyStart();
  }

  bool get _shouldShowHud => _isHudVisible || _displayedContacts.isEmpty;

  void _toggleHudVisibility() {
    if (_suppressNextHudToggle) {
      _suppressNextHudToggle = false;
      return;
    }
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

  Widget _wrapPaneWithSelfContactHold(
    ScrollController controller,
    Widget child,
  ) {
    return GestureDetector(
      onDoubleTap: () => _onPaneDoubleTap(controller),
      behavior: HitTestBehavior.translucent,
      child: SelfContactHoldDetector(
        onHoldReady: () => _onSelfContactHoldReady(controller),
        onHoldComplete: () => _setSelfContactFromPane(controller),
        onHoldCancel: _cancelSelfContactHoldFlash,
        child: child,
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
      key: ValueKey('listview_${controller.hashCode}'),
      controller: controller,
      scrollDirection: Axis.horizontal,
      physics: isLocked
          ? const NeverScrollableScrollPhysics()
          : const PageScrollPhysics(),
      itemExtent: width,
      itemCount: itemCount,
      scrollCacheExtent: ScrollCacheExtent.pixels(
          width * 2), // Cache at least 2 items to ensure rendering
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
        if (displayedContacts.isNotEmpty &&
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

        final showSelfContactFlash =
            _selfContactHighlightPane == controller && isCurrentPage;

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
          showSelfContactFlash: showSelfContactFlash,
          selfContactFlashController: _selfContactHighlightController,
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

          // Ensure ListView shows add cards when there are no contacts
          if (displayedContacts.isEmpty &&
              halfWidth > 0 &&
              !_isApplyingBulkLoad) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_isApplyingBulkLoad) {
                _scrollPanesToEmptyStart();
              }
            });
          }

          return SafeArea(
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _wrapPaneWithSelfContactHold(
                        _scrollController1,
                        _buildListView(
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
                    ),
                    Expanded(
                      child: _wrapPaneWithSelfContactHold(
                        _scrollController2,
                        _buildListView(
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
                    ),
                  ],
                ),
                if (_shouldShowHud)
                  ContactsHud(
                    favoritesMode: _favoritesMode,
                    onSettings: () {
                      _updateCurrentPagesFromScrollControllers();
                      _saveScrollPositions();
                      _saveCurrentScrollPositions();
                      setState(() {
                        _showSettings = true;
                      });
                    },
                    onToggleFavorites: _toggleFavoritesMode,
                    onAbout: () {
                      _updateCurrentPagesFromScrollControllers();
                      _saveScrollPositions();
                      _saveCurrentScrollPositions();
                      setState(() {
                        _showAbout = true;
                      });
                    },
                  ),
                if (_showSettings)
                  Positioned.fill(
                    child: SettingsScreen(
                      selfContactColor: _selfContact?.color,
                      onPrepareClose: _prepareForBulkLoadClose,
                      onClose: () async {
                        setState(() {
                          _showSettings = false;
                        });
                        _loadVibrationsSetting();

                        final bulkLoaded = await _storageService
                            .loadAndClearContactsBulkLoaded();
                        if (bulkLoaded) {
                          await _prepareForBulkLoadClose();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _finalizeAfterBulkLoad();
                          });
                          return;
                        }

                        _resumeContactsViewAfterOverlay();
                      },
                    ),
                  ),
                if (_showAbout)
                  Positioned.fill(
                    child: AboutScreen(
                      selfContactColor: _selfContact?.color,
                      onClose: () {
                        setState(() {
                          _showAbout = false;
                        });
                        _resumeContactsViewAfterOverlay();
                      },
                    ),
                  ),
              ],
            ),
          );
        }));
  }
}
