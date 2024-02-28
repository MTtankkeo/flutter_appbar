import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/position.dart';

enum AppbarPropagation {
  stop,
  next,
}

class AppBarController {
  final _positions = <AppBarPosition>[];

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

      // If when a current available not consumed by a appbar.
      if ((consumed - previousConsumed).abs() > precisionErrorTolerance) {
        if (propagation == AppbarPropagation.stop) break;
        if (propagation == AppbarPropagation.next) continue; // for legibility.
      }
    }

    return consumed;
  }
}
