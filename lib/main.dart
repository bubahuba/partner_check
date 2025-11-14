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
      title: 'PartnerCheck Free',
      home: const InitialScreen(),
    );
  }
}
