import 'package:flutter/material.dart';

// Painter for showing MS Paint style brush size preview
class BrushSizePreviewPainter extends CustomPainter {
  final Color color;
  final double minWidth;
  final double maxWidth;
  final double currentWidth;

  BrushSizePreviewPainter({
    required this.color,
    required this.minWidth,
    required this.maxWidth,
    required this.currentWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round;

    final double startY = size.height / 2;
    final double startX = 4;
    final double endX = size.width - 4;

    // Draw the horizontal line showing size progression
    final Path path = Path();
    path.moveTo(startX, startY);

    // Create a line from thin to thick
    for (double x = startX; x <= endX; x++) {
      final double progress = (x - startX) / (endX - startX);
      final double strokeWidth = minWidth + progress * (maxWidth - minWidth);

      paint.strokeWidth = strokeWidth;
      canvas.drawCircle(
        Offset(x, startY),
        strokeWidth / 2,
        paint,
      );
    }

    // Draw the current size indicator
    final double currentX = startX +
        ((currentWidth - minWidth) / (maxWidth - minWidth)) * (endX - startX);
    final Paint indicatorPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(
      Offset(currentX, startY),
      currentWidth / 2 + 3,
      indicatorPaint,
    );
  }

  @override
  bool shouldRepaint(covariant BrushSizePreviewPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.currentWidth != currentWidth;
  }
}
