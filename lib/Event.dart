class Event {
   int? id;
  final String name;
  final String category;
  final DateTime date;
  final String status;
  final String location;
  final String description;

  Event({
     this.id,
    required this.name,
    required this.status,
    required this.category,
    required this.date,
    required this.location,
    required this.description,
  });
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['ID'],
      name: map['name'],
      status: map['status'],
      description: map['description'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      location: map['location']
    );
  }
}
