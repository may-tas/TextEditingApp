import 'package:celebrare_assignment/cubit/canvas_state.dart';
import 'package:celebrare_assignment/models/text_item_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CanvasCubit extends Cubit<CanvasState> {
  CanvasCubit() : super(CanvasState.initial());

  void addText(String text) {
    final newTextItem = TextItem(
      text: text,
      x: 50,
      y: 50,
      fontSize: 16,
      fontFamily: 'Arial',
    );
    _updateState(textItems: [...state.textItems, newTextItem]);
  }

  void editText(int index, String newText) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(text: newText);
    _updateState(textItems: updatedItems);
  }

  void moveText(int index, double x, double y) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(x: x, y: y);
    _updateState(textItems: updatedItems);
  }

  void changeFontSize(int index, double fontSize) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontSize: fontSize);
    _updateState(textItems: updatedItems);
  }

  void changeFontStyle(int index, String fontFamily) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontFamily: fontFamily);
    _updateState(textItems: updatedItems);
  }

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

  void deleteText(int index) {
    final updatedItems = List<TextItem>.from(state.textItems)..removeAt(index);
    _updateState(textItems: updatedItems);
  }

  void clearCanvas() {
    _updateState(textItems: []);
  }

  void _updateState({required List<TextItem> textItems}) {
    final newState = state.copyWith(
      textItems: textItems,
      history: [...state.history, state],
      future: [], // Clear the redo stack when making new changes
    );
    emit(newState);
  }
}
