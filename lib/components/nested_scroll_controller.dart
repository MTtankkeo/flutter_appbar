import 'package:flutter/material.dart';
import 'package:flutter_appbar/components/nested_scroll_position.dart';

/// A [ScrollController] that always uses [NestedScrollPosition].
class NestedScrollController extends ScrollController {
  NestedScrollController({
    super.debugLabel,
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.onAttach,
    super.onDetach,
  });

  @override
  NestedScrollPosition get position => super.position as NestedScrollPosition;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return NestedScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
    );
  }
}
