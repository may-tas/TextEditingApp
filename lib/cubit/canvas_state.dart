import 'package:flutter/material.dart';
import '../models/text_item_model.dart';
import '../constants/color_constants.dart';
import '../models/draw_model.dart';

class CanvasState {
  final List<TextItem> textItems;
  final List<DrawPath> drawPaths;
  final List<CanvasState> history;
  final List<CanvasState> future;
  final Color backgroundColor;
  final String? backgroundImagePath;
  final int? selectedTextItemIndex;
  final bool isTrayShown;
  final String? message;
  final String? currentPageName;
  final bool isDrawingMode;
  final Color currentDrawColor;
  final double currentStrokeWidth;
  final BrushType currentBrushType;

  const CanvasState({
    required this.textItems,
    required this.drawPaths,
    required this.history,
    required this.future,
    this.backgroundColor = ColorConstants.backgroundDarkGray,
    this.backgroundImagePath,
    this.selectedTextItemIndex,
    this.isTrayShown = false,
    this.message,
    this.currentPageName,
    this.isDrawingMode = false,
    this.currentDrawColor = ColorConstants.dialogTextBlack,
    this.currentStrokeWidth = 5.0,
    this.currentBrushType = BrushType.brush,
  });

  factory CanvasState.initial() {
    return const CanvasState(
      textItems: [],
      drawPaths: [],
      history: [],
      future: [],
      backgroundColor: ColorConstants.backgroundDarkGray,
      backgroundImagePath: null,
      selectedTextItemIndex: null,
      isTrayShown: false,
      message: null,
      currentPageName: null,
      isDrawingMode: false,
      currentDrawColor: ColorConstants.dialogTextBlack,
      currentStrokeWidth: 5.0,
      currentBrushType: BrushType.brush,
    );
  }

  CanvasState copyWith({
    List<TextItem>? textItems,
    List<DrawPath>? drawPaths,
    List<CanvasState>? history,
    List<CanvasState>? future,
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
    String? message,
    String? currentPageName,
    bool clearCurrentPageName = false,
  }) {
    return CanvasState(
      textItems: textItems ?? this.textItems,
      drawPaths: drawPaths ?? this.drawPaths,
      history: history ?? this.history,
      future: future ?? this.future,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundImagePath: clearBackgroundImage
          ? null
          : (backgroundImagePath ?? this.backgroundImagePath),
      selectedTextItemIndex: deselect
          ? null
          : (selectedTextItemIndex ?? this.selectedTextItemIndex),
      isTrayShown: deselect ? false : (isTrayShown ?? this.isTrayShown),
      message: message ?? this.message,
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
          history == other.history &&
          future == other.future &&
          isTrayShown == other.isTrayShown &&
          message == other.message &&
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
      history.hashCode ^
      future.hashCode ^
      isTrayShown.hashCode ^
      isDrawingMode.hashCode ^
      currentDrawColor.hashCode ^
      currentStrokeWidth.hashCode ^
      currentBrushType.hashCode ^
      message.hashCode ^
      currentPageName.hashCode;
}
