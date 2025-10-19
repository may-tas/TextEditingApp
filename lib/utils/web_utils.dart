import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

/// Web-specific utilities and keyboard shortcuts
class WebUtils {
  WebUtils._();

  /// Check if running on web platform
  static bool get isWeb => kIsWeb;

  /// Register PWA service worker (call this in main.dart)
  static Future<void> registerServiceWorker() async {
    if (!kIsWeb) return;

    // Service worker registration happens automatically via flutter_bootstrap.js
    // This is a placeholder for any additional web-specific initialization
    debugPrint('✅ Running on Web - PWA features enabled');
  }

  /// Install PWA prompt (for supported browsers)
  static Future<void> promptInstall() async {
    if (!kIsWeb) return;

    // The install prompt is handled by the browser's native UI
    // This method can be used to trigger custom install flows if needed
    debugPrint('💡 PWA install prompt triggered');
  }
}

/// Keyboard shortcut handler for web platform
class KeyboardShortcuts extends StatelessWidget {
  final Widget child;
  final VoidCallback? onSave;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onNew;
  final VoidCallback? onClear;
  final VoidCallback? onToggleDrawing;

  const KeyboardShortcuts({
    super.key,
    required this.child,
    this.onSave,
    this.onUndo,
    this.onRedo,
    this.onNew,
    this.onClear,
    this.onToggleDrawing,
  });

  @override
  Widget build(BuildContext context) {
    // Only apply keyboard shortcuts on web
    if (!kIsWeb) return child;

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        // Save: Ctrl/Cmd + S
        const SingleActivator(LogicalKeyboardKey.keyS, control: true): () {
          onSave?.call();
        },
        const SingleActivator(LogicalKeyboardKey.keyS, meta: true): () {
          onSave?.call();
        },

        // Undo: Ctrl/Cmd + Z
        const SingleActivator(LogicalKeyboardKey.keyZ, control: true): () {
          onUndo?.call();
        },
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true): () {
          onUndo?.call();
        },

        // Redo: Ctrl/Cmd + Shift + Z or Ctrl/Cmd + Y
        const SingleActivator(LogicalKeyboardKey.keyZ,
            control: true, shift: true): () {
          onRedo?.call();
        },
        const SingleActivator(LogicalKeyboardKey.keyZ, meta: true, shift: true):
            () {
          onRedo?.call();
        },
        const SingleActivator(LogicalKeyboardKey.keyY, control: true): () {
          onRedo?.call();
        },
        const SingleActivator(LogicalKeyboardKey.keyY, meta: true): () {
          onRedo?.call();
        },

        // New: Ctrl/Cmd + N
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          onNew?.call();
        },
        const SingleActivator(LogicalKeyboardKey.keyN, meta: true): () {
          onNew?.call();
        },

        // Clear: Ctrl/Cmd + Delete
        const SingleActivator(LogicalKeyboardKey.delete, control: true): () {
          onClear?.call();
        },
        const SingleActivator(LogicalKeyboardKey.delete, meta: true): () {
          onClear?.call();
        },

        // Toggle Drawing: Ctrl/Cmd + D
        const SingleActivator(LogicalKeyboardKey.keyD, control: true): () {
          onToggleDrawing?.call();
        },
        const SingleActivator(LogicalKeyboardKey.keyD, meta: true): () {
          onToggleDrawing?.call();
        },
      },
      child: Focus(
        autofocus: true,
        child: child,
      ),
    );
  }
}

/// Web-specific responsive breakpoints
class WebBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }
}
