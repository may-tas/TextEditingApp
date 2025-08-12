import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_clipboard/super_clipboard.dart';
import '../models/text_item_model.dart';
import 'canvas_state.dart';

class CanvasCubit extends Cubit<CanvasState> {
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
    final newTextItem = TextItem(
      text: text,
      x: 50,
      y: 50,
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

  // FIX: Reset all formatting
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
    emit(
      state.copyWith(
        textItems: [],
        history: [...state.history, state],
        future: [],
        selectedTextItemIndex: null,
        deselect: true,
        clearCurrentPageName: true, // Clear the current page name when clearing canvas
      ),
    );
  }

  // update state with this
  void _updateState({
    List<TextItem>? textItems,
    Color? backgroundColor,
  }) {
    final newState = state.copyWith(
      textItems: textItems ?? state.textItems,
      backgroundColor: backgroundColor,
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

  // ==================== SAVE/LOAD FUNCTIONALITY ====================

  // Save current canvas state
  Future<void> savePage(String pageName) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      print('🔄 Saving page: $pageName'); // Debug log

      // Convert current state to JSON
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
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      print('📦 Page data: ${jsonEncode(pageData)}'); // Debug log

      // Save the page data
      final saved = await prefs.setString('page_$pageName', jsonEncode(pageData));
      print('💾 Page saved successfully: $saved'); // Debug log

      // Update saved pages list
      List<String> savedPages = prefs.getStringList('saved_pages') ?? [];
      print('📋 Current saved pages before: $savedPages'); // Debug log

      if (!savedPages.contains(pageName)) {
        savedPages.add(pageName);
        final listSaved = await prefs.setStringList('saved_pages', savedPages);
        print('📝 Updated saved pages list: $listSaved -> $savedPages'); // Debug log
      }

      // Verify the save
      final verification = prefs.getStringList('saved_pages');
      print('✅ Verification - saved pages: $verification'); // Debug log

      // Set the current page name and emit success message
      emit(state.copyWith(
        currentPageName: pageName,
        message: 'Page "$pageName" saved successfully!',
      ));
    } catch (e, stackTrace) {
      print('❌ Error saving page: $e'); // Debug log
      print('Stack trace: $stackTrace'); // Debug log
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

  // Load a saved page
  Future<void> loadPage(String pageName) async {
    try {
      print('🔄 Loading page: $pageName'); // Debug log

      final prefs = await SharedPreferences.getInstance();
      final pageDataString = prefs.getString('page_$pageName');

      print('📦 Raw page data: $pageDataString'); // Debug log

      if (pageDataString == null) {
        print('❌ Page not found: $pageName'); // Debug log
        emit(state.copyWith(message: 'Page "$pageName" not found'));
        return;
      }

      final pageData = jsonDecode(pageDataString);
      print('📋 Decoded page data: $pageData'); // Debug log

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

      print('✅ Successfully loaded ${textItems.length} text items'); // Debug log

      emit(CanvasState(
        textItems: textItems,
        backgroundColor: Color(pageData['backgroundColor']),
        selectedTextItemIndex: null,
        message: 'Page "$pageName" loaded successfully!',
        history: [],
        future: [],
        currentPageName: pageName, // Set the current page name
      ));
    } catch (e, stackTrace) {
      print('❌ Error loading page: $e'); // Debug log
      print('Stack trace: $stackTrace'); // Debug log
      emit(state.copyWith(
        message: 'Error loading page: $e',
      ));
    }
  }

  // Create new page (clears current page name)
  void createNewPage() {
    emit(state.copyWith(
      textItems: [],
      backgroundColor: Colors.black,
      selectedTextItemIndex: null,
      history: [],
      future: [],
      clearCurrentPageName: true, // Clear the current page name
      message: 'New page created',
    ));
  }

  // Get list of saved pages
  Future<List<String>> getSavedPages() async {
    try {
      print('🔄 Getting saved pages...'); // Debug log

      final prefs = await SharedPreferences.getInstance();
      final savedPages = prefs.getStringList('saved_pages') ?? [];

      print('📋 Found saved pages: $savedPages'); // Debug log

      // Also check what keys exist in SharedPreferences
      final allKeys = prefs.getKeys();
      final pageKeys = allKeys.where((key) => key.startsWith('page_')).toList();
      print('🔑 All page keys in storage: $pageKeys'); // Debug log

      return savedPages;
    } catch (e, stackTrace) {
      print('❌ Error getting saved pages: $e'); // Debug log
      print('Stack trace: $stackTrace'); // Debug log
      return [];
    }
  }

  // Delete a saved page
  Future<void> deletePage(String pageName) async {
    try {
      print('🗑️ Deleting page: $pageName'); // Debug log

      final prefs = await SharedPreferences.getInstance();

      // Remove the page data
      final dataRemoved = await prefs.remove('page_$pageName');
      print('📦 Page data removed: $dataRemoved'); // Debug log

      // Update the saved pages list
      List<String> savedPages = prefs.getStringList('saved_pages') ?? [];
      print('📋 Saved pages before removal: $savedPages'); // Debug log

      savedPages.remove(pageName);
      final listUpdated = await prefs.setStringList('saved_pages', savedPages);
      print('📝 Saved pages after removal: $savedPages, updated: $listUpdated'); // Debug log

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
      print('❌ Error deleting page: $e'); // Debug log
      print('Stack trace: $stackTrace'); // Debug log
      emit(state.copyWith(
        message: 'Error deleting page: $e',
      ));
    }
  }

  // Get page preview data (for thumbnails or previews)
  Future<Map<String, dynamic>?> getPagePreview(String pageName) async {
    try {
      print('🔍 Getting preview for page: $pageName'); // Debug log

      final prefs = await SharedPreferences.getInstance();
      final pageDataString = prefs.getString('page_$pageName');

      if (pageDataString == null) {
        print('❌ No preview data found for: $pageName'); // Debug log
        return null;
      }

      final pageData = jsonDecode(pageDataString);
      final preview = {
        'name': pageName,
        'textCount': (pageData['textItems'] as List).length,
        'backgroundColor': Color(pageData['backgroundColor']),
        'timestamp': pageData['timestamp'],
        'lastModified': DateTime.fromMillisecondsSinceEpoch(pageData['timestamp']),
      };

      print('✅ Preview generated for $pageName: ${preview['textCount']} items'); // Debug log
      return preview;
    } catch (e, stackTrace) {
      print('❌ Error getting preview for $pageName: $e'); // Debug log
      print('Stack trace: $stackTrace'); // Debug log
      return null;
    }
  }

  // Clear message (useful for dismissing notifications)
  void clearMessage() {
    emit(state.copyWith(message: null));
  }

  // Debug method to clear all saved data (useful for testing)
  Future<void> clearAllSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final pageKeys = allKeys.where((key) => key.startsWith('page_') || key == 'saved_pages');

      for (final key in pageKeys) {
        await prefs.remove(key);
      }

      print('🧹 Cleared all saved data: $pageKeys'); // Debug log

      emit(state.copyWith(
        message: 'All saved data cleared!',
        clearCurrentPageName: true,
      ));
    } catch (e) {
      print('❌ Error clearing saved data: $e'); // Debug log
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied to clipboard')),
      );
    }).catchError((error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to copy: $error')),
      );
    });
  }
}