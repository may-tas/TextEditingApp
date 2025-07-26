import 'package:celebrare_assignment/models/text_item_model.dart';

class CanvasState {
  final List<TextItem> textItems;
  final List<CanvasState> history;
  final List<CanvasState> future;

  final int? selectedItemIndex; 


  const CanvasState({
    required this.textItems,
    required this.history,
    required this.future,

  });

  factory CanvasState.initial() {
    return const CanvasState(textItems: [], history: [], future: []);

    this.selectedItemIndex,
  });

  factory CanvasState.initial() {
    return const CanvasState(textItems: [], history: [], future: [], selectedItemIndex: null); 

  }

  CanvasState copyWith({
    List<TextItem>? textItems,
    List<CanvasState>? history,
    List<CanvasState>? future,

    int? selectedItemIndex, 

  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      history: history ?? this.history,
      future: future ?? this.future,

      selectedItemIndex: selectedItemIndex ?? this.selectedItemIndex, 

    );
  }
}
