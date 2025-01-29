# Introduction
This package implements the flexible app bar behavior, and we pursue higher performance and responsiveness than the app bar generally provided by Flutter. In addition, this package avoids unnecessary gesture contention, ensuring responsiveness in most typical situations.

## Preview
The GIF below demonstrates the package in action. Please note that due to compression, the animation may appear distorted or choppy.

![preview](https://github.com/user-attachments/assets/9b077c66-83c3-4374-b217-f37dbe644d01)

## Usage
This section covers the basic usage of this package and how to integrate it into your application.

### How to apply the appbar?
To integrate an app bar into your application, use the `AppBarConnection` and AppBar widgets as shown in the example below:

> [!NOTE]
> If you define a separate `ScrollController` for a scrollable widget, you must explicitly pass that instance to the scrollController property of `AppBarConnection` to ensure proper synchronization.

```dart
AppBarConnection(
  appBars: [
    AppBar(
      behavior: MaterialAppBarBehavior(),
      body: Container(
        width: double.infinity,
        height: 300,
        color: Colors.red,
        alignment: Alignment.center,
        child: Text("Header", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      ),
    )
  ],
  child: ListView.builder(
    itemCount: 100,
    itemBuilder: (context, index) {
      return Text("Hello, World! $index");
    },
  ),
)
```

### How to apply effects according to appbar position?
To adjust UI effects dynamically according to the app bar’s position, use the AppBar.builder method. This provides the position object, which contains the current state of the app bar, including its expansion and shrinkage percentages.

```dart
AppBar.builder(
  behavior: MaterialAppBarBehavior(),
  builder: (context, position) {
    position.expandedPercent; // 1.0
    position.shrinkedPercent; // 0.0
    return ...;
  }
)
```

### How to customize appbar alignment?
Try applying the `AppBarAlignment` that is a providing standard enumeration in this package.

```kotlin
AppBar(
  behavior: MaterialAppBarBehavior(),
  alignment: AppBarAlignment.center, // like this
  body: ...
)
```

## The Properties of AppBarAlignment
The `AppBarAlignment` enum provides multiple alignment options for positioning the app bar relative to the scroll behavior and layout size.

| Properie | Description
| ------ | ------ |
| Scroll | Display the same as the scroll item. (is Default Value)
| Center | Based on the size of the appbar, the center is located at the center of the size of the appbar.
| Absolute | Even if the appbar is reduced and expanded, the absolute position of the appbar does not change.

## AppBar Behavior
The package includes different app bar behaviors that define how the app bar interacts with user scroll actions.

> This provides developers with full control over how the app bar should behave under different scrolling conditions.

### AppBarBehavior abstract class
This is an abstract class that dictates the overall behavior of the app bar. It provides two key methods:

- setPixels(double available, AppBarPosition appBar, ScrollPosition scroll): Updates the app bar based on the available scroll offset and returns the remaining value after consumption.

- align(AppBarPosition appBar, ScrollPosition scroll): Determines the app bar’s alignment based on its position and the current scroll state.

### AbsoluteAppBarBehavior
This behavior keeps the app bar in a fixed position, ignoring scroll interactions.

### MaterialAppBarBehavior
This behavior mimics the Material 3 design behavior for app bars, supporting floating, dragging, and alignment animations.

| Property | Description |
|----------|-------------|
| `floating` | Allows the app bar to expand and collapse without requiring the user to scroll to the top. |
| `dragOnlyExpanding` | Prevents the app bar from expanding automatically when scrolling up. It can only be expanded by dragging. (Cannot be used with `floating`.) |
| `alwaysScrolling` | Ensures the app bar can be scrolled even when the content is not scrollable. Useful for keeping the app bar responsive. |
| `alignAnimation` | Enables smooth animation when the app bar switches between expanded and collapsed states. |
| `alignDuration` | Defines the duration of the alignment animation. Default is `300ms`. |
| `alignCurve` | Sets the animation curve for the alignment transition, controlling the easing effect. |

