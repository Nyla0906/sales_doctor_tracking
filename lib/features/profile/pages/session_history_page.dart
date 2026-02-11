import 'package:flutter/material.dart';

import '../../../data/tracking/repo_impl.dart';
import '../models/tracking_session.dart';
import 'session_detail_page.dart';

class SessionHistoryPage extends StatefulWidget {
  final TrackingRepoImpl repo;
  const SessionHistoryPage({super.key, required this.repo});

  @override
  State<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends State<SessionHistoryPage> {
  late Future<List<TrackingSession>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repo.mySessions();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = widget.repo.mySessions();
    });
    // FutureBuilder yangilansin deb kutib turamiz
    await _future;
  }

  String _fmtDt(DateTime d) {
    final local = d.toLocal();
    return "${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} "
        "${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Session history"),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<TrackingSession>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text("Error: ${snap.error}"));
          }

          final items = snap.data ?? [];

          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                children: const [
                  SizedBox(height: 260),
                  Center(child: Text("No sessions yet")),
                  SizedBox(height: 20),
                  Center(child: Text("Pull down to refresh")),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final s = items[i];

                final subtitle = StringBuffer()
                  ..write("Start: ${_fmtDt(s.startTime)}");
                if (s.stopTime != null) {
                  subtitle.write("\nStop: ${_fmtDt(s.stopTime!)}");
                }

                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  tileColor: Colors.white,
                  title: Text(
                    "Session ${s.sessionId.substring(0, 6)} • ${s.status}",
                  ),
                  subtitle: Text(subtitle.toString()),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SessionDetailPage(
                          repo: widget.repo,
                          session: s,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
