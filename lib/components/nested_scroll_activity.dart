import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/nested_scroll_position.dart';

/// A [BallisticScrollActivity] that applies scroll updates
/// based on the delta for a [NestedScrollPosition].
class BallisticNestedScrollActivity extends BallisticScrollActivity {
  BallisticNestedScrollActivity(
    super.delegate,
    super.simulation,
    super.vsync,
    super.shouldIgnorePointer,
  );

  NestedScrollPosition get position => delegate as NestedScrollPosition;

  double? _newPixels;
  double? _oldPixels;

  @override
  bool applyMoveTo(double value) {
    _oldPixels ??= position.totalPixels;
    _newPixels = value;
    final delta = _newPixels! - _oldPixels!;

    Future.microtask(() => _oldPixels = _newPixels);

    // The value of pixels for the new scroll offset.
    final pixels = position.pixels + delta;

    return super.applyMoveTo(pixels);
  }

  /// No overscroll adjustment applied.
  double applyOverscrollTo(double value) {
    return value;
  }
}
