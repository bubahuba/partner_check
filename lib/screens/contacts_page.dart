import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models.dart';
import '../utils/color_utils.dart';
import 'settings_screen.dart';

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
  bool _isHudVisible = false;
  double _overlayHeight = 0.2; // Initial height: 20%
  int _currentPage1 = 0;
  int _currentPage2 = 0;
  double? _lastWidth1;
  double? _lastWidth2;
  bool _showSettings = false;
  bool _favoritesMode = false;
  Set<String> _favoriteNames = {};
  late AnimationController _heartAnimationController1;
  late AnimationController _heartAnimationController2;
  late AnimationController _flashAnimationController1;
  late AnimationController _flashAnimationController2;
  bool _isMatch = false;
  bool _baseMatch1 = false;
  bool _overlayMatch1 = false;
  bool _baseMatch2 = false;
  bool _overlayMatch2 = false;

  static const String _storageKey = 'stored_contacts';
  static const String _favoritesKey = 'favorite_contacts';
  static const String _vibrationsKey = 'vibrations_enabled';
  bool _vibrationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
    _heartAnimationController1 = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _heartAnimationController2 = AnimationController(
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
    _loadContacts();
    _loadFavorites();
    // Check for initial match after everything is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForMatch();
    });
  }

  void _addScrollListeners() {
    _scrollController1.addListener(() {
      if (_scrollController1.hasClients) {
        final width = _scrollController1.position.viewportDimension;
        if (width > 0) {
          final displayedContacts = _displayedContacts;
          final page = (_scrollController1.offset / width)
              .round()
              .clamp(0, displayedContacts.length - 1);
          if (page != _currentPage1) {
            setState(() {
              _currentPage1 = page;
            });
            _checkForMatch();
          }
        }
      }
    });

    _scrollController2.addListener(() {
      if (_scrollController2.hasClients) {
        final width = _scrollController2.position.viewportDimension;
        if (width > 0) {
          final displayedContacts = _displayedContacts;
          final page = (_scrollController2.offset / width)
              .round()
              .clamp(0, displayedContacts.length - 1);
          if (page != _currentPage2) {
            setState(() {
              _currentPage2 = page;
            });
            _checkForMatch();
          }
        }
      }
    });
  }

  // Check for match between current pair and trigger animation
  void _checkForMatch() {
    final displayedContacts = _displayedContacts;
    if (displayedContacts.isEmpty ||
        _currentPage1 >= displayedContacts.length ||
        _currentPage2 >= displayedContacts.length) {
      if (_isMatch) {
        setState(() {
          _isMatch = false;
        });
        _heartAnimationController1.stop();
        _heartAnimationController2.stop();
        _heartAnimationController1.reset();
        _heartAnimationController2.reset();
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
      baseMatch = ColorUtils.areColorsMatching(color1, color2);
      overlayMatch = ColorUtils.areColorsMatching(overlay1, overlay2);

      // Cross-match: overlay of one contact with base of the other
      crossMatch1 = ColorUtils.areColorsMatching(overlay1, color2);
      crossMatch2 = ColorUtils.areColorsMatching(color1, overlay2);

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
    if (_heartAnimationController1.isAnimating) {
      _heartAnimationController1.stop();
    }
    if (_heartAnimationController2.isAnimating) {
      _heartAnimationController2.stop();
    }
    _heartAnimationController1.reset();
    _heartAnimationController2.reset();

    setState(() {
      _isMatch = newMatch;
      _baseMatch1 = baseMatch1;
      _overlayMatch1 = overlayMatch1;
      _baseMatch2 = baseMatch2;
      _overlayMatch2 = overlayMatch2;
    });

    if (newMatch) {
      // Trigger animation and haptic feedback
      _heartAnimationController1.repeat(reverse: true);
      _heartAnimationController2.repeat(reverse: true);
      // Trigger flash animations
      _flashAnimationController1.forward().then((_) {
        _flashAnimationController1.reverse();
      });
      _flashAnimationController2.forward().then((_) {
        _flashAnimationController2.reverse();
      });
      // Count number of matches
      int matchCount = 0;
      if (baseMatch) matchCount++;
      if (overlayMatch) matchCount++;
      if (crossMatch1) matchCount++;
      if (crossMatch2) matchCount++;

      // Haptic feedback - vibrate twice if multiple matches (only if enabled)
      if (_vibrationsEnabled) {
        if (matchCount >= 2) {
          HapticFeedback.vibrate();
          Future.delayed(const Duration(milliseconds: 600), () {
            HapticFeedback.vibrate();
          });
        } else {
          HapticFeedback.vibrate();
        }
      }
    } else {
      // Reset flash animations
      _flashAnimationController1.reset();
      _flashAnimationController2.reset();
    }
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
    _heartAnimationController1.dispose();
    _heartAnimationController2.dispose();
    _flashAnimationController1.dispose();
    _flashAnimationController2.dispose();
    super.dispose();
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
      // Check for match after loading contacts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkForMatch();
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

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favoriteNames.toList());
  }

  void _updateFavoritesFromContacts() {
    // Update contacts with favorite status
    _contacts = _contacts.map((contact) {
      return contact.copyWith(
          isFavorite: _favoriteNames.contains(contact.name));
    }).toList();
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

  void _toggleFavoritesMode() {
    setState(() {
      _favoritesMode = !_favoritesMode;
      // Reset scroll positions when toggling mode
      _currentPage1 = 0;
      _currentPage2 = 0;
      if (_scrollController1.hasClients) {
        _scrollController1.jumpTo(0);
      }
      if (_scrollController2.hasClients) {
        _scrollController2.jumpTo(0);
      }
    });
    _checkForMatch();
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
  }

  void _updateOverlayHeight(double delta, double cardHeight) {
    setState(() {
      // delta is negative when dragging up, positive when dragging down
      // We want dragging up to increase overlay height, down to decrease
      final heightChange = -delta / cardHeight;
      _overlayHeight = (_overlayHeight + heightChange).clamp(0.0, 1.0);
    });
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
    return ListView.builder(
      controller: controller,
      scrollDirection: Axis.horizontal,
      physics: const PageScrollPhysics(),
      itemExtent: width,
      itemCount: displayedContacts.length,
      itemBuilder: (context, index) {
        final contact = displayedContacts[index];
        final isCurrentPage =
            (controller == _scrollController1 && index == _currentPage1) ||
                (controller == _scrollController2 && index == _currentPage2);
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
                        final flashOpacity = isCurrentPage && baseMatch
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
                        final flashOpacity = isCurrentPage && overlayMatch
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
                    child: _isHudVisible
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                contact.name,
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              isCurrentPage && _isMatch
                                  ? AnimatedBuilder(
                                      animation: heartAnimationController,
                                      builder: (context, child) {
                                        // Scale from 1.0 to 1.2 when there's a match
                                        final scale = 1.0 +
                                            (heartAnimationController.value *
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
                                              _toggleFavorite(contact.name);
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
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
                                      visualDensity: VisualDensity.compact,
                                    ),
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
                savedPage1 = (_scrollController1.offset / oldWidth)
                    .round()
                    .clamp(0, displayedContacts.length - 1);
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
                savedPage2 = (_scrollController2.offset / oldWidth)
                    .round()
                    .clamp(0, displayedContacts.length - 1);
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
                final targetOffset = savedPage1 * halfWidth;
                _scrollController1.jumpTo(targetOffset);
                _currentPage1 = savedPage1;
              }
            });
          }

          if (widthChanged2) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_scrollController2.hasClients && halfWidth > 0) {
                final targetOffset = savedPage2 * halfWidth;
                _scrollController2.jumpTo(targetOffset);
                _currentPage2 = savedPage2;
              }
            });
          }

          return Stack(
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
                        _heartAnimationController1,
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
                        _heartAnimationController2,
                        _flashAnimationController2,
                        _baseMatch2,
                        _overlayMatch2),
                  ),
                ],
              ),
              if (_isHudVisible)
                Positioned(
                  top: 0,
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
            ],
          );
        }));
  }
}
