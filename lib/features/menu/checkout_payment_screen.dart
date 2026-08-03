import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/di/injection.dart';
import '../../core/database/local_storage.dart';
import '../../screens/payment_flow_helpers.dart';
import '../../screens/payment_navigation.dart';
import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';
import '../../screens/card_payment_screen.dart';
import '../../screens/split_payment_flow.dart';
import '../../screens/tip_screen.dart';
import '../../shared/widgets/pax_pos_app_bar.dart';
import '../../shared/widgets/pos_keypay_panel.dart';
import '../../core/services/payment_service.dart';
import 'data/dummy_payments_data.dart';
import 'models/payment_transaction.dart';
import 'terminal_menu_screen.dart';
import 'transaction_detail_screen.dart';

enum CheckoutPaymentMethod {
  cardTap,
  cardChipPin,
  mobileWallet,
  paymentLink,
  cash,
}

enum _BillFlowStep {
  amount,
  cardPresent,
  splitChoice,
  equalSplit,
  customSplit,
  tip,
  summary,
}

enum _SplitMode { full, equal, custom }

class CheckoutPaymentScreen extends StatefulWidget {
  static const routeName = 'checkout_payment';

  final CheckoutPaymentMethod? initialMethod;

  const CheckoutPaymentScreen({super.key, this.initialMethod});

  static MaterialPageRoute<void> materialRoute({
    CheckoutPaymentMethod? initialMethod,
  }) {
    return MaterialPageRoute<void>(
      settings: const RouteSettings(name: routeName),
      builder: (_) => CheckoutPaymentScreen(initialMethod: initialMethod),
    );
  }

  @override
  State<CheckoutPaymentScreen> createState() => _CheckoutPaymentScreenState();
}

class _CheckoutPaymentScreenState extends State<CheckoutPaymentScreen> {
  final _money = NumberFormat.currency(locale: 'en_GB', symbol: '£');
  final _paymentService = PaymentService();
  final _customTipCtrl = TextEditingController();
  final _customSplitCtrls = <TextEditingController>[];
  final _transactions = <PaymentTransaction>[];

  CheckoutPaymentMethod _method = CheckoutPaymentMethod.cardTap;
  _BillFlowStep _step = _BillFlowStep.amount;

  double _billAmount = 0;

  /// Minor units entered on the handheld keypay (e.g. "1569" → £15.69).
  String _amountKeypadRaw = '';
  _SplitMode _splitMode = _SplitMode.full;
  int _splitCount = 2;
  List<double> _basePayments = <double>[];
  int _currentPaymentIndex = 0;
  bool _isProcessing = false;
  double _selectedTip = 0;


  double totalAmount=0.0;

  final bool completeWithPopResult=false;

  @override
  void initState() {
    super.initState();
    _method = widget.initialMethod ?? CheckoutPaymentMethod.cardTap;
    if (!sl<LocalStorage>().cashEnabled &&
        _method == CheckoutPaymentMethod.cash) {
      _method = CheckoutPaymentMethod.cardTap;
    }
  }

