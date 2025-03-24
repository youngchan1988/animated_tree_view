// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';

/// A list whose items the user can interactively reorder by dragging.
///
/// {@youtube 560 315 https://www.youtube.com/watch?v=3fB1mxOsqJE}
///
/// This sample shows by dragging the user can reorder the items of the list.
/// The [onReorder] parameter is required and will be called when a child
/// widget is dragged to a new position.
///
/// {@tool dartpad}
///
/// ** See code in examples/api/lib/material/reorderable_list/reorderable_list_view.0.dart **
/// {@end-tool}
///
/// By default, on [TargetPlatformVariant.desktop] platforms each item will
/// have a drag handle added on top of it that will allow the user to grab it
/// to move the item. On [TargetPlatformVariant.mobile], no drag handle will be
/// added, but when the user long presses anywhere on the item it will start
/// moving the item. Displaying drag handles can be controlled with
/// [AnimatedReorderableListView.buildDefaultDragHandles].
///
/// All list items must have a key.
///
/// This example demonstrates using the [AnimatedReorderableListView.proxyDecorator] callback
/// to customize the appearance of a list item while it's being dragged.
///
/// {@tool dartpad}
/// While a drag is underway, the widget returned by the [AnimatedReorderableListView.proxyDecorator]
/// callback serves as a "proxy" (a substitute) for the item in the list. The proxy is
/// created with the original list item as its child. The [AnimatedReorderableListView.proxyDecorator]
/// callback in this example is similar to the default one except that it changes the
/// proxy item's background color.
///
/// ** See code in examples/api/lib/material/reorderable_list/reorderable_list_view.1.dart **
/// {@end-tool}
///
/// This example demonstrates using the [AnimatedReorderableListView.proxyDecorator] callback to
/// customize the appearance of a [Card] while it's being dragged.
///
/// {@tool dartpad}
/// The default [proxyDecorator] wraps the dragged item in a [Material] widget and animates
/// its elevation. This example demonstrates how to use the [AnimatedReorderableListView.proxyDecorator]
/// callback to update the dragged card elevation without inserted a new [Material] widget.
///
/// ** See code in examples/api/lib/material/reorderable_list/reorderable_list_view.2.dart **
/// {@end-tool}
class AnimatedReorderableListView extends _AnimatedScrollView {
  /// Creates a reorderable list from a pre-built list of widgets.
  ///
  /// This constructor is appropriate for lists with a small number of
  /// children because constructing the [List] requires doing work for every
  /// child that could possibly be displayed in the list view instead of just
  /// those children that are actually visible.
  ///
  /// See also:
  ///
  ///   * [AnimatedReorderableListView.builder], which allows you to build a reorderable
  ///     list where the items are built as needed when scrolling the list.

  /// Creates a reorderable list from widget items that are created on demand.
  ///
  /// This constructor is appropriate for list views with a large number of
  /// children because the builder is called only for those children
  /// that are actually visible.
  ///
  /// The `itemBuilder` callback will be called only with indices greater than
  /// or equal to zero and less than `itemCount`.
  ///
  /// The `itemBuilder` should always return a non-null widget, and actually
  /// create the widget instances when called. Avoid using a builder that
  /// returns a previously-constructed widget; if the list view's children are
  /// created in advance, or all at once when the [AnimatedReorderableListView] itself
  /// is created, it is more efficient to use the [AnimatedReorderableListView]
  /// constructor. Even more efficient, however, is to create the instances
  /// on demand using this constructor's `itemBuilder` callback.
  ///
  /// This example creates a list using the
  /// [AnimatedReorderableListView.builder] constructor. Using the [IndexedWidgetBuilder], The
  /// list items are built lazily on demand.
  /// {@tool dartpad}
  ///
  /// ** See code in examples/api/lib/material/reorderable_list/reorderable_list_view.reorderable_list_view_builder.0.dart **
  /// {@end-tool}
  /// See also:
  ///
  ///   * [AnimatedReorderableListView], which allows you to build a reorderable
  ///     list with all the items passed into the constructor.
  const AnimatedReorderableListView({
    super.key,
    required super.itemBuilder,
    super.initialItemCount,
    required this.onReorder,
    this.onReorderStart,
    this.onReorderEnd,
    this.itemExtent,
    this.itemExtentBuilder,
    this.prototypeItem,
    this.proxyDecorator,
    this.buildDefaultDragHandles = true,
    this.padding,
    this.header,
    this.footer,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.scrollController,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.anchor = 0.0,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.autoScrollerVelocityScalar,
  }) : assert(
          (itemExtent == null && prototypeItem == null) ||
              (itemExtent == null && itemExtentBuilder == null) ||
              (prototypeItem == null && itemExtentBuilder == null),
          'You can only pass one of itemExtent, prototypeItem and itemExtentBuilder.',
        );

  /// {@macro flutter.widgets.reorderable_list.itemBuilder}
  // final IndexedWidgetBuilder itemBuilder;

  /// {@macro flutter.widgets.reorderable_list.itemCount}
  // final int itemCount;

  /// {@macro flutter.widgets.reorderable_list.onReorder}
  final ReorderCallback onReorder;

  /// {@macro flutter.widgets.reorderable_list.onReorderStart}
  final void Function(int index)? onReorderStart;

  /// {@macro flutter.widgets.reorderable_list.onReorderEnd}
  final void Function(int index)? onReorderEnd;

  /// {@macro flutter.widgets.reorderable_list.proxyDecorator}
  final ReorderItemProxyDecorator? proxyDecorator;

  /// If true: on desktop platforms, a drag handle is stacked over the
  /// center of each item's trailing edge; on mobile platforms, a long
  /// press anywhere on the item starts a drag.
  ///
  /// The default desktop drag handle is just an [Icons.drag_handle]
  /// wrapped by a [ReorderableDragStartListener]. On mobile
  /// platforms, the entire item is wrapped with a
  /// [ReorderableDelayedDragStartListener].
  ///
  /// To change the appearance or the layout of the drag handles, make
  /// this parameter false and wrap each list item, or a widget within
  /// each list item, with [ReorderableDragStartListener] or
  /// [ReorderableDelayedDragStartListener], or a custom subclass
  /// of [ReorderableDragStartListener].
  ///
  /// The following sample specifies `buildDefaultDragHandles: false`, and
  /// uses a [Card] at the leading edge of each item for the item's drag handle.
  ///
  /// {@tool dartpad}
  ///
  ///
  /// ** See code in examples/api/lib/material/reorderable_list/reorderable_list_view.build_default_drag_handles.0.dart **
  /// {@end-tool}
  final bool buildDefaultDragHandles;

  /// {@macro flutter.widgets.reorderable_list.padding}
  final EdgeInsets? padding;

  /// A non-reorderable header item to show before the items of the list.
  ///
  /// If null, no header will appear before the list.
  final Widget? header;

  /// A non-reorderable footer item to show after the items of the list.
  ///
  /// If null, no footer will appear after the list.
  final Widget? footer;

  /// {@macro flutter.widgets.scroll_view.scrollDirection}
  final Axis scrollDirection;

  /// {@macro flutter.widgets.scroll_view.reverse}
  final bool reverse;

  /// {@macro flutter.widgets.scroll_view.controller}
  final ScrollController? scrollController;

  /// {@macro flutter.widgets.scroll_view.primary}

  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [scrollController] is null.
  final bool? primary;

  /// {@macro flutter.widgets.scroll_view.physics}
  final ScrollPhysics? physics;

  /// {@macro flutter.widgets.scroll_view.shrinkWrap}
  final bool shrinkWrap;

  /// {@macro flutter.widgets.scroll_view.anchor}
  final double anchor;

  /// {@macro flutter.rendering.RenderViewportBase.cacheExtent}
  final double? cacheExtent;

  /// {@macro flutter.widgets.scrollable.dragStartBehavior}
  final DragStartBehavior dragStartBehavior;

  /// {@macro flutter.widgets.scroll_view.keyboardDismissBehavior}
  ///
  /// The default is [ScrollViewKeyboardDismissBehavior.manual]
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// {@macro flutter.widgets.scrollable.restorationId}
  final String? restorationId;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;

  /// {@macro flutter.widgets.list_view.itemExtent}
  final double? itemExtent;

  /// {@macro flutter.widgets.list_view.itemExtentBuilder}
  final ItemExtentBuilder? itemExtentBuilder;

  /// {@macro flutter.widgets.list_view.prototypeItem}
  final Widget? prototypeItem;

  /// {@macro flutter.widgets.EdgeDraggingAutoScroller.velocityScalar}
  ///
  /// {@macro flutter.widgets.SliverReorderableList.autoScrollerVelocityScalar.default}
  final double? autoScrollerVelocityScalar;

  @override
  State<AnimatedReorderableListView> createState() =>
      AnimatedReorderableListViewState();
}

