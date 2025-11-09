# Introduction
This package implements the flexible appbar behavior, and we pursue higher performance and responsiveness than the appbar generally provided by Flutter. In addition, this package avoids unnecessary gesture contention, ensuring responsiveness in most typical situations.

## Related Packages
| Name | Introduction |
| ---- | ------------ |
| [flutter_refresh_indicator](https://pub.dev/packages/flutter_refresh_indicator) | A flexible, native-like refresh indicator built on flutter_appbar. |
| [flutter_infinite_scroll_pagination ](https://pub.dev/packages/flutter_infinite_scroll_pagination) | Easy infinite scroll loading with one-line wrapping, no setup needed. |
| [flutter_scroll_bottom_sheet](https://pub.dev/packages/flutter_scroll_bottom_sheet) | A bottom sheet widget that syncs smoothly with scroll events for a seamless UX. |

## Preview
The GIF below demonstrates the package in action. Please note that due to compression, the animation may appear distorted or choppy.

![preview](https://github.com/user-attachments/assets/9b077c66-83c3-4374-b217-f37dbe644d01)
![preview](https://github.com/user-attachments/assets/e8b18258-f764-49e6-8068-4c34b9b6d62b)

## Usage
This section covers the basic usage of this package and how to integrate it into your application.

### How to apply the appbar?
To integrate an appbar into your application, use the `AppBarConnection` and AppBar widgets as shown in the example below.

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
    ),
  ],
  child: ListView.builder(
    itemCount: 100,
    itemBuilder: (context, index) {
      return Text("Hello, World! $index");
    },
  ),
)
```

### How to apply the sized appbar?
You can explicitly define both the minimum and maximum extents for the appbar, allowing you to set fixed sizes rather than having it adjust dynamically, See Also, The SizedAppBar does not provide an alignment option.

```dart
AppBar(
  minExtent: 0,   // Optional
  maxExtent: 200, // Optional
  behavior: MaterialAppBarBehavior(),
  body: ...
)
```

### How to apply effects according to appbar position?
To adjust UI effects dynamically according to the appbar’s position, use the AppBar.builder method. This provides the position object, which contains the current state of the appbar, including its expansion and shrinkage percentages.

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

### How to refer the other appbar position.
To obtain the `AppBarPosition` for a specific index, the `positionOf()` function of an explicitly defined `AppBarController` can be used.

```dart
@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) => controller.synchronizeWith(0, 1));
}

AppBarConnection(
  controller: controller,
  appBars: [
    AppBar.builder(...), // target to refer
    AppBar.builder(
      behavior: ...,
      builder: (context, ) {
        final position = controller.positionOf(0); // ScrollPosition
        position?.expandedPercent; // 1.0 or null
        position?.shrinkedPercent; // 0.0 or null
        return ...;
      }
    )
  ],
  child: ...
)
```

### How to customize appbar alignment?
Try applying the `Alignment` that is a providing standard enumeration in this package.

```dart
AppBar(
  behavior: MaterialAppBarBehavior(),
  alignment: Alignment.center, // like this
  body: ...
)
```

### How to apply initial offset of the appbar?
`initialOffset` defines the initial expansion or collapse state of the appbar and must be a value between 0 and 1.

```dart
AppBar(
  initialOffset: 1, // 0 ~ 1
  body: ...
)
```

### How to set fixed scrollable height?
When `fixedScrollableHeight` is enabled, the scrollable widget's height is calculated as if the AppBar is fully collapsed, regardless of its current expansion state.

This prevents the scrollable view from resizing dynamically as the AppBar expands or collapses, which can help avoid layout shifts, visual glitches, and performance overhead caused by frequent height changes.

#### Locally

```dart
AppBarConnection(
  fixedScrollableHeight: true,
  appBars: [...],
  child: ...
)
```

#### Globaly

```dart
AppBarConnection.defaultFixedScrollableHeight = true;
```

## AppBar Behavior
The package includes different appbar behaviors that define how the appbar interacts with user scroll actions.

> This provides developers with full control over how the appbar should behave under different scrolling conditions.

### AppBarBehavior abstract class
This is an abstract class that dictates the overall behavior of the appbar. It provides two key methods:

```dart
/// Updates the given appbar based on available scroll offset,
/// the current appbar position, and the nested scroll position.
double setPixels(
  double available,
  AppBarPosition appBar,
  NestedScrollPosition scroll,
);
```

```dart
/// Updates the appbar during bouncing (overscroll) situations
/// Returns any remaining scroll offset that was not consumed.
double setBouncing(
  double available,
  AppBarPosition appBar,
  NestedScrollPosition scroll,
);
```

```dart
/// Determines the alignment of the appbar based on appbar position and scroll.
AppBarAlignmentCommand? align(
  AppBarPosition appBar,
  NestedScrollPosition scroll,
);
```

### AbsoluteAppBarBehavior
This behavior keeps the appbar in a fixed position, ignoring scroll interactions.

| Property | Description |
|----------|-------------|
| `bouncing` | Whether the appbar will be synchronized when bouncing overscroll occurs. |

### MaterialAppBarBehavior
This behavior mimics the Material 3 design behavior for appbars, supporting floating, dragging, and alignment animations.

| Property | Description |
|----------|-------------|
| `floating` | Allows the appbar to expand and collapse without requiring the user to scroll to the top. |
| `bouncing` | Whether the appbar will be synchronized when bouncing overscroll occurs. |
| `dragOnlyExpanding` | Prevents the appbar from expanding automatically when scrolling up. It can only be expanded by dragging. (Cannot be used with `floating`.) |
| `alwaysScrolling` | Ensures the appbar can be scrolled even when the content is not scrollable. Useful for keeping the appbar responsive. |
| `alignAnimation` | Enables smooth animation when the appbar switches between expanded and collapsed states. |
| `alignDuration` | Defines the duration of the alignment animation. Default is `300ms`. |
| `alignCurve` | Sets the animation curve for the alignment transition, controlling the easing effect. |
