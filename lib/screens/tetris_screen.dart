import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/tetris_engine.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../services/contact_storage_service.dart';
import '../utils/tetris_session_colors.dart';
import '../utils/tetris_web_keyboard.dart';
import '../widgets/tetris_board.dart';
import '../widgets/tetris_game_over_overlay.dart';
import '../widgets/tetris_session_background.dart';
import 'tetris_players_screen.dart';

class TetrisScreen extends StatefulWidget {
  final TetrisSession session;

  const TetrisScreen({
    super.key,
    required this.session,
  });

  @override
  State<TetrisScreen> createState() => _TetrisScreenState();
}

class _TetrisScreenState extends State<TetrisScreen> {
  final ContactStorageService _storageService = ContactStorageService();
  late TetrisEngine _engine;
  Timer? _tickTimer;
  final FocusNode _focusNode = FocusNode();
  late Color _backgroundColor1;
  late Color _backgroundColor2;
  final _backgroundRandom = Random();
  late final List<Color> _sessionPieceColors;
  bool _isNewRecord = false;
  bool _gameOverHandled = false;

  @override
  void initState() {
    super.initState();
    _sessionPieceColors = tetrisPieceColorsFromSession(widget.session);
    final backgroundPair = pickRandomTetrisBackgroundPair(_sessionPieceColors);
    _backgroundColor1 = backgroundPair.$1;
    _backgroundColor2 = backgroundPair.$2;
    _engine = TetrisEngine(
      pieceColors: _sessionPieceColors,
      onPieceLanded: _onPieceLanded,
    );
    _startTimers();
    HardwareKeyboard.instance.addHandler(_handleHardwareKey);
    installTetrisWebKeyboardFix(onGameKey: _handleWebGameKey);
  }

  void _onPieceLanded(Color landedColor) {
    if (!mounted) return;
    setState(() {
      if (_backgroundRandom.nextBool()) {
        _backgroundColor1 = landedColor;
      } else {
        _backgroundColor2 = landedColor;
      }
    });
  }

  void _handleWebGameKey(String key) {
    if (key != 'ArrowUp' ||
        _engine.isGameOver ||
        _engine.isPaused ||
        !mounted) {
      return;
    }
    _engine.rotate();
    setState(() {});
  }

