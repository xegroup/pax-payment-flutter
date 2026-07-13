import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/di/injection.dart';
import '../core/database/local_storage.dart';
import '../features/auth/login_screen.dart';
import '../shared/theme/pax_text_styles.dart';
import '../screens/teya_ui.dart';

/// First launch: merchant sets username, password, and manager PIN.
class FirstTimeSetupScreen extends StatefulWidget {
  const FirstTimeSetupScreen({super.key});

  @override
  State<FirstTimeSetupScreen> createState() => _FirstTimeSetupScreenState();
}

class _FirstTimeSetupScreenState extends State<FirstTimeSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _confirmPinCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _pinCtrl.dispose();
    _confirmPinCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final storage = sl<LocalStorage>();
    await storage.setLoginUsername(_usernameCtrl.text.trim());
    await storage.setLoginPassword(_passwordCtrl.text);
    await storage.setManagerPin(_pinCtrl.text.trim());
    await storage.setCredentialsConfigured(true);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TeyaScreenScaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              'First-time setup',
              style: PaxTextStyles.h2.copyWith(color: TeyaColors.textDark),
            ),
            const SizedBox(height: 8),
            Text(
              'Create credentials for this PAX terminal.',
              style: PaxTextStyles.bodyMedium.copyWith(color: TeyaColors.textGrey),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _usernameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      hintText: 'Merchant login',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Enter a username' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscurePassword,
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
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPasswordCtrl,
                    obscureText: _obscurePassword,
                    decoration: const InputDecoration(
                      labelText: 'Confirm password',
                    ),
                    validator: (v) {
                      if (v != _passwordCtrl.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _pinCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Manager PIN',
                      hintText: '4 digits',
                    ),
                    validator: (v) {
                      if (v == null || v.length != 4) {
                        return 'PIN must be 4 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _confirmPinCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm manager PIN',
                    ),
                    validator: (v) {
                      if (v != _pinCtrl.text) {
                        return 'PINs do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  TeyaPrimaryButton(label: 'Complete setup', onPressed: _save),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
