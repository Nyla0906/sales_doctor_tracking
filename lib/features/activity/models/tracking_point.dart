class TrackingPoint {
  final String eventId;
  final double lat;
  final double lon;
  final DateTime deviceTimestamp;
  final double accuracyM;
  final double speedMps;
  final double headingDeg;
  final String provider;
  final bool mock;

  TrackingPoint({
    required this.eventId,
    required this.lat,
    required this.lon,
    required this.deviceTimestamp,
    required this.accuracyM,
    required this.speedMps,
    required this.headingDeg,
    required this.provider,
    required this.mock,
  });

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'lat': lat,
    'lon': lon,
    'deviceTimestamp': deviceTimestamp.toUtc().toIso8601String(),
    'accuracyM': accuracyM,
    "speedMps": speedMps,
    'headingDeg': headingDeg,
    'provider': provider,
    'mock': mock,
  };
}
