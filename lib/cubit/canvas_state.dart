import '../models/text_item_model.dart';

class CanvasState {
  final List<TextItem> textItems;
  final List<CanvasState> history;
  final List<CanvasState> future;
  final int? selectedTextItemIndex;

  const CanvasState({
    required this.textItems,
    required this.history,
    required this.future,
    this.selectedTextItemIndex,
  });

  factory CanvasState.initial() {
    return const CanvasState(textItems: [], history: [], future: [], selectedTextItemIndex: null);
  }

  CanvasState copyWith({
    List<TextItem>? textItems,
    List<CanvasState>? history,
    List<CanvasState>? future,
    int? selectedTextItemIndex,
    bool deselect = false,
  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      history: history ?? this.history,
      future: future ?? this.future,
      selectedTextItemIndex: deselect ? null : selectedTextItemIndex ?? this.selectedTextItemIndex,
    );
  }
}
