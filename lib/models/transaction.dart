class Transaction {
  String? userId;
  String? transactionId;
  double? amount;
  String? status;
  DateTime? createdAt;

  Transaction({this.userId, this.transactionId, this.amount, this.status, this.createdAt});

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      userId: json['user'],
      transactionId: json['transaction_id'],
      amount: (json['amount'] as num?)?.toDouble(),
      status: json['status'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    );
  }
}
