import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:texterra/models/draw_model.dart';

void main() {
  group('DrawingPoint', () {
    test('creates DrawingPoint with offset and paint', () {
      final paint = Paint()
        ..color = Colors.black
        ..strokeWidth = 5.0;

      final point = DrawingPoint(
        offset: const Offset(10, 20),
        paint: paint,
      );

      expect(point.offset, const Offset(10, 20));
      expect(point.paint.color, Colors.black);
      expect(point.paint.strokeWidth, 5.0);
    });

    test('toJson serializes DrawingPoint correctly', () {
      final paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final point = DrawingPoint(
        offset: const Offset(15.5, 25.5),
        paint: paint,
      );

      final json = point.toJson();

      expect(json['offsetX'], 15.5);
      expect(json['offsetY'], 25.5);
      expect(
        json['color'],
        Colors.red.toARGB32(),
      );
      expect(json['strokeWidth'], 3.0);
      expect(json['strokeCap'], StrokeCap.round.index);
      expect(json['strokeJoin'], StrokeJoin.round.index);
    });

    test('fromJson deserializes DrawingPoint correctly', () {
      final json = {
        'offsetX': 30.5,
        'offsetY': 40.5,
        'color': Colors.blue.toARGB32(),
        'strokeWidth': 7.0,
        'strokeCap': StrokeCap.square.index,
        'strokeJoin': StrokeJoin.miter.index,
      };

      final point = DrawingPoint.fromJson(json);

      expect(point.offset.dx, 30.5);
      expect(point.offset.dy, 40.5);
      expect(point.paint.color.toARGB32(), Colors.blue.toARGB32());
      expect(point.paint.strokeWidth, 7.0);
      expect(point.paint.strokeCap, StrokeCap.square);
      expect(point.paint.strokeJoin, StrokeJoin.miter);
    });

    test('serialization round-trip preserves data', () {
      final paint = Paint()
        ..color = const Color(0xFF123456)
        ..strokeWidth = 12.5
        ..strokeCap = StrokeCap.butt
        ..strokeJoin = StrokeJoin.bevel;

      final original = DrawingPoint(
        offset: const Offset(100.25, 200.75),
        paint: paint,
      );

      final json = original.toJson();
      final deserialized = DrawingPoint.fromJson(json);

      expect(deserialized.offset, original.offset);
      expect(
          deserialized.paint.color.toARGB32(), original.paint.color.toARGB32());
      expect(deserialized.paint.strokeWidth, original.paint.strokeWidth);
      expect(deserialized.paint.strokeCap, original.paint.strokeCap);
      expect(deserialized.paint.strokeJoin, original.paint.strokeJoin);
    });
  });

  group('DrawPath', () {
    test('creates DrawPath with required parameters', () {
      final paint = Paint()
        ..color = Colors.black
        ..strokeWidth = 5.0;

      final points = [
        DrawingPoint(offset: const Offset(10, 10), paint: paint),
        DrawingPoint(offset: const Offset(20, 20), paint: paint),
      ];

      final path = DrawPath(
        points: points,
        color: Colors.black,
        strokeWidth: 5.0,
      );

      expect(path.points.length, 2);
      expect(path.color, Colors.black);
      expect(path.strokeWidth, 5.0);
      expect(path.brushType, BrushType.brush); // Default value
      expect(path.isFill, false); // Default value
    });

    test('creates DrawPath with optional parameters', () {
      final paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 3.0;

      final points = [
        DrawingPoint(offset: const Offset(10, 10), paint: paint),
      ];

      final path = DrawPath(
        points: points,
        color: Colors.red,
        strokeWidth: 3.0,
        brushType: BrushType.marker,
        isFill: true,
      );

      expect(path.brushType, BrushType.marker);
      expect(path.isFill, true);
    });

    test('toJson serializes DrawPath correctly', () {
      final paint = Paint()
        ..color = Colors.green
        ..strokeWidth = 4.0;

      final points = [
        DrawingPoint(offset: const Offset(10, 10), paint: paint),
        DrawingPoint(offset: const Offset(20, 20), paint: paint),
        DrawingPoint(offset: const Offset(30, 30), paint: paint),
      ];

      final path = DrawPath(
        points: points,
        color: Colors.green,
        strokeWidth: 4.0,
        brushType: BrushType.marker,
        isFill: false,
      );

      final json = path.toJson();

      expect(json['points'], isA<List>());
      expect(json['points'].length, 3);
      expect(
        json['color'],
        Colors.green.toARGB32(),
      );
      expect(json['strokeWidth'], 4.0);
      expect(json['brushType'], BrushType.marker.index);
      expect(json['isFill'], false);
    });

    test('fromJson deserializes DrawPath correctly', () {
      final pointsJson = [
        {
          'offsetX': 10.0,
          'offsetY': 10.0,
          'color': Colors.blue.toARGB32(),
          'strokeWidth': 6.0,
          'strokeCap': StrokeCap.round.index,
          'strokeJoin': StrokeJoin.round.index,
        },
        {
          'offsetX': 20.0,
          'offsetY': 20.0,
          'color': Colors.blue.toARGB32(),
          'strokeWidth': 6.0,
          'strokeCap': StrokeCap.round.index,
          'strokeJoin': StrokeJoin.round.index,
        },
      ];

      final json = {
        'points': pointsJson,
        'color': Colors.blue.toARGB32(),
        'strokeWidth': 6.0,
        'strokeCap': StrokeCap.round.index,
        'brushType': BrushType.brush.index,
        'isFill': false,
      };

      final path = DrawPath.fromJson(json);

      expect(path.points.length, 2);
      expect(path.color.toARGB32(), Colors.blue.toARGB32());
      expect(path.strokeWidth, 6.0);
      expect(path.brushType, BrushType.brush);
      expect(path.isFill, false);
    });

    test('fromJson handles missing optional fields with defaults', () {
      final pointsJson = [
        {
          'offsetX': 10.0,
          'offsetY': 10.0,
          'color': Colors.red.toARGB32(),
          'strokeWidth': 5.0,
          'strokeCap': StrokeCap.round.index,
          'strokeJoin': StrokeJoin.round.index,
        },
      ];

      final json = {
        'points': pointsJson,
        'color': Colors.red.toARGB32(),
        'strokeWidth': 5.0,
      };

      final path = DrawPath.fromJson(json);

      expect(path.brushType, BrushType.brush); // Default
      expect(path.isFill, false); // Default
    });

    test('serialization round-trip preserves all data', () {
      final paint = Paint()
        ..color = const Color(0xFFABCDEF)
        ..strokeWidth = 8.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final points = [
        DrawingPoint(offset: const Offset(50.5, 60.5), paint: paint),
        DrawingPoint(offset: const Offset(70.5, 80.5), paint: paint),
      ];

      final original = DrawPath(
        points: points,
        color: const Color(0xFFABCDEF),
        strokeWidth: 8.5,
        brushType: BrushType.marker,
        isFill: true,
      );

      final json = original.toJson();
      final deserialized = DrawPath.fromJson(json);

      expect(deserialized.points.length, original.points.length);
      expect(deserialized.color.toARGB32(), original.color.toARGB32());
      expect(deserialized.strokeWidth, original.strokeWidth);
      expect(deserialized.brushType, original.brushType);
      expect(deserialized.isFill, original.isFill);

      // Check first point
      expect(deserialized.points[0].offset, original.points[0].offset);
      expect(deserialized.points[0].paint.color.toARGB32(),
          original.points[0].paint.color.toARGB32());
      expect(deserialized.points[0].paint.strokeWidth,
          original.points[0].paint.strokeWidth);
    });

    test('empty points list is handled correctly', () {
      final path = DrawPath(
        points: [],
        color: Colors.black,
        strokeWidth: 5.0,
      );

      expect(path.points, isEmpty);

      final json = path.toJson();
      final deserialized = DrawPath.fromJson(json);

      expect(deserialized.points, isEmpty);
    });

    test('large path with many points serializes correctly', () {
      final paint = Paint()
        ..color = Colors.purple
        ..strokeWidth = 2.0;

      // Create a path with 100 points
      final points = List.generate(
        100,
        (i) => DrawingPoint(
          offset: Offset(i.toDouble(), i.toDouble() * 2),
          paint: paint,
        ),
      );

      final path = DrawPath(
        points: points,
        color: Colors.purple,
        strokeWidth: 2.0,
      );

      final json = path.toJson();
      final deserialized = DrawPath.fromJson(json);

      expect(deserialized.points.length, 100);
      expect(deserialized.points[0].offset, const Offset(0, 0));
      expect(deserialized.points[99].offset, const Offset(99, 198));
    });
  });

  group('BrushType', () {
    test('BrushType enum has correct values', () {
      expect(BrushType.values.length, 2);
      expect(BrushType.brush.index, 0);
      expect(BrushType.marker.index, 1);
    });

    test('BrushType can be serialized and deserialized', () {
      final brushIndex = BrushType.brush.index;
      final markerIndex = BrushType.marker.index;

      expect(BrushType.values[brushIndex], BrushType.brush);
      expect(BrushType.values[markerIndex], BrushType.marker);
    });
  });

  group('DrawPath Edge Cases', () {
    test('handles single point path', () {
      final paint = Paint()
        ..color = Colors.orange
        ..strokeWidth = 5.0;

      final path = DrawPath(
        points: [DrawingPoint(offset: const Offset(50, 50), paint: paint)],
        color: Colors.orange,
        strokeWidth: 5.0,
      );

      expect(path.points.length, 1);

      final json = path.toJson();
      final deserialized = DrawPath.fromJson(json);

      expect(deserialized.points.length, 1);
      expect(deserialized.points[0].offset, const Offset(50, 50));
    });

    test('handles fill path correctly', () {
      final paint = Paint()
        ..color = Colors.cyan
        ..strokeWidth = 1.0;

      final path = DrawPath(
        points: [DrawingPoint(offset: Offset.zero, paint: paint)],
        color: Colors.cyan,
        strokeWidth: 1.0,
        isFill: true,
      );

      expect(path.isFill, true);

      final json = path.toJson();
      final deserialized = DrawPath.fromJson(json);

      expect(deserialized.isFill, true);
    });

    test('handles different stroke widths in points', () {
      final paint1 = Paint()
        ..color = Colors.black
        ..strokeWidth = 2.0;

      final paint2 = Paint()
        ..color = Colors.black
        ..strokeWidth = 5.0;

      final paint3 = Paint()
        ..color = Colors.black
        ..strokeWidth = 10.0;

      final path = DrawPath(
        points: [
          DrawingPoint(offset: const Offset(10, 10), paint: paint1),
          DrawingPoint(offset: const Offset(20, 20), paint: paint2),
          DrawingPoint(offset: const Offset(30, 30), paint: paint3),
        ],
        color: Colors.black,
        strokeWidth: 5.0,
      );

      final json = path.toJson();
      final deserialized = DrawPath.fromJson(json);

      expect(deserialized.points[0].paint.strokeWidth, 2.0);
      expect(deserialized.points[1].paint.strokeWidth, 5.0);
      expect(deserialized.points[2].paint.strokeWidth, 10.0);
    });

    test('handles negative coordinates', () {
      final paint = Paint()
        ..color = Colors.red
        ..strokeWidth = 5.0;

      final path = DrawPath(
        points: [
          DrawingPoint(offset: const Offset(-10, -20), paint: paint),
          DrawingPoint(offset: const Offset(-30, -40), paint: paint),
        ],
        color: Colors.red,
        strokeWidth: 5.0,
      );

      final json = path.toJson();
      final deserialized = DrawPath.fromJson(json);

      expect(deserialized.points[0].offset, const Offset(-10, -20));
      expect(deserialized.points[1].offset, const Offset(-30, -40));
    });

    test('handles very small and very large coordinates', () {
      final paint = Paint()
        ..color = Colors.blue
        ..strokeWidth = 5.0;

      final path = DrawPath(
        points: [
          DrawingPoint(offset: const Offset(0.001, 0.001), paint: paint),
          DrawingPoint(offset: const Offset(9999.99, 9999.99), paint: paint),
        ],
        color: Colors.blue,
        strokeWidth: 5.0,
      );

      final json = path.toJson();
      final deserialized = DrawPath.fromJson(json);

      expect(deserialized.points[0].offset.dx, closeTo(0.001, 0.0001));
      expect(deserialized.points[0].offset.dy, closeTo(0.001, 0.0001));
      expect(deserialized.points[1].offset.dx, closeTo(9999.99, 0.01));
      expect(deserialized.points[1].offset.dy, closeTo(9999.99, 0.01));
    });
  });
}
