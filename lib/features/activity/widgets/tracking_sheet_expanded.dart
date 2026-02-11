import 'package:flutter/material.dart';

class TrackingSheetExpanded extends StatelessWidget {
  final String duration;
  final String km;
  final VoidCallback onPause;
  final VoidCallback onCheckLocation;

  const TrackingSheetExpanded({
    super.key,
    required this.duration,
    required this.km,
    required this.onPause,
    required this.onCheckLocation,
  });

  @override
  Widget build(BuildContext context) {
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            children: [
              _handle(onPrimary.withOpacity(0.35)),
              const SizedBox(height: 24),

              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "$km km",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: onPrimary,
                      ),
                    ),
                    Text(
                      "Distance",
                      style: TextStyle(color: onPrimary.withOpacity(0.75)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              Text(
                duration,
                style: TextStyle(
                  fontSize: 86,
                  fontWeight: FontWeight.w700,
                  color: onPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Duration",
                style: TextStyle(color: onPrimary.withOpacity(0.75)),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: 120,
                height: 120,
                child: ElevatedButton(
                  onPressed: onPause,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 10,
                  ),
                  child: const Icon(Icons.pause, size: 46),
                ),
              ),

              const Spacer(),

              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: onCheckLocation,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: onPrimary.withOpacity(0.6)),
                    foregroundColor: onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: const Icon(Icons.location_on),
                  label: const Text("Check my location"),
                ),
              ),

              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }

  Widget _handle(Color c) {
    return Center(
      child: Container(
        width: 44,
        height: 5,
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}
