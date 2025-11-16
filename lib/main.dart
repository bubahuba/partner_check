import 'package:flutter/material.dart';
import 'screens/initial_screen.dart';

void main() {
  runApp(const PartnerCheck());
}

class PartnerCheck extends StatelessWidget {
  const PartnerCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Partner Check',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          surface: Colors.black,
        ),
      ),
      home: const InitialScreen(),
    );
  }
}
