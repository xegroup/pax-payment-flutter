import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/network/MyApiClient.dart';
import '../features/auth/data/login_response.dart';
import '../features/auth/data/signup_request.dart';
import '../features/auth/login_screen.dart';
import '../features/menu/checkout_payment_screen.dart';
import '../shared/theme/pax_text_styles.dart';
import 'teya_ui.dart';

/// First launch: register a merchant account via the signup API.
class FirstTimeSetupScreen extends StatefulWidget {
  const FirstTimeSetupScreen({super.key});

  @override
  State<FirstTimeSetupScreen> createState() => _FirstTimeSetupScreenState();
}

class _FirstTimeSetupScreenState extends State<FirstTimeSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
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

  void _handleSignupResponse(LoginResponse response) {
    if (response.isSuccess) {
      MyApiClient.setAuthToken(response.token.trim());
      Navigator.of(context).pushReplacement(CheckoutPaymentScreen.materialRoute());
      return;
    }
    _showError(response.failureMessage);
  }

  Future<void> _goToLogin() async {
    if (_isLoading || !mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _signup() async {
    FocusScope.of(context).unfocus();
    if (_isLoading) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final request = SignupRequest(
        name: _nameCtrl.text.trim(),
        username: _usernameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        password: _passwordCtrl.text,
        status: 'active',
      );
      final response = await MyApiClient.signup(request.toJson());
      if (!mounted) return;
      _handleSignupResponse(response);
    } on DioException catch (e) {
      if (!mounted) return;
      final parsed = LoginResponse.tryParse(e.response?.data);
      if (parsed != null) {
        _showError(parsed.failureMessage);
        return;
      }
      _showError('Unable to create account. Please try again.');
    } catch (_) {
      if (!mounted) return;
      _showError('Unable to create account. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TeyaScreenScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'Create account',
              style: PaxTextStyles.h2.copyWith(color: TeyaColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Register your merchant account for this PAX terminal.',
              style: PaxTextStyles.bodyMedium.copyWith(color: TeyaColors.textGrey),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      hintText: 'Business or owner name',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _usernameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Choose a username',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter a username' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@business.com',
                    ),
                    validator: (v) {
                      final s = v?.trim() ?? '';
                      if (s.isEmpty) return 'Enter your email';
                      if (!s.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    decoration: const InputDecoration(
                      labelText: 'Phone',
                      hintText: 'Phone number',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter your phone number' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _signup(),
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: 'Password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.length < 4) ? 'Minimum 4 characters' : null,
                  ),
                  const SizedBox(height: 24),
                  TeyaPrimaryButton(
                    label: _isLoading ? 'Creating account...' : 'Create account',
                    enabled: !_isLoading,
                    onPressed: _signup,
                  ),
                  const SizedBox(height: 12),
                  TeyaSecondaryButton(
                    label: 'Already a user',
                    onPressed: _goToLogin,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
