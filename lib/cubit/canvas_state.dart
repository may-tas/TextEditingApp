import 'package:flutter/material.dart';
import '../models/text_item_model.dart';

class CanvasState {
  final List<TextItem> textItems;
  final List<CanvasState> history;
  final List<CanvasState> future;
  final Color backgroundColor;
  final int? selectedTextItemIndex;
  final bool isTrayShown;
  final String? message; // save/load feedback
  final String? currentPageName;

  // 🔹 New fields for background image
  final String? backgroundImagePath;
  final BoxFit backgroundFit;
  final double backgroundOpacity;
  final double backgroundBlur;

  const CanvasState({
    required this.textItems,
    required this.history,
    required this.future,
    this.backgroundColor = const Color(0xFF1A1A1A),
    this.selectedTextItemIndex,
    this.isTrayShown = false,
    this.message,
    this.currentPageName,

    // 🔹 Defaults for new fields
    this.backgroundImagePath,
    this.backgroundFit = BoxFit.cover,
    this.backgroundOpacity = 1.0,
    this.backgroundBlur = 0.0,
  });

  factory CanvasState.initial() {
    return const CanvasState(
      textItems: [],
      history: [],
      future: [],
      backgroundColor: Color(0xFF1A1A1A),
      selectedTextItemIndex: null,
      isTrayShown: false,
      message: null,
      currentPageName: null,

      // 🔹 Defaults for background image
      backgroundImagePath: null,
      backgroundFit: BoxFit.cover,
      backgroundOpacity: 1.0,
      backgroundBlur: 0.0,
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

    // 🔹 New
    String? backgroundImagePath,
    BoxFit? backgroundFit,
    double? backgroundOpacity,
    double? backgroundBlur,
  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      history: history ?? this.history,
      future: future ?? this.future,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      selectedTextItemIndex: deselect
          ? null
          : (selectedTextItemIndex ?? this.selectedTextItemIndex),
      isTrayShown: deselect ? false : (isTrayShown ?? this.isTrayShown),
      message: message,
      currentPageName:
          clearCurrentPageName ? null : (currentPageName ?? this.currentPageName),

      // 🔹 Copy new fields
      backgroundImagePath: backgroundImagePath ?? this.backgroundImagePath,
      backgroundFit: backgroundFit ?? this.backgroundFit,
      backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
      backgroundBlur: backgroundBlur ?? this.backgroundBlur,
    );
  }

  @override
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
          currentPageName == other.currentPageName &&
          backgroundImagePath == other.backgroundImagePath &&
          backgroundFit == other.backgroundFit &&
          backgroundOpacity == other.backgroundOpacity &&
          backgroundBlur == other.backgroundBlur;

  @override
  int get hashCode =>
      textItems.hashCode ^
      backgroundColor.hashCode ^
      selectedTextItemIndex.hashCode ^
      history.hashCode ^
      future.hashCode ^
      isTrayShown.hashCode ^
      message.hashCode ^
      currentPageName.hashCode ^
      backgroundImagePath.hashCode ^
      backgroundFit.hashCode ^
      backgroundOpacity.hashCode ^
      backgroundBlur.hashCode;
}
