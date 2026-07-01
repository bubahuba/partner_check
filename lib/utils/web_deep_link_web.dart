import '../models.dart';
import 'tetris_share_codec.dart';

enum WebDeepLinkFeature { tetris, plasma, lava }

class WebDeepLink {
  final WebDeepLinkFeature feature;
  final TetrisSession session;

  const WebDeepLink({
    required this.feature,
    required this.session,
  });
}

const _sharedContactName = '?';

WebDeepLink? parseWebDeepLink(Uri uri) {
  final featureName = uri.queryParameters['feature'];
  final feature = switch (featureName) {
    'tetris' => WebDeepLinkFeature.tetris,
    'plasma' || 'mandala' => WebDeepLinkFeature.plasma,
    'lava' || 'glitch' => WebDeepLinkFeature.lava,
    _ => null,
  };
  if (feature == null) {
    return null;
  }

  final encoded = uri.queryParameters['colors'];
  if (encoded == null || encoded.isEmpty) {
    return null;
  }

  final colors = decodeTetrisColors(encoded);
  if (colors == null) {
    return null;
  }

  final (color1, color2) = colors;
  return WebDeepLink(
    feature: feature,
    session: TetrisSession(
      contact1Name: _sharedContactName,
      contact1Color: color1,
      contact2Name: _sharedContactName,
      contact2Color: color2,
    ),
  );
}
