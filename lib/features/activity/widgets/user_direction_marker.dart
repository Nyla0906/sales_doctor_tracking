import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UserDirectionMarker extends StatelessWidget {
  final double headingDeg;
  final double size;

  const UserDirectionMarker({
    super.key,
    required this.headingDeg,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final rad = headingDeg * math.pi / 180.0;

    return Transform.rotate(
      angle: rad,
      child: SvgPicture.asset(
        'assets/icons/navigation.svg',
        width: size,
        height: size,
        // xohlasang rangini ham shu yerda boshqarasan:
        // colorFilter: ColorFilter.mode(Colors.black, BlendMode.srcIn),
      ),
    );
  }
}