class AnimatedReorderableListViewState
    extends _AnimatedScrollViewState<AnimatedReorderableListView> {
  Widget _itemBuilder(BuildContext context, int index, animation) {
    final Widget item = widget.itemBuilder(context, index, animation);
    assert(() {
      if (item.key == null) {
        throw FlutterError(
          'Every item of ReorderableListView must have a key.',
        );
      }
      return true;
    }());

    final Key itemGlobalKey =
        _ReorderableListViewChildGlobalKey(item.key!, this);

    if (widget.buildDefaultDragHandles) {
      switch (Theme.of(context).platform) {
        case TargetPlatform.linux:
        case TargetPlatform.windows:
        case TargetPlatform.macOS:
          switch (widget.scrollDirection) {
            case Axis.horizontal:
              return Stack(
                key: itemGlobalKey,
                children: <Widget>[
                  item,
                  Positioned.directional(
                    textDirection: Directionality.of(context),
                    start: 0,
                    end: 0,
                    bottom: 8,
                    child: Align(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                    ),
                  ),
                ],
              );
            case Axis.vertical:
              return Stack(
                key: itemGlobalKey,
                children: <Widget>[
                  item,
                  Positioned.directional(
                    textDirection: Directionality.of(context),
                    top: 0,
                    bottom: 0,
                    end: 8,
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                    ),
                  ),
                ],
              );
          }

        case TargetPlatform.iOS:
        case TargetPlatform.android:
        case TargetPlatform.fuchsia:
          return ReorderableDelayedDragStartListener(
            key: itemGlobalKey,
            index: index,
            child: item,
          );
      }
    }

    return KeyedSubtree(
      key: itemGlobalKey,
      child: item,
    );
  }

  Widget _proxyDecorator(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (BuildContext context, Widget? child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 6, animValue)!;
        return Material(
          elevation: elevation,
          child: child,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    assert(debugCheckHasOverlay(context));

    // If there is a header or footer we can't just apply the padding to the list,
    // so we break it up into padding for the header, footer and padding for the list.
    final EdgeInsets padding = widget.padding ?? EdgeInsets.zero;
    double? start = widget.header == null ? null : 0.0;
    double? end = widget.footer == null ? null : 0.0;
    if (widget.reverse) {
      (start, end) = (end, start);
    }

    final EdgeInsets startPadding, endPadding, listPadding;
    (startPadding, endPadding, listPadding) = switch (widget.scrollDirection) {
      Axis.horizontal || Axis.vertical when (start ?? end) == null => (
          EdgeInsets.zero,
          EdgeInsets.zero,
          padding
        ),
      Axis.horizontal => (
          padding.copyWith(left: 0),
          padding.copyWith(right: 0),
          padding.copyWith(left: start, right: end)
        ),
      Axis.vertical => (
          padding.copyWith(top: 0),
          padding.copyWith(bottom: 0),
          padding.copyWith(top: start, bottom: end)
        ),
    };
    final (EdgeInsets headerPadding, EdgeInsets footerPadding) = widget.reverse
        ? (startPadding, endPadding)
        : (endPadding, startPadding);

    return CustomScrollView(
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      controller: widget.scrollController,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      anchor: widget.anchor,
      cacheExtent: widget.cacheExtent,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      slivers: <Widget>[
        if (widget.header != null)
          SliverPadding(
            padding: headerPadding,
            sliver: SliverToBoxAdapter(child: widget.header),
          ),
        SliverPadding(
          padding: listPadding,
          sliver: SliverAnimatedReorderableList(
            key: _sliverAnimatedMultiBoxKey,
            itemBuilder: _itemBuilder,
            itemExtent: widget.itemExtent,
            itemExtentBuilder: widget.itemExtentBuilder,
            prototypeItem: widget.prototypeItem,
            initialItemCount: widget.initialItemCount,
            onReorder: widget.onReorder,
            onReorderStart: widget.onReorderStart,
            onReorderEnd: widget.onReorderEnd,
            proxyDecorator: widget.proxyDecorator ?? _proxyDecorator,
            autoScrollerVelocityScalar: widget.autoScrollerVelocityScalar,
          ),
        ),
        if (widget.footer != null)
          SliverPadding(
            padding: footerPadding,
            sliver: SliverToBoxAdapter(child: widget.footer),
          ),
      ],
    );
  }
}

// A global key that takes its identity from the object and uses a value of a
// particular type to identify itself.
//
// The difference with GlobalObjectKey is that it uses [==] instead of [identical]
// of the objects used to generate widgets.
@optionalTypeArgs
class _ReorderableListViewChildGlobalKey extends GlobalObjectKey {
  const _ReorderableListViewChildGlobalKey(this.subKey, this.state)
      : super(subKey);

  final Key subKey;
  final State state;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _ReorderableListViewChildGlobalKey &&
        other.subKey == subKey &&
        other.state == state;
  }

  @override
  int get hashCode => Object.hash(subKey, state);
}

/// A sliver list that allows the user to interactively reorder the list items.
///
/// It is up to the application to wrap each child (or an internal part of the
/// child) with a drag listener that will recognize the start of an item drag
/// and then start the reorder by calling
/// [SliverAnimatedReorderableListState.startItemDragReorder]. This is most easily
/// achieved by wrapping each child in a [ReorderableDragStartListener] or
/// a [ReorderableDelayedDragStartListener]. These will take care of
/// recognizing the start of a drag gesture and call the list state's start
/// item drag method.
///
/// This widget's [SliverAnimatedReorderableListState] can be used to manually start an item
/// reorder, or cancel a current drag that's already underway. To refer to the
/// [SliverAnimatedReorderableListState] either provide a [GlobalKey] or use the static
/// [SliverAnimatedReorderableList.of] method from an item's build method.
///
/// See also:
///
///  * [AnimatedReorderableList], a regular widget list that allows the user to reorder
///    its items.
///  * [AnimatedReorderableListView], a Material Design list that allows the user to
///    reorder its items.
class SliverAnimatedReorderableList extends StatefulWidget {
  /// Creates a sliver list that allows the user to interactively reorder its
  /// items.
  ///
  /// The [itemCount] must be greater than or equal to zero.
  const SliverAnimatedReorderableList({
    super.key,
    required this.itemBuilder,
    this.findChildIndexCallback,
    this.initialItemCount = 0,
    required this.onReorder,
    this.onReorderStart,
    this.onReorderEnd,
    this.itemExtent,
    this.itemExtentBuilder,
    this.prototypeItem,
    this.proxyDecorator,
    double? autoScrollerVelocityScalar,
  })  : autoScrollerVelocityScalar =
            autoScrollerVelocityScalar ?? _kDefaultAutoScrollVelocityScalar,
        assert(
          (itemExtent == null && prototypeItem == null) ||
              (itemExtent == null && itemExtentBuilder == null) ||
              (prototypeItem == null && itemExtentBuilder == null),
          'You can only pass one of itemExtent, prototypeItem and itemExtentBuilder.',
        );

  // An eyeballed value for a smooth scrolling experience.
  static const double _kDefaultAutoScrollVelocityScalar = 50;

  /// {@macro flutter.widgets.reorderable_list.itemBuilder}
  final AnimatedItemBuilder itemBuilder;

  /// {@macro flutter.widgets.SliverChildBuilderDelegate.findChildIndexCallback}
  final ChildIndexGetter? findChildIndexCallback;

  /// {@macro flutter.widgets.reorderable_list.itemCount}
  final int initialItemCount;

  /// {@macro flutter.widgets.reorderable_list.onReorder}
  final ReorderCallback onReorder;

  /// {@macro flutter.widgets.reorderable_list.onReorderStart}
  final void Function(int)? onReorderStart;

  /// {@macro flutter.widgets.reorderable_list.onReorderEnd}
  final void Function(int)? onReorderEnd;

  /// {@macro flutter.widgets.reorderable_list.proxyDecorator}
  final ReorderItemProxyDecorator? proxyDecorator;

  /// {@macro flutter.widgets.list_view.itemExtent}
  final double? itemExtent;

  /// {@macro flutter.widgets.list_view.itemExtentBuilder}
  final ItemExtentBuilder? itemExtentBuilder;

  /// {@macro flutter.widgets.list_view.prototypeItem}
  final Widget? prototypeItem;

  /// {@macro flutter.widgets.EdgeDraggingAutoScroller.velocityScalar}
  ///
  /// {@template flutter.widgets.SliverReorderableList.autoScrollerVelocityScalar.default}
  /// Defaults to 50 if not set or set to null.
  /// {@endtemplate}
  final double autoScrollerVelocityScalar;

