import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/appbar_position.dart';

enum AppbarPropagation {
  stop,
  next,
}

class AppBarController extends Listenable {
  /// The values defines the instance of [AppBarPosition].
  final _positions = <AppBarPosition>[];

  /// The listeners called when a state of this controller changed.
  final _listeners = ObserverList<VoidCallback>();

  /// The value defines the instance of [EdgeInsets] for the appbar padding.
  EdgeInsets _padding = const EdgeInsets.all(0.0);

  /// Returns the instance of [EdgeInsets] for the appbar padding.
  EdgeInsets get padding {
    return _padding;
  }

  /// Defines the appbar padding as a given [insets].
  set padding(EdgeInsets insets) {
    _padding = insets;
    notifyListeners();
  }

  attach(AppBarPosition position) {
    assert(!_positions.contains(position), "Already attached in this controller.");
    _positions.add(position);
  }

  detach(AppBarPosition position) {
    assert(_positions.contains(position), "Already not attached in this controller.");
    _positions.remove(position);
  }

  /// Returns attached a appbar position in this controller by given index.
  AppBarPosition at(int index) {
    if (_positions.length < index && index < 0) {
      throw FlutterError("The given index overflowed attached appbar positions length.");
    }

    return _positions[index];
  }

  double consumeAll(double available, ScrollPosition scroll, AppbarPropagation propagation) {
    final targets = available < 0 ? _positions : _positions.reversed;
    double consumed = 0;

    for (final it in targets) {
      final previousConsumed = consumed;
      consumed += it.behavior.setPixels(available - consumed, it, scroll);

      // If when all consumed, stops the travel.
      if ((consumed - available).abs() < precisionErrorTolerance) {
        break;
      }

      // If when a current available not consumed by a appbar.
      if ((consumed - previousConsumed).abs() > precisionErrorTolerance) {
        if (propagation == AppbarPropagation.stop) break;
        if (propagation == AppbarPropagation.next) continue;
      }
    }

    return consumed;
  }

  void clearAlignAll() {
    for (final it in _positions) { it.clearAlign(); }
  }

  void alignAll(ScrollPosition position) {
    for (final it in _positions) { it.align(position); }
  }
  
  @override
  void addListener(VoidCallback listener) {
    assert(!_listeners.contains(listener), "Already exists a given listener.");
    _listeners.add(listener);
  }
  
  @override
  void removeListener(VoidCallback listener) {
    assert(_listeners.contains(listener), "Already not exists a given listener");
    _listeners.remove(listener);
  }

  notifyListeners() {
    for (final listener in _listeners) {
      listener.call();
    }
  }
}
