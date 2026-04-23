import 'package:flutter_test/flutter_test.dart';
import 'package:texterra/cubit/canvas_cubit.dart';
import 'package:texterra/cubit/canvas_state.dart';
import 'package:texterra/models/history_model.dart';

void main() {
  group('History Tree Tests', () {
    test('Initial state has root node', () {
      final state = CanvasState.initial();
      expect(state.historyTree.nodes.containsKey('root'), true);
      expect(state.historyTree.currentNodeId, 'root');
    });

    test('History tree can add nodes', () {
      final tree = HistoryTree.initial();
      final node = HistoryNode(
        id: 'test_node',
        timestamp: DateTime.now(),
        description: 'Test change',
        stateDiff: {'test': 'value'},
        parentId: 'root',
      );

      final updatedTree = HistoryManager.addNodeToTree(tree, node);
      expect(updatedTree.nodes.containsKey('test_node'), true);
      expect(updatedTree.nodes['root']?.childIds.contains('test_node'), true);
    });

    test('Can jump to history node', () {
      final initialState = CanvasState.initial();
      final targetNode = HistoryNode(
        id: 'target',
        timestamp: DateTime.now(),
        description: 'Target state',
        stateDiff: {'textItems': []},
        parentId: 'root',
      );

      final result = HistoryManager.jumpToNode(initialState, targetNode);
      expect(result.historyTree.currentNodeId, 'target');
    });
  });
}