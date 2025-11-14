import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'contacts_page.dart';
import 'settings_screen.dart';

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

