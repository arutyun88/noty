# Noty

A Flutter package for displaying various types of user messages with animated stacked snackbars.

## Current Status

This package is feature-complete and production-ready. All core functionality has been implemented:

- ✅ **SnackbarMessage** - Abstract base class for all snackbar messages
- ✅ **SnackbarType** - Enumeration of message types (info, success, warning, error, loading)
- ✅ **SnackbarPriority** - Enumeration of message priorities (low, normal, high, critical)
- ✅ **SnackbarAction** - Class for interactive actions in messages
- ✅ **BasicSnackbarMessage** - Basic implementation for simple notifications
- ✅ **SnackbarController** - Controller for managing stacked snackbars with spam prevention and priority management
- ✅ **SnackbarAdapter** - Abstract base class for connecting external data sources to the snackbar system
- ✅ **NetworkSnackbarAdapter** - Adapter for monitoring network connectivity
- ✅ **SnackbarAdapterSets** - Predefined adapter combinations for different use cases
- ✅ **SnackbarMessages** - Utility class for creating typed snackbar messages
- ✅ **SnackbarMixin** - Mixin for simplified snackbar usage in widgets
- ✅ **SnackbarOverlay** - Main widget for displaying snackbars over application interface

**Package Status**: ✅ **Complete & Production Ready**
This package provides a complete solution for snackbar management with no additional components needed.

## Architecture

The package follows a focused architecture where snackbars are displayed exclusively through the overlay system:

- **SnackbarOverlay** - Main widget for displaying snackbars over the entire application
- **SnackbarController** - Manages message lifecycle and state
- **SnackbarMessage** - Data models for different message types
- **SnackbarAdapter** - System for integrating with external services
- **Utility Classes** - Helper methods and mixins for common operations

This design ensures consistent behavior, prevents UI conflicts, and provides a unified user experience across the application.

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  noty: ^0.0.1
```

### Examples

The package includes comprehensive examples demonstrating all features:

- **[Simple Example](example/lib/simple_example.dart)** - Basic usage and core message types
- **[Advanced Example](example/lib/advanced_example.dart)** - All features including priorities, actions, grouping, and positioning
- **[Adapters Example](example/lib/adapters_example.dart)** - External system integration with adapters

To run examples:
```bash
cd example
flutter run
```

### Basic Usage

Currently, you can create basic snackbar messages and manage them with the controller:

```dart
import 'package:noty/noty.dart';

// Create a controller
final controller = SnackbarController();

// Create a basic snackbar message
final message = BasicSnackbarMessage(
  id: 'welcome',
  message: 'Welcome to the app!',
  type: SnackbarType.info,
  duration: Duration(seconds: 3),
  priority: SnackbarPriority.normal,
);

// Show the message
controller.showSnackbar(message);

// Create a message with actions
final errorMessage = BasicSnackbarMessage(
  id: 'network_error',
  message: 'Network connection failed',
  type: SnackbarType.error,
  priority: SnackbarPriority.critical,
  persistent: true,
  actions: [
    SnackbarAction(
      label: 'Retry',
      onPressed: () => retryConnection(),
    ),
  ],
);

// Show error message
controller.showSnackbar(errorMessage);

// Update existing message
controller.updateMessage('network_error', 
  BasicSnackbarMessage(
    id: 'network_error',
    message: 'Connection restored!',
    type: SnackbarType.success,
  )
);

// Hide specific message
controller.hideSnackbar('welcome');

// Clear all messages
controller.clearAll();

// Using adapters for automatic notifications
final networkAdapter = NetworkSnackbarAdapter();
networkAdapter.initialize(controller);

// Or use predefined adapter sets
final adapters = SnackbarAdapterSets.basic;
for (final adapter in adapters) {
  adapter.initialize(controller);
}

// Create custom adapters
final customAdapter = CustomSnackbarAdapter(
  id: 'time_monitor',
  initialize: (controller) {
    Timer.periodic(Duration(hours: 1), (_) {
      controller.showSnackbar(
        BasicSnackbarMessage(
          id: 'hourly_reminder',
          message: 'Another hour has passed!',
          type: SnackbarType.info,
        ),
      );
    });
  },
);
customAdapter.initialize(controller);

// Using utility methods for quick message creation
final infoMessage = SnackbarMessages.info('Profile updated');
controller.showSnackbar(infoMessage);

final errorMessage = SnackbarMessages.error(
  'Failed to save data',
  actions: [
    SnackbarAction(
      label: 'Retry',
      onPressed: () => retryOperation(),
    ),
  ],
);
controller.showSnackbar(errorMessage);

// Using mixin in widgets
class MyWidget extends StatelessWidget with SnackbarMixin {
  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SnackbarController>(context);
    
    return ElevatedButton(
      onPressed: () => showSuccess(controller, 'Operation completed!'),
      child: Text('Execute'),
    );
  }
}

// Using SnackbarOverlay for displaying snackbars
MaterialApp(
  home: SnackbarOverlay(
    child: MyHomePage(),
    stackAlignment: StackAlignment.topRight,
    maxVisibleMessages: 3,
    padding: EdgeInsets.all(16),
  ),
);

// With adapters
SnackbarOverlay(
  child: MyApp(),
  adapters: [
    NetworkSnackbarAdapter(),
    CustomSnackbarAdapter(
      id: 'custom_monitor',
      initialize: (controller) {
        // Your custom logic here
      },
    ),
  ],
  maxVisibleMessages: 5,
);

## API Reference

### SnackbarMessage

Abstract base class for all snackbar message types.

