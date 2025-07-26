// lib/cubit/canvas_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/text_item_model.dart';
import 'canvas_state.dart';

class CanvasCubit extends Cubit<CanvasState> {
  CanvasCubit() : super(CanvasState.initial());

  /// NEW METHOD: Sets the index of the currently selected text item.
  /// Pass `null` to deselect any item.
  void selectTextItem(int? index) {
    // Only emit if the selection actually changes to avoid unnecessary rebuilds
    if (index != state.selectedIndex) {
      emit(state.copyWith(selectedIndex: index));
    }
  }

  /// Helper to safely get the index of the selected item.
  /// Returns null if no item is selected or if the index is out of bounds.
  int? _getEffectiveSelectedIndex() {
    final index = state.selectedIndex;
    if (index != null && index >= 0 && index < state.textItems.length) {
      return index;
    }
    return null; // No valid item selected
  }

  // METHOD MODIFIED: Adds text and automatically selects the newly added item.
  void addText(String text) {
    final newTextItem = TextItem(
      text: text,
      x: 50,
      y: 50,
      fontSize: 16,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal,
      fontFamily: 'Arial',
      color: Colors.white, // My Default color for the text
    );
    final updatedTextItems = [...state.textItems, newTextItem];
    _updateState(
      textItems: updatedTextItems,
      selectedIndex: updatedTextItems.length - 1, // Select the newly added item
    );
  }

  // METHOD MODIFIED: Uses the internally tracked selectedIndex.
  void changeTextColor(Color color) {
    // Removed index parameter
    final index = _getEffectiveSelectedIndex();
    if (index == null) return; // Do nothing if no item is selected

    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(color: color);
    _updateState(textItems: updatedItems);
  }

  // NOTE: editText still takes an index because it's called from EditableTextWidget's
  // dialog, which knows its own index. This is fine.
  void editText(int index, String newText) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(text: newText);
    _updateState(textItems: updatedItems);
  }

  // NOTE: moveText still takes an index, likely from drag/drop events. This is fine.
  void moveText(int index, double x, double y) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(x: x, y: y);
    _updateState(textItems: updatedItems);
  }

  // METHOD MODIFIED: Uses the internally tracked selectedIndex.
  void changeFontSize(double fontSize) {
    // Removed index parameter
    final index = _getEffectiveSelectedIndex();
    if (index == null) return;

    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontSize: fontSize);
    _updateState(textItems: updatedItems);
  }

  // METHOD MODIFIED: Uses the internally tracked selectedIndex.
  void changeFontFamily(String fontFamily) {
    // Removed index parameter
    final index = _getEffectiveSelectedIndex();
    if (index == null) return;

    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontFamily: fontFamily);
    _updateState(textItems: updatedItems);
  }

  // METHOD MODIFIED: Uses the internally tracked selectedIndex.
  void changeFontStyle(FontStyle fontStyle) {
    // Removed index parameter
    final index = _getEffectiveSelectedIndex();
    if (index == null) return;

    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontStyle: fontStyle);
    _updateState(textItems: updatedItems);
  }

  // METHOD MODIFIED: Uses the internally tracked selectedIndex.
  void changeFontWeight(FontWeight fontWeight) {
    // Removed index parameter
    final index = _getEffectiveSelectedIndex();
    if (index == null) return;

    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontWeight: fontWeight);
    _updateState(textItems: updatedItems);
  }

  // METHOD MODIFIED: When deleting, unselect if the deleted item was selected
  // and adjust selectedIndex for subsequent items if needed.
  void deleteText(int index) {
    final updatedList = List<TextItem>.from(state.textItems)..removeAt(index);
    int? newSelectedIndex = state.selectedIndex;

    if (newSelectedIndex != null) {
      if (newSelectedIndex == index) {
        // If the deleted item was the selected one
        newSelectedIndex = null; // Deselect it
      } else if (newSelectedIndex > index) {
        // If the selected item was after the deleted one
        newSelectedIndex--; // Adjust its index
      }
    }
    _updateState(
      textItems: updatedList,
      selectedIndex: newSelectedIndex,
    );
  }

  // METHOD MODIFIED: When clearing, deselect everything.
  void clearCanvas() {
    _updateState(textItems: [], selectedIndex: null);
  }

  // MODIFIED: _updateState now accepts and uses selectedIndex.
  void _updateState({
    required List<TextItem> textItems,
    int? selectedIndex, // Made optional and nullable for flexibilty
  }) {
    // If selectedIndex is not explicitly provided, maintain the existing one.
    // This is important for undo/redo or other operations that don't change selection.
    final effectiveSelectedIndex = selectedIndex ?? state.selectedIndex;

    final newState = state.copyWith(
      textItems: textItems,
      history: [...state.history, state],
      future: [],
      selectedIndex:
          effectiveSelectedIndex, // Pass effective selectedIndex here
    );
    emit(newState);
  }

  // No changes needed for undo/redo regarding selection handling as of now,
  // as the full state (including selectedIndex) is saved/restored.
  void undo() {
    if (state.history.isNotEmpty) {
      final previousState = state.history.last;
      final newHistory = List<CanvasState>.from(state.history)..removeLast();

      emit(previousState.copyWith(
        history: newHistory,
        future: [state, ...state.future],
      ));
    }
  }

  void redo() {
    if (state.future.isNotEmpty) {
      final nextState = state.future.first;
      final newFuture = List<CanvasState>.from(state.future)..removeAt(0);

      emit(nextState.copyWith(
        future: newFuture,
        history: [...state.history, state],
      ));
    }
  }
}
