import 'dart:ui';

/// Writes four session colors to [shader] starting at [floatIndex].
/// Order: contact1 base, contact1 reversed, contact2 base, contact2 reversed.
int writeSessionShaderColors(
  FragmentShader shader,
  int floatIndex,
  List<Color> colors,
) {
  for (var i = 0; i < 4; i++) {
    final color = i < colors.length
        ? colors[i]
        : (colors.isNotEmpty ? colors.last : const Color(0xFF808080));
    shader.setFloat(floatIndex++, color.r);
    shader.setFloat(floatIndex++, color.g);
    shader.setFloat(floatIndex++, color.b);
    shader.setFloat(floatIndex++, color.a);
  }
  return floatIndex;
}
