class Subscription {
  String? userId;
  String? transactionId;
  DateTime? startDate;
  DateTime? endDate;

  Subscription({this.userId, this.transactionId, this.startDate, this.endDate});

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      userId: json['user'],
      transactionId: json['transaction'],
      startDate: DateTime.tryParse(json['start_date'] ?? ''),
      endDate: DateTime.tryParse(json['end_date'] ?? ''),
    );
  }
}
