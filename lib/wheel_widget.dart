import 'dart:math';
import 'package:flutter/widgets.dart';

double deg2rad(double deg) => deg * pi / 180;
double rad2deg(double rad) => rad * 180 / pi;

class WheelWidget extends CustomPainter {
  final double borderThickness;
  final Color filledZoneColor;
  final Color emptyZoneColor;
  final double progress;

  WheelWidget({
    required this.borderThickness,
    required this.filledZoneColor,
    required this.emptyZoneColor,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    Paint emptyZonePaint = Paint()
      ..color = emptyZoneColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderThickness;

    Paint filledZonePaint = Paint()
      ..color = filledZoneColor
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderThickness;

    canvas.drawCircle(center, size.height / 2, emptyZonePaint);

    canvas.drawArc(
        Rect.fromCenter(
            center: center, width: size.height, height: size.height),
        deg2rad(-90),
        deg2rad(progress.toDouble() % 360),
        false,
        filledZonePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
