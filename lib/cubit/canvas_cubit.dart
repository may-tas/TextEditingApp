import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/text_item_model.dart';
import 'canvas_state.dart';

class CanvasCubit extends Cubit<CanvasState> {
  CanvasCubit() : super(CanvasState.initial());

  //method to toggle the color tray
  void toggleTray(){
    emit(state.copyWith(isTrayShown: !state.isTrayShown));
  }
  //method to select text
  void selectText(int index) {
    if (index >= 0 && index < state.textItems.length) {
      emit(state.copyWith(selectedTextItemIndex: index));
    }
  }

  // method to deselect text
  void deselectText() {
    emit(state.copyWith(selectedTextItemIndex: null, deselect: true));
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
      fontFamily: 'Roboto',
      color: Colors.white, // My Default color for the text
    );
    final updatedItems = List<TextItem>.from(state.textItems)..add(newTextItem);
    emit(
      state.copyWith(
        textItems: updatedItems,
        selectedTextItemIndex: updatedItems.length - 1,
        history: [...state.history, state],
        future: [],
      ),
    );
  }

  // FIX: Reset all formatting
  void resetFormatting(int index) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(
      fontSize: 16,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal,
      fontFamily: 'Roboto',
      color: Colors.white, // Reset to default color
    );
    _updateState(textItems: updatedItems);
  }

  // method to change and emit new TextColor
  void changeTextColor(int index, Color color) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(color: color);
    _updateState(textItems: updatedItems);
  }

  // method to change background color
  void changeBackgroundColor(Color color) {
    _updateState(backgroundColor: color);
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
  void changeFontSize(int index, double fontSize) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontSize: fontSize);
    _updateState(textItems: updatedItems);
  }

  // method to change and emit new fontFamily
  void changeFontFamily(int index, String fontFamily) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontFamily: fontFamily);
    _updateState(textItems: updatedItems);
  }

  // method to change and emit new fontStyle
  void changeFontStyle(int index, FontStyle fontStyle) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontStyle: fontStyle);
    _updateState(textItems: updatedItems);
  }

  // method to change and emit new fontWeight
  void changeFontWeight(int index, FontWeight fontWeight) {
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
    emit(
      state.copyWith(
        textItems: [],
        history: [...state.history, state],
        future: [],
        selectedTextItemIndex: null,
        deselect: true,
      ),
    );
  }

  // update state with this
  void _updateState({
    List<TextItem>? textItems,
    Color? backgroundColor,
  }) {
    final newState = state.copyWith(
      textItems: textItems ?? state.textItems,
      backgroundColor: backgroundColor,
      history: [...state.history, state],
      future: [],
    );
    emit(newState);
  }

  void deleteText(int index) {
    final updatedList = List<TextItem>.from(state.textItems)..removeAt(index);
    emit(state.copyWith(
        textItems: updatedList,
        selectedTextItemIndex: null,
        history: [...state.history, state],
        future: [],
        deselect: true));
  }
}
