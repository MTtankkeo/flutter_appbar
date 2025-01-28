<div align="center">
  <img width="" src="https://github.com/user-attachments/assets/535a7285-56f8-4f3f-8356-c9f54aed4d36">
  <h1>Flutter Appbar</h1>
  <table>
        <thead>
          <tr>
            <th>Version</th>
            <th>v1.0.0-dev1</th>
          </tr>
        </tbody>
    </table>
</div>

# Introduction
This package implements the flexible appbar behavior, And we pursue higher performance and responsiveness than the appbar generally provided by Flutter.

## Preview
The gif image below may appear distorted and choppy due to compression.

![preview](https://github.com/user-attachments/assets/9b077c66-83c3-4374-b217-f37dbe644d01)

## Usage
The following explains the basic usage of this package.

### How to apply the appbar?
To simply apply an app bar to your application, you can use the `AppBarConnection` and the `AppBar` widgets like this.

```dart
AppBarConnection(
  appBars: [
    AppBar(
      behavior: MaterialAppBarBehavior(),
      body: Container(
        width: 1e10,
        height: 300,
        color: Colors.red,
        alignment: Alignment.center,
        child: Text("Header", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      ),
    )
  ],
  child: ListView.builder(
    physics: BouncingScrollPhysics(),
    itemCount: 100,
    itemBuilder: (context, index) {
      return Text("Hello, World! $index");
    },
  ),
)
```
