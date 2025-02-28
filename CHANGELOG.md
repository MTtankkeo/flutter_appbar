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
- Fixed an issue where the appbar did not properly consume the overscroll when the overscroll direction immediately switched to forward or backward, or vice versa, causing abnormal behavior.

## 1.1.3
- Fixed an issue related to bouncing overscroll about appbar pixels safety.

## 1.1.4
- Fixed an issue [#2](https://github.com/MTtankkeo/flutter_appbar/issues/2) where the alignment animation did not run when wrapped with `TabBarView`.

## 1.1.5 ~ 1.1.6
- Fixed an issue [#3](https://github.com/MTtankkeo/flutter_appbar/issues/3).

## 1.1.7
- Fixed an issue where hit testing did not work correctly when the app bar was scrolled status.
- Added additional comments for documentation.

## 1.2.0
- Updated by removing the existing legacy appbar alignment-related code and adding functions such as `notifyScrollEnd`, `performAlignment`, `expand`, and `shrink` to allow more flexible external control over alignment.
- Updated `AbsoluteAppBarBehavior`, which previously did not support alignment, to allow external control over appbar alignment animations.

## 1.2.1
- Fixed an issue where the appbar would expand again when its height increased in the fully shrinked state by normalizing its offset to a range of 0 to 1 instead of using the pixels unit.
- Added the `initialOffset` property to `AppBar` and `SizedAppBar`, which defines the initial expansion or collapse state of the app bar and must be a value between 0 and 1.

## 1.2.2
- Fixed an issue where Flutter default stretch overscroll effect behaved unnaturally when scrolling was not possible with `ClampingScrollPhysics`.

## 1.2.3
- Fixed an issue where the appbar could reference outdated `maxScrollExtent` values because the `Scrollable` widget layout intrinsic size changes were updated only after all size calculations were completed.

## 1.3.0
- Added `EffectUtil` class for the appbar effect calculation.
- Added `AppBarFadeEffect.onShrink` widget that apply fade-out effect by a given appbar position.
- Added `AppBarFadeEffect.onExpand` widget that apply fade-out effect by a given appbar position.

## 1.3.1
- Fixed an issue where multiple instances of `ScrollController` were created when `NestedScrollConnection` was nested two or more times in the widget tree.
- Fixed an issue where the `alwaysScrolling` option related logic in `MaterialAppBarBehavior` did not correctly determine the scrollability of the appbar.

## 1.3.2
- Fixed an issue where an exception occurred in `ScrollController` when the widget tree structure changed(e.g. detach and then attach).

## 1.4.0
- Added `NestedScrollConnectionPropagation` enumeration for NestedScrollConnection widget.
- Added `propagation` property that is NestedScrollConnectionPropagation type in NestedScrollConnection widget.
- Added `nestedPropagation` property that is NestedScrollConnectionPropagation type in AppBarConnection widget.
- Remove `NestedScrollFlingListener` typedef.
- Changed the fling listener to a consuming.