import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;

/// Web-specific utilities for PWA functionality
class WebUtils {
  static final WebUtils _instance = WebUtils._internal();
  factory WebUtils() => _instance;
  WebUtils._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  /// Check if running on web platform
  static bool get isWeb => kIsWeb;

  /// Check if PWA is installed
  bool get isPWAInstalled {
    if (!isWeb) return false;
    return html.window.matchMedia('(display-mode: standalone)').matches ||
           html.window.matchMedia('(display-mode: fullscreen)').matches ||
           html.window.matchMedia('(display-mode: minimal-ui)').matches;
  }

  /// Check if service worker is supported
  bool get isServiceWorkerSupported {
    if (!isWeb) return false;
    return js_util.hasProperty(html.window.navigator, 'serviceWorker');
  }

  /// Get network connectivity status
  Future<bool> get isOnline async {
    if (!isWeb) return true;
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return true; // Assume online if check fails
    }
  }

  /// Initialize web-specific features
  void initialize() {
    if (!isWeb) return;

    _setupConnectivityMonitoring();
    _setupKeyboardShortcuts();
    _setupPWAInstallPrompt();
    _setupDragAndDrop();
  }

  /// Setup connectivity monitoring
  void _setupConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        final isOnline = result != ConnectivityResult.none;
        debugPrint('[WebUtils] Network status: ${isOnline ? 'online' : 'offline'}');

        // Dispatch custom event that can be caught by Flutter
        final event = html.CustomEvent('networkstatuschange', detail: isOnline);
        html.window.dispatchEvent(event);
      },
    );
  }

  /// Setup global keyboard shortcuts for web
  void _setupKeyboardShortcuts() {
    if (!isWeb) return;

    html.document.onKeyDown.listen((html.KeyboardEvent event) {
      // Prevent default browser behavior for our shortcuts
      if (_isTextEditorShortcut(event)) {
        event.preventDefault();
        _handleKeyboardShortcut(event);
      }
    });
  }

  /// Check if the key combination is a text editor shortcut
  bool _isTextEditorShortcut(html.KeyboardEvent event) {
    final ctrlOrCmd = event.ctrlKey || event.metaKey;

    // Common text editor shortcuts
    return ctrlOrCmd && (
      event.key == 'n' || // New
      event.key == 'o' || // Open
      event.key == 's' || // Save
      event.key == 'z' || // Undo
      event.key == 'y' || // Redo
      event.key == 'a' || // Select all
      event.key == 'c' || // Copy
      event.key == 'v' || // Paste
      event.key == 'x'    // Cut
    );
  }

  /// Handle keyboard shortcuts
  void _handleKeyboardShortcut(html.KeyboardEvent event) {
    final ctrlOrCmd = event.ctrlKey || event.metaKey;
    final shift = event.shiftKey;

    if (!ctrlOrCmd) return;

    switch (event.key.toLowerCase()) {
      case 'n':
        if (!shift) _triggerAction('new_document');
        break;
      case 'o':
        _triggerAction('open_document');
        break;
      case 's':
        if (shift) {
          _triggerAction('save_as');
        } else {
          _triggerAction('save_document');
        }
        break;
      case 'z':
        if (shift) {
          _triggerAction('redo');
        } else {
          _triggerAction('undo');
        }
        break;
      case 'y':
        _triggerAction('redo');
        break;
      case 'a':
        _triggerAction('select_all');
        break;
      case 'c':
        _triggerAction('copy');
        break;
      case 'v':
        _triggerAction('paste');
        break;
      case 'x':
        _triggerAction('cut');
        break;
    }
  }

  /// Trigger action callback (to be set by the app)
  Function(String action)? _actionCallback;

  void setActionCallback(Function(String action) callback) {
    _actionCallback = callback;
  }

  void _triggerAction(String action) {
    _actionCallback?.call(action);
  }

  /// Setup PWA install prompt
  void _setupPWAInstallPrompt() {
    if (!isWeb || isPWAInstalled) return;

    // Listen for the beforeinstallprompt event
    html.window.addEventListener('beforeinstallprompt', (html.Event event) {
      event.preventDefault();
      final promptEvent = event as html.Event;

      // Store the event for later use
      _installPrompt = promptEvent;

      // Notify the app that install is available
      final customEvent = html.CustomEvent('pwa_install_available');
      html.window.dispatchEvent(customEvent);
    });

    // Listen for successful installation
    html.window.addEventListener('appinstalled', (html.Event event) {
      debugPrint('[WebUtils] PWA installed successfully');
      _installPrompt = null;

      final customEvent = html.CustomEvent('pwa_installed');
      html.window.dispatchEvent(customEvent);
    });
  }

  html.Event? _installPrompt;

  /// Show PWA install prompt
  Future<bool> showInstallPrompt() async {
    if (_installPrompt == null) return false;

    try {
      // Call the prompt
      js_util.callMethod(_installPrompt!, 'prompt', []);

      // Wait for user choice
      final choice = await js_util.promiseToFuture(
        js_util.getProperty(_installPrompt!, 'userChoice')
      );

      final outcome = js_util.getProperty(choice, 'outcome');
      return outcome == 'accepted';
    } catch (e) {
      debugPrint('[WebUtils] Install prompt error: $e');
      return false;
    }
  }

  /// Setup drag and drop functionality
  void _setupDragAndDrop() {
    if (!isWeb) return;

    // Setup global drag and drop handlers
    html.document.body?.addEventListener('dragover', (html.Event event) {
      event.preventDefault();
      final dragEvent = event as html.MouseEvent;
      dragEvent.dataTransfer?.dropEffect = 'copy';
    });

    html.document.body?.addEventListener('drop', (html.Event event) {
      event.preventDefault();
      final dropEvent = event as html.MouseEvent;
      final files = dropEvent.dataTransfer?.files;

      if (files != null && files.isNotEmpty) {
        _handleDroppedFiles(files);
      }
    });
  }

  /// Handle dropped files
  void _handleDroppedFiles(html.FileList files) {
    final fileList = <PlatformFile>[];

    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      fileList.add(PlatformFile(
        name: file.name,
        size: file.size,
        path: null, // Web files don't have paths
        bytes: null, // Will be read asynchronously
        readStream: null,
      ));
    }

    // Notify the app about dropped files
    final customEvent = html.CustomEvent('files_dropped', detail: fileList);
    html.window.dispatchEvent(customEvent);
  }

  /// Read file content as bytes (for web)
  Future<Uint8List?> readFileAsBytes(html.File file) async {
    final completer = Completer<Uint8List?>();

    final reader = html.FileReader();
    reader.onLoad.listen((html.ProgressEvent event) {
      final result = reader.result;
      if (result is String) {
        completer.complete(Uint8List.fromList(utf8.encode(result)));
      } else if (result is Uint8List) {
        completer.complete(result);
      } else {
        completer.complete(null);
      }
    });

    reader.onError.listen((html.ProgressEvent event) {
      completer.complete(null);
    });

    reader.readAsArrayBuffer(file);
    return completer.future;
  }

  /// Download file to user's device
  void downloadFile(String filename, Uint8List bytes, String mimeType) {
    if (!isWeb) return;

    final blob = html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrl(blob);

    final anchor = html.AnchorElement(href: url)
      ..download = filename
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  /// Share content using Web Share API (if available)
  Future<bool> shareContent(String title, String text, {String? url}) async {
    if (!isWeb) return false;

    try {
      if (js_util.hasProperty(html.window.navigator, 'share')) {
        final shareData = <String, dynamic>{'title': title, 'text': text};
        if (url != null) shareData['url'] = url;

        await js_util.promiseToFuture(
          js_util.callMethod(html.window.navigator, 'share', [js.JsObject.jsify(shareData)])
        );
        return true;
      }
    } catch (e) {
      debugPrint('[WebUtils] Share failed: $e');
    }
    return false;
  }

  /// Request notification permission
  Future<bool> requestNotificationPermission() async {
    if (!isWeb) return false;

    try {
      if (js_util.hasProperty(html.window, 'Notification')) {
        final permission = await js_util.promiseToFuture<String>(
          js_util.callMethod(html.window, 'Notification', ['requestPermission'])
        );
        return permission == 'granted';
      }
    } catch (e) {
      debugPrint('[WebUtils] Notification permission request failed: $e');
    }
    return false;
  }

  /// Show notification
  void showNotification(String title, String body, {String? icon}) {
    if (!isWeb) return;

    try {
      if (js_util.hasProperty(html.window, 'Notification')) {
        final options = <String, dynamic>{
          'body': body,
          'icon': icon ?? '/icons/Icon-192.png',
          'badge': '/icons/Icon-192.png',
        };

        js_util.callConstructor(
          js_util.getProperty(html.window, 'Notification'),
          [title, js.JsObject.jsify(options)]
        );
      }
    } catch (e) {
      debugPrint('[WebUtils] Show notification failed: $e');
    }
  }

  /// Cleanup resources
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}

/// Extension methods for web-specific functionality
extension WebBuildContextExtension on BuildContext {
  /// Check if running on web
  bool get isWeb => WebUtils.isWeb;

  /// Get web utils instance
  WebUtils get webUtils => WebUtils();
}

/// Keyboard shortcuts for web
class WebKeyboardShortcuts {
  static const newDocument = SingleActivator(LogicalKeyboardKey.keyN, control: true);
  static const openDocument = SingleActivator(LogicalKeyboardKey.keyO, control: true);
  static const saveDocument = SingleActivator(LogicalKeyboardKey.keyS, control: true);
  static const saveAsDocument = SingleActivator(LogicalKeyboardKey.keyS, control: true, shift: true);
  static const undo = SingleActivator(LogicalKeyboardKey.keyZ, control: true);
  static const redo = SingleActivator(LogicalKeyboardKey.keyY, control: true);
  static const redoAlt = SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true);
  static const selectAll = SingleActivator(LogicalKeyboardKey.keyA, control: true);
  static const copy = SingleActivator(LogicalKeyboardKey.keyC, control: true);
  static const paste = SingleActivator(LogicalKeyboardKey.keyV, control: true);
  static const cut = SingleActivator(LogicalKeyboardKey.keyX, control: true);
}