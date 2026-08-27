import 'package:flutter/material.dart';

import 'auth_session.dart';
import 'session_service.dart';
import '../network/MyApiClient.dart';

/// Re-validates the session when the app returns to the foreground.
class SessionLifecycleWatcher extends StatefulWidget {
  const SessionLifecycleWatcher({super.key, required this.child});

  final Widget child;

  @override
  State<SessionLifecycleWatcher> createState() =>
      _SessionLifecycleWatcherState();
}

class _SessionLifecycleWatcherState extends State<SessionLifecycleWatcher>
    with WidgetsBindingObserver {
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verifySession();
    }
  }

  Future<void> _verifySession() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      final status = await SessionService.validateStoredSession();
      if (status == SessionStatus.expired) {
        await AuthSession.handleUnauthorized(
          clearToken: MyApiClient.clearAuthToken,
        );
      }
    } catch (_) {
      // Ignore transient network errors while the app is open.
    } finally {
      _isChecking = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
