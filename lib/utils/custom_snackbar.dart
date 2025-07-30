import 'package:flutter/material.dart';

enum SnackbarType {
  success,
  info,
  error,
}

class CustomSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    required SnackbarType type,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getIcon(type),
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getBackgroundColor(type),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
      duration: duration,
      action: actionLabel != null && onActionPressed != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: Colors.white,
              onPressed: onActionPressed,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle_outline;
      case SnackbarType.info:
        return Icons.info_outline;
      case SnackbarType.error:
        return Icons.error_outline;
    }
  }

  static Color _getBackgroundColor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return const Color(0xFF4CAF50); // Green
      case SnackbarType.info:
        return const Color(0xFF2196F3); // Blue
      case SnackbarType.error:
        return const Color(0xFFF44336); // Red
    }
  }

  // Convenience methods for different snackbar types
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.success,
      duration: duration,
      onActionPressed: onActionPressed,
      actionLabel: actionLabel,
    );
  }

  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.info,
      duration: duration,
      onActionPressed: onActionPressed,
      actionLabel: actionLabel,
    );
  }

  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onActionPressed,
    String? actionLabel,
  }) {
    show(
      context: context,
      message: message,
      type: SnackbarType.error,
      duration: duration,
      onActionPressed: onActionPressed,
      actionLabel: actionLabel,
    );
  }
} 