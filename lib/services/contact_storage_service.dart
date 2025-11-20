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

