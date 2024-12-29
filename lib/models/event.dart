class Event {
  String? title;
  String? description;
  DateTime? startDate;
  DateTime? endDate;

  Event({this.title, this.description, this.startDate, this.endDate});

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      title: json['title'],
      description: json['description'],
      startDate: DateTime.tryParse(json['start_date'] ?? ''),
      endDate: DateTime.tryParse(json['end_date'] ?? ''),
    );
  }
}
