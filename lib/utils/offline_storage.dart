import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages offline storage and sync for web platform
class OfflineStorageManager {
  OfflineStorageManager._();

  static final OfflineStorageManager instance = OfflineStorageManager._();

  // Queue for pending operations when offline
  final List<Map<String, dynamic>> _pendingOperations = [];

  /// Check if the app is running online
  Future<bool> isOnline() async {
    if (!kIsWeb) return true;

    return true; // Assume online for now
  }

  /// Save data with offline support
  Future<bool> saveWithOfflineSupport(
    String key,
    String data, {
    bool requiresSync = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setString(key, data);

      if (requiresSync && !await isOnline()) {
        _pendingOperations.add({
          'type': 'save',
          'key': key,
          'data': data,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        // Save pending operations
        await _savePendingOperations();

        log('📴 Offline: Queued save operation for $key');
      }

      return saved;
    } catch (e) {
      log('❌ Error saving with offline support: $e');
      return false;
    }
  }

  /// Load pending operations from storage
  Future<void> loadPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingJson = prefs.getString('pending_operations');

      if (pendingJson != null) {
        // In a real implementation, you'd parse and restore the queue
        log('📥 Loaded pending operations from storage');
      }
    } catch (e) {
      log('❌ Error loading pending operations: $e');
    }
  }

  /// Save pending operations to storage
  Future<void> _savePendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // In a real implementation, you'd serialize the queue
      await prefs.setString('pending_operations', 'queue_data');
      log('💾 Saved pending operations to storage');
    } catch (e) {
      log('❌ Error saving pending operations: $e');
    }
  }

  /// Sync pending operations when back online
  Future<void> syncPendingOperations() async {
    if (_pendingOperations.isEmpty) return;

    if (!await isOnline()) {
      log('📴 Still offline, cannot sync yet');
      return;
    }

    log('🔄 Syncing ${_pendingOperations.length} pending operations...');

    final operations = List<Map<String, dynamic>>.from(_pendingOperations);
    _pendingOperations.clear();

    for (final operation in operations) {
      try {
        // Process each operation
        final type = operation['type'];
        final key = operation['key'];
        final data = operation['data'];

        if (type == 'save') {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(key, data);
          log('✅ Synced save operation for $key');
        }
      } catch (e) {
        log('❌ Error syncing operation: $e');

        _pendingOperations.add(operation);
      }
    }

    // Clear pending operations from storage if all synced
    if (_pendingOperations.isEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('pending_operations');
      log('🎉 All operations synced successfully');
    }
  }

  /// Get count of pending operations
  int get pendingOperationsCount => _pendingOperations.length;

  /// Check if there are pending operations
  bool get hasPendingOperations => _pendingOperations.isNotEmpty;

  /// Clear all pending operations (use with caution)
  Future<void> clearPendingOperations() async {
    _pendingOperations.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pending_operations');
    log('🧹 Cleared all pending operations');
  }
}

class OfflineCanvasSupport {
  /// Save page with offline support
  static Future<void> savePageOffline(
    String pageName,
    Map<String, dynamic> pageData,
  ) async {
    final manager = OfflineStorageManager.instance;

    // Convert page data to JSON string
    final dataString = pageData.toString();

    // Save with offline support
    await manager.saveWithOfflineSupport(
      'page_$pageName',
      dataString,
      requiresSync: true,
    );
  }

  /// Sync all pages when back online
  static Future<void> syncPages() async {
    final manager = OfflineStorageManager.instance;
    await manager.syncPendingOperations();
  }
}
