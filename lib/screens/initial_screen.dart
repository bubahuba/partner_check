import 'package:flutter/material.dart';
import '../services/contact_storage_service.dart';
import 'contacts_page.dart';
import 'settings_screen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  InitialScreenState createState() => InitialScreenState();
}

class InitialScreenState extends State<InitialScreen> {
  bool? _hasContacts;

  @override
  void initState() {
    super.initState();
    _loadInitialRoute();
  }

  Future<void> _loadInitialRoute() async {
    final contacts = await ContactStorageService().loadContacts();
    if (!mounted) return;
    setState(() {
      _hasContacts = contacts.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasContacts == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_hasContacts!) {
      return const ContactsPage();
    }

    return const SettingsScreen();
  }
}
