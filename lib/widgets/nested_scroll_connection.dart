import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/scroll_position.dart';

typedef NestedScrollConsume = double Function(double available, ScrollPosition position);
typedef NestedScrollFlingConsume = double Function(double velocity, ScrollPosition position);
typedef NestedScrollBouncingConsume = double Function(double available, ScrollPosition position);

/// Used by [NestedScrollConnection].
class NestedScrollConnection extends StatefulWidget {
  const NestedScrollConnection({
    super.key,
    this.preScroll,
    this.postScroll,
    this.fling,
    this.bouncing,
    required this.child,
  });

  final NestedScrollConsume? preScroll;
  final NestedScrollConsume? postScroll;
  final NestedScrollFlingConsume? fling;
  final NestedScrollBouncingConsume? bouncing;
  final Widget child;
  
  /// Finds the ancestor [NestedScrollConnectionState] from the closest instance of this class
  /// that encloses the given context.
  /// 
  /// Used by [NestedScrollPosition].
  static NestedScrollConnectionState? of(BuildContext context) {
    return context.findAncestorStateOfType<NestedScrollConnectionState>();
  }

  @override
  State<NestedScrollConnection> createState() => NestedScrollConnectionState();
}

class NestedScrollConnectionState extends State<NestedScrollConnection> {
  double preScroll(double available, ScrollPosition position) {
    final consumed = widget.preScroll?.call(available, position) ?? 0.0;
    if ((consumed - available).abs() > precisionErrorTolerance) {
      return NestedScrollConnection.of(context)?.preScroll(available - consumed, position) ?? 0.0;
    }

    // The given scroll offset has all been consumed.
    return consumed;
  }
  
  double postScroll(double available, ScrollPosition position) {
    final consumed = widget.postScroll?.call(available, position) ?? 0.0;
    if ((consumed - available).abs() > precisionErrorTolerance) {
      return NestedScrollConnection.of(context)?.postScroll(available - consumed, position) ?? 0.0;
    }
    
    // The given scroll offset has all been consumed.
    return consumed;
  }

  double fling(double velocity, ScrollPosition position) {
    final consumed = widget.fling?.call(velocity, position) ?? velocity;
    if ((consumed - velocity).abs() > precisionErrorTolerance) {
      return NestedScrollConnection.of(context)?.fling(consumed, position) ?? consumed;
    }

    // The given scroll fling velocity has all been consumed.
    return consumed;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
