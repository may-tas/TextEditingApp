import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'canvas_state.dart';

class HistoryNode {
  final String id;
  final CanvasState state;
  final DateTime timestamp;
  final ui.Image? thumbnail;
  final List<HistoryNode> children;
  final HistoryNode? parent;
  final String? actionDescription;

  const HistoryNode({
    required this.id,
    required this.state,
    required this.timestamp,
    this.thumbnail,
    this.children = const [],
    this.parent,
    this.actionDescription,
  });

  HistoryNode copyWith({
    String? id,
    CanvasState? state,
    DateTime? timestamp,
    ui.Image? thumbnail,
    List<HistoryNode>? children,
    HistoryNode? parent,
    String? actionDescription,
  }) {
    return HistoryNode(
      id: id ?? this.id,
      state: state ?? this.state,
      timestamp: timestamp ?? this.timestamp,
      thumbnail: thumbnail ?? this.thumbnail,
      children: children ?? this.children,
      parent: parent ?? this.parent,
      actionDescription: actionDescription ?? this.actionDescription,
    );
  }

  HistoryNode addChild(HistoryNode child) {
    return copyWith(
      children: [...children, child],
    );
  }

  bool get isLeaf => children.isEmpty;

  bool get hasBranches => children.length > 1;

  int get depth {
    int d = 0;
    HistoryNode? current = parent;
    while (current != null) {
      d++;
      current = current.parent;
    }
    return d;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryNode &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}