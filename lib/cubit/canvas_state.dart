import 'package:flutter/material.dart';
import '../models/text_item_model.dart';

class CanvasState {
  final List<TextItem> textItems;
  final List<CanvasState> history;
  final List<CanvasState> future;
  final Color backgroundColor;
  final int? selectedTextItemIndex;
  final bool isTrayShown;
  final double canvasWidth;
  final double canvasHeight;

  const CanvasState({
    required this.textItems,
    required this.history,
    required this.future,
    this.backgroundColor = const Color(0xFF1A1A1A),
    this.selectedTextItemIndex,
    this.isTrayShown = false,
    required this.canvasWidth,
    required this.canvasHeight,
  });

  factory CanvasState.initial() {
    return const CanvasState(
      textItems: [],
      history: [],
      future: [],
      backgroundColor: Color(0xFF1A1A1A),
      selectedTextItemIndex: null,
      canvasWidth: 0,
      canvasHeight: 0,
    );
  }

  CanvasState copyWith({
    List<TextItem>? textItems,
    List<CanvasState>? history,
    List<CanvasState>? future,
    Color? backgroundColor,
    int? selectedTextItemIndex,
    bool deselect = false,
    bool? isTrayShown,
    double? canvasWidth,
    double? canvasHeight,
  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      history: history ?? this.history,
      future: future ?? this.future,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedTextItemIndex: deselect ? null : selectedTextItemIndex ?? this.selectedTextItemIndex,
      isTrayShown: deselect ? false : (isTrayShown ?? this.isTrayShown),
      canvasWidth: canvasWidth ?? this.canvasWidth,
      canvasHeight: canvasHeight ?? this.canvasHeight,
    );
  }
}