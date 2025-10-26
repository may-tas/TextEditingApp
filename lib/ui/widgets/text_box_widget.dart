import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;

import '../../cubit/canvas_cubit.dart';
import '../../models/text_item_model.dart';
import '../../constants/color_constants.dart';

class TextBoxWidget extends StatefulWidget {
  final int index;
  final TextItem textItem;
  final bool isSelected;
  final ValueChanged<bool>? onRotationStateChanged;

  const TextBoxWidget({
    super.key,
    required this.index,
    required this.textItem,
    required this.isSelected,
    this.onRotationStateChanged,
  });

  @override
  State<TextBoxWidget> createState() => _TextBoxWidgetState();
}

class _TextBoxWidgetState extends State<TextBoxWidget> {
  late TextPainter _textPainter;
  bool _isRotating = false;
  double? _startRotation;
  Offset? _startPanPosition;

  @override
  void initState() {
    super.initState();
    _updateTextPainter();
  }

  @override
  void didUpdateWidget(TextBoxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textItem != widget.textItem) {
      _updateTextPainter();
    }
  }

  void _updateTextPainter() {
    _textPainter = TextPainter(
      text: TextSpan(
        text: widget.textItem.text,
        style: GoogleFonts.getFont(
          widget.textItem.fontFamily,
          fontStyle: widget.textItem.fontStyle,
          fontWeight: widget.textItem.fontWeight,
          fontSize: widget.textItem.fontSize,
          decoration: widget.textItem.isUnderlined
              ? TextDecoration.underline
              : TextDecoration.none,
          color: widget.textItem.color,
          backgroundColor: widget.textItem.isHighlighted &&
                  widget.textItem.highlightColor != null
              ? widget.textItem.highlightColor
              : null,
          shadows: widget.textItem.hasShadow
              ? [
                  Shadow(
                    color: widget.textItem.shadowColor,
                    offset: widget.textItem.shadowOffset,
                    blurRadius: widget.textItem.shadowBlurRadius,
                  ),
                ]
              : null,
        ),
      ),
      textAlign: widget.textItem.textAlign,
      textDirection: TextDirection.ltr,
    );
    _textPainter.layout();
  }

  double _calculateAngle(Offset center, Offset point) {
    return math.atan2(point.dy - center.dy, point.dx - center.dx);
  }

  @override
  Widget build(BuildContext context) {
    final textSize = _textPainter.size;
    final padding = 8.0;
    final boxWidth = textSize.width + (padding * 2);
    final boxHeight = textSize.height + (padding * 2);

    return GestureDetector(
      onTap: () async {
        context.read<CanvasCubit>().selectText(widget.index);

        // Open edit dialog
        final result = await showDialog<String>(
          context: context,
          builder: (context) =>
              _EditTextDialog(initialText: widget.textItem.text),
        );

        if (!context.mounted) return;
        if (result == '_delete_') {
          context.read<CanvasCubit>().deleteText(widget.index);
        } else if (result != null) {
          context.read<CanvasCubit>().editText(widget.index, result);
        }
      },
      child: Transform.rotate(
        angle: widget.textItem.rotation,
        alignment: Alignment.center,
        child: Container(
          width: boxWidth,
          height: boxHeight,
          decoration: BoxDecoration(
            border: widget.isSelected
                ? Border.all(
                    color: ColorConstants.dialogButtonBlue,
                    width: 2,
                  )
                : null,
            borderRadius: BorderRadius.circular(4),
            color: widget.isSelected
                ? ColorConstants.highlightYellow.withValues(alpha: 0.1)
                : Colors.transparent,
          ),
          child: Stack(
            children: [
              // Text content
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: CustomPaint(
                    painter: _TextPainter(
                      textPainter: _textPainter,
                    ),
                  ),
                ),
              ),

              // Rotation handle
              if (widget.isSelected)
                Positioned(
                  right: -12,
                  top: -12,
                  child: GestureDetector(
                    onPanStart: (details) {
                      setState(() => _isRotating = true);
                      _startRotation = widget.textItem.rotation;
                      final renderBox = context.findRenderObject() as RenderBox;
                      _startPanPosition =
                          renderBox.globalToLocal(details.globalPosition);
                      widget.onRotationStateChanged?.call(true);
                    },
                    onPanUpdate: (details) {
                      if (_isRotating &&
                          _startPanPosition != null &&
                          _startRotation != null) {
                        final renderBox =
                            context.findRenderObject() as RenderBox;
                        final center = Offset(boxWidth / 2, boxHeight / 2);
                        final currentPos =
                            renderBox.globalToLocal(details.globalPosition);

                        // Calculate the angle from center to start position
                        final startAngle =
                            _calculateAngle(center, _startPanPosition!);
                        // Calculate the angle from center to current position
                        final currentAngle =
                            _calculateAngle(center, currentPos);
                        // Calculate the delta rotation
                        final deltaRotation = currentAngle - startAngle;
                        // Apply the delta to the starting rotation
                        final newRotation = _startRotation! + deltaRotation;

                        context
                            .read<CanvasCubit>()
                            .rotateText(widget.index, newRotation);
                      }
                    },
                    onPanEnd: (details) {
                      if (_isRotating &&
                          _startPanPosition != null &&
                          _startRotation != null) {
                        final renderBox =
                            context.findRenderObject() as RenderBox;
                        final center = Offset(boxWidth / 2, boxHeight / 2);
                        final currentPos =
                            renderBox.globalToLocal(details.globalPosition);

                        // Calculate final rotation the same way as in onPanUpdate
                        final startAngle =
                            _calculateAngle(center, _startPanPosition!);
                        final currentAngle =
                            _calculateAngle(center, currentPos);
                        final deltaRotation = currentAngle - startAngle;
                        final newRotation = _startRotation! + deltaRotation;

                        context
                            .read<CanvasCubit>()
                            .rotateTextWithHistory(widget.index, newRotation);
                      }
                      setState(() => _isRotating = false);
                      _startPanPosition = null;
                      _startRotation = null;
                      widget.onRotationStateChanged?.call(false);
                    },
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: ColorConstants.dialogButtonBlue,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.refresh,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TextPainter extends CustomPainter {
  final TextPainter textPainter;

  _TextPainter({required this.textPainter});

  @override
  void paint(Canvas canvas, Size size) {
    textPainter.paint(canvas, Offset.zero);
  }

  @override
  bool shouldRepaint(_TextPainter oldDelegate) {
    return textPainter != oldDelegate.textPainter;
  }
}

class _EditTextDialog extends StatelessWidget {
  final String initialText;

  const _EditTextDialog({required this.initialText});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final controller = TextEditingController(text: initialText);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Edit Text',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: formKey,
              child: TextFormField(
                controller: controller,
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Text cannot be empty'
                    : null,
                decoration: InputDecoration(
                  labelText: 'Text',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                        color: ColorConstants.dialogPurple, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context, '_delete_'),
                  child: const Text(
                    'Remove',
                    style: TextStyle(color: ColorConstants.gray600),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final trimmedText = controller.text.trim();

                    if (trimmedText.isEmpty) {
                      formKey.currentState?.validate();
                    } else {
                      Navigator.pop(context, trimmedText);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        ColorConstants.dialogPurple.withValues(alpha: 0.2),
                    foregroundColor: ColorConstants.dialogPurple,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
