class Activity {
  final int id;
  final String activity;
  final String type;
  final int participants;
  final double price;

  Activity({
    required this.id,
    required this.activity,
    required this.type,
    required this.participants,
    required this.price,
  });

  factory Activity.fromJson(Map<String, dynamic> json, int id) {
    return Activity(
      id: id,
      activity: json['activity'],
      type: json['type'],
      participants: json['participants'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'activity': activity,
      'type': type,
      'participants': participants,
      'price': price,
    };
  }
}