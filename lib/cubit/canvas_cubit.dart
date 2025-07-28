import 'package:celebrare_assignment/cubit/canvas_state.dart';
import 'package:celebrare_assignment/models/text_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CanvasCubit extends Cubit<CanvasState> {
  CanvasCubit() : super(CanvasState.initial());

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
    _updateState(textItems: [...state.textItems, newTextItem]);
  }

  // method to change and emit new TextColor
  void changeTextColor(int index, Color color) {
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
    _updateState(textItems: []);
  }

  // update state with this
  void _updateState({required List<TextItem> textItems}) {
    final newState = state.copyWith(
      textItems: textItems,
      history: [...state.history, state],
      future: [],
    );
    emit(newState);
  }

  void deleteText(int index) {
    final updatedList = List<TextItem>.from(state.textItems)..removeAt(index);
    emit(state.copyWith(textItems: updatedList));
  }
}
