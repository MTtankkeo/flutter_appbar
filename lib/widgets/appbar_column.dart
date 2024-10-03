import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/appbar_controller.dart';

class AppBarColumn extends StatefulWidget {
  const AppBarColumn({
    super.key,
    required this.controller,
    required this.children,
  });

  final AppBarController controller;
  final List<Widget> children;

  @override
  State<AppBarColumn> createState() => _AppBarColumnState();
}

class _AppBarColumnState extends State<AppBarColumn> {
  void didUpdateAppBar() {
    setState(() {
      // Generally, when the padding of the AppBar changed.
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(didUpdateAppBar);
  }

  @override
  void dispose() {
    super.dispose();
    widget.controller.removeListener(didUpdateAppBar);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.controller.padding,
      child: Column(children: widget.children),
    );
  }
}