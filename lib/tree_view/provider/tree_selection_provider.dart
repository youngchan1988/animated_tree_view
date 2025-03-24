import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class TreeSelectionProvider extends InheritedWidget {
  final List<String> _selectedNodeKeys = [];

  TreeSelectionProvider({
    super.key,
    required super.child,
  });

  /// Checks if a node with the given [nodeKey] is selected.
  bool isNodeSelected(String nodeKey) {
    return _selectedNodeKeys.contains(nodeKey);
  }

  /// Toggles the selection state of a node with the given [nodeKey].
  void toggleSelection(String nodeKey) {
    if (_selectedNodeKeys.contains(nodeKey)) {
      _selectedNodeKeys.remove(nodeKey);
    } else {
      _selectedNodeKeys.add(nodeKey);
    }
  }

  /// Selects a single node with the given [nodeKey], deselecting all others.
  void radioSelect(String nodeKey) {
    _selectedNodeKeys.clear();
    _selectedNodeKeys.add(nodeKey);
  }

  /// Sets the selection state of multiple nodes with the given [nodeKeys].
  void setSelections(List<String> nodeKeys) {
    _selectedNodeKeys.clear();
    _selectedNodeKeys.addAll(nodeKeys);
  }

  /// Clears all selected nodes.
   void clearSelection() {
    _selectedNodeKeys.clear();
  }

  List<String> get selectedNodeKeys => _selectedNodeKeys;

  static TreeSelectionProvider of(BuildContext context) {
    final TreeSelectionProvider? result =
        context.dependOnInheritedWidgetOfExactType<TreeSelectionProvider>();
    assert(result != null, 'No TreeSelectionProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(TreeSelectionProvider old) {
    return listEquals(old._selectedNodeKeys, _selectedNodeKeys);
  }
}
