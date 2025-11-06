import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/flutter_appbar.dart';

/// Signature for the callback that is called when nested scroll event consuming.
typedef NestedScrollListener = double Function(
  double available,
  NestedScrollPosition position,
);

/// Signature for the predicate that is used when all events from child
/// widgets need to be consumed and taken over in specific situations.
typedef NestedScrollPredicate = bool Function(
  double available,
  NestedScrollPosition position,
);

/// Signature for the callback that returns a [NestedScrollListener] which
/// handles nested scroll consumption logic based on the connection.
typedef NestedScrollConsumer = NestedScrollListener? Function(
  NestedScrollConnection connection,
);

/// The enumeration that defines how nested scrolling events are handled.
enum NestedScrollConnectionPropagation {
  /// Sets the current widget to handle scrolling events first
  /// before passing any remaining events to an ancestor.
  selfFirst,

  /// Sets scrolling events to be deferred to an ancestor
  /// before being handled by the current widget.
  deferToAncestor,

  /// Sets downward scrolls to be handled by the child first,
  /// while upward scrolls are handled by the ancestor first.
  directional,
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
    this.predicate,
    this.propagation = NestedScrollConnectionPropagation.directional,
    required this.child,
  });

  final NestedScrollListener? onPreScroll;
  final NestedScrollListener? onPostScroll;
  final NestedScrollListener? onFling;
  final NestedScrollListener? onBouncing;
  final NestedScrollPredicate? predicate;
  final NestedScrollConnectionPropagation propagation;
  final Widget child;

  /// Finds the ancestor [NestedScrollConnectionState] from the closest
  /// instance of this class that encloses the given context.
  static NestedScrollConnectionState? of(BuildContext context) {
    return context.findAncestorStateOfType<NestedScrollConnectionState>();
  }

  @override
  State<NestedScrollConnection> createState() => NestedScrollConnectionState();
}

class NestedScrollConnectionState extends State<NestedScrollConnection> {
  /// Returns a list of [NestedScrollConnection] widgets
  /// including self and all ancestor widgets up the tree.
  List<NestedScrollConnection> findSelfAndAncestorWidgets() {
    final List<NestedScrollConnection> widgets = [widget];

    context.visitAncestorElements((element) {
      if (element.widget is NestedScrollConnection) {
        widgets.add(element.widget as NestedScrollConnection);
      }

      return true;
    });

    return widgets;
  }

  double consumeWith(
    double available,
    NestedScrollPosition position,
    NestedScrollConsumer selfConsumer,
    NestedScrollConsumer ancestorConsumer,
  ) {
    final List<NestedScrollConnection> delegators =
        findSelfAndAncestorWidgets();

    // Current consumed amount from available.
    double consumed = 0;

    // Returns the remaining offset after consumption.
    double remained() => available - consumed;

    for (final delegator in delegators) {
      if (delegator.predicate?.call(available, position) ?? false) {
        consumed += selfConsumer(delegator)?.call(remained(), position) ?? 0.0;

        // When the available offset has been fully consumed.
        if ((consumed - available).abs() < precisionErrorTolerance) {
          return consumed;
        }
      }
    }

    if (widget.propagation == NestedScrollConnectionPropagation.selfFirst) {
      consumed += selfConsumer(widget)?.call(remained(), position) ?? 0.0;

      // When the available offset is not fully consumed,
      // delegate the remainder to the ancestor.
      if ((consumed - available).abs() > precisionErrorTolerance) {
        return ancestorConsumer(widget)?.call(remained(), position) ?? consumed;
      }
    } else if (widget.propagation ==
        NestedScrollConnectionPropagation.deferToAncestor) {
      consumed += ancestorConsumer(widget)?.call(remained(), position) ?? 0.0;

      // When the available offset is not fully consumed,
      // delegate the remainder to the ancestor.
      if ((consumed - available).abs() > precisionErrorTolerance) {
        return selfConsumer(widget)?.call(remained(), position) ?? consumed;
      }
    } else {
      final prioritized = List<NestedScrollConnection>.from(delegators)
        ..sort((a, b) {
          int priority(NestedScrollConnection c) {
            return switch (c.propagation) {
              NestedScrollConnectionPropagation.selfFirst => 0,
              NestedScrollConnectionPropagation.directional => 1,
              NestedScrollConnectionPropagation.deferToAncestor => 2,
            };
          }

          return priority(a).compareTo(priority(b));
        });

      final targets = available > 0 ? prioritized : prioritized.reversed;

      for (final it in targets) {
        consumed += selfConsumer(it)?.call(remained(), position) ?? 0;

        // If when all consumed, stops the travel.
        if ((consumed - available).abs() < precisionErrorTolerance) {
          break;
        }
      }
    }

    return consumed;
  }

  double preScroll(double available, NestedScrollPosition position) {
    return consumeWith(
      available,
      position,
      (connection) => connection.onPreScroll,
      (connection) => NestedScrollConnection.of(context)?.preScroll,
    );
  }

  double postScroll(double available, NestedScrollPosition position) {
    return consumeWith(
      available,
      position,
      (connection) => connection.onPostScroll,
      (connection) => NestedScrollConnection.of(context)?.postScroll,
    );
  }

  double fling(double available, NestedScrollPosition position) {
    return consumeWith(
      available,
      position,
      (connection) => connection.onFling,
      (connection) => NestedScrollConnection.of(context)?.fling,
    );
  }

  double bouncing(double available, NestedScrollPosition position) {
    return consumeWith(
      available,
      position,
      (connection) => connection.onBouncing,
      (connection) => NestedScrollConnection.of(context)?.bouncing,
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
