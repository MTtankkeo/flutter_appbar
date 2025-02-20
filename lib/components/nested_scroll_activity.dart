import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/nested_scroll_position.dart';

class BallisticNestedScrollActivity extends BallisticScrollActivity {
  BallisticNestedScrollActivity(
    super.delegate,
    super.simulation,
    super.vsync,
    super.shouldIgnorePointer
  );

  NestedScrollPosition get position => delegate as NestedScrollPosition;

  double? newPixels;
  double? oldPixels;

  @override
  bool applyMoveTo(double value) {
    oldPixels ??= position.totalPixels;
    newPixels = value;
    final delta = newPixels! - oldPixels!;

    Future.microtask(() => oldPixels = newPixels);

    // The value of pixels for the new scroll offset.
    final pixels = position.pixels + delta;

    return super.applyMoveTo(pixels);
  }

  double applyOverscrollTo(double value) {
    return value;
  }
}