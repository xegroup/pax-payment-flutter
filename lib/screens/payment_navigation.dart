import 'package:flutter/material.dart';

import '../features/menu/checkout_payment_screen.dart';
import 'payment_declined_screen.dart';
import 'payment_success_screen.dart';

/// Clears the payment stack and opens a fresh [CheckoutPaymentScreen].
void navigateToCheckout(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    CheckoutPaymentScreen.materialRoute(),
    (route) => false,
  );
}

/// Opens success screen. When [popWithResult] is true, pops with `true` on done (split flow).
void navigateToPaymentSuccess(
  BuildContext context, {
  required double amount,
  String? cardLast4,
  String? cardType,
  required String transactionId,
  DateTime? timestamp,
  bool popWithResult = false,
}) {
  final route = MaterialPageRoute<void>(
    builder: (_) => PaymentSuccessScreen(
      amount: amount,
      cardLast4: cardLast4,
      cardType: cardType,
      transactionId: transactionId,
      timestamp: timestamp.toString(),
      popWithResult: popWithResult,
    ),
  );
  if (popWithResult) {
    Navigator.of(context).push(route);
  } else {
    Navigator.of(context).pushAndRemoveUntil(
      route,
      (route) => route.settings.name == CheckoutPaymentScreen.routeName,
    );
  }
}

void navigateToPaymentDeclined(
  BuildContext context, {
  required double amount,
  String? declineReason,
  bool popWithResult = false,
}) {
  final route = MaterialPageRoute<void>(
    builder: (_) => PaymentDeclinedScreen(
      amount: amount,
      declineReason: declineReason,
      popWithResult: popWithResult,
    ),
  );
  if (popWithResult) {
    Navigator.of(context).pushReplacement(route);
  } else {
    Navigator.of(context).pushAndRemoveUntil(
      route,
      (route) => route.settings.name == CheckoutPaymentScreen.routeName,
    );
  }
}
