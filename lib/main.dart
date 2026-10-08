import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app_route_observer.dart';
import 'core/auth/auth_session.dart';
import 'core/auth/session_lifecycle_watcher.dart';
import 'core/config/app_flags.dart';
import 'core/di/injection.dart';
import 'features/auth/splash_screen.dart';
import 'features/menu/data/dummy_payments_data.dart';
import 'shared/resources/paxpayment_strings.dart';
import 'shared/theme/theme_service.dart';
import 'shared/utils/localization_service.dart';

ThemeService? _appThemeService;
ThemeService get appThemeService => _appThemeService!;

LocalizationService? _appLocalizationService;
LocalizationService get appLocalizationService => _appLocalizationService!;

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (isMobilePlatform && !isRunningTests) {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
  if (GetIt.I.isRegistered<SharedPreferences>()) {
    await GetIt.I.reset(dispose: false);
  }
  await setupDependencies();
  final prefs = sl<SharedPreferences>();
  if (isRunningTests) {
    _appThemeService = ThemeService(prefs: prefs);
    _appLocalizationService = LocalizationService(prefs: prefs);
  } else {
    _appThemeService ??= ThemeService(prefs: prefs);
    _appLocalizationService ??= LocalizationService(prefs: prefs);
  }
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
        return SessionLifecycleWatcher(
          child: MaterialApp(
            title: PaxPaymentStrings.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: AuthSession.navigatorKey,
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
            builder: (context, child) {
              final mediaQuery = MediaQuery.of(context);
              final keyboardBottom = mediaQuery.viewInsets.bottom;
              // Android reports the IME inset short of the navigation bar,
              // which clips the bottom of the UI while the keyboard is open.
              if (keyboardBottom <= 0 || child == null) {
                return child ?? const SizedBox.shrink();
              }
              return MediaQuery(
                data: mediaQuery.copyWith(
                  viewInsets: mediaQuery.viewInsets.copyWith(
                    bottom: keyboardBottom + 22,
                  ),
                ),
                child: child,
              );
            },
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}
