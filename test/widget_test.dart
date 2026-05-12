import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pax_payment/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Splash then login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await initializeApp();
    await tester.pumpWidget(const PaxPaymentApp());
    expect(find.text('PAX PAYMENT'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
