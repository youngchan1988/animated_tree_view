import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:animated_tree_view/support/my_platform.dart';
import 'package:animated_tree_view/tree_view/tree_view_state_helper.dart';
import 'package:animated_tree_view/tree_view/widgets/multi_value_listenable_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../providers/tree_selection_provider.dart';

typedef DropFeedback<T> = Widget Function(List<T> node);
typedef OnDropWillAccept<T> = bool Function(List<T> draggedNode, T targetNode);
typedef OnDropAccept<T> = void Function(List<T> draggedNode, T targetNode);

class ExpandableNodeItem<Data, Tree extends ITreeNode<Data>>
    extends StatelessWidget {
  final TreeNodeWidgetBuilder<Tree> builder;
  final AutoScrollController scrollController;
  final AnimatedListStateController animatedListStateController;
  final Tree node;
  final Animation<double> animation;
  final Indentation indentation;
  final ExpansionIndicatorBuilder<Data>? expansionIndicatorBuilder;
  final bool remove;
  final int? index;
  final ValueSetter<Tree>? onItemTap;
  final ValueSetter<Tree>? onItemDoubleTap;
  final ValueSetter<Tree>? onItemSecondaryTap;
  final Function(Tree, TapDownDetails)? onItemSecondaryTapDown;
  final Function(Tree, TapUpDetails)? onItemSecondaryTapUp;
  final ValueSetter<Tree>? onItemLongPress;
  final ValueSetter<Tree> onToggleExpansion;
  final bool showRootNode;
  final LastChildCacheManager lastChildCacheManager;
  final bool enableDragDrop;
  final DropFeedback<Tree>? dragFeedBack;
  final OnDropWillAccept<Tree>? onDropWillAccept;
  final OnDropAccept<Tree>? onDropAccept;

  static Widget insertedNode<Data, Tree extends ITreeNode<Data>>({
    required int index,
    required Tree node,
    required TreeNodeWidgetBuilder<Tree> builder,
    required AutoScrollController scrollController,
    required AnimatedListStateController<Data> animatedListStateController,
    required Animation<double> animation,
    required ExpansionIndicatorBuilder<Data>? expansionIndicator,
    required ValueSetter<Tree>? onItemTap,
    ValueSetter<Tree>? onItemDoubleTap,
    ValueSetter<Tree>? onItemSecondaryTap,
    Function(Tree, TapDownDetails)? onItemSecondaryTapDown,
    Function(Tree, TapUpDetails)? onItemSecondaryTapUp,
    ValueSetter<Tree>? onItemLongPress,
    required ValueSetter<Tree> onToggleExpansion,
    required bool showRootNode,
    required Indentation indentation,
    required LastChildCacheManager lastChildCacheManager,
    bool enableDragDrop = false,
    DropFeedback<Tree>? dragFeedBack,
    OnDropWillAccept<Tree>? onDropWillAccept,
    OnDropAccept<Tree>? onDropAccept,
  }) {
    // return ValueListenableBuilder<INode>(
    //   key: ValueKey(node.key + index.toString()),
    //   valueListenable: node,
    //   builder: (context, treeNode, _) {
    return MultiValueListenableBuilder(
      key: ValueKey(node.key + index.toString()),
      valueListenables: [
        node,
        node.listenableData,
        node.hoverNotifier,
        node.selectedNotifier,
      ],
      builder: (context, data, _) => ExpandableNodeItem<Data, Tree>(
        builder: builder,
        scrollController: scrollController,
        animatedListStateController: animatedListStateController,
        node: node,
        index: index,
        animation: animation,
        indentation: indentation,
        expansionIndicatorBuilder: expansionIndicator,
        onToggleExpansion: onToggleExpansion,
        onItemTap: onItemTap,
        onItemDoubleTap: onItemDoubleTap,
        onItemSecondaryTap: onItemSecondaryTap,
        onItemSecondaryTapDown: onItemSecondaryTapDown,
        onItemSecondaryTapUp: onItemSecondaryTapUp,
        onItemLongPress: onItemLongPress,
        showRootNode: showRootNode,
        lastChildCacheManager: lastChildCacheManager,
        enableDragDrop: enableDragDrop,
        dragFeedBack: dragFeedBack,
        onDropWillAccept: onDropWillAccept,
        onDropAccept: onDropAccept,
      ),
    );
    //   },
    // );
  }

  static Widget removedNode<Data, Tree extends ITreeNode<Data>>({
    required Tree node,
    required TreeNodeWidgetBuilder<Tree> builder,
    required AutoScrollController scrollController,
    required AnimatedListStateController<Data> animatedListStateController,
    required Animation<double> animation,
    required ExpansionIndicatorBuilder<Data>? expansionIndicator,
    required ValueSetter<Tree>? onItemTap,
    ValueSetter<Tree>? onItemDoubleTap,
    ValueSetter<Tree>? onItemSecondaryTap,
    Function(Tree, TapDownDetails)? onItemSecondaryTapDown,
    Function(Tree, TapUpDetails)? onItemSecondaryTapUp,
    ValueSetter<Tree>? onItemLongPress,
    required ValueSetter<Tree> onToggleExpansion,
    required bool showRootNode,
    required Indentation indentation,
    required LastChildCacheManager lastChildCacheManager,
  }) {
    return ExpandableNodeItem<Data, Tree>(
      key: ValueKey(node.key),
      builder: builder,
      scrollController: scrollController,
      animatedListStateController: animatedListStateController,
      node: node,
      remove: true,
      animation: animation,
      indentation: indentation,
      expansionIndicatorBuilder: expansionIndicator,
      onItemTap: onItemTap,
      onItemDoubleTap: onItemDoubleTap,
      onItemSecondaryTap: onItemSecondaryTap,
      onItemSecondaryTapDown: onItemSecondaryTapDown,
      onItemSecondaryTapUp: onItemSecondaryTapUp,
      onItemLongPress: onItemLongPress,
      onToggleExpansion: onToggleExpansion,
      showRootNode: showRootNode,
      lastChildCacheManager: lastChildCacheManager,
    );
  }

  const ExpandableNodeItem({
    super.key,
    required this.builder,
    required this.scrollController,
    required this.animatedListStateController,
    required this.node,
    required this.animation,
    required this.onToggleExpansion,
    this.index,
    this.remove = false,
    this.expansionIndicatorBuilder,
    this.onItemTap,
    this.onItemDoubleTap,
    this.onItemSecondaryTap,
    this.onItemSecondaryTapDown,
    this.onItemSecondaryTapUp,
    this.onItemLongPress,
    required this.showRootNode,
    required this.indentation,
    required this.lastChildCacheManager,
    this.enableDragDrop = false,
    this.dragFeedBack,
    this.onDropWillAccept,
    this.onDropAccept,
  });

  @override
  Widget build(BuildContext context) {
    final itemContainer = ExpandableNodeContainer<Tree>(
      key: ValueKey("container#$key"),
      animation: animation,
      node: node,
      indentation: indentation,
      minLevelToIndent: showRootNode ? 0 : 1,
      lastChildCacheManager: lastChildCacheManager,
      expansionIndicator: node.childrenAsList.isEmpty
          ? null
          : expansionIndicatorBuilder?.call(context, node),
      onTap: remove
          ? null
          : (item) {
              final selectionProvider = TreeSelectionProvider.of(context);
              final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
              var isCtrlOrCmdPressed = false;
              if (isWeb) {
                isCtrlOrCmdPressed = HardwareKeyboard.instance.isControlPressed;
              } else {
                if (isMacOs) {
                  isCtrlOrCmdPressed = HardwareKeyboard.instance.isMetaPressed;
                } else if (isLinux || isWindows || isFuchsia) {
                  isCtrlOrCmdPressed =
                      HardwareKeyboard.instance.isControlPressed;
                }
              }

              if (isShiftPressed) {
                selectionProvider.multipleSelectNode(
                    node, index ?? 0, animatedListStateController.list);
              } else if (isCtrlOrCmdPressed) {
                selectionProvider.checkSelectNode(item);
              } else {
                onToggleExpansion(item);
                selectionProvider.radioSelectNode(item);
                onItemTap?.call(item);
              }
            },
      onDoubleTap: remove ? null : (item) => onItemDoubleTap?.call(item),
      onSecondaryTapUp: remove
          ? null
          : (item, details) => onItemSecondaryTapUp?.call(item, details),
      onSecondaryTapDown: remove
          ? null
          : (item, details) => onItemSecondaryTapDown?.call(item, details),
      onSecondaryTap: remove ? null : (item) => onItemSecondaryTap?.call(item),
      onLongPress: remove ? null : (item) => onItemLongPress?.call(item),
      onHover: remove
          ? null
          : (item, hovered) {
              item.hovered = hovered;
            },
      enableDragDrop: enableDragDrop,
      dragFeedBack: dragFeedBack,
      onDropWillAccept: onDropWillAccept,
      onDropAccept: onDropAccept,
      child: builder(context, node),
    );

    if (index == null || remove) return itemContainer;

    return AutoScrollTag(
      key: ValueKey("tag#${node.key}"),
      controller: scrollController,
      index: index!,
      child: itemContainer,
    );
  }
}

