import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/behavior.dart';

class AppBarPosition extends Listenable {
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

  double minExtent = 0;
  double maxExtent = 0;

  double get expandedPercent => maxExtent == 0 ? 1 : 1 - shrinkedPercent;
  double get shrinkedPercent => maxExtent == 0 ? 0 : pixels / maxExtent;

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

  @override
  void addListener(VoidCallback listener) {
    _pixelsNotifier.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _pixelsNotifier.removeListener(listener);
  }
}
