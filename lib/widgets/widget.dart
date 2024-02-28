import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/controller.dart';
import 'package:flutter_appbar/components/position.dart';
import 'package:flutter_appbar/components/scroll_controller.dart';
import 'package:flutter_appbar/widgets/appbar.dart';
import 'package:flutter_appbar/widgets/nested_scroll_connection.dart';
import 'package:flutter_appbar/widgets/scrollable_gesture_delegator.dart';

/// Synchronize appbars with [Scrollable] to configure dynamic appbar behavior
/// by nested scroll.
/// 
/// And, implementable with single [Scrollable].
/// 
/// How to use this widget?
/// ```dart
/// AppBarConnection(
///   appBars: [ ...AppBar ],
///   child: ...
/// );
/// ```
class AppBarConnection extends StatefulWidget {
  const AppBarConnection({
    super.key,
    required this.appBars,
    required this.child,
    this.propagation = AppbarPropagation.next,
    this.controller,
    this.scrollController,
  });

  final List<AppBar> appBars;
  final Widget child;

  final AppbarPropagation propagation;

  final AppBarController? controller;

  /// This controller is define scroll controller of [PrimaryScrollController].
  final NestedScrollController? scrollController;

  /// Finds the ancestor [AppBarConnectionState] from the closest instance of this class
  /// that encloses the given context.
  /// 
  /// Used by [AppBar].
  static AppBarConnectionState? of(BuildContext context) {
    return context.findAncestorStateOfType<AppBarConnectionState>();
  }

  @override
  State<AppBarConnection> createState() => AppBarConnectionState();
}

class AppBarConnectionState extends State<AppBarConnection> {
  late final AppBarController _controller = widget.controller ?? AppBarController();
  late final NestedScrollController _scrollController = widget.scrollController ?? NestedScrollController();

  void attach(AppBarPosition position) => _controller.attach(position);
  void detach(AppBarPosition position) => _controller.detach(position);

  double _handleNestedScroll(double available, ScrollPosition position) {
    return _controller.consumeAll(
      available,
      position,
      widget.propagation,
    ); // the total consumed.
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollConnection(
      preScroll: _handleNestedScroll,
      postScroll: _handleNestedScroll,
      child: Column(
        children: [
          // Wrap the widget that acts as a scroll gesture delegator to enable scrolling
          // by dragging the appbar.
          ScrollableGestureDelegator(
            controller: _scrollController,
            child: Column(children: widget.appBars)
          ),

          // with scrollable.
          Expanded(
            child: PrimaryScrollController(
              controller: _scrollController,
              child: widget.child
            ),
          ),
        ],
      ),
    );
  }
}

/*
class _AppBarLayout extends MultiChildRenderObjectWidget {
  _AppBarLayout({
    required super.children,
  }) {
    if (super.children.length != 2) {
      throw FlutterError("The children should be given only the appbar and the scrollable (2 in total)");
    }
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderAppBarLayout();
  }
}

class RenderAppBarLayout extends RenderBox
    with ContainerRenderObjectMixin<RenderBox, AppBarLayoutParentData>,
         RenderBoxContainerDefaultsMixin<RenderBox, AppBarLayoutParentData> {

  List<RenderBox> get children => getChildrenAsList();

  RenderBox get appBar => children[0];
  RenderBox get scrollable => children[1];

  @override
  void performLayout() {
    // Possibly, the appbar height can be greater than the parent height.
    appBar.layout(constraints.copyWith(maxHeight: double.infinity), parentUsesSize: true);

    scrollable.layout(constraints.copyWith(
      maxHeight: max(constraints.maxHeight - appBar.size.height, 0.0),
    ), parentUsesSize: true);

    // This widget size is equal to the the parent widget size.
    size = constraints.biggest;
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, { required Offset position }) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! AppBarLayoutParentData) {
      child.parentData = AppBarLayoutParentData();
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(appBar, offset);
    context.paintChild(scrollable, Offset(offset.dx, offset.dy + appBar.size.height));
  }
}

class AppBarLayoutParentData extends ContainerBoxParentData<RenderBox> { }
*/