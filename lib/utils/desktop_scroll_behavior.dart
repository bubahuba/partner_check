import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Enables click-and-drag scrolling on desktop (mouse/trackpad) for panes.
class DesktopScrollBehavior extends MaterialScrollBehavior {
  const DesktopScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
        PointerDeviceKind.trackpad,
      };
}
