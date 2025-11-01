import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/canvas_cubit.dart';
import '../../cubit/canvas_state.dart';
import '../../models/history_entry.dart';
import 'canvas_thumbnail.dart';

class HistoryTimeline extends StatefulWidget {
  const HistoryTimeline({super.key});

  @override
  State<HistoryTimeline> createState() => _HistoryTimelineState();
}

class _HistoryTimelineState extends State<HistoryTimeline> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      builder: (context, state) {
        final history = state.history;
        final currentIndex = state.currentHistoryIndex;

        return Container(
          width: 300,
          height: 400,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.history, color: Colors.white),
                    const SizedBox(width: 8),
                    const Text(
                      'History Timeline',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // Timeline
              Expanded(
                child: history.isEmpty
                  ? const Center(child: Text('No history available', style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final entry = history[index];
                        final isCurrent = index == currentIndex;

                        return _HistoryEntryTile(
                          entry: entry,
                          isCurrent: isCurrent,
                          onTap: () => _jumpToEntry(context, index),
                        );
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _jumpToEntry(BuildContext context, int index) {
    final cubit = context.read<CanvasCubit>();
    final targetState = cubit.state.history[index].state;
    cubit.emit(targetState.copyWith(
      history: cubit.state.history,
      currentHistoryIndex: index,
    ));
  }
}

class _HistoryEntryTile extends StatefulWidget {
  final HistoryEntry entry;
  final bool isCurrent;
  final VoidCallback onTap;

  const _HistoryEntryTile({
    required this.entry,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  State<_HistoryEntryTile> createState() => _HistoryEntryTileState();
}

class _HistoryEntryTileState extends State<_HistoryEntryTile> {
  ui.Image? _thumbnail;

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(widget.entry.timestamp);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: widget.isCurrent
              ? Colors.blue.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.isCurrent ? Colors.blue : Colors.white.withOpacity(0.2),
            width: widget.isCurrent ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            SizedBox(
              width: 40,
              height: 30,
              child: CanvasThumbnail(
                state: widget.entry.state,
                width: 40,
                height: 30,
                onThumbnailGenerated: (image) {
                  if (mounted) {
                    setState(() {
                      _thumbnail = image;
                    });
                  }
                },
              ),
            ),

            const SizedBox(width: 8),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.entry.actionDescription ?? 'Action',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: widget.isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),

            // Current indicator
            if (widget.isCurrent)
              const Icon(
                Icons.radio_button_checked,
                color: Colors.blue,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s ago';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}