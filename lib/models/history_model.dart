import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

/// Represents a node in the history tree
class HistoryNode extends Equatable {
  final String id;
  final DateTime timestamp;
  final String description;
  final ui.Image? thumbnail;
  final Map<String, dynamic> stateDiff; // Only store changes, not full state
  final List<String> childIds; // For branching
  final String? parentId;

  const HistoryNode({
    required this.id,
    required this.timestamp,
    required this.description,
    this.thumbnail,
    required this.stateDiff,
    this.childIds = const [],
    this.parentId,
  });

  HistoryNode copyWith({
    String? id,
    DateTime? timestamp,
    String? description,
    ui.Image? thumbnail,
    Map<String, dynamic>? stateDiff,
    List<String>? childIds,
    String? parentId,
  }) {
    return HistoryNode(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      stateDiff: stateDiff ?? this.stateDiff,
      childIds: childIds ?? this.childIds,
      parentId: parentId ?? this.parentId,
    );
  }

  @override
  List<Object?> get props => [id, timestamp, description, stateDiff, childIds, parentId];
}

/// Manages the history tree structure
class HistoryTree extends Equatable {
  final Map<String, HistoryNode> nodes;
  final String currentNodeId;
  final String rootNodeId;

  const HistoryTree({
    required this.nodes,
    required this.currentNodeId,
    required this.rootNodeId,
  });

  HistoryTree.initial()
      : nodes = {
          'root': HistoryNode(
            id: 'root',
            timestamp: DateTime.now(),
            description: 'Initial state',
            stateDiff: {},
          )
        },
        currentNodeId = 'root',
        rootNodeId = 'root';

  HistoryTree copyWith({
    Map<String, HistoryNode>? nodes,
    String? currentNodeId,
    String? rootNodeId,
  }) {
    return HistoryTree(
      nodes: nodes ?? this.nodes,
      currentNodeId: currentNodeId ?? this.currentNodeId,
      rootNodeId: rootNodeId ?? this.rootNodeId,
    );
  }

  /// Get the current node
  HistoryNode? get currentNode => nodes[currentNodeId];

  /// Get all nodes in chronological order (for timeline display)
  List<HistoryNode> getTimelineNodes() {
    final visited = <String>{};
    final result = <HistoryNode>[];

    void traverse(String nodeId) {
      if (visited.contains(nodeId)) return;
      visited.add(nodeId);

      final node = nodes[nodeId];
      if (node != null) {
        result.add(node);
        for (final childId in node.childIds) {
          traverse(childId);
        }
      }
    }

    traverse(rootNodeId);
    result.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Most recent first
    return result;
  }

  /// Check if we can undo
  bool get canUndo => currentNode?.parentId != null;

  /// Check if we can redo
  bool get canRedo => currentNode?.childIds.isNotEmpty ?? false;

  /// Get the path from root to current node
  List<HistoryNode> getCurrentPath() {
    final path = <HistoryNode>[];
    String? currentId = currentNodeId;

    while (currentId != null) {
      final node = nodes[currentId];
      if (node != null) {
        path.insert(0, node);
      }
      currentId = node?.parentId;
    }

    return path;
  }

  @override
  List<Object?> get props => [nodes, currentNodeId, rootNodeId];
}