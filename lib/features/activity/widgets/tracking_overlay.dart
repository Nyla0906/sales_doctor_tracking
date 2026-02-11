import 'package:flutter/material.dart';

class TrackingOverlay extends StatelessWidget {
  final bool loading;
  final VoidCallback onLocate;

  const TrackingOverlay({
    super.key,
    required this.loading,
    required this.onLocate,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: SafeArea(
        child: Row(
          children: [
            if (loading)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(blurRadius: 10, color: Colors.black12),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10),
                    Text("Finding location..."),
                  ],
                ),
              ),
            const Spacer(),
            FloatingActionButton(
              heroTag: "locate",
              mini: true,
              onPressed: onLocate,
              child: const Icon(Icons.navigation),
            ),
          ],
        ),
      ),
    );
  }
}