class ExpandableNodeContainer<Tree extends ITreeNode> extends StatelessWidget {
  final Animation<double> animation;
  final ValueSetter<Tree>? onTap;
  final ValueSetter<Tree>? onDoubleTap;
  final ValueSetter<Tree>? onSecondaryTap;
  final Function(Tree, TapDownDetails)? onSecondaryTapDown;
  final Function(Tree, TapUpDetails)? onSecondaryTapUp;
  final ValueSetter<Tree>? onLongPress;
  final Function(Tree, bool)? onHover;
  final Tree node;
  final ExpansionIndicator? expansionIndicator;
  final Indentation indentation;
  final Widget child;
  final int minLevelToIndent;
  final LastChildCacheManager lastChildCacheManager;
  final bool enableDragDrop;
  final DropFeedback<Tree>? dragFeedBack;
  final OnDropWillAccept<Tree>? onDropWillAccept;
  final OnDropAccept<Tree>? onDropAccept;

  const ExpandableNodeContainer({
    super.key,
    required this.animation,
    required this.onTap,
    this.onDoubleTap,
    this.onSecondaryTap,
    this.onSecondaryTapDown,
    this.onSecondaryTapUp,
    this.onLongPress,
    this.onHover,
    required this.child,
    required this.node,
    required this.indentation,
    required this.minLevelToIndent,
    required this.lastChildCacheManager,
    this.expansionIndicator,
    this.enableDragDrop = false,
    this.dragFeedBack,
    this.onDropWillAccept,
    this.onDropAccept,
  }) : assert(!enableDragDrop || dragFeedBack != null);

