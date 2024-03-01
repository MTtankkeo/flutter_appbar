import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appbar/components/scroll_controller.dart';
import 'package:flutter_appbar/widgets/nested_scroll_connection.dart';

class NestedScrollEndNotification extends ScrollNotification {
  NestedScrollEndNotification({
    required super.metrics,
    required super.context,
    required this.target,
  });

  final ScrollPosition target;
}

/// Facilitate the implementation of appbar behavior through interaction
/// with [NestedScrollConnection].
/// 
/// Used by [NestedScrollController].
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
      return NestedScrollConnection.of(targetContext)?.preScroll(available, this) ?? 0.0;
    }

    // No context exists to refer.
    return 0.0;
  }

  double _postScroll(double available) {
    final targetContext = context.notificationContext;
    if (targetContext != null) {
      return NestedScrollConnection.of(targetContext)?.postScroll(available, this) ?? 0.0;
    }

    // No context exists to refer.
    return 0.0;
  }

  double _fling(double velocity) {
    final targetContext = context.notificationContext;
    if (targetContext != null) {
      return NestedScrollConnection.of(targetContext)?.fling(velocity, this) ?? velocity;
    }
    
    // no context exists to refer.
    return velocity;
  }
  
  @override
  void didOverscrollBy(double value) {
    super.didOverscrollBy(value);

    // If not all are consumed, the non-clamping scrolling cannot be performed.
    if (isNestedScrolling && activity is BallisticScrollActivity) {
      isNestedScrolling = false;

      // Begin clamping ballistic scrolling.
      Future.microtask(() => goBallistic(activity?.velocity ?? 0.0));
    }
  }

  double setPostPixels(double newPixels) {
    if (newPixels != pixels) {
      double overscroll = applyBoundaryConditions(newPixels);
      double oldPixels = pixels;
      correctPixels(newPixels - overscroll);
      if (pixels != oldPixels) {
        notifyListeners();
        didUpdateScrollPositionBy(pixels - oldPixels);
      }

      final double consumed = overscroll != 0.0
        ? _postScroll(-overscroll)
        : 0.0;
  
      overscroll += consumed;

      if (overscroll.abs() > precisionErrorTolerance) {
        didOverscrollBy(overscroll);
        return overscroll;
      }
    }
    return 0.0;
  }

  @override
  double setPixels(double newPixels) {
    final double available = pixels - newPixels;
    final double consumed = _preScroll(available);

    // When all new scroll offset are consumed.
    if ((consumed - available).abs() < precisionErrorTolerance) {
      isNestedScrolling = true;
      return 0.0;
    }

    return setPostPixels(newPixels + consumed);
  }

  /// Reflects the given new pixels in the this position without
  /// considering the nested scroll.
  double setRawPixels(double newPixels) {
    return super.setPixels(newPixels);
  }

  @override
  void goBallistic(double velocity) {
    if (velocity == 0.0) return goIdle();

    // += consumed by nested scroll.
    velocity = _fling(velocity);
    
    // Do not begin activity when fling velocity has all been consumed.
    if (velocity.abs() < precisionErrorTolerance) {
      return goIdle();
    }

    assert(hasPixels);
    final Simulation? simulation = physics.createBallisticSimulation(
      // If it's true, must begin non-clamping scrolling.
      isNestedScrolling
        ? copyWith(minScrollExtent: -double.infinity, maxScrollExtent: double.infinity)
        : this,
      velocity
    );
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

  @override
  void didEndScroll() {
    super.didEndScroll();

    context.notificationContext?.dispatchNotification(
      NestedScrollEndNotification(
        metrics: copyWith(),
        context: context.notificationContext,
        target: this
      ),
    );
  }
}
