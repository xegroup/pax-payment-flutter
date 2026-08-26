import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import '../../features/transaction/data/transaction_save_service.dart';

/// Thrown when a payment cannot be started or completed.
class PaymentServiceException implements Exception {
  final String message;
  final String? code;
  final Object? cause;

  const PaymentServiceException(
    this.message, {
    this.code,
    this.cause,
  });

  @override
  String toString() {
    final buffer = StringBuffer('PaymentServiceException: $message');
    if (code != null) {
      buffer.write(' (code: $code)');
    }
    return buffer.toString();
  }
}

/// Flutter service responsible for delegating payment calls to native code.
class PaymentService {
  static const String _channelName = 'evo_payment_channel';
  static const MethodChannel _channel = MethodChannel(_channelName);

  /// Starts payment: [paymentMethod] is `card` (native EVO) or `cash` (local only).
  ///
  /// [amount] is expected in the smallest currency unit (for example pence).
  Future<Map<String, dynamic>> startPayment({
    required int amount,
    String title = '',
    String paymentMethod = 'card',
  }) async {
    if (amount <= 0) {
      throw const PaymentServiceException(
        'Amount must be greater than zero.',
        code: 'invalid_amount',
      );
    }

    if (paymentMethod == 'cash') {
      final result = <String, dynamic>{
        'status': 'success',
        'transactionId': 'CASH-${DateTime.now().millisecondsSinceEpoch}',
        'amount': (amount / 100).toStringAsFixed(2),
        'cardNumber': '',
        'date': DateTime.now().toIso8601String(),
        'paymentMethod': 'cash',
      };
      await saveTransactionFromEvoResult(
        result,
        amountMajor: amount / 100.0,
      );
      return result;
    }

    final payload = <String, dynamic>{
      'amount': amount,
      'title': title,
      'paymentMethod': paymentMethod,
    };

    try {
      final rawResult = await _channel
          .invokeMethod<dynamic>('startPayment', payload)
          .timeout(const Duration(seconds: 45));

      if (rawResult == null) {
        throw const PaymentServiceException(
          'Native payment returned no result.',
          code: 'empty_result',
        );
      }

      if (rawResult is! Map) {
        throw PaymentServiceException(
          'Unexpected native result type: ${rawResult.runtimeType}.',
          code: 'invalid_result_type',
        );
      }

      final result = rawResult.map(
        (key, value) => MapEntry(key.toString(), value),
      );
      await saveTransactionFromEvoResult(
        result,
        amountMajor: amount / 100.0,
      );
      return result;
    } on PlatformException catch (e) {
      if (e.code == 'IOS_PAYMENT_NOT_SUPPORTED') {
        throw PaymentServiceException(
          e.message ?? 'Card payments are not available on this device.',
          code: 'ios_payment_not_supported',
          cause: e,
        );
      }
      throw PaymentServiceException(
        e.message ?? 'Native payment call failed.',
        code: e.code,
        cause: e,
      );
    } on MissingPluginException catch (e) {
      throw PaymentServiceException(
        Platform.isIOS
            ? 'Card payments are not available on iOS yet. Use cash or another device.'
            : 'Payment channel is not implemented on this platform.',
        code: 'missing_plugin',
        cause: e,
      );
    } on TimeoutException catch (e) {
      throw PaymentServiceException(
        'Payment request timed out.',
        code: 'timeout',
        cause: e,
      );
    } catch (e) {
      throw PaymentServiceException(
        'Unexpected error while starting payment.',
        code: 'unknown_error',
        cause: e,
      );
    }
  }

  /// Starts a native EVO refund flow for a previously captured transaction.
  Future<Map<String, dynamic>> startRefund({
    required int amount,
    required String originalTransactionId,
    String title = '',
  }) async {
    if (amount <= 0) {
      throw const PaymentServiceException(
        'Refund amount must be greater than zero.',
        code: 'invalid_amount',
      );
    }
    if (originalTransactionId.trim().isEmpty) {
      throw const PaymentServiceException(
        'Original transaction ID is required for refund.',
        code: 'invalid_original_transaction',
      );
    }

    final payload = <String, dynamic>{
      'amount': amount,
      'title': title,
      'originalTransactionId': originalTransactionId,
    };

    try {
      final rawResult = await _channel
          .invokeMethod<dynamic>('startRefund', payload)
          .timeout(const Duration(seconds: 45));
      if (rawResult == null) {
        throw const PaymentServiceException(
          'Native refund returned no result.',
          code: 'empty_result',
        );
      }
      if (rawResult is! Map) {
        throw PaymentServiceException(
          'Unexpected native refund result type: ${rawResult.runtimeType}.',
          code: 'invalid_result_type',
        );
      }
      final result = rawResult.map((key, value) => MapEntry(key.toString(), value));
      await saveTransactionFromEvoResult(
        result,
        amountMajor: amount / 100.0,
        isRefund: true,
        originalTransactionId: originalTransactionId,
      );
      return result;
    } on PlatformException catch (e) {
      if (e.code == 'IOS_PAYMENT_NOT_SUPPORTED') {
        throw PaymentServiceException(
          e.message ?? 'Refunds are not available on this device.',
          code: 'ios_payment_not_supported',
          cause: e,
        );
      }
      throw PaymentServiceException(
        e.message ?? 'Native refund call failed.',
        code: e.code,
        cause: e,
      );
    } on MissingPluginException catch (e) {
      throw PaymentServiceException(
        Platform.isIOS
            ? 'Refunds are not available on iOS yet.'
            : 'Refund channel is not implemented on this platform.',
        code: 'missing_plugin',
        cause: e,
      );
    } on TimeoutException catch (e) {
      throw PaymentServiceException(
        'Refund request timed out.',
        code: 'timeout',
        cause: e,
      );
    } catch (e) {
      throw PaymentServiceException(
        'Unexpected error while starting refund.',
        code: 'unknown_error',
        cause: e,
      );
    }
  }
}
