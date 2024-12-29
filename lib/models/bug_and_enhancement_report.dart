class BugAndEnhancementReport {
  String? userId;
  String? title;
  String? description;
  String? status;
  String? severity;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? feedback;

  BugAndEnhancementReport({this.userId, this.title, this.description, this.status, this.severity, this.createdAt, this.updatedAt, this.feedback});

  factory BugAndEnhancementReport.fromJson(Map<String, dynamic> json) {
    return BugAndEnhancementReport(
      userId: json['user'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      severity: json['severity'],
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? ''),
      feedback: json['feedback'],
    );
  }
}
