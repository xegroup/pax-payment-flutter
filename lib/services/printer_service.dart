import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/device/pax_device_channel.dart';
import '../features/menu/models/payment_transaction.dart';

/// Receipt printing (preview / PAX channel stub until SDK is integrated).
class PrinterService {
  PrinterService._();

  static final _ukDate = DateFormat('dd/MM/yyyy HH:mm', 'en_GB');
  static final _money = NumberFormat.currency(locale: 'en_GB', symbol: '£');

  static String formatReceiptText(PaymentTransaction transaction) {
    final type = transaction.isRefund
        ? 'Refund'
        : transaction.isCash
            ? 'Cash'
            : 'Sale';
    final last4 = transaction.cardLast4?.trim() ?? '';
    final cardLine = transaction.isCash
        ? 'Cash'
        : '${transaction.cardType} •••• ${last4.length >= 4 ? last4.substring(last4.length - 4) : '····'}';
    final auth = transaction.id.length <= 8
        ? transaction.id
        : transaction.id.substring(0, 8);
    final ref = transaction.id.startsWith('TXN-')
        ? transaction.id
        : 'TXN-${transaction.id}';

    return '''
    XEPOS
    -------------------------
    Date: ${transaction.time}
    Type: $type
    Amount: ${_money.format(transaction.amount.abs())}
    Card: $cardLine
    Auth: $auth
    Ref: $ref
    -------------------------
    APPROVED
    Thank you
''';
  }

  static String testReceiptText() => '''
    XEPOS
    -------------------------
    Test Print - XEPOS - OK
    -------------------------
''';

  /// Prints a payment receipt. Shows preview dialog until PAX SDK is wired.
  static Future<void> printReceipt(
    BuildContext context,
    PaymentTransaction transaction,
  ) async {
    final body = formatReceiptText(transaction);
    await _printOrPreview(context, body, title: 'Receipt');
    // TODO: Replace with PAX PrinterManager SDK call — see PAX PAXSTORE SDK docs
    try {
      await PaxDeviceChannel.printText(body);
    } catch (_) {
      // Native print not available; preview already shown.
    }
  }

  static Future<void> printTestReceipt(BuildContext context) async {
    const body = '''
    XEPOS
    -------------------------
    Test Print - XEPOS - OK
    -------------------------
''';
    await _printOrPreview(context, body, title: 'Test print');
    try {
      await PaxDeviceChannel.printText(body);
    } catch (_) {}
  }

  static Future<void> _printOrPreview(
    BuildContext context,
    String text, {
    required String title,
  }) async {
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            text.trim(),
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.35,
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