  @override
  SliverAnimatedReorderableListState createState() =>
      SliverAnimatedReorderableListState();

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [SliverAnimatedReorderableList] item widgets to
  /// start or cancel an item drag operation.
  ///
  /// If no [SliverAnimatedReorderableList] surrounds the context given, this function
  /// will assert in debug mode and throw an exception in release mode.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  ///  * [maybeOf], a similar function that will return null if no
  ///    [SliverAnimatedReorderableList] ancestor is found.
  static SliverAnimatedReorderableListState of(BuildContext context) {
    final SliverAnimatedReorderableListState? result =
        context.findAncestorStateOfType<SliverAnimatedReorderableListState>();
    assert(() {
      if (result == null) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
            'SliverReorderableList.of() called with a context that does not contain a SliverReorderableList.',
          ),
          ErrorDescription(
            'No SliverReorderableList ancestor could be found starting from the context that was passed to SliverReorderableList.of().',
          ),
          ErrorHint(
            'This can happen when the context provided is from the same StatefulWidget that '
            'built the SliverReorderableList. Please see the SliverReorderableList documentation for examples '
            'of how to refer to an SliverReorderableList object:\n'
            '  https://api.flutter.dev/flutter/widgets/SliverReorderableListState-class.html',
          ),
          context.describeElement('The context used was'),
        ]);
      }
      return true;
    }());
    return result!;
  }

  /// The state from the closest instance of this class that encloses the given
  /// context.
  ///
  /// This method is typically used by [SliverAnimatedReorderableList] item widgets that
  /// insert or remove items in response to user input.
  ///
  /// If no [SliverAnimatedReorderableList] surrounds the context given, this function
  /// will return null.
  ///
  /// This method can be expensive (it walks the element tree).
  ///
  /// See also:
  ///
  ///  * [of], a similar function that will throw if no [SliverAnimatedReorderableList]
  ///    ancestor is found.
  static SliverAnimatedReorderableListState? maybeOf(BuildContext context) {
    return context
        .findAncestorStateOfType<SliverAnimatedReorderableListState>();
  }
}

