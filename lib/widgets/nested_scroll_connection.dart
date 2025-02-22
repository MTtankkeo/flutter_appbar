import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

typedef NestedScrollListener = double Function(double available, ScrollPosition position);
typedef NestedScrollFlingListener = double Function(double velocity, ScrollPosition position);

/// Used by [NestedScrollConnection].
class NestedScrollConnection extends StatefulWidget {
  const NestedScrollConnection({
    super.key,
    this.onPreScroll,
    this.onPostScroll,
    this.onFling,
    this.onBouncing,
    required this.child,
  });

  final NestedScrollListener? onPreScroll;
  final NestedScrollListener? onPostScroll;
  final NestedScrollFlingListener? onFling;
  final NestedScrollListener? onBouncing;
  final Widget child;

  /// Finds the ancestor [NestedScrollConnectionState] from the closest instance of this class
  /// that encloses the given context.
  static NestedScrollConnectionState? of(BuildContext context) {
    return context.findAncestorStateOfType<NestedScrollConnectionState>();
  }

  @override
  State<NestedScrollConnection> createState() => NestedScrollConnectionState();
}

class NestedScrollConnectionState extends State<NestedScrollConnection> {
  double preScroll(double available, ScrollPosition position) {
    final consumed = widget.onPreScroll?.call(available, position) ?? 0.0;
    if ((consumed - available).abs() > precisionErrorTolerance) {
      return NestedScrollConnection.of(context)?.preScroll(available - consumed, position) ?? consumed;
    }

    // The given scroll offset has all been consumed.
    return consumed;
  }

  double postScroll(double available, ScrollPosition position) {
    final consumed = widget.onPostScroll?.call(available, position) ?? 0.0;
    if ((consumed - available).abs() > precisionErrorTolerance) {
      return NestedScrollConnection.of(context)?.postScroll(available - consumed, position) ?? consumed;
    }

    // The given scroll offset has all been consumed.
    return consumed;
  }

  double fling(double velocity, ScrollPosition position) {
    final consumed = widget.onFling?.call(velocity, position) ?? velocity;
    if ((consumed - velocity).abs() > precisionErrorTolerance) {
      return NestedScrollConnection.of(context)?.fling(consumed, position) ?? consumed;
    }

    // The given scroll fling velocity has all been consumed.
    return consumed;
  }

  double bouncing(double available, ScrollPosition position) {
    final consumed = widget.onBouncing?.call(available, position) ?? 0.0;
    if ((consumed - available).abs() > precisionErrorTolerance) {
      return NestedScrollConnection.of(context)?.bouncing(available - consumed, position) ?? consumed;
    }

    // The given scroll offset has all been consumed.
    return consumed;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
