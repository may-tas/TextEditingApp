import 'dart:async';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:texterra/utils/web_utils.dart';

/// Drag and drop overlay for web platform
class DragDropOverlay extends StatefulWidget {
  final Widget child;
  final Function(List<PlatformFile> files)? onFilesDropped;
  final Function(bool isDragging)? onDragStateChanged;

  const DragDropOverlay({
    Key? key,
    required this.child,
    this.onFilesDropped,
    this.onDragStateChanged,
  }) : super(key: key);

  @override
  State<DragDropOverlay> createState() => _DragDropOverlayState();
}

class _DragDropOverlayState extends State<DragDropOverlay> {
  bool _isDragging = false;
  StreamSubscription<html.Event>? _dragSubscription;
  StreamSubscription<html.Event>? _dropSubscription;

  @override
  void initState() {
    super.initState();
    if (WebUtils.isWeb) {
      _setupWebDragDrop();
    }
  }

  @override
  void dispose() {
    _dragSubscription?.cancel();
    _dropSubscription?.cancel();
    super.dispose();
  }

  void _setupWebDragDrop() {
    // Listen for custom events from WebUtils
    html.window.addEventListener('files_dropped', (html.Event event) {
      final customEvent = event as html.CustomEvent;
      final files = customEvent.detail as List<PlatformFile>?;

      if (files != null && files.isNotEmpty) {
        widget.onFilesDropped?.call(files);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isDragging && WebUtils.isWeb)
          Container(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.file_upload,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Drop files here',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Supported: Images, Text files, Documents',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// PWA Install Prompt Widget
class PWAInstallPrompt extends StatefulWidget {
  final Widget child;

  const PWAInstallPrompt({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<PWAInstallPrompt> createState() => _PWAInstallPromptState();
}

class _PWAInstallPromptState extends State<PWAInstallPrompt> {
  bool _showInstallPrompt = false;
  StreamSubscription<html.Event>? _installAvailableSubscription;
  StreamSubscription<html.Event>? _installedSubscription;

  @override
  void initState() {
    super.initState();
    if (WebUtils.isWeb && !WebUtils().isPWAInstalled) {
      _setupInstallPrompt();
    }
  }

  @override
  void dispose() {
    _installAvailableSubscription?.cancel();
    _installedSubscription?.cancel();
    super.dispose();
  }

  void _setupInstallPrompt() {
    // Listen for install availability
    html.window.addEventListener('pwa_install_available', (html.Event event) {
      if (mounted) {
        setState(() => _showInstallPrompt = true);
      }
    });

    // Listen for successful installation
    html.window.addEventListener('pwa_installed', (html.Event event) {
      if (mounted) {
        setState(() => _showInstallPrompt = false);
        _showSuccessMessage();
      }
    });
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('App installed successfully! 🎉'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _installPWA() async {
    final webUtils = WebUtils();
    final accepted = await webUtils.showInstallPrompt();

    if (accepted) {
      setState(() => _showInstallPrompt = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showInstallPrompt)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.install_mobile,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Install TextEditingApp',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => setState(() => _showInstallPrompt = false),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Install our app for a better experience with offline access and native app features.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _showInstallPrompt = false),
                          child: const Text('Not now'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _installPWA,
                          child: const Text('Install'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Network Status Indicator
class NetworkStatusIndicator extends StatefulWidget {
  final Widget child;

  const NetworkStatusIndicator({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<NetworkStatusIndicator> createState() => _NetworkStatusIndicatorState();
}

class _NetworkStatusIndicatorState extends State<NetworkStatusIndicator> {
  bool _isOnline = true;
  StreamSubscription<html.Event>? _networkSubscription;

  @override
  void initState() {
    super.initState();
    if (WebUtils.isWeb) {
      _setupNetworkMonitoring();
      _checkInitialStatus();
    }
  }

  @override
  void dispose() {
    _networkSubscription?.cancel();
    super.dispose();
  }

  void _setupNetworkMonitoring() {
    html.window.addEventListener('networkstatuschange', (html.Event event) {
      final customEvent = event as html.CustomEvent;
      final isOnline = customEvent.detail as bool? ?? true;

      if (mounted && _isOnline != isOnline) {
        setState(() => _isOnline = isOnline);

        // Show snackbar notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(isOnline ? 'Back online' : 'You are offline'),
              ],
            ),
            duration: const Duration(seconds: 3),
            backgroundColor: isOnline ? Colors.green : Colors.orange,
          ),
        );
      }
    });
  }

  Future<void> _checkInitialStatus() async {
    final webUtils = WebUtils();
    final isOnline = await webUtils.isOnline;
    if (mounted && _isOnline != isOnline) {
      setState(() => _isOnline = isOnline);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!WebUtils.isWeb)
          const SizedBox.shrink(), // Don't show on non-web platforms
        if (WebUtils.isWeb && !_isOnline)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.orange,
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'You are currently offline',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Web-specific keyboard shortcuts handler
class WebKeyboardShortcuts extends StatefulWidget {
  final Widget child;
  final Function(String shortcut)? onShortcut;

  const WebKeyboardShortcuts({
    Key? key,
    required this.child,
    this.onShortcut,
  }) : super(key: key);

  @override
  State<WebKeyboardShortcuts> createState() => _WebKeyboardShortcutsState();
}

class _WebKeyboardShortcutsState extends State<WebKeyboardShortcuts> {
  final Set<String> _pressedKeys = {};

  @override
  void initState() {
    super.initState();
    if (WebUtils.isWeb) {
      _setupKeyboardListeners();
    }
  }

  @override
  void dispose() {
    if (WebUtils.isWeb) {
      _removeKeyboardListeners();
    }
    super.dispose();
  }

  void _setupKeyboardListeners() {
    html.document.addEventListener('keydown', _handleKeyDown);
    html.document.addEventListener('keyup', _handleKeyUp);
  }

  void _removeKeyboardListeners() {
    html.document.removeEventListener('keydown', _handleKeyDown);
    html.document.removeEventListener('keyup', _handleKeyUp);
  }

  void _handleKeyDown(html.KeyboardEvent event) {
    final key = event.key?.toLowerCase() ?? '';
    final ctrl = event.ctrlKey || event.metaKey;
    final shift = event.shiftKey;
    final alt = event.altKey;

    // Build shortcut string
    final parts = <String>[];
    if (ctrl) parts.add('ctrl');
    if (event.metaKey && !ctrl) parts.add('cmd'); // macOS command key
    if (shift) parts.add('shift');
    if (alt) parts.add('alt');
    parts.add(key);

    final shortcut = parts.join('+');

    // Prevent default browser behavior for our shortcuts
    if (_isHandledShortcut(shortcut)) {
      event.preventDefault();
      event.stopPropagation();

      // Only trigger on keydown to avoid repeated triggers
      if (!_pressedKeys.contains(shortcut)) {
        _pressedKeys.add(shortcut);
        widget.onShortcut?.call(shortcut);
      }
    }
  }

  void _handleKeyUp(html.KeyboardEvent event) {
    final key = event.key?.toLowerCase() ?? '';
    final ctrl = event.ctrlKey || event.metaKey;
    final shift = event.shiftKey;
    final alt = event.altKey;

    final parts = <String>[];
    if (ctrl) parts.add('ctrl');
    if (event.metaKey && !ctrl) parts.add('cmd');
    if (shift) parts.add('shift');
    if (alt) parts.add('alt');
    parts.add(key);

    final shortcut = parts.join('+');
    _pressedKeys.remove(shortcut);
  }

  bool _isHandledShortcut(String shortcut) {
    const handledShortcuts = {
      'ctrl+n', 'cmd+n',
      'ctrl+z', 'cmd+z',
      'ctrl+y', 'cmd+y',
      'ctrl+shift+z', 'cmd+shift+z',
      'ctrl+s', 'cmd+s',
      'delete', 'backspace',
      'ctrl+t', 'cmd+t',
      'ctrl+d', 'cmd+d',
      'escape',
    };

    return handledShortcuts.contains(shortcut);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}