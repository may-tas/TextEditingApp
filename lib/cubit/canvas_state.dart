import 'package:flutter/material.dart';
import '../models/text_item_model.dart';

class CanvasState {
  final List<TextItem> textItems;
  final List<CanvasState> history;
  final List<CanvasState> future;
  final Color backgroundColor;
  final bool isBackgroundColorTrayVisible; // Added this field
  final int? selectedTextItemIndex;

  const CanvasState({
    required this.textItems,
    required this.history,
    required this.future,
    this.backgroundColor = const Color(0xFF1A1A1A),
    this.isBackgroundColorTrayVisible = false, // Default hidden
    this.selectedTextItemIndex,
  });

  factory CanvasState.initial() {
    return const CanvasState(
      textItems: [],
      history: [],
      future: [],
      backgroundColor: Color(0xFF1A1A1A),
      isBackgroundColorTrayVisible: false,
      selectedTextItemIndex: null,
    );
  }

  CanvasState copyWith({
    List<TextItem>? textItems,
    List<CanvasState>? history,
    List<CanvasState>? future,
    Color? backgroundColor,
    bool? isBackgroundColorTrayVisible,
    int? selectedTextItemIndex,
    bool deselect = false,
  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      history: history ?? this.history,
      future: future ?? this.future,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      isBackgroundColorTrayVisible: isBackgroundColorTrayVisible ?? this.isBackgroundColorTrayVisible,
      selectedTextItemIndex: deselect ? null : selectedTextItemIndex ?? this.selectedTextItemIndex,
    );
  }
}