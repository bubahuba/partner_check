import 'package:flutter/material.dart';

/// +1 for LTR (slide from trailing edge), -1 for RTL (slide from leading edge).
double horizontalSlideSign(BuildContext context) {
  return Directionality.of(context) == TextDirection.rtl ? -1.0 : 1.0;
}

Offset horizontalSlideBegin(BuildContext context) {
  return Offset(horizontalSlideSign(context), 0);
}

Offset horizontalPanelSlideOffset(BuildContext context, double progress) {
  return Offset(
    horizontalSlideSign(context) * progress * MediaQuery.sizeOf(context).width,
    0,
  );
}

Widget buildHorizontalSlideTransition(
  BuildContext context,
  Animation<double> animation,
  Widget child,
) {
  final tween = Tween(begin: horizontalSlideBegin(context), end: Offset.zero)
      .chain(CurveTween(curve: Curves.ease));
  return SlideTransition(position: animation.drive(tween), child: child);
}
