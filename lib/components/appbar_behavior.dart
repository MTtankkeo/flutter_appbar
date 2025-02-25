import 'dart:math';

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

/// The abstract class that defines the behavior of the appbar that is
/// including how it consumes scroll offsets and aligns appbar.
abstract class AppBarBehavior {
  const AppBarBehavior({
    required this.alignDuration,
    required this.alignCurve,
  });

  /// The duration of the appbar alignment animation.
  final Duration alignDuration;

  /// The curve of the appbar alignment animation.
  final Curve alignCurve;

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
  AppBarAlignmentCommand? align(AppBarPosition appBar, ScrollPosition scroll);
}

abstract class DrivenAppBarBehavior extends AppBarBehavior {
  const DrivenAppBarBehavior({
    required this.bouncing,
    super.alignDuration = const Duration(milliseconds: 300),
    super.alignCurve = Curves.ease,
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
  AppBarAlignmentCommand? align(AppBarPosition appBar, ScrollPosition scroll) => null;

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
    super.alignDuration,
    super.alignCurve,
    this.alignAnimation = true,
    this.floating = false,
    this.dragOnlyExpanding = false,
    this.alwaysScrolling = true,
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

  @override
  double setPixels(double available, AppBarPosition appBar, ScrollPosition scroll) {
    assert(floating ? !dragOnlyExpanding : true, "[floating] and [dragOnlyExpanding] cannot be used together.");

    // APPBAR SCROLLING CONSTRAINTS

    scroll = scroll as NestedScrollPosition;

    // No consume when bouncing overscroll for appbar pixels safety.
    if (scroll.totalPixels < scroll.minScrollExtent
     || scroll.totalPixels > scroll.maxScrollExtent) {
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

    final double consumed = appBar.setPixelsWithDelta(available);
    final double minScrollExtent = scroll.minScrollExtent;
    final double maxScrollExtent = scroll.maxScrollExtent;

    // When the app bar scrolls the layout intrinsic size changes so this
    // information is preemptively communicated to the [ScrollPosition].
    if (consumed.abs() > precisionErrorTolerance) {
      scroll.applyContentDimensions(minScrollExtent, max(minScrollExtent, maxScrollExtent + consumed));
    }

    return consumed;
  }

  @override
  AppBarAlignmentCommand? align(AppBarPosition appBar, ScrollPosition scroll) {
    if (alignAnimation) {
      return appBar.expandedPercent < 0.5
        ? AppBarAlignmentCommand.shrink
        : AppBarAlignmentCommand.expand;
    }

    return null;
  }
}