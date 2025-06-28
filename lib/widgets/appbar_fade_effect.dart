import 'package:flutter/material.dart';
import 'package:flutter_appbar/flutter_appbar.dart';
import 'package:flutter_appbar/utils/effect_util.dart';

/// The widget that apply fade-out effect by a given appbar position.
class AppBarFadeEffect extends StatelessWidget {
  /// The fade-out effect is applied when on shrink the appbar.
  AppBarFadeEffect.onShrink({
    super.key,
    double start = 0,
    double end = 1,
    required AppBarPosition position,
    required this.child,
  })  : value = position.expandedPercent,
        start = 1 - start,
        end = 1 - end;

  /// The fade-out effect is applied when on expand the appbar.
  AppBarFadeEffect.onExpand({
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
      opacity: EffectUtil.invertInRange(value, start, end),
      child: child,
    );
  }
}
