import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'settings_screen.dart';
import 'models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts Phone Numbers',
      home: const InitialScreen(),
    );
  }
}

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  static const String _storageKey = 'stored_contacts';
  bool _isLoading = true;
  bool _hasStorage = false;

  @override
  void initState() {
    super.initState();
    _checkStorage();
  }

  Future<void> _checkStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString(_storageKey);
    setState(() {
      _hasStorage = storedData != null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasStorage) {
      return const ContactsPage();
    } else {
      return const SettingsScreen();
    }
  }
}

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
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

  static const Color _fallbackTileColor = Color(0xFFE0E0E0);
  static const String _storageKey = 'stored_contacts';
  static const String _favoritesKey = 'favorite_contacts';

  @override
  void initState() {
    super.initState();
    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();
    _addScrollListeners();
    _loadContacts();
    _loadFavorites();
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
            _currentPage1 = page;
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
            _currentPage2 = page;
          }
        }
      }
    });
  }

  Color _colorFromValue(int colorValue) {
    return Color(0xFF000000 | colorValue);
  }

  Color _overlayColorFromValue(int colorValue) {
    // Reverse the hex digits: 123456 -> 654321
    // Convert to 6-digit hex string, reverse it, then convert back
    final hexString = colorValue.toRadixString(16).padLeft(6, '0');
    final reversedHexString = hexString.split('').reversed.join('');
    final reversed = int.parse(reversedHexString, radix: 16);
    return Color(reversed);
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();
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
    }
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

  Widget _buildListView(ScrollController controller, double height,
      double width, int currentPage, bool needsRestore) {
    final displayedContacts = _displayedContacts;
    return ListView.builder(
      controller: controller,
      scrollDirection: Axis.horizontal,
      physics: const PageScrollPhysics(),
      itemExtent: width,
      itemCount: displayedContacts.length,
      itemBuilder: (context, index) {
        final contact = displayedContacts[index];
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
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                contact.name,
                                style: const TextStyle(color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              IconButton(
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
          } else if (_lastWidth1 == null) {
            _lastWidth1 = halfWidth;
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
          } else if (_lastWidth2 == null) {
            _lastWidth2 = halfWidth;
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
                    child: _buildListView(_scrollController1,
                        constraints.maxHeight, halfWidth, _currentPage1, false),
                  ),
                  Expanded(
                    child: _buildListView(_scrollController2,
                        constraints.maxHeight, halfWidth, _currentPage2, false),
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
                    },
                  ),
                ),
            ],
          );
        }));
  }
}
