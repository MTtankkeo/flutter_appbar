import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/position.dart';

class AppBarController {
  final _positions = <AppBarPosition>[];

  attach(AppBarPosition position) {
    assert(
        !_positions.contains(position), "Already attached in this controller.");
    _positions.add(position);
  }

  detach(AppBarPosition position) {
    assert(_positions.contains(position),
        "Already not attached in this controller.");
    _positions.remove(position);
  }

  double consumeAll(double available, ScrollPosition scroll) {
    final targets = available < 0 ? _positions : _positions.reversed;
    double consumed = 0;

    for (final it in targets) {
      consumed += it.behavior.setPixels(available - consumed, it, scroll);
    }

    return consumed;
  }
}