  @override
  Widget build(BuildContext context) {
    final selectionProvider = TreeSelectionProvider.of(context);
    final theme = Theme.of(context);
    final itemChild = SizeTransition(
      axis: Axis.vertical,
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: Ink(
        color:
            node.isSelected ? theme.colorScheme.primary.withAlpha(180) : null,
        child: InkWell(
          // focusNode: node.focusNode,
          onTap: () {
            // node.focusNode.requestFocus();
            onTap?.call(node);
          },
          onDoubleTap: onDoubleTap == null ? null : () => onDoubleTap!(node),
          onSecondaryTap:
              onSecondaryTap == null ? null : () => onSecondaryTap!(node),
          onSecondaryTapDown: onSecondaryTapDown == null
              ? null
              : (details) => onSecondaryTapDown!(node, details),
          onSecondaryTapUp: onSecondaryTapUp == null
              ? null
              : (details) => onSecondaryTapUp!(node, details),
          onLongPress: enableDragDrop || onLongPress == null
              ? null
              : () => onLongPress!(node),
          onHover:
              onHover == null ? null : (hovered) => onHover!(node, hovered),
          child: Indent(
            indentation: indentation,
            node: node,
            minLevelToIndent: minLevelToIndent,
            lastChildCacheManager: lastChildCacheManager,
            child: expansionIndicator == null
                ? child
                : PositionedExpansionIndicator(
                    expansionIndicator: expansionIndicator!,
                    child: child,
                  ),
          ),
        ),
      ),
    );
    if (!enableDragDrop) {
      return itemChild;
    }

    return DragTarget<List<Tree>>(
      onWillAcceptWithDetails: (details) {
        // 判断 draggedNode 是否可以被接受
        if (details.data.contains(node)) {
          debugPrint("draggedNode contains node");
          return false;
        }
        // find the minimum level of the draggedNode
        var minLevelToIndent = details.data[0].level;
        var minLevelNode = details.data[0];
        for (var node in details.data) {
          if (node.isRoot) {
            debugPrint("draggedNode is root");
            return false;
          }
          if (node.level < minLevelToIndent) {
            minLevelToIndent = node.level;
            minLevelNode = node;
          }
        }
        if (minLevelNode.parent == node) {
          debugPrint(
              "draggedNode is parent of node: parent key= ${minLevelNode.parent?.key} and node key= ${node.key}");
          return false;
        }
        debugPrint("draggedNode can be accepted");
        return onDropWillAccept?.call(details.data, node) ?? false;
      },
      onAcceptWithDetails: (details) {
        debugPrint("onAcceptWithDetails");
        // 将 draggedNode 添加到当前节点的 children 中
        onDropAccept?.call(details.data, node);
      },
      builder: (context, candidateData, rejectedData) {
        Color willAcceptColor = Colors.transparent;
        if (candidateData.isNotEmpty) {
          willAcceptColor = Theme.of(context).colorScheme.primary.withAlpha(60);
        }
        List<Tree> draggedNode = [];
        if (selectionProvider.selectedNodes.contains(node)) {
          draggedNode =
              selectionProvider.selectedNodes.map((e) => e as Tree).toList();
        } else {
          draggedNode = [node];
        }
        return LongPressDraggable<List<Tree>>(
          data: draggedNode,
          feedback: dragFeedBack?.call(draggedNode) ?? itemChild,
          child: candidateData.isNotEmpty || rejectedData.isNotEmpty
              ? Container(
                  color: willAcceptColor,
                  child: itemChild,
                )
              : itemChild,
        );
      },
    );
  }
}
