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

## 1.0.2
- Fixed the junk issue related to clipping during overscrolling.
- Added basic logic for bouncing overscroll consumption (still in development).

## 1.1.0
- Added `DrivenAppBarBehavior`, which handles the bouncing synchronization of the app bar. (`AbsoluteAppBarBehavior` and `MaterialAppBarBehavior` now inherit from the `DrivenAppBarBehavior` class.)
- Added `bouncing` property in `AbsoluteAppBarBehavior`.
- Added `bouncing` property in `MaterialAppBarBehavior`.
- Added related logic in `AppBarConnection` to enable synchronization with bouncing.
- Added the bouncingAlignment property to the AppBar, allowing the layout alignment of the app bar to be defined when synchronized with bouncing.

## 1.1.1
- Fixed an issue where the dragOnlyExpanding option in `MaterialAppBarBehavior` was not working correctly.
- Fixed an issue where the app bar was not scrolling correctly in Bouncing even when scrolling was not possible.

## 1.1.2
- Added `synchronizeWith` function to synchronize appbar updates between specified indices, ensuring that when the appbar at the first index is updated, the appbar at the second index is also updated accordingly.