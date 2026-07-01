import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models.dart';
import '../utils/plasma_motion.dart';
import '../utils/tetris_link_sharing.dart';
import '../utils/tetris_session_colors.dart';
import '../utils/tetris_share_codec.dart';
import '../widgets/icons/back_icon.dart';
import '../widgets/icons/share_icon.dart';
import '../widgets/session_plasma_background.dart';

class PlasmaScreen extends StatefulWidget {
  final TetrisSession session;
  final bool isSharedLaunch;
  final VoidCallback? onClose;

  const PlasmaScreen({
    super.key,
    required this.session,
    this.isSharedLaunch = false,
    this.onClose,
  });

  @override
  State<PlasmaScreen> createState() => _PlasmaScreenState();
}

class _PlasmaScreenState extends State<PlasmaScreen>
    with TickerProviderStateMixin {
  PlasmaMotionController? _motionController;
  late final List<Color> _sessionColors;

  @override
  void initState() {
    super.initState();
    _sessionColors = tetrisPieceColorsFromSession(widget.session);
    _initMotionController();
  }

  @override
  void reassemble() {
    super.reassemble();
    _initMotionController();
  }

  void _initMotionController() {
    _motionController?.dispose();
    _motionController = createPlasmaMotionController(vsync: this)..start();
  }

  @override
  void dispose() {
    _motionController?.dispose();
    _motionController = null;
    super.dispose();
  }

  Future<void> _sharePlasmaLink() async {
    final languageCode = AppLocalizations.normalizeLanguageCode(
      Localizations.localeOf(context).languageCode,
    );
    final url = buildPlasmaShareUrl(
      languageCode: languageCode,
      color1: widget.session.contact1Color,
      color2: widget.session.contact2Color,
    );
    await shareTetrisLink(context, url);
  }

  @override
  Widget build(BuildContext context) {
    final motionController = _motionController;
    if (motionController == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.shrink(),
      );
    }

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
            onPressed: _sharePlasmaLink,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mediaSize = MediaQuery.sizeOf(context);
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : mediaSize.width;
          final height = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : mediaSize.height;

          return SessionPlasmaBackground(
            key:
                ValueKey(Object.hashAll([..._sessionColors, motionController])),
            size: Size(width, height),
            colors: _sessionColors,
            deviceDensity: MediaQuery.devicePixelRatioOf(context),
            motionController: motionController,
          );
        },
      ),
    );
  }
}
