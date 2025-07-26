// lib/cubit/canvas_state.dart
import '../models/text_item_model.dart';

class CanvasState {
  final List<TextItem> textItems;
  final List<CanvasState> history;
  final List<CanvasState> future;
  final int?
      selectedIndex; // <--- ADDED: To track the currently selected text item's index

  const CanvasState({
    required this.textItems,
    required this.history,
    required this.future,
    this.selectedIndex, // <--- ADDED: Constructor parameter
  });

  factory CanvasState.initial() {
    return const CanvasState(
      textItems: [],
      history: [],
      future: [],
      selectedIndex: null, // <--- INITIALIZED: No item selected initially
    );
  }

  CanvasState copyWith({
    List<TextItem>? textItems,
    List<CanvasState>? history,
    List<CanvasState>? future,
    int? selectedIndex, // <--- ADDED: copyWith parameter
  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      history: history ?? this.history,
      future: future ?? this.future,
      selectedIndex: selectedIndex, // <--- USED: Update the selectedIndex
    );
  }
}
