import 'package:celebrare_assignment/models/text_item_model.dart';

class CanvasState {
  final List<TextItem> textItems;
  final List<CanvasState> history;
  final List<CanvasState> future;
<<<<<<< HEAD
=======
  final int? selectedItemIndex; 
>>>>>>> b06f4c7 (Text Size Change Applied to Newest Text Instead of Selected One)

  const CanvasState({
    required this.textItems,
    required this.history,
    required this.future,
<<<<<<< HEAD
  });

  factory CanvasState.initial() {
    return const CanvasState(textItems: [], history: [], future: []);
=======
    this.selectedItemIndex,
  });

  factory CanvasState.initial() {
    return const CanvasState(textItems: [], history: [], future: [], selectedItemIndex: null); 
>>>>>>> b06f4c7 (Text Size Change Applied to Newest Text Instead of Selected One)
  }

  CanvasState copyWith({
    List<TextItem>? textItems,
    List<CanvasState>? history,
    List<CanvasState>? future,
<<<<<<< HEAD
=======
    int? selectedItemIndex, 
>>>>>>> b06f4c7 (Text Size Change Applied to Newest Text Instead of Selected One)
  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      history: history ?? this.history,
      future: future ?? this.future,
<<<<<<< HEAD
=======
      selectedItemIndex: selectedItemIndex ?? this.selectedItemIndex, 
>>>>>>> b06f4c7 (Text Size Change Applied to Newest Text Instead of Selected One)
    );
  }
}
