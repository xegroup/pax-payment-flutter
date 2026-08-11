import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/network/MyApiClient.dart';
import '../../features/auth/data/login_request.dart';
import '../../features/auth/data/login_response.dart';
import '../../screens/first_time_setup_screen.dart';
import '../../shared/resources/paxpayment_strings.dart';
import '../../shared/responsive/responsive.dart';
import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';
import '../menu/checkout_payment_screen.dart';

/// Sign-in screen backed by the login API.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailOrPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleLoginResponse(LoginResponse response) {
    if (response.isSuccess) {
      MyApiClient.setAuthToken(response.token.trim());
      Navigator.of(context).pushReplacement(CheckoutPaymentScreen.materialRoute());
      return;
    }
    _showError(response.failureMessage);
  }

  Future<void> _onLogin() async {
    FocusScope.of(context).unfocus();
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final request = LoginRequest(
        email: _emailOrPhoneController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final response = await MyApiClient.login(request.toJson());
      if (!mounted) return;
      _handleLoginResponse(response);
    } on DioException catch (e) {
      if (!mounted) return;
      final parsed = LoginResponse.tryParse(e.response?.data);
      if (parsed != null) {
        _showError(parsed.failureMessage);
        return;
      }
      _showError('Unable to sign in. Please try again.');
    } catch (_) {
      if (!mounted) return;
      _showError('Unable to sign in. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _goToSignup() {
    if (_isLoading || !mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const FirstTimeSetupScreen()),
    );
  }

  void _onForgotPassword() {
    FocusScope.of(context).unfocus();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Forgot password'),
        content: Text(
          'Contact support:\n${PaxPaymentStrings.supportPhoneUK}\n'
          '${PaxPaymentStrings.supportPhoneUSA}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);

    final maxFormWidth = r.layout(
      mobilePortrait: r.widthPercent(0.92, min: 300, max: 420),
      mobileLandscape: r.widthPercent(0.55, min: 320, max: 440),
      tabletPortrait: r.widthPercent(0.55, min: 400, max: 480),
      tabletLandscape: r.widthPercent(0.38, min: 400, max: 520),
    );

    final horizontalPad = r.layout(
      mobilePortrait: PaxPaymentSpacing.sp20,
      mobileLandscape: PaxPaymentSpacing.sp24,
      tabletPortrait: PaxPaymentSpacing.sp32,
      tabletLandscape: PaxPaymentSpacing.sp32,
    );

    final sectionGap = r.layout(
      mobilePortrait: PaxPaymentSpacing.sp24,
      mobileLandscape: PaxPaymentSpacing.sp16,
      tabletPortrait: PaxPaymentSpacing.sp28,
      tabletLandscape: PaxPaymentSpacing.sp24,
    );

    final fieldGap = r.value(
      mobile: PaxPaymentSpacing.sp16,
      tablet: PaxPaymentSpacing.sp20,
    );

    final titleSize = r.layout(
      mobilePortrait: 26.0,
      mobileLandscape: 22.0,
      tabletPortrait: 30.0,
      tabletLandscape: 28.0,
    );

    final subtitleSize = r.layout(
      mobilePortrait: 15.0,
      mobileLandscape: 14.0,
      tabletPortrait: 16.0,
      tabletLandscape: 15.0,
    );

    final buttonHeight = r.value(
      mobile: PaxPaymentSpacing.buttonHeightMd,
      tablet: PaxPaymentSpacing.buttonHeightLg,
    );

    final borderRadius = BorderRadius.circular(PaxPaymentSpacing.radiusLg);

    return Scaffold(
      backgroundColor: PaxPaymentColors.adminBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPad,
              vertical: PaxPaymentSpacing.sp16,
            ),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxFormWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: r.value(mobile: 48.0, tablet: 56.0),
                      color: PaxPaymentColors.adminTitle,
                    ),
                    SizedBox(height: sectionGap * 0.5),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w800,
                            color: PaxPaymentColors.darkGrayText,
                            letterSpacing: -0.5,
                          ),
                    ),
                    SizedBox(height: PaxPaymentSpacing.sp8),
                    Text(
                      'Sign in with your username and password.',
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontSize: subtitleSize,
                                color: PaxPaymentColors.hintText,
                                height: 1.35,
                              ),
                    ),
                    SizedBox(height: sectionGap),
                    TextFormField(
                      controller: _emailOrPhoneController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      decoration: InputDecoration(
                        labelText: 'Username',
                        hintText: 'Enter your username',
                        filled: true,
                        fillColor: PaxPaymentColors.white,
                        border: OutlineInputBorder(borderRadius: borderRadius),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: borderRadius,
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: borderRadius,
                          borderSide: const BorderSide(
                            color: PaxPaymentColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: PaxPaymentColors.adminTitle,
                        ),
                      ),
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (s.isEmpty) return 'Enter your username';
                        return null;
                      },
                    ),
                    SizedBox(height: fieldGap),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onLogin(),
                      autofillHints: const [AutofillHints.password],
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        filled: true,
                        fillColor: PaxPaymentColors.white,
                        border: OutlineInputBorder(borderRadius: borderRadius),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: borderRadius,
                          borderSide: BorderSide(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: borderRadius,
                          borderSide: const BorderSide(
                            color: PaxPaymentColors.primaryBlue,
                            width: 2,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                          color: PaxPaymentColors.adminTitle,
                        ),
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword ? 'Show' : 'Hide',
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: PaxPaymentColors.mediumGray,
                          ),
                        ),
                      ),
                      validator: (v) {
                        final s = v?.trim() ?? '';
                        if (s.isEmpty) return 'Enter your password';
                        return null;
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _onForgotPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    SizedBox(height: PaxPaymentSpacing.sp8),
                    SizedBox(
                      height: buttonHeight,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _onLogin,
                        style: FilledButton.styleFrom(
                          backgroundColor: PaxPaymentColors.primaryBlue,
                          foregroundColor: PaxPaymentColors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: borderRadius,
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: PaxPaymentColors.white,
                                ),
                              )
                            : Text(
                                'Log in',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: PaxPaymentColors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                      ),
                    ),
                    SizedBox(height: PaxPaymentSpacing.sp12),
                    TextButton(
                      onPressed: _isLoading ? null : _goToSignup,
                      child: const Text('Create account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
