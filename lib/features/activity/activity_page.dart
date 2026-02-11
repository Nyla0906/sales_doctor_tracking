import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'cubit/activity_cubit.dart';
import 'cubit/activity_state.dart';
import 'widgets/tracking_overlay.dart';
import 'widgets/tracking_sheet.dart';
import 'widgets/user_direction_marker.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final MapController map = MapController();
  LatLng center = const LatLng(41.2995, 69.2401);
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _goToMyLocation();
  }

  Future<void> _goToMyLocation() async {
    try {
      setState(() => loading = true);

      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        setState(() => loading = false);
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        setState(() => loading = false);
        return;
      }

      final p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final me = LatLng(p.latitude, p.longitude);

      setState(() {
        center = me;
        loading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        map.move(me, 17);
      });
    } catch (_) {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: map,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 12,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName: "com.example.sales_doctor_tracking_app",
            ),

            /// ✅ Polyline (UI smooth)
            BlocBuilder<ActivityCubit, ActivityState>(
              buildWhen: (a, b) => a.uiPath != b.uiPath,
              builder: (context, st) {
                if (st.uiPath.length < 2) return const SizedBox.shrink();
                return PolylineLayer(
                  polylines: [
                    Polyline(
                      points: st.uiPath,
                      strokeWidth: 5,
                    ),
                  ],
                );
              },
            ),

            BlocBuilder<ActivityCubit, ActivityState>(
              buildWhen: (a, b) =>
              a.currentPos != b.currentPos || a.headingDeg != b.headingDeg,
              builder: (context, st) {
                final p = st.currentPos ?? center;
                return MarkerLayer(
                  markers: [
                    Marker(
                      point: p,
                      width: 36,
                      height: 36,
                      child: UserDirectionMarker(
                        headingDeg: st.headingDeg,
                        size: 22,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),

        TrackingOverlay(
          loading: loading,
          onLocate: _goToMyLocation,
        ),

        TrackingSheet(
          onLocate: _goToMyLocation,
        ),
      ],
    );
  }
}
