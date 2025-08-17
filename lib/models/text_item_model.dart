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
  final bool shadowEnabled;
  final double shadowOffsetX;
  final double shadowOffsetY;
  final double shadowBlur;
  final Color shadowColor;

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
    this.shadowEnabled = false,
    this.shadowOffsetX = 0,
    this.shadowOffsetY = 0,
    this.shadowBlur = 0,
    this.shadowColor = const Color(0xFF000000), // default black shadow
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
    bool? shadowEnabled,
    double? shadowOffsetX,
    double? shadowOffsetY,
    double? shadowBlur,
    Color? shadowColor,
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
      shadowEnabled: shadowEnabled ?? this.shadowEnabled,
      shadowOffsetX: shadowOffsetX ?? this.shadowOffsetX,
      shadowOffsetY: shadowOffsetY ?? this.shadowOffsetY,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  String toHTML() {
    final cssColor =
        "#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}";
    final cssFontWeight = fontWeight.value;
    final cssFontStyle = fontStyle == FontStyle.italic ? 'italic' : 'normal';
    final style =
        'font-size: ${fontSize}px; font-family: $fontFamily; color: $cssColor; font-weight: $cssFontWeight; font-style: $cssFontStyle;';
    return '<span style="$style">$text</span>';
  }
}
