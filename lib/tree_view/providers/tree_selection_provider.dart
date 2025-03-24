import 'package:animated_tree_view/tree_view/tree_node.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TreeSelectionProvider extends InheritedWidget {
  final List<String> _selectedNodePaths = [];

  TreeSelectionProvider({
    super.key,
    required super.child,
  });

  /// Checks if a node with the given [nodeKey] is selected.
  bool isNodeSelected(String nodeKey) {
    return _selectedNodePaths.contains(nodeKey);
  }

  /// Toggles the selection state of a node with the given [nodeKey].
  void toggleSelection(String nodeKey) {
    if (_selectedNodePaths.contains(nodeKey)) {
      _selectedNodePaths.remove(nodeKey);
    } else {
      _selectedNodePaths.add(nodeKey);
    }
  }

  void radioSelectNode(ITreeNode node) {
    for (var p in _selectedNodePaths) {
      final n = node.root.elementAt(p) as ITreeNode;
      n.select = false;
    }
    clearSelection();
    _selectedNodePaths.add(node.path);
    node.select = true;
  }

  /// Sets the selection state of multiple nodes with the given [nodeKeys].
  void setSelections(List<String> nodeKeys) {
    _selectedNodePaths.clear();
    _selectedNodePaths.addAll(nodeKeys);
  }

  /// Clears all selected nodes.
  void clearSelection() {
    _selectedNodePaths.clear();
  }

  List<String> get selectedNodePaths => _selectedNodePaths;

  static TreeSelectionProvider of(BuildContext context) {
    final TreeSelectionProvider? result =
        context.dependOnInheritedWidgetOfExactType<TreeSelectionProvider>();
    assert(result != null, 'No TreeSelectionProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(TreeSelectionProvider old) {
    return listEquals(old._selectedNodePaths, _selectedNodePaths);
  }
}
