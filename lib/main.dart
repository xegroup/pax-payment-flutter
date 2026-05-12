import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_route_observer.dart';
import 'core/di/injection.dart';
import 'features/auth/splash_screen.dart';
import 'features/menu/data/dummy_payments_data.dart';
import 'shared/theme/theme_service.dart';
import 'shared/utils/localization_service.dart';

late final ThemeService appThemeService;
late final LocalizationService appLocalizationService;

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetIt.I.reset();
  await setupDependencies();
  final prefs = sl<SharedPreferences>();
  appThemeService = ThemeService(prefs: prefs);
  appLocalizationService = LocalizationService(prefs: prefs);
  await DummyPaymentsData.initialize();
}

Future<void> main() async {
  await initializeApp();
  runApp(const PaxPaymentApp());
}

class PaxPaymentApp extends StatelessWidget {
  const PaxPaymentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([appThemeService, appLocalizationService]),
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorObservers: [appRouteObserver],
          theme: appThemeService.lightTheme,
          darkTheme: appThemeService.darkTheme,
          themeMode: appThemeService.themeMode,
          locale: appLocalizationService.currentLocale,
          supportedLocales: appLocalizationService.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const SplashScreen(),
        );
      },
    );
  }
}
