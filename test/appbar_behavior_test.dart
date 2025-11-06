import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter_appbar/flutter_appbar.dart';
import 'package:flutter_test/flutter_test.dart';

import 'main.dart';

void main() {
  testWidgets(
    "AbsoluteAppBarBehavior ensures the AppBar remains fixed during scrolling",
    (tester) async {
      tester.view.physicalSize = kPhysicalSize;
      tester.view.devicePixelRatio = 1.0;

      final AppBarController appBarController = AppBarController();
      final NestedScrollController scrollController = NestedScrollController();

      await tester.pumpWidget(
        createTemplate(
          [
            AppBar(
              behavior: const AbsoluteAppBarBehavior(),
              body: Container(height: 100, color: Colors.red),
            ),
          ],
          appBarController,
          scrollController,
        ),
      );

      {
        final Offset topLeft = tester.getTopLeft(find.byType(AppBar));
        final Offset bottomLeft = tester.getBottomLeft(find.byType(AppBar));

        expect(topLeft.dy, 0.0);
        expect(bottomLeft.dy, 100.0);
        expect(scrollController.offset, 0.0);
      }

      await tester.drag(find.byType(ListView), const Offset(0, -100));
      await tester.pump();

      {
        final Offset topLeft = tester.getTopLeft(find.byType(AppBar));
        final Offset bottomLeft = tester.getBottomLeft(find.byType(AppBar));

        expect(topLeft.dy, 0.0);
        expect(bottomLeft.dy, 100.0);
        expect(scrollController.offset, 100.0);
      }
    },
    variant: TargetPlatformVariant.mobile(),
  );

  testWidgets(
    "MaterialAppBarBehavior ensures the floating:true",
    (tester) async {
      tester.view.physicalSize = kPhysicalSize;
      tester.view.devicePixelRatio = 1.0;

      final AppBarController appBarController = AppBarController();
      final NestedScrollController scrollController = NestedScrollController();

      await tester.pumpWidget(createTemplate(
        [
          AppBar(
            behavior: const MaterialAppBarBehavior(floating: true),
            body: Container(height: 100, color: Colors.red),
          ),
        ],
        appBarController,
        scrollController,
      ));

      {
        final Offset topLeft = tester.getTopLeft(find.byType(AppBar));
        final Offset bottomLeft = tester.getBottomLeft(find.byType(AppBar));

        expect(topLeft.dy, 0.0);
        expect(bottomLeft.dy, 100.0);
        expect(scrollController.offset, 0.0);
      }

      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();

      {
        final Offset topLeft = tester.getTopLeft(find.byType(AppBar));
        final Offset bottomLeft = tester.getBottomLeft(find.byType(AppBar));

        expect(topLeft.dy, 0.0);
        expect(bottomLeft.dy, 0.0);
        expect(scrollController.offset, 100.0);
      }

      await tester.drag(find.byType(ListView), const Offset(0, 100));
      await tester.pump();

      {
        final Offset topLeft = tester.getTopLeft(find.byType(AppBar));
        final Offset bottomLeft = tester.getBottomLeft(find.byType(AppBar));

        expect(topLeft.dy, 0.0);
        expect(bottomLeft.dy, 100.0);
        expect(scrollController.offset, 100.0);
      }
    },
    variant: TargetPlatformVariant.mobile(),
  );

  testWidgets(
    "MaterialAppBarBehavior ensures the floating:false",
    (tester) async {
      tester.view.physicalSize = kPhysicalSize;
      tester.view.devicePixelRatio = 1.0;

      final AppBarController appBarController = AppBarController();
      final NestedScrollController scrollController = NestedScrollController();

      await tester.pumpWidget(createTemplate(
        [
          AppBar(
            behavior: const MaterialAppBarBehavior(floating: false),
            body: Container(height: 100, color: Colors.red),
          ),
        ],
        appBarController,
        scrollController,
      ));

      {
        final Offset topLeft = tester.getTopLeft(find.byType(AppBar));
        final Offset bottomLeft = tester.getBottomLeft(find.byType(AppBar));

        expect(topLeft.dy, 0.0);
        expect(bottomLeft.dy, 100.0);
        expect(scrollController.offset, 0.0);
      }

      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();

      {
        final Offset topLeft = tester.getTopLeft(find.byType(AppBar));
        final Offset bottomLeft = tester.getBottomLeft(find.byType(AppBar));

        expect(topLeft.dy, 0.0);
        expect(bottomLeft.dy, 0.0);
        expect(scrollController.offset, 100.0);
      }

      await tester.drag(find.byType(ListView), const Offset(0, 100));
      await tester.pump();

      {
        final Offset topLeft = tester.getTopLeft(find.byType(AppBar));
        final Offset bottomLeft = tester.getBottomLeft(find.byType(AppBar));

        expect(topLeft.dy, 0.0);
        expect(bottomLeft.dy, 0.0);
        expect(scrollController.offset, 0.0);
      }
    },
    variant: TargetPlatformVariant.mobile(),
  );

  testWidgets(
    "MaterialAppBarBehavior ensures the dragOnlyExpanding:true",
    (tester) async {
      tester.view.physicalSize = kPhysicalSize;
      tester.view.devicePixelRatio = 1.0;

      final AppBarController appBarController = AppBarController();
      final NestedScrollController scrollController = NestedScrollController();

      await tester.pumpWidget(createTemplate(
        [
          AppBar(
            behavior: const MaterialAppBarBehavior(dragOnlyExpanding: true),
            body: Container(height: 100, color: Colors.red),
          ),
        ],
        appBarController,
        scrollController,
      ));

      {
        final Offset topLeft = tester.getTopLeft(find.byType(AppBar));
        final Offset bottomLeft = tester.getBottomLeft(find.byType(AppBar));

        expect(topLeft.dy, 0.0);
        expect(bottomLeft.dy, 100.0);
        expect(scrollController.offset, 0.0);
      }

      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();

      {
        final Offset topLeft = tester.getTopLeft(find.byType(AppBar));
        final Offset bottomLeft = tester.getBottomLeft(find.byType(AppBar));

        expect(topLeft.dy, 0.0);
        expect(bottomLeft.dy, 0.0);
        expect(scrollController.offset, 100.0);
      }

      await tester.fling(find.byType(ListView), const Offset(0, 50), 1000);
      await tester.pumpAndSettle();

      // The appbar should not expand when scrolling is not caused by dragging.
      // (i.e., when in the BallisticScrollActivity state).
      {
        final Offset topLeft = tester.getTopLeft(find.byType(AppBar));
        final Offset bottomLeft = tester.getBottomLeft(find.byType(AppBar));

        expect(topLeft.dy, 0.0);
        expect(bottomLeft.dy, 0.0);
        expect(scrollController.offset, 0.0);
      }

      await tester.drag(find.byType(ListView), const Offset(0, 100));
      await tester.pump();

      {
        final Offset topLeft = tester.getTopLeft(find.byType(AppBar));
        final Offset bottomLeft = tester.getBottomLeft(find.byType(AppBar));

        expect(topLeft.dy, 0.0);
        expect(bottomLeft.dy, 100.0);
        expect(scrollController.offset, 0.0);
      }
    },
    variant: TargetPlatformVariant.mobile(),
  );

  testWidgets(
    "MaterialAppBarBehavior ensures the alwaysScrolling:true",
    (tester) async {
      tester.view.physicalSize = kPhysicalSize;
      tester.view.devicePixelRatio = 1.0;

      final AppBarController appBarController = AppBarController();
      final NestedScrollController scrollController = NestedScrollController();

      await tester.pumpWidget(createTemplate(
        [
          AppBar(
            behavior: const MaterialAppBarBehavior(alwaysScrolling: true),
            body: Container(height: 100, color: Colors.red),
          ),
        ],
        appBarController,
        scrollController,
        scrollExtent: 0.0,
      ));

      {
        final Offset topLeft = tester.getTopLeft(find.byType(AppBar));
        final Offset bottomLeft = tester.getBottomLeft(find.byType(AppBar));

        expect(topLeft.dy, 0.0);
        expect(bottomLeft.dy, 100.0);
        expect(scrollController.offset, 0.0);
      }

      appBarController.consumeScroll(
        -100,
        scrollController.position,
        AppbarPropagation.next,
      );

      await tester.pump();

      {
        final Offset topLeft = tester.getTopLeft(find.byType(AppBar));
        final Offset bottomLeft = tester.getBottomLeft(find.byType(AppBar));

        expect(topLeft.dy, 0.0);
        expect(bottomLeft.dy, 0.0);
        expect(scrollController.offset, 0.0);
      }
    },
    variant: TargetPlatformVariant.mobile(),
  );
}
