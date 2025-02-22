import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/appbar_position.dart';
import 'package:flutter_appbar/components/nested_scroll_position.dart';

/// Representing different alignment options for the appbar.
enum AppBarAlignmentCommand {
  /// Align to expanded state.
  expand,
  /// Align to shrunk state.
  shrink,
}

class AppBarAlignmentBehavior {
  const AppBarAlignmentBehavior({
    required this.target,
    required this.duration,
    required this.curve,
  });

  final AppBarAlignmentCommand target;
  final Duration duration;
  final Curve curve;
}

/// The abstract class that defines the behavior of the appbar,
/// including how it consumes scroll offsets and aligns appbar.
abstract class AppBarBehavior {
  const AppBarBehavior();

  /// Updates the given appbar based on available scroll offset,
  /// the current appbar position, and the scroll position.
  /// 
  /// And, returns the value remaining after consumption.
  double setPixels(
    double available,
    AppBarPosition appBar,
    ScrollPosition scroll,
  );

  double setBouncing(
    double available,
    AppBarPosition appBar,
    ScrollPosition scroll
  );

  /// Determines the alignment of the appbar based on appbar position and scroll.
  AppBarAlignmentBehavior? align(AppBarPosition appBar, ScrollPosition scroll);
}

abstract class DrivenAppBarBehavior extends AppBarBehavior {
  const DrivenAppBarBehavior({
    required this.bouncing
  });

  /// Whether the appbar will be synchronized when bouncing overscroll occurs.
  final bool bouncing;

  @override
  double setBouncing(double available, AppBarPosition appBar, ScrollPosition scroll) {
    if (bouncing && (scroll as NestedScrollPosition).totalPixels + available <= 0) {
      appBar.lentPixels += available;
      return available;
    }

    return 0;
  }
}

class AbsoluteAppBarBehavior extends DrivenAppBarBehavior {
  const AbsoluteAppBarBehavior({
    super.bouncing = false
  });

  @override
  AppBarAlignmentBehavior? align(AppBarPosition appBar, ScrollPosition scroll) => null;

  @override
  double setPixels(
    double available,
    AppBarPosition appBar,
    ScrollPosition scroll
  ) => 0;
}

class MaterialAppBarBehavior extends DrivenAppBarBehavior {
  const MaterialAppBarBehavior({
    super.bouncing = false,
    this.floating = false,
    this.dragOnlyExpanding = false,
    this.alwaysScrolling = true,
    this.alignAnimation = true,
    this.alignDuration = const Duration(milliseconds: 300),
    this.alignCurve = Curves.ease,
  });

  /// Whether the appbar can be expanded and contracted without
  /// scrolling to the top of the scroll.
  final bool floating;

  /// Whether the appbar can only be expanded by drag.
  /// 
  /// See also:
  /// - If [floating] is true, must be define false.
  final bool dragOnlyExpanding;

  /// Whether the appbar can be scroll even when the [Scrollable] is no scroll possible.
  final bool alwaysScrolling;

  /// Whether to align the appbar when the scroll is ended.
  final bool alignAnimation;

  /// The duration of the appbar alignment animation.
  final Duration alignDuration;

  /// The curve of the appbar alignment animation.
  final Curve alignCurve;

  AppBarAlignmentBehavior createAlignBehavior(AppBarAlignmentCommand target) {
    return AppBarAlignmentBehavior(target: target, duration: alignDuration, curve: alignCurve);
  }

  @override
  double setPixels(double available, AppBarPosition appBar, ScrollPosition scroll) {
    assert(floating ? !dragOnlyExpanding : true, "[floating] and [dragOnlyExpanding] cannot be used together.");

    // APPBAR SCROLLING CONSTRAINTS

    if ((scroll as NestedScrollPosition).totalPixels < scroll.minScrollExtent) {
      return 0;
    }

    if (!floating) {
      // No consume when scroll offset is zero ~ infinity.
      if (scroll.pixels > precisionErrorTolerance) return 0;

      if (dragOnlyExpanding
       && scroll.isBallisticScrolling
       && appBar.shrinkedPercent == 1) {
        return 0;
      }
    }

    if (!alwaysScrolling) {
      if (appBar.maxExtent > scroll.maxScrollExtent) return 0;
    }

    return appBar.setPixelsWithDelta(available);
  }

  @override
  AppBarAlignmentBehavior? align(AppBarPosition appBar, ScrollPosition scroll) {
    if (alignAnimation) {
      return appBar.expandedPercent < 0.5
        ? createAlignBehavior(AppBarAlignmentCommand.expand)
        : createAlignBehavior(AppBarAlignmentCommand.shrink);
    }

    return null;
  }
}