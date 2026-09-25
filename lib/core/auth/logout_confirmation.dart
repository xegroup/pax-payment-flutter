import 'package:flutter/material.dart';

import '../di/injection.dart';
import '../database/local_storage.dart';

/// Shows logout dialog with username and password confirmation.
Future<bool> confirmLogoutWithPassword(BuildContext context) async {
  final username = sl<LocalStorage>().loginUsername.trim();
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _LogoutPasswordDialog(username: username),
  );
  return result == true;
}

class _LogoutPasswordDialog extends StatefulWidget {
  const _LogoutPasswordDialog({required this.username});

  final String username;

  @override
  State<_LogoutPasswordDialog> createState() => _LogoutPasswordDialogState();
}

class _LogoutPasswordDialogState extends State<_LogoutPasswordDialog> {
  late final TextEditingController _passwordCtrl;
  bool _obscure = true;
  bool _isVerifying = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _passwordCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordCtrl.text.trim();
    if (password.isEmpty) {
      setState(() => _errorText = 'Enter your password');
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    final verified =
        await sl<LocalStorage>().verifyLoginPassword(password);
    if (!mounted) return;

    if (verified) {
      Navigator.pop(context, true);
      return;
    }

    setState(() {
      _isVerifying = false;
      _errorText = 'Incorrect password';
    });
  }

  @override
  Widget build(BuildContext context) {
    final usernameLabel = widget.username.isNotEmpty
        ? widget.username
        : 'Signed-in user';

    return AlertDialog(
      title: const Text('Log out'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Username',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 4),
          Text(
            usernameLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            enabled: !_isVerifying,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Password',
              errorText: _errorText,
              suffixIcon: IconButton(
                onPressed: _isVerifying
                    ? null
                    : () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isVerifying ? null : _submit,
          child: _isVerifying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Log out'),
        ),
      ],
    );
  }
}
