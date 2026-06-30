import 'dart:html' as html;

html.EventListener? _keydownListener;
void Function(String key)? _onGameKey;

/// Stops the browser from consuming arrow keys before Flutter receives them.
/// [onGameKey] is a fallback for ArrowUp, which some browsers still swallow.
void installTetrisWebKeyboardFix({void Function(String key)? onGameKey}) {
  uninstallTetrisWebKeyboardFix();
  _onGameKey = onGameKey;

  _keydownListener = (html.Event event) {
    if (event is! html.KeyboardEvent) return;
    if (event.repeat ?? false) return;

    final key = event.key;
    if (key == null) return;

    switch (key) {
      case 'ArrowUp':
      case 'ArrowDown':
      case 'ArrowLeft':
      case 'ArrowRight':
        event.preventDefault();
        if (key == 'ArrowUp') {
          _onGameKey?.call(key);
        }
    }
  };

  html.window.addEventListener('keydown', _keydownListener!, true);
}

void uninstallTetrisWebKeyboardFix() {
  if (_keydownListener == null) return;
  html.window.removeEventListener('keydown', _keydownListener!, true);
  _keydownListener = null;
  _onGameKey = null;
}
