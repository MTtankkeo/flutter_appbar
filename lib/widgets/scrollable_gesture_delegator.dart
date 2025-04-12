import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// A widget that deliver a gesture for [Scrollable] to a given [ScrollController].
@protected
class ScrollableGestureDelegator extends StatefulWidget {
  const ScrollableGestureDelegator({
    super.key,
    required this.controller,
    required this.child,
  });

  final ScrollController controller;
  final Widget child;

  @override
  State<ScrollableGestureDelegator> createState() => _ScrollableGestureDelegatorState();
}

class _ScrollableGestureDelegatorState extends State<ScrollableGestureDelegator> {
  ScrollPosition? get position {
    return widget.controller.positions.isNotEmpty
      ? widget.controller.positions.last
      : null;
  }

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

  // TOUCH HANDLERS

  Drag? _drag;
  ScrollHoldController? _hold;

  void _handleDragDown(DragDownDetails details) {
    _hold = position?.hold(_disposeHold);
  }

  void _handleDragStart(DragStartDetails details) {
    _drag = position?.drag(details, _disposeDrag);
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    _drag?.update(details);
  }

  void _handleDragEnd(DragEndDetails details) {
    _drag?.end(details);
  }

  void _handleDragCancel() {
    _hold?.cancel();
    _drag?.cancel();
  }

  void _disposeHold() => _hold = null;
  void _disposeDrag() => _drag = null;
}
