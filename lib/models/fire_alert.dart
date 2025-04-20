class FireAlert {
  final String id;
  final String location;
  final String severity;
  final String description;
  final String reporterId;
  final DateTime timestamp;
  final String status;
  final bool verified;

  FireAlert({
    required this.id,
    required this.location,
    required this.severity,
    required this.description,
    required this.reporterId,
    required this.timestamp,
    required this.status,
    required this.verified,
  });

  factory FireAlert.fromJson(Map<String, dynamic> json) {
    return FireAlert(
      id: json['id'] as String,
      location: json['location'] as String,
      severity: json['severity'] as String,
      description: json['description'] as String,
      reporterId: json['reporterId'] as String,
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      status: json['status'] as String,
      verified: json['verified'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location': location,
      'severity': severity,
      'description': description,
      'reporterId': reporterId,
      'timestamp': timestamp,
      'status': status,
      'verified': verified,
    };
  }
}
