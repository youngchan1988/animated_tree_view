import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';

class FilesTreeView<T> extends StatelessWidget {
  final TreeNode<T> tree;
  final bool showRootNode;
  final ExpansionBehavior expansionBehavior;
  final ExpansionIndicatorBuilder? expansionIndicatorBuilder;
  final Indentation? indentation;
  final Duration? animationDuration;
  final bool enableDragDrop;
  final Widget? dragFeedBack;

  final ValueSetter<TreeNode<T>>? onItemTap;
  final TreeNodeWidgetBuilder<TreeNode<T>> itemBuilder;

  const FilesTreeView({
    super.key,
    required this.tree,
    this.showRootNode = true,
    this.expansionBehavior = ExpansionBehavior.none,
    this.expansionIndicatorBuilder,
    this.indentation,
    this.animationDuration,
    this.enableDragDrop = false,
    this.dragFeedBack,
    this.onItemTap,
    required this.itemBuilder,
  }) : assert(!enableDragDrop || dragFeedBack != null);

  @override
  Widget build(BuildContext context) {
    return TreeView.simpleTyped<T, TreeNode<T>>(
      tree: tree,
      showRootNode: showRootNode,
      expansionBehavior: expansionBehavior,
      expansionIndicatorBuilder: expansionIndicatorBuilder,
      indentation: indentation,
      enableReorder: false,
      animationDuration: animationDuration,
      onItemTap: onItemTap,
      builder: (context, node) {
        // 如果节点为叶子，则仅支持拖拽
        if (node.children.isEmpty) {
          return LongPressDraggable<TreeNode<T>>(
            data: node,
            feedback: FractionalTranslation(
              translation: const Offset(0.5, 0.5),
              child: Opacity(
                  opacity: 0.8,
                  child: Material(
                    child: SizedBox(
                      width: 200,
                      height: 52,
                      child: itemBuilder(context, node),
                    ),
                  )),
            ),
            child: itemBuilder(context, node),
          );
        }
        // 非叶子节点：支持拖拽和拖放目标
        return DragTarget<TreeNode<T>>(
          onWillAcceptWithDetails: (details) {
            return details.data.level > node.level;
          },
          onAcceptWithDetails: (draggedNodeDetails) {
            // 将 draggedNode 添加到当前节点的 children 中
            final draggedNode = draggedNodeDetails.data;
            draggedNode.delete();
            node.add(draggedNode);
          },
          builder: (context, candidateData, rejectedData) {
            return LongPressDraggable<TreeNode<T>>(
              data: node,
              feedback: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: Material(
                  child: SizedBox(
                    width: 200,
                    height: 52,
                    child: itemBuilder(context, node),
                  ),
                ),
              ),
              child: itemBuilder(context, node),
            );
          },
        );
      },
    );
  }
}