  List<CheckoutPaymentMethod> _paymentMethodsForUi() {
    final cashOn = sl<LocalStorage>().cashEnabled;
    return CheckoutPaymentMethod.values.where((m) {
      if (m == CheckoutPaymentMethod.cash) return cashOn;
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _customTipCtrl.dispose();
    for (final c in _customSplitCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAmount = _step == _BillFlowStep.amount;
    final isCardPresent = _step == _BillFlowStep.cardPresent;
    return Scaffold(
      backgroundColor: isAmount || isCardPresent
          ? PaxPaymentColors.white
          : PaxPaymentColors.adminBackground,
      appBar: isCardPresent ? null : _buildCheckoutAppBar(context),
      body: Stack(
        children: [
          if (isAmount)
            _buildAmountStepLayout(context)
          else if (isCardPresent)
            _buildCardPresentStep(context)
          else
            ListView(
              padding: const EdgeInsets.all(PaxPaymentSpacing.sp16),
              children: [_buildFlowBody(context)],
            ),
          if (_isProcessing)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.22),
              child: Center(
                child: _ProcessingCard(
                  isCash: _method == CheckoutPaymentMethod.cash,
                ),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildCheckoutAppBar(BuildContext context) {
    final isAmount = _step == _BillFlowStep.amount;
    return PaxPosAppBar(
      onGoBack: isAmount
          ? () => Navigator.of(context).maybePop()
          : null,
      onMenu: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const TerminalMenuScreen(),
          ),
        );
      },
      trailing: [
        if (isAmount)
          PopupMenuButton<CheckoutPaymentMethod>(
            tooltip: 'Payment method',
            icon: Icon(
              Icons.payments_outlined,
              color: PaxPaymentColors.darkGrayText.withValues(alpha: 0.85),
            ),
            onSelected: (m) => setState(() => _method = m),
            itemBuilder: (ctx) => _paymentMethodsForUi()
                .map(
                  (m) => PopupMenuItem(value: m, child: Text(_methodLabel(m))),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildFlowBody(BuildContext context) {
    return switch (_step) {
      _BillFlowStep.amount => const SizedBox.shrink(),
      _BillFlowStep.cardPresent => const SizedBox.shrink(),
      _BillFlowStep.splitChoice => _splitChoiceStep(context),
      _BillFlowStep.equalSplit => _equalSplitStep(context),
      _BillFlowStep.customSplit => _customSplitStep(context),
      _BillFlowStep.tip => _tipStep(context),
      _BillFlowStep.summary => _summaryStep(context),
    };
  }

  String get _keypayDisplayPounds {
    if (_amountKeypadRaw.isEmpty) return '0.00';
    final padded = _amountKeypadRaw.padLeft(3, '0');
    final cents = padded.substring(padded.length - 2);
    final pounds = padded.substring(0, padded.length - 2);
    return '$pounds.$cents';
  }

  double get _keypayAmount =>
      _amountKeypadRaw.isEmpty ? 0.0 : int.parse(_amountKeypadRaw) / 100;

  Widget _buildAmountStepLayout(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final amountStyle = Theme.of(context).textTheme.displayMedium?.copyWith(
      color: PaxPaymentColors.darkGrayText,
      fontWeight: FontWeight.w600,
    );
    final cursorH = (amountStyle?.fontSize ?? 40) * 1.05;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('£', style: amountStyle),
                Text(_keypayDisplayPounds, style: amountStyle),
                const SizedBox(width: 3),
                _KeypayCursor(height: cursorH),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: PaxPaymentSpacing.sp16),
          child: TextButton(
            onPressed: _onSplitBillPressed,
            child: Text(
              'Split bill',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: PaxPaymentColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              PaxPaymentSpacing.sp16,
              0,
              PaxPaymentSpacing.sp16,
              PaxPaymentSpacing.sp12 + bottom,
            ),
            child: PosKeypayPanel(
              onDigit: _onAmountDigit,
              onDelete: _onAmountDelete,
              onClear: _onAmountClear,
              showCalculatorOperators: false,
              showClearKey: false,
              footer: Material(
                color: PaxPaymentColors.posKeypayAccent,
                child: InkWell(
                  onTap: _onChargePressed,
                  child: SizedBox(
                    height: 52,
                    child: Center(
                      child: Text(
                        'Charge',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: PaxPaymentColors.onPosKeypayAccent,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardPresentStep(BuildContext context) {
    final pad = MediaQuery.paddingOf(context);
    final amountStyle = Theme.of(context).textTheme.displayMedium?.copyWith(
      color: PaxPaymentColors.darkGrayText,
      fontWeight: FontWeight.w700,
    );

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              PaxPaymentSpacing.sp16,
              PaxPaymentSpacing.sp8,
              PaxPaymentSpacing.sp16,
              PaxPaymentSpacing.sp12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final active = i == 0;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: PaxPaymentSpacing.sp6,
                  ),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? PaxPaymentColors.textGreen
                          : Colors.transparent,
                      border: Border.all(
                        color: active
                            ? PaxPaymentColors.textGreen
                            : PaxPaymentColors.mediumGray.withValues(
                                alpha: 0.45,
                              ),
                        width: 1.5,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: PaxPaymentSpacing.sp16,
            ),
            child: Row(
              children: [
                PaxPosBackButton(
                  onPressed: () => setState(() => _step = _BillFlowStep.amount),
                ),
                const Spacer(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'English',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: PaxPaymentColors.darkGrayText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: PaxPaymentSpacing.sp8),
                    const Text('🇬🇧', style: TextStyle(fontSize: 22)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: PaxPaymentSpacing.sp24,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: _advanceFromCardPresent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.contactless_rounded,
                          size: 72,
                          color: PaxPaymentColors.primaryBlue,
                        ),
                        const SizedBox(height: PaxPaymentSpacing.sp24),
                        Text(
                          _money.format(_to2(_billAmount)),
                          style: amountStyle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: PaxPaymentSpacing.sp16),
                        Text(
                          'Tap, insert, or swipe',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: PaxPaymentColors.mediumGray,
                                fontWeight: FontWeight.w400,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: pad.bottom),
        ],
      ),
    );
  }

  void _advanceFromCardPresent() {
    setState(() => _step = _BillFlowStep.splitChoice);
  }

  void _onAmountDigit(String d) {
    final addLen = d.length;
    if (_amountKeypadRaw.length + addLen > 8) return;
    HapticFeedback.selectionClick();
    setState(() => _amountKeypadRaw += d);
  }

  void _onAmountDelete() {
    if (_amountKeypadRaw.isEmpty) return;
    setState(() {
      _amountKeypadRaw = _amountKeypadRaw.substring(
        0,
        _amountKeypadRaw.length - 1,
      );
    });
  }

  void _onAmountClear() {
    setState(() => _amountKeypadRaw = '');
  }

  void _onSplitBillPressed() {
    final parsed = _keypayAmount;
    if (parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _billAmount = _to2(parsed);
      _step = _BillFlowStep.splitChoice;
    });
  }

  Future<void> _launchSplitTeyaFlow() async {
    if (_basePayments.isEmpty) return;
    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => SplitPaymentFlowScreen(amounts: _basePayments),
      ),
    );
    if (!mounted) return;
    if (ok == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All split payments completed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    _restartFlow();
  }

  Future<void> _onChargePressed() async {
    final parsed = _keypayAmount;
    if (parsed <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (sl<LocalStorage>().tipsEnabled) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => TipScreen(baseAmount: parsed),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => CardPaymentScreen(totalAmount: parsed),
        ),
      );
    }
  }
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  String generateTransactionId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final r = Random.secure();
    return 'TXN-${List.generate(8, (_) => chars[r.nextInt(chars.length)]).join()}';
  }
  Future<void> _startCardPayment() async {
    setState(() => _isProcessing = true);

    try {
      final result = await _paymentService.startPayment(
        amount: (totalAmount * 100).round(),
        title: 'Payment',
        paymentMethod: 'card',
      );

      if (!mounted) return;

      final status = parsePaymentStatus(result);
      if (status == null) {
        _showMessage('Payment cancelled');
        return;
      }

      final nativeId = result['transactionId']?.toString().trim();
      final transactionId = (nativeId != null && nativeId.isNotEmpty)
          ? nativeId
          : generateTransactionId();
      final last4 = extractCardLast4(result['cardNumber']);
      final cardType = parseCardType(result);
      final evoRef = nativeId?.isNotEmpty == true ? nativeId : null;

      if (status == PaymentStatus.success) {
        await saveCardTransaction(
          amount: totalAmount,
          status: PaymentStatus.success,
          transactionId: transactionId,
          cardLast4: last4,
          cardType: cardType,
          evoTransactionRef: evoRef,
        );
        if (!mounted) return;
        navigateToPaymentSuccess(
          context,
          amount: totalAmount,
          cardLast4: last4,
          cardType: cardType,
          transactionId: transactionId,
          popWithResult: completeWithPopResult,
        );
      } else {
        await saveCardTransaction(
          amount: totalAmount,
          status: PaymentStatus.failed,
          transactionId: transactionId,
          cardLast4: last4,
          cardType: cardType,
          evoTransactionRef: evoRef,
        );
        if (!mounted) return;
        navigateToPaymentDeclined(
          context,
          amount: totalAmount,
          declineReason: parseDeclineReason(result),
          popWithResult: completeWithPopResult,
        );
      }
    } on PaymentServiceException catch (e) {
      if (!mounted) return;
      _showMessage(e.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Payment could not be processed');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
  Widget _splitChoiceStep(BuildContext context) {
    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _money.format(_billAmount),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: PaxPaymentColors.darkGrayText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp16),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _splitMode = _SplitMode.full;
                _basePayments = [_to2(_billAmount)];
                _currentPaymentIndex = 0;
                _selectedTip = 0;
                _transactions.clear();
              });
              _launchSplitTeyaFlow();
            },
            child: const Text('Pay in full'),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          OutlinedButton(
            onPressed: () => setState(() {
              _splitMode = _SplitMode.equal;
              _step = _BillFlowStep.equalSplit;
            }),
            child: const Text('Equal split'),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          OutlinedButton(
            onPressed: _openCustomSplit,
            child: const Text('Custom split'),
          ),
        ],
      ),
    );
  }

  Widget _equalSplitStep(BuildContext context) {
    final per = _splitCount <= 0 ? 0.0 : _billAmount / _splitCount;
    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '$_splitCount payments of',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: PaxPaymentColors.mediumGray,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp6),
          Text(
            _money.format(_to2(per)),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: PaxPaymentColors.darkGrayText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp18),
          Text(
            'Number of payments',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: PaxPaymentColors.darkGrayText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.outlined(
                onPressed: _splitCount > 2
                    ? () => setState(() => _splitCount--)
                    : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              const SizedBox(width: PaxPaymentSpacing.sp12),
              Text(
                '$_splitCount',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: PaxPaymentColors.darkGrayText,
                ),
              ),
              const SizedBox(width: PaxPaymentSpacing.sp12),
              IconButton.outlined(
                onPressed: _splitCount < 10
                    ? () => setState(() => _splitCount++)
                    : null,
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: PaxPaymentSpacing.sp18),
          FilledButton(
            onPressed: _confirmEqualSplit,
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _confirmEqualSplit() {
    final totalPennies = (_billAmount * 100).round();
    final basePennies = totalPennies ~/ _splitCount;
    var remainder = totalPennies % _splitCount;
    final out = <double>[];
    for (var i = 0; i < _splitCount; i++) {
      var p = basePennies;
      if (remainder > 0) {
        p++;
        remainder--;
      }
      out.add(p / 100);
    }

    setState(() {
      _basePayments = out;
      _transactions.clear();
      _currentPaymentIndex = 0;
      _selectedTip = 0;
    });
    _launchSplitTeyaFlow();
  }

  void _openCustomSplit() {
    for (final c in _customSplitCtrls) {
      c.dispose();
    }
    _customSplitCtrls
      ..clear()
      ..addAll([
        TextEditingController(text: _to2(_billAmount / 2).toStringAsFixed(2)),
        TextEditingController(text: _to2(_billAmount / 2).toStringAsFixed(2)),
      ]);
    setState(() {
      _splitMode = _SplitMode.custom;
      _step = _BillFlowStep.customSplit;
    });
  }

  Widget _customSplitStep(BuildContext context) {
    final sum = _customSplitCtrls.fold<double>(
      0,
      (s, c) => s + (double.tryParse(c.text.trim()) ?? 0),
    );
    final difference = _to2(_billAmount - sum);
    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bill ${_money.format(_billAmount)}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: PaxPaymentColors.darkGrayText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp12),
          ...List.generate(_customSplitCtrls.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: PaxPaymentSpacing.sp10),
              child: TextField(
                controller: _customSplitCtrls[index],
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Payment ${index + 1}',
                  prefixText: '£ ',
                ),
              ),
            );
          }),
          Row(
            children: [
              TextButton.icon(
                onPressed: _customSplitCtrls.length < 8 ? _addSplitRow : null,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add'),
              ),
              const SizedBox(width: PaxPaymentSpacing.sp8),
              TextButton.icon(
                onPressed: _customSplitCtrls.length > 2
                    ? _removeSplitRow
                    : null,
                icon: const Icon(Icons.remove_rounded),
                label: const Text('Remove'),
              ),
            ],
          ),
          const SizedBox(height: PaxPaymentSpacing.sp8),
          Text(
            difference == 0
                ? 'Total matched'
                : difference > 0
                ? 'Remaining: ${_money.format(difference)}'
                : 'Over by: ${_money.format(-difference)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: difference == 0
                  ? PaxPaymentColors.textGreen
                  : PaxPaymentColors.errorRed,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp14),
          FilledButton(
            onPressed: _confirmCustomSplit,
            child: const Text('Confirm split'),
          ),
        ],
      ),
    );
  }