/// The state for a sliver list that allows the user to interactively reorder
/// the list items.
///
/// An app that needs to start a new item drag or cancel an existing one
/// can refer to the [SliverAnimatedReorderableList]'s state with a global key:
///
/// ```dart
/// // (e.g. in a stateful widget)
/// GlobalKey<SliverReorderableListState> listKey = GlobalKey<SliverReorderableListState>();
///
/// // ...
///
/// @override
/// Widget build(BuildContext context) {
///   return SliverReorderableList(
///     key: listKey,
///     itemBuilder: (BuildContext context, int index) => const SizedBox(height: 10.0),
///     itemCount: 5,
///     onReorder: (int oldIndex, int newIndex) {
///        // ...
///     },
///   );
/// }
///
/// // ...
///
/// void _stop() {
///   listKey.currentState!.cancelReorder();
/// }
/// ```
///
/// [ReorderableDragStartListener] and [ReorderableDelayedDragStartListener]
/// refer to their [SliverAnimatedReorderableList] with the static
/// [SliverAnimatedReorderableList.of] method.
class SliverAnimatedReorderableListState
    extends State<SliverAnimatedReorderableList> with TickerProviderStateMixin {
  // Map of index -> child state used manage where the dragging item will need
  // to be inserted.
  final Map<int, _ReorderableItemState> _items = <int, _ReorderableItemState>{};

  OverlayEntry? _overlayEntry;
  int? _dragIndex;
  _DragInfo? _dragInfo;
  int? _insertIndex;
  Offset? _finalDropPosition;
  MultiDragGestureRecognizer? _recognizer;
  int? _recognizerPointer;

  EdgeDraggingAutoScroller? _autoScroller;

  late ScrollableState _scrollable;
  Axis get _scrollDirection => axisDirectionToAxis(_scrollable.axisDirection);
  bool get _reverse => axisDirectionIsReversed(_scrollable.axisDirection);

  @protected
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrollable = Scrollable.of(context);
    if (_autoScroller?.scrollable != _scrollable) {
      _autoScroller?.stopAutoScroll();
      _autoScroller = EdgeDraggingAutoScroller(
        _scrollable,
        onScrollViewScrolled: _handleScrollableAutoScrolled,
        velocityScalar: widget.autoScrollerVelocityScalar,
      );
    }
  }

  @protected
  @override
  void didUpdateWidget(covariant SliverAnimatedReorderableList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialItemCount != oldWidget.initialItemCount) {
      cancelReorder();
    }

    if (widget.autoScrollerVelocityScalar !=
        oldWidget.autoScrollerVelocityScalar) {
      _autoScroller?.stopAutoScroll();
      _autoScroller = EdgeDraggingAutoScroller(
        _scrollable,
        onScrollViewScrolled: _handleScrollableAutoScrolled,
        velocityScalar: widget.autoScrollerVelocityScalar,
      );
    }
  }

  @protected
  @override
  void dispose() {
    _dragReset();
    _recognizer?.dispose();
    for (final _ActiveItem item in _incomingItems.followedBy(_outgoingItems)) {
      item.controller!.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    _itemCount = widget.initialItemCount;
    super.initState();
  }

  final List<_ActiveItem> _incomingItems = <_ActiveItem>[];
  final List<_ActiveItem> _outgoingItems = <_ActiveItem>[];
  int _itemCount = 0;

  _ActiveItem? _removeActiveItemAt(List<_ActiveItem> items, int itemIndex) {
    final int i = binarySearch(items, _ActiveItem.index(itemIndex));
    return i == -1 ? null : items.removeAt(i);
  }

  _ActiveItem? _activeItemAt(List<_ActiveItem> items, int itemIndex) {
    final int i = binarySearch(items, _ActiveItem.index(itemIndex));
    return i == -1 ? null : items[i];
  }

  // The insertItem() and removeItem() index parameters are defined as if the
  // removeItem() operation removed the corresponding list/grid entry
  // immediately. The entry is only actually removed from the
  // ListView/GridView when the remove animation finishes. The entry is added
  // to _outgoingItems when removeItem is called and removed from
  // _outgoingItems when the remove animation finishes.

  int _indexToItemIndex(int index) {
    int itemIndex = index;
    for (final _ActiveItem item in _outgoingItems) {
      if (item.itemIndex <= itemIndex) {
        itemIndex += 1;
      } else {
        break;
      }
    }
    return itemIndex;
  }

  int _itemIndexToIndex(int itemIndex) {
    int index = itemIndex;
    for (final _ActiveItem item in _outgoingItems) {
      assert(item.itemIndex != itemIndex);
      if (item.itemIndex < itemIndex) {
        index -= 1;
      } else {
        break;
      }
    }
    return index;
  }

  SliverChildDelegate _createDelegate() {
    return SliverChildBuilderDelegate(
      _itemBuilder,
      childCount: _itemCount,
      findChildIndexCallback: widget.findChildIndexCallback == null
          ? null
          : (Key key) {
              final int? index = widget.findChildIndexCallback!(key);
              return index != null ? _indexToItemIndex(index) : null;
            },
    );
  }

  /// Insert an item at [index] and start an animation that will be passed to
  /// [SliverAnimatedGrid.itemBuilder] or [SliverAnimatedList.itemBuilder] when
  /// the item is visible.
  ///
  /// This method's semantics are the same as Dart's [List.insert] method: it
  /// increases the length of the list of items by one and shifts
  /// all items at or after [index] towards the end of the list of items.
  void insertItem(int index, {Duration duration = _kDuration}) {
    assert(index >= 0);

    final int itemIndex = _indexToItemIndex(index);
    assert(itemIndex >= 0 && itemIndex <= _itemCount);

    // Increment the incoming and outgoing item indices to account
    // for the insertion.
    for (final _ActiveItem item in _incomingItems) {
      if (item.itemIndex >= itemIndex) {
        item.itemIndex += 1;
      }
    }
    for (final _ActiveItem item in _outgoingItems) {
      if (item.itemIndex >= itemIndex) {
        item.itemIndex += 1;
      }
    }

    final AnimationController controller = AnimationController(
      duration: duration,
      vsync: this,
    );
    final _ActiveItem incomingItem = _ActiveItem.incoming(
      controller,
      itemIndex,
    );
    setState(() {
      _incomingItems
        ..add(incomingItem)
        ..sort();
      _itemCount += 1;
    });

    controller.forward().then<void>((_) {
      _removeActiveItemAt(_incomingItems, incomingItem.itemIndex)!
          .controller!
          .dispose();
    });
  }

  /// Insert multiple items at [index] and start an animation that will be passed
  /// to [AnimatedGrid.itemBuilder] or [AnimatedList.itemBuilder] when the items
  /// are visible.
  void insertAllItems(int index, int length, {Duration duration = _kDuration}) {
    for (int i = 0; i < length; i++) {
      insertItem(index + i, duration: duration);
    }
  }

  /// Remove the item at [index] and start an animation that will be passed
  /// to [builder] when the item is visible.
  ///
  /// Items are removed immediately. After an item has been removed, its index
  /// will no longer be passed to the subclass' [SliverAnimatedGrid.itemBuilder]
  /// or [SliverAnimatedList.itemBuilder]. However the item will still appear
  /// for [duration], and during that time [builder] must construct its widget
  /// as needed.
  ///
  /// This method's semantics are the same as Dart's [List.remove] method: it
  /// decreases the length of items by one and shifts
  /// all items at or before [index] towards the beginning of the list of items.
  void removeItem(int index, AnimatedRemovedItemBuilder builder,
      {Duration duration = _kDuration}) {
    assert(index >= 0);

    final int itemIndex = _indexToItemIndex(index);
    assert(itemIndex >= 0 && itemIndex < _itemCount);
    assert(_activeItemAt(_outgoingItems, itemIndex) == null);

    final _ActiveItem? incomingItem =
        _removeActiveItemAt(_incomingItems, itemIndex);
    final AnimationController controller = incomingItem?.controller ??
        AnimationController(duration: duration, value: 1.0, vsync: this);
    final _ActiveItem outgoingItem =
        _ActiveItem.outgoing(controller, itemIndex, builder);
    setState(() {
      _outgoingItems
        ..add(outgoingItem)
        ..sort();
    });

    controller.reverse().then<void>((void value) {
      _removeActiveItemAt(_outgoingItems, outgoingItem.itemIndex)!
          .controller!
          .dispose();

      // Decrement the incoming and outgoing item indices to account
      // for the removal.
      for (final _ActiveItem item in _incomingItems) {
        if (item.itemIndex > outgoingItem.itemIndex) {
          item.itemIndex -= 1;
        }
      }
      for (final _ActiveItem item in _outgoingItems) {
        if (item.itemIndex > outgoingItem.itemIndex) {
          item.itemIndex -= 1;
        }
      }

      setState(() => _itemCount -= 1);
    });
  }

  /// Remove all the items and start an animation that will be passed to
  /// `builder` when the items are visible.
  ///
  /// Items are removed immediately. However, the
  /// items will still appear for `duration` and during that time
  /// `builder` must construct its widget as needed.
  ///
  /// This method's semantics are the same as Dart's [List.clear] method: it
  /// removes all the items in the list.
  void removeAllItems(AnimatedRemovedItemBuilder builder,
      {Duration duration = _kDuration}) {
    for (int i = _itemCount - 1; i >= 0; i--) {
      removeItem(i, builder, duration: duration);
    }
  }

  /// Initiate the dragging of the item at [index] that was started with
  /// the pointer down [event].
  ///
  /// The given [recognizer] will be used to recognize and start the drag
  /// item tracking and lead to either an item reorder, or a canceled drag.
  ///
  /// Most applications will not use this directly, but will wrap the item
  /// (or part of the item, like a drag handle) in either a
  /// [ReorderableDragStartListener] or [ReorderableDelayedDragStartListener]
  /// which call this method when they detect the gesture that triggers a drag
  /// start.
  void startItemDragReorder({
    required int index,
    required PointerDownEvent event,
    required MultiDragGestureRecognizer recognizer,
  }) {
    assert(0 <= index && index < _itemCount);
    setState(() {
      if (_dragInfo != null) {
        cancelReorder();
      } else if (_recognizer != null && _recognizerPointer != event.pointer) {
        _recognizer!.dispose();
        _recognizer = null;
        _recognizerPointer = null;
      }

      if (_items.containsKey(index)) {
        _dragIndex = index;
        _recognizer = recognizer
          ..onStart = _dragStart
          ..addPointer(event);
        _recognizerPointer = event.pointer;
      } else {
        // TODO(darrenaustin): Can we handle this better, maybe scroll to the item?
        throw Exception('Attempting to start a drag on a non-visible item');
      }
    });
  }

  /// Cancel any item drag in progress.
  ///
  /// This should be called before any major changes to the item list
  /// occur so that any item drags will not get confused by
  /// changes to the underlying list.
  ///
  /// If a drag operation is in progress, this will immediately reset
  /// the list to back to its pre-drag state.
  ///
  /// If no drag is active, this will do nothing.
  void cancelReorder() {
    setState(() {
      _dragReset();
    });
  }

  void _registerItem(_ReorderableItemState item) {
    if (_dragInfo != null && _items[item.index] != item) {
      item.updateForGap(_dragInfo!.index, _dragInfo!.index,
          _dragInfo!.itemExtent, false, _reverse);
    }
    _items[item.index] = item;
    if (item.index == _dragInfo?.index) {
      item.dragging = true;
      item.rebuild();
    }
  }

  void _unregisterItem(int index, _ReorderableItemState item) {
    final _ReorderableItemState? currentItem = _items[index];
    if (currentItem == item) {
      _items.remove(index);
    }
  }

  Drag? _dragStart(Offset position) {
    assert(_dragInfo == null);
    final _ReorderableItemState item = _items[_dragIndex!]!;
    item.dragging = true;
    widget.onReorderStart?.call(_dragIndex!);
    item.rebuild();

    _insertIndex = item.index;
    _dragInfo = _DragInfo(
      item: item,
      initialPosition: position,
      scrollDirection: _scrollDirection,
      onUpdate: _dragUpdate,
      onCancel: _dragCancel,
      onEnd: _dragEnd,
      onDropCompleted: _dropCompleted,
      proxyDecorator: widget.proxyDecorator,
      tickerProvider: this,
    );
    _dragInfo!.startDrag();

    final OverlayState overlay = Overlay.of(context, debugRequiredFor: widget);
    assert(_overlayEntry == null);
    _overlayEntry = OverlayEntry(builder: _dragInfo!.createProxy);
    overlay.insert(_overlayEntry!);

    for (final _ReorderableItemState childItem in _items.values) {
      if (childItem == item || !childItem.mounted) {
        continue;
      }
      childItem.updateForGap(
          _insertIndex!, _insertIndex!, _dragInfo!.itemExtent, false, _reverse);
    }
    return _dragInfo;
  }

  void _dragUpdate(_DragInfo item, Offset position, Offset delta) {
    setState(() {
      _overlayEntry?.markNeedsBuild();
      _dragUpdateItems();
      _autoScroller?.startAutoScrollIfNecessary(_dragTargetRect);
    });
  }

  void _dragCancel(_DragInfo item) {
    setState(() {
      _dragReset();
    });
  }

  void _dragEnd(_DragInfo item) {
    setState(() {
      if (_insertIndex == item.index) {
        _finalDropPosition = _itemOffsetAt(_insertIndex!);
      } else if (_reverse) {
        if (_insertIndex! >= _items.length) {
          // Drop at the starting position of the last element and offset its own extent
          _finalDropPosition = _itemOffsetAt(_items.length - 1) -
              _extentOffset(item.itemExtent, _scrollDirection);
        } else {
          // Drop at the end of the current element occupying the insert position
          _finalDropPosition = _itemOffsetAt(_insertIndex!) +
              _extentOffset(_itemExtentAt(_insertIndex!), _scrollDirection);
        }
      } else {
        if (_insertIndex! == 0) {
          // Drop at the starting position of the first element and offset its own extent
          _finalDropPosition = _itemOffsetAt(0) -
              _extentOffset(item.itemExtent, _scrollDirection);
        } else {
          // Drop at the end of the previous element occupying the insert position
          final int atIndex = _insertIndex! - 1;
          _finalDropPosition = _itemOffsetAt(atIndex) +
              _extentOffset(_itemExtentAt(atIndex), _scrollDirection);
        }
      }
    });
    widget.onReorderEnd?.call(_insertIndex!);
  }

  void _dropCompleted() {
    final int fromIndex = _dragIndex!;
    final int toIndex = _insertIndex!;
    if (fromIndex != toIndex) {
      widget.onReorder.call(fromIndex, toIndex);
    }
    setState(() {
      _dragReset();
    });
  }

  void _dragReset() {
    if (_dragInfo != null) {
      if (_dragIndex != null && _items.containsKey(_dragIndex)) {
        final _ReorderableItemState dragItem = _items[_dragIndex!]!;
        dragItem._dragging = false;
        dragItem.rebuild();
        _dragIndex = null;
      }
      _dragInfo?.dispose();
      _dragInfo = null;
      _autoScroller?.stopAutoScroll();
      _resetItemGap();
      _recognizer?.dispose();
      _recognizer = null;
      _overlayEntry?.remove();
      _overlayEntry?.dispose();
      _overlayEntry = null;
      _finalDropPosition = null;
    }
  }

  void _resetItemGap() {
    for (final _ReorderableItemState item in _items.values) {
      item.resetGap();
    }
  }

  void _handleScrollableAutoScrolled() {
    if (_dragInfo == null) {
      return;
    }
    _dragUpdateItems();
    // Continue scrolling if the drag is still in progress.
    _autoScroller?.startAutoScrollIfNecessary(_dragTargetRect);
  }

  void _dragUpdateItems() {
    assert(_dragInfo != null);
    final double gapExtent = _dragInfo!.itemExtent;
    final double proxyItemStart = _offsetExtent(
        _dragInfo!.dragPosition - _dragInfo!.dragOffset, _scrollDirection);
    final double proxyItemEnd = proxyItemStart + gapExtent;

    // Find the new index for inserting the item being dragged.
    int newIndex = _insertIndex!;
    for (final _ReorderableItemState item in _items.values) {
      if ((_reverse && item.index == _dragIndex!) || !item.mounted) {
        continue;
      }

      final Rect geometry = item.targetGeometry();
      final double itemStart =
          _scrollDirection == Axis.vertical ? geometry.top : geometry.left;
      final double itemExtent =
          _scrollDirection == Axis.vertical ? geometry.height : geometry.width;
      final double itemEnd = itemStart + itemExtent;
      final double itemMiddle = itemStart + itemExtent / 2;

      if (_reverse) {
        if (itemEnd >= proxyItemEnd && proxyItemEnd >= itemMiddle) {
          // The start of the proxy is in the beginning half of the item, so
          // we should swap the item with the gap and we are done looking for
          // the new index.
          newIndex = item.index;
          break;
        } else if (itemMiddle >= proxyItemStart &&
            proxyItemStart >= itemStart) {
          // The end of the proxy is in the ending half of the item, so
          // we should swap the item with the gap and we are done looking for
          // the new index.
          newIndex = item.index + 1;
          break;
        } else if (itemStart > proxyItemEnd && newIndex < (item.index + 1)) {
          newIndex = item.index + 1;
        } else if (proxyItemStart > itemEnd && newIndex > item.index) {
          newIndex = item.index;
        }
      } else {
        if (item.index == _dragIndex!) {
          // If end of the proxy is not in ending half of item,
          // we don't process, because it's original dragged item.
          if (itemMiddle <= proxyItemEnd && proxyItemEnd <= itemEnd) {
            newIndex = _dragIndex!;
          }
        } else if (itemStart <= proxyItemStart &&
            proxyItemStart <= itemMiddle) {
          // The start of the proxy is in the beginning half of the item, so
          // we should swap the item with the gap and we are done looking for
          // the new index.
          newIndex = item.index;
          break;
        } else if (itemMiddle <= proxyItemEnd && proxyItemEnd <= itemEnd) {
          // The end of the proxy is in the ending half of the item, so
          // we should swap the item with the gap and we are done looking for
          // the new index.
          newIndex = item.index + 1;
          break;
        } else if (itemEnd < proxyItemStart && newIndex < (item.index + 1)) {
          newIndex = item.index + 1;
        } else if (proxyItemEnd < itemStart && newIndex > item.index) {
          newIndex = item.index;
        }
      }
    }

    if (newIndex != _insertIndex) {
      _insertIndex = newIndex;
      for (final _ReorderableItemState item in _items.values) {
        if (item.index == _dragIndex! || !item.mounted) {
          continue;
        }
        item.updateForGap(_dragIndex!, newIndex, gapExtent, true, _reverse);
      }
    }
  }

  Rect get _dragTargetRect {
    final Offset origin = _dragInfo!.dragPosition - _dragInfo!.dragOffset;
    return Rect.fromLTWH(origin.dx, origin.dy, _dragInfo!.itemSize.width,
        _dragInfo!.itemSize.height);
  }

  Offset _itemOffsetAt(int index) {
    return _items[index]!.targetGeometry().topLeft;
  }

  double _itemExtentAt(int index) {
    return _sizeExtent(_items[index]!.targetGeometry().size, _scrollDirection);
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (_dragInfo != null && index >= _itemCount) {
      return switch (_scrollDirection) {
        Axis.horizontal => SizedBox(width: _dragInfo!.itemExtent),
        Axis.vertical => SizedBox(height: _dragInfo!.itemExtent),
      };
    }
    final _ActiveItem? outgoingItem = _activeItemAt(_outgoingItems, index);
    if (outgoingItem != null) {
      return outgoingItem.removedItemBuilder!(
        context,
        outgoingItem.controller!.view,
      );
    }

    final _ActiveItem? incomingItem = _activeItemAt(_incomingItems, index);
    final Animation<double> animation =
        incomingItem?.controller?.view ?? kAlwaysCompleteAnimation;
    final Widget child = widget.itemBuilder(
      context,
      _itemIndexToIndex(index),
      animation,
    );
    assert(child.key != null, 'All list items must have a key');
    final OverlayState overlay = Overlay.of(context, debugRequiredFor: widget);
    return _ReorderableItem(
      key: _ReorderableItemGlobalKey(child.key!, index, this),
      index: index,
      capturedThemes:
          InheritedTheme.capture(from: context, to: overlay.context),
      child: _wrapWithSemantics(child, index),
    );
  }

  Widget _wrapWithSemantics(Widget child, int index) {
    void reorder(int startIndex, int endIndex) {
      if (startIndex != endIndex) {
        widget.onReorder(startIndex, endIndex);
      }
    }

    // First, determine which semantics actions apply.
    final Map<CustomSemanticsAction, VoidCallback> semanticsActions =
        <CustomSemanticsAction, VoidCallback>{};

    // Create the appropriate semantics actions.
    void moveToStart() => reorder(index, 0);
    void moveToEnd() => reorder(index, _itemCount);
    void moveBefore() => reorder(index, index - 1);
    // To move after, go to index+2 because it is moved to the space
    // before index+2, which is after the space at index+1.
    void moveAfter() => reorder(index, index + 2);

    final WidgetsLocalizations localizations = WidgetsLocalizations.of(context);
    final bool isHorizontal = _scrollDirection == Axis.horizontal;
    // If the item can move to before its current position in the list.
    if (index > 0) {
      semanticsActions[
              CustomSemanticsAction(label: localizations.reorderItemToStart)] =
          moveToStart;
      String reorderItemBefore = localizations.reorderItemUp;
      if (isHorizontal) {
        reorderItemBefore = Directionality.of(context) == TextDirection.ltr
            ? localizations.reorderItemLeft
            : localizations.reorderItemRight;
      }
      semanticsActions[CustomSemanticsAction(label: reorderItemBefore)] =
          moveBefore;
    }

    // If the item can move to after its current position in the list.
    if (index < _itemCount - 1) {
      String reorderItemAfter = localizations.reorderItemDown;
      if (isHorizontal) {
        reorderItemAfter = Directionality.of(context) == TextDirection.ltr
            ? localizations.reorderItemRight
            : localizations.reorderItemLeft;
      }
      semanticsActions[CustomSemanticsAction(label: reorderItemAfter)] =
          moveAfter;
      semanticsActions[
              CustomSemanticsAction(label: localizations.reorderItemToEnd)] =
          moveToEnd;
    }

    // Pass toWrap with a GlobalKey into the item so that when it
    // gets dragged, the accessibility framework can preserve the selected
    // state of the dragging item.
    //
    // Also apply the relevant custom accessibility actions for moving the item
    // up, down, to the start, and to the end of the list.
    return Semantics(
      container: true,
      customSemanticsActions: semanticsActions,
      child: child,
    );
  }

  @protected
  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasOverlay(context));
    // final SliverChildBuilderDelegate childrenDelegate =
    //     SliverChildBuilderDelegate(
    //   _itemBuilder,
    //   childCount: widget.itemCount,
    //   findChildIndexCallback: widget.findChildIndexCallback,
    // );
    final childrenDelegate = _createDelegate();
    if (widget.itemExtent != null) {
      return SliverFixedExtentList(
        delegate: childrenDelegate,
        itemExtent: widget.itemExtent!,
      );
    } else if (widget.itemExtentBuilder != null) {
      return SliverVariedExtentList(
        delegate: childrenDelegate,
        itemExtentBuilder: widget.itemExtentBuilder!,
      );
    } else if (widget.prototypeItem != null) {
      return SliverPrototypeExtentList(
        delegate: childrenDelegate,
        prototypeItem: widget.prototypeItem!,
      );
    }
    return SliverList(delegate: childrenDelegate);
  }
}

