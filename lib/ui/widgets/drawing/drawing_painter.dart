import 'package:flutter/material.dart';
import '../../../models/draw_model.dart';

class DrawingPainter extends CustomPainter {
  final List<DrawPath> paths;

  DrawingPainter({required this.paths});

  @override
  void paint(Canvas canvas, Size size) {
    for (var path in paths) {
      if (path.isFill) {
        // Fill the entire visible canvas area
        final paint = Paint()
          ..color = path.color
          ..style = PaintingStyle.fill;

        canvas.drawRect(Offset.zero & size, paint);
        continue; // Skip the regular path drawing for fill operations
      }
      final points = path.points;
      if (points.isEmpty) continue;

      final paint = points.first.paint;

      if (points.length == 1) {
        // Draw a dot for single point
        canvas.drawCircle(points.first.offset, paint.strokeWidth / 2, paint);
      } else {
        // Draw a path for multiple points
        final drawPath = Path();
        drawPath.moveTo(points.first.offset.dx, points.first.offset.dy);

        for (int i = 1; i < points.length; i++) {
          drawPath.lineTo(points[i].offset.dx, points[i].offset.dy);
        }

        canvas.drawPath(drawPath, paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
