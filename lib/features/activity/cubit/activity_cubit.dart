import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';

import '../../../data/tracking/repo_impl.dart';
import '../models/tracking_point.dart';
import 'activity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final TrackingRepoImpl repo;
  ActivityCubit(this.repo) : super(const ActivityState());

  final Distance _dist = const Distance();
  final _uuid = const Uuid();

  StreamSubscription<Position>? _posSub;
  Timer? _flushTimer;
  Timer? _durationTimer;

  final List<TrackingPoint> _buffer = [];

  LatLng? _ema;
  static const double _alpha = 0.20;

  static const double _maxAccuracyM = 25;
  static const double _minMoveM = 5;

  Future<void> start() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        emit(state.copyWith(error: "Location service o‘chiq"));
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        emit(state.copyWith(error: "Location permission berilmagan"));
        return;
      }

      final startRes = await repo.startSession();
      final sessionId = startRes.sessionId;

      _buffer.clear();
      _ema = null;

      emit(const ActivityState(tracking: true).copyWith(sessionId: sessionId));

      _flushTimer?.cancel();
      _flushTimer = Timer.periodic(const Duration(seconds: 10), (_) => _flush());

      _durationTimer?.cancel();
      _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!state.tracking) return;
        emit(state.copyWith(durationSec: state.durationSec + 1));
      });

      final settings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      );

      _posSub?.cancel();
      _posSub = Geolocator.getPositionStream(locationSettings: settings).listen(
        _onPosition,
        onError: (e) => emit(state.copyWith(error: e.toString())),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> stop() async {
    final sessionId = state.sessionId;
    if (sessionId == null) return;

    // ✅ agar allaqachon stop ketayotgan bo‘lsa, qayta bosilganda qaytib ketadi
    if (state.stopping) return;

    try {
      // ✅ UI darhol “tracking off” bo‘ladi, End tugma “qotib” qolmaydi
      emit(state.copyWith(tracking: false, stopping: true, error: null));

      // ✅ streamni darrov to‘xtat (endi nuqta qo‘shilmaydi)
      await _posSub?.cancel();
      _posSub = null;

      // ✅ timerlarni to‘xtat
      _flushTimer?.cancel();
      _flushTimer = null;

      _durationTimer?.cancel();
      _durationTimer = null;

      // ✅ qolgan batchni yubor
      await _flush();

      // ✅ stop body
      final last = state.rawPath.isNotEmpty ? state.rawPath.last : null;

      await repo.stopSession(
        sessionId: sessionId,
        stopTime: DateTime.now().toUtc(),
        stopLat: last?.latitude ?? 0,
        stopLon: last?.longitude ?? 0,
      );

      // ✅ STOP tugadi
      emit(state.copyWith(stopping: false));
    } catch (e) {
      // agar network yiqilsa ham UI yo‘qolmasin
      emit(state.copyWith(stopping: false, error: e.toString()));
    }
  }


  void _onPosition(Position pos) {
    if (!state.tracking) return;
    if (pos.accuracy > _maxAccuracyM) return;

    final newRaw = LatLng(pos.latitude, pos.longitude);

    if (state.rawPath.isNotEmpty) {
      final last = state.rawPath.last;
      final meters = _dist.as(LengthUnit.Meter, last, newRaw);
      if (meters < _minMoveM) return;
    }

    final rawNext = List<LatLng>.from(state.rawPath)..add(newRaw);

    double nextKm = state.distanceKm;
    if (state.rawPath.isNotEmpty) {
      final m = _dist.as(LengthUnit.Meter, state.rawPath.last, newRaw);
      nextKm += (m / 1000.0);
    }

    final smooth = _emaSmooth(newRaw);
    final uiNext = List<LatLng>.from(state.uiPath)..add(smooth);

    final heading = (pos.heading.isFinite && pos.heading >= 0)
        ? pos.heading
        : state.headingDeg;

    emit(state.copyWith(
      rawPath: rawNext,
      uiPath: uiNext,
      distanceKm: nextKm,
      headingDeg: heading,
      error: null,
    ));

    _buffer.add(
      TrackingPoint(
        eventId: _uuid.v4(),
        lat: newRaw.latitude,
        lon: newRaw.longitude,
        deviceTimestamp: DateTime.now().toUtc(),
        accuracyM: pos.accuracy,
        speedMps: pos.speed.isFinite ? pos.speed : 0.0,
        headingDeg: pos.heading.isFinite ? pos.heading : 0.0,
        provider: (pos.isMocked ?? false) ? "mock" : "gps",
        mock: pos.isMocked ?? false,
      ),
    );

    if (_buffer.length >= 5) {
      _flush();
    }
  }

  LatLng _emaSmooth(LatLng p) {
    if (_ema == null) {
      _ema = p;
      return p;
    }
    final prev = _ema!;
    final lat = prev.latitude + _alpha * (p.latitude - prev.latitude);
    final lon = prev.longitude + _alpha * (p.longitude - prev.longitude);
    _ema = LatLng(lat, lon);
    return _ema!;
  }

  Future<void> _flush() async {
    final sessionId = state.sessionId;
    if (sessionId == null) return;
    if (_buffer.isEmpty) return;

    final batch = List<TrackingPoint>.from(_buffer);
    _buffer.clear();

    try {
      await repo.ingestPoints(sessionId, batch);
      debugPrint("POINTS SENT: ${batch.length}");
    } catch (e) {
      _buffer.insertAll(0, batch);
      debugPrint("FLUSH ERROR: $e");
    }
  }

  @override
  Future<void> close() async {
    await _posSub?.cancel();
    _flushTimer?.cancel();
    _durationTimer?.cancel();
    return super.close();
  }
}
