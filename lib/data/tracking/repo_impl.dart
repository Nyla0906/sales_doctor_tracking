import '../../features/profile/models/session_points.dart';
import '../../features/profile/models/tracking_session.dart';
import '../../features/activity/models/tracking_point.dart';
import 'api.dart';

class StartSessionRes {
  final String sessionId;
  StartSessionRes(this.sessionId);

  factory StartSessionRes.fromJson(Map<String, dynamic> j) {
    return StartSessionRes(j['sessionId'] as String);
  }
}

class TrackingRepoImpl {
  final TrackingApi api;
  TrackingRepoImpl({required this.api});

  Future<StartSessionRes> startSession() async {
    final data = await api.startSession();
    return StartSessionRes.fromJson(data);
  }

  Future<void> stopSession({
    required String sessionId,
    required DateTime stopTime,
    required double stopLat,
    required double stopLon,
  }) async {
    await api.stopSession(
      sessionId: sessionId,
      stopTime: stopTime,
      stopLat: stopLat,
      stopLon: stopLon,
    );
  }

  Future<void> ingestPoints(String sessionId, List<TrackingPoint> points) async {
    final payload = points.map((p) => p.toJson()).toList();
    await api.ingestPoints(sessionId, payload);
  }

  Future<List<TrackingSession>> mySessions() async {
    final list = await api.mySessions();
    return list
        .map((e) => TrackingSession.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SessionPoint>> mySessionPoints(
      String sessionId, {
        DateTime? from,
        DateTime? to,
        int? max,
        bool downsample = true,
        double? simplifyEpsM,
      }) async {
    final data = await api.mySessionPoints(
      sessionId,
      from: from,
      to: to,
      max: max,
      downsample: downsample,
      simplifyEpsM: simplifyEpsM,
    );

    final points = (data['points'] as List).cast<Map<String, dynamic>>();
    return points.map(SessionPoint.fromJson).toList();
  }
}
