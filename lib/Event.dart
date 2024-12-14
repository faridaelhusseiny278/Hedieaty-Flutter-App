class Event {
  int? id;
  final String name;
  final String category;
  final DateTime date;
  final String status;
  final String location;
  final String? description;

  Event({
    this.id,
    required this.name,
    required this.status,
    required this.category,
    required this.date,
    required this.location,
    this.description,
  });

  // Factory constructor to create an Event object from a Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['eventId'],
      name: map['eventName'],
      status: map['Status'],
      description: map['description'] ?? '',
      category: map['category'],
      date: DateTime.parse(map['eventDate']),
      location: map['eventLocation'],
    );
  }

  // Method to convert an Event object into a Map (JSON representation)
  Map<String, dynamic> toJson() {
    return {
      'eventId': id,
      'eventName': name,
      'category': category,
      'eventDate': date.toIso8601String(), // Convert DateTime to ISO 8601 format
      'Status': status,
      'eventLocation': location,
      'description': description ?? '', // Use an empty string if null
    };
  }
}
