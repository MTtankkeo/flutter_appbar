import 'package:flutter/widgets.dart';
import 'package:flutter_appbar/components/position.dart';

abstract class AppBarBehavior {
  setPixels(
    double available,
    AppBarPosition appBar,
    ScrollPosition scroll,
  );
}

class MaterialAppBarBehavior extends AppBarBehavior {
  @override
  setPixels(double available, AppBarPosition appBar, ScrollPosition scroll) {
    return appBar.setPixelsWithDelta(available);
  }
}
