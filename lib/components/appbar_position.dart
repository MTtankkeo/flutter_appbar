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
    _pixelsNotifier.addListener(notifyListeners);

    _lentPixelsNotifier = ValueNotifier<double>(0);
    _lentPixelsNotifier.addListener(notifyListeners);
  }

  late final _listeners = ObserverList<VoidCallback>();

  late TickerProvider vsync;
  late AppBarBehavior behavior;

  AnimationController? _animation;

  double get pixels => _pixelsNotifier.value;
  late final ValueNotifier<double> _pixelsNotifier;
  set pixels(double value) => _pixelsNotifier.value = value;

  double get lentPixels => _lentPixelsNotifier.value;
  late final ValueNotifier<double> _lentPixelsNotifier;
  set lentPixels(double value) => _lentPixelsNotifier.value = value;

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

  /// Returns the value that finally reflected [delta].
  double setPixelsWithDelta(double delta) => setPixels(pixels - delta);

  /// Animates alignment of the appbar by a given scroll position
  /// and the alignment behavior of the current behavior.
  bool notifyScrollEnd(ScrollPosition scroll) {
    final alignment = behavior.align(this, scroll);
    if (alignment != null) {
      performAlignment(alignment);
      return true;
    }

    return false;
  }

  /// Animates alignment of the appbar by a given scroll position
  /// and a given appbar alignment behavior.
  void performAlignment(AppBarAlignmentCommand command) {
    final start = pixels;
    final end = command == AppBarAlignmentCommand.shrink ? maxExtent : minExtent;

    /// If the target pixels and the current pixels are the same,
    /// a appbar is no need to align.
    if ((pixels - end).abs() < precisionErrorTolerance) {
      return;
    }

    _animation?.dispose();
    _animation = AnimationController(vsync: vsync, duration: behavior.alignDuration);
    _animation!.addListener(() {
      final newVector = end - start;
      final newPixels = start + (newVector * behavior.alignCurve.transform(_animation!.value));

      setPixels(newPixels);
    });
    _animation!.forward();
  }

  void expand() => performAlignment(AppBarAlignmentCommand.expand);
  void shrink() => performAlignment(AppBarAlignmentCommand.shrink);

  void clearAlign() {
    _animation?.dispose();
    _animation = null;
  }

  @override
  void addListener(VoidCallback listener) {
    assert(!_listeners.contains(listener), "Already exists a given listener.");
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    assert(_listeners.contains(listener), "Already not exists a given listener.");
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (final listener in _listeners) {
      listener.call();
    }
  }
}
