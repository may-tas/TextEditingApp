import 'package:celebrare_assignment/cubit/canvas_state.dart';
import 'package:celebrare_assignment/models/text_item_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CanvasCubit extends Cubit<CanvasState> {
  CanvasCubit() : super(const CanvasState());

  // Add a new text item to the canvas
  void addText(String text) {
    final newTextItem = TextItem(
      text: text,
      x: 50, // Default position
      y: 50,
      fontSize: 16,
      fontFamily: 'Arial',
    );

    _updateState(
      textItems: [...state.textItems, newTextItem],
    );
  }

  // Move an existing text item
  void moveText(int index, double x, double y) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(x: x, y: y);

    _updateState(textItems: updatedItems);
  }

  // Change font size or style of a text item
  void changeFont(int index, double fontSize, String fontFamily) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(
      fontSize: fontSize,
      fontFamily: fontFamily,
    );

    _updateState(textItems: updatedItems);
  }

  // Undo the last action
  void undo() {
    if (state.history.isNotEmpty) {
      final previousState = state.history.last;
      emit(
        previousState.copyWith(
          future: [state, ...state.future],
          history: state.history.sublist(0, state.history.length - 1),
        ),
      );
    }
  }

  // Redo the last undone action
  void redo() {
    if (state.future.isNotEmpty) {
      final nextState = state.future.first;
      emit(
        nextState.copyWith(
          history: [...state.history, state],
          future: state.future.sublist(1),
        ),
      );
    }
  }

  // Helper to manage undo/redo history
  void _updateState({required List<TextItem> textItems}) {
    emit(
      CanvasState(
        textItems: textItems,
        history: [...state.history, state],
        future: const [],
      ),
    );
  }
}
