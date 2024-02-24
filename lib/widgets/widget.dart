import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/scroll_controller.dart';
import 'package:flutter_appbar/widgets/appbar.dart';
import 'package:flutter_appbar/widgets/gesture_delegator.dart';

class AppBarConnection extends StatefulWidget {
  const AppBarConnection({
    super.key,
    required this.appBars,
    required this.child,
    this.scrollController,
  });
  
  final List<AppBar> appBars;
  final Widget child;
  
  /// This controller is define scroll controller of [PrimaryScrollController].
  final NestedScrollController? scrollController;

  @override
  State<AppBarConnection> createState() => _AppBarConnectionState();
}

class _AppBarConnectionState extends State<AppBarConnection> {
  late final NestedScrollController _scrollController = widget.scrollController ?? NestedScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScrollableGestureDelegator(
          controller: _scrollController,
          child: Column(children: widget.appBars)
        ),
        
        // with scrollable.
        Expanded(
          child: PrimaryScrollController(controller: _scrollController, child: widget.child),
        ),
      ],
    );
  }
}