import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/appbar_controller.dart';
import 'package:flutter_appbar/components/appbar_position.dart';
import 'package:flutter_appbar/components/nested_scroll_controller.dart';
import 'package:flutter_appbar/components/nested_scroll_position.dart';
import 'package:flutter_appbar/components/appbar.dart';
import 'package:flutter_appbar/widgets/appbar_column.dart';
import 'package:flutter_appbar/widgets/nested_scroll_connection.dart';
import 'package:flutter_appbar/widgets/scrollable_gesture_delegator.dart';

/// Synchronize appbars with [Scrollable] to configure dynamic appbar behavior
/// by nested scroll.
/// 
/// And, implementable with single [Scrollable].
/// 
/// How to use this widget?
/// ```dart
/// AppBarConnection(
///   appBars: [ ...AppBar ],
///   child: ...
/// );
/// ```
class AppBarConnection extends StatefulWidget {
  const AppBarConnection({
    super.key,
    required this.appBars,
    required this.child,
    this.propagation = AppbarPropagation.next,
    this.controller,
    this.scrollController,
  });

  final List<AppBar> appBars;
  final Widget child;

  final AppbarPropagation propagation;

  final AppBarController? controller;

  /// This controller is define scroll controller of [PrimaryScrollController].
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
  late final AppBarController _controller = widget.controller ?? AppBarController();
  late final NestedScrollController _scrollController = widget.scrollController ?? NestedScrollController();

  void attach(AppBarPosition position) => _controller.attach(position);
  void detach(AppBarPosition position) => _controller.detach(position);

  double _handleNestedScroll(double available, ScrollPosition position) {
    return _controller.consumeAll(
      available,
      position,
      widget.propagation,
    ); // the total consumed.
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.depth != 0) return false;
        if (notification is NestedScrollEndNotification) {
          _controller.alignAll(notification.target);
        } else if (notification is ScrollStartNotification) {
          _controller.clearAlignAll();
        }

        return false;
      },
      child: NestedScrollConnection(
        onPreScroll: _handleNestedScroll,
        onPostScroll: _handleNestedScroll,
        child: Column(
          children: [
            // Wrap the widget that acts as a scroll gesture delegator to enable
            // scrolling by dragging a appbar.
            ScrollableGestureDelegator(
              controller: _scrollController,
              child: AppBarColumn(controller: _controller, children: widget.appBars)
            ),

            // With scrollable.
            Expanded(
              child: PrimaryScrollController(
                controller: _scrollController,
                child: widget.child
              ),
            ),
          ],
        ),
      ),
    );
  }
}