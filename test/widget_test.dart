import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pax_payment/core/di/injection.dart';
import 'package:pax_payment/core/database/local_storage.dart';
import 'package:pax_payment/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await initializeApp();
  });

  test('initializeApp registers core services', () {
    expect(sl<LocalStorage>(), isNotNull);
  });

  test('hasCredentials is false before setup', () async {
    final storage = sl<LocalStorage>();
    expect(await storage.hasCredentials(), isFalse);
  });

  test('credentials can be stored and verified', () async {
    final storage = sl<LocalStorage>();
    await storage.setLoginUsername('merchant');
    await storage.setLoginPassword('secret');
    await storage.setManagerPin('1234');
    await storage.setCredentialsConfigured(true);

    expect(await storage.hasCredentials(), isTrue);
    expect(await storage.verifyLoginPassword('secret'), isTrue);
    expect(await storage.verifyManagerPin('1234'), isTrue);
  });
}
