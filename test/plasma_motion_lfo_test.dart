import 'package:flutter_test/flutter_test.dart';
import 'package:partner_check/utils/plasma_motion.dart';

void main() {
  group('plasmaMotionFromLfo', () {
    test('defaults at t=0', () {
      final params = plasmaMotionFromLfo(0);
      expect(params.center.dx, closeTo(0.5, 0.001));
      expect(params.center.dy, closeTo(0.5 + 0.15 * 0.866, 0.001));
      expect(params.speed, closeTo(0.85, 0.001));
      expect(params.intensity, closeTo(0.88 + 0.1 * 0.707, 0.001));
    });

    test('keeps values in safe ranges', () {
      for (var i = 0; i <= 100; i++) {
        final params = plasmaMotionFromLfo(i * 0.3);
        expect(params.center.dx, inInclusiveRange(0.12, 0.88));
        expect(params.center.dy, inInclusiveRange(0.12, 0.88));
        expect(params.speed, inInclusiveRange(0.45, 1.45));
        expect(params.intensity, inInclusiveRange(0.65, 1.0));
      }
    });
  });
}
