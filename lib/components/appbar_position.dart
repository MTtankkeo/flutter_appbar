import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/appbar_behavior.dart';

class AppBarPosition extends Listenable {
  AppBarPosition({
    required this.vsync,
    required this.behavior,
    double initialPixels = 0,
  }) {
    _pixelsNotifier = ValueNotifier<double>(0);
  }

  late TickerProvider vsync;
  late AppBarBehavior behavior;

  AnimationController? _animation;

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

  void align(ScrollPosition scroll) {
    final alignBehavior = behavior.align(this, scroll);
    if (alignBehavior != null) {
      final start = pixels;
      final end   = alignBehavior.target == AppBarAlign.expand ? maxExtent : minExtent;

      /// If the target pixels and the current pixels are the same,
      /// a appbar is no need to align.
      if ((pixels - end).abs() < precisionErrorTolerance) {
        return;
      }

      _animation?.dispose();
      _animation = AnimationController(vsync: vsync, duration: alignBehavior.duration);
      _animation!.addListener(() {
        final vector = end - start;
        final newPixels = start + (vector * alignBehavior.curve.transform(_animation!.value));

        setPixels(newPixels);
      });
      _animation!.forward();
    }
  }

  void clearAlign() {
    _animation?.dispose();
    _animation = null;
  }

  @override
  void addListener(VoidCallback listener) {
    _pixelsNotifier.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _pixelsNotifier.removeListener(listener);
  }
}
