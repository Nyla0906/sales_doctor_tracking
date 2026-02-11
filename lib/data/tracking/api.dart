import 'package:dio/dio.dart';

class TrackingApi {
  final Dio dio;
  TrackingApi(this.dio);

  Future<Map<String, dynamic>> startSession() async {
    final r = await dio.post('/api/v1/tracking/sessions/start');
    return (r.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> stopSession({
    required String sessionId,
    required DateTime stopTime,
    required double stopLat,
    required double stopLon,
  }) async {
    final r = await dio.post(
      '/api/v1/tracking/sessions/$sessionId/stop',
      data: {
        'stopTime': stopTime.toUtc().toIso8601String(),
        'stopLat': stopLat,
        'stopLon': stopLon,
      },
    );
    return (r.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> ingestPoints(
      String sessionId,
      List<Map<String, dynamic>> points,
      ) async {
    final r = await dio.post(
      '/api/v1/tracking/sessions/$sessionId/points',
      data: {'points': points},
    );
    return (r.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> mySessions() async {
    final r = await dio.get('/api/v1/tracking/sessions');
    return (r.data as Map<String, dynamic>)['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> mySessionPoints(
      String sessionId, {
        DateTime? from,
        DateTime? to,
        int? max,
        bool downsample = true,
        double? simplifyEpsM,
      }) async {
    final qp = <String, dynamic>{
      if (from != null) 'from': from.toUtc().toIso8601String(),
      if (to != null) 'to': to.toUtc().toIso8601String(),
      if (max != null) 'max': max,
      'downsample': downsample,
      if (simplifyEpsM != null) 'simplifyEpsM': simplifyEpsM,
    };

    final r = await dio.get(
      '/api/v1/tracking/sessions/$sessionId/points',
      queryParameters: qp,
    );
    return (r.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
  }
}
