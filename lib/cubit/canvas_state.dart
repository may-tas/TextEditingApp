import 'package:flutter/material.dart';
import '../models/text_item_model.dart';

class CanvasState {
  final List<TextItem> textItems;
  final List<CanvasState> history;
  final List<CanvasState> future;
  final Color backgroundColor; // Added background color
  final int? selectedTextItemIndex;

  const CanvasState({
    required this.textItems,
    required this.history,
    required this.future,
    this.backgroundColor = const Color(0xFF1A1A1A), // Default value
    this.selectedTextItemIndex,
  });

  factory CanvasState.initial() {
    return const CanvasState(
      textItems: [], 
      history: [], 
      future: [],
      backgroundColor: Color(0xFF1A1A1A), // Default dark background
    , selectedTextItemIndex: null);
  }

  CanvasState copyWith({
    List<TextItem>? textItems,
    List<CanvasState>? history,
    List<CanvasState>? future,
    Color? backgroundColor,
    int? selectedTextItemIndex,
    bool deselect = false,
  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      history: history ?? this.history,
      future: future ?? this.future,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedTextItemIndex: deselect ? null : selectedTextItemIndex ?? this.selectedTextItemIndex,
    );
  }
}