import 'package:flutter/material.dart';
import 'package:flutter_appbar/widgets/nested_scroll_connection.dart';

class NestedScrollPosition extends ScrollPositionWithSingleContext {
  NestedScrollPosition({
    required super.physics,
    required super.context,
    super.debugLabel,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
  });

  /// If this value is true, will perform a non-clamping scrolling.
  bool isNestedScrolling = false;

  double _preScroll(double available) {
    final targetContext = context.notificationContext;
    if (targetContext != null) {
      return NestedScrollConnection.of(targetContext)
              ?.preScroll(available, this) ??
          0;
    }

    // No context exists to refer.
    return 0.0;
  }

  @override
  double setPixels(double newPixels) {
    final available = pixels - newPixels;
    final consumed = _preScroll(available);

    // When all new scroll offsets are consumed.
    if ((consumed - available).abs() < 0.000001) {
      isNestedScrolling = true;
      return 0;
    }

    // If not all are consumed, the non-clamping scrolling cannot be performed.
    if (isNestedScrolling && activity is BallisticScrollActivity) {
      isNestedScrolling = false;
      Future.microtask(() => goBallistic(activity?.velocity ?? 0));
    }

    return super.setPixels(newPixels + consumed);
  }

  @override
  void goBallistic(double velocity) {
    if (velocity == 0) {
      return goIdle();
    }

    assert(hasPixels);
    final Simulation? simulation = physics.createBallisticSimulation(
        isNestedScrolling
            ? copyWith(
                minScrollExtent: -double.infinity,
                maxScrollExtent: double.infinity)
            : this,
        velocity);
    if (simulation != null) {
      beginActivity(BallisticScrollActivity(
        this,
        simulation,
        context.vsync,
        activity?.shouldIgnorePointer ?? true,
      ));
    } else {
      goIdle();
    }
  }
}
