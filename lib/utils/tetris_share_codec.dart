import 'dart:convert';

const tetrisShareBaseUrl = 'https://partnercheck.huba.sk/app/';

/// Packs two 24-bit contact colors as 6 big-endian bytes, Base64url-encoded.
String encodeTetrisColors(int color1, int color2) {
  final c1 = color1 & 0xFFFFFF;
  final c2 = color2 & 0xFFFFFF;
  final bytes = <int>[
    (c1 >> 16) & 0xFF,
    (c1 >> 8) & 0xFF,
    c1 & 0xFF,
    (c2 >> 16) & 0xFF,
    (c2 >> 8) & 0xFF,
    c2 & 0xFF,
  ];
  return base64Url.encode(bytes).replaceAll('=', '');
}

/// Decodes [encoded] back to two 24-bit contact color values, or null if invalid.
(int, int)? decodeTetrisColors(String encoded) {
  if (encoded.isEmpty) return null;

  final normalized = encoded.replaceAll('-', '+').replaceAll('_', '/');
  final padding = (4 - normalized.length % 4) % 4;
  final padded = normalized + ('=' * padding);

  List<int> bytes;
  try {
    bytes = base64Url.decode(padded);
  } on FormatException {
    return null;
  }

  if (bytes.length != 6) return null;

  final color1 = (bytes[0] << 16) | (bytes[1] << 8) | bytes[2];
  final color2 = (bytes[3] << 16) | (bytes[4] << 8) | bytes[5];
  return (color1, color2);
}

String buildTetrisShareUrl({
  required String languageCode,
  required int color1,
  required int color2,
}) {
  return _buildFeatureShareUrl(
    feature: 'tetris',
    languageCode: languageCode,
    color1: color1,
    color2: color2,
  );
}

String buildPlasmaShareUrl({
  required String languageCode,
  required int color1,
  required int color2,
}) {
  return _buildFeatureShareUrl(
    feature: 'plasma',
    languageCode: languageCode,
    color1: color1,
    color2: color2,
  );
}

String buildLavaShareUrl({
  required String languageCode,
  required int color1,
  required int color2,
}) {
  return _buildFeatureShareUrl(
    feature: 'lava',
    languageCode: languageCode,
    color1: color1,
    color2: color2,
  );
}

String _buildFeatureShareUrl({
  required String feature,
  required String languageCode,
  required int color1,
  required int color2,
}) {
  final uri = Uri.parse(tetrisShareBaseUrl).replace(
    queryParameters: {
      'feature': feature,
      'lang': languageCode,
      'colors': encodeTetrisColors(color1, color2),
    },
  );
  return uri.toString();
}
