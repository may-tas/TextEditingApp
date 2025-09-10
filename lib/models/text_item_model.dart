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
  final bool isHighlighted;
  final Color? highlightColor;

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

    final style =
        'font-size: ${fontSize}px; font-family: $fontFamily; color: $cssColor; font-weight: $cssFontWeight; font-style: $cssFontStyle; $textDecoration$backgroundColor';
    return '<span style="$style">$text</span>';
  }
}
