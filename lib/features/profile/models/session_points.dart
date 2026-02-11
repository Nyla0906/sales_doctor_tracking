class SessionPoint {
  final DateTime ts;
  final double lat;
  final double lon;
  final double? accuracyM;
  final double? speedMs;
  final double? headingDeg;

  SessionPoint({
    required this.ts,
    required this.lat,
    required this.lon,
    this.accuracyM,
    this.speedMs,
    this.headingDeg,
  });

  factory SessionPoint.fromJson(Map<String, dynamic> j) {
    return SessionPoint(
      ts: DateTime.parse(j['ts'] as String),
      lat: (j['lat'] as num).toDouble(),
      lon: (j['lon'] as num).toDouble(),
      accuracyM: (j['accuracyM'] as num?)?.toDouble(),
      speedMs: (j['speedMs'] as num?)?.toDouble(),
      headingDeg: (j['headingDeg'] as num?)?.toDouble(),
    );
  }
}
