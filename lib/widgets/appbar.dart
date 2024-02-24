import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/behavior.dart';
import 'package:flutter_appbar/components/position.dart';

typedef AppBarBuilder = Widget Function(BuildContext context, AppBarPosition position);

class AppBar extends StatefulWidget {
  AppBar({
    super.key,
    required Widget body,
    required this.behavior,
  }) : builder = ((context, position) => body);
  
  const AppBar.builder({
    super.key, 
    required this.builder,
    required this.behavior,
  });

  final AppBarBuilder builder;
  final AppBarBehavior behavior;

  @override
  State<AppBar> createState() => _AppBarState();
}

class _AppBarState extends State<AppBar> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(context, AppBarPosition());
  }
}