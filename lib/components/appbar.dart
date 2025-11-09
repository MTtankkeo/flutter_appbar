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

/// The widget configures dynamic appbar behavior that interacts
/// with [Scrollable] widget.
///
/// Used with [AppBarConnection].
class AppBar extends StatefulWidget {
  AppBar({
    super.key,
    required this.behavior,
    required Widget body,
    this.alignment = Alignment.bottomCenter,
    this.bouncingAlignment = Alignment.bottomCenter,
    this.initialOffset = 0,
    this.minExtent = 0,
    this.maxExtent,
  }) : builder = ((_, position) => body);

  AppBar.builder({
    super.key,
    required this.behavior,
    required AppBarBuilder builder,
    this.alignment = Alignment.bottomCenter,
    this.bouncingAlignment = Alignment.bottomCenter,
    this.initialOffset = 0,
    this.minExtent = 0,
    this.maxExtent,
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

  /// Alignment of the appbar relative to its container.
  final Alignment alignment;

  /// Alignment of the appbar applied during overscroll
  /// when bouncing.
  final Alignment bouncingAlignment;

  /// The value that defines initial normalized appbar offset.
  /// Therefore, this value must be defined from 0 to 1.
  final double initialOffset;

  /// The minimum height the AppBar can shrink to.
  final double minExtent;

  /// The maximum height the AppBar can expand to.
  final double? maxExtent;

  @override
  State<AppBar> createState() => _AppBarState();
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
    assert(
      _connection != null,
      "AppBarConnection widget does not exist at the ancestor.",
    );

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
    return RepaintBoundary(
      child: ClipRRect(
        child: _AppBar(
          minExtent: widget.minExtent,
          maxExtent: widget.maxExtent,
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
    this.minExtent = 0,
    this.maxExtent,
    required this.position,
    required this.alignment,
    required this.bouncingAlignment,
  });

  final double minExtent;
  final double? maxExtent;
  final AppBarPosition position;
  final Alignment alignment;
  final Alignment bouncingAlignment;

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
    required Alignment alignment,
    required Alignment bouncingAlignment,
  }) {
    this.minExtent = minExtent ?? 0;
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

  Alignment get alignment => _alignment!;
  Alignment? _alignment;
  set alignment(Alignment value) {
    if (_alignment != value) {
      _alignment = value;
      markNeedsLayout();
    }
  }

  Alignment get bouncingAlignment => _bouncingAlignment!;
  Alignment? _bouncingAlignment;
  set bouncingAlignment(Alignment value) {
    if (_bouncingAlignment != value) {
      _bouncingAlignment = value;
      markNeedsLayout();
    }
  }

  double get minExtent => _minExtent;
  double _minExtent = 0;
  set minExtent(double value) {
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
  bool get isSizedLayout => maxExtent != null;

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

  /// Translates the given offset based on scroll and bounce positions.
  /// Uses Alignment values to determine the proportion of movement applied.
  Offset translate(Offset offset) {
    if (isSizedLayout) return Offset.zero;

    // Convert Alignment.y (-1.0 to 1.0) to a 0.0 to 1.0 factor.
    final double scrollFactor = (alignment.y + 1) / 2;
    final double bounceFactor = (bouncingAlignment.y + 1) / 2;

    // Apply scroll offset based on alignment factor.
    double y = offset.dy - position.pixels * scrollFactor;

    // Apply bounce offset based on bouncing alignment factor.
    y += position.lentPixels * -bounceFactor;

    return Offset(offset.dx, y);
  }

  @override
  void performLayout() {
    child.layout(constraints, parentUsesSize: true);

    // Determine effective min and max extents.
    final eMinExtent = minExtent;
    final eMaxExtent = maxExtent ?? child.size.height;

    // Set the scrollable range for the AppBar position.
    position.maxExtent = eMaxExtent - eMinExtent;

    // Calculate the current AppBar height based
    // on scroll position and any lent pixels.
    final double appBarPixels = eMaxExtent - position.pixels;
    final double appBarHeight = appBarPixels + lentPixels;

    size = Size(child.size.width, appBarHeight);
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
