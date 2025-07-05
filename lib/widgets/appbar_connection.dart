import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/appbar_controller.dart';
import 'package:flutter_appbar/components/appbar_position.dart';
import 'package:flutter_appbar/components/nested_scroll_controller.dart';
import 'package:flutter_appbar/components/nested_scroll_position.dart';
import 'package:flutter_appbar/components/appbar.dart';
import 'package:flutter_appbar/widgets/appbar_column.dart';
import 'package:flutter_appbar/widgets/nested_scroll_connection.dart';
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
  });

  final List<AppBar> appBars;
  final Widget child;

  final AppbarPropagation propagation;

  /// The enumeration that defines the propagation type of the nested scroll connection.
  final NestedScrollConnectionPropagation nestedPropagation;

  /// The controller that defines states([AppBarPosition]) and other features of the appbar.
  final AppBarController? controller;

  /// The controller that defines scroll controller of [PrimaryScrollController].
  final NestedScrollController? scrollController;

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

  /// The value defines instance of NestedScrollController.
  late final NestedScrollController _scrollController;

  void attach(AppBarPosition position) => _controller.attach(position);
  void detach(AppBarPosition position) => _controller.detach(position);

  double _handleNestedScroll(double available, ScrollPosition position) {
    return _controller.consumeScroll(
      available,
      position,
      widget.propagation,
    );
  }

  double _handleBouncing(double available, ScrollPosition position) {
    return _controller.consumeBouncing(available, position, widget.propagation);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Initializes the scroll controller for the nested scroll position.
    _scrollController = widget.scrollController ??
        AppBarConnection.of(context)?._scrollController ??
        NestedScrollController();
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            assert(constraints.maxWidth != double.infinity);
            assert(constraints.maxHeight != double.infinity);
            return Column(
              children: [
                // Wrap the widget that acts as a scroll gesture delegator to enable
                // scrolling by dragging a appbar.
                ScrollableGestureDelegator(
                  controller: _scrollController,
                  child: AppBarColumn(
                    controller: _controller,
                    constraints: constraints,
                    children: widget.appBars,
                  ),
                ),

                // With scrollable.
                Expanded(
                  child: PrimaryScrollController(
                    scrollDirection: Axis.vertical,
                    controller: _scrollController,
                    child: widget.child,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
