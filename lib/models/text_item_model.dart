import 'dart:ui';

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
    );
  }
}
