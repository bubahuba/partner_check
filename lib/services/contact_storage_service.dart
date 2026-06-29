import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models.dart';

/// Service for managing contact storage using SharedPreferences
class ContactStorageService {
  static const String _storageKey = 'stored_contacts';
  static const String _favoritesKey = 'favorite_contacts';
  static const String _vibrationsKey = 'vibrations_enabled';
  static const String _hudVisibleKey = 'hud_visible';
  static const String _scrollPos1AllKey = 'scroll_pos_1_all';
  static const String _scrollPos2AllKey = 'scroll_pos_2_all';
  static const String _scrollPos1FavoritesKey = 'scroll_pos_1_favorites';
  static const String _scrollPos2FavoritesKey = 'scroll_pos_2_favorites';
  static const String _lockedPaneKey = 'locked_pane';
  static const String _orderingContactKey = 'ordering_contact';
  static const String _originalContactOrderKey = 'original_contact_order';
  static const String _pendingSelfContactPickKey = 'pending_self_contact_pick';
  static const String _selfContactNameKey = 'self_contact_name';
  static const String _selfContactColorKey = 'self_contact_color';
  static const String _contactsBulkLoadedKey = 'contacts_bulk_loaded';
  static const String _settingsAddedContactKey = 'settings_added_contact_name';

  /// Load contacts from storage
  Future<List<StoredContact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString(_storageKey);

    if (storedData != null) {
      final List<dynamic> jsonList = json.decode(storedData);
      return jsonList.map((json) => StoredContact.fromJson(json)).toList();
    }
    return [];
  }

  /// Save contacts to storage
  Future<void> saveContacts(List<StoredContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = contacts.map((contact) => contact.toJson()).toList();
    await prefs.setString(_storageKey, json.encode(jsonList));
  }

  /// Load favorites from storage
  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesList = prefs.getStringList(_favoritesKey);
    return favoritesList?.toSet() ?? {};
  }

  /// Save favorites to storage
  Future<void> saveFavorites(Set<String> favoriteNames) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, favoriteNames.toList());
  }

  /// Load vibrations setting
  Future<bool> loadVibrationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationsKey) ?? true;
  }

  /// Save vibrations setting
  Future<void> saveVibrationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationsKey, enabled);
  }

  /// Load HUD visibility state
  Future<bool> loadHudVisible() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hudVisibleKey) ?? true;
  }

  /// Save HUD visibility state
  Future<void> saveHudVisible(bool visible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hudVisibleKey, visible);
  }

  /// Load scroll positions
  Future<ScrollPositions> loadScrollPositions() async {
    final prefs = await SharedPreferences.getInstance();
    return ScrollPositions(
      page1All: prefs.getInt(_scrollPos1AllKey) ?? 0,
      page2All: prefs.getInt(_scrollPos2AllKey) ?? 0,
      page1Favorites: prefs.getInt(_scrollPos1FavoritesKey) ?? 0,
      page2Favorites: prefs.getInt(_scrollPos2FavoritesKey) ?? 0,
    );
  }

  /// Save scroll positions
  Future<void> saveScrollPositions(ScrollPositions positions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scrollPos1AllKey, positions.page1All);
    await prefs.setInt(_scrollPos2AllKey, positions.page2All);
    await prefs.setInt(_scrollPos1FavoritesKey, positions.page1Favorites);
    await prefs.setInt(_scrollPos2FavoritesKey, positions.page2Favorites);
  }

  /// Load locked pane state (1 or 2, or null if not locked)
  Future<int?> loadLockedPane() async {
    final prefs = await SharedPreferences.getInstance();
    final lockedPane = prefs.getInt(_lockedPaneKey);
    return lockedPane; // Returns null if not set
  }

  /// Save locked pane state
  Future<void> saveLockedPane(int? lockedPane) async {
    final prefs = await SharedPreferences.getInstance();
    if (lockedPane != null) {
      await prefs.setInt(_lockedPaneKey, lockedPane);
    } else {
      await prefs.remove(_lockedPaneKey);
    }
  }

  /// Load ordering contact name
  Future<String?> loadOrderingContact() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_orderingContactKey);
  }

  /// Save ordering contact name
  Future<void> saveOrderingContact(String? contactName) async {
    final prefs = await SharedPreferences.getInstance();
    if (contactName != null && contactName.isNotEmpty) {
      await prefs.setString(_orderingContactKey, contactName);
    } else {
      await prefs.remove(_orderingContactKey);
    }
  }

  /// Load original contact order
  Future<List<StoredContact>> loadOriginalContactOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString(_originalContactOrderKey);

    if (storedData != null) {
      final List<dynamic> jsonList = json.decode(storedData);
      return jsonList.map((json) => StoredContact.fromJson(json)).toList();
    }
    return [];
  }

  /// Save original contact order
  Future<void> saveOriginalContactOrder(List<StoredContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = contacts.map((contact) => contact.toJson()).toList();
    await prefs.setString(_originalContactOrderKey, json.encode(jsonList));
  }

  /// Clear original contact order
  Future<void> clearOriginalContactOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_originalContactOrderKey);
  }

  /// Whether the user still needs to pick their own contact (iOS after bulk import).
  Future<bool> loadPendingSelfContactPick() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pendingSelfContactPickKey) ?? false;
  }

  Future<void> savePendingSelfContactPick(bool pending) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pendingSelfContactPickKey, pending);
  }

  /// Saved "me" contact identity (survives scroll position changes).
  Future<StoredSelfContact?> loadSelfContact() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_selfContactNameKey);
    if (name == null || name.isEmpty) return null;
    return StoredSelfContact(
      name: name,
      color: prefs.getInt(_selfContactColorKey) ?? 0,
    );
  }

  Future<void> saveSelfContact(StoredSelfContact contact) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selfContactNameKey, contact.name);
    await prefs.setInt(_selfContactColorKey, contact.color);
  }

  Future<void> clearSelfContact() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_selfContactNameKey);
    await prefs.remove(_selfContactColorKey);
  }

  Future<void> markContactsBulkLoaded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_contactsBulkLoadedKey, true);
  }

  Future<bool> loadAndClearContactsBulkLoaded() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getBool(_contactsBulkLoadedKey) ?? false;
    if (value) {
      await prefs.remove(_contactsBulkLoadedKey);
    }
    return value;
  }

  /// Marks that settings added a single contact that should be selected for sorting.
  Future<void> markSettingsAddedContact(String contactName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_contactsBulkLoadedKey, true);
    await prefs.setString(_settingsAddedContactKey, contactName);
  }

  Future<String?> loadAndClearSettingsAddedContact() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_settingsAddedContactKey);
    if (name != null) {
      await prefs.remove(_settingsAddedContactKey);
    }
    return name;
  }
}

/// Persisted identity of the user's own contact.
class StoredSelfContact {
  final String name;
  final int color;

  const StoredSelfContact({required this.name, required this.color});
}

/// Data class for scroll positions
class ScrollPositions {
  final int page1All;
  final int page2All;
  final int page1Favorites;
  final int page2Favorites;

  ScrollPositions({
    required this.page1All,
    required this.page2All,
    required this.page1Favorites,
    required this.page2Favorites,
  });
}
