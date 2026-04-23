import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/history_model.dart';
import '../cubit/canvas_state.dart';
import '../models/draw_model.dart';
import 'dart:math';

/// Utility class for managing history operations
class HistoryManager {
  static const int maxHistorySize = 50; // Limit history size for performance

  /// Generate a thumbnail from a canvas widget
  static Future<ui.Image?> generateThumbnail(
    GlobalKey canvasKey,
    double width,
    double height,
  ) async {
    try {
      final boundary = canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 0.5);
      return image;
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
      return null;
    }
  }

  /// Calculate the diff between two canvas states
  static Map<String, dynamic> calculateStateDiff(CanvasState oldState, CanvasState newState) {
    final diff = <String, dynamic>{};

    // Compare text items
    if (oldState.textItems != newState.textItems) {
      diff['textItems'] = _listDiff(oldState.textItems, newState.textItems);
    }

    // Compare draw paths
    if (oldState.drawPaths != newState.drawPaths) {
      diff['drawPaths'] = _listDiff(oldState.drawPaths, newState.drawPaths);
    }

    // Compare background color
    if (oldState.backgroundColor != newState.backgroundColor) {
      diff['backgroundColor'] = newState.backgroundColor.value;
    }

    // Compare background image
    if (oldState.backgroundImagePath != newState.backgroundImagePath) {
      diff['backgroundImagePath'] = newState.backgroundImagePath;
    }

    // Compare drawing mode settings
    if (oldState.isDrawingMode != newState.isDrawingMode) {
      diff['isDrawingMode'] = newState.isDrawingMode;
    }

    if (oldState.currentDrawColor != newState.currentDrawColor) {
      diff['currentDrawColor'] = newState.currentDrawColor.value;
    }

    if (oldState.currentStrokeWidth != newState.currentStrokeWidth) {
      diff['currentStrokeWidth'] = newState.currentStrokeWidth;
    }

    if (oldState.currentBrushType != newState.currentBrushType) {
      diff['currentBrushType'] = newState.currentBrushType.toString();
    }

    return diff;
  }

  /// Apply a diff to a canvas state
  static CanvasState applyDiff(CanvasState baseState, Map<String, dynamic> diff) {
    return baseState.copyWith(
      textItems: diff.containsKey('textItems')
          ? _applyListDiff(baseState.textItems, diff['textItems'])
          : null,
      drawPaths: diff.containsKey('drawPaths')
          ? _applyListDiff(baseState.drawPaths, diff['drawPaths'])
          : null,
      backgroundColor: diff.containsKey('backgroundColor')
          ? Color(diff['backgroundColor'])
          : null,
      backgroundImagePath: diff['backgroundImagePath'],
      isDrawingMode: diff['isDrawingMode'],
      currentDrawColor: diff.containsKey('currentDrawColor')
          ? Color(diff['currentDrawColor'])
          : null,
      currentStrokeWidth: diff['currentStrokeWidth']?.toDouble(),
      currentBrushType: diff.containsKey('currentBrushType')
          ? _parseBrushType(diff['currentBrushType'])
          : null,
    );
  }

  /// Generate a description for a state change
  static String generateDescription(Map<String, dynamic> diff) {
    final changes = <String>[];

    if (diff.containsKey('textItems')) {
      final textDiff = diff['textItems'] as Map<String, dynamic>;
      if (textDiff['added']?.isNotEmpty ?? false) {
        changes.add('Added ${textDiff['added'].length} text item(s)');
      }
      if (textDiff['removed']?.isNotEmpty ?? false) {
        changes.add('Removed ${textDiff['removed'].length} text item(s)');
      }
      if (textDiff['modified']?.isNotEmpty ?? false) {
        changes.add('Modified ${textDiff['modified'].length} text item(s)');
      }
    }

    if (diff.containsKey('drawPaths')) {
      final drawDiff = diff['drawPaths'] as Map<String, dynamic>;
      if (drawDiff['added']?.isNotEmpty ?? false) {
        changes.add('Added ${drawDiff['added'].length} drawing(s)');
      }
      if (drawDiff['removed']?.isNotEmpty ?? false) {
        changes.add('Removed ${drawDiff['removed'].length} drawing(s)');
      }
    }

    if (diff.containsKey('backgroundColor')) {
      changes.add('Changed background color');
    }

    if (diff.containsKey('backgroundImagePath')) {
      changes.add('Changed background image');
    }

    if (diff.containsKey('isDrawingMode')) {
      changes.add(diff['isDrawingMode'] ? 'Entered drawing mode' : 'Exited drawing mode');
    }

    return changes.isNotEmpty ? changes.join(', ') : 'Canvas modified';
  }

  /// Create a new history node
  static HistoryNode createNode({
    required String id,
    required CanvasState oldState,
    required CanvasState newState,
    required String parentId,
    ui.Image? thumbnail,
  }) {
    final diff = calculateStateDiff(oldState, newState);
    final description = generateDescription(diff);

    return HistoryNode(
      id: id,
      timestamp: DateTime.now(),
      description: description,
      thumbnail: thumbnail,
      stateDiff: diff,
      parentId: parentId,
    );
  }

  /// Add a node to the history tree
  static HistoryTree addNodeToTree(HistoryTree tree, HistoryNode node) {
    final updatedNodes = Map<String, HistoryNode>.from(tree.nodes);
    updatedNodes[node.id] = node;

    // Update parent's child list
    if (node.parentId != null && updatedNodes.containsKey(node.parentId)) {
      final parent = updatedNodes[node.parentId]!;
      final updatedParent = parent.copyWith(
        childIds: [...parent.childIds, node.id],
      );
      updatedNodes[node.parentId!] = updatedParent;
    }

    // Limit history size by removing old nodes
    if (updatedNodes.length > maxHistorySize) {
      _pruneOldNodes(updatedNodes, tree.rootNodeId);
    }

    return tree.copyWith(
      nodes: updatedNodes,
      currentNodeId: node.id,
    );
  }

  /// Jump to a specific node in history
  static CanvasState jumpToNode(CanvasState currentState, HistoryNode targetNode) {
    // Start from the root state and apply diffs along the path
    CanvasState result = CanvasState.initial();

    final path = _getPathToNode(currentState.historyTree, targetNode.id);
    for (final node in path) {
      result = applyDiff(result, node.stateDiff);
    }

    return result.copyWith(
      historyTree: currentState.historyTree.copyWith(currentNodeId: targetNode.id),
    );
  }

  /// Get the path from root to a specific node
  static List<HistoryNode> _getPathToNode(HistoryTree tree, String nodeId) {
    final path = <HistoryNode>[];
    String? currentId = nodeId;

    while (currentId != null && currentId != tree.rootNodeId) {
      final node = tree.nodes[currentId];
      if (node != null) {
        path.insert(0, node);
      }
      currentId = node?.parentId;
    }

    return path;
  }

  /// Prune old nodes to maintain history size limit
  static void _pruneOldNodes(Map<String, HistoryNode> nodes, String rootId) {
    // Simple pruning: remove nodes that are too far from current branches
    // This is a basic implementation - could be made more sophisticated
    final toRemove = <String>[];

    for (final entry in nodes.entries) {
      if (entry.key != rootId && !_isNodeReachable(nodes, rootId, entry.key)) {
        toRemove.add(entry.key);
      }
    }

    for (final id in toRemove) {
      nodes.remove(id);
    }
  }

  /// Check if a node is reachable from root
  static bool _isNodeReachable(Map<String, HistoryNode> nodes, String rootId, String targetId) {
    final visited = <String>{};

    bool traverse(String id) {
      if (visited.contains(id)) return false;
      visited.add(id);

      if (id == targetId) return true;

      final node = nodes[id];
      if (node == null) return false;

      for (final childId in node.childIds) {
        if (traverse(childId)) return true;
      }

      return false;
    }

    return traverse(rootId);
  }

  /// Helper method to calculate list differences
  static Map<String, dynamic> _listDiff<T>(List<T> oldList, List<T> newList) {
    final added = <T>[];
    final removed = <T>[];
    final modified = <int>[];

    // Simple diff - could be made more sophisticated
    final maxLength = max(oldList.length, newList.length);

    for (int i = 0; i < maxLength; i++) {
      if (i >= oldList.length) {
        added.add(newList[i]);
      } else if (i >= newList.length) {
        removed.add(oldList[i]);
      } else if (oldList[i] != newList[i]) {
        modified.add(i);
      }
    }

    return {
      'added': added,
      'removed': removed,
      'modified': modified,
    };
  }

  /// Apply list diff
  static List<T> _applyListDiff<T>(List<T> baseList, Map<String, dynamic> diff) {
    final result = List<T>.from(baseList);

    // This is a simplified implementation
    // In a real scenario, you'd need more sophisticated merging logic
    final added = diff['added'] as List<T>? ?? [];
    final removed = diff['removed'] as List<T>? ?? [];

    result.addAll(added);
    for (final item in removed) {
      result.remove(item);
    }

    return result;
  }

  /// Parse brush type from string
  static BrushType _parseBrushType(String typeString) {
    switch (typeString) {
      case 'BrushType.brush':
        return BrushType.brush;
      case 'BrushType.eraser':
        return BrushType.eraser;
      case 'BrushType.marker':
        return BrushType.marker;
      default:
        return BrushType.brush;
    }
  }
}