class _ReorderableItem extends StatefulWidget {
  const _ReorderableItem({
    required Key super.key,
    required this.index,
    required this.child,
    required this.capturedThemes,
  });

  final int index;
  final Widget child;
  final CapturedThemes capturedThemes;

  @override
  _ReorderableItemState createState() => _ReorderableItemState();
}

class _ReorderableItemState extends State<_ReorderableItem> {
  late SliverAnimatedReorderableListState _listState;

  Offset _startOffset = Offset.zero;
  Offset _targetOffset = Offset.zero;
  AnimationController? _offsetAnimation;

  Key get key => widget.key!;
  int get index => widget.index;

  bool get dragging => _dragging;
  set dragging(bool dragging) {
    if (mounted) {
      setState(() {
        _dragging = dragging;
      });
    }
  }

  bool _dragging = false;

  @override
  void initState() {
    _listState = SliverAnimatedReorderableList.of(context);
    _listState._registerItem(this);
    super.initState();
  }

  @override
  void dispose() {
    _offsetAnimation?.dispose();
    _listState._unregisterItem(index, this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ReorderableItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _listState._unregisterItem(oldWidget.index, this);
      _listState._registerItem(this);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_dragging) {
      final Size size = _extentSize(
          _listState._dragInfo!.itemExtent, _listState._scrollDirection);
      return SizedBox.fromSize(size: size);
    }
    _listState._registerItem(this);
    return Transform.translate(
      offset: offset,
      child: widget.child,
    );
  }

  @override
  void deactivate() {
    _listState._unregisterItem(index, this);
    super.deactivate();
  }

  Offset get offset {
    if (_offsetAnimation != null) {
      final double animValue =
          Curves.easeInOut.transform(_offsetAnimation!.value);
      return Offset.lerp(_startOffset, _targetOffset, animValue)!;
    }
    return _targetOffset;
  }

  void updateForGap(int dragIndex, int gapIndex, double gapExtent, bool animate,
      bool reverse) {
    // An offset needs to be added to create a gap when we are between the
    // moving element (dragIndex) and the current gap position (gapIndex).
    // For how to update the gap position, refer to [_dragUpdateItems].
    final Offset newTargetOffset;
    if (gapIndex < dragIndex && index < dragIndex && index >= gapIndex) {
      newTargetOffset = _extentOffset(
          reverse ? -gapExtent : gapExtent, _listState._scrollDirection);
    } else if (gapIndex > dragIndex && index > dragIndex && index < gapIndex) {
      newTargetOffset = _extentOffset(
          reverse ? gapExtent : -gapExtent, _listState._scrollDirection);
    } else {
      newTargetOffset = Offset.zero;
    }
    if (newTargetOffset != _targetOffset) {
      _targetOffset = newTargetOffset;
      if (animate) {
        if (_offsetAnimation == null) {
          _offsetAnimation = AnimationController(
            vsync: _listState,
            duration: const Duration(milliseconds: 250),
          )
            ..addListener(rebuild)
            ..addStatusListener((AnimationStatus status) {
              if (status.isCompleted) {
                _startOffset = _targetOffset;
                _offsetAnimation!.dispose();
                _offsetAnimation = null;
              }
            })
            ..forward();
        } else {
          _startOffset = offset;
          _offsetAnimation!.forward(from: 0.0);
        }
      } else {
        if (_offsetAnimation != null) {
          _offsetAnimation!.dispose();
          _offsetAnimation = null;
        }
        _startOffset = _targetOffset;
      }
      rebuild();
    }
  }

  void resetGap() {
    if (_offsetAnimation != null) {
      _offsetAnimation!.dispose();
      _offsetAnimation = null;
    }
    _startOffset = Offset.zero;
    _targetOffset = Offset.zero;
    rebuild();
  }

  Rect targetGeometry() {
    final RenderBox itemRenderBox = context.findRenderObject()! as RenderBox;
    final Offset itemPosition =
        itemRenderBox.localToGlobal(Offset.zero) + _targetOffset;
    return itemPosition & itemRenderBox.size;
  }

  void rebuild() {
    if (mounted) {
      setState(() {});
    }
  }
}

/// A wrapper widget that will recognize the start of a drag on the wrapped
/// widget by a [PointerDownEvent], and immediately initiate dragging the
/// wrapped item to a new location in a reorderable list.
///
/// See also:
///
///  * [ReorderableDelayedDragStartListener], a similar wrapper that will
///    only recognize the start after a long press event.
///  * [AnimatedReorderableList], a widget list that allows the user to reorder
///    its items.
///  * [SliverAnimatedReorderableList], a sliver list that allows the user to reorder
///    its items.
///  * [AnimatedReorderableListView], a Material Design list that allows the user to
///    reorder its items.
class ReorderableDragStartListener extends StatelessWidget {
  /// Creates a listener for a drag immediately following a pointer down
  /// event over the given child widget.
  ///
  /// This is most commonly used to wrap part of a list item like a drag
  /// handle.
  const ReorderableDragStartListener({
    super.key,
    required this.child,
    required this.index,
    this.enabled = true,
  });

  /// The widget for which the application would like to respond to a tap and
  /// drag gesture by starting a reordering drag on a reorderable list.
  final Widget child;

  /// The index of the associated item that will be dragged in the list.
  final int index;

  /// Whether the [child] item can be dragged and moved in the list.
  ///
  /// If true, the item can be moved to another location in the list when the
  /// user taps on the child. If false, tapping on the child will be ignored.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: enabled
          ? (PointerDownEvent event) => _startDragging(context, event)
          : null,
      child: child,
    );
  }

  /// Provides the gesture recognizer used to indicate the start of a reordering
  /// drag operation.
  ///
  /// By default this returns an [ImmediateMultiDragGestureRecognizer] but
  /// subclasses can use this to customize the drag start gesture.
  @protected
  MultiDragGestureRecognizer createRecognizer() {
    return ImmediateMultiDragGestureRecognizer(debugOwner: this);
  }

  void _startDragging(BuildContext context, PointerDownEvent event) {
    final DeviceGestureSettings? gestureSettings =
        MediaQuery.maybeGestureSettingsOf(context);
    final SliverAnimatedReorderableListState? list =
        SliverAnimatedReorderableList.maybeOf(context);
    list?.startItemDragReorder(
      index: index,
      event: event,
      recognizer: createRecognizer()..gestureSettings = gestureSettings,
    );
  }
}

/// A wrapper widget that will recognize the start of a drag operation by
/// looking for a long press event. Once it is recognized, it will start
/// a drag operation on the wrapped item in the reorderable list.
///
/// See also:
///
///  * [ReorderableDragStartListener], a similar wrapper that will
///    recognize the start of the drag immediately after a pointer down event.
///  * [AnimatedReorderableList], a widget list that allows the user to reorder
///    its items.
///  * [SliverAnimatedReorderableList], a sliver list that allows the user to reorder
///    its items.
///  * [AnimatedReorderableListView], a Material Design list that allows the user to
///    reorder its items.
class ReorderableDelayedDragStartListener extends ReorderableDragStartListener {
  /// Creates a listener for an drag following a long press event over the
  /// given child widget.
  ///
  /// This is most commonly used to wrap an entire list item in a reorderable
  /// list.
  const ReorderableDelayedDragStartListener({
    super.key,
    required super.child,
    required super.index,
    super.enabled,
  });

  @override
  MultiDragGestureRecognizer createRecognizer() {
    return DelayedMultiDragGestureRecognizer(debugOwner: this);
  }
}

typedef _DragItemUpdate = void Function(
    _DragInfo item, Offset position, Offset delta);
typedef _DragItemCallback = void Function(_DragInfo item);

class _DragInfo extends Drag {
  _DragInfo({
    required _ReorderableItemState item,
    Offset initialPosition = Offset.zero,
    this.scrollDirection = Axis.vertical,
    this.onUpdate,
    this.onEnd,
    this.onCancel,
    this.onDropCompleted,
    this.proxyDecorator,
    required this.tickerProvider,
  }) {
    // TODO(polina-c): stop duplicating code across disposables
    // https://github.com/flutter/flutter/issues/137435
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectCreated(
        library: 'package:flutter/widgets.dart',
        className: '$_DragInfo',
        object: this,
      );
    }
    final RenderBox itemRenderBox =
        item.context.findRenderObject()! as RenderBox;
    listState = item._listState;
    index = item.index;
    child = item.widget.child;
    capturedThemes = item.widget.capturedThemes;
    dragPosition = initialPosition;
    dragOffset = itemRenderBox.globalToLocal(initialPosition);
    itemSize = item.context.size!;
    itemExtent = _sizeExtent(itemSize, scrollDirection);
    itemLayoutConstraints = itemRenderBox.constraints;
    scrollable = Scrollable.of(item.context);
  }

  final Axis scrollDirection;
  final _DragItemUpdate? onUpdate;
  final _DragItemCallback? onEnd;
  final _DragItemCallback? onCancel;
  final VoidCallback? onDropCompleted;
  final ReorderItemProxyDecorator? proxyDecorator;
  final TickerProvider tickerProvider;

  late SliverAnimatedReorderableListState listState;
  late int index;
  late Widget child;
  late Offset dragPosition;
  late Offset dragOffset;
  late Size itemSize;
  late BoxConstraints itemLayoutConstraints;
  late double itemExtent;
  late CapturedThemes capturedThemes;
  ScrollableState? scrollable;
  AnimationController? _proxyAnimation;

  void dispose() {
    if (kFlutterMemoryAllocationsEnabled) {
      FlutterMemoryAllocations.instance.dispatchObjectDisposed(object: this);
    }
    _proxyAnimation?.dispose();
  }

  void startDrag() {
    _proxyAnimation = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 250),
    )
      ..addStatusListener((AnimationStatus status) {
        if (status.isDismissed) {
          _dropCompleted();
        }
      })
      ..forward();
  }

  @override
  void update(DragUpdateDetails details) {
    final Offset delta = _restrictAxis(details.delta, scrollDirection);
    dragPosition += delta;
    onUpdate?.call(this, dragPosition, details.delta);
  }

  @override
  void end(DragEndDetails details) {
    _proxyAnimation!.reverse();
    onEnd?.call(this);
  }

  @override
  void cancel() {
    _proxyAnimation?.dispose();
    _proxyAnimation = null;
    onCancel?.call(this);
  }

  void _dropCompleted() {
    _proxyAnimation?.dispose();
    _proxyAnimation = null;
    onDropCompleted?.call();
  }

  Widget createProxy(BuildContext context) {
    return capturedThemes.wrap(
      _DragItemProxy(
        listState: listState,
        index: index,
        size: itemSize,
        constraints: itemLayoutConstraints,
        animation: _proxyAnimation!,
        position: dragPosition - dragOffset - _overlayOrigin(context),
        proxyDecorator: proxyDecorator,
        child: child,
      ),
    );
  }
}

