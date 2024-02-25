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

class AppBar extends StatefulWidget {
  AppBar({
    super.key,
    required Widget body,
    required this.behavior,
    this.alignment = AppBarAlignment.scroll,
  }) : builder = ((context, position) => body);
  
  const AppBar.builder({
    super.key, 
    required this.builder,
    required this.behavior,
    this.alignment = AppBarAlignment.scroll,
  });

  final AppBarBuilder builder;
  final AppBarBehavior behavior;
  final AppBarAlignment alignment;

  @override
  State<AppBar> createState() => _AppBarState();
}

class _AppBarState extends State<AppBar> {
  late final AppBarPosition _position = AppBarPosition(behavior: widget.behavior);

  @override
  void initState() {
    super.initState();
    
    final connection = AppBarConnection.of(context);
    assert(connection != null, "AppBarConnection widget does not exist at the ancestor.");

    connection?.attach(_position);
  }

  @override
  void dispose() {
    AppBarConnection.of(context)?.detach(_position);

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

  AppBarPosition get position => _position!;
  AppBarPosition? _position;
  set position(AppBarPosition value) {
    if (_position != value) {
      _position = value;
      _position!.addListener(markNeedsLayout);
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

  @override
  void performLayout() {
    child.layout(constraints, parentUsesSize: true);

    position.maxExtent = child.size.height;
    size = Size(
      child.size.width,
      child.size.height - position.pixels
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    return child.hitTest(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child, offset);
  }
}