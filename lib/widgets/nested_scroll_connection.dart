import 'package:flutter/widgets.dart';

typedef NestedScrollConsume = double Function(double available,ScrollPosition position);

class NestedScrollConnection extends StatefulWidget {
  const NestedScrollConnection({
    super.key,
    this.preScroll,
    this.postScroll,
    required this.child,
  });

  final NestedScrollConsume? preScroll;
  final NestedScrollConsume? postScroll;
  final Widget child;

  static NestedScrollConnectionState? of(BuildContext context) {
    return context.findAncestorStateOfType<NestedScrollConnectionState>();
  }

  @override
  State<NestedScrollConnection> createState() => NestedScrollConnectionState();
}

class NestedScrollConnectionState extends State<NestedScrollConnection> {
  double preScroll(double available, ScrollPosition position) {
    final consumed = widget.preScroll?.call(available, position) ?? 0;
    if ((consumed - available).abs() > 0.000001) {
      return NestedScrollConnection.of(context)?.preScroll(available - consumed, position) ?? 0;
    }

    // The given scroll offset are all consumed.
    return consumed;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
