import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_clipboard/super_clipboard.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:texterra/utils/custom_snackbar.dart';
import '../models/text_item_model.dart';
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
      color: Colors.white, // My Default color for the text
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

  // Reset all formatting
  void resetFormatting(int index) {
    final updatedItems = List<TextItem>.from(state.textItems);
    updatedItems[index] = updatedItems[index].copyWith(
      fontSize: 16,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.normal,
      fontFamily: 'Roboto',
      isUnderlined: false,
      color: Colors.white, // Reset to default color
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
        emit(state.copyWith(message: 'Background image uploaded successfully!'));
      }
    } catch (e) {
      print('Error uploading background image: $e');
      emit(state.copyWith(message: 'Error uploading image: $e'));
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
        emit(state.copyWith(message: 'Background photo captured successfully!'));
      }
    } catch (e) {
      print('Error taking photo for background: $e');
      emit(state.copyWith(message: 'Error taking photo: $e'));
    }
  }

  // Method to remove background image
  void removeBackgroundImage() {
    // Delete the old image file if it exists
    if (state.backgroundImagePath != null) {
      _deleteImageFile(state.backgroundImagePath!);
    }
    
    _updateState(clearBackgroundImage: true);
    emit(state.copyWith(message: 'Background image removed'));
  }

  // Helper method to save image to app directory
  Future<String?> _saveImageToAppDirectory(XFile image) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'bg_${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final savedPath = path.join(appDir.path, fileName);
      
      // Copy the file to app directory
      final File imageFile = File(image.path);
      await imageFile.copy(savedPath);
      
      print('Image saved to: $savedPath');
      return savedPath;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  // Helper method to delete image file
  Future<void> _deleteImageFile(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        print('Deleted image file: $imagePath');
      }
    } catch (e) {
      print('Error deleting image file: $e');
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
        history: [...state.history, state],
        future: [],
        selectedTextItemIndex: null,
        deselect: true,
        clearCurrentPageName: true,
        clearBackgroundImage: true,
      ),
    );
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

  Future<void> savePage(String pageName) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('🔄 Saving page: $pageName');

      final pageData = {
        'textItems': state.textItems.map((item) => {
          'text': item.text,
          'x': item.x,
          'y': item.y,
          'fontSize': item.fontSize,
          'fontWeight': item.fontWeight.index,
          'fontStyle': item.fontStyle.index,
          'color': item.color.value,
          'fontFamily': item.fontFamily,
          'isUnderlined': item.isUnderlined,
        }).toList(),
        'backgroundColor': state.backgroundColor.value,
        'backgroundImagePath': state.backgroundImagePath, // Save background image path
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      print('📦 Page data: ${jsonEncode(pageData)}');

      // Save the page data
      final saved = await prefs.setString('page_$pageName', jsonEncode(pageData));
      print('💾 Page saved successfully: $saved');

      // Update saved pages list
      List<String> savedPages = prefs.getStringList('saved_pages') ?? [];
      print('📋 Current saved pages before: $savedPages');

      if (!savedPages.contains(pageName)) {
        savedPages.add(pageName);
        final listSaved = await prefs.setStringList('saved_pages', savedPages);
        print('📝 Updated saved pages list: $listSaved -> $savedPages');
      }

      // Verify the save
      final verification = prefs.getStringList('saved_pages');
      print('✅ Verification - saved pages: $verification');

      // Set the current page name and emit success message
      emit(state.copyWith(
        currentPageName: pageName,
        message: 'Page "$pageName" saved successfully!',
      ));
    } catch (e, stackTrace) {
      print('❌ Error saving page: $e');
      print('Stack trace: $stackTrace');
      emit(state.copyWith(
        message: 'Error saving page: $e',
      ));
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
      print('🔄 Loading page: $pageName');

      final prefs = await SharedPreferences.getInstance();
      final pageDataString = prefs.getString('page_$pageName');

      print('📦 Raw page data: $pageDataString');

      if (pageDataString == null) {
        print('❌ Page not found: $pageName');
        emit(state.copyWith(message: 'Page "$pageName" not found'));
        return;
      }

      final pageData = jsonDecode(pageDataString);
      print('📋 Decoded page data: $pageData');

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
        );
      }).toList();

      // Load background image path if it exists
      final backgroundImagePath = pageData['backgroundImagePath'] as String?;
      
      // Verify the background image file still exists
      String? validImagePath;
      if (backgroundImagePath != null) {
        final imageFile = File(backgroundImagePath);
        if (await imageFile.exists()) {
          validImagePath = backgroundImagePath;
        } else {
          print('⚠️ Background image file not found: $backgroundImagePath');
        }
      }

      print('✅ Successfully loaded ${textItems.length} text items');

      emit(CanvasState(
        textItems: textItems,
        backgroundColor: Color(pageData['backgroundColor']),
        backgroundImagePath: validImagePath,
        selectedTextItemIndex: null,
        message: 'Page "$pageName" loaded successfully!',
        history: [],
        future: [],
        currentPageName: pageName,
      ));
    } catch (e, stackTrace) {
      print('❌ Error loading page: $e');
      print('Stack trace: $stackTrace');
      emit(state.copyWith(
        message: 'Error loading page: $e',
      ));
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
      backgroundColor: Colors.black,
      selectedTextItemIndex: null,
      history: [],
      future: [],
      clearCurrentPageName: true,
      clearBackgroundImage: true,
      message: 'New page created',
    ));
  }

  // Get list of saved pages
  Future<List<String>> getSavedPages() async {
    try {
      print('🔄 Getting saved pages...');

      final prefs = await SharedPreferences.getInstance();
      final savedPages = prefs.getStringList('saved_pages') ?? [];

      print('📋 Found saved pages: $savedPages');

      // Also check what keys exist in SharedPreferences
      final allKeys = prefs.getKeys();
      final pageKeys = allKeys.where((key) => key.startsWith('page_')).toList();
      print('🔑 All page keys in storage: $pageKeys');

      return savedPages;
    } catch (e, stackTrace) {
      print('❌ Error getting saved pages: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Delete a saved page (now also cleans up background image files)
  Future<void> deletePage(String pageName) async {
    try {
      print('🗑️ Deleting page: $pageName');

      final prefs = await SharedPreferences.getInstance();

      // Get page data to check for background image before deleting
      final pageDataString = prefs.getString('page_$pageName');
      if (pageDataString != null) {
        try {
          final pageData = jsonDecode(pageDataString);
          final backgroundImagePath = pageData['backgroundImagePath'] as String?;
          
          // Delete the background image file if it exists
          if (backgroundImagePath != null) {
            await _deleteImageFile(backgroundImagePath);
          }
        } catch (e) {
          print('⚠️ Error reading page data for cleanup: $e');
        }
      }

      // Remove the page data
      final dataRemoved = await prefs.remove('page_$pageName');
      print('📦 Page data removed: $dataRemoved');

      // Update the saved pages list
      List<String> savedPages = prefs.getStringList('saved_pages') ?? [];
      print('📋 Saved pages before removal: $savedPages');

      savedPages.remove(pageName);
      final listUpdated = await prefs.setStringList('saved_pages', savedPages);
      print('📝 Saved pages after removal: $savedPages, updated: $listUpdated');

      // If the deleted page is the current page, clear the current page name
      if (state.currentPageName == pageName) {
        emit(state.copyWith(
          clearCurrentPageName: true,
          message: 'Page "$pageName" deleted successfully!',
        ));
      } else {
        emit(state.copyWith(
          message: 'Page "$pageName" deleted successfully!',
        ));
      }
    } catch (e, stackTrace) {
      print('❌ Error deleting page: $e');
      print('Stack trace: $stackTrace');
      emit(state.copyWith(
        message: 'Error deleting page: $e',
      ));
    }
  }

  // Get page preview data (for thumbnails or previews)
  Future<Map<String, dynamic>?> getPagePreview(String pageName) async {
    try {
      print('🔍 Getting preview for page: $pageName');

      final prefs = await SharedPreferences.getInstance();
      final pageDataString = prefs.getString('page_$pageName');

      if (pageDataString == null) {
        print('❌ No preview data found for: $pageName');
        return null;
      }

      final pageData = jsonDecode(pageDataString);
      final preview = {
        'name': pageName,
        'textCount': (pageData['textItems'] as List).length,
        'backgroundColor': Color(pageData['backgroundColor']),
        'backgroundImagePath': pageData['backgroundImagePath'], // Include background image
        'timestamp': pageData['timestamp'],
        'lastModified': DateTime.fromMillisecondsSinceEpoch(pageData['timestamp']),
      };

      print('✅ Preview generated for $pageName: ${preview['textCount']} items');
      return preview;
    } catch (e, stackTrace) {
      print('❌ Error getting preview for $pageName: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Clear message (useful for dismissing notifications)
  void clearMessage() {
    emit(state.copyWith(message: null));
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
            final backgroundImagePath = pageData['backgroundImagePath'] as String?;
            if (backgroundImagePath != null) {
              await _deleteImageFile(backgroundImagePath);
            }
          } catch (e) {
            print('⚠️ Error cleaning up image for $key: $e');
          }
        }
      }

      // Clear all saved page data
      final keysToRemove = allKeys.where((key) => key.startsWith('page_') || key == 'saved_pages');
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }

      // Also clear current background image
      if (state.backgroundImagePath != null) {
        await _deleteImageFile(state.backgroundImagePath!);
      }

      print('🧹 Cleared all saved data: $keysToRemove');

      emit(state.copyWith(
        message: 'All saved data cleared!',
        clearCurrentPageName: true,
        clearBackgroundImage: true,
      ));
    } catch (e) {
      print('❌ Error clearing saved data: $e');
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
}