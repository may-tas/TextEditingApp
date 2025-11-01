import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../cubit/canvas_state.dart';
import '../../models/draw_model.dart';

class CanvasThumbnail extends StatefulWidget {
  final CanvasState state;
  final double width;
  final double height;
  final Function(ui.Image?)? onThumbnailGenerated;

  const CanvasThumbnail({
    super.key,
    required this.state,
    this.width = 120,
    this.height = 80,
    this.onThumbnailGenerated,
  });

  @override
  State<CanvasThumbnail> createState() => _CanvasThumbnailState();
}

class _CanvasThumbnailState extends State<CanvasThumbnail> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Generate thumbnail after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateThumbnail();
    });
  }

  @override
  void didUpdateWidget(CanvasThumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      // Regenerate thumbnail when state changes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _generateThumbnail();
      });
    }
  }

  Future<void> _generateThumbnail() async {
    try {
      final RenderRepaintBoundary boundary = _repaintBoundaryKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 0.5);
      widget.onThumbnailGenerated?.call(image);
    } catch (e) {
      // If thumbnail generation fails, call with null
      widget.onThumbnailGenerated?.call(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _repaintBoundaryKey,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.state.backgroundColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              // Background image if exists
              if (widget.state.backgroundImagePath != null)
                Positioned.fill(
                  child: Image.asset(
                    widget.state.backgroundImagePath!,
                    fit: BoxFit.cover,
                  ),
                ),

              // Drawing paths
              if (widget.state.drawPaths.isNotEmpty)
                Positioned.fill(
                  child: CustomPaint(
                    painter: DrawingCanvasPainter(
                      drawPaths: widget.state.drawPaths,
                      isThumbnail: true,
                    ),
                  ),
                ),

              // Text items (simplified for thumbnail)
              ...widget.state.textItems.map((textItem) {
                final scaleX = widget.width / (MediaQuery.of(context).size.width);
                final scaleY = widget.height / (MediaQuery.of(context).size.height);
                return Positioned(
                  left: textItem.x * scaleX,
                  top: textItem.y * scaleY,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: widget.width * 0.8,
                      maxHeight: widget.height * 0.8,
                    ),
                    child: Text(
                      textItem.text,
                      style: TextStyle(
                        color: textItem.color,
                        fontSize: (textItem.fontSize * 0.3).clamp(8.0, 20.0),
                        fontWeight: textItem.fontWeight,
                        fontStyle: textItem.fontStyle,
                        fontFamily: textItem.fontFamily,
                        decoration: textItem.isUnderlined ? TextDecoration.underline : null,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// Simplified painter for thumbnails
class DrawingCanvasPainter extends CustomPainter {
  final List<DrawPath> drawPaths;
  final bool isThumbnail;

  DrawingCanvasPainter({
    required this.drawPaths,
    this.isThumbnail = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final path in drawPaths) {
      final paint = Paint()
        ..color = path.color
        ..strokeWidth = isThumbnail ? path.strokeWidth * 0.5 : path.strokeWidth
        ..strokeCap = path.strokeCap
        ..strokeJoin = StrokeJoin.round
        ..style = path.isFill ? PaintingStyle.fill : PaintingStyle.stroke;

      final pathObj = Path();
      if (path.points.isNotEmpty) {
        pathObj.moveTo(path.points[0].offset.dx, path.points[0].offset.dy);
        for (int i = 1; i < path.points.length; i++) {
          pathObj.lineTo(path.points[i].offset.dx, path.points[i].offset.dy);
        }
      }

      canvas.drawPath(pathObj, paint);
    }
  }

  @override
  bool shouldRepaint(DrawingCanvasPainter oldDelegate) {
    return oldDelegate.drawPaths != drawPaths;
  }
}