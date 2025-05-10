import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  /// The total consumed pixels about bouncing like [BouncingScrollPhysics]. (e.g. IOS and MAC)
  double lentPixels = 0;

  /// Returns the pixels that is final value combined with [lentPixels] and [pixels].
  double get totalPixels => super.pixels + lentPixels;

  @override
  double get maxScrollExtent {
    // Since BouncingScrollPhysics does not allow scrolling when maxScrollExtent is 0,
    // it is defined as a value close to zero but not exactly zero, as shown below.
    if (physics is BouncingScrollPhysics) {
      return max(precisionErrorTolerance, super.maxScrollExtent);
    }

    return super.maxScrollExtent;
  }

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

  /// Called before the new velocity for ballistic scrolling is used.
  double _fling(double velocity) {
    final targetContext = context.notificationContext;
    if (targetContext != null) {
      return NestedScrollConnection.of(targetContext)?.fling(velocity, this) ?? velocity;
    }

    return velocity;
  }

  /// Called before the new overscrolled about bouncing is reflected.
  double _bouncing(double available) {
    final targetContext = context.notificationContext;
    if (targetContext != null) {
      return NestedScrollConnection.of(targetContext)?.bouncing(available, this) ?? available;
    }

    return available;
  }

  /// Ensures that the remaining [lentPixels] is completely consumed by the appbar.
  void _ensureLentPixels() {
    final consumed = _bouncing(-lentPixels);
    lentPixels += consumed;
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
    if (lentPixels + value > maxScrollExtent) {
      return value - maxScrollExtent;
    } else if (lentPixels + value < minScrollExtent) {
      return value - minScrollExtent;
    }

    return 0.0; // No overscroll
  }

  double setPostPixels(double newPixels, double clipedOverscroll, double systemOverscroll) {
    final double overscroll = overscrollOf(newPixels, minScrollExtent, maxScrollExtent);
    final double oldPixels = pixels;
    final double rawPixels = newPixels - overscroll;
    final double overDelta = systemOverscroll - clipedOverscroll;
    final isBouncing = overDelta.abs() > precisionErrorTolerance;

    // Notifies that the scroll offset has changed.
    void onNotify() {
      if (pixels != oldPixels) {
        notifyListeners();
        didUpdateScrollPositionBy(pixels - oldPixels);
      }
    }

    // First, apply clipped a given new pixels.
    correctPixels(rawPixels);

    final double available = isBouncing ? -overDelta : -clipedOverscroll;
    final double consumed = (isBouncing ? overDelta != 0.0 : clipedOverscroll != 0.0)
      ? _postScroll(available)
      : 0.0;

    clipedOverscroll += consumed;

    /// It is also considered nested scrolling when the remaining
    /// scroll amount is fully consumed in the post phase.
    if ((consumed - available).abs() < precisionErrorTolerance) {
      isNestedScrolling = true;
    }

    // When overscrolling is clipped or bouncing.
    if (overDelta.abs() < precisionErrorTolerance) {
      if (clipedOverscroll.abs() > precisionErrorTolerance) {
        didOverscrollBy(clipedOverscroll);
        onNotify();
        return clipedOverscroll;
      }
    } else {
      final double bouncingDelta = overDelta + consumed;
      if (bouncingDelta.abs() > precisionErrorTolerance) {
        final double consumed = _bouncing(bouncingDelta);
        final double restDelta = bouncingDelta - consumed;

        lentPixels += consumed;

        if (restDelta.abs() > precisionErrorTolerance) {
          correctBy(restDelta);
        }

        didOverscroll();
      }
    }

    onNotify();

    return 0.0;
  }

  @override
  void applyUserOffset(double delta) {
    updateUserScrollDirection(delta > 0.0 ? ScrollDirection.forward : ScrollDirection.reverse);
    setPixels(pixels - physics.applyPhysicsToUserOffset(copyWith(pixels: totalPixels), delta));
  }

  @override
  double setPixels(double newPixels) {
    if (pixels == newPixels) return 0.0;

    // Request the final consumption to ensure [lentPixels] recovers to zero.
    if (lentPixels + newPixels == minScrollExtent) {
      _ensureLentPixels();
      return setPostPixels(minScrollExtent, 0, 0);
    }

    final bool isOldOverscrolledForward = totalPixels < super.minScrollExtent;
    final bool isOldOverscrolledBackward = totalPixels > super.maxScrollExtent;
    final bool isNewOverscrolledForward = lentPixels + newPixels < super.minScrollExtent;
    final bool isNewOverscrolledBackward = lentPixels + newPixels > super.maxScrollExtent;
    final bool isOldOverscrolled = isOldOverscrolledForward || isOldOverscrolledBackward;
    final bool isNewOverscrolled = isNewOverscrolledForward || isNewOverscrolledBackward;

    // When the overscroll direction immediately switches to
    // the forward or backward direction, or vice versa.
    if (isOldOverscrolledForward && isNewOverscrolledBackward
     || isOldOverscrolledBackward && isNewOverscrolledForward) {
      _ensureLentPixels();
    }

    // Handling the case where previously in an overscrolled state,
    // but now the overscroll has resolved.
    if (isOldOverscrolled && !isNewOverscrolled) {
      if (totalPixels < minScrollExtent) {
        correctPixels(super.minScrollExtent);
      } else {
        correctPixels(super.maxScrollExtent);
      }

      // Ensures that the remaining [lentPixels] are fully consumed
      // since it is no longer an bouncing overscroll.
      if (lentPixels.abs() > precisionErrorTolerance) {
        _ensureLentPixels();
      }
    } else if (isOldOverscrolledForward && isNewOverscrolledBackward) {

      // Transition from forward overscroll to backward overscroll.
      correctPixels(super.maxScrollExtent);
    } else if (isOldOverscrolledBackward && isNewOverscrolledForward) {

      // Transition from backward overscroll to forward overscroll.
      correctPixels(super.minScrollExtent);
    }

    final double clipedOverscroll = applyBoundaryConditions(newPixels);
    final double systemOverscroll = overscrollOf(newPixels, minScrollExtent, maxScrollExtent);
    final double overDelta = systemOverscroll - clipedOverscroll;

    if (pixels + overDelta < minScrollExtent
     || pixels + overDelta > maxScrollExtent) {
      isNestedScrolling = true;
    }

    final double available = pixels - newPixels;
    final double consumed = _preScroll(available);

    // When all new scroll offset are consumed.
    if ((consumed - available).abs() < precisionErrorTolerance) {
      isNestedScrolling = true;
      return 0.0;
    }

    return setPostPixels(newPixels + consumed, clipedOverscroll, systemOverscroll);
  }

  /// Reflects the given new pixels in the this position without
  /// considering the nested scroll.
  double setRawPixels(double newPixels) {
    return super.setPixels(newPixels);
  }

  @override
  void goBallistic(double velocity) {
    // A velocity is consumed by nested scroll.
    velocity = velocity - _fling(velocity);

    // Fixed an issue for #3:
    // https://github.com/MTtankkeo/flutter_appbar/issues/3
    if (velocity.abs() == 0 && activity is DragScrollActivity) {
      isNestedScrolling = false;
    }

    // Fixed an issue for #6
    // https://github.com/MTtankkeo/flutter_appbar/issues/6
    if (activity is IdleScrollActivity) {
      isNestedScrolling = false;
    }

    // When infinite scrolling is already possible, there is no need to replace
    // the [BallisticScrollActivity] instance even if the size has changed.
    if (velocity != 0 && isNestedScrolling && activity is BallisticNestedScrollActivity) {
      return;
    }

    assert(hasPixels);
    final Simulation? simulation = physics.createBallisticSimulation(
      // If it's true, must begin non-clamping scrolling.
      isNestedScrolling
        ? copyWith(minScrollExtent: -double.infinity, maxScrollExtent: double.infinity, pixels: totalPixels)
        : copyWith(pixels: totalPixels),
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
