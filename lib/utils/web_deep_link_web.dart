import '../models.dart';
import 'tetris_share_codec.dart';

class WebDeepLink {
  final TetrisSession session;

  const WebDeepLink({required this.session});
}

const _sharedContactName = '?';

WebDeepLink? parseWebDeepLink(Uri uri) {
  if (uri.queryParameters['feature'] != 'tetris') {
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
    session: TetrisSession(
      contact1Name: _sharedContactName,
      contact1Color: color1,
      contact2Name: _sharedContactName,
      contact2Color: color2,
    ),
  );
}
