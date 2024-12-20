import 'package:celebrare_assignment/models/text_item_model.dart';
import 'package:equatable/equatable.dart';

class CanvasState extends Equatable {
  final List<TextItem> textItems;
  final List<CanvasState> history;
  final List<CanvasState> future;

  const CanvasState({
    this.textItems = const [],
    this.history = const [],
    this.future = const [],
  });

  CanvasState copyWith({
    List<TextItem>? textItems,
    List<CanvasState>? history,
    List<CanvasState>? future,
  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      history: history ?? this.history,
      future: future ?? this.future,
    );
  }

  @override
  List<Object?> get props => [textItems, history, future];
}
