import 'package:flutter/material.dart';
import '../../../models/draw_model.dart';
import 'dart:math' as math;

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

      // Use brush-specific rendering
      _renderBrushStroke(canvas, path);
    }
  }

  void _renderBrushStroke(Canvas canvas, DrawPath path) {
    final points = path.points;
    if (points.isEmpty) return;

    switch (path.brushType) {
      case BrushType.sprayPaint:
        _renderSprayPaint(canvas, path);
        break;
      case BrushType.charcoal:
        _renderCharcoal(canvas, path);
        break;
      case BrushType.watercolor:
        _renderWatercolor(canvas, path);
        break;
      case BrushType.oilPaint:
        _renderOilPaint(canvas, path);
        break;
      default:
        _renderStandardStroke(canvas, path);
        break;
    }
  }

  void _renderStandardStroke(Canvas canvas, DrawPath path) {
    final points = path.points;
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

  void _renderSprayPaint(Canvas canvas, DrawPath path) {
    final points = path.points;
    final basePaint = points.first.paint;

    // Create spray effect with multiple small dots
    for (var point in points) {
      final sprayRadius = basePaint.strokeWidth * 1.5;
      final numDots = (sprayRadius * 0.8).round();

      for (int i = 0; i < numDots; i++) {
        final angle = (i / numDots) * 2 * math.pi;
        final distance = math.Random().nextDouble() * sprayRadius;
        final dotOffset = Offset(
          point.offset.dx + math.cos(angle) * distance,
          point.offset.dy + math.sin(angle) * distance,
        );

        final dotPaint = Paint()
          ..color = basePaint.color.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(dotOffset, 1.0, dotPaint);
      }
    }
  }

  void _renderCharcoal(Canvas canvas, DrawPath path) {
    final points = path.points;
    final basePaint = points.first.paint;

    // Create textured charcoal effect
    if (points.length == 1) {
      canvas.drawCircle(
          points.first.offset, basePaint.strokeWidth / 2, basePaint);
    } else {
      // Draw multiple overlapping strokes for texture
      for (int layer = 0; layer < 3; layer++) {
        final layerPaint = Paint()
          ..color = basePaint.color.withValues(alpha: 0.3)
          ..strokeWidth = basePaint.strokeWidth + layer * 2
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        final drawPath = Path();
        drawPath.moveTo(points.first.offset.dx, points.first.offset.dy);

        for (int i = 1; i < points.length; i++) {
          drawPath.lineTo(points[i].offset.dx, points[i].offset.dy);
        }

        canvas.drawPath(drawPath, layerPaint);
      }
    }
  }

  void _renderWatercolor(Canvas canvas, DrawPath path) {
    final points = path.points;
    final basePaint = points.first.paint;

    // Create watercolor bleeding effect with larger, softer strokes
    if (points.length == 1) {
      // Single point with soft edges
      final paint1 = Paint()
        ..color = basePaint.color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
          points.first.offset, basePaint.strokeWidth * 1.5, paint1);

      final paint2 = Paint()
        ..color = basePaint.color.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(points.first.offset, basePaint.strokeWidth, paint2);
    } else {
      // Multiple soft layers for bleeding effect
      for (int layer = 2; layer >= 0; layer--) {
        final layerPaint = Paint()
          ..color = basePaint.color.withValues(alpha: 0.2 + layer * 0.1)
          ..strokeWidth = basePaint.strokeWidth * (1.5 - layer * 0.2)
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        final drawPath = Path();
        drawPath.moveTo(points.first.offset.dx, points.first.offset.dy);

        for (int i = 1; i < points.length; i++) {
          drawPath.lineTo(points[i].offset.dx, points[i].offset.dy);
        }

        canvas.drawPath(drawPath, layerPaint);
      }
    }
  }

  void _renderOilPaint(Canvas canvas, DrawPath path) {
    final points = path.points;
    final basePaint = points.first.paint;

    // Create thick, textured oil paint effect
    if (points.length == 1) {
      canvas.drawCircle(
          points.first.offset, basePaint.strokeWidth / 2, basePaint);
    } else {
      // Draw main stroke
      final mainPath = Path();
      mainPath.moveTo(points.first.offset.dx, points.first.offset.dy);

      for (int i = 1; i < points.length; i++) {
        mainPath.lineTo(points[i].offset.dx, points[i].offset.dy);
      }

      canvas.drawPath(mainPath, basePaint);

      // Add texture with slightly offset strokes
      for (int texture = 0; texture < 2; texture++) {
        final texturePaint = Paint()
          ..color = basePaint.color.withValues(alpha: 0.4)
          ..strokeWidth = basePaint.strokeWidth * 0.7
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke;

        final texturePath = Path();
        final offsetX = (texture - 0.5) * 2;
        final offsetY = (texture - 0.5) * 2;

        texturePath.moveTo(
            points.first.offset.dx + offsetX, points.first.offset.dy + offsetY);

        for (int i = 1; i < points.length; i++) {
          texturePath.lineTo(
              points[i].offset.dx + offsetX, points[i].offset.dy + offsetY);
        }

        canvas.drawPath(texturePath, texturePaint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}
