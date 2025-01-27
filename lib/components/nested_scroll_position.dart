import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appbar/flutter_appbar.dart';

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
/// By default, if scroll offset consumed all by appbar,
/// must be maintain the `non-clamping` or `non-bouncing` scrolling behavior.
/// 
/// - This implies that ballistic scroll-activity should be performed
///   without considering the min-extent and max-extent of the scroll.
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

  bool get isBallisticScrolling => activity is BallisticScrollActivity;

  /// Returns whether it is not currently bouncing overscrolling.
  bool get isBouncing => lentPixels.abs() > precisionErrorTolerance;

  /// Whether this scroll position are currently overscrolling. FYI,
  /// If this value is true, will perform a non-clamping or
  /// non-bouncing scrolling.
  bool isNestedScrolling = false;

  /// The total overscrolled pixels in the non-clamping-based scroll behavior
  /// like [BouncingScrollPhysics]. (e.g. IOS and MAC)
  double lentPixels = 0;

  late bool isPreviousBouncing = false;

  /// Called before the new scroll pixels is consumed in this scroll position.
  double _preScroll(double available) {
    final targetContext = context.notificationContext;
    if (targetContext != null) {
      return NestedScrollConnection.of(targetContext)?.preScroll(available, this) ?? 0.0;
    }

    return 0.0;
  }

  /// Called after the new scroll pixels is consumed in this scroll position.
  double _postScroll(double available) {
    final targetContext = context.notificationContext;
    if (targetContext != null) {
      return NestedScrollConnection.of(targetContext)?.postScroll(available, this) ?? 0.0;
    }

    return 0.0;
  }

  double _fling(double velocity) {
    final targetContext = context.notificationContext;
    if (targetContext != null) {
      return NestedScrollConnection.of(targetContext)?.fling(velocity, this) ?? velocity;
    }

    return velocity;
  }

  void didOverscroll() {
    // If not all are consumed, the non-clamping scrolling cannot be performed.
    if (isNestedScrolling && isBallisticScrolling) {
      isNestedScrolling = false;

      // Begin clamping ballistic scrolling.
      Future.microtask(() => goBallistic(activity?.velocity ?? 0.0));
    }
  }

  @override
  void didOverscrollBy(double value) {
    super.didOverscrollBy(value);

    // Called because it was overscrolled.
    didOverscroll();
  }

  double overscrollOf(double value, double minScrollExtent, double maxScrollExtent) {
    if (value > maxScrollExtent) {
      return value - maxScrollExtent;
    } else if (value < minScrollExtent) {
      return value - minScrollExtent;
    }

    return 0.0; // No overscroll
  }

  double setPostPixels(double newPixels) {
    if (newPixels != pixels) {
      double clipedOverscroll = applyBoundaryConditions(newPixels);
      double systemOverscroll = overscrollOf(newPixels, minScrollExtent, maxScrollExtent);
      double oldPixels = pixels;
      double rawPixels = newPixels - systemOverscroll;
      double overDelta = systemOverscroll - clipedOverscroll;
      final isBouncing = overDelta.abs() > precisionErrorTolerance;

      // print("system: $systemOverscroll, clipped: $clipedOverscroll, delta: $overDelta");

      correctPixels(rawPixels);

      final double consumed = (isBouncing ? overDelta != 0.0 : clipedOverscroll != 0.0)
        ? _postScroll(isBouncing ? -overDelta : -clipedOverscroll)
        : 0.0;

      clipedOverscroll += consumed;

      if (overDelta.abs() < precisionErrorTolerance) {
        if (clipedOverscroll.abs() > precisionErrorTolerance) {
          didOverscrollBy(clipedOverscroll);
          return overDelta;
        }
      } else {
        final double finalDelta = overDelta + consumed;
        if (finalDelta.abs() > precisionErrorTolerance) {
          correctBy(finalDelta);
          didOverscroll();
        }
      }

      if (pixels != oldPixels) {
        notifyListeners();
        didUpdateScrollPositionBy(pixels - oldPixels);
      }
    }

    return 0.0;
  }

  @override
  double setPixels(double newPixels) {
    final bool isOldOverscrolled = pixels < minScrollExtent || pixels > maxScrollExtent;
    final bool isNewOverscrolled = newPixels < minScrollExtent || newPixels > maxScrollExtent;

    // Handling the case where previously in an overscrolled state,
    // but now the overscroll has resolved.
    if (isOldOverscrolled && !isNewOverscrolled) {
      if (pixels < minScrollExtent) {
        correctPixels(minScrollExtent);
      } else {
        correctPixels(maxScrollExtent);
      }
    }

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
    // A velocity is consumed by nested scroll.
    velocity = _fling(velocity);

    print(isNestedScrolling);

    assert(hasPixels);
    final Simulation? simulation = physics.createBallisticSimulation(
      // If it's true, must begin non-clamping scrolling.
      isNestedScrolling
        ? copyWith(minScrollExtent: -double.infinity, maxScrollExtent: double.infinity)
        : copyWith(),
      velocity
    );

    if (simulation != null) {
      beginActivity(BallisticNestedScrollActivity(
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
