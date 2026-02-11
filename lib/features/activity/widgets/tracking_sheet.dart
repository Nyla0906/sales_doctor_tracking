import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/activity_cubit.dart';
import '../cubit/activity_state.dart';
import 'tracking_sheet_collapsed.dart';
import 'tracking_sheet_expanded.dart';

class TrackingSheet extends StatefulWidget {
  final Future<void> Function() onLocate;

  const TrackingSheet({
    super.key,
    required this.onLocate,
  });

  @override
  State<TrackingSheet> createState() => _TrackingSheetState();
}

class _TrackingSheetState extends State<TrackingSheet> {
  final ctrl = DraggableScrollableController();
  double size = 0.22;

  static const minSize = 0.22;
  static const maxSize = 1.0;

  String _fmtSec(int sec) {
    final d = Duration(seconds: sec);
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    if (h > 0) return "${h.toString().padLeft(2, '0')}:$m:$s";
    return "$m:$s";
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (n) {
        if (size != n.extent) setState(() => size = n.extent);
        return false;
      },
      child: BlocBuilder<ActivityCubit, ActivityState>(
        buildWhen: (prev, next) {
          return prev.tracking != next.tracking ||
              prev.durationSec != next.durationSec ||
              prev.distanceKm != next.distanceKm;
        },
        builder: (context, state) {
          if (!state.tracking) {
            return Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: SafeArea(
                child: Center(
                  child: SizedBox(
                    width: 140,
                    height: 140,
                    child: ElevatedButton(
                      onPressed: () => context.read<ActivityCubit>().start(),
                      style: ElevatedButton.styleFrom(
                        shape: const CircleBorder(),
                        elevation: 8,
                      ),
                      child: const Text(
                        "Start",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          final expanded = size > 0.7;
          final duration = _fmtSec(state.durationSec);
          final km = state.distanceKm.toStringAsFixed(2);

          return DraggableScrollableSheet(
            controller: ctrl,
            initialChildSize: minSize,
            minChildSize: minSize,
            maxChildSize: maxSize,
            snap: true,
            snapSizes: const [minSize, maxSize],
            builder: (context, scroll) {
              return Container(
                decoration: BoxDecoration(
                  color: expanded
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: const [BoxShadow(blurRadius: 18, color: Colors.black12)],
                ),
                child: SingleChildScrollView(
                  controller: scroll,
                  child: expanded
                      ? TrackingSheetExpanded(
                    duration: duration,
                    km: km,
                    onPause: () => context.read<ActivityCubit>().stop(),
                    onCheckLocation: () async {
                      await widget.onLocate();
                      if (ctrl.isAttached) {
                        ctrl.animateTo(
                          minSize,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      }
                    },
                  )
                      : TrackingSheetCollapsed(
                    duration: duration,
                    km: km,
                    onPause: () => context.read<ActivityCubit>().stop(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
