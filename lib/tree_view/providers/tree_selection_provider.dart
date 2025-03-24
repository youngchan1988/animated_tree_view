import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TreeSelectionProvider extends InheritedWidget {
  final List<ITreeNode> _selectedNodes = [];

  TreeSelectionProvider({
    super.key,
    required super.child,
  });

  void radioSelectNode(ITreeNode node) {
    for (var n in _selectedNodes) {
      n.select = false;
    }
    clearSelection();
    _selectedNodes.add(node);
    node.select = true;
  }

  void checkSelectNode(ITreeNode node) {
    if (_selectedNodes.contains(node)) {
      _selectedNodes.remove(node);
    } else {
      _selectedNodes.add(node);
    }
    node.select = !node.isSelected;
  }

  void multipleSelectNode(ITreeNode node, int index, List<ITreeNode> list) {
    if (_selectedNodes.isNotEmpty) {
      final lastNode = _selectedNodes.last;
      final lastIndex = list.indexOf(lastNode);
      if (index < lastIndex) {
        for (var i = index; i <= lastIndex; i++) {
          final n = list[i];
          if (!_selectedNodes.contains(n)) {
            _selectedNodes.add(n);
          }

          n.select = true;
        }
      } else {
        for (var i = lastIndex; i <= index; i++) {
          final n = list[i];
          if (!_selectedNodes.contains(n)) {
            _selectedNodes.add(n);
          }
          n.select = true;
        }
      }
    } else {
      _selectedNodes.add(node);
      node.select = true;
    }
  }

  /// Clears all selected nodes.
  void clearSelection() {
    _selectedNodes.clear();
  }

  List<ITreeNode> get selectedNodes => _selectedNodes;

  static TreeSelectionProvider of(BuildContext context) {
    final TreeSelectionProvider? result =
        context.dependOnInheritedWidgetOfExactType<TreeSelectionProvider>();
    assert(result != null, 'No TreeSelectionProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(TreeSelectionProvider old) {
    return listEquals(old._selectedNodes, _selectedNodes);
  }
}
