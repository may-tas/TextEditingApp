import 'package:flutter/material.dart';

enum BrushType { 
  brush, 
  marker, 
  highlighter, 
  pencil,
  watercolor,
  oilPaint,
  charcoal,
  sprayPaint,
}

class DrawingPoint {
  final Offset offset;
  final Paint paint;
  final double pressure;

  DrawingPoint({
    required this.offset,
    required this.paint,
    this.pressure = 1.0,
  });
}

class DrawPath {
  final List<DrawingPoint> points;
  final Color color;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final bool isFill;
  final BrushType brushType;

  DrawPath({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.strokeCap = StrokeCap.round,
    this.isFill = false,
    this.brushType = BrushType.brush,
  });

  DrawPath copyWith({
    List<DrawingPoint>? points,
    Color? color,
    double? strokeWidth,
    StrokeCap? strokeCap,
    BrushType? brushType,
  }) {
    return DrawPath(
      points: points ?? this.points,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      strokeCap: strokeCap ?? this.strokeCap,
      brushType: brushType ?? this.brushType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points
          .map((point) => {
                'x': point.offset.dx,
                'y': point.offset.dy,
                'color': point.paint.color.toARGB32(),
                'strokeWidth': point.paint.strokeWidth,
                'pressure': point.pressure,
                'style': point.paint.style.index, // Save paint style
              })
          .toList(),
      'color': color.toARGB32(),
      'strokeWidth': strokeWidth,
      'strokeCap': strokeCap.index,
      'isFill': isFill,
      'brushType': brushType.index,
    };
  }

  factory DrawPath.fromJson(Map<String, dynamic> json) {
    final List<dynamic> pointsList = json['points'];

    return DrawPath(
      points: pointsList.map((pointJson) {
        return DrawingPoint(
          offset: Offset(pointJson['x'], pointJson['y']),
          paint: Paint()
            ..color = Color(pointJson['color'])
            ..strokeWidth = pointJson['strokeWidth']
            ..strokeCap = StrokeCap.round
            ..style = pointJson['style'] != null
                ? PaintingStyle.values[pointJson['style']]
                : PaintingStyle.stroke, // Default to stroke for compatibility
          pressure: pointJson['pressure'] ?? 1.0,
        );
      }).toList(),
      color: Color(json['color']),
      strokeWidth: json['strokeWidth'],
      strokeCap: StrokeCap.values[json['strokeCap']],
      isFill: json['isFill'] ?? false,
      brushType: BrushType.values[json['brushType'] ?? 0],
    );
  }
}
