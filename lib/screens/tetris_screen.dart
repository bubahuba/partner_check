import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../game/tetris_engine.dart';
import '../l10n/app_localizations.dart';
import '../models.dart';
import '../services/contact_storage_service.dart';
import '../utils/tetris_link_sharing.dart';
import '../utils/tetris_session_colors.dart';
import '../utils/tetris_share_codec.dart';
import '../utils/tetris_web_keyboard.dart';
import '../widgets/icons/back_icon.dart';
import '../widgets/icons/share_icon.dart';
import '../widgets/tetris_board.dart';
import '../widgets/tetris_board_touch_handler.dart';
import '../widgets/tetris_game_over_overlay.dart';
import '../widgets/tetris_session_background.dart';
import 'tetris_players_screen.dart';

class TetrisScreen extends StatefulWidget {
  final TetrisSession session;
  final bool isSharedLaunch;
  final VoidCallback? onClose;

  const TetrisScreen({
    super.key,
    required this.session,
    this.isSharedLaunch = false,
    this.onClose,
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
  bool _rotateHighlighted = false;
  bool _leftHighlighted = false;
  bool _rightHighlighted = false;
  bool _downHighlighted = false;
  Timer? _controlPulseTimer;
  bool _awaitingFirstInput = false;

  @override
  void initState() {
    super.initState();
    _sessionPieceColors = tetrisPieceColorsFromSession(widget.session);
    final backgroundPair = pickRandomTetrisBackgroundPair(_sessionPieceColors);
    _backgroundColor1 = backgroundPair.$1;
    _backgroundColor2 = backgroundPair.$2;
    _engine = TetrisEngine(
      pieceColors: _sessionPieceColors,
      onPieceSpawned: _onPieceSpawned,
    );
    _beginPausedWithFirstPiece();
    _startTimers();
    HardwareKeyboard.instance.addHandler(_handleHardwareKey);
    installTetrisWebKeyboardFix(onGameKey: _handleWebGameKey);
  }

  void _beginPausedWithFirstPiece() {
    _engine.spawnInitialPiece();
    _engine.setPaused(true);
    _awaitingFirstInput = true;
  }

  void _onPieceSpawned(Color pieceColor) {
    if (!mounted) return;
    setState(() {
      if (_backgroundRandom.nextBool()) {
        _backgroundColor1 = pieceColor;
      } else {
        _backgroundColor2 = pieceColor;
      }
    });
  }

  void _handleWebGameKey(String key) {
    if (key != 'ArrowUp' || _engine.isGameOver || !mounted) {
      return;
    }
    _resumeFromFirstInput();
    if (_engine.isPaused) {
      if (mounted) setState(() {});
      return;
    }
    _engine.rotate();
    _pulseControlHighlight(setRotate: true);
  }

  void _resumeFromFirstInput() {
    if (!_awaitingFirstInput) return;
    _awaitingFirstInput = false;
    if (_engine.isPaused) {
      _engine.setPaused(false);
    }
  }

  bool get _touchEnabled =>
      !_engine.isGameOver && (!_engine.isPaused || _awaitingFirstInput);

  void _setControlHighlight({
    bool? rotate,
    bool? left,
    bool? right,
    bool? down,
  }) {
    if (!mounted) return;
    setState(() {
      if (rotate != null) _rotateHighlighted = rotate;
      if (left != null) _leftHighlighted = left;
      if (right != null) _rightHighlighted = right;
      if (down != null) _downHighlighted = down;
    });
  }

  void _pulseControlHighlight({
    bool setRotate = false,
    bool setDown = false,
  }) {
    _controlPulseTimer?.cancel();
    _setControlHighlight(
      rotate: setRotate ? true : null,
      down: setDown ? true : null,
    );
    _controlPulseTimer = Timer(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      _setControlHighlight(
        rotate: setRotate ? false : null,
        down: setDown ? false : null,
      );
    });
  }

  void _clearHorizontalHighlight() {
    if (!_leftHighlighted && !_rightHighlighted) return;
    _setControlHighlight(left: false, right: false);
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

    var isNewRecord = false;
    if (!widget.isSharedLaunch) {
      isNewRecord = await _storageService.upsertTetrisRecordIfBetter(
          widget.session, weeks);
    }
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
      _beginPausedWithFirstPiece();
    });
  }

  void _togglePause() {
    if (_engine.isGameOver) return;
    setState(() {
      if (_engine.isPaused) {
        _awaitingFirstInput = false;
      }
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

  Future<void> _shareTetrisLink() async {
    final languageCode = AppLocalizations.normalizeLanguageCode(
      Localizations.localeOf(context).languageCode,
    );
    final url = buildTetrisShareUrl(
      languageCode: languageCode,
      color1: widget.session.contact1Color,
      color2: widget.session.contact2Color,
    );
    await shareTetrisLink(context, url);
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _controlPulseTimer?.cancel();
    HardwareKeyboard.instance.removeHandler(_handleHardwareKey);
    uninstallTetrisWebKeyboardFix();
    _focusNode.dispose();
    super.dispose();
  }

  bool _handleHardwareKey(KeyEvent event) {
    if (event is KeyUpEvent) {
      final key = event.logicalKey;
      var changed = false;
      if (key == LogicalKeyboardKey.arrowDown) {
        _engine.setSoftDrop(false);
        if (_downHighlighted) {
          _downHighlighted = false;
          changed = true;
        }
      } else if (key == LogicalKeyboardKey.arrowLeft) {
        if (_leftHighlighted) {
          _leftHighlighted = false;
          changed = true;
        }
      } else if (key == LogicalKeyboardKey.arrowRight) {
        if (_rightHighlighted) {
          _rightHighlighted = false;
          changed = true;
        }
      } else if (_isRotateKey(event)) {
        if (_rotateHighlighted) {
          _rotateHighlighted = false;
          changed = true;
        }
      } else {
        return false;
      }
      if (changed && mounted) setState(() {});
      return changed;
    }

    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return false;
    }

    if (_engine.isGameOver) return false;

    final wasAwaiting = _awaitingFirstInput;
    _resumeFromFirstInput();

    final key = event.logicalKey;
    if (_isRotateKey(event)) {
      final webArrowUp = kIsWeb &&
          (event.logicalKey == LogicalKeyboardKey.arrowUp ||
              event.physicalKey == PhysicalKeyboardKey.arrowUp);
      if (webArrowUp) {
        if (wasAwaiting && mounted) setState(() {});
        return wasAwaiting;
      }
      if (!_engine.isPaused) {
        _rotateHighlighted = true;
        _engine.rotate();
      } else if (wasAwaiting && mounted) {
        setState(() {});
      }
    } else if (key == LogicalKeyboardKey.arrowDown) {
      _downHighlighted = true;
      _engine.setSoftDrop(true);
    } else if (key == LogicalKeyboardKey.keyS) {
      if (!wasAwaiting) {
        _togglePause();
      } else if (mounted) {
        setState(() {});
      }
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (!_engine.isPaused) {
        _leftHighlighted = true;
        _engine.moveLeft();
      } else if (wasAwaiting && mounted) {
        setState(() {});
      }
    } else if (key == LogicalKeyboardKey.arrowRight) {
      if (!_engine.isPaused) {
        _rightHighlighted = true;
        _engine.moveRight();
      } else if (wasAwaiting && mounted) {
        setState(() {});
      }
    } else {
      if (wasAwaiting && mounted) setState(() {});
      return wasAwaiting;
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

  Widget _buildTetrisBoard({
    required Size boardSize,
    required bool isGameOver,
  }) {
    return SizedBox(
      width: boardSize.width,
      height: boardSize.height,
      child: TetrisBoardTouchHandler(
        enabled: _touchEnabled,
        boardWidth: boardSize.width,
        onMoveLeft: () {
          _resumeFromFirstInput();
          if (_engine.isPaused) return;
          _engine.moveLeft();
          _setControlHighlight(left: true, right: false);
          setState(() {});
        },
        onMoveRight: () {
          _resumeFromFirstInput();
          if (_engine.isPaused) return;
          _engine.moveRight();
          _setControlHighlight(right: true, left: false);
          setState(() {});
        },
        onRotate: () {
          _resumeFromFirstInput();
          if (_engine.isPaused) return;
          _engine.rotate();
          _pulseControlHighlight(setRotate: true);
        },
        onHardDrop: () {
          _resumeFromFirstInput();
          if (_engine.isPaused) return;
          _engine.hardDrop();
          _pulseControlHighlight(setDown: true);
          setState(() {});
        },
        onTouchEnd: _clearHorizontalHighlight,
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
  }

  Widget _buildTetrisControls({required bool isGameOver}) {
    return _TetrisControls(
      enabled: !isGameOver,
      isPaused: _engine.isPaused,
      rotateHighlighted: _rotateHighlighted,
      leftHighlighted: _leftHighlighted,
      rightHighlighted: _rightHighlighted,
      downHighlighted: _downHighlighted,
      onMoveLeftDown: () => _setControlHighlight(left: true, right: false),
      onMoveLeftUp: () => _setControlHighlight(left: false),
      onMoveLeft: () {
        _resumeFromFirstInput();
        if (!_engine.isPaused) {
          _engine.moveLeft();
          setState(() {});
        } else {
          setState(() {});
        }
      },
      onMoveRightDown: () => _setControlHighlight(right: true, left: false),
      onMoveRightUp: () => _setControlHighlight(right: false),
      onMoveRight: () {
        _resumeFromFirstInput();
        if (!_engine.isPaused) {
          _engine.moveRight();
          setState(() {});
        } else {
          setState(() {});
        }
      },
      onRotateDown: () => _setControlHighlight(rotate: true),
      onRotateUp: () => _setControlHighlight(rotate: false),
      onRotate: () {
        _resumeFromFirstInput();
        if (!_engine.isPaused) {
          _engine.rotate();
          setState(() {});
        } else {
          setState(() {});
        }
      },
      onSoftDropDown: () {
        _resumeFromFirstInput();
        _setControlHighlight(down: true);
        _engine.setSoftDrop(true);
        setState(() {});
      },
      onSoftDropUp: () {
        _setControlHighlight(down: false);
        _engine.setSoftDrop(false);
      },
      onPause: _togglePause,
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n) {
    return AppBar(
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
      title: Text(l10n.tetrisWeeks(_engine.weeks)),
      actions: [
        IconButton(
          icon: const ShareIcon(),
          onPressed: _shareTetrisLink,
        ),
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
        child: SafeArea(
          child: Focus(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: _handleKeyEvent,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape =
                    constraints.maxWidth > constraints.maxHeight;
                final controls = _buildTetrisControls(isGameOver: isGameOver);

                Widget buildBoard(Size maxSize) {
                  final boardSize = tetrisPlayfieldSize(
                    maxSize.width,
                    maxSize.height,
                  );
                  return _buildTetrisBoard(
                    boardSize: boardSize,
                    isGameOver: isGameOver,
                  );
                }

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    final hadAwaiting = _awaitingFirstInput;
                    _resumeFromFirstInput();
                    if (hadAwaiting) {
                      setState(() {});
                    }
                    _focusNode.requestFocus();
                  },
                  child: isLandscape
                      ? Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: LayoutBuilder(
                                  builder: (context, boardConstraints) {
                                    return buildBoard(
                                      Size(
                                        boardConstraints.maxWidth,
                                        boardConstraints.maxHeight,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            controls,
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: Center(
                                child: buildBoard(
                                  Size(
                                    constraints.maxWidth,
                                    constraints.maxHeight,
                                  ),
                                ),
                              ),
                            ),
                            SafeArea(
                              top: false,
                              child: controls,
                            ),
                          ],
                        ),
                );
              },
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
  final bool rotateHighlighted;
  final bool leftHighlighted;
  final bool rightHighlighted;
  final bool downHighlighted;
  final VoidCallback onMoveLeftDown;
  final VoidCallback onMoveLeftUp;
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRightDown;
  final VoidCallback onMoveRightUp;
  final VoidCallback onMoveRight;
  final VoidCallback onRotateDown;
  final VoidCallback onRotateUp;
  final VoidCallback onRotate;
  final VoidCallback onSoftDropDown;
  final VoidCallback onSoftDropUp;
  final VoidCallback onPause;

  const _TetrisControls({
    required this.enabled,
    required this.isPaused,
    required this.rotateHighlighted,
    required this.leftHighlighted,
    required this.rightHighlighted,
    required this.downHighlighted,
    required this.onMoveLeftDown,
    required this.onMoveLeftUp,
    required this.onMoveLeft,
    required this.onMoveRightDown,
    required this.onMoveRightUp,
    required this.onMoveRight,
    required this.onRotateDown,
    required this.onRotateUp,
    required this.onRotate,
    required this.onSoftDropDown,
    required this.onSoftDropUp,
    required this.onPause,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TetrisControlButton(
                    icon: Icons.arrow_back,
                    highlighted: leftHighlighted,
                    onTapDown: onMoveLeftDown,
                    onTapUp: onMoveLeftUp,
                    onTap: onMoveLeft,
                  ),
                  _TetrisControlButton(
                    icon: Icons.arrow_downward,
                    highlighted: downHighlighted,
                    onTapDown: onSoftDropDown,
                    onTapUp: onSoftDropUp,
                    onTap: () {},
                  ),
                  _TetrisControlButton(
                    icon: Icons.arrow_forward,
                    highlighted: rightHighlighted,
                    onTapDown: onMoveRightDown,
                    onTapUp: onMoveRightUp,
                    onTap: onMoveRight,
                  ),
                  _TetrisControlButton(
                    icon: Icons.rotate_right,
                    highlighted: rotateHighlighted,
                    onTapDown: onRotateDown,
                    onTapUp: onRotateUp,
                    onTap: onRotate,
                  ),
                  _TetrisControlButton(
                    icon: isPaused ? Icons.play_arrow : Icons.pause,
                    highlighted: false,
                    onTapDown: () {},
                    onTapUp: () {},
                    onTap: onPause,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TetrisControlButton extends StatelessWidget {
  final IconData icon;
  final bool highlighted;
  final VoidCallback onTapDown;
  final VoidCallback onTapUp;
  final VoidCallback onTap;

  const _TetrisControlButton({
    required this.icon,
    required this.highlighted,
    required this.onTapDown,
    required this.onTapUp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapUp: (_) => onTapUp(),
      onTapCancel: onTapUp,
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeOut,
        scale: highlighted ? 1.08 : 1.0,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: highlighted ? 1 : 0.72),
            size: 32,
          ),
        ),
      ),
    );
  }
}
