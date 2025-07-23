// lib/cubit/canvas_state.dart
import 'package:celebrare_assignment/models/text_item_model.dart';
import 'package:flutter/material.dart'; // Add this import if Color, FontStyle etc. are used elsewhere in CanvasState

class CanvasState {
  final List<TextItem> textItems;
  final List<CanvasState> history;
  final List<CanvasState> future;
  final String? selectedTextItemId; // <--- NEW: ID of the currently selected item

  const CanvasState({
    required this.textItems,
    this.history = const [], // Initialize as empty list if not provided
    this.future = const [],   // Initialize as empty list if not provided
    this.selectedTextItemId,  // Initialize in constructor
  });

  factory CanvasState.initial() {
    return const CanvasState(
      textItems: [],
      history: [],
      future: [],
      selectedTextItemId: null, // <--- NEW: Initially no item is selected
    );
  }

  CanvasState copyWith({
    List<TextItem>? textItems,
    List<CanvasState>? history,
    List<CanvasState>? future,
    String? selectedTextItemId, // Allow copyWith to update selected item ID
  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      history: history ?? this.history,
      future: future ?? this.future,
      selectedTextItemId: selectedTextItemId, // <--- IMPORTANT: Do NOT use ?? this.selectedTextItemId here for selectedTextItemId
      // We want to be able to explicitly set selectedTextItemId to null (unselect)
      // if selectedTextItemId is passed as null to copyWith.
      // If selectedTextItemId is omitted (not passed), it will default to the current state's selectedTextItemId.
    );
  }
}
