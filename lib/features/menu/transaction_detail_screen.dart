import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/security/manager_pin_gate.dart';
import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';
import '../../core/services/payment_service.dart';
import 'data/dummy_payments_data.dart';
import 'models/payment_transaction.dart';

/// Full payment detail + practical actions.
class TransactionDetailScreen extends StatefulWidget {
  final PaymentTransaction transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionDetailScreen> createState() => _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  static final _money = NumberFormat.currency(locale: 'en_GB', symbol: '£');
  static final _full = DateFormat('dd/MM/yyyy HH:mm', 'en_GB');
  final _paymentService = PaymentService();
  bool _isRefunding = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.transaction;
    final canRefund = !t.isRefund &&
        !t.isRefunded &&
        t.refundSupported &&
        t.status == PaymentStatus.success;
    final amountText = _money.format(t.amount.abs());

    return Scaffold(
      backgroundColor: PaxPaymentColors.adminBackground,
      appBar: AppBar(
        title: const Text('Transaction details'),
        backgroundColor: PaxPaymentColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: PaxPaymentColors.darkGrayText,
      ),
      body: ListView(
        padding: const EdgeInsets.all(PaxPaymentSpacing.sp20),
        children: [
          Text(
            amountText,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: PaxPaymentColors.darkGrayText,
                  fontWeight: FontWeight.w500,
                  decoration: t.isRefund || t.amount < 0
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          if (canRefund || t.isRefund || t.amount < 0)
            FilledButton.tonalIcon(
              onPressed: _isRefunding ? null : () => _confirmRefund(context),
              icon: const Icon(Icons.subdirectory_arrow_left_rounded),
              label: Text(_isRefunding ? 'Processing...' : 'Payment void'),
            ),
          const SizedBox(height: PaxPaymentSpacing.sp24),
          Text(
            'TRANSACTION DETAILS',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: PaxPaymentColors.mediumGray,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp12),
          _DetailRow(label: 'Date', value: _full.format(t.time)),
          _DetailRow(
            label: 'Card',
            value: '${t.cardType} ${t.maskedLast4Display}',
          ),
          _DetailRow(
            label: 'Approval code',
            value: t.id.length <= 6 ? t.id : t.id.substring(0, 6),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp18),
          Text(
            'RECEIPT OPTIONS',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: PaxPaymentColors.mediumGray,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline_rounded),
            title: const Text('Customer receipt'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Printing customer receipt for ${t.id}…'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.email_outlined),
            title: const Text('Email receipt'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Email receipt for ${t.id} (demo)'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.storefront_outlined),
            title: const Text('Merchant receipt'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Printing merchant receipt for ${t.id}…'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: PaxPaymentSpacing.sp16),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: const Color(0xFF2E3637),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRefund(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Refund payment?'),
        content: Text(
          'Refund ${_money.format(widget.transaction.amount)} for transaction ${widget.transaction.id}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Refund'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final pinOk = await verifyManagerPin(
      context,
      reason: 'Manager PIN is required to process a refund.',
    );
    if (!pinOk || !mounted) return;
    await _runRefund();
  }

  Future<void> _runRefund() async {
    setState(() => _isRefunding = true);
    try {
      final amountCents = (widget.transaction.amount * 100).round();
      // TODO(EVO): Ensure [refundOriginalId] matches the gateway reference EVO expects (may differ from local row id).
      final originalId = widget.transaction.refundOriginalId;
      final result = await _paymentService.startRefund(
        amount: amountCents,
        originalTransactionId: originalId,
        title: 'Refund $originalId',
      );
      final statusValue = (result['status'] ?? '').toString().toLowerCase();
      final success = statusValue == 'success' ||
          statusValue == 'approved' ||
          statusValue == 'ok' ||
          statusValue == 'completed' ||
          statusValue == 'true';
      if (success) {
        final refund = PaymentTransaction(
          id: (result['transactionId'] ??
                  result['refundTransactionId'] ??
                  'RFND-${DateTime.now().millisecondsSinceEpoch}')
              .toString(),
          amount: -widget.transaction.amount,
          status: PaymentStatus.success,
          time: DateTime.now(),
          customerName: 'Refund for ${widget.transaction.id}',
          cardType: widget.transaction.cardType,
          refundSupported: false,
          isRefund: true,
          originalTransactionId: widget.transaction.id,
        );
        await DummyPaymentsData.addTransaction(refund);
        await DummyPaymentsData.markTransactionRefunded(widget.transaction.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Refund completed'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Refund failed'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on PaymentServiceException catch (e) {
      if (!mounted) return;
      if (e.code == 'ios_payment_not_supported' || e.code == 'missing_plugin') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message.isNotEmpty
                  ? e.message
                  : 'Refund not available on this device.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final cancelled = e.code == 'PAYMENT_CANCELLED';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cancelled ? 'Refund cancelled' : 'Refund failed'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refund failed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRefunding = false);
      }
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PaxPaymentSpacing.sp12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: PaxPaymentColors.darkGrayText,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PaxPaymentColors.darkGrayText,
                ),
          ),
        ],
      ),
    );
  }
}
