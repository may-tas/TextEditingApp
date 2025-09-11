import 'package:flutter/material.dart';
import '../models/text_item_model.dart';

class CanvasState {
  final List<TextItem> textItems;
  final List<CanvasState> history;
  final List<CanvasState> future;
  final Color backgroundColor;
  final String? backgroundImagePath; 
  final int? selectedTextItemIndex;
  final bool isTrayShown;
  final String? message;
  final String? currentPageName;

  const CanvasState({
    required this.textItems,
    required this.history,
    required this.future,
    this.backgroundColor = const Color(0xFF1A1A1A),
    this.backgroundImagePath, 
    this.selectedTextItemIndex,
    this.isTrayShown = false,
    this.message,
    this.currentPageName,
  });

  factory CanvasState.initial() {
    return const CanvasState(
      textItems: [],
      history: [],
      future: [],
      backgroundColor: Color(0xFF1A1A1A),
      backgroundImagePath: null,
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
    String? backgroundImagePath,
    bool clearBackgroundImage = false,
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
      backgroundImagePath: clearBackgroundImage 
          ? null 
          : (backgroundImagePath ?? this.backgroundImagePath),
      selectedTextItemIndex: deselect ? null : (selectedTextItemIndex ?? this.selectedTextItemIndex),
      isTrayShown: deselect ? false : (isTrayShown ?? this.isTrayShown),
      message: message ?? this.message,
      currentPageName: clearCurrentPageName ? null : (currentPageName ?? this.currentPageName),
    );
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
          other is CanvasState &&
              runtimeType == other.runtimeType &&
              textItems == other.textItems &&
              backgroundColor == other.backgroundColor &&
              backgroundImagePath == other.backgroundImagePath &&
              selectedTextItemIndex == other.selectedTextItemIndex &&
              history == other.history &&
              future == other.future &&
              isTrayShown == other.isTrayShown &&
              message == other.message &&
              currentPageName == other.currentPageName;

  int get hashCode =>
      textItems.hashCode ^
      backgroundColor.hashCode ^
      backgroundImagePath.hashCode ^
      selectedTextItemIndex.hashCode ^
      history.hashCode ^
      future.hashCode ^
      isTrayShown.hashCode ^
      message.hashCode ^
      currentPageName.hashCode;
}