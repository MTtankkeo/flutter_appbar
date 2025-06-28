import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Signature for the callback that is called when nested scroll event consuming.
typedef NestedScrollListener = double Function(
    double available, ScrollPosition position);

/// The enumeration that defines how nested scrolling events are handled.
enum NestedScrollConnectionPropagation {
  /// Sets the current widget to handle scrolling events first
  /// before passing any remaining events to an ancestor.
  selfFirst,

  /// Sets scrolling events to be deferred to an ancestor
  /// before being handled by the current widget.
  deferToAncestor
}

/// A widget that allows the ancestor to consume the new scroll offset occurring
/// in a descendant [Scrollable] widget before it is consumed by the child.
///
/// Used by [NestedScrollConnection].
class NestedScrollConnection extends StatefulWidget {
  const NestedScrollConnection({
    super.key,
    this.onPreScroll,
    this.onPostScroll,
    this.onFling,
    this.onBouncing,
    this.propagation = NestedScrollConnectionPropagation.selfFirst,
    required this.child,
  });

  final NestedScrollListener? onPreScroll;
  final NestedScrollListener? onPostScroll;
  final NestedScrollListener? onFling;
  final NestedScrollListener? onBouncing;
  final NestedScrollConnectionPropagation propagation;
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
  double consumeWith(
      double available,
      ScrollPosition position,
      NestedScrollListener? selfListener,
      NestedScrollListener? ancestorListener) {
    final double consumed;

    if (widget.propagation == NestedScrollConnectionPropagation.selfFirst) {
      consumed = selfListener?.call(available, position) ?? 0.0;
      if ((consumed - available).abs() > precisionErrorTolerance) {
        return ancestorListener?.call(available - consumed, position) ??
            consumed;
      }
    } else {
      consumed = ancestorListener?.call(available, position) ?? 0.0;
      if ((consumed - available).abs() > precisionErrorTolerance) {
        return selfListener?.call(available - consumed, position) ?? consumed;
      }
    }

    return consumed;
  }

  double preScroll(double available, ScrollPosition position) {
    return consumeWith(available, position, widget.onPreScroll,
        NestedScrollConnection.of(context)?.preScroll);
  }

  double postScroll(double available, ScrollPosition position) {
    return consumeWith(available, position, widget.onPostScroll,
        NestedScrollConnection.of(context)?.postScroll);
  }

  double fling(double available, ScrollPosition position) {
    return consumeWith(available, position, widget.onFling,
        NestedScrollConnection.of(context)?.fling);
  }

  double bouncing(double available, ScrollPosition position) {
    return consumeWith(available, position, widget.onBouncing,
        NestedScrollConnection.of(context)?.bouncing);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
