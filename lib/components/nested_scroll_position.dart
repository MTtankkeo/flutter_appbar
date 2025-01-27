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

  @override
  void didOverscrollBy(double value) {
    super.didOverscrollBy(value);

    // If not all are consumed, the non-clamping scrolling cannot be performed.
    if (isNestedScrolling && isBallisticScrolling) {
      isNestedScrolling = false;

      // Begin clamping ballistic scrolling.
      Future.microtask(() => goBallistic(activity?.velocity ?? 0.0));
    }
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
      double rawPixels = newPixels - clipedOverscroll;
      double overDelta = systemOverscroll - clipedOverscroll;

      // print("system: $systemOverscroll, clipped: $clipedOverscroll, delta: $overDelta");

      correctPixels(rawPixels);
      if (pixels != oldPixels) {
        notifyListeners();
        didUpdateScrollPositionBy(pixels - oldPixels);
      }

      final double consumed = clipedOverscroll != 0.0
        ? _postScroll(-clipedOverscroll)
        : 0.0;

      clipedOverscroll += consumed;

      if (overDelta.abs() < precisionErrorTolerance
       && clipedOverscroll.abs() > precisionErrorTolerance) {
        print("더 이상 오버스크롤을 허용하지 않도록 처리 됨");
        didOverscrollBy(clipedOverscroll);
        return clipedOverscroll;
      }
    }

    return 0.0;
  }

  @override
  double setPixels(double newPixels) {
    final bool isOldOverscrolled = pixels < minScrollExtent || pixels > maxScrollExtent;
    final bool isNewOverscrolled = newPixels < minScrollExtent || newPixels > maxScrollExtent;

    if (isOldOverscrolled && !isNewOverscrolled) {
      // 이전에 오버스크롤 상태였으나, 이제 오버스크롤이 풀렸을 때 처리
      print("오버스크롤 풀림: $newPixels");
    } else if (!isOldOverscrolled && isNewOverscrolled) {
      // 새로운 오버스크롤 상태에 진입했을 때 처리
      // print("오버스크롤 상태: $newPixels");

      return setPostPixels(newPixels);
    } else if (isNewOverscrolled) {
      // 그 외의 경우 처리 (오버스크롤 상태 유지 또는 오버스크롤과 무관한 상태)
      return super.setPixels(newPixels);
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
