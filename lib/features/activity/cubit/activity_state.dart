import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class ActivityState extends Equatable {
  final bool tracking;
  final bool stopping; // ✅ NEW
  final String? sessionId;

  final int durationSec;
  final double distanceKm;

  final List<LatLng> rawPath;
  final List<LatLng> uiPath;

  final double headingDeg;
  final String? error;

  const ActivityState({
    this.tracking = false,
    this.stopping = false, // ✅ NEW
    this.sessionId,
    this.durationSec = 0,
    this.distanceKm = 0,
    this.rawPath = const [],
    this.uiPath = const [],
    this.headingDeg = 0,
    this.error,
  });

  LatLng? get currentPos => rawPath.isNotEmpty ? rawPath.last : null;

  ActivityState copyWith({
    bool? tracking,
    bool? stopping, // ✅ NEW
    String? sessionId,
    int? durationSec,
    double? distanceKm,
    List<LatLng>? rawPath,
    List<LatLng>? uiPath,
    double? headingDeg,
    String? error,
  }) {
    return ActivityState(
      tracking: tracking ?? this.tracking,
      stopping: stopping ?? this.stopping, // ✅ NEW
      sessionId: sessionId ?? this.sessionId,
      durationSec: durationSec ?? this.durationSec,
      distanceKm: distanceKm ?? this.distanceKm,
      rawPath: rawPath ?? this.rawPath,
      uiPath: uiPath ?? this.uiPath,
      headingDeg: headingDeg ?? this.headingDeg,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
    tracking,
    stopping, // ✅ NEW
    sessionId,
    durationSec,
    distanceKm,
    rawPath,
    uiPath,
    headingDeg,
    error,
  ];
}

