## 1.0.0-dev1
- 😀 Initial publishing.

## 1.0.0-dev2
- Proceed with documentation of README.md and its overall source-code by adding comments.
- Renamed from `AppBarAlign` to `AppBarAlignmentCommand` and from `AppBarAlignBehavior` to `AppBarAlignmentBehavior`.
- Fixed an issue by implementing code that delegates all appbar states and operations from the existing appbar controller to the new app bar controller.

## 1.0.0-dev3
- Fixed an issue by preventing scroll offset from being pre-consumed during forward overscrolling, resolving various issues related to the bouncing scroll physics.

## 1.0.0-dev4
- Fixed an issue where the appbar did not expand properly.
- Added the SizedAppBar widget to allow defining a fixed size.

## 1.0.0-beta1
- Fixed an issue where the scroll activity instance was replaced even when it was not necessary due to changes in the Scrollable's size.

## 1.0.1
- Fixed an issue where the scroll activity does not change to Idle even when the velocity is 0.