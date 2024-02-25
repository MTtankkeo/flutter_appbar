import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/position.dart';
import 'package:flutter_appbar/components/scroll_position.dart';

abstract class AppBarBehavior {
  const AppBarBehavior();

  double setPixels(
    double available,
    AppBarPosition appBar,
    ScrollPosition scroll,
  );
}

class MaterialAppBarBehavior extends AppBarBehavior {
  const MaterialAppBarBehavior({
    this.floating = false,
    this.dragOnlyExpanding = false,
  });

  final bool floating;
  final bool dragOnlyExpanding;

  @override
  double setPixels(double available, AppBarPosition appBar, ScrollPosition scroll) {
    assert(floating ? !dragOnlyExpanding : true, "[floating] and [dragOnlyExpanding] cannot be used together.");
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

    return appBar.setPixelsWithDelta(available);
  }
}