  void _addSplitRow() {
    setState(() {
      _customSplitCtrls.add(TextEditingController(text: '0.00'));
    });
  }

  void _removeSplitRow() {
    if (_customSplitCtrls.length <= 2) return;
    final last = _customSplitCtrls.removeLast();
    last.dispose();
    setState(() {});
  }

  void _confirmCustomSplit() {
    final values = _customSplitCtrls
        .map((c) => double.tryParse(c.text.trim()) ?? -1)
        .toList(growable: false);
    if (values.any((v) => v <= 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Each custom amount must be greater than zero'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final sum = values.fold<double>(0, (a, b) => a + b);
    if ((_to2(sum) - _to2(_billAmount)).abs() > 0.009) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Custom split must total ${_money.format(_billAmount)}',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _basePayments = values.map(_to2).toList(growable: false);
      _transactions.clear();
      _currentPaymentIndex = 0;
      _selectedTip = 0;
    });
    _launchSplitTeyaFlow();
  }

  Widget _tipStep(BuildContext context) {
    final baseAmount = _basePayments[_currentPaymentIndex];
    final tip10 = _to2(baseAmount * 0.10);
    final tip125 = _to2(baseAmount * 0.125);
    final tip15 = _to2(baseAmount * 0.15);
    final totalWithTip = _to2(baseAmount + _selectedTip);
    final tipsOn = sl<LocalStorage>().tipsEnabled;

    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _money.format(baseAmount),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: PaxPaymentColors.darkGrayText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp8),
          if (tipsOn) ...[
            Text(
              'Would you like to add a tip?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: PaxPaymentColors.darkGrayText,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: PaxPaymentSpacing.sp12),
            OutlinedButton(
              onPressed: () => setState(() => _selectedTip = tip10),
              child: Text('10% (${_money.format(tip10)})'),
            ),
            const SizedBox(height: PaxPaymentSpacing.sp8),
            OutlinedButton(
              onPressed: () => setState(() => _selectedTip = tip125),
              child: Text('12.5% (${_money.format(tip125)})'),
            ),
            const SizedBox(height: PaxPaymentSpacing.sp8),
            OutlinedButton(
              onPressed: () => setState(() => _selectedTip = tip15),
              child: Text('15% (${_money.format(tip15)})'),
            ),
            const SizedBox(height: PaxPaymentSpacing.sp8),
            OutlinedButton(
              onPressed: _showCustomTipDialog,
              child: const Text('Custom amount'),
            ),
            const SizedBox(height: PaxPaymentSpacing.sp8),
            OutlinedButton(
              onPressed: () => setState(() => _selectedTip = 0),
              child: const Text('No thanks'),
            ),
            const SizedBox(height: PaxPaymentSpacing.sp14),
          ] else ...[
            Text(
              'Tips are turned off in Payment settings.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PaxPaymentColors.mediumGray,
              ),
            ),
            const SizedBox(height: PaxPaymentSpacing.sp14),
          ],
          Container(
            padding: const EdgeInsets.all(PaxPaymentSpacing.sp10),
            decoration: BoxDecoration(
              color: PaxPaymentColors.lightGray,
              borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusMd),
            ),
            child: Text(
              'To charge: ${_money.format(totalWithTip)}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: PaxPaymentColors.darkGrayText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp14),
          FilledButton(
            onPressed: _processCurrentPayment,
            child: Text('Take payment ${_currentPaymentIndex + 1}'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCustomTipDialog() async {
    _customTipCtrl.text = _selectedTip.toStringAsFixed(2);
    final value = await showDialog<double>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Custom tip'),
          content: TextField(
            controller: _customTipCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              prefixText: '£ ',
              hintText: '0.00',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final tip = double.tryParse(_customTipCtrl.text.trim());
                if (tip == null || tip < 0) {
                  return;
                }
                Navigator.pop(ctx, _to2(tip));
              },
              child: const Text('Set tip'),
            ),
          ],
        );
      },
    );
    if (value != null) {
      setState(() => _selectedTip = value);
    }
  }

  Future<void> _processCurrentPayment() async {
    if (_isProcessing) return;
    final base = _basePayments[_currentPaymentIndex];
    final chargeAmount = _to2(base + _selectedTip);
    final storeTag = sl<LocalStorage>().currentStore;
    final paymentMethod = _method == CheckoutPaymentMethod.cash
        ? 'cash'
        : 'card';

    setState(() => _isProcessing = true);
    PaymentTransaction? tx;
    var shouldAdvance = false;
    try {
      final result = await _paymentService.startPayment(
        amount: (chargeAmount * 100).round(),
        title: 'Payment ${_currentPaymentIndex + 1}',
        paymentMethod: paymentMethod,
      );

      final statusValue = (result['status'] ?? '').toString().toLowerCase();
      final status = switch (statusValue) {
        'success' ||
        'approved' ||
        'ok' ||
        'completed' ||
        'true' => PaymentStatus.success,
        'cancelled' => null,
        _ => PaymentStatus.failed,
      };

      if (status == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment cancelled'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final nativeId = result['transactionId']?.toString().trim();
        // TODO(EVO): Confirm native `transactionId` mapping if EVO returns multiple reference fields.
        final synthId =
            'TXN-${DateTime.now().millisecondsSinceEpoch}-${_currentPaymentIndex + 1}';
        final id = (nativeId != null && nativeId.isNotEmpty)
            ? nativeId
            : synthId;
        final last4 = _extractLast4(result['cardNumber']);
        final evoRef = nativeId?.isNotEmpty == true ? nativeId : null;

        tx = PaymentTransaction(
          id: id,
          amount: chargeAmount,
          status: status,
          time: DateTime.now(),
          customerName: _basePayments.length > 1
              ? 'Split #${_currentPaymentIndex + 1}'
              : 'Walk-in Customer',
          cardType: _methodLabel(_method),
          refundSupported:
              status == PaymentStatus.success && _supportsRefund(_method),
          cardLast4: last4,
          evoTransactionRef: evoRef,
          storeTag: storeTag,
        );
        await DummyPaymentsData.addTransaction(tx);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == PaymentStatus.success
                  ? 'Payment successful'
                  : 'Payment failed',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
        shouldAdvance = status == PaymentStatus.success;
      }
    } on PaymentServiceException catch (e) {
      if (!mounted) return;
      if (e.code == 'ios_payment_not_supported' || e.code == 'missing_plugin') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message.isNotEmpty
                  ? e.message
                  : 'Card payments are not available on this device.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        final cancelled = e.code == 'PAYMENT_CANCELLED';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cancelled ? 'Payment cancelled' : 'Payment failed'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment failed'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      if (tx != null) {
        _transactions.add(tx);
      }
      _selectedTip = 0;
      if (shouldAdvance && _currentPaymentIndex < _basePayments.length - 1) {
        _currentPaymentIndex++;
      } else if (shouldAdvance) {
        _step = _BillFlowStep.summary;
      }
    });
  }

  Widget _summaryStep(BuildContext context) {
    final totalCharged = _transactions.fold<double>(0, (s, t) => s + t.amount);
    final successCount = _transactions
        .where((t) => t.status == PaymentStatus.success)
        .length;
    final allSuccess = successCount == _transactions.length;
    final latest = _transactions.isEmpty ? null : _transactions.last;

    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            allSuccess
                ? Icons.check_circle_rounded
                : Icons.warning_amber_rounded,
            size: 42,
            color: allSuccess
                ? PaxPaymentColors.textGreen
                : PaxPaymentColors.errorRed,
          ),
          const SizedBox(height: PaxPaymentSpacing.sp8),
          Text(
            allSuccess ? 'All payments completed' : 'Some payments failed',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: PaxPaymentColors.darkGrayText,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp12),
          Text(
            'Original bill: ${_money.format(_billAmount)}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: PaxPaymentColors.mediumGray,
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp2),
          Text(
            'Mode: ${_splitModeLabel(_splitMode)}',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: PaxPaymentColors.mediumGray),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp4),
          Text(
            'Charged total: ${_money.format(_to2(totalCharged))}',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: PaxPaymentColors.darkGrayText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp4),
          Text(
            'Payments: $successCount/${_transactions.length} successful',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: PaxPaymentColors.mediumGray),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp16),
          if (latest != null)
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        TransactionDetailScreen(transaction: latest),
                  ),
                );
              },
              child: const Text('View latest transaction'),
            ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          OutlinedButton(
            onPressed: _restartFlow,
            child: const Text('New sale'),
          ),
        ],
      ),
    );
  }

  void _restartFlow() {
    for (final c in _customSplitCtrls) {
      c.dispose();
    }
    _customSplitCtrls.clear();
    setState(() {
      _step = _BillFlowStep.amount;
      _billAmount = 0;
      _splitMode = _SplitMode.full;
      _splitCount = 2;
      _basePayments = <double>[];
      _currentPaymentIndex = 0;
      _selectedTip = 0;
      _transactions.clear();
      _amountKeypadRaw = '';
    });
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(PaxPaymentSpacing.sp16),
      decoration: BoxDecoration(
        color: PaxPaymentColors.white,
        borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusXl),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }

  double _to2(double value) => double.parse(value.toStringAsFixed(2));

  static String? _extractLast4(Object? raw) {
    final digits = raw?.toString().replaceAll(RegExp(r'\D'), '') ?? '';
    if (digits.length >= 4) {
      return digits.substring(digits.length - 4);
    }
    return null;
  }

  static String _methodLabel(CheckoutPaymentMethod method) {
    return switch (method) {
      CheckoutPaymentMethod.cardTap => 'Card tap',
      CheckoutPaymentMethod.cardChipPin => 'Card chip + PIN',
      CheckoutPaymentMethod.mobileWallet => 'Mobile wallet',
      CheckoutPaymentMethod.paymentLink => 'Payment link',
      CheckoutPaymentMethod.cash => 'Cash',
    };
  }

  static bool _supportsRefund(CheckoutPaymentMethod method) {
    return method == CheckoutPaymentMethod.cardTap ||
        method == CheckoutPaymentMethod.cardChipPin;
  }

  static String _splitModeLabel(_SplitMode mode) {
    return switch (mode) {
      _SplitMode.full => 'Pay in full',
      _SplitMode.equal => 'Equal split',
      _SplitMode.custom => 'Custom split',
    };
  }
}

class _KeypayCursor extends StatefulWidget {
  const _KeypayCursor({required this.height});

  final double height;

  @override
  State<_KeypayCursor> createState() => _KeypayCursorState();
}

class _KeypayCursorState extends State<_KeypayCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 530),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(opacity: _controller.value > 0.45 ? 1 : 0, child: child);
      },
      child: Container(
        width: 2.5,
        height: widget.height,
        decoration: BoxDecoration(
          color: PaxPaymentColors.posKeypayAccent,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

class _ProcessingCard extends StatelessWidget {
  const _ProcessingCard({this.isCash = false});

  final bool isCash;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(PaxPaymentSpacing.sp18),
      decoration: BoxDecoration(
        color: PaxPaymentColors.white,
        borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusLg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: PaxPaymentSpacing.sp12),
          Text(
            isCash
                ? 'Recording cash payment...'
                : 'Present card and authorize...',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: PaxPaymentColors.darkGrayText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
