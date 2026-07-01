import 'dart:js_interop';

import 'package:web/web.dart';

JSFunction? _keydownListener;
void Function(String key)? _onGameKey;

/// Stops the browser from consuming arrow keys before Flutter receives them.
/// [onGameKey] is a fallback for ArrowUp, which some browsers still swallow.
void installTetrisWebKeyboardFix({void Function(String key)? onGameKey}) {
  uninstallTetrisWebKeyboardFix();
  _onGameKey = onGameKey;

  _keydownListener = ((Event event) {
    final keyboardEvent = event as KeyboardEvent;
    if (keyboardEvent.repeat) return;

    final key = keyboardEvent.key;
    if (key.isEmpty) return;

    switch (key) {
      case 'ArrowUp':
      case 'ArrowDown':
      case 'ArrowLeft':
      case 'ArrowRight':
        keyboardEvent.preventDefault();
        if (key == 'ArrowUp') {
          _onGameKey?.call(key);
        }
    }
  }).toJS;

  window.addEventListener('keydown', _keydownListener, true.toJS);
}

void uninstallTetrisWebKeyboardFix() {
  if (_keydownListener == null) return;
  window.removeEventListener('keydown', _keydownListener, true.toJS);
  _keydownListener = null;
  _onGameKey = null;
}
