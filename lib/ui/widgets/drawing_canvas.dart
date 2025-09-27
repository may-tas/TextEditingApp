import 'package:flutter/material.dart';
import '../../models/draw_model.dart';
import '../../constants/color_constants.dart';
import 'drawing/drawing_painter.dart';
import 'drawing/drawing_tools_panel.dart';

class DrawingCanvas extends StatefulWidget {
  final List<DrawPath> paths;
  final bool isDrawingMode;
  final Color currentDrawColor;
  final double currentStrokeWidth;
  final Function(Offset) onStartDrawing;
  final Function(Offset) onUpdateDrawing;
  final Function() onEndDrawing;
  final Function(Color) onColorChanged;
  final Function(double) onStrokeWidthChanged;
  final Function() onUndoDrawing;
  final Function() onClearDrawing;

  const DrawingCanvas({
    super.key,
    required this.paths,
    required this.isDrawingMode,
    required this.currentDrawColor,
    required this.currentStrokeWidth,
    required this.onStartDrawing,
    required this.onUpdateDrawing,
    required this.onEndDrawing,
    required this.onColorChanged,
    required this.onStrokeWidthChanged,
    required this.onUndoDrawing,
    required this.onClearDrawing,
  });

  @override
  State<DrawingCanvas> createState() => _DrawingCanvasState();
}

class _DrawingCanvasState extends State<DrawingCanvas> {
  // Position for the draggable toolbar
  Offset _toolbarPosition = Offset(16, 100);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main Drawing Canvas
        IgnorePointer(
          ignoring: !widget.isDrawingMode,
          child: GestureDetector(
            onPanStart: (details) {
              if (widget.isDrawingMode) {
                widget.onStartDrawing(details.localPosition);
              }
            },
            onPanUpdate: (details) {
              if (widget.isDrawingMode) {
                widget.onUpdateDrawing(details.localPosition);
              }
            },
            onPanEnd: (_) {
              if (widget.isDrawingMode) {
                widget.onEndDrawing();
              }
            },
            child: RepaintBoundary(
              child: CustomPaint(
                painter: DrawingPainter(paths: widget.paths),
                size: Size.infinite,
              ),
            ),
          ),
        ),

        // Drawing Tools Panel (only visible in drawing mode)
        if (widget.isDrawingMode)
          Positioned(
            left: _toolbarPosition.dx,
            top: _toolbarPosition.dy,
            child: IgnorePointer(
              ignoring: false, // Always accept pointer events for the toolbar
              child: Material(
                color: ColorConstants.transparent,
                child: LongPressDraggable<String>(
                  data: "toolbarDrag",
                  delay: Duration(
                      milliseconds:
                          500), // Require long press to start dragging
                  feedback: Material(
                    color: ColorConstants.transparent,
                    elevation: 8.0,
                    child: Opacity(
                      opacity: 0.85,
                      child: DrawingToolsPanel(
                        currentColor: widget.currentDrawColor,
                        currentStrokeWidth: widget.currentStrokeWidth,
                        onColorChanged: (_) {}, // No-op in feedback
                        onStrokeWidthChanged: (_) {}, // No-op in feedback
                      ),
                    ),
                  ),
                  childWhenDragging: const SizedBox.shrink(),
                  onDragEnd: (details) {
                    // Calculate new position
                    final RenderBox renderBox =
                        context.findRenderObject() as RenderBox;
                    final Offset localPosition =
                        renderBox.globalToLocal(details.offset);

                    final screenSize = MediaQuery.of(context).size;
                    double newX = localPosition.dx;
                    double newY = localPosition.dy;

                    // Keep toolbar on screen
                    if (newX < 0) newX = 0;
                    if (newX > screenSize.width - 100) {
                      newX = screenSize.width - 100;
                    }
                    if (newY < 0) newY = 0;
                    if (newY > screenSize.height - 300) {
                      newY = screenSize.height - 300;
                    }

                    setState(() {
                      _toolbarPosition = Offset(newX, newY);
                    });
                  },
                  child: DrawingToolsPanel(
                    currentColor: widget.currentDrawColor,
                    currentStrokeWidth: widget.currentStrokeWidth,
                    onColorChanged: widget.onColorChanged,
                    onStrokeWidthChanged: widget.onStrokeWidthChanged,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
