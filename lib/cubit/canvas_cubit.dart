// lib/cubit/canvas_cubit.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/text_item_model.dart';
import 'canvas_state.dart';

class CanvasCubit extends Cubit<CanvasState> {
  CanvasCubit() : super(CanvasState.initial());

  void selectTextItem(int? index) {
    if (index != state.selectedIndex) {
      emit(state.copyWith(selectedIndex: index));
    }
  }

  int? _getEffectiveSelectedIndex() {
    final index = state.selectedIndex;
    if (index != null && index >= 0 && index < state.textItems.length) {
      return index;
    }
    return null;
  }

  // method to add the text
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
      selectedIndex: updatedTextItems.length - 1,
    );
  }

  // method to change and emit new TextColor
  void changeTextColor(Color color) {
    final index = _getEffectiveSelectedIndex();
    if (index == null) return;

    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(color: color);
    _updateState(textItems: updatedItems);
  }

  // method to editText and emit changes
  void editText(int index, String newText) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(text: newText);
    _updateState(textItems: updatedItems);
  }

  // method to moveText and emit changes
  void moveText(int index, double x, double y) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(x: x, y: y);
    _updateState(textItems: updatedItems);
  }

  // method to change and emit new fontSize
  void changeFontSize(double fontSize) {
    final index = _getEffectiveSelectedIndex();
    if (index == null) return;

    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontSize: fontSize);
    _updateState(textItems: updatedItems);
  }

  // method to change and emit new fontFamily
  void changeFontFamily(String fontFamily) {
    final index = _getEffectiveSelectedIndex();
    if (index == null) return;

    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontFamily: fontFamily);
    _updateState(textItems: updatedItems);
  }

  // method to change and emit new fontStyle
  void changeFontStyle(FontStyle fontStyle) {
    final index = _getEffectiveSelectedIndex();
    if (index == null) return;

    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontStyle: fontStyle);
    _updateState(textItems: updatedItems);
  }

  // method to change and emit new fontWeight
  void changeFontWeight(FontWeight fontWeight) {
    final index = _getEffectiveSelectedIndex();
    if (index == null) return;

    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontWeight: fontWeight);
    _updateState(textItems: updatedItems);
  }

  // method to undo changes and emit it
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

  // method to redo changes and emit it
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

  // method to empty the canvas
  void clearCanvas() {
    _updateState(textItems: [], selectedIndex: null);
  }

  // update state with this
  void _updateState({
    required List<TextItem> textItems,
    int? selectedIndex,
  }) {
    final effectiveSelectedIndex = selectedIndex ?? state.selectedIndex;

    final newState = state.copyWith(
      textItems: textItems,
      history: [...state.history, state],
      future: [],
      selectedIndex: effectiveSelectedIndex,
    );
    emit(newState);
  }

  void deleteText(int index) {
    final updatedList = List<TextItem>.from(state.textItems)..removeAt(index);
    int? newSelectedIndex = state.selectedIndex;

    if (newSelectedIndex != null) {
      if (newSelectedIndex == index) {
        newSelectedIndex = null;
      } else if (newSelectedIndex > index) {
        newSelectedIndex--;
      }
    }
    _updateState(
      textItems: updatedList,
      selectedIndex: newSelectedIndex,
    );
  }
}
