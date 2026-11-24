import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/flutter_appbar.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetsApp(
      debugShowCheckedModeBanner: false,
      color: const Color(0xFFFFFFFF),
      home: DefaultTextStyle(
        style: const TextStyle(
          fontSize: 14,
          fontWeight: .w400,
          letterSpacing: 0.25,
          height: 1.43,
          decoration: .none,
        ),
        child: SafeArea(
          child: Example(),
        ),
      ),
    );
  }
}

/// Example widget demonstrating multiple AppBars with nested scrolling.
class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBarConnection(
      // Connect multiple AppBars with a scrollable child.
      appBars: [
        AppBar(
          behavior: const MaterialAppBarBehavior(dragOnlyExpanding: true),
          alignment: .center,
          body: const HeaderAppBar(),
        ),
        AppBar(
          behavior: const MaterialAppBarBehavior(floating: true),
          body: const FloatingAppBar(),
        ),
      ],
      child: ListView.builder(
        itemCount: 100,
        itemBuilder: (context, index) {
          return Text("Hello, World! $index");
        },
      ),
    );
  }
}

class HeaderAppBar extends StatelessWidget {
  const HeaderAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: .infinity,
      height: 300,
      color: const Color(0xFFFF0000),
      alignment: .center,
      child: const Column(
        mainAxisAlignment: .center,
        children: [
          Text(
            "Header",
            style: TextStyle(fontSize: 32, fontWeight: .bold),
          ),
          Text(
            "dragOnlyExpanding: true",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class FloatingAppBar extends StatelessWidget {
  const FloatingAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: .infinity,
      padding: const .all(15),
      color: const Color(0xFF0064FF),
      alignment: .center,
      child: const Column(
        children: [
          Text(
            "AppBar",
            style: TextStyle(fontSize: 20, fontWeight: .bold),
          ),
          Text(
            "floating: true",
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