Offset _overlayOrigin(BuildContext context) {
  final OverlayState overlay =
      Overlay.of(context, debugRequiredFor: context.widget);
  final RenderBox overlayBox = overlay.context.findRenderObject()! as RenderBox;
  return overlayBox.localToGlobal(Offset.zero);
}

class _DragItemProxy extends StatelessWidget {
  const _DragItemProxy({
    required this.listState,
    required this.index,
    required this.child,
    required this.position,
    required this.size,
    required this.constraints,
    required this.animation,
    required this.proxyDecorator,
  });

  final SliverAnimatedReorderableListState listState;
  final int index;
  final Widget child;
  final Offset position;
  final Size size;
  final BoxConstraints constraints;
  final AnimationController animation;
  final ReorderItemProxyDecorator? proxyDecorator;

  @override
  Widget build(BuildContext context) {
    final Widget proxyChild =
        proxyDecorator?.call(child, index, animation.view) ?? child;
    final Offset overlayOrigin = _overlayOrigin(context);

    return MediaQuery(
      // Remove the top padding so that any nested list views in the item
      // won't pick up the scaffold's padding in the overlay.
      data: MediaQuery.of(context).removePadding(removeTop: true),
      child: AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          Offset effectivePosition = position;
          final Offset? dropPosition = listState._finalDropPosition;
          if (dropPosition != null) {
            effectivePosition = Offset.lerp(dropPosition - overlayOrigin,
                effectivePosition, Curves.easeOut.transform(animation.value))!;
          }
          return Positioned(
            left: effectivePosition.dx,
            top: effectivePosition.dy,
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: OverflowBox(
                minWidth: constraints.minWidth,
                minHeight: constraints.minHeight,
                maxWidth: constraints.maxWidth,
                maxHeight: constraints.maxHeight,
                alignment: listState._scrollDirection == Axis.horizontal
                    ? Alignment.centerLeft
                    : Alignment.topCenter,
                child: child,
              ),
            ),
          );
        },
        child: proxyChild,
      ),
    );
  }
}

double _sizeExtent(Size size, Axis scrollDirection) {
  return switch (scrollDirection) {
    Axis.horizontal => size.width,
    Axis.vertical => size.height,
  };
}

Size _extentSize(double extent, Axis scrollDirection) {
  return switch (scrollDirection) {
    Axis.horizontal => Size(extent, 0),
    Axis.vertical => Size(0, extent),
  };
}

double _offsetExtent(Offset offset, Axis scrollDirection) {
  return switch (scrollDirection) {
    Axis.horizontal => offset.dx,
    Axis.vertical => offset.dy,
  };
}

Offset _extentOffset(double extent, Axis scrollDirection) {
  return switch (scrollDirection) {
    Axis.horizontal => Offset(extent, 0.0),
    Axis.vertical => Offset(0.0, extent),
  };
}

Offset _restrictAxis(Offset offset, Axis scrollDirection) {
  return switch (scrollDirection) {
    Axis.horizontal => Offset(offset.dx, 0.0),
    Axis.vertical => Offset(0.0, offset.dy),
  };
}

// A global key that takes its identity from the object and uses a value of a
// particular type to identify itself.
//
// The difference with GlobalObjectKey is that it uses [==] instead of [identical]
// of the objects used to generate widgets.
@optionalTypeArgs
class _ReorderableItemGlobalKey extends GlobalObjectKey {
  const _ReorderableItemGlobalKey(this.subKey, this.index, this.state)
      : super(subKey);

  final Key subKey;
  final int index;
  final SliverAnimatedReorderableListState state;

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is _ReorderableItemGlobalKey &&
        other.subKey == subKey &&
        other.index == index &&
        other.state == state;
  }

  @override
  int get hashCode => Object.hash(subKey, index, state);
}

// The default insert/remove animation duration.
const Duration _kDuration = Duration(milliseconds: 300);

// Incoming and outgoing animated items.
class _ActiveItem implements Comparable<_ActiveItem> {
  _ActiveItem.incoming(this.controller, this.itemIndex)
      : removedItemBuilder = null;
  _ActiveItem.outgoing(
      this.controller, this.itemIndex, this.removedItemBuilder);
  _ActiveItem.index(this.itemIndex)
      : controller = null,
        removedItemBuilder = null;

  final AnimationController? controller;
  final AnimatedRemovedItemBuilder? removedItemBuilder;
  int itemIndex;

  @override
  int compareTo(_ActiveItem other) => itemIndex - other.itemIndex;
}

abstract class _AnimatedScrollView extends StatefulWidget {
  /// Creates a scrolling container that animates items when they are inserted
  /// or removed.
  const _AnimatedScrollView({
    super.key,
    required this.itemBuilder,
    this.removedSeparatorBuilder,
    this.initialItemCount = 0,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.clipBehavior = Clip.hardEdge,
  }) : assert(initialItemCount >= 0);

  /// {@template flutter.widgets.AnimatedScrollView.itemBuilder}
  /// Called, as needed, to build children widgets.
  ///
  /// Children are only built when they're scrolled into view.
  ///
  /// The [AnimatedItemBuilder] index parameter indicates the item's
  /// position in the scroll view. The value of the index parameter will be
  /// between 0 and [initialItemCount] plus the total number of items that have
  /// been inserted with [AnimatedListState.insertItem] or
  /// [AnimatedGridState.insertItem] and less the total number of items that
  /// have been removed with [AnimatedListState.removeItem] or
  /// [AnimatedGridState.removeItem].
  ///
  /// Implementations of this callback should assume that
  /// `removeItem` removes an item immediately.
  /// {@endtemplate}
  final AnimatedItemBuilder itemBuilder;

  /// {@template flutter.widgets.AnimatedScrollView.removedSeparatorBuilder}
  /// Called, as needed, to build separator widgets.
  ///
  /// Separators are only built when they're scrolled into view.
  ///
  /// The [AnimatedItemBuilder] index parameter indicates the
  /// separator's corresponding item's position in the scroll view. The value
  /// of the index parameter will be between 0 and [initialItemCount] plus the
  /// total number of items that have been inserted with [AnimatedListState.insertItem]
  /// and less the total number of items that have been removed with [AnimatedListState.removeItem].
  ///
  /// Implementations of this callback should assume that
  /// `removeItem` removes an item immediately.
  /// {@endtemplate}
  final AnimatedItemBuilder? removedSeparatorBuilder;

  /// {@template flutter.widgets.AnimatedScrollView.initialItemCount}
  /// The number of items the [AnimatedList] or [AnimatedGrid] will start with.
  ///
  /// The appearance of the initial items is not animated. They
  /// are created, as needed, by [itemBuilder] with an animation parameter
  /// of [kAlwaysCompleteAnimation].
  /// {@endtemplate}
  final int initialItemCount;

  /// {@macro flutter.widgets.scroll_view.scrollDirection}
  final Axis scrollDirection;

  /// Whether the scroll view scrolls in the reading direction.
  ///
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the scroll view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  ///
  /// Similarly, if [scrollDirection] is [Axis.vertical], then the scroll view
  /// scrolls from top to bottom when [reverse] is false and from bottom to top
  /// when [reverse] is true.
  ///
  /// Defaults to false.
  final bool reverse;

  /// An object that can be used to control the position to which this scroll
  /// view is scrolled.
  ///
  /// Must be null if [primary] is true.
  ///
  /// A [ScrollController] serves several purposes. It can be used to control
  /// the initial scroll position (see [ScrollController.initialScrollOffset]).
  /// It can be used to control whether the scroll view should automatically
  /// save and restore its scroll position in the [PageStorage] (see
  /// [ScrollController.keepScrollOffset]). It can be used to read the current
  /// scroll position (see [ScrollController.offset]), or change it (see
  /// [ScrollController.animateTo]).
  final ScrollController? controller;

  /// Whether this is the primary scroll view associated with the parent
  /// [PrimaryScrollController].
  ///
  /// On iOS, this identifies the scroll view that will scroll to top in
  /// response to a tap in the status bar.
  ///
  /// Defaults to true when [scrollDirection] is [Axis.vertical] and
  /// [controller] is null.
  final bool? primary;

  /// How the scroll view should respond to user input.
  ///
  /// For example, this determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  ///
  /// Defaults to matching platform conventions.
  final ScrollPhysics? physics;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  ///
  /// If the scroll view does not shrink wrap, then the scroll view will expand
  /// to the maximum allowed size in the [scrollDirection]. If the scroll view
  /// has unbounded constraints in the [scrollDirection], then [shrinkWrap] must
  /// be true.
  ///
  /// Shrink wrapping the content of the scroll view is significantly more
  /// expensive than expanding to the maximum allowed size because the content
  /// can expand and contract during scrolling, which means the size of the
  /// scroll view needs to be recomputed whenever the scroll position changes.
  ///
  /// Defaults to false.
  final bool shrinkWrap;

  /// The amount of space by which to inset the children.
  final EdgeInsetsGeometry? padding;

