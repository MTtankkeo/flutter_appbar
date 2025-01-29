import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/appbar_position.dart';

enum AppbarPropagation {
  stop,
  next,
}

/// This class provides essential functionality and roles for managing and tracking the appbar.
/// 
/// See Also, It performs the following roles:
/// 
/// - Manages the competition for consuming scroll offsets among app bars.
/// - Defines and manages the state of app bars.
/// - Rebuilds the layout through alignment and listeners.
/// - Or other related tasks.
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

  /// Delegates the task of adding the appbar position to this controller
  /// to ensure it can be reliably detached and disposed later.
  void attach(AppBarPosition position) {
    assert(!_positions.contains(position), "Already attached in this controller.");
    _positions.add(position);
  }

  /// Delegates the task of detaching and disposing of the appbar position
  /// to ensure consistency with [attach] function.
  void detach(AppBarPosition position) {
    assert(_positions.contains(position), "Already not attached in this controller.");
    _positions.remove(position);
  }

  /// Returns attached the appbar position in this controller by given index.
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

  /// Delegates all positions and context from a given controller to itself
  /// and removes all positions from the given controller, ensuring that
  /// each appbar position exists only once in the controller.
  void delegateFrom(AppBarController other) {
    _positions.clear();
    _positions.addAll(other._positions..clear());
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

  /// Notifies that the state related to the controller has changed.
  void notifyListeners() {
    for (final listener in _listeners) {
      listener.call();
    }
  }

  /// Disposes all instances related the controller(e.g. [TouchRippleEffect]).
  void dispose() {
    _positions.toList().forEach((position) => detach(position));
  }
}
