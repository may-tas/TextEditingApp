class TextItem {
  final String text;
  final double x;
  final double y;
  final double fontSize;
  final String fontFamily;

  TextItem({
    required this.text,
    required this.x,
    required this.y,
    required this.fontSize,
    required this.fontFamily,
  });

  TextItem copyWith({
    String? text,
    double? x,
    double? y,
    double? fontSize,
    String? fontFamily,
  }) {
    return TextItem(
      text: text ?? this.text,
      x: x ?? this.x,
      y: y ?? this.y,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
    );
  }

  // Convert TextItem to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'x': x,
      'y': y,
      'fontSize': fontSize,
      'fontFamily': fontFamily,
    };
  }

  // Create TextItem from a JSON map
  factory TextItem.fromJson(Map<String, dynamic> json) {
    return TextItem(
      text: json['text'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      fontSize: (json['fontSize'] as num).toDouble(),
      fontFamily: json['fontFamily'] as String,
    );
  }
}
