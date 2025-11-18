import 'package:flutter/material.dart';
import 'contacts_page.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  InitialScreenState createState() => InitialScreenState();
}

class InitialScreenState extends State<InitialScreen> {
  @override
  Widget build(BuildContext context) {
    // Always show ContactsPage first, even if empty
    // SettingsScreen will be shown only when explicitly opened from ContactsPage
    return const ContactsPage();
  }
}
