import 'dart:convert';
import 'package:celebrare_assignment/models/text_item_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _textItemsKey = 'text_items';

  // Save the list of TextItem to SharedPreferences
  Future<void> saveTextItems(List<TextItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(_textItemsKey, encodedList);
  }

  // Load the list of TextItem from SharedPreferences
  Future<List<TextItem>> loadTextItems() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = prefs.getString(_textItemsKey);

    if (encodedList != null) {
      final List<dynamic> decodedList = jsonDecode(encodedList);
      return decodedList
          .map((item) => TextItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return [];
  }
}
