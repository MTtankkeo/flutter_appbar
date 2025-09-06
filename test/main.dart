import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/flutter_appbar.dart';

/// The physical size used for testing layouts and scroll behavior.
const Size kPhysicalSize = Size(100, 200);

/// Custom scroll physics for tests that always allow drag gestures
/// to start immediately, while inheriting bouncing behavior.
class TestBouncingScrollPhysics extends ScrollPhysics {
  const TestBouncingScrollPhysics()
      : super(parent: const BouncingScrollPhysics());

  /// Removes the default drag threshold so that drags are
  /// recognized without requiring a minimum motion distance.
  @override
  double? get dragStartDistanceMotionThreshold => null;
}

/// Creates a template widget with a list of AppBars and a scrollable ListView.
Widget createTemplate(
  List<AppBar> appbars,
  AppBarController appBarController,
  NestedScrollController scrollController,
) {
  final bool isIOS = defaultTargetPlatform == TargetPlatform.iOS;
  final bool isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
  final bool isCupertino = isIOS || isMacOS;

  return Builder(
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            physics: isCupertino
                ? const TestBouncingScrollPhysics()
                : const ClampingScrollPhysics(),
          ),
          child: AppBarConnection(
            controller: appBarController,
            appBars: appbars,
            child: ListView(
              controller: scrollController,
              children: [SizedBox(height: kPhysicalSize.height * 3)],
            ),
          ),
        ),
      );
    },
  );
}
