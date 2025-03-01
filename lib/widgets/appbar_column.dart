import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/appbar_controller.dart';

/// A widget that represents a column of app bars with a custom render object.
/// It listens to the [AppBarController] for layout updates.
class AppBarColumn extends StatefulWidget {
  const AppBarColumn({
    super.key,
    required this.controller,
    required this.constraints,
    required this.children,
  });

  /// The instance that defines a controller that manages app bar state updates.
  final AppBarController controller;

  /// The instance that defines constraints inherited from
  /// the parent widget to control the layout.
  final BoxConstraints constraints;

  /// The values that defines appbar widgets to be displayed in a column.
  final List<Widget> children;

  @override
  State<AppBarColumn> createState() => _AppBarColumnState();
}

class _AppBarColumnState extends State<AppBarColumn> {
  /// Called when the appbar properties are updated.
  void didUpdateAppBar() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(didUpdateAppBar);
  }

  @override
  void dispose() {
    widget.controller.removeListener(didUpdateAppBar);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RenderAppBarColumn(
      constraints: widget.constraints,
      child: Column(children: widget.children),
    );
  }
}

/// A widget that delegates layout to a custom render box for precise control
/// over the size and constraints of the app bar column.
class RenderAppBarColumn extends SingleChildRenderObjectWidget {
  const RenderAppBarColumn({
    super.key,
    required super.child,
    required this.constraints
  });

  /// The instance that defines constraints that dictate the maximum allowable size.
  final BoxConstraints constraints;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return AppBarColumnRenderBox(parentConstraints: constraints);
  }

  @override
  void updateRenderObject(BuildContext context, covariant AppBarColumnRenderBox renderObject) {
    renderObject.parentConstraints = constraints;
  }
}

/// A custom render-box that ensures the app bar column does not overflow
/// by enforcing size constraints from the parent widget(i.g. ancestor).
class AppBarColumnRenderBox extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  AppBarColumnRenderBox({required BoxConstraints parentConstraints}) {
    _parentConstraints = parentConstraints;
  }

  @override
  RenderBox get child => super.child!;

  late BoxConstraints _parentConstraints;
  BoxConstraints get parentConstraints => _parentConstraints;
  set parentConstraints(BoxConstraints newValue) {
    if (_parentConstraints != newValue) {
      _parentConstraints = newValue;
      markNeedsLayout();
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return child.hitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    child.layout(constraints, parentUsesSize: true);

    // Clamps the size to the parent constraints to prevent layout overflow.
    size = Size(
      child.size.width.clamp(0, parentConstraints.maxWidth),
      child.size.height.clamp(0, parentConstraints.maxHeight)
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child, offset);
  }
}