import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'canvas_state.dart';

class HistoryEntry {
  final CanvasState state;
  final DateTime timestamp;
  final String? actionDescription;
  ui.Image? thumbnail;

  HistoryEntry({
    required this.state,
    required this.timestamp,
    this.actionDescription,
    this.thumbnail,
  });

  HistoryEntry copyWith({
    CanvasState? state,
    DateTime? timestamp,
    String? actionDescription,
    ui.Image? thumbnail,
  }) {
    return HistoryEntry(
      state: state ?? this.state,
      timestamp: timestamp ?? this.timestamp,
      actionDescription: actionDescription ?? this.actionDescription,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}