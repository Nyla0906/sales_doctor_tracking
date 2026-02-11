import 'package:flutter/material.dart';

class TrackingSheetCollapsed extends StatelessWidget {
  final String duration;
  final String km;
  final VoidCallback onPause;

  const TrackingSheetCollapsed({
    super.key,
    required this.duration,
    required this.km,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          _handle(),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Time: $duration",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  "$km km",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: 110,
            height: 110,
            child: ElevatedButton(
              onPressed: onPause,
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                elevation: 10,
              ),
              child: const Icon(Icons.pause, size: 44),
            ),
          ),
        ],
      ),
    );
  }

  Widget _handle() {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
