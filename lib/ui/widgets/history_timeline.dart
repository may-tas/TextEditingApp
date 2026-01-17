import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubit/canvas_cubit.dart';
import '../../cubit/canvas_state.dart';
import '../../models/history_model.dart';
import 'dart:ui' as ui;

class HistoryTimeline extends StatefulWidget {
  const HistoryTimeline({Key? key}) : super(key: key);

  @override
  State<HistoryTimeline> createState() => _HistoryTimelineState();
}

class _HistoryTimelineState extends State<HistoryTimeline> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CanvasCubit, CanvasState>(
      builder: (context, state) {
        final timelineNodes = state.historyTree.getTimelineNodes();

        if (timelineNodes.isEmpty) {
          return const SizedBox.shrink();
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: _isExpanded ? 300 : 60,
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Column(
            children: [
              // Header
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white24)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isExpanded ? Icons.history : Icons.history_toggle_off,
                        color: Colors.white,
                        size: 24,
                      ),
                      if (_isExpanded) ...[
                        const SizedBox(width: 8),
                        const Text(
                          'History',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${timelineNodes.length} steps',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Timeline
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: timelineNodes.length,
                  itemBuilder: (context, index) {
                    final node = timelineNodes[index];
                    final isCurrent = node.id == state.historyTree.currentNodeId;

                    return _HistoryNodeItem(
                      node: node,
                      isCurrent: isCurrent,
                      isExpanded: _isExpanded,
                      onTap: () => _jumpToNode(context, node),
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

  void _jumpToNode(BuildContext context, HistoryNode node) {
    final cubit = context.read<CanvasCubit>();
    cubit.jumpToHistoryNode(node);
  }
}

class _HistoryNodeItem extends StatelessWidget {
  final HistoryNode node;
  final bool isCurrent;
  final bool isExpanded;
  final VoidCallback onTap;

  const _HistoryNodeItem({
    required this.node,
    required this.isCurrent,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCurrent ? Colors.blue.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrent ? Colors.blue : Colors.white24,
            width: isCurrent ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 40,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey[800],
              ),
              child: node.thumbnail != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: RawImage(
                        image: node.thumbnail,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.image,
                      color: Colors.white54,
                      size: 20,
                    ),
            ),

            if (isExpanded) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      node.description,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatTimestamp(node.timestamp),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}