import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/tracking/repo_impl.dart';
import '../models/tracking_session.dart';

class SessionDetailPage extends StatefulWidget {
  final TrackingRepoImpl repo;
  final TrackingSession session;

  const SessionDetailPage({
    super.key,
    required this.repo,
    required this.session,
  });

  @override
  State<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends State<SessionDetailPage> {
  final MapController map = MapController();
  List<LatLng> path = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    final pts = await widget.repo.mySessionPoints(
      widget.session.sessionId,
      max: 2000,
      downsample: true,
      simplifyEpsM: 8,
    );

    final p = pts.map((e) => LatLng(e.lat, e.lon)).toList();

    setState(() {
      path = p;
      loading = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (path.length < 2) return;
      final bounds = LatLngBounds.fromPoints(path);
      map.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final center = path.isNotEmpty
        ? path.first
        : const LatLng(41.2995, 69.2401);

    return Scaffold(
      appBar: AppBar(title: const Text("Session route")),
      body: Stack(
        children: [
          FlutterMap(
            mapController: map,
            options: MapOptions(initialCenter: center, initialZoom: 15),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.example.sales_doctor_tracking_app",
              ),
              if (path.length >= 2)
                PolylineLayer(
                  polylines: [Polyline(points: path, strokeWidth: 5)],
                ),
              if (path.isNotEmpty)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: path.first,
                      width: 24,
                      height: 24,
                      child: const Icon(Icons.circle, size: 16),
                    ),
                    Marker(
                      point: path.last,
                      width: 24,
                      height: 24,
                      child: const Icon(Icons.location_on),
                    ),
                  ],
                ),
            ],
          ),
          if (loading)
            const Positioned.fill(
              child: ColoredBox(
                color: Colors.black12,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
