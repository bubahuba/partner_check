import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/contact_storage_service.dart';
import '../utils/web_deep_link.dart';
import 'contacts_page.dart';
import 'lava_screen.dart';
import 'plasma_screen.dart';
import 'settings_screen.dart';
import 'tetris_screen.dart';

class InitialScreen extends StatefulWidget {
  const InitialScreen({super.key});

  @override
  InitialScreenState createState() => InitialScreenState();
}

class InitialScreenState extends State<InitialScreen> {
  bool? _hasContacts;
  WebDeepLink? _webDeepLink;

  @override
  void initState() {
    super.initState();
    _loadInitialRoute();
  }

  Future<void> _loadInitialRoute() async {
    WebDeepLink? webDeepLink;
    if (kIsWeb) {
      webDeepLink = parseWebDeepLink(Uri.base);
    }

    final contacts = await ContactStorageService().loadContacts();
    if (!mounted) return;
    setState(() {
      _hasContacts = contacts.isNotEmpty;
      _webDeepLink = webDeepLink;
    });
  }

  void _closeWebDeepLink() {
    setState(() {
      _webDeepLink = null;
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

    final webDeepLink = _webDeepLink;
    if (webDeepLink != null) {
      return switch (webDeepLink.feature) {
        WebDeepLinkFeature.tetris => TetrisScreen(
            session: webDeepLink.session,
            isSharedLaunch: true,
            onClose: _closeWebDeepLink,
          ),
        WebDeepLinkFeature.plasma => PlasmaScreen(
            session: webDeepLink.session,
            isSharedLaunch: true,
            onClose: _closeWebDeepLink,
          ),
        WebDeepLinkFeature.lava => LavaScreen(
            session: webDeepLink.session,
            isSharedLaunch: true,
            onClose: _closeWebDeepLink,
          ),
      };
    }

    if (_hasContacts!) {
      return const ContactsPage();
    }

    return const SettingsScreen();
  }
}
