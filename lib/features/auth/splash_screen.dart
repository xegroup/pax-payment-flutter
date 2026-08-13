import 'package:flutter/material.dart';

import '../../core/di/injection.dart';
import '../../core/network/MyApiClient.dart';
import '../../core/security/secure_storage_service.dart';
import '../../shared/responsive/responsive.dart';
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

    await Future<void>.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final token = await sl<SecureStorageService>().getAuthToken();
    if (token != null && token.isNotEmpty) {
      Navigator.of(context).pushReplacement(CheckoutPaymentScreen.materialRoute());
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final titleSize = r.layout(
      mobilePortrait: r.widthPercent(0.09, min: 26, max: 34),
      mobileLandscape: r.widthPercent(0.07, min: 20, max: 28),
      tabletPortrait: r.widthPercent(0.06, min: 36, max: 48),
      tabletLandscape: r.widthPercent(0.045, min: 32, max: 44),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0D2B5E),
      body: Center(
        child: Text(
          'PAX PAYMENT',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontSize: titleSize,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
