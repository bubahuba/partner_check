import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models.dart';
import '../utils/lava_gyro_timeline.dart';
import '../utils/tetris_link_sharing.dart';
import '../utils/tetris_session_colors.dart';
import '../utils/tetris_share_codec.dart';
import '../widgets/icons/back_icon.dart';
import '../widgets/icons/share_icon.dart';
import '../widgets/session_lava_background.dart';

class LavaScreen extends StatefulWidget {
  final TetrisSession session;
  final bool isSharedLaunch;
  final VoidCallback? onClose;

  const LavaScreen({
    super.key,
    required this.session,
    this.isSharedLaunch = false,
    this.onClose,
  });

  @override
  State<LavaScreen> createState() => _LavaScreenState();
}

class _LavaScreenState extends State<LavaScreen> {
  final LavaGyroTimelineController _gyroTimeline = LavaGyroTimelineController();
  late final List<Color> _sessionColors;

  @override
  void initState() {
    super.initState();
    _sessionColors = tetrisPieceColorsFromSession(widget.session);
    _gyroTimeline.start();
  }

  @override
  void reassemble() {
    super.reassemble();
    _gyroTimeline.restart();
  }

  @override
  void dispose() {
    _gyroTimeline.dispose();
    super.dispose();
  }

  Future<void> _shareLavaLink() async {
    final languageCode = AppLocalizations.normalizeLanguageCode(
      Localizations.localeOf(context).languageCode,
    );
    final url = buildLavaShareUrl(
      languageCode: languageCode,
      color1: widget.session.contact1Color,
      color2: widget.session.contact2Color,
    );
    await shareTetrisLink(context, url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        leading: widget.onClose == null
            ? null
            : IconButton(
                icon: const BackIcon(),
                onPressed: widget.onClose,
              ),
        automaticallyImplyLeading: widget.onClose == null,
        title: const SizedBox.shrink(),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon: const ShareIcon(),
            onPressed: _shareLavaLink,
          ),
        ],
      ),
      body: SessionLavaBackground(
        colors: _sessionColors,
        gyroTimeline: _gyroTimeline,
        child: const SizedBox.expand(),
      ),
    );
  }
}
