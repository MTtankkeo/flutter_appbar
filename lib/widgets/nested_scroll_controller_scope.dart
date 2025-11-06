import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/flutter_appbar.dart';

/// Signature for a function that creates a [NestedScrollController] when needed.
/// Called only if no controller exists in the current context.
typedef NestedScrollControllerBuilder = NestedScrollController Function(
  BuildContext context,
);

/// Signature for building a widget that requires a [NestedScrollController].
typedef NestedScrollWidgetBuilder = Widget Function(
  BuildContext context,
  NestedScrollController controller,
);

/// Ensures a single [NestedScrollController] is used within the widget tree.
///
/// If an ancestor has already provided a [NestedScrollController] via
/// [PrimaryScrollController], this widget uses that controller to avoid
/// conflicts caused by multiple controllers being created by different
/// widgets or packages.
///
/// Otherwise, it creates a new [NestedScrollController] for its children.
class NestedScrollControllerScope extends StatefulWidget {
  const NestedScrollControllerScope({
    super.key,
    required this.factory,
    required this.builder,
    this.controller,
  });

  /// Called to create a [NestedScrollController] if no controller is provided.
  /// Used only when the widget needs to generate a controller for its children.
  final NestedScrollControllerBuilder factory;

  /// Builds widgets with the available [NestedScrollController].
  final NestedScrollWidgetBuilder builder;

  /// Optional controller that can be passed from outside.
  /// If provided, the widget will use this instead of creating a new one.
  final NestedScrollController? controller;

  @override
  State<NestedScrollControllerScope> createState() =>
      _NestedScrollControllerScopeState();
}

class _NestedScrollControllerScopeState
    extends State<NestedScrollControllerScope> {
  NestedScrollController? _controller;

  /// Whether the widget should dispose the controller it created.
  /// Defaults to true if no [NestedScrollController] is provided.
  late bool shouldDispose = widget.controller == null;

  @override
  void dispose() {
    if (shouldDispose) _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = PrimaryScrollController.maybeOf(context);

    // Reuse the existing NestedScrollController.
    if (primary != null && primary is NestedScrollController) {
      return widget.builder(context, primary);
    }

    // Create a NestedScrollController if none exists.
    _controller ??= widget.controller ?? widget.factory(context);

    return PrimaryScrollController(
      scrollDirection: Axis.vertical,
      controller: _controller!,
      child: widget.builder(context, _controller!),
    );
  }
}
