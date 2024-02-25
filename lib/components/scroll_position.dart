import 'dart:math';

import 'package:flutter/foundation.dart';
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

  bool get isBallisticScrolling => activity is BallisticScrollActivity;

  /// If this value is true, will perform a non-clamping scrolling.
  bool isNestedScrolling = false;

  double _preScroll(double available) {
    final targetContext = context.notificationContext;
    if (targetContext != null) {
      return NestedScrollConnection.of(targetContext)?.preScroll(available, this) ?? 0;
    }

    // No context exists to refer.
    return 0;
  }

  double _postScroll(double available) {
    final targetContext = context.notificationContext;
    if (targetContext != null) {
      return NestedScrollConnection.of(targetContext)?.postScroll(available, this) ?? 0;
    }

    // No context exists to refer.
    return 0;
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

      final double consumed = overscroll != 0
        ? _postScroll(-overscroll)
        : 0;
  
      overscroll += consumed;

      if (overscroll.abs() > precisionErrorTolerance) {
        didOverscrollBy(overscroll);
        return overscroll;
      }
    }
    return 0;
  }

  @override
  double setPixels(double newPixels) {
    final double available = pixels - newPixels;
    final double consumed = _preScroll(available);

    // When all new scroll offsets are consumed.
    if ((consumed - available).abs() < precisionErrorTolerance) {
      isNestedScrolling = true;
      return 0;
    }

    // If not all are consumed, the non-clamping scrolling cannot be performed.
    /*
    if (isNestedScrolling && activity is BallisticScrollActivity) {
      isNestedScrolling = false;

      // Begin clamping ballistic scrolling.
      Future.microtask(() => goBallistic(activity?.velocity ?? 0));
    }
    */

    return setPostPixels(newPixels + consumed);
  }

  @override
  void goBallistic(double velocity) {
    if (velocity == 0) return goIdle();

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
}