  /// {@macro flutter.material.Material.clipBehavior}
  ///
  /// Defaults to [Clip.hardEdge].
  final Clip clipBehavior;
}

abstract class _AnimatedScrollViewState<T extends _AnimatedScrollView>
    extends State<T> with TickerProviderStateMixin {
  final GlobalKey<SliverAnimatedReorderableListState>
      _sliverAnimatedMultiBoxKey = GlobalKey();

  /// Insert an item at [index] and start an animation that will be passed
  /// to [AnimatedGrid.itemBuilder] or [AnimatedList.itemBuilder] when the item
  /// is visible.
  ///
  /// If using [AnimatedList.separated] the animation will also be passed
  /// to `separatorBuilder`.
  ///
  /// This method's semantics are the same as Dart's [List.insert] method: it
  /// increases the length of the list of items by one and shifts
  /// all items at or after [index] towards the end of the list of items.
  void insertItem(int index, {Duration duration = _kDuration}) {
    if (widget.removedSeparatorBuilder == null) {
      _sliverAnimatedMultiBoxKey.currentState!
          .insertItem(index, duration: duration);
    } else {
      final int itemIndex = _computeItemIndex(index);
      _sliverAnimatedMultiBoxKey.currentState!
          .insertItem(itemIndex, duration: duration);
      if (itemCount > 1) {
        // Because `insertItem` moves the items after the index, we need to insert the separator
        // at the same index as the item. If there is only one item, we don't need to insert a separator.
        _sliverAnimatedMultiBoxKey.currentState!
            .insertItem(itemIndex, duration: duration);
      }
    }
  }

  /// Insert multiple items at [index] and start an animation that will be passed
  /// to [AnimatedGrid.itemBuilder] or [AnimatedList.itemBuilder] when the items
  /// are visible.
  ///
  /// If using [AnimatedList.separated] the animation will also be passed to `separatorBuilder`.
  void insertAllItems(int index, int length,
      {Duration duration = _kDuration, bool isAsync = false}) {
    if (widget.removedSeparatorBuilder == null) {
      _sliverAnimatedMultiBoxKey.currentState!
          .insertAllItems(index, length, duration: duration);
    } else {
      final int itemIndex = _computeItemIndex(index);
      final int lengthWithSeparators =
          itemCount == 0 ? length * 2 - 1 : length * 2;
      _sliverAnimatedMultiBoxKey.currentState!
          .insertAllItems(itemIndex, lengthWithSeparators, duration: duration);
    }
  }

  /// Remove the item at [index] and start an animation that will be passed to
  /// [builder] when the item is visible.
  ///
  /// If using [AnimatedList.separated], the animation will also be passed to the
  /// corresponding separator's [AnimatedList.removedSeparatorBuilder].
  ///
  /// Items are removed immediately. After an item has been removed, its index
  /// will no longer be passed to the [builder]. However, the
  /// item will still appear for [duration] and during that time
  /// [builder] must construct its widget as needed.
  ///
  /// This method's semantics are the same as Dart's [List.remove] method: it
  /// decreases the length of items by one and shifts all items at or before
  /// [index] towards the beginning of the list of items.
  ///
  /// See also:
  ///
  ///   * [AnimatedRemovedItemBuilder], which describes the arguments to the
  ///     [builder] argument.
  void removeItem(int index, AnimatedRemovedItemBuilder builder,
      {Duration duration = _kDuration}) {
    final AnimatedItemBuilder? removedSeparatorBuilder =
        widget.removedSeparatorBuilder;
    if (removedSeparatorBuilder == null) {
      // There are no separators. Remove only the item.
      _sliverAnimatedMultiBoxKey.currentState!
          .removeItem(index, builder, duration: duration);
    } else {
      final int itemIndex = _computeItemIndex(index);
      // Remove the item
      _sliverAnimatedMultiBoxKey.currentState!
          .removeItem(itemIndex, builder, duration: duration);
      if (itemCount > 1) {
        if (itemIndex == itemCount - 1) {
          // The item was removed from the end of the list, so the separator to remove is the one at `last index` - 1.
          _sliverAnimatedMultiBoxKey.currentState!.removeItem(itemIndex - 1,
              _toRemovedItemBuilder(removedSeparatorBuilder, index - 1),
              duration: duration);
        } else {
          // The item was removed from the middle or beginning of the list,
          // so the corresponding separator took its place and needs to be removed at `itemIndex`.
          _sliverAnimatedMultiBoxKey.currentState!.removeItem(
              itemIndex, _toRemovedItemBuilder(removedSeparatorBuilder, index),
              duration: duration);
        }
      }
    }
  }

  /// Remove all the items and start an animation that will be passed to
  /// [builder] when the items are visible.
  ///
  /// If using [AnimatedList.separated], the animation will also be passed
  /// to the corresponding separator's [AnimatedList.removedSeparatorBuilder].
  ///
  /// Items are removed immediately. However, the
  /// items will still appear for [duration], and during that time
  /// [builder] must construct its widget as needed.
  ///
  /// This method's semantics are the same as Dart's [List.clear] method: it
  /// removes all the items in the list.
  ///
  /// See also:
  ///
  ///   * [AnimatedRemovedItemBuilder], which describes the arguments to the
  ///     [builder] argument.
  void removeAllItems(AnimatedRemovedItemBuilder builder,
      {Duration duration = _kDuration}) {
    final AnimatedItemBuilder? removedSeparatorBuilder =
        widget.removedSeparatorBuilder;
    if (removedSeparatorBuilder == null) {
      // There are no separators. We can remove all items with the same builder.
      _sliverAnimatedMultiBoxKey.currentState!
          .removeAllItems(builder, duration: duration);
      return;
    }

    // There are separators. We need to remove items and separators separately
    // with the corresponding builders.
    for (int index = itemCount - 1; index >= 0; index--) {
      if (index.isEven) {
        _sliverAnimatedMultiBoxKey.currentState!
            .removeItem(index, builder, duration: duration);
      } else {
        // The index of the separator's corresponding item
        final int itemIndex = index ~/ 2;
        _sliverAnimatedMultiBoxKey.currentState!.removeItem(
            index, _toRemovedItemBuilder(removedSeparatorBuilder, itemIndex),
            duration: duration);
      }
    }
  }

  int get itemCount => _sliverAnimatedMultiBoxKey.currentState!._itemCount;

  // Helper method to compute the index for the item to insert or remove considering the separators in between.
  int _computeItemIndex(int index) {
    if (index == 0) {
      return index;
    }
    final int itemsAndSeparatorsCount = itemCount;
    final int separatorsCount = itemsAndSeparatorsCount ~/ 2;
    final int separatedItemsCount = itemCount - separatorsCount;

    final bool isNewLastIndex = index == separatedItemsCount;
    final int indexAdjustedForSeparators = index * 2;
    return isNewLastIndex
        ? indexAdjustedForSeparators - 1
        : indexAdjustedForSeparators;
  }

  // Helper method to create an [AnimatedRemovedItemBuilder]
  // from an [AnimatedItemBuilder] for given [index].
  AnimatedRemovedItemBuilder _toRemovedItemBuilder(
      AnimatedItemBuilder builder, int index) {
    return (BuildContext context, Animation<double> animation) {
      return builder(context, index, animation);
    };
  }

  // Widget _wrap(Widget sliver, Axis direction) {
  //   EdgeInsetsGeometry? effectivePadding = widget.padding;
  //   if (widget.padding == null) {
  //     final MediaQueryData? mediaQuery = MediaQuery.maybeOf(context);
  //     if (mediaQuery != null) {
  //       // Automatically pad sliver with padding from MediaQuery.
  //       final EdgeInsets mediaQueryHorizontalPadding =
  //           mediaQuery.padding.copyWith(top: 0.0, bottom: 0.0);
  //       final EdgeInsets mediaQueryVerticalPadding =
  //           mediaQuery.padding.copyWith(left: 0.0, right: 0.0);
  //       // Consume the main axis padding with SliverPadding.
  //       effectivePadding = direction == Axis.vertical
  //           ? mediaQueryVerticalPadding
  //           : mediaQueryHorizontalPadding;
  //       // Leave behind the cross axis padding.
  //       sliver = MediaQuery(
  //         data: mediaQuery.copyWith(
  //           padding: direction == Axis.vertical
  //               ? mediaQueryHorizontalPadding
  //               : mediaQueryVerticalPadding,
  //         ),
  //         child: sliver,
  //       );
  //     }
  //   }

  //   if (effectivePadding != null) {
  //     sliver = SliverPadding(padding: effectivePadding, sliver: sliver);
  //   }
  //   return CustomScrollView(
  //     scrollDirection: widget.scrollDirection,
  //     reverse: widget.reverse,
  //     controller: widget.controller,
  //     primary: widget.primary,
  //     physics: widget.physics,
  //     clipBehavior: widget.clipBehavior,
  //     shrinkWrap: widget.shrinkWrap,
  //     slivers: <Widget>[ sliver ],
  //   );
  // }
}
