import 'package:flutter_test/flutter_test.dart';
import 'package:partner_check/utils/tetris_share_codec.dart';

void main() {
  test('encode and decode round-trip', () {
    const color1 = 0xFF0044;
    const color2 = 0xAABBCC;

    final encoded = encodeTetrisColors(color1, color2);
    final decoded = decodeTetrisColors(encoded);

    expect(decoded, (color1, color2));
  });

  test('buildTetrisShareUrl includes feature lang and colors', () {
    final url = buildTetrisShareUrl(
      languageCode: 'en',
      color1: 0x123456,
      color2: 0xABCDEF,
    );

    final uri = Uri.parse(url);
    expect(uri.host, 'partnercheck.huba.sk');
    expect(uri.path, '/app/');
    expect(uri.queryParameters['feature'], 'tetris');
    expect(uri.queryParameters['lang'], 'en');
    expect(
      decodeTetrisColors(uri.queryParameters['colors']!),
      (0x123456, 0xABCDEF),
    );
  });

  test('buildPlasmaShareUrl includes feature lang and colors', () {
    final url = buildPlasmaShareUrl(
      languageCode: 'sk',
      color1: 0x123456,
      color2: 0xABCDEF,
    );

    final uri = Uri.parse(url);
    expect(uri.queryParameters['feature'], 'plasma');
    expect(uri.queryParameters['lang'], 'sk');
    expect(
      decodeTetrisColors(uri.queryParameters['colors']!),
      (0x123456, 0xABCDEF),
    );
  });

  test('buildLavaShareUrl includes feature lang and colors', () {
    final url = buildLavaShareUrl(
      languageCode: 'en',
      color1: 0x123456,
      color2: 0xABCDEF,
    );

    final uri = Uri.parse(url);
    expect(uri.queryParameters['feature'], 'lava');
    expect(uri.queryParameters['lang'], 'en');
    expect(
      decodeTetrisColors(uri.queryParameters['colors']!),
      (0x123456, 0xABCDEF),
    );
  });

  test('decodeTetrisColors rejects invalid input', () {
    expect(decodeTetrisColors(''), isNull);
    expect(decodeTetrisColors('not-valid'), isNull);
  });
}
