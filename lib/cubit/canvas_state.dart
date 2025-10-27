import 'package:flutter/material.dart';
import '../models/text_item_model.dart';
import '../constants/color_constants.dart';
import '../models/draw_model.dart';
import '../models/history_entry.dart';

class CanvasState {
  final List<TextItem> textItems;
  final List<DrawPath> drawPaths;
  final List<HistoryEntry> history;
  final int currentHistoryIndex;
  final Color backgroundColor;
  final String? backgroundImagePath;
  final int? selectedTextItemIndex;
  final bool isTrayShown;
  final String? currentPageName;
  final bool isDrawingMode;
  final Color currentDrawColor;
  final double currentStrokeWidth;
  final BrushType currentBrushType;

  const CanvasState({
    required this.textItems,
    required this.drawPaths,
    required this.history,
    required this.currentHistoryIndex,
    this.backgroundColor = ColorConstants.backgroundDarkGray,
    this.backgroundImagePath,
    this.selectedTextItemIndex,
    this.isTrayShown = false,
    this.currentPageName,
    this.isDrawingMode = false,
    this.currentDrawColor = ColorConstants.dialogTextBlack,
    this.currentStrokeWidth = 5.0,
    this.currentBrushType = BrushType.brush,
  });

  factory CanvasState.initial() {
    final initialState = const CanvasState(
      textItems: [],
      drawPaths: [],
      history: [],
      currentHistoryIndex: 0,
      backgroundColor: ColorConstants.backgroundDarkGray,
      backgroundImagePath: null,
      selectedTextItemIndex: null,
      isTrayShown: false,
      currentPageName: null,
      isDrawingMode: false,
      currentDrawColor: ColorConstants.dialogTextBlack,
      currentStrokeWidth: 5.0,
      currentBrushType: BrushType.brush,
    );

    // Add initial state to history
    final initialEntry = HistoryEntry(
      state: initialState,
      timestamp: DateTime.now(),
      actionDescription: 'Initial state',
    );

    return initialState.copyWith(
      history: [initialEntry],
      currentHistoryIndex: 0,
    );
  }

  CanvasState copyWith({
    List<TextItem>? textItems,
    List<DrawPath>? drawPaths,
    List<HistoryEntry>? history,
    int? currentHistoryIndex,
    Color? backgroundColor,
    String? backgroundImagePath,
    bool clearBackgroundImage = false,
    int? selectedTextItemIndex,
    bool deselect = false,
    bool? isTrayShown,
    bool? isDrawingMode,
    Color? currentDrawColor,
    double? currentStrokeWidth,
    BrushType? currentBrushType,
    String? currentPageName,
    bool clearCurrentPageName = false,
  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      drawPaths: drawPaths ?? this.drawPaths,
      history: history ?? this.history,
      currentHistoryIndex: currentHistoryIndex ?? this.currentHistoryIndex,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundImagePath: clearBackgroundImage
          ? null
          : (backgroundImagePath ?? this.backgroundImagePath),
      selectedTextItemIndex: deselect
          ? null
          : (selectedTextItemIndex ?? this.selectedTextItemIndex),
      isTrayShown: deselect ? false : (isTrayShown ?? this.isTrayShown),
      currentPageName: clearCurrentPageName
          ? null
          : (currentPageName ?? this.currentPageName),
      isDrawingMode: isDrawingMode ?? this.isDrawingMode,
      currentDrawColor: currentDrawColor ?? this.currentDrawColor,
      currentStrokeWidth: currentStrokeWidth ?? this.currentStrokeWidth,
      currentBrushType: currentBrushType ?? this.currentBrushType,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CanvasState &&
          runtimeType == other.runtimeType &&
          textItems == other.textItems &&
          drawPaths == other.drawPaths &&
          backgroundColor == other.backgroundColor &&
          backgroundImagePath == other.backgroundImagePath &&
          selectedTextItemIndex == other.selectedTextItemIndex &&
          isDrawingMode == other.isDrawingMode &&
          isTrayShown == other.isTrayShown &&
          currentPageName == other.currentPageName &&
          currentDrawColor == other.currentDrawColor &&
          currentStrokeWidth == other.currentStrokeWidth &&
          currentBrushType == other.currentBrushType;

  @override
  int get hashCode =>
      textItems.hashCode ^
      drawPaths.hashCode ^
      backgroundColor.hashCode ^
      backgroundImagePath.hashCode ^
      selectedTextItemIndex.hashCode ^
      isTrayShown.hashCode ^
      isDrawingMode.hashCode ^
      currentDrawColor.hashCode ^
      currentStrokeWidth.hashCode ^
      currentBrushType.hashCode ^
      currentPageName.hashCode;
}