  void _startTimers() {
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      if (!mounted) return;
      final gameOverWeeks = _engine.tick();
      setState(() {});
      if (gameOverWeeks != null && !_gameOverHandled) {
        _gameOverHandled = true;
        unawaited(_handleGameOver(gameOverWeeks));
      }
    });
  }

  Future<void> _handleGameOver(int weeks) async {
    if (!mounted) return;

    final isNewRecord =
        await _storageService.upsertTetrisRecordIfBetter(widget.session, weeks);
    if (!mounted) return;

    setState(() {
      _isNewRecord = isNewRecord && weeks > 0;
    });
  }

  void _startNewGame() {
    final backgroundPair = pickRandomTetrisBackgroundPair(_sessionPieceColors);
    setState(() {
      _engine.resetGame();
      _gameOverHandled = false;
      _isNewRecord = false;
      _backgroundColor1 = backgroundPair.$1;
      _backgroundColor2 = backgroundPair.$2;
    });
  }

  void _togglePause() {
    if (_engine.isGameOver) return;
    setState(() {
      _engine.setPaused(!_engine.isPaused);
    });
  }

  Future<void> _openPlayersScreen() async {
    final wasPaused = _engine.isPaused;
    if (!_engine.isGameOver && !wasPaused) {
      setState(() => _engine.setPaused(true));
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => TetrisPlayersScreen(
          backgroundColor1: _backgroundColor1,
          backgroundColor2: _backgroundColor2,
        ),
      ),
    );

    if (!mounted || _engine.isGameOver || wasPaused) return;
    setState(() => _engine.setPaused(false));
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
    uninstallTetrisWebKeyboardFix();
    _focusNode.dispose();
    super.dispose();
  }

  bool _handleHardwareKey(KeyEvent event) {
    if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        _engine.setSoftDrop(false);
        if (mounted) setState(() {});
      }
      return false;
    }

    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return false;
    }

    if (_engine.isGameOver) return false;

    final key = event.logicalKey;
    if (_isRotateKey(event)) {
      final webArrowUp = kIsWeb &&
          (event.logicalKey == LogicalKeyboardKey.arrowUp ||
              event.physicalKey == PhysicalKeyboardKey.arrowUp);
      if (!webArrowUp && !_engine.isPaused) {
        _engine.rotate();
      }
      if (webArrowUp) {
        return false;
      }
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _engine.setSoftDrop(true);
    } else if (key == LogicalKeyboardKey.keyS) {
      _togglePause();
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (!_engine.isPaused) _engine.moveLeft();
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (!_engine.isPaused) _engine.moveRight();
    } else {
      return false;
    }

    if (mounted) setState(() {});
    return true;
  }

  bool _isRotateKey(KeyEvent event) {
    return event.logicalKey == LogicalKeyboardKey.arrowUp ||
        event.logicalKey == LogicalKeyboardKey.numpad8 ||
        event.logicalKey == LogicalKeyboardKey.keyX ||
        event.logicalKey == LogicalKeyboardKey.keyW ||
        event.physicalKey == PhysicalKeyboardKey.arrowUp;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    return KeyEventResult.ignored;
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.white,
      title: Text(l10n.tetrisWeeks(_engine.weeks)),
      actions: [
        IconButton(
          icon: const Icon(Icons.emoji_events),
          tooltip: l10n.tetrisPlayersTitle,
          onPressed: _openPlayersScreen,
        ),
        if (!_engine.isGameOver)
          IconButton(
            icon: Icon(_engine.isPaused ? Icons.play_arrow : Icons.pause),
            tooltip: _engine.isPaused ? l10n.tetrisResume : l10n.tetrisPause,
            onPressed: _togglePause,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isGameOver = _engine.isGameOver;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(l10n),
      body: TetrisSessionBackground(
        color1: _backgroundColor1,
        color2: _backgroundColor2,
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _focusNode.requestFocus(),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final boardWidth = tetrisPlayfieldMaxWidth(
                              context,
                              availableHeight: constraints.maxHeight,
                            );
                            return SizedBox(
                              width: boardWidth,
                              child: AspectRatio(
                                aspectRatio: TetrisEngine.hCount /
                                    TetrisEngine.vCount,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    TetrisBoard(engine: _engine),
                                    if (isGameOver)
                                      TetrisGameOverOverlay(
                                        weeks: _engine.weeks,
                                        isNewRecord: _isNewRecord,
                                        onStartNewGame: _startNewGame,
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                _TetrisControls(
                  enabled: !isGameOver,
                  isPaused: _engine.isPaused,
                  onMoveLeft: () {
                    if (!_engine.isPaused) {
                      _engine.moveLeft();
                      setState(() {});
                    }
                  },
                  onMoveRight: () {
                    if (!_engine.isPaused) {
                      _engine.moveRight();
                      setState(() {});
                    }
                  },
                  onRotate: () {
                    if (!_engine.isPaused) {
                      _engine.rotate();
                      setState(() {});
                    }
                  },
                  onSoftDropDown: () => _engine.setSoftDrop(true),
                  onSoftDropUp: () => _engine.setSoftDrop(false),
                  onPause: _togglePause,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TetrisControls extends StatelessWidget {
  final bool enabled;
  final bool isPaused;
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final VoidCallback onRotate;
  final VoidCallback onSoftDropDown;
  final VoidCallback onSoftDropUp;
  final VoidCallback onPause;

  const _TetrisControls({
    required this.enabled,
    required this.isPaused,
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onRotate,
    required this.onSoftDropDown,
    required this.onSoftDropUp,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              IconButton(
                icon: const Icon(Icons.rotate_right, color: Colors.white),
                iconSize: 32,
                onPressed: onRotate,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    iconSize: 32,
                    onPressed: onMoveLeft,
                  ),
                  GestureDetector(
                    onTapDown: (_) => onSoftDropDown(),
                    onTapUp: (_) => onSoftDropUp(),
                    onTapCancel: onSoftDropUp,
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.arrow_downward,
                          size: 32, color: Colors.white),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    iconSize: 32,
                    onPressed: onMoveRight,
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onPause,
                icon: Icon(isPaused ? Icons.play_arrow : Icons.pause,
                    color: Colors.white),
                label: Text(
                  isPaused ? l10n.tetrisResume : l10n.tetrisPause,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
