import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/position.dart';
import 'package:flutter_appbar/components/scroll_position.dart';

enum AppBarAlign {
  none,
  expand,
  shrink,
}

abstract class AppBarBehavior {
  const AppBarBehavior();

  double setPixels(
    double available,
    AppBarPosition appBar,
    ScrollPosition scroll,
  );

  AppBarAlign align(AppBarPosition appBar, ScrollPosition scroll);
}

class MaterialAppBarBehavior extends AppBarBehavior {
  const MaterialAppBarBehavior({
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

  @override
  double setPixels(double available, AppBarPosition appBar, ScrollPosition scroll) {
    assert(floating ? !dragOnlyExpanding : true, "[floating] and [dragOnlyExpanding] cannot be used together.");

    // APPBAR SCROLLING CONSTRAINTS

    if (!floating) {
      final bool isDragging = !(scroll as NestedScrollPosition).isBallisticScrolling;
      
      if (scroll.pixels > 0) {
        return 0;
      } else {
        if (dragOnlyExpanding
         && isDragging == false
         && appBar.shrinkedPercent == 1) {
          return 0;
        }
      }
    }

    if (!alwaysScrolling) {
      if (appBar.maxExtent > scroll.maxScrollExtent) return 0;
    }

    return appBar.setPixelsWithDelta(available);
  }

  @override
  AppBarAlign align(AppBarPosition appBar, ScrollPosition scroll) {
    return appBar.expandedPercent > 0.5
      ? AppBarAlign.expand
      : AppBarAlign.shrink;
  }
}