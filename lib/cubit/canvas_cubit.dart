import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/color_constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:texterra/utils/custom_snackbar.dart';
import '../models/text_item_model.dart';
import '../models/draw_model.dart';
import 'canvas_state.dart';

class CanvasCubit extends Cubit<CanvasState> {
  final ImagePicker _imagePicker = ImagePicker();

  CanvasCubit() : super(CanvasState.initial());

  //method to toggle the color tray
  void toggleTray() {
    emit(state.copyWith(isTrayShown: !state.isTrayShown));
  }

  //method to select text
  void selectText(int index) {
    if (index >= 0 && index < state.textItems.length) {
      emit(state.copyWith(selectedTextItemIndex: index));
    }
  }

  // Add to your CanvasCubit class
  void fillCanvas(Color fillColor) {
    // Create a special "fill" path that covers the entire canvas
    final paint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    // Create a single point path with a special flag indicating it's a fill
    final fillPath = DrawPath(
      points: [DrawingPoint(offset: Offset.zero, paint: paint)],
      color: fillColor,
      strokeWidth: 1.0,
      isFill: true, // New flag to indicate this is a fill operation
    );

    // Add this to the beginning of paths so it appears as a background
    final updatedPaths = [fillPath, ...state.drawPaths];

    emit(state.copyWith(drawPaths: updatedPaths));
  }

  // method to deselect text
  void deselectText() {
    emit(state.copyWith(selectedTextItemIndex: null, deselect: true));
  }

  // method to add the text
  void addText(String text) {
    // Calculate offset based on the number of existing text items
    final offset = state.textItems.length * 20.0; // 20px offset for each item

    final newTextItem = TextItem(
      text: text,
      x: 50 + offset,
      y: 50 + offset,
      fontSize: 16,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal,
      fontFamily: 'Roboto',
      isUnderlined: false,
      color: ColorConstants.uiWhite, // My Default color for the text
    );
    final updatedItems = List<TextItem>.from(state.textItems)..add(newTextItem);
    emit(
      state.copyWith(
        textItems: updatedItems,
        selectedTextItemIndex: updatedItems.length - 1,
        history: [...state.history, state],
        future: [],
      ),
    );
  }

  // Method to toggle text highlighting
  void toggleTextHighlight(int index, {Color? highlightColor}) {
    final updatedItems = List<TextItem>.from(state.textItems);
    final currentItem = updatedItems[index];

    updatedItems[index] = currentItem.copyWith(
      isHighlighted: !currentItem.isHighlighted,
      highlightColor: highlightColor ?? ColorConstants.highlightYellow,
    );
    _updateState(textItems: updatedItems);
  }

// Method to set specific highlight color
  void changeHighlightColor(int index, Color color) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(
      isHighlighted: true,
      highlightColor: color,
    );
    _updateState(textItems: updatedItems);
  }

