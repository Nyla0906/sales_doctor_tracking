class TrackingSession {
  final String sessionId;
  final DateTime startTime;
  final DateTime? stopTime;
  final String status;
  final DateTime? lastPointAt;

  TrackingSession({
    required this.sessionId,
    required this.startTime,
    required this.stopTime,
    required this.status,
    required this.lastPointAt,
  });

  factory TrackingSession.fromJson(Map<String, dynamic> j) {
    DateTime? dt(String? s) => s == null ? null : DateTime.parse(s);

    return TrackingSession(
      sessionId: j['sessionId'] as String,
      startTime: DateTime.parse(j['startTime'] as String),
      stopTime: dt(j['stopTime'] as String?),
      status: (j['status'] ?? '') as String,
      lastPointAt: dt(j['lastPointAt'] as String?),
    );
  }
}
