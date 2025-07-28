// lib/models/text_item_model.dart
import 'dart:ui';

class TextItem {
  final String text;
  final double x;
  final double y;
  final double fontSize;
  final FontStyle fontStyle;
  final FontWeight fontWeight;
  final String fontFamily;
  final Color color;

  TextItem({
    required this.text,
    required this.x,
    required this.y,
    required this.fontSize,
    required this.fontStyle,
    required this.fontWeight,
    required this.fontFamily,
    required this.color,
  });

  TextItem copyWith({
    String? text,
    double? x,
    double? y,
    double? fontSize,
    FontStyle? fontStyle,
    FontWeight? fontWeight,
    String? fontFamily,
    Color? color,
  }) {
    return TextItem(
      text: text ?? this.text,
      x: x ?? this.x,
      y: y ?? this.y,
      fontSize: fontSize ?? this.fontSize,
      fontStyle: fontStyle ?? this.fontStyle,
      fontWeight: fontWeight ?? this.fontWeight,
      fontFamily: fontFamily ?? this.fontFamily,
      color: color ?? this.color,
    );
  }
}
