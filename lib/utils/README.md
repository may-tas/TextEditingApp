# Utils Directory

This directory contains utility classes and helper functions for the TextEditingApp.

## CustomSnackbar

A custom Snackbar implementation that provides a consistent and themed user experience across the app.

### Features

- **Three Types**: Success, Info, and Error states
- **Consistent Styling**: Aligned with the app's color scheme
- **Easy to Use**: Simple static methods for different snackbar types
- **Action Support**: Optional action buttons for user interactions
- **Customizable Duration**: Configurable display duration

### Usage

#### Basic Usage

```dart
import 'package:texterra/utils/custom_snackbar.dart';

// Success notification
CustomSnackbar.showSuccess(
  context: context,
  message: 'Operation completed successfully!',
);

// Info notification
CustomSnackbar.showInfo(
  context: context,
  message: 'This is an informational message.',
);

// Error notification
CustomSnackbar.showError(
  context: context,
  message: 'Something went wrong. Please try again.',
);
```

#### Advanced Usage

```dart
// Custom snackbar with action
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

// Custom duration
CustomSnackbar.showError(
  context: context,
  message: 'Critical error occurred!',
  duration: const Duration(seconds: 5),
);
```

### Snackbar Types

| Type | Color | Icon | Use Case |
|------|-------|------|----------|
| Success | Green | ✓ | Successful operations, confirmations |
| Info | Blue | ℹ | Informational messages, tips |
| Error | Red | ⚠ | Errors, warnings, failures |

### Implementation Details

- **No External Dependencies**: Uses only Flutter's built-in widgets
- **Floating Behavior**: Snackbars appear as floating elements with rounded corners
- **Consistent Margins**: 16px margin from screen edges
- **White Text**: High contrast text for better readability
- **Responsive Design**: Adapts to different screen sizes

### Best Practices

1. **Use Appropriate Types**: Choose the right snackbar type for your message
2. **Keep Messages Concise**: Short, clear messages work best
3. **Provide Actions When Needed**: Use action buttons for undo/retry operations
4. **Consider Duration**: Longer duration for important messages, shorter for quick confirmations
5. **Avoid Overuse**: Don't show snackbars for every minor action

### Migration from Default Snackbar

Replace existing `ScaffoldMessenger` usage:

```dart
// Old way
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Message'),
    backgroundColor: Colors.green,
  ),
);

// New way
CustomSnackbar.showSuccess(
  context: context,
  message: 'Message',
);
```

### Examples

See `snackbar_examples.dart` for complete usage examples and demonstration scenarios. 