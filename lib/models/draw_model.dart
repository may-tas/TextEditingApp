import 'package:flutter/material.dart';

enum BrushType {
  brush,
  marker,
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

  Map<String, dynamic> toJson() {
    return {
      'offsetX': offset.dx,
      'offsetY': offset.dy,
      'color': paint.color.value,
      'strokeWidth': paint.strokeWidth,
      'strokeCap': paint.strokeCap.index,
      'strokeJoin': paint.strokeJoin.index,
      'pressure': pressure,
    };
  }

  factory DrawingPoint.fromJson(Map<String, dynamic> json) {
    final paint = Paint()
      ..color = Color(json['color'] as int)
      ..strokeWidth = (json['strokeWidth'] as num).toDouble()
      ..strokeCap = StrokeCap.values[json['strokeCap'] as int]
      ..strokeJoin = StrokeJoin.values[json['strokeJoin'] as int];

    return DrawingPoint(
      offset: Offset(
        (json['offsetX'] as num).toDouble(),
        (json['offsetY'] as num).toDouble(),
      ),
      paint: paint,
      pressure: (json['pressure'] as num?)?.toDouble() ?? 1.0,
    );
  }
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
      'points': points.map((point) => point.toJson()).toList(),
      'color': color.value,
      'strokeWidth': strokeWidth,
      'strokeCap': strokeCap.index,
      'isFill': isFill,
      'brushType': brushType.index,
    };
  }

  factory DrawPath.fromJson(Map<String, dynamic> json) {
    final List<dynamic> pointsList = json['points'];

    return DrawPath(
      points: pointsList
          .map((pointJson) => DrawingPoint.fromJson(pointJson))
          .toList(),
      color: Color(json['color'] as int),
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      strokeCap: json['strokeCap'] != null
          ? StrokeCap.values[json['strokeCap'] as int]
          : StrokeCap.round,
      isFill: json['isFill'] ?? false,
      brushType: json['brushType'] != null
          ? BrushType.values[json['brushType'] as int]
          : BrushType.brush,
    );
  }
}
