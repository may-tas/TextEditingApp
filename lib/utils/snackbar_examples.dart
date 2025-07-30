import 'package:flutter/material.dart';
import 'custom_snackbar.dart';

/// Example widget demonstrating how to use the CustomSnackbar
/// This can be used as a reference for implementing snackbars throughout the app
class SnackbarExamples extends StatelessWidget {
  const SnackbarExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snackbar Examples'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _showSuccessExample(context),
              child: const Text('Show Success Snackbar'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _showInfoExample(context),
              child: const Text('Show Info Snackbar'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _showErrorExample(context),
              child: const Text('Show Error Snackbar'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _showSnackbarWithAction(context),
              child: const Text('Show Snackbar with Action'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessExample(BuildContext context) {
    CustomSnackbar.showSuccess(
      context: context,
      message: 'Text added successfully!',
    );
  }

  void _showInfoExample(BuildContext context) {
    CustomSnackbar.showInfo(
      context: context,
      message: 'You can drag text items to move them around.',
    );
  }

  void _showErrorExample(BuildContext context) {
    CustomSnackbar.showError(
      context: context,
      message: 'Failed to save changes. Please try again.',
    );
  }

  void _showSnackbarWithAction(BuildContext context) {
    CustomSnackbar.show(
      context: context,
      message: 'Text deleted. You can undo this action.',
      type: SnackbarType.info,
      actionLabel: 'UNDO',
      onActionPressed: () {
        // Handle undo action
        CustomSnackbar.showSuccess(
          context: context,
          message: 'Text restored successfully!',
        );
      },
    );
  }
}

/// Example usage in CanvasCubit methods
class CanvasCubitExamples {
  // Example of how to use CustomSnackbar in cubit methods
  // Note: You'll need to pass BuildContext to these methods or use a different approach
  
  static void addTextWithNotification(BuildContext context, String text) {
    // Add text logic here
    // ...
    
    // Show success notification
    CustomSnackbar.showSuccess(
      context: context,
      message: 'Text "$text" added successfully!',
    );
  }

  static void clearCanvasWithConfirmation(BuildContext context) {
    // Clear canvas logic here
    // ...
    
    // Show info notification with undo action
    CustomSnackbar.show(
      context: context,
      message: 'Canvas cleared. All text items have been removed.',
      type: SnackbarType.info,
      actionLabel: 'UNDO',
      onActionPressed: () {
        // Handle undo logic
        CustomSnackbar.showSuccess(
          context: context,
          message: 'Canvas restored successfully!',
        );
      },
    );
  }

  static void handleError(BuildContext context, String errorMessage) {
    CustomSnackbar.showError(
      context: context,
      message: errorMessage,
      duration: const Duration(seconds: 5),
    );
  }
} 