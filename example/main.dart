import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_appbar/flutter_appbar.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: AppBarConnection(
            appBars: [
              AppBar(
                behavior: const MaterialAppBarBehavior(dragOnlyExpanding: true),
                alignment: AppBarAlignment.center,
                body: Container(
                  width: double.infinity,
                  height: 300,
                  color: Colors.red,
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Header",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "dragOnlyExpanding: true",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              AppBar(
                behavior: const MaterialAppBarBehavior(floating: true),
                body: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  color: Colors.blue,
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      Text(
                        "AppBar",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text("floating: true", style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
            child: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) {
                return Text(
                  "Hello, World! $index",
                  style: const TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
