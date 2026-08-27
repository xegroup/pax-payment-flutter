import 'package:flutter/material.dart';

import '../../core/auth/session_service.dart';
import '../../core/network/MyApiClient.dart';
import '../../shared/responsive/responsive.dart';
import '../../shared/theme/paxpayment_colors.dart';
import '../menu/checkout_payment_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _routeNext());
  }

  Future<void> _routeNext() async {
    MyApiClient.init('https://api-app.xepay.co.uk/');
    await MyApiClient.loadPersistedAuthToken();

    if (!mounted) return;

    try {
      final status = await SessionService.validateStoredSession();
      if (!mounted) return;

      switch (status) {
        case SessionStatus.authenticated:
          Navigator.of(context).pushReplacement(
            CheckoutPaymentScreen.materialRoute(),
          );
        case SessionStatus.expired:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => const LoginScreen(
                sessionMessage:
                    'Your session has expired. Please sign in again.',
              ),
            ),
          );
        case SessionStatus.unauthenticated:
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
          );
      }
    } catch (_) {
      await MyApiClient.clearAuthToken();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final iconSize = r.layout(
      mobilePortrait: r.widthPercent(0.42, min: 140, max: 220),
      mobileLandscape: r.heightPercent(0.5, min: 120, max: 180),
      tabletPortrait: r.widthPercent(0.28, min: 180, max: 260),
      tabletLandscape: r.heightPercent(0.45, min: 160, max: 240),
    );

    return Scaffold(
      backgroundColor: PaxPaymentColors.primaryBlue,
      body: Center(
        child: Image.asset(
          'assets/images/xepay_icon.png',
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
