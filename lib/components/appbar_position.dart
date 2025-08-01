import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/appbar_behavior.dart';

class AppBarPosition extends Listenable {
  AppBarPosition({
    required this.vsync,
    required this.behavior,
    double initialOffset = 0,
  }) {
    assert(initialOffset >= 0, "The [initialOffset] must be from 0 to 1");
    assert(initialOffset <= 1, "The [initialOffset] must be from 0 to 1");

    _offsetNotifier = ValueNotifier<double>(initialOffset);
    _offsetNotifier.addListener(notifyListeners);

    _lentPixelsNotifier = ValueNotifier<double>(0);
    _lentPixelsNotifier.addListener(notifyListeners);
  }

  /// The observer list that defines function that is called
  /// when the pixels of the appbar position changed.
  late final _listeners = ObserverList<VoidCallback>();

  late TickerProvider vsync;
  late AppBarBehavior behavior;

  /// Controls the animation for appbar alignment. (e.g., expanding, shrinking).
  ///
  /// This instance of [AnimationController] is typically used to drive
  /// animations that visually represent the alignment of the app bar,
  /// such as during expand or shrink operations.
  AnimationController? _animation;

  /// Returns the pixels representing the expanded state of the appbar.
  double get expandedPixels => 0.0;

  /// Returns the pixels representing the shrinked state of the appbar.
  double get shrinkedPixels => extent;

  /// Returns the normalized pixels of the appbar position.
  double get offset => _offsetNotifier.value;

  /// The instance that defines the normalized pixels of the appbar position.
  late final ValueNotifier<double> _offsetNotifier;

  /// Defines the normalized pixels of the appbar position.
  set offset(double value) {
    assert(value >= 0, "A given value must be from 0 to 1");
    assert(value <= 1, "A given value must be from 0 to 1");
    _offsetNotifier.value = value;
  }

  double get lentPixels => _lentPixelsNotifier.value;
  late final ValueNotifier<double> _lentPixelsNotifier;
  set lentPixels(double value) => _lentPixelsNotifier.value = value;

  double minExtent = 0;
  double maxExtent = 0;

  /// Returns the pixels where the appbar can scroll.
  double get extent => maxExtent - minExtent;

  /// Returns the current intrinsic pixels of the appbar position.
  double get pixels => extent * offset;

  /// The current expansion percentage(0.0 ~ 1.0) of the appbar.
  double get expandedPercent => maxExtent == 0 ? 1 : 1 - shrinkedPercent;

  /// The current shrinking percentage(0.0 ~ 1.0) of the appbar.
  double get shrinkedPercent => maxExtent == 0 ? 0 : offset;

  /// Returns the value that finally reflected [newPixels].
  double setPixels(double newPixels) {
    final double oldPixels = pixels;
    final double normalized = newPixels < 0 ? 0 : newPixels / extent;

    offset = normalized.abs().clamp(0, 1);

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
    final end =
        command == AppBarAlignmentCommand.shrink ? maxExtent : minExtent;

    /// If the target pixels and the current pixels are the same,
    /// a appbar is no need to align.
    if ((pixels - end).abs() < precisionErrorTolerance) {
      return;
    }

    _animation?.dispose();
    _animation =
        AnimationController(vsync: vsync, duration: behavior.alignDuration);
    _animation!.addListener(() {
      final newVector = end - start;
      final newPixels = start +
          (newVector * behavior.alignCurve.transform(_animation!.value));

      setPixels(newPixels);
    });
    _animation!.forward();
  }

  /// Expands the appbar to its expanded state, optionally with animation.
  ///
  /// If [useAnimate] is true (default), the expansion will be animated.
  /// Otherwise, the app bar will snap to its expanded size immediately.
  void expand({bool useAnimate = true}) {
    if (useAnimate) {
      performAlignment(AppBarAlignmentCommand.expand);
      return;
    }

    setPixels(expandedPixels);
  }

  /// Shrinks the appbar to its shrinked state, optionally with animation.
  ///
  /// If [useAnimate] is true (default), the shrinking will be animated.
  /// Otherwise, the app bar will snap to its shrunk size immediately.
  void shrink({bool useAnimate = true}) {
    if (useAnimate) {
      performAlignment(AppBarAlignmentCommand.shrink);
      return;
    }

    setPixels(shrinkedPixels);
  }

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
    assert(
      _listeners.contains(listener),
      "Already not exists a given listener.",
    );
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (final listener in _listeners) {
      listener.call();
    }
  }
}
