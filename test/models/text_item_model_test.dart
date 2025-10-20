import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:texterra/models/text_item_model.dart';

void main() {
  group('TextItem Model', () {
    test('creates TextItem with required parameters', () {
      final textItem = TextItem(
        text: 'Test',
        x: 10,
        y: 20,
        fontSize: 16,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontFamily: 'Roboto',
        isUnderlined: false,
        color: Colors.black,
      );

      expect(textItem.text, 'Test');
      expect(textItem.x, 10);
      expect(textItem.y, 20);
      expect(textItem.fontSize, 16);
      expect(textItem.fontStyle, FontStyle.normal);
      expect(textItem.fontWeight, FontWeight.normal);
      expect(textItem.fontFamily, 'Roboto');
      expect(textItem.isUnderlined, false);
      expect(textItem.color, Colors.black);
    });

    test('creates TextItem with default optional parameters', () {
      final textItem = TextItem(
        text: 'Test',
        x: 10,
        y: 20,
        fontSize: 16,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontFamily: 'Roboto',
        isUnderlined: false,
        color: Colors.black,
      );

      expect(textItem.isHighlighted, false);
      expect(textItem.highlightColor, isNull);
      expect(textItem.textAlign, TextAlign.left);
      expect(textItem.hasShadow, false);
      expect(textItem.shadowColor, Colors.black);
      expect(textItem.shadowBlurRadius, 4.0);
      expect(textItem.shadowOffset, const Offset(2.0, 2.0));
    });

    test('toHTML generates correct HTML with basic styling', () {
      final textItem = TextItem(
        text: 'Test',
        x: 10,
        y: 20,
        fontSize: 16,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontFamily: 'Arial',
        isUnderlined: false,
        color: Colors.black,
      );

      final html = textItem.toHTML();

      expect(html, contains('font-size: 16.0px'));
      expect(html, contains('font-family: Arial'));
      expect(html, contains('font-style: normal'));
    });

    test('toHTML includes underline decoration', () {
      final textItem = TextItem(
        text: 'Test',
        x: 10,
        y: 20,
        fontSize: 16,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontFamily: 'Arial',
        isUnderlined: true,
        color: Colors.black,
      );

      final html = textItem.toHTML();

      expect(html, contains('text-decoration: underline'));
    });

    test('toHTML includes highlight background color', () {
      final textItem = TextItem(
        text: 'Test',
        x: 10,
        y: 20,
        fontSize: 16,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontFamily: 'Arial',
        isUnderlined: false,
        color: Colors.black,
        isHighlighted: true,
        highlightColor: Colors.yellow,
      );

      final html = textItem.toHTML();

      expect(html, contains('background-color:'));
    });

    test('toHTML includes text shadow', () {
      final textItem = TextItem(
        text: 'Test',
        x: 10,
        y: 20,
        fontSize: 16,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontFamily: 'Arial',
        isUnderlined: false,
        color: Colors.black,
        hasShadow: true,
        shadowColor: Colors.grey,
        shadowBlurRadius: 4.0,
        shadowOffset: const Offset(2.0, 2.0),
      );

      final html = textItem.toHTML();

      expect(html, contains('text-shadow:'));
    });

    test('copyWith creates new instance with updated values', () {
      final original = TextItem(
        text: 'Original',
        x: 10,
        y: 20,
        fontSize: 16,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.normal,
        fontFamily: 'Roboto',
        isUnderlined: false,
        color: Colors.black,
      );

      final updated = original.copyWith(
        text: 'Updated',
        fontSize: 24,
        color: const Color(0xFFF44336),
      );

      expect(updated.text, 'Updated');
      expect(updated.fontSize, 24);
      expect(updated.color, const Color(0xFFF44336));
      expect(updated.x, 10); // Unchanged
      expect(updated.y, 20); // Unchanged
    });

    test('copyWith preserves original values when not specified', () {
      final original = TextItem(
        text: 'Test',
        x: 10,
        y: 20,
        fontSize: 16,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
        fontFamily: 'Arial',
        isUnderlined: true,
        color: const Color(0xFF2196F3),
        isHighlighted: true,
        highlightColor: const Color(0xFFFFEB3B),
      );

      final updated = original.copyWith(text: 'Updated');

      expect(updated.text, 'Updated');
      expect(updated.fontStyle, FontStyle.italic);
      expect(updated.fontWeight, FontWeight.bold);
      expect(updated.fontFamily, 'Arial');
      expect(updated.isUnderlined, true);
      expect(updated.isHighlighted, true);
      expect(updated.highlightColor, const Color(0xFFFFEB3B));
    });

    test('toJson serializes TextItem correctly', () {
      final textItem = TextItem(
        text: 'Test',
        x: 10,
        y: 20,
        fontSize: 16,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.bold,
        fontFamily: 'Arial',
        isUnderlined: true,
        color: const Color(0xFFF44336),
        isHighlighted: true,
        highlightColor: const Color(0xFFFFEB3B),
        textAlign: TextAlign.center,
        hasShadow: true,
        shadowColor: Colors.black,
        shadowBlurRadius: 5.0,
        shadowOffset: const Offset(3.0, 3.0),
      );

      final json = textItem.toJson();

      expect(json['text'], 'Test');
      expect(json['x'], 10);
      expect(json['y'], 20);
      expect(json['fontSize'], 16);
      expect(json['fontStyle'], FontStyle.italic.index);
      expect(json['fontWeight'], FontWeight.bold.index);
      expect(json['fontFamily'], 'Arial');
      expect(json['isUnderlined'], true);
      expect(json['color'], 0xFFF44336);
      expect(json['isHighlighted'], true);
      expect(json['highlightColor'], 0xFFFFEB3B);
      expect(json['textAlign'], TextAlign.center.index);
      expect(json['hasShadow'], true);
      expect(json['shadowColor'], Colors.black.value);
      expect(json['shadowBlurRadius'], 5.0);
      expect(json['shadowOffsetDx'], 3.0);
      expect(json['shadowOffsetDy'], 3.0);
    });

    test('fromJson deserializes TextItem correctly', () {
      final json = {
        'text': 'Test',
        'x': 10.0,
        'y': 20.0,
        'fontSize': 16.0,
        'fontStyle': FontStyle.italic.index,
        'fontWeight': FontWeight.bold.index,
        'fontFamily': 'Arial',
        'isUnderlined': true,
        'color': 0xFFF44336,
        'isHighlighted': true,
        'highlightColor': 0xFFFFEB3B,
        'textAlign': TextAlign.center.index,
        'hasShadow': true,
        'shadowColor': 0xFF000000,
        'shadowBlurRadius': 5.0,
        'shadowOffsetDx': 3.0,
        'shadowOffsetDy': 3.0,
      };

      final textItem = TextItem.fromJson(json);

      expect(textItem.text, 'Test');
      expect(textItem.x, 10);
      expect(textItem.y, 20);
      expect(textItem.fontSize, 16);
      expect(textItem.fontStyle, FontStyle.italic);
      expect(textItem.fontWeight, FontWeight.bold);
      expect(textItem.fontFamily, 'Arial');
      expect(textItem.isUnderlined, true);
      expect(textItem.color, const Color(0xFFF44336));
      expect(textItem.isHighlighted, true);
      expect(textItem.highlightColor, const Color(0xFFFFEB3B));
      expect(textItem.textAlign, TextAlign.center);
      expect(textItem.hasShadow, true);
      expect(textItem.shadowColor, const Color(0xFF000000));
      expect(textItem.shadowBlurRadius, 5.0);
      expect(textItem.shadowOffset, const Offset(3.0, 3.0));
    });

    test('fromJson handles missing optional fields with defaults', () {
      final json = {
        'text': 'Test',
        'x': 10.0,
        'y': 20.0,
        'fontSize': 16.0,
        'fontStyle': FontStyle.normal.index,
        'fontWeight': FontWeight.normal.index,
        'fontFamily': 'Roboto',
        'color': Colors.black.value,
      };

      final textItem = TextItem.fromJson(json);

      expect(textItem.isUnderlined, false);
      expect(textItem.textAlign, TextAlign.left);
      expect(textItem.isHighlighted, false);
      expect(textItem.highlightColor, isNull);
      expect(textItem.hasShadow, false);
      expect(textItem.shadowColor, Colors.black);
      expect(textItem.shadowBlurRadius, 4.0);
      expect(textItem.shadowOffset, const Offset(2.0, 2.0));
    });

    test('serialization round-trip preserves all data', () {
      final original = TextItem(
        text: 'Test Round Trip',
        x: 15.5,
        y: 25.5,
        fontSize: 18,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w600,
        fontFamily: 'Helvetica',
        isUnderlined: true,
        color: const Color(0xFF123456),
        isHighlighted: true,
        highlightColor: const Color(0xFFABCDEF),
        textAlign: TextAlign.right,
        hasShadow: true,
        shadowColor: const Color(0xFF111111),
        shadowBlurRadius: 7.5,
        shadowOffset: const Offset(4.5, 5.5),
      );

      final json = original.toJson();
      final deserialized = TextItem.fromJson(json);

      expect(deserialized.text, original.text);
      expect(deserialized.x, original.x);
      expect(deserialized.y, original.y);
      expect(deserialized.fontSize, original.fontSize);
      expect(deserialized.fontStyle, original.fontStyle);
      expect(deserialized.fontWeight, original.fontWeight);
      expect(deserialized.fontFamily, original.fontFamily);
      expect(deserialized.isUnderlined, original.isUnderlined);
      expect(deserialized.color, original.color);
      expect(deserialized.isHighlighted, original.isHighlighted);
      expect(deserialized.highlightColor, original.highlightColor);
      expect(deserialized.textAlign, original.textAlign);
      expect(deserialized.hasShadow, original.hasShadow);
      expect(deserialized.shadowColor, original.shadowColor);
      expect(deserialized.shadowBlurRadius, original.shadowBlurRadius);
      expect(deserialized.shadowOffset, original.shadowOffset);
    });
  });
}
