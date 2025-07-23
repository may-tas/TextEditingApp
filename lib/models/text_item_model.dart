// lib/models/text_item_model.dart
import 'package:flutter/material.dart'; // Using material.dart for Color, FontStyle, FontWeight
import 'package:uuid/uuid.dart'; // <--- NEW: Import uuid package

class TextItem {
  final String id; // <--- NEW: Unique ID for each text item
  final String text;
  final double x;
  final double y;
  final double fontSize;
  final FontStyle fontStyle;
  final FontWeight fontWeight;
  final String fontFamily;
  final Color color;

  // Create a Uuid generator instance
  static const Uuid _uuid = Uuid();

  TextItem({
    String? id, // Optional: if an ID is provided, use it; otherwise, generate a new one
    required this.text,
    required this.x,
    required this.y,
    required this.fontSize,
    required this.fontStyle,
    required this.fontWeight,
    required this.fontFamily,
    required this.color,
  }) : id = id ?? _uuid.v4(); // Generate a unique ID if not provided

  TextItem copyWith({
    String? id, // Allow copying with a new ID (though typically the ID remains the same)
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
      id: id ?? this.id, // <--- NEW: Retain the original ID by default
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