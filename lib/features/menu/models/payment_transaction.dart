enum PaymentStatus { success, failed, refunded }

/// Payment row / detail model used across list, reports and refund flow.
class PaymentTransaction {
  final String id;
  final double amount;
  final PaymentStatus status;
  final String time;
  final String customerName;
  final String cardType;
  final bool refundSupported;
  final bool isRefund;
  final bool isRefunded;
  final String? originalTransactionId;

  /// Last 4 digits of the card when known (from terminal / native).
  final String? cardLast4;

  /// EVO / gateway transaction reference for refunds; null for purely local rows.
  final String? evoTransactionRef;

  /// Store / site tag for multi-store filtering.
  final String storeTag;


  const PaymentTransaction({
    required this.id,
    required this.amount,
    required this.status,
    required this.time,
    required this.customerName,
    required this.cardType,
    required this.refundSupported,
    this.isRefund = false,
    this.isRefunded = false,
    this.originalTransactionId,
    this.cardLast4,
    this.evoTransactionRef,
    this.storeTag = ''
  });

  /// Reference to send to native refund (EVO); falls back to [id].
  String get refundOriginalId =>
      (evoTransactionRef != null && evoTransactionRef!.trim().isNotEmpty)
          ? evoTransactionRef!.trim()
          : id.trim();

  String get maskedLast4Display {
    final d = cardLast4?.trim() ?? '';
    if (d.length >= 4) {
      return '···· ${d.substring(d.length - 4)}';
    }
    return '····';
  }

  bool get isCash => cardType.toLowerCase() == 'cash';

  PaymentTransaction copyWith({
    PaymentStatus? status,
    bool? isRefunded,
    bool? refundSupported,
  }) {
    return PaymentTransaction(
      id: id,
      amount: amount,
      status: status ?? this.status,
      time: time,
      customerName: customerName,
      cardType: cardType,
      refundSupported: refundSupported ?? this.refundSupported,
      isRefund: isRefund,
      isRefunded: isRefunded ?? this.isRefunded,
      originalTransactionId: originalTransactionId,
      cardLast4: cardLast4,
      evoTransactionRef: evoTransactionRef,
      storeTag: storeTag
    );
  }

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    final statusStr = (json['status'] ?? 'failed').toString().toLowerCase();
    final status = switch (statusStr) {
      'success' => PaymentStatus.success,
      'refunded' => PaymentStatus.refunded,
      _ => PaymentStatus.failed,
    };
    return PaymentTransaction(
      id: (json['id'] ?? '').toString(),
      amount: ((json['amount'] as num?) ?? 0).toDouble(),
      status: status,
      time: (json['time'] ?? '').toString(),
      customerName: (json['customerName'] ?? 'Walk-in Customer').toString(),
      cardType: (json['cardType'] ?? 'Card').toString(),
      refundSupported: (json['refundSupported'] as bool?) ?? false,
      isRefund: (json['isRefund'] as bool?) ?? false,
      isRefunded: (json['isRefunded'] as bool?) ?? false,
      originalTransactionId: json['originalTransactionId']?.toString(),
      cardLast4: json['cardLast4']?.toString(),
      evoTransactionRef: json['evoTransactionRef']?.toString(),
      storeTag: (json['storeTag'] ?? '').toString()
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'amount': amount,
      'status': status.name,
      'time': time,
      'customerName': customerName,
      'cardType': cardType,
      'refundSupported': refundSupported,
      'isRefund': isRefund,
      'isRefunded': isRefunded,
      'originalTransactionId': originalTransactionId,
      'cardLast4': cardLast4,
      'evoTransactionRef': evoTransactionRef,
      'storeTag': storeTag,
    };
  }
}
