import 'package:sales_doctor_tracking_app/features/profile/models/session_points.dart';
import 'package:sales_doctor_tracking_app/features/profile/models/tracking_session.dart';
import 'package:sales_doctor_tracking_app/features/activity/models/tracking_point.dart';
import 'api.dart';
import 'local /session_dao.dart';
import 'local /session_entity.dart';

class StartSessionRes {
  final String sessionId;
  StartSessionRes(this.sessionId);

  factory StartSessionRes.fromJson(Map<String, dynamic> j) {
    return StartSessionRes(j['sessionId'] as String);
  }
}

class TrackingRepoImpl {
  final TrackingApi api;
  final SessionDao sessionDao;

  TrackingRepoImpl({
    required this.api,
    required this.sessionDao,
  });

  SessionEntity _toEntity(TrackingSession s) {
    return SessionEntity(
      sessionId: s.sessionId,
      startTime: s.startTime.toUtc().toIso8601String(),
      status: s.status,
      stopTime: s.stopTime?.toUtc().toIso8601String(),
    );
  }

  TrackingSession _fromEntity(SessionEntity e) {
    return TrackingSession(
      sessionId: e.sessionId,
      startTime: DateTime.parse(e.startTime),
      stopTime: e.stopTime == null ? null : DateTime.parse(e.stopTime!),
      status: e.status,
      lastPointAt: null, // hozir DBga saqlamayapmiz
    );
  }

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

    // ✅ Stop bo‘ldi degani: DB’da ham statusni yangilab qo‘yamiz
    await sessionDao.markStopped(
      sessionId,
      'STOPPED',
      stopTime.toUtc().toIso8601String(),
    );
  }

  Future<void> ingestPoints(String sessionId, List<TrackingPoint> points) async {
    final payload = points.map((p) => p.toJson()).toList();
    await api.ingestPoints(sessionId, payload);
  }

  Future<List<TrackingSession>> mySessions() async {
    // 1) DB’dan (tez / offline)
    final cached = await sessionDao.getAll();
    final cachedModels = cached.map(_fromEntity).toList();

    try {
      // 2) API’dan
      final list = await api.mySessions();
      final remote = list
          .map((e) => TrackingSession.fromJson(e as Map<String, dynamic>))
          .toList();

      // 3) DB’ni update
      await sessionDao.upsertAll(remote.map(_toEntity).toList());

      return remote;
    } catch (_) {
      return cachedModels;
    }
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
