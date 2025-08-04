import 'package:flutter/material.dart';

enum SnackbarType { success, info, error }

class CustomSnackbar {
  static final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  
  static GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  static void show({
    required String message,
    required SnackbarType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final context = _navigatorKey.currentContext;
    if (context == null) return;

    // Using a more reliable way to access overlay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final overlayState = Navigator.of(context).overlay;
      if (overlayState == null) return;

      late OverlayEntry overlayEntry;

      overlayEntry = OverlayEntry(
        builder: (context) => _SnackbarWidget(
          message: message,
          type: type,
          onDismiss: () => overlayEntry.remove(),
        ),
      );

      overlayState.insert(overlayEntry);

      // Auto-dismiss after duration
      Future.delayed(duration, () {
        if (overlayEntry.mounted) {
          overlayEntry.remove();
        }
      });
    });
  }

  static void showSuccess(String message, {Duration? duration}) {
    show(
      message: message,
      type: SnackbarType.success,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static void showInfo(String message, {Duration? duration}) {
    show(
      message: message,
      type: SnackbarType.info,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  static void showError(String message, {Duration? duration}) {
    show(
      message: message,
      type: SnackbarType.error,
      duration: duration ?? const Duration(seconds: 4),
    );
  }
}

class _SnackbarWidget extends StatefulWidget {
  final String message;
  final SnackbarType type;
  final VoidCallback onDismiss;

  const _SnackbarWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_SnackbarWidget> createState() => _SnackbarWidgetState();
}

class _SnackbarWidgetState extends State<_SnackbarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  Color _getBackgroundColor() {
    // Dark grey background for all types
    return const Color(0xFF3C3C3C);
  }

  Color _getAccentColor() {
    switch (widget.type) {
      case SnackbarType.success:
        return const Color(0xFF4CAF50); // Simple green
      case SnackbarType.info:
        return const Color(0xFF2196F3); // Simple blue  
      case SnackbarType.error:
        return const Color(0xFFF44336); // Simple red
    }
  }

  Color _getTextColor() {
    // White text for better contrast on dark background
    return Colors.white;
  }

  IconData _getIcon() {
    switch (widget.type) {
      case SnackbarType.success:
        return Icons.check_circle;
      case SnackbarType.info:
        return Icons.info;
      case SnackbarType.error:
        return Icons.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      _getIcon(),
                      color: _getAccentColor(),
                      size: 18,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: TextStyle(
                          color: _getTextColor(),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _dismiss,
                      child: Icon(
                        Icons.close,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