// Update your resetFormatting method to include highlighting
  void resetFormatting(int index) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(
      fontSize: 16,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal,
      fontFamily: 'Roboto',
      isUnderlined: false,
      isHighlighted: false, // Add this line
      highlightColor: null, // Add this line
      color: ColorConstants.uiWhite,
    );
    _updateState(textItems: updatedItems);
  }

  // method to change and emit new TextColor
  void changeTextColor(int index, Color color) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(color: color);
    _updateState(textItems: updatedItems);
  }

  // method to change background color
  void changeBackgroundColor(Color color) {
    _updateState(backgroundColor: color);
  }

  // Method to upload background image from gallery
  Future<void> uploadBackgroundImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress to reduce file size
      );

      if (image == null) return; // User cancelled selection

      // Save image to app's document directory
      final savedPath = await _saveImageToAppDirectory(image);

      if (savedPath != null) {
        _updateState(backgroundImagePath: savedPath);
        CustomSnackbar.showSuccess('Background image uploaded successfully!');
      }
    } catch (e) {
      log('Error uploading background image: $e');
      CustomSnackbar.showError('Error uploading image: $e');
    }
  }

  // Method to take photo for background
  Future<void> takePhotoForBackground() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Compress to reduce file size
      );

      if (image == null) return; // User cancelled

      // Save image to app's document directory
      final savedPath = await _saveImageToAppDirectory(image);

      if (savedPath != null) {
        _updateState(backgroundImagePath: savedPath);
        CustomSnackbar.showSuccess('Background photo captured successfully!');
      }
    } catch (e) {
      log('Error taking photo for background: $e');
      CustomSnackbar.showError('Error taking photo: $e');
    }
  }

  // Method to remove background image
  void removeBackgroundImage() {
    // Delete the old image file if it exists
    if (state.backgroundImagePath != null) {
      _deleteImageFile(state.backgroundImagePath!);
    }

    _updateState(clearBackgroundImage: true);
    CustomSnackbar.showInfo('Background image removed');
  }

  // Helper method to save image to app directory
  Future<String?> _saveImageToAppDirectory(XFile image) async {
    try {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        final mimeType = image.mimeType ?? 'image/png';
        final dataUrl = 'data:$mimeType;base64,$base64String';
        log('Image saved as data URL');
        return dataUrl;
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName =
            'bg_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
        final savedPath = path.join(appDir.path, fileName);

        // Copy the file to app directory
        final File imageFile = File(image.path);
        await imageFile.copy(savedPath);
        log('Image saved to: $savedPath');
        return savedPath;
      }
    } catch (e) {
      log('Error saving image: $e');
      return null;
    }
  }

  // Helper method to delete image file
  Future<void> _deleteImageFile(String imagePath) async {
    try {
      if (kIsWeb && imagePath.startsWith('data:')) {
        // On web, data URLs don't need to be deleted from storage
        log('Cleared data URL from memory');
        return;
      }

      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        log('Deleted image file: $imagePath');
      }
    } catch (e) {
      log('Error deleting image file: $e');
    }
  }

  // method to editText and emit changes
  void editText(int index, String newText) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(text: newText);
    _updateState(textItems: updatedItems);
  }

  // method to moveText and emit changes
  void moveText(int index, double x, double y) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(x: x, y: y);
    _updateState(textItems: updatedItems);
  }

  // method to change and emit new fontSize
  void changeFontSize(int index, double fontSize) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontSize: fontSize);
    _updateState(textItems: updatedItems);
  }

  // method to change and emit new fontFamily
  void changeFontFamily(int index, String fontFamily) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontFamily: fontFamily);
    _updateState(textItems: updatedItems);
  }

  // method to change and emit new fontStyle
  void changeFontStyle(int index, FontStyle fontStyle) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontStyle: fontStyle);
    _updateState(textItems: updatedItems);
  }

  void changeTextUnderline(int index, bool isUnderlined) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] =
        updatedItems[index].copyWith(isUnderlined: isUnderlined);
    _updateState(textItems: updatedItems);
  }

  // method to change and emit new fontWeight
  void changeFontWeight(int index, FontWeight fontWeight) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(fontWeight: fontWeight);
    _updateState(textItems: updatedItems);
  }

  // method to change text alignment
  void changeTextAlignment(int index, TextAlign align) {
    if (index < 0 || index >= state.textItems.length) return;

    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(textAlign: align);

    emit(state.copyWith(textItems: updatedItems));
  }

  // method to undo changes and emit it
  void undo() {
    if (state.history.isNotEmpty) {
      final previousState = state.history.last;
      final newHistory = List<CanvasState>.from(state.history)..removeLast();
      emit(previousState.copyWith(
        history: newHistory,
        future: [state, ...state.future],
      ));
    }
  }

  // method to redo changes and emit it
  void redo() {
    if (state.future.isNotEmpty) {
      final nextState = state.future.first;
      final newFuture = List<CanvasState>.from(state.future)..removeAt(0);
      emit(nextState.copyWith(
        future: newFuture,
        history: [...state.history, state],
      ));
    }
  }

  // method to empty the canvas
  void clearCanvas() {
    // Delete the background image if it exists
    if (state.backgroundImagePath != null) {
      _deleteImageFile(state.backgroundImagePath!);
    }

    emit(
      state.copyWith(
        textItems: [],
        drawPaths: [],
        history: [...state.history, state],
        future: [],
        selectedTextItemIndex: null,
        deselect: true,
        isDrawingMode: false, // Exit drawing mode when clearing
        clearCurrentPageName: true,
        clearBackgroundImage: true,
      ),
    );
    CustomSnackbar.showInfo('Canvas cleared');
  }

  void _updateState({
    List<TextItem>? textItems,
    Color? backgroundColor,
    String? backgroundImagePath,
    bool clearBackgroundImage = false,
  }) {
    final newState = state.copyWith(
      textItems: textItems ?? state.textItems,
      backgroundColor: backgroundColor,
      backgroundImagePath: backgroundImagePath,
      clearBackgroundImage: clearBackgroundImage,
      history: [...state.history, state],
      future: [],
    );
    emit(newState);
  }

  void deleteText(int index) {
    final updatedList = List<TextItem>.from(state.textItems)..removeAt(index);
    emit(state.copyWith(
        textItems: updatedList,
        selectedTextItemIndex: null,
        history: [...state.history, state],
        future: [],
        deselect: true));
  }

  Future<void> savePage(String pageName, {String? label, int? color}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      log('🔄 Saving page: $pageName');

      final pageData = {
        'textItems': state.textItems
            .map((item) => {
                  'text': item.text,
                  'x': item.x,
                  'y': item.y,
                  'fontSize': item.fontSize,
                  'fontWeight': item.fontWeight.index,
                  'fontStyle': item.fontStyle.index,
                  'color': item.color.toARGB32(),
                  'fontFamily': item.fontFamily,
                  'isUnderlined': item.isUnderlined,
                  'textAlign':
                      item.textAlign.index, // Save alignment as integer
                })
            .toList(),
        'drawPaths': state.drawPaths
            .map((path) => path.toJson())
            .toList(), // Save drawing paths
        'backgroundColor': state.backgroundColor.toARGB32(),
        'backgroundImagePath':
            state.backgroundImagePath, // Save background image path
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        if (label != null && label.isNotEmpty) 'label': label,
        if (color != null) 'pageColor': color,
      };

      log('📦 Page data: ${jsonEncode(pageData)}');

      // Save the page data
      final saved =
          await prefs.setString('page_$pageName', jsonEncode(pageData));
      log('💾 Page saved successfully: $saved');

      // Update saved pages list
      List<String> savedPages = prefs.getStringList('saved_pages') ?? [];
      log('📋 Current saved pages before: $savedPages');

      if (!savedPages.contains(pageName)) {
        savedPages.add(pageName);
        final listSaved = await prefs.setStringList('saved_pages', savedPages);
        log('📝 Updated saved pages list: $listSaved -> $savedPages');
      }

      // Verify the save
      final verification = prefs.getStringList('saved_pages');
      log('✅ Verification - saved pages: $verification');

      // Set the current page name and emit success message
      emit(state.copyWith(
        currentPageName: pageName,
      ));
      CustomSnackbar.showSuccess('Page "$pageName" saved successfully!');
    } catch (e, stackTrace) {
      log('❌ Error saving page: $e');
      log('Stack trace: $stackTrace');
      CustomSnackbar.showError('Error saving page: $e');
    }
  }

  // Method to handle save action (auto-save if page exists, otherwise show dialog)
  Future<bool> handleSaveAction() async {
    if (state.currentPageName != null) {
      // If there's a current page, auto-save it
      await savePage(state.currentPageName!);
      return true; // Indicates that save was handled automatically
    }
    return false; // Indicates that dialog should be shown
  }

  // Load a saved page (now includes background image)
  Future<void> loadPage(String pageName) async {
    try {
      log('🔄 Loading page: $pageName');

      final prefs = await SharedPreferences.getInstance();
      final pageDataString = prefs.getString('page_$pageName');

      log('📦 Raw page data: $pageDataString');

      if (pageDataString == null) {
        log('❌ Page not found: $pageName');
        CustomSnackbar.showError('Page "$pageName" not found');
        return;
      }

      final pageData = jsonDecode(pageDataString);
      log('📋 Decoded page data: $pageData');

      final textItems = (pageData['textItems'] as List).map((item) {
        return TextItem(
          text: item['text'],
          x: item['x'].toDouble(),
          y: item['y'].toDouble(),
          fontSize: item['fontSize'].toDouble(),
          fontWeight: FontWeight.values[item['fontWeight']],
          fontStyle: FontStyle.values[item['fontStyle']],
          color: Color(item['color']),
          fontFamily: item['fontFamily'],
          isUnderlined: item['isUnderlined'] ?? false,
          textAlign: TextAlign
              .values[item['textAlign'] ?? 0], // Default to left if missing
        );
      }).toList();

      // Load drawing paths if they exist
      List<DrawPath> drawPaths = [];
      if (pageData.containsKey('drawPaths')) {
        final drawPathsData = pageData['drawPaths'] as List<dynamic>;
        drawPaths = drawPathsData.map((pathData) {
          return DrawPath.fromJson(pathData);
        }).toList();
      }

      // Load background image path if it exists
      final backgroundImagePath = pageData['backgroundImagePath'] as String?;

      // Verify the background image file still exists or is valid
      String? validImagePath;
      if (backgroundImagePath != null) {
        if (kIsWeb && backgroundImagePath.startsWith('data:')) {
          // On web, data URLs are always valid if they exist
          validImagePath = backgroundImagePath;
        } else {
          // On mobile, check if the file exists
          final imageFile = File(backgroundImagePath);
          if (await imageFile.exists()) {
            validImagePath = backgroundImagePath;
          } else {
            log('⚠ Background image file not found: $backgroundImagePath');
          }
        }
      }

      log('✅ Successfully loaded ${textItems.length} text items and ${drawPaths.length} drawing paths');

      emit(CanvasState(
        textItems: textItems,
        drawPaths: drawPaths,
        backgroundColor: Color(pageData['backgroundColor']),
        backgroundImagePath: validImagePath,
        selectedTextItemIndex: null,
        history: [],
        future: [],
        currentPageName: pageName,
      ));
      CustomSnackbar.showSuccess('Page "$pageName" loaded successfully!');
    } catch (e, stackTrace) {
      log('❌ Error loading page: $e');
      log('Stack trace: $stackTrace');
      CustomSnackbar.showError('Error loading page: $e');
    }
  }

  // Create new page (clears current page name and background image)
  void createNewPage() {
    // Delete the current background image if it exists
    if (state.backgroundImagePath != null) {
      _deleteImageFile(state.backgroundImagePath!);
    }

    emit(state.copyWith(
      textItems: [],
      drawPaths: [], // Clear drawing paths too
      backgroundColor: ColorConstants.dialogTextBlack,
      selectedTextItemIndex: null,
      history: [],
      future: [],
      isDrawingMode: false, // Exit drawing mode when creating new page
      clearCurrentPageName: true,
      clearBackgroundImage: true,
    ));
    CustomSnackbar.showInfo('New page created');
  }

  // Get list of saved pages
  Future<List<String>> getSavedPages() async {
    try {
      log('🔄 Getting saved pages...');

      final prefs = await SharedPreferences.getInstance();
      final savedPages = prefs.getStringList('saved_pages') ?? [];

      log('📋 Found saved pages: $savedPages');

      // Also check what keys exist in SharedPreferences
      final allKeys = prefs.getKeys();
      final pageKeys = allKeys.where((key) => key.startsWith('page_')).toList();
      log('🔑 All page keys in storage: $pageKeys');

      return savedPages;
    } catch (e, stackTrace) {
      log('❌ Error getting saved pages: $e');
      log('Stack trace: $stackTrace');
      return [];
    }
  }

  // Delete a saved page (now also cleans up background image files)
  Future<void> deletePage(String pageName) async {
    try {
      log('🗑 Deleting page: $pageName');

      final prefs = await SharedPreferences.getInstance();

      // Get page data to check for background image before deleting
      final pageDataString = prefs.getString('page_$pageName');
      if (pageDataString != null) {
        try {
          final pageData = jsonDecode(pageDataString);
          final backgroundImagePath =
              pageData['backgroundImagePath'] as String?;

          // Delete the background image file if it exists
          if (backgroundImagePath != null) {
            await _deleteImageFile(backgroundImagePath);
          }
        } catch (e) {
          log('⚠ Error reading page data for cleanup: $e');
        }
      }

      // Remove the page data
      final dataRemoved = await prefs.remove('page_$pageName');
      log('📦 Page data removed: $dataRemoved');

      // Update the saved pages list
      List<String> savedPages = prefs.getStringList('saved_pages') ?? [];
      log('📋 Saved pages before removal: $savedPages');

      savedPages.remove(pageName);
      final listUpdated = await prefs.setStringList('saved_pages', savedPages);
      log('📝 Saved pages after removal: $savedPages, updated: $listUpdated');

      // If the deleted page is the current page, clear the current page name
      if (state.currentPageName == pageName) {
        emit(state.copyWith(
          clearCurrentPageName: true,
        ));
      }
      CustomSnackbar.showSuccess('Page "$pageName" deleted successfully!');
    } catch (e, stackTrace) {
      log('❌ Error deleting page: $e');
      log('Stack trace: $stackTrace');
      CustomSnackbar.showError('Error deleting page: $e');
    }
  }

  // Get page preview data (for thumbnails or previews)
  Future<Map<String, dynamic>?> getPagePreview(String pageName) async {
    try {
      log('🔍 Getting preview for page: $pageName');

      final prefs = await SharedPreferences.getInstance();
      final pageDataString = prefs.getString('page_$pageName');

      if (pageDataString == null) {
        log('❌ No preview data found for: $pageName');
        return null;
      }

      final pageData = jsonDecode(pageDataString);
      final preview = {
        'name': pageName,
        'textCount': (pageData['textItems'] as List).length,
        'backgroundColor':
            Color(pageData['pageColor'] ?? pageData['backgroundColor']),
        'backgroundImagePath':
            pageData['backgroundImagePath'], // Include background image
        'timestamp': pageData['timestamp'],
        'lastModified':
            DateTime.fromMillisecondsSinceEpoch(pageData['timestamp']),
        'label': pageData['label'] ?? '',
      };

      log('✅ Preview generated for $pageName: ${preview['textCount']} items');
      return preview;
    } catch (e, stackTrace) {
      log('❌ Error getting preview for $pageName: $e');
      log('Stack trace: $stackTrace');
      return null;
    }
  }

  // Debug method to clear all saved data (now also cleans up image files)
  Future<void> clearAllSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final pageKeys = allKeys.where((key) => key.startsWith('page_'));

      // Clean up all background image files
      for (final key in pageKeys) {
        final pageDataString = prefs.getString(key);
        if (pageDataString != null) {
          try {
            final pageData = jsonDecode(pageDataString);
            final backgroundImagePath =
                pageData['backgroundImagePath'] as String?;
            if (backgroundImagePath != null) {
              await _deleteImageFile(backgroundImagePath);
            }
          } catch (e) {
            log('⚠ Error cleaning up image for $key: $e');
          }
        }
      }

      // Clear all saved page data
      final keysToRemove = allKeys
          .where((key) => key.startsWith('page_') || key == 'saved_pages');
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }

      // Also clear current background image
      if (state.backgroundImagePath != null) {
        await _deleteImageFile(state.backgroundImagePath!);
      }

      log('🧹 Cleared all saved data: $keysToRemove');

      emit(state.copyWith(
        clearCurrentPageName: true,
        clearBackgroundImage: true,
      ));
      CustomSnackbar.showSuccess('All saved data cleared!');
    } catch (e) {
      log('❌ Error clearing saved data: $e');
      CustomSnackbar.showError('Error clearing saved data: $e');
    }
  }

  // copy with formatting
  void copyText(int index, BuildContext context) async {
    if (index < 0 || index >= state.textItems.length) return;
    final itemToCopy = state.textItems[index];
    final plainText = itemToCopy.text;
    final htmlText = itemToCopy.toHTML();

    final superClipboard = SystemClipboard.instance;
    final items = DataWriterItem();

    items.add(Formats.plainText(plainText));
    items.add(Formats.htmlText(htmlText));

    await superClipboard?.write([items]).then((_) {
      if (!context.mounted) return;
      CustomSnackbar.showInfo('Copied to clipboard');
    }).catchError((error) {
      if (!context.mounted) return;
      CustomSnackbar.showError('Failed to copy: $error');
    });
  }

  // Drawing related methods

  // Toggle between drawing mode and text mode
  void toggleDrawingMode() {
    emit(state.copyWith(
      isDrawingMode: !state.isDrawingMode,
      selectedTextItemIndex: null,
      deselect: true,
    ));
  }

  // Set drawing mode explicitly
  void setDrawingMode(bool isDrawing) {
    if (state.isDrawingMode != isDrawing) {
      emit(state.copyWith(
        isDrawingMode: isDrawing,
        selectedTextItemIndex: null,
        deselect: true,
      ));
    }
  }

  // Set the current drawing color
  void setDrawColor(Color color) {
    emit(state.copyWith(currentDrawColor: color));
  }

  // Set the current stroke width
  void setStrokeWidth(double width) {
    emit(state.copyWith(currentStrokeWidth: width));
  }

  // Set the current brush type
  void setBrushType(BrushType brushType) {
    emit(state.copyWith(currentBrushType: brushType));
  }

  // Create paint for different brush types
  Paint _createPaintForBrush(
      BrushType brushType, Color color, double strokeWidth) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    switch (brushType) {
      case BrushType.brush:
        paint
          ..color = color
          ..strokeWidth = strokeWidth
          ..filterQuality = FilterQuality.high;
        break;
      case BrushType.marker:
        paint
          ..color = color.withValues(alpha: 0.7)
          ..strokeWidth = strokeWidth * 1.5
          ..filterQuality = FilterQuality.medium;
        break;
    }
    return paint;
  }

  // Add a new drawing path
  void startNewDrawPath(Offset point) {
    if (!state.isDrawingMode) return;

    final paint = _createPaintForBrush(
      state.currentBrushType,
      state.currentDrawColor,
      state.currentStrokeWidth,
    );

    final drawingPoint = DrawingPoint(
      offset: point,
      paint: paint,
    );

    final newPath = DrawPath(
      points: [drawingPoint],
      color: state.currentDrawColor,
      strokeWidth: state.currentStrokeWidth,
      brushType: state.currentBrushType,
    );

    final newPaths = List<DrawPath>.from(state.drawPaths)..add(newPath);

    // Save current state to history
    final historyState = state.copyWith();
    final newHistory = List<CanvasState>.from(state.history)..add(historyState);

    emit(state.copyWith(
      drawPaths: newPaths,
      history: newHistory,
      future: [], // Clear future as we've made a new action
    ));
  }

  // Update the current drawing path with a new point
  void updateDrawPath(Offset point) {
    if (!state.isDrawingMode || state.drawPaths.isEmpty) return;

    final paint = _createPaintForBrush(
      state.currentBrushType,
      state.currentDrawColor,
      state.currentStrokeWidth,
    );

    final drawingPoint = DrawingPoint(
      offset: point,
      paint: paint,
    );

    final currentPaths = List<DrawPath>.from(state.drawPaths);
    final currentPath = currentPaths.last;
    final updatedPoints = List<DrawingPoint>.from(currentPath.points)
      ..add(drawingPoint);

    currentPaths[currentPaths.length - 1] = DrawPath(
      points: updatedPoints,
      color: currentPath.color,
      strokeWidth: currentPath.strokeWidth,
      brushType: currentPath.brushType,
    );

    emit(state.copyWith(drawPaths: currentPaths));
  }

  // Clear all drawing paths
  void clearDrawings() {
    if (state.drawPaths.isEmpty) return;

    // Save current state to history
    final historyState = state.copyWith();
    final newHistory = List<CanvasState>.from(state.history)..add(historyState);

    emit(state.copyWith(
      drawPaths: [],
      history: newHistory,
      future: [], // Clear future as we've made a new action
    ));
    CustomSnackbar.showInfo('Drawings cleared');
  }

  // Undo the last drawing stroke
  void undoLastDrawing() {
    if (state.drawPaths.isEmpty) return;

    // Save current state to history
    final historyState = state.copyWith();
    final newHistory = List<CanvasState>.from(state.history)..add(historyState);

    // Remove the last path
    final newPaths = List<DrawPath>.from(state.drawPaths);
    newPaths.removeLast();

    emit(state.copyWith(
      drawPaths: newPaths,
      history: newHistory,
      future: [], // Clear future as we've made a new action
    ));

    CustomSnackbar.showInfo('Last stroke undone');
  }
}
