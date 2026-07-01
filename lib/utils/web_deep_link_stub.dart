import '../models.dart';

enum WebDeepLinkFeature { tetris, plasma, lava }

class WebDeepLink {
  final WebDeepLinkFeature feature;
  final TetrisSession session;

  const WebDeepLink({
    required this.feature,
    required this.session,
  });
}

WebDeepLink? parseWebDeepLink(Uri uri) => null;
