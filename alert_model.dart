class AlertItem {
  final String id;
  final String timestamp;
  final String type; // "Fall", "Panic", "Inactivity"
  final String status; // "Warning", "Confirmed", "Resolved"

  AlertItem({
    required this.id,
    required this.timestamp,
    required this.type,
    required this.status,
  });

  // Converts backend JSON database data into a Dart object
  factory AlertItem.fromJson(Map<String, dynamic> json) {
    return AlertItem(
      id: json['id'].toString(),
      timestamp: json['timestamp'] ?? '',
      type: json['type'] ?? 'Unknown',
      status: json['status'] ?? 'Unknown',
    );
  }
}
