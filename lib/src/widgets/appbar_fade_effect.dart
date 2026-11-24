import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/flutter_appbar.dart';

/// The widget that apply fade-out effect by a given appbar position.
class AppBarFadeEffect extends StatelessWidget {
  /// The fade-out effect is applied when on shrink the appbar.
  new onShrink({
    super.key,
    double start = 0,
    double end = 1,
    required AppBarPosition position,
    required this.child,
  }) : value = position.expandedPercent,
       start = 1 - start,
       end = 1 - end;

  /// The fade-out effect is applied when on expand the appbar.
  new onExpand({
    super.key,
    this.start = 0,
    this.end = 1,
    required AppBarPosition position,
    required this.child,
  }) : value = position.shrinkedPercent;

  final double start;
  final double end;
  final double value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: invertInRange(value, start, end),
      child: child,
    );
  }

  /// Inverts [value] within the range defined by [start] and [end].
  static double invertInRange(
    double value,
    double start,
    double end,
  ) {
    double minValue = start < end ? start : end;
    double maxValue = start < end ? end : start;

    if (value <= minValue) return 0;
    if (value >= maxValue) return 1;

    double normalized = (value - minValue) / (maxValue - minValue);
    return normalized;
  }
}
