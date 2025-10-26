import 'package:flutter/material.dart';

class TextItem {
  final String text;
  final double x;
  final double y;
  final double fontSize;
  final FontStyle fontStyle;
  final FontWeight fontWeight;
  final bool isUnderlined;
  final String fontFamily;
  final Color color;
  final bool isHighlighted;
  final Color? highlightColor;
  final TextAlign textAlign;

  // Shadow properties
  final bool hasShadow;
  final Color shadowColor;
  final double shadowBlurRadius;
  final Offset shadowOffset;

  // Rotation in radians
  final double rotation;

  TextItem({
    required this.text,
    required this.x,
    required this.y,
    required this.fontSize,
    required this.fontStyle,
    required this.fontWeight,
    required this.fontFamily,
    required this.isUnderlined,
    required this.color,
    this.isHighlighted = false,
    this.highlightColor,
    this.textAlign = TextAlign.left,
    this.hasShadow = false,
    this.shadowColor = Colors.black,
    this.shadowBlurRadius = 4.0,
    this.shadowOffset = const Offset(2.0, 2.0),
    this.rotation = 0.0,
  });

  TextItem copyWith({
    String? text,
    double? x,
    double? y,
    double? fontSize,
    FontStyle? fontStyle,
    FontWeight? fontWeight,
    String? fontFamily,
    bool? isUnderlined,
    Color? color,
    bool? isHighlighted,
    Color? highlightColor,
    TextAlign? textAlign,
    bool? hasShadow,
    Color? shadowColor,
    double? shadowBlurRadius,
    Offset? shadowOffset,
    double? rotation,
  }) {
    return TextItem(
      text: text ?? this.text,
      x: x ?? this.x,
      y: y ?? this.y,
      fontSize: fontSize ?? this.fontSize,
      fontStyle: fontStyle ?? this.fontStyle,
      fontWeight: fontWeight ?? this.fontWeight,
      fontFamily: fontFamily ?? this.fontFamily,
      isUnderlined: isUnderlined ?? this.isUnderlined,
      color: color ?? this.color,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      highlightColor: highlightColor ?? this.highlightColor,
      textAlign: textAlign ?? this.textAlign,
      hasShadow: hasShadow ?? this.hasShadow,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      rotation: rotation ?? this.rotation,
    );
  }

  String toHTML() {
    final cssColor =
        "#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}";
    final cssFontWeight = fontWeight.value;
    final cssFontStyle = fontStyle == FontStyle.italic ? 'italic' : 'normal';
    final textDecoration = isUnderlined ? 'text-decoration: underline; ' : '';
    final backgroundColor = isHighlighted && highlightColor != null
        ? 'background-color: #${highlightColor!.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}; '
        : '';

    final textShadow = hasShadow
        ? 'text-shadow: ${shadowOffset.dx}px ${shadowOffset.dy}px ${shadowBlurRadius}px #${shadowColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}; '
        : '';

    final style =
        'font-size: ${fontSize}px; font-family: $fontFamily; color: $cssColor; font-weight: $cssFontWeight; font-style: $cssFontStyle; $textDecoration$backgroundColor$textShadow';
    return '<span style="$style">$text</span>';
  }

  // Convert to map for saving
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'x': x,
      'y': y,
      'fontSize': fontSize,
      'fontWeight': fontWeight.index,
      'fontStyle': fontStyle.index,
      'color': color.toARGB32(),
      'fontFamily': fontFamily,
      'isUnderlined': isUnderlined,
      'textAlign': textAlign.index,
      'isHighlighted': isHighlighted,
      'highlightColor': highlightColor?.toARGB32(),
      'hasShadow': hasShadow,
      'shadowColor': shadowColor.toARGB32(),
      'shadowBlurRadius': shadowBlurRadius,
      'shadowOffsetDx': shadowOffset.dx,
      'shadowOffsetDy': shadowOffset.dy,
      'rotation': rotation,
    };
  }

  // Create from map when loading
  factory TextItem.fromJson(Map<String, dynamic> json) {
    return TextItem(
      text: json['text'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      fontSize: json['fontSize'].toDouble(),
      fontWeight: FontWeight.values[json['fontWeight']],
      fontStyle: FontStyle.values[json['fontStyle']],
      color: Color(json['color']),
      fontFamily: json['fontFamily'],
      isUnderlined: json['isUnderlined'] ?? false,
      textAlign: TextAlign.values[json['textAlign'] ?? 0],
      isHighlighted: json['isHighlighted'] ?? false,
      highlightColor:
          json['highlightColor'] != null ? Color(json['highlightColor']) : null,
      hasShadow: json['hasShadow'] ?? false,
      shadowColor: json['shadowColor'] != null
          ? Color(json['shadowColor'])
          : Colors.black,
      shadowBlurRadius: json['shadowBlurRadius']?.toDouble() ?? 4.0,
      shadowOffset:
          json['shadowOffsetDx'] != null && json['shadowOffsetDy'] != null
              ? Offset(json['shadowOffsetDx'].toDouble(),
                  json['shadowOffsetDy'].toDouble())
              : const Offset(2.0, 2.0),
      rotation: json['rotation']?.toDouble() ?? 0.0,
    );
  }
}
