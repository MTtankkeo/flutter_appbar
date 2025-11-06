import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// A widget that makes its child behave like a scrollable area
/// for vertical drags and delegates gestures to the given
/// [ScrollController] as if dragging a scrollable region.
@protected
class ScrollableGestureDelegator extends StatefulWidget {
  const ScrollableGestureDelegator({
    super.key,
    required this.controller,
    required this.child,
  });

  /// The [ScrollController] that receives the delegated gestures.
  final ScrollController controller;

  /// The child widget that detects gestures.
  final Widget child;

  @override
  State<ScrollableGestureDelegator> createState() =>
      _ScrollableGestureDelegatorState();
}

class _ScrollableGestureDelegatorState
    extends State<ScrollableGestureDelegator> {
  /// Returns the last attached [ScrollPosition] from the controller, if any.
  ScrollPosition? get position {
    return widget.controller.positions.isNotEmpty
        ? widget.controller.positions.last
        : null;
  }

  /// Builds a GestureDetector that intercepts vertical drag gestures
  /// and delegates them to the scrollable's [ScrollPosition].
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragDown: _handleDragDown,
      onVerticalDragStart: _handleDragStart,
      onVerticalDragUpdate: _handleDragUpdate,
      onVerticalDragEnd: _handleDragEnd,
      onVerticalDragCancel: _handleDragCancel,
      child: widget.child,
    );
  }

  // --------------------------
  // TOUCH HANDLERS
  // --------------------------

  /// Represents the active drag on the scrollable.
  Drag? _drag;

  /// Represents a hold on the scrollable to temporarily prevent ballistic scrolling.
  ScrollHoldController? _hold;

  /// Called when a vertical drag starts (finger touches the screen).
  /// Requests a hold on the scrollable to prepare for dragging.
  void _handleDragDown(DragDownDetails details) {
    _hold = position?.hold(_disposeHold);
  }

  /// Called when the drag gesture officially starts.
  /// Starts dragging the scrollable using its [ScrollPosition].
  void _handleDragStart(DragStartDetails details) {
    _drag = position?.drag(details, _disposeDrag);
  }

  /// Updates the scrollable with movement delta as the user drags.
  void _handleDragUpdate(DragUpdateDetails details) {
    _drag?.update(details);
  }

  /// Ends the drag and allows the scrollable to continue its ballistic scrolling.
  void _handleDragEnd(DragEndDetails details) {
    _drag?.end(details);
  }

  /// Cancels any active drag or hold, e.g., when the gesture is interrupted.
  void _handleDragCancel() {
    _hold?.cancel();
    _drag?.cancel();
  }

  /// Cleanup callback for when the hold ends.
  void _disposeHold() => _hold = null;

  /// Cleanup callback for when the drag ends.
  void _disposeDrag() => _drag = null;
}
