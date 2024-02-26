import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/behavior.dart';
import 'package:flutter_appbar/components/position.dart';
import 'package:flutter_appbar/flutter_appbar.dart';

typedef AppBarBuilder = Widget Function(BuildContext context, AppBarPosition position);

enum AppBarAlignment {
  absolute,
  center,
  scroll,
}

/// The widget configures dynamic appbar behavior that interacts
/// with [Scrollable] widget.
///
/// Used with [AppBarConnection].
class AppBar extends StatefulWidget {
  AppBar({
    super.key,
    required Widget body,
    required this.behavior,
    this.alignment = AppBarAlignment.scroll,
  }) : builder = ((_, position) => body);

  AppBar.builder({
    super.key,
    required AppBarBuilder builder,
    required this.behavior,
    this.alignment = AppBarAlignment.scroll,
  }) : builder = ((_, position) {

    // When position is updated, the widget state is also updated.
    return AnimatedBuilder(animation: position, builder: (context, _) => builder(context, position));
  });

  final AppBarBuilder builder;
  final AppBarBehavior behavior;
  final AppBarAlignment alignment;

  @override
  State<AppBar> createState() => _AppBarState();
}

class _AppBarState extends State<AppBar> with SingleTickerProviderStateMixin {
  late final AppBarPosition _position = AppBarPosition(
    vsync: this,
    behavior: widget.behavior
  );

  late final AppBarConnectionState? _connection;

  @override
  void initState() {
    super.initState();

    _connection = AppBarConnection.of(context);
    assert(_connection != null, "AppBarConnection widget does not exist at the ancestor.");

    // Attach the initial position to the appbar controller.
    _connection?.attach(_position);
  }

  @override
  void didUpdateWidget(covariant AppBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.behavior != widget.behavior) {
      _position.behavior = widget.behavior;
    }
  }

  @override
  void dispose() {
    _connection?.detach(_position);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: _AppBar(
        position: _position,
        alignment: widget.alignment,
        child: widget.builder(context, _position),
      ),
    );
  }
}

class _AppBar extends SingleChildRenderObjectWidget {
  const _AppBar({
    required super.child,
    required this.position,
    required this.alignment,
  });

  final AppBarPosition position;
  final AppBarAlignment alignment;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAppBar(position: position, alignment: alignment);
  }

  @override
  void updateRenderObject(BuildContext context, RenderAppBar renderObject) {
    renderObject
      ..position = position
      ..alignment = alignment;
  }
}

class RenderAppBar extends RenderBox with RenderObjectWithChildMixin<RenderBox> {
  RenderAppBar({
    required AppBarPosition position,
    required AppBarAlignment alignment,
  }) {
    this.position = position;
    this.alignment = alignment;
  }

  @override
  RenderBox get child => super.child!;

  /// When the child size previously measured in the layout phase should be recycled.
  bool useCachedSize = false;

  AppBarPosition get position => _position!;
  AppBarPosition? _position;
  set position(AppBarPosition value) {
    if (_position != value) {
      _position = value;
      _position!.addListener(() {

        // Because the size of the child widget itself has not updated,
        // there is no need to remeasure size of child widget in the layout phase.
        useCachedSize = true;
        markNeedsLayout();
      });
      markNeedsLayout();
    }
  }

  AppBarAlignment get alignment => _alignment!;
  AppBarAlignment? _alignment;
  set alignment(AppBarAlignment value) {
    if (_alignment != value) {
      _alignment = value;
      markNeedsLayout();
    }
  }

  Offset align(Offset offset) {
    switch (alignment) {
      case AppBarAlignment.absolute: return offset;
      case AppBarAlignment.center: return Offset(offset.dx, offset.dy - position.pixels / 2);
      case AppBarAlignment.scroll: return Offset(offset.dx, offset.dy - position.pixels);
    }
  }

  @override
  void performLayout() {
    if (!useCachedSize) {
      child.layout(constraints, parentUsesSize: true);
    } else {
      useCachedSize = false;
    }

    position.maxExtent = child.size.height;
    size = Size(child.size.width, child.size.height - position.pixels);
  }

  /// No need to implement hit-test in this [RenderBox].
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return child.hitTest(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child, align(offset));
  }
}
