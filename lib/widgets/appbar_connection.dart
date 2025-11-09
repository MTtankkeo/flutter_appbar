import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/appbar_controller.dart';
import 'package:flutter_appbar/components/appbar_position.dart';
import 'package:flutter_appbar/components/nested_scroll_controller.dart';
import 'package:flutter_appbar/components/nested_scroll_position.dart';
import 'package:flutter_appbar/components/appbar.dart';
import 'package:flutter_appbar/widgets/appbar_column.dart';
import 'package:flutter_appbar/widgets/nested_scroll_connection.dart';
import 'package:flutter_appbar/widgets/nested_scroll_controller_scope.dart';
import 'package:flutter_appbar/widgets/scrollable_gesture_delegator.dart';

/// ## Introduction
/// Synchronize appbars with [Scrollable] to configure dynamic appbar behavior
/// by nested scroll for your cool and sexy, wonderful application.
///
/// See Also, And all of this can be implemented as a single [Scrollable].
///
/// ## Usage
///
/// ### How to use this widget?
/// ```dart
/// AppBarConnection(
///   appBars: [ ...AppBar, ...AppBar.builder ],
///   child: ... // the widget you want.
/// );
/// ```
class AppBarConnection extends StatefulWidget {
  const AppBarConnection({
    super.key,
    required this.appBars,
    required this.child,
    this.propagation = AppbarPropagation.next,
    this.nestedPropagation = NestedScrollConnectionPropagation.directional,
    this.controller,
    this.scrollController,
    this.fixedScrollableHeight,
  });

  final List<AppBar> appBars;
  final Widget child;

  /// Defines how scroll offsets are propagated across nested AppBars.
  final AppbarPropagation propagation;

  /// Defines the propagation behavior for nested scroll connections.
  /// Determines how scroll events from child scrollables affect this [AppBar].
  final NestedScrollConnectionPropagation nestedPropagation;

  /// The controller that defines states([AppBarPosition]) and other features of the appbar.
  final AppBarController? controller;

  /// The controller that defines scroll controller of [PrimaryScrollController].
  final NestedScrollController? scrollController;

  /// When true, the scrollable widget's height is always calculated as if
  /// the AppBar is fully collapsed, regardless of whether the AppBar is
  /// expanded or collapsed.
  ///
  /// This is useful when the scrollable widget's size should not be
  /// adjusted based on the AppBar's movement, helping to avoid layout
  /// overhead and visual glitches caused by dynamic size changes.
  final bool? fixedScrollableHeight;

  /// A static default value for [fixedScrollableHeight],
  /// used when no explicit value is provided.
  static bool defaultFixedScrollableHeight = false;

  /// Finds the ancestor [AppBarConnectionState] from the closest instance of this class
  /// that encloses the given context.
  ///
  /// Used by [AppBar].
  static AppBarConnectionState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppBarConnectionState>();
  }

  @override
  State<AppBarConnection> createState() => AppBarConnectionState();
}

class AppBarConnectionState extends State<AppBarConnection> {
  /// The value defines a unique instance of [AppBarController]
  /// to manage the positions of the appbar in this widget.
  late AppBarController _controller = widget.controller ?? AppBarController();

  void attach(AppBarPosition position) => _controller.attach(position);
  void detach(AppBarPosition position) => _controller.detach(position);

  double _handleNestedScroll(double available, NestedScrollPosition position) {
    return _controller.consumeScroll(
      available,
      position,
      widget.propagation,
    );
  }

  double _handleBouncing(double available, NestedScrollPosition position) {
    return _controller.consumeBouncing(available, position, widget.propagation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppBarConnection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != null &&
        oldWidget.controller != widget.controller) {
      _controller = widget.controller!..delegateFrom(_controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is NestedScrollEndNotification) {
          _controller.alignAll(notification.target);
        } else if (notification is ScrollStartNotification) {
          _controller.clearAlignAll();
        }

        return false;
      },
      child: NestedScrollConnection(
        onBouncing: _handleBouncing,
        onPreScroll: _handleNestedScroll,
        onPostScroll: _handleNestedScroll,
        propagation: widget.nestedPropagation,

        // Uses the provided NestedScrollController if available.
        // Otherwise, creates a new instance for the widget tree.
        child: NestedScrollControllerScope(
          controller: widget.scrollController,
          factory: (context) => NestedScrollController(),
          builder: (context, scrollController) {
            return LayoutBuilder(
              builder: (context, constraints) {
                assert(constraints.maxWidth != double.infinity);
                assert(constraints.maxHeight != double.infinity);
                return _RenderAppBarConnection(
                  fixedScrollableHeight: widget.fixedScrollableHeight ??
                      AppBarConnection.defaultFixedScrollableHeight,
                  children: [
                    // Wrap the widget that acts as a scroll gesture delegator
                    // to enable scrolling by dragging a appbar.
                    ScrollableGestureDelegator(
                      controller: scrollController,
                      child: AppBarColumn(
                        controller: _controller,
                        constraints: constraints,
                        children: widget.appBars,
                      ),
                    ),

                    // With scrollable.
                    widget.child,
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// A widget that creates a [_AppBarConnectionRenderBox] to layout.
class _RenderAppBarConnection extends MultiChildRenderObjectWidget {
  const _RenderAppBarConnection({
    required super.children,
    required this.fixedScrollableHeight,
  });

  final bool fixedScrollableHeight;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _AppBarConnectionRenderBox(
        fixedScrollableHeight: fixedScrollableHeight);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _AppBarConnectionRenderBox renderObject,
  ) {
    renderObject.fixedScrollableHeight = fixedScrollableHeight;
  }
}

/// A RenderBox that lays out an AppBar (or multiple AppBars) above
/// a scrollable body, managing their vertical positioning and height.
class _AppBarConnectionRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _ParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _ParentData> {
  _AppBarConnectionRenderBox({
    required bool fixedScrollableHeight,
  }) {
    this._fixedScrollableHeight = fixedScrollableHeight;
  }

  late bool _fixedScrollableHeight;
  bool get fixedScrollableHeight => _fixedScrollableHeight;
  set fixedScrollableHeight(bool newValue) {
    if (_fixedScrollableHeight != newValue) {
      _fixedScrollableHeight = newValue;
      markNeedsLayout();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _ParentData) {
      child.parentData = _ParentData();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    final RenderBox appBars = firstChild!;
    final RenderBox body = childAfter(appBars)!;
    final bodyParentData = body.parentData as _ParentData;

    // Layout the app bars with unconstrained height, allowing
    // them to occupy only the vertical space they need.
    appBars.layout(
      BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0,
        maxHeight: double.infinity,
      ),
      parentUsesSize: true,
    );

    if (fixedScrollableHeight) {
      // Use full constraints for the body when fixedScrollableHeight is enabled,
      // treating the scrollable as if the AppBar is fully collapsed.
      body.layout(constraints, parentUsesSize: true);
    } else {
      // Determine the remaining height available for the body.
      final availableHeight = constraints.maxHeight - appBars.size.height;

      // Explicitly set minHeight to 0.0 to prevent unbounded layout errors.
      final bodyConstraints = BoxConstraints(
        minWidth: constraints.minWidth,
        maxWidth: constraints.maxWidth,
        minHeight: 0.0,
        maxHeight: max(0.0, availableHeight),
      );

      body.layout(bodyConstraints, parentUsesSize: true);
    }

    // Position the body immediately below the app bars.
    bodyParentData.offset = Offset(0, appBars.size.height);

    size = Size(constraints.maxWidth, constraints.maxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}

/// ParentData used by [_AppBarConnectionRenderBox]
/// to store positional information for each child.
class _ParentData extends ContainerBoxParentData<RenderBox> {}
