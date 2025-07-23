// lib/cubit/canvas_cubit.dart
import 'package:celebrare_assignment/cubit/canvas_state.dart';
import 'package:celebrare_assignment/models/text_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CanvasCubit extends Cubit<CanvasState> {
  CanvasCubit() : super(CanvasState.initial());

  // Method to select a text item by its ID
  void selectTextItem(String? id) {
    // Only update if the selection is new or unselecting
    if (state.selectedTextItemId != id) {
      _updateState(
        textItems: state.textItems, // Keep textItems the same
        selectedTextItemId: id,     // Update the selected ID
      );
    }
  }

  // method to add the text and automatically select it
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
    _updateState(
      textItems: [...state.textItems, newTextItem],
      selectedTextItemId: newTextItem.id, // Select the newly added item
    );
  }

  // Generic method to update the currently selected text item's properties
  // All specific update methods (like changeFontSize) will call this.
  void _updateSelectedTextItem({
    String? text,
    Color? color,
    double? x,
    double? y,
    double? fontSize,
    String? fontFamily,
    FontStyle? fontStyle,
    FontWeight? fontWeight,
  }) {
    // If no item is selected, or if the list of items is empty, do nothing
    if (state.selectedTextItemId == null || state.textItems.isEmpty) {
      return;
    }

    final updatedItems = state.textItems.map((item) {
      if (item.id == state.selectedTextItemId) {
        // Found the selected item, apply updates
        return item.copyWith(
          text: text,
          color: color,
          x: x,
          y: y,
          fontSize: fontSize,
          fontFamily: fontFamily,
          fontStyle: fontStyle,
          fontWeight: fontWeight,
        );
      }
      return item; // Return other items as they are
    }).toList(); // Convert back to a new list to ensure immutability

    _updateState(textItems: updatedItems);
  }

  // --- Updated methods to use _updateSelectedTextItem (removed 'index' parameter) ---

  // method to change and emit new TextColor
  void changeTextColor(Color color) {
    _updateSelectedTextItem(color: color);
  }

  // method to editText and emit changes
  void editText(String newText) {
    _updateSelectedTextItem(text: newText);
  }

  // method to moveText and emit changes
  // Note: If 'moveText' is primarily triggered by a drag gesture *before* an explicit select,
  // you might need to ensure 'selectTextItem' is called on drag start, or pass the ID of the dragged item directly here.
  void moveText(double x, double y) {
    _updateSelectedTextItem(x: x, y: y);
  }

  // method to change and emit new fontSize
  void changeFontSize(double fontSize) {
    _updateSelectedTextItem(fontSize: fontSize);
  }

  // method to change and emit new fontFamily
  void changeFontFamily(String fontFamily) {
    _updateSelectedTextItem(fontFamily: fontFamily);
  }

  // method to change and emit new fontStyle
  void changeFontStyle(FontStyle fontStyle) {
    _updateSelectedTextItem(fontStyle: fontStyle);
  }

  // method to change and emit new fontWeight
  void changeFontWeight(FontWeight fontWeight) {
    _updateSelectedTextItem(fontWeight: fontWeight);
  }

  // --- Undo/Redo/Clear methods (no changes needed for ID logic here) ---

  // method to undo changes and emit it
  void undo() {
    if (state.history.isNotEmpty) {
      final previousState = state.history.last;
      final newHistory = List<CanvasState>.from(state.history)..removeLast();

      // Emit the previous state, ensuring history and future are also updated
      emit(previousState.copyWith(
        history: newHistory,
        future: [state, ...state.future],
        // selectedTextItemId from previousState will be restored automatically
      ));
    }
  }

  // method to redo changes and emit it
  void redo() {
    if (state.future.isNotEmpty) {
      final nextState = state.future.first;
      final newFuture = List<CanvasState>.from(state.future)..removeAt(0);

      // Emit the next state, ensuring history and future are also updated
      emit(nextState.copyWith(
        future: newFuture,
        history: [...state.history, state],
        // selectedTextItemId from nextState will be applied automatically
      ));
    }
  }

  // method to empty the canvas
  void clearCanvas() {
    _updateState(
      textItems: [],
      selectedTextItemId: null, // Clear selection when canvas is cleared
    );
  }

  // update state with this (now accepts selectedTextItemId as an optional parameter)
  void _updateState({
    required List<TextItem> textItems,
    String? selectedTextItemId, // New optional parameter
  }) {
    final newState = state.copyWith(
      textItems: textItems,
      history: [...state.history, state], // Add current state to history before emitting new state
      future: [], // Clear future on any new action
      selectedTextItemId: selectedTextItemId, // Set the selected ID (can be null for unselect)
    );
    emit(newState);
  }
}