```dart
abstract class SnackbarMessage {
  final String id;           // Unique identifier
  final String message;      // Text to display
  final SnackbarType type;   // Message type
  final Duration? duration;  // Auto-hide duration
  final Widget? icon;        // Custom icon
  final SnackbarPriority priority; // Display priority
  final bool persistent;     // Stay on screen permanently
  final List<SnackbarAction>? actions; // Interactive buttons
  final String? groupId;     // Group identifier
}
```

### SnackbarType

- `info` - Information message (2s default duration)
- `success` - Success message (2s default duration)
- `warning` - Warning message (3s default duration)
- `error` - Error message (4s default duration)
- `loading` - Loading message (infinite duration)

### SnackbarPriority

- `low(0)` - Secondary information
- `normal(1)` - Standard notifications (default)
- `high(2)` - Important notifications
- `critical(3)` - Critical errors requiring immediate action

### SnackbarAction

```dart
SnackbarAction({
  required String label,      // Button text
  required VoidCallback onPressed, // Tap handler
  Color? textColor,          // Custom text color
})
```

### SnackbarController

Manages the lifecycle of snackbar messages with features like spam prevention, priority management, and grouping.

```dart
class SnackbarController extends ChangeNotifier {
  // Show a message
  void showSnackbar(SnackbarMessage message);
  
  // Hide a specific message
  void hideSnackbar(String id);
  
  // Hide all messages in a group
  void hideGroup(String groupId);
  
  // Update existing message
  void updateMessage(String id, SnackbarMessage newMessage);
  
  // Clear all messages
  void clearAll();
  
  // Clear non-persistent messages only
  void clearNonPersistent();
}
```

**Key Features:**
- **Spam Prevention**: Prevents showing the same message too frequently (2-second interval)
- **Priority Management**: Messages are sorted by priority (critical → high → normal → low)
- **Group Management**: Related messages can be grouped and managed together
- **Message Limits**: Maximum 10 total messages, 3 per group
- **Reactive Updates**: Extends ChangeNotifier for easy integration with Flutter widgets

### SnackbarAdapter

Abstract base class for connecting external data sources to the snackbar system.

```dart
abstract class SnackbarAdapter {
  String get id;
  void initialize(SnackbarController controller);
  void dispose();
}
```

**Key Features:**
- **Automatic Notifications**: Monitors app state changes and shows notifications automatically
- **Resource Management**: Proper cleanup with dispose method
- **Easy Integration**: Simple interface for connecting any data source

### NetworkSnackbarAdapter

Automatically monitors network connectivity and shows appropriate notifications.

```dart
const networkAdapter = NetworkSnackbarAdapter();
networkAdapter.initialize(controller);
```

**Features:**
- **Connection Lost**: Shows error message with retry action
- **Connection Restored**: Shows success message
- **Slow Connection**: Shows warning message

### SnackbarAdapterSets

Predefined combinations of adapters for different use cases.

```dart
// Basic set for simple apps
final adapters = SnackbarAdapterSets.basic;

// Advanced set for full-featured apps
final adapters = SnackbarAdapterSets.advanced;

// Custom set
final customSet = SnackbarAdapterSets.custom([
  NetworkSnackbarAdapter(),
  CustomSnackbarAdapter(
    id: 'custom_monitor',
    initialize: (controller) {
      // Your custom logic here
    },
  ),
]);
```

### SnackbarMessages

Utility class for creating typed snackbar messages with appropriate defaults.

```dart
// Quick message creation
final info = SnackbarMessages.info('Data updated');
final success = SnackbarMessages.success('File saved');
final error = SnackbarMessages.error('Connection failed');
final warning = SnackbarMessages.warning('Low battery');
final loading = SnackbarMessages.loading('Processing...', customId: 'process');
```

**Features:**
- **Auto-generated IDs**: Unique IDs based on timestamp
- **Type-specific defaults**: Appropriate durations and priorities for each type
- **Custom ID support**: For loading indicators that need specific management

### SnackbarMixin

Mixin for simplified snackbar usage in widgets.

```dart
class MyWidget extends StatelessWidget with SnackbarMixin {
  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SnackbarController>();
    
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => showInfo(controller, 'Info message'),
          child: Text('Show Info'),
        ),
        ElevatedButton(
          onPressed: () => showError(
            controller,
            'Error occurred',
            actions: [SnackbarAction(label: 'Retry', onPressed: retry)],
          ),
          child: Text('Show Error'),
        ),
        ElevatedButton(
          onPressed: () => showLoading(controller, 'Loading...', id: 'main'),
          child: Text('Show Loading'),
        ),
      ],
    );
  }
}
```

**Available Methods:**
- `showInfo()` - Shows information message
- `showSuccess()` - Shows success message
- `showError()` - Shows error message with optional actions
- `showWarning()` - Shows warning message
- `showLoading()` - Shows persistent loading indicator
- `hideLoading()` - Hides specific loading indicator
- `clearAllSnackbars()` - Clears all active snackbars

### SnackbarOverlay

Main widget for displaying snackbars over application interface.

```dart
SnackbarOverlay({
  required Widget child,
  List<SnackbarAdapter> adapters = const [],
  EdgeInsets? padding,
  int maxVisibleMessages = 5,
  StackAlignment alignment = StackAlignment.topRight,
  SnackbarController? controller,
})
```

**Features:**
- **Overlay System**: Displays snackbars over other widgets
- **Adapter Management**: Integrates with external systems automatically
- **Animated Stacking**: Smooth animations for multiple messages
- **Auto-hide Timers**: Configurable display durations
- **Flexible Positioning**: Choose from 4 screen corners
- **Message Limits**: Control maximum visible messages

**StackAlignment Options:**
- `topLeft` - Top left corner
- `topRight` - Top right corner (default)
- `bottomLeft` - Bottom left corner
- `bottomRight` - Bottom right corner

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
