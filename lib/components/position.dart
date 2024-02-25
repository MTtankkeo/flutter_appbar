
import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/behavior.dart';

class AppBarPosition {
  AppBarPosition({
    required this.behavior,
    double initialPixels = 0,
  }) {
    _pixelsNotifier = ValueNotifier<double>(0);
  }

  late AppBarBehavior behavior;

  double get pixels => _pixelsNotifier.value;
  late final ValueNotifier<double> _pixelsNotifier;
  set pixels(double value) => _pixelsNotifier.value = value;

  // double pixels;
  double minExtent = 0;
  double maxExtent = 0;

  /// Returns the value that finally reflected [newPixels].
  double setPixels(double newPixels) {
    final oldPixels = pixels;

    if (newPixels < minExtent) {
      pixels = minExtent;
    } else if (newPixels > maxExtent) {
      pixels = maxExtent;
    } else {
      pixels = newPixels;
    }

    return oldPixels - pixels;
  }

  double setPixelsWithDelta(double delta) => setPixels(pixels - delta);

  void addListener(VoidCallback listener) {
    _pixelsNotifier.addListener(listener);
  }

  void removeListener(VoidCallback listener) {
    _pixelsNotifier.removeListener(listener);
  }
}