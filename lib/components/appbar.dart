import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/flutter_appbar.dart';

/// Signature for a function that creates a widget for a appbar.
///
/// Used by [AppBar.builder].
typedef AppBarBuilder = Widget Function(
  BuildContext context,
  AppBarPosition position,
);

/// This enum provides multiple alignment options for positioning
/// the appbar relative to the scroll behavior and layout size.
enum AppBarAlignment {
  /// Sets to display the same as the scroll item. (default)
  absolute,

  /// Sets to based on the size of the appbar, the center
  /// is located at the center of the size of the appbar.
  center,

  /// Sets to even if the appbar is reduced and expanded,
  /// the absolute position of the appbar does not change.
  scroll,
}

/// The widget configures dynamic appbar behavior that interacts
/// with [Scrollable] widget.
///
/// Used with [AppBarConnection].
class AppBar extends StatefulWidget {
  AppBar({
    super.key,
    required this.behavior,
    required Widget body,
    this.alignment = AppBarAlignment.scroll,
    this.bouncingAlignment = AppBarAlignment.scroll,
    this.initialOffset = 0,
  }) : builder = ((_, position) => body);

  AppBar.builder({
    super.key,
    required this.behavior,
    required AppBarBuilder builder,
    this.alignment = AppBarAlignment.scroll,
    this.bouncingAlignment = AppBarAlignment.scroll,
    this.initialOffset = 0,
  }) : builder = ((_, position) {
          /// When position is updated, the widget state is also updated.
          return ListenableBuilder(
            listenable: position,
            builder: (context, _) => builder(context, position),
          );
        });

  /// The function that creates a widget for the appbar.
  final AppBarBuilder builder;

  /// The instance that defines the behavior of the appbar that is
  /// including how it consumes scroll offsets and aligns appbar.
  final AppBarBehavior behavior;

  /// The enumeration that defines the type of the appbar alignment.
  final AppBarAlignment alignment;

  /// The enumeration that defines the type of the appbar alignment
  /// when bouncing overscroll.
  final AppBarAlignment bouncingAlignment;

  /// The value that defines initial normalized appbar offset.
  /// Therefore, this value must be defined from 0 to 1.
  final double initialOffset;

  @override
  State<AppBar> createState() => _AppBarState();
}

class SizedAppBar extends AppBar {
  SizedAppBar({
    super.key,
    super.initialOffset,
    required this.minExtent,
    required this.maxExtent,
    required super.behavior,
    required super.body,
  });

  SizedAppBar.builder({
    super.key,
    super.initialOffset,
    required this.minExtent,
    required this.maxExtent,
    required super.behavior,
    required super.builder,
  }) : super.builder();

  final double minExtent;
  final double maxExtent;
}

class _AppBarState extends State<AppBar>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AppBarPosition _position = AppBarPosition(
    vsync: this,
    behavior: widget.behavior,
    initialOffset: widget.initialOffset,
  );

  late final AppBarConnectionState? _connection;

  @override
  void initState() {
    super.initState();

    _connection = AppBarConnection.of(context);
    assert(_connection != null,
        "AppBarConnection widget does not exist at the ancestor.");

    // Attach the initial position to the appbar controller.
    _connection?.attach(_position);
  }

  @override
  void didUpdateWidget(covariant AppBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Updates a behavior of the position when an appbar-behavior changes.
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
    final bool isSizedAppBar = widget is SizedAppBar;

    return RepaintBoundary(
      child: ClipRRect(
        child: _AppBar(
          minExtent: isSizedAppBar ? (widget as SizedAppBar).minExtent : null,
          maxExtent: isSizedAppBar ? (widget as SizedAppBar).maxExtent : null,
          position: _position,
          alignment: widget.alignment,
          bouncingAlignment: widget.bouncingAlignment,
          child: widget.builder(context, _position),
        ),
      ),
    );
  }
}

class _AppBar extends SingleChildRenderObjectWidget {
  const _AppBar({
    required super.child,
    this.minExtent,
    this.maxExtent,
    required this.position,
    required this.alignment,
    required this.bouncingAlignment,
  });

  final double? minExtent;
  final double? maxExtent;
  final AppBarPosition position;
  final AppBarAlignment alignment;
  final AppBarAlignment bouncingAlignment;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAppBar(
      minExtent: minExtent,
      maxExtent: maxExtent,
      position: position,
      alignment: alignment,
      bouncingAlignment: bouncingAlignment,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderAppBar renderObject) {
    renderObject
      ..minExtent = minExtent
      ..maxExtent = maxExtent
      ..position = position
      ..alignment = alignment
      ..bouncingAlignment = bouncingAlignment;
  }
}

class RenderAppBar extends RenderBox
    with RenderObjectWithChildMixin<RenderBox> {
  RenderAppBar({
    required double? minExtent,
    required double? maxExtent,
    required AppBarPosition position,
    required AppBarAlignment alignment,
    required AppBarAlignment bouncingAlignment,
  }) {
    this.minExtent = minExtent;
    this.maxExtent = maxExtent;
    this.position = position;
    this.alignment = alignment;
    this.bouncingAlignment = bouncingAlignment;
  }

  @override
  RenderBox get child => super.child!;

  double get lentPixels => position.lentPixels.abs();

  AppBarPosition get position => _position!;
  AppBarPosition? _position;
  set position(AppBarPosition value) {
    if (_position != value) {
      _position?.removeListener(markNeedsLayout);
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

  AppBarAlignment get bouncingAlignment => _bouncingAlignment!;
  AppBarAlignment? _bouncingAlignment;
  set bouncingAlignment(AppBarAlignment value) {
    if (_bouncingAlignment != value) {
      _bouncingAlignment = value;
      markNeedsLayout();
    }
  }

  double? get minExtent => _minExtent;
  double? _minExtent;
  set minExtent(double? value) {
    if (_minExtent != value) {
      _minExtent = value;
      markNeedsLayout();
    }
  }

  double? get maxExtent => _maxExtent;
  double? _maxExtent;
  set maxExtent(double? value) {
    if (_maxExtent != value) {
      _maxExtent = value;
      markNeedsLayout();
    }
  }

  /// Whether the appbar should operate based on the given max extent(e.g. max height).
  bool get isSizedLayout => minExtent != null && maxExtent != null;

  @override
  BoxConstraints get constraints {
    if (isSizedLayout) {
      final double height = (maxExtent! - position.pixels) + lentPixels;
      return super
          .constraints
          .copyWith(maxHeight: height.clamp(0.0, double.infinity));
    }

    return super.constraints;
  }

  Offset translate(Offset offset) {
    Offset result;

    switch (alignment) {
      case AppBarAlignment.absolute:
        result = offset;
      case AppBarAlignment.center:
        result = Offset(offset.dx, offset.dy - position.pixels / 2);
      case AppBarAlignment.scroll:
        result = Offset(offset.dx, offset.dy - position.pixels);
    }

    switch (bouncingAlignment) {
      case AppBarAlignment.absolute:
        result = result.translate(0, 0);
      case AppBarAlignment.center:
        result = result.translate(0, lentPixels / 2);
      case AppBarAlignment.scroll:
        result = result.translate(0, lentPixels);
    }

    return result;
  }

  @override
  void performLayout() {
    // When the size needs to be calculated dynamically.
    if (!isSizedLayout) {
      child.layout(constraints, parentUsesSize: true);
      position.maxExtent = child.size.height;

      final double appBarPixels = child.size.height - position.pixels;
      final double appBarHeight = appBarPixels + lentPixels;

      size = Size(child.size.width, appBarHeight);
    } else {
      child.layout(constraints, parentUsesSize: true);
      position.maxExtent = maxExtent! - minExtent!;

      final double appBarPixels = maxExtent! - position.pixels;
      final double appBarHeight = appBarPixels + lentPixels;

      size = Size(child.size.width, appBarHeight);
    }
  }

  /// No need to implement hit-test in this [RenderBox].
  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return child.hitTest(result, position: position);
  }

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final Offset translatedOffset =
        isSizedLayout ? Offset.zero : translate(Offset.zero);

    // Adjusts the position to compensate for the offset modification.
    return result.addWithPaintOffset(
      offset: translatedOffset,
      position: position,
      hitTest: (result, position) {
        return super.hitTest(result, position: position);
      },
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child, isSizedLayout ? offset : translate(offset));
  }
}
