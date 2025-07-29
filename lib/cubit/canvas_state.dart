import 'package:flutter/material.dart';
import '../models/text_item_model.dart';

class CanvasState {
  final List<TextItem> textItems;
  final List<CanvasState> history;
  final List<CanvasState> future;
  final Color backgroundColor; // Added background color

  const CanvasState({
    required this.textItems,
    required this.history,
    required this.future,
    this.backgroundColor = const Color(0xFF1A1A1A), // Default value
  });

  factory CanvasState.initial() {
    return const CanvasState(
      textItems: [], 
      history: [], 
      future: [],
      backgroundColor: Color(0xFF1A1A1A), // Default dark background
    );
  }

  CanvasState copyWith({
    List<TextItem>? textItems,
    List<CanvasState>? history,
    List<CanvasState>? future,
    Color? backgroundColor,
  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      history: history ?? this.history,
      future: future ?? this.future,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }
}