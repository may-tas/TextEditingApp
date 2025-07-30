import '../models/text_item_model.dart';

class CanvasState {
  final List<TextItem> textItems;
  final List<CanvasState> history;
  final List<CanvasState> future;
  final int? selectedIndex;

  const CanvasState({
    required this.textItems,
    required this.history,
    required this.future,
    this.selectedIndex,
  });

  factory CanvasState.initial() {
    return const CanvasState(textItems: [], history: [], future: [], selectedIndex: null);
  }

  CanvasState copyWith({
    List<TextItem>? textItems,
    List<CanvasState>? history,
    List<CanvasState>? future,
    int? selectedIndex,
  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      history: history ?? this.history,
      future: future ?? this.future,
      selectedIndex: selectedIndex ?? this.selectedIndex,
    );
  }
}
