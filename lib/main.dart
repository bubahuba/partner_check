import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/initial_screen.dart';
import 'services/pro_subscription_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final proService = ProSubscriptionService();
  await proService.initialize();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ChangeNotifierProvider.value(
      value: proService,
      child: const PartnerCheck(),
    ),
  );
}

class PartnerCheck extends StatelessWidget {
  const PartnerCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Partner Check',
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) {
          return supportedLocales.first;
        }
        final languageCode =
            locale.languageCode == 'iw' ? 'he' : locale.languageCode;
        for (final supported in supportedLocales) {
          if (supported.languageCode == languageCode) {
            return supported;
          }
        }
        return supportedLocales.first;
      },
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
