import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:noty/noty.dart';

void main() {
  group('SnackbarMessage', () {
    test('BasicSnackbarMessage creation', () {
      final message = BasicSnackbarMessage(
        id: 'test_message',
        message: 'Test message',
        type: SnackbarType.info,
      );

      expect(message.id, 'test_message');
      expect(message.message, 'Test message');
      expect(message.type, SnackbarType.info);
      expect(message.priority, SnackbarPriority.normal);
      expect(message.persistent, false);
    });

    test('SnackbarMessage with custom properties', () {
      final message = BasicSnackbarMessage(
        id: 'custom_message',
        message: 'Custom message',
        type: SnackbarType.error,
        priority: SnackbarPriority.critical,
        persistent: true,
        duration: const Duration(seconds: 10),
      );

      expect(message.priority, SnackbarPriority.critical);
      expect(message.persistent, true);
      expect(message.duration, const Duration(seconds: 10));
    });
  });

  group('SnackbarAction', () {
    test('SnackbarAction creation', () {
      bool actionCalled = false;
      
      final action = SnackbarAction(
        label: 'Retry',
        onPressed: () => actionCalled = true,
        textColor: Colors.red,
      );

      expect(action.label, 'Retry');
      expect(action.textColor, Colors.red);
      
      action.onPressed();
      expect(actionCalled, true);
    });
  });

  group('SnackbarPriority', () {
    test('Priority values are correct', () {
      expect(SnackbarPriority.low.value, 0);
      expect(SnackbarPriority.normal.value, 1);
      expect(SnackbarPriority.high.value, 2);
      expect(SnackbarPriority.critical.value, 3);
    });

    test('Priority comparison works', () {
      expect(SnackbarPriority.critical.value > SnackbarPriority.high.value, true);
      expect(SnackbarPriority.high.value > SnackbarPriority.normal.value, true);
      expect(SnackbarPriority.normal.value > SnackbarPriority.low.value, true);
    });
  });

  group('SnackbarController', () {
    late SnackbarController controller;

    setUp(() {
      controller = SnackbarController();
    });

    test('Initial state is empty', () {
      expect(controller.messageCount, 0);
      expect(controller.hasMessages, false);
      expect(controller.messages, isEmpty);
    });

    test('Show snackbar adds message', () {
      final message = BasicSnackbarMessage(
        id: 'test',
        message: 'Test message',
        type: SnackbarType.info,
      );

      controller.showSnackbar(message);

      expect(controller.messageCount, 1);
      expect(controller.hasMessages, true);
      expect(controller.messages.first.id, 'test');
    });

    test('Hide snackbar removes message', () {
      final message = BasicSnackbarMessage(
        id: 'test',
        message: 'Test message',
        type: SnackbarType.info,
      );

      controller.showSnackbar(message);
      expect(controller.messageCount, 1);

      controller.hideSnackbar('test');
      expect(controller.messageCount, 0);
      expect(controller.hasMessages, false);
    });

    test('Spam prevention works', () {
      final message = BasicSnackbarMessage(
        id: 'spam_test',
        message: 'Spam test',
        type: SnackbarType.info,
      );

      controller.showSnackbar(message);
      expect(controller.messageCount, 1);

      // Try to show same message immediately
      controller.showSnackbar(message);
      expect(controller.messageCount, 1); // Should not add duplicate
    });

    test('Priority sorting works', () {
      final lowPriority = BasicSnackbarMessage(
        id: 'low',
        message: 'Low priority',
        type: SnackbarType.info,
        priority: SnackbarPriority.low,
      );

      final highPriority = BasicSnackbarMessage(
        id: 'high',
        message: 'High priority',
        type: SnackbarType.error,
        priority: SnackbarPriority.high,
      );

      controller.showSnackbar(lowPriority);
      controller.showSnackbar(highPriority);

      expect(controller.messages.first.id, 'high'); // High priority should be first
      expect(controller.messages.last.id, 'low');  // Low priority should be last
    });

    test('Group management works', () {
      final message1 = BasicSnackbarMessage(
        id: 'group1_msg1',
        message: 'Group 1 message 1',
        type: SnackbarType.info,
        groupId: 'group1',
      );

      final message2 = BasicSnackbarMessage(
        id: 'group1_msg2',
        message: 'Group 1 message 2',
        type: SnackbarType.success,
        groupId: 'group1',
      );

      controller.showSnackbar(message1);
      controller.showSnackbar(message2);

      expect(controller.messageCount, 2);

      controller.hideGroup('group1');
      expect(controller.messageCount, 0);
    });

    test('Clear all removes all messages', () {
      final message1 = BasicSnackbarMessage(
        id: 'msg1',
        message: 'Message 1',
        type: SnackbarType.info,
      );

      final message2 = BasicSnackbarMessage(
        id: 'msg2',
        message: 'Message 2',
        type: SnackbarType.success,
      );

      controller.showSnackbar(message1);
      controller.showSnackbar(message2);
      expect(controller.messageCount, 2);

      controller.clearAll();
      expect(controller.messageCount, 0);
      expect(controller.hasMessages, false);
    });

    test('Update message replaces existing message', () {
      final originalMessage = BasicSnackbarMessage(
        id: 'update_test',
        message: 'Original message',
        type: SnackbarType.info,
      );

      final updatedMessage = BasicSnackbarMessage(
        id: 'update_test',
        message: 'Updated message',
        type: SnackbarType.success,
      );

      controller.showSnackbar(originalMessage);
      expect(controller.messages.first.message, 'Original message');

      controller.updateMessage('update_test', updatedMessage);
      expect(controller.messageCount, 1); // Should still be only one message
      expect(controller.messages.first.message, 'Updated message');
    });
  });

  group('SnackbarAdapter', () {
    test('CustomSnackbarAdapter creation and initialization', () {
      bool initialized = false;
      
      final adapter = CustomSnackbarAdapter(
        id: 'test_adapter',
        initialize: (controller) {
          initialized = true;
        },
      );

      expect(adapter.id, 'test_adapter');
      
      final controller = SnackbarController();
      adapter.initialize(controller);
      expect(initialized, true);
    });

    test('CustomSnackbarAdapter with dispose', () {
      bool disposed = false;
      
      final adapter = CustomSnackbarAdapter(
        id: 'test_adapter',
        initialize: (controller) {},
        dispose: () {
          disposed = true;
        },
      );

      adapter.dispose();
      expect(disposed, true);
    });
  });

  group('SnackbarAdapterListExtension', () {
    late List<SnackbarAdapter> adapters;

    setUp(() {
      adapters = [
        CustomSnackbarAdapter(id: 'adapter1', initialize: (controller) {}),
        CustomSnackbarAdapter(id: 'adapter2', initialize: (controller) {}),
      ];
    });

    test('addIfNotExists adds new adapter', () {
      final newAdapter = CustomSnackbarAdapter(id: 'adapter3', initialize: (controller) {});
      final result = adapters.addIfNotExists(newAdapter);
      
      expect(result.length, 3);
      expect(result.last.id, 'adapter3');
    });

    test('addIfNotExists prevents duplicates', () {
      final duplicateAdapter = CustomSnackbarAdapter(id: 'adapter1', initialize: (controller) {});
      final result = adapters.addIfNotExists(duplicateAdapter);
      
      expect(result.length, 2); // Should not add duplicate
      expect(result, equals(adapters));
    });

    test('removeById removes adapter', () {
      final result = adapters.removeById('adapter1');
      
      expect(result.length, 1);
      expect(result.first.id, 'adapter2');
    });

    test('removeById returns original list if adapter not found', () {
      final result = adapters.removeById('nonexistent');
      
      expect(result.length, 2);
      expect(result, equals(adapters));
    });

    test('replace updates existing adapter', () {
      final updatedAdapter = CustomSnackbarAdapter(id: 'adapter1', initialize: (controller) {});
      final result = adapters.replace(updatedAdapter);
      
      expect(result.length, 2);
      expect(result.first.id, 'adapter1');
    });

    test('replace adds new adapter if not found', () {
      final newAdapter = CustomSnackbarAdapter(id: 'adapter3', initialize: (controller) {});
      final result = adapters.replace(newAdapter);
      
      expect(result.length, 3);
      expect(result.last.id, 'adapter3');
    });
  });

  group('SnackbarAdapterSets', () {
    test('basic set contains network adapter', () {
      expect(SnackbarAdapterSets.basic.length, 1);
      expect(SnackbarAdapterSets.basic.first.id, 'network_adapter');
    });

    test('minimal set contains network adapter', () {
      expect(SnackbarAdapterSets.minimal.length, 1);
      expect(SnackbarAdapterSets.minimal.first.id, 'network_adapter');
    });

    test('custom set creates new list', () {
      final customSet = SnackbarAdapterSets.custom([
        CustomSnackbarAdapter(id: 'custom1', initialize: (controller) {}),
        CustomSnackbarAdapter(id: 'custom2', initialize: (controller) {}),
      ]);
      
      expect(customSet.length, 2);
      expect(customSet.first.id, 'custom1');
      expect(customSet.last.id, 'custom2');
    });

    test('getById returns correct adapter', () {
      final adapter = SnackbarAdapterSets.getById('network_adapter');
      expect(adapter, isNotNull);
      expect(adapter!.id, 'network_adapter');
    });

    test('getById returns null for non-existent adapter', () {
      final adapter = SnackbarAdapterSets.getById('nonexistent');
      expect(adapter, isNull);
    });
  });

  group('NetworkSnackbarMessage', () {
    test('connectionLost factory creates correct message', () {
      final message = NetworkSnackbarMessage.connectionLost(() {});
      
      expect(message.id, 'network_lost');
      expect(message.message, 'Соединение потеряно');
      expect(message.type, SnackbarType.error);
      expect(message.priority, SnackbarPriority.critical);
      expect(message.groupId, 'network');
      expect(message.actions, isNotNull);
      expect(message.actions!.length, 1);
      expect(message.actions!.first.label, 'Повторить');
    });

    test('connectionRestored factory creates correct message', () {
      final message = NetworkSnackbarMessage.connectionRestored();
      
      expect(message.id, 'network_restored');
      expect(message.message, 'Соединение восстановлено');
      expect(message.type, SnackbarType.success);
      expect(message.priority, SnackbarPriority.normal);
      expect(message.groupId, 'network');
    });

    test('slowConnection factory creates correct message', () {
      final message = NetworkSnackbarMessage.slowConnection();
      
      expect(message.id, 'network_slow');
      expect(message.message, 'Медленное соединение');
      expect(message.type, SnackbarType.warning);
      expect(message.priority, SnackbarPriority.normal);
      expect(message.groupId, 'network');
    });
  });

  group('NetworkSnackbarAdapter', () {
    test('NetworkSnackbarAdapter has correct id', () {
      const adapter = NetworkSnackbarAdapter();
      expect(adapter.id, 'network_adapter');
    });

    test('NetworkSnackbarAdapter can be initialized', () {
      const adapter = NetworkSnackbarAdapter();
      final controller = SnackbarController();
      
      // Should not throw
      adapter.initialize(controller);
    });
  });

  group('SnackbarMessages', () {
    test('info creates correct message', () {
      final message = SnackbarMessages.info('Test info message');
      
      expect(message.message, 'Test info message');
      expect(message.type, SnackbarType.info);
      expect(message.priority, SnackbarPriority.normal);
      expect(message.persistent, false);
      expect(message.id.startsWith('info_'), true);
    });

    test('success creates correct message', () {
      final message = SnackbarMessages.success('Test success message');
      
      expect(message.message, 'Test success message');
      expect(message.type, SnackbarType.success);
      expect(message.duration, const Duration(seconds: 2));
      expect(message.id.startsWith('success_'), true);
    });

    test('error creates correct message', () {
      final actions = [
        SnackbarAction(label: 'Retry', onPressed: () {}),
      ];
      final message = SnackbarMessages.error(
        'Test error message',
        actions: actions,
      );
      
      expect(message.message, 'Test error message');
      expect(message.type, SnackbarType.error);
      expect(message.priority, SnackbarPriority.high);
      expect(message.duration, const Duration(seconds: 4));
      expect(message.actions, actions);
      expect(message.id.startsWith('error_'), true);
    });

    test('warning creates correct message', () {
      final message = SnackbarMessages.warning('Test warning message');
      
      expect(message.message, 'Test warning message');
      expect(message.type, SnackbarType.warning);
      expect(message.duration, const Duration(seconds: 3));
      expect(message.id.startsWith('warning_'), true);
    });

    test('loading creates correct message', () {
      final message = SnackbarMessages.loading(
        'Test loading message',
        customId: 'custom_loading',
      );
      
      expect(message.message, 'Test loading message');
      expect(message.type, SnackbarType.loading);
      expect(message.persistent, true);
      expect(message.id, 'custom_loading');
    });

    test('loading creates auto-generated ID when customId is null', () {
      final message = SnackbarMessages.loading('Test loading message');
      
      expect(message.id.startsWith('loading_'), true);
    });
  });

  group('SnackbarMixin', () {
    late SnackbarController controller;
    late TestWidgetWithMixin widget;

    setUp(() {
      controller = SnackbarController();
      widget = TestWidgetWithMixin();
    });

    test('showInfo shows info message', () {
      widget.showInfo(controller, 'Test info');
      
      expect(controller.messageCount, 1);
      expect(controller.messages.first.type, SnackbarType.info);
      expect(controller.messages.first.message, 'Test info');
    });

    test('showSuccess shows success message', () {
      widget.showSuccess(controller, 'Test success');
      
      expect(controller.messageCount, 1);
      expect(controller.messages.first.type, SnackbarType.success);
      expect(controller.messages.first.message, 'Test success');
    });

    test('showError shows error message', () {
      final actions = [SnackbarAction(label: 'Retry', onPressed: () {})];
      widget.showError(controller, 'Test error', actions: actions);
      
      expect(controller.messageCount, 1);
      expect(controller.messages.first.type, SnackbarType.error);
      expect(controller.messages.first.message, 'Test error');
      expect(controller.messages.first.actions, actions);
    });

    test('showWarning shows warning message', () {
      widget.showWarning(controller, 'Test warning');
      
      expect(controller.messageCount, 1);
      expect(controller.messages.first.type, SnackbarType.warning);
      expect(controller.messages.first.message, 'Test warning');
    });

    test('showLoading shows loading message', () {
      widget.showLoading(controller, 'Test loading', id: 'test_loading');
      
      expect(controller.messageCount, 1);
      expect(controller.messages.first.type, SnackbarType.loading);
      expect(controller.messages.first.message, 'Test loading');
      expect(controller.messages.first.id, 'test_loading');
      expect(controller.messages.first.persistent, true);
    });

    test('hideLoading removes loading message', () {
      widget.showLoading(controller, 'Test loading', id: 'test_loading');
      expect(controller.messageCount, 1);
      
      widget.hideLoading(controller, id: 'test_loading');
      expect(controller.messageCount, 0);
    });

    test('clearAllSnackbars clears all messages', () {
      widget.showInfo(controller, 'Info');
      widget.showSuccess(controller, 'Success');
      widget.showError(controller, 'Error');
      expect(controller.messageCount, 3);
      
      widget.clearAllSnackbars(controller);
      expect(controller.messageCount, 0);
    });
  });
}

/// Test class that uses SnackbarMixin for testing purposes
class TestWidgetWithMixin with SnackbarMixin {}
