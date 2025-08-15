import 'package:flutter/material.dart';
import '../models/text_item_model.dart';

class CanvasState {
  final List<TextItem> textItems;
  final List<CanvasState> history;
  final List<CanvasState> future;
  final Color backgroundColor;
  final int? selectedTextItemIndex;
  final bool isTrayShown;
  final String? message; // Added message field for save/load feedback
  final String? currentPageName;

  const CanvasState({
    required this.textItems,
    required this.history,
    required this.future,
    this.backgroundColor = const Color(0xFF1A1A1A), // Default dark background
    this.selectedTextItemIndex,
    this.isTrayShown = false,
    this.message, // Optional message field
    this.currentPageName,
  });

  factory CanvasState.initial() {
    return const CanvasState(
      textItems: [],
      history: [],
      future: [],
      backgroundColor: Color(0xFF1A1A1A), // Default dark background
      selectedTextItemIndex: null,
      isTrayShown: false,
      message: null,
      currentPageName: null,
    );
  }

  CanvasState copyWith({
    List<TextItem>? textItems,
    List<CanvasState>? history,
    List<CanvasState>? future,
    Color? backgroundColor,
    int? selectedTextItemIndex,
    bool deselect = false,
    bool? isTrayShown,
    String? message,
    String? currentPageName,
    bool clearCurrentPageName = false,
  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      history: history ?? this.history,
      future: future ?? this.future,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedTextItemIndex: deselect ? null : (selectedTextItemIndex ?? this.selectedTextItemIndex),
      isTrayShown: deselect ? false : (isTrayShown ?? this.isTrayShown),
      message: message, // Allow message to be set to null explicitly
      currentPageName: clearCurrentPageName ? null : (currentPageName ?? this.currentPageName),
    );
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CanvasState &&
              runtimeType == other.runtimeType &&
              textItems == other.textItems &&
              backgroundColor == other.backgroundColor &&
              selectedTextItemIndex == other.selectedTextItemIndex &&
              history == other.history &&
              future == other.future &&
              isTrayShown == other.isTrayShown &&
              message == other.message &&
              currentPageName == other.currentPageName;

  int get hashCode =>
      textItems.hashCode ^
      backgroundColor.hashCode ^
      selectedTextItemIndex.hashCode ^
      history.hashCode ^
      future.hashCode ^
      isTrayShown.hashCode ^
      message.hashCode ^
      currentPageName.hashCode;
}