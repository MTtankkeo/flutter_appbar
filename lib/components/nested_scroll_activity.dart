import 'package:flutter/widgets.dart';

class BallisticNestedScrollActivity extends BallisticScrollActivity {
  BallisticNestedScrollActivity(
    super.delegate,
    super.simulation,
    super.vsync,
    super.shouldIgnorePointer
  );

  ScrollPosition get position => delegate as ScrollPosition;

  double? newPixels;
  double? oldPixels;

  @override
  bool applyMoveTo(double value) {
    oldPixels ??= position.pixels;
    newPixels = value;
    final delta = newPixels! - oldPixels!;

    Future.microtask(() => oldPixels = newPixels);

    return super.applyMoveTo(position.pixels + delta);
  }
}