import 'package:flutter/material.dart';
import 'snackbar_message.dart';

/// Состояние для управления снэкбарами.
/// Хранит список сообщений и время их последнего показа.
///
/// ---
///
/// State for managing snackbars.
/// Stores a list of messages and their last shown times.
class SnackbarState {
  /// Список сообщений для отображения
  ///
  /// ---
  ///
  /// List of messages to display
  final List<SnackbarMessage> messages;

  /// Время последнего показа сообщений (ключ - ID сообщения).
  /// Для предотвращения частого повтора одинаковых сообщений
  ///
  /// ---
  ///
  /// Last shown times of messages (key - message ID).
  /// Used to prevent showing duplicate messages too frequently
  final Map<String, DateTime> lastShownTimes;

  const SnackbarState({
    this.messages = const [],
    this.lastShownTimes = const {},
  });

  SnackbarState copyWith({
    List<SnackbarMessage>? messages,
    Map<String, DateTime>? lastShownTimes,
  }) =>
      SnackbarState(
        messages: messages ?? this.messages,
        lastShownTimes: lastShownTimes ?? this.lastShownTimes,
      );

  /// Возвращает сообщения, отсортированные по приоритету и времени.
  ///
  /// Алгоритм сортировки:
  /// 1. По приоритету (критические → высокие → обычные → низкие)
  /// 2. По времени добавления (новые сообщения выше старых)
  ///
  /// Это обеспечивает отображение важных сообщений в верхней части списка.
  ///
  /// ---
  ///
  /// Returns messages sorted by priority and time.
  ///
  /// Sorting algorithm:
  /// 1. By priority (critical → high → normal → low)
  /// 2. By insertion time (newer messages above older ones)
  ///
  /// This ensures important messages are displayed at the top of the list.
  List<SnackbarMessage> get sortedMessages {
    final sorted = List<SnackbarMessage>.from(messages);
    sorted.sort((a, b) {
      // Сначала по приоритету (убывающий)
      // First by priority (descending)
      final priorityCompare = b.priority.value.compareTo(a.priority.value);
      if (priorityCompare != 0) return priorityCompare;

      // Затем по времени добавления (новые сверху)
      // Then by insertion time (newer first)
      return messages.indexOf(b).compareTo(messages.indexOf(a));
    });
    return sorted;
  }

  /// Группирует сообщения по идентификатору группы.
  ///
  /// Возвращает карту, где:
  /// - Ключ: groupId сообщения (может быть null для несгруппированных)
  /// - Значение: список сообщений этой группы, отсортированный по приоритету
  ///
  /// Полезно для:
  /// - Управления связанными уведомлениями (сеть, синхронизация)
  /// - Группового скрытия сообщений
  /// - Ограничения количества сообщений в группе
  ///
  /// ---
  ///
  /// Groups messages by group identifier.
  ///
  /// Returns a map where:
  /// - Key: message groupId (can be null for ungrouped messages)
  /// - Value: list of messages in this group, sorted by priority
  ///
  /// Useful for:
  /// - Managing related notifications (network, sync)
  /// - Group message hiding
  /// - Limiting messages count per group
  Map<String?, List<SnackbarMessage>> get groupedMessages {
    final Map<String?, List<SnackbarMessage>> groups = {};
    for (final message in sortedMessages) {
      final group = message.groupId;
      groups[group] = [...(groups[group] ?? []), message];
    }
    return groups;
  }
}

/// Контроллер для управления снэкбарами.
///
/// Основные возможности:
/// - Показ и скрытие снэкбаров
/// - Управление приоритетами сообщений
/// - Предотвращение спама одинаковых сообщений
/// - Ограничение количества одновременно показываемых сообщений
/// - Группировка связанных уведомлений
///
/// Использует паттерн [ChangeNotifier] для реактивного управления состоянием.
///
/// ---
///
/// Controller for managing snackbars.
///
/// Main features:
/// - Show and hide snackbars
/// - Message priority management
/// - Spam prevention for duplicate messages
/// - Limit concurrent message count
/// - Group related notifications
///
/// Uses [ChangeNotifier] pattern for reactive state management.
class SnackbarController extends ChangeNotifier {
  SnackbarState _state = const SnackbarState();

  /// Текущее состояние контроллера
  SnackbarState get state => _state;

  /// Список сообщений, отсортированный по приоритету
  List<SnackbarMessage> get messages => _state.sortedMessages;

  /// Количество активных сообщений
  int get messageCount => _state.messages.length;

  /// Проверяет, есть ли активные сообщения
  bool get hasMessages => _state.messages.isNotEmpty;

  /// Настройки для предотвращения спама сообщений.
  ///
  /// - [_spamPreventionDuration] - минимальный интервал между показом
  ///   одинаковых сообщений (2 секунды)
  /// - [_maxMessagesPerGroup] - максимальное количество сообщений
  ///   в одной группе (3 сообщения)
  /// - [_maxTotalMessages] - общее максимальное количество сообщений
  ///   на экране (10 сообщений)
  ///
  /// ---
  ///
  /// Settings for message spam prevention.
  ///
  /// - [_spamPreventionDuration] - minimum interval between showing
  ///   identical messages (2 seconds)
  /// - [_maxMessagesPerGroup] - maximum messages per group (3 messages)
  /// - [_maxTotalMessages] - total maximum messages on screen (10 messages)
  static const Duration _spamPreventionDuration = Duration(seconds: 2);
  static const int _maxMessagesPerGroup = 3;
  static const int _maxTotalMessages = 10;

  /// Показывает снэкбар с заданным сообщением.
  ///
  /// Выполняет следующие проверки и операции:
  /// 1. Проверка на спам (частое повторение одного сообщения)
  /// 2. Удаление предыдущего сообщения с тем же ID
  /// 3. Ограничение количества сообщений в группе
  /// 4. Ограничение общего количества сообщений
  /// 5. Добавление нового сообщения в состояние
  ///
  /// Параметры:
  /// - [message] - сообщение для отображения
  ///
  /// Пример:
  /// ```dart
  /// controller.showSnackbar(SnackbarMessage(
  ///   id: 'success',
  ///   message: 'Операция выполнена успешно',
  ///   type: SnackbarType.success,
  /// ));
  /// ```
  ///
  /// ---
  ///
  /// Shows snackbar with given message.
  ///
  /// Performs the following checks and operations:
  /// 1. Spam check (frequent repetition of same message)
  /// 2. Remove previous message with same ID
  /// 3. Limit messages count per group
  /// 4. Limit total messages count
  /// 5. Add new message to state
  ///
  /// Parameters:
  /// - [message] - message to display
  ///
  /// Example:
  /// ```dart
  /// controller.showSnackbar(SnackbarMessage(
  ///   id: 'success',
  ///   message: 'Operation completed successfully',
  ///   type: SnackbarType.success,
  /// ));
  /// ```
  void showSnackbar(SnackbarMessage message) {
    if (_isSpam(message)) {
      return;
    }

    // Удаляем предыдущее сообщение с тем же id
    // Remove previous message with same id
    var filteredMessages = _state.messages.where((m) => m.id != message.id).toList();

    // Ограничиваем количество сообщений в группе
    // Limit messages count per group
    if (message.groupId != null) {
      final groupMessages = filteredMessages.where((m) => m.groupId == message.groupId).toList();
      if (groupMessages.length >= _maxMessagesPerGroup) {
        // Удаляем самое старое сообщение из группы
        // Remove oldest message in group
        final oldestInGroup = groupMessages.first;
        filteredMessages.removeWhere((m) => m.id == oldestInGroup.id);
      }
    }

    // Ограничиваем общее количество сообщений
    // Limit total messages
    if (filteredMessages.length >= _maxTotalMessages) {
      // Удаляем самые старые сообщения с низким приоритетом
      // Remove oldest low-priority messages
      filteredMessages.sort((a, b) => a.priority.value.compareTo(b.priority.value));
      filteredMessages = filteredMessages.skip(1).toList();
    }

    // Добавляем новое сообщение и обновляем время показа
    // Add new message and update shown time
    final newLastShownTimes = Map<String, DateTime>.from(_state.lastShownTimes);
    newLastShownTimes[message.id] = DateTime.now();
    
    _state = _state.copyWith(
      messages: [...filteredMessages, message],
      lastShownTimes: newLastShownTimes,
    );
    
    notifyListeners();
  }

  /// Скрывает снэкбар по идентификатору.
  ///
  /// Удаляет сообщение с указанным ID из списка активных сообщений.
  /// Если сообщение не найдено, метод ничего не делает.
  ///
  /// Параметры:
  /// - [id] - идентификатор сообщения для скрытия
  ///
  /// Пример:
  /// ```dart
  /// controller.hideSnackbar('loading_message');
  /// ```
  ///
  /// ---
  ///
  /// Hides snackbar by identifier.
  ///
  /// Removes message with specified ID from active messages list.
  /// If message is not found, method does nothing.
  ///
  /// Parameters:
  /// - [id] - identifier of message to hide
  ///
  /// Example:
  /// ```dart
  /// controller.hideSnackbar('loading_message');
  /// ```
  void hideSnackbar(String id) {
    final filteredMessages = _state.messages.where((m) => m.id != id).toList();
    _state = _state.copyWith(messages: filteredMessages);
    notifyListeners();
  }

  /// Скрывает все снэкбары в указанной группе.
  ///
  /// Удаляет все сообщения с указанным groupId из списка активных сообщений.
  /// Полезно для массового скрытия связанных уведомлений
  /// (например, все сетевые уведомления или уведомления синхронизации).
  ///
  /// Параметры:
  /// - [groupId] - идентификатор группы для скрытия
  ///
  /// Пример:
  /// ```dart
  /// // Скрыть все сетевые уведомления
  /// controller.hideGroup('network');
  /// ```
  ///
  /// ---
  ///
  /// Hides all snackbars in specified group.
  ///
  /// Removes all messages with specified groupId from active messages list.
  /// Useful for bulk hiding of related notifications
  /// (e.g., all network notifications or sync notifications).
  ///
  /// Parameters:
  /// - [groupId] - group identifier to hide
  ///
  /// Example:
  /// ```dart
  /// // Hide all network notifications
  /// controller.hideGroup('network');
  /// ```
  void hideGroup(String groupId) {
    final filteredMessages = _state.messages.where((m) => m.groupId != groupId).toList();
    _state = _state.copyWith(messages: filteredMessages);
    notifyListeners();
  }

  /// Очищает все снэкбары.
  ///
  /// Полностью сбрасывает состояние, удаляя все активные сообщения
  /// и историю времен показа. Используется для полной очистки интерфейса.
  ///
  /// Пример:
  /// ```dart
  /// // Очистить все уведомления при выходе из приложения
  /// controller.clearAll();
  /// ```
  ///
  /// ---
  ///
  /// Clears all snackbars.
  ///
  /// Completely resets state, removing all active messages
  /// and shown times history. Used for complete UI cleanup.
  ///
  /// Example:
  /// ```dart
  /// // Clear all notifications when exiting app
  /// controller.clearAll();
  /// ```
  void clearAll() {
    _state = const SnackbarState();
    notifyListeners();
  }

  /// Очищает все непостоянные (non-persistent) снэкбары, оставляя только персистентные.
  ///
  /// Метод фильтрует текущий список сообщений, удаляя все сообщения
  /// с `persistent = false` и сохраняя только те, у которых `persistent = true`.
  ///
  /// Полезно для:
  /// - Очистки временных уведомлений при смене экрана
  /// - Удаления старых сообщений после обновления данных
  /// - Периодической очистки UI от накопившихся уведомлений
  ///
  /// Персистентные сообщения (загрузки, критические ошибки) остаются видимыми.
  ///
  /// Пример использования:
  /// ```dart
  /// // При переходе на новый экран
  /// controller.clearNonPersistent();
  /// ```
  ///
  /// ---
  ///
  /// Clears all non-persistent snackbars, keeping only persistent ones.
  ///
  /// This method filters the current message list, removing all messages
  /// with `persistent = false` and keeping only those with `persistent = true`.
  ///
  /// Useful for:
  /// - Clearing temporary notifications when changing screens
  /// - Removing old messages after data updates
  /// - Periodic UI cleanup from accumulated notifications
  ///
  /// Persistent messages (downloads, critical errors) remain visible.
  ///
  /// Usage example:
  /// ```dart
  /// // When navigating to a new screen
  /// controller.clearNonPersistent();
  /// ```
  void clearNonPersistent() {
    final persistentMessages = _state.messages.where((m) => m.persistent).toList();
    _state = _state.copyWith(messages: persistentMessages);
    notifyListeners();
  }

  /// Проверяет, является ли сообщение спамом.
  ///
  /// Сообщение считается спамом, если оно показывалось слишком часто
  /// (интервал между показами меньше [_spamPreventionDuration]).
  ///
  /// Алгоритм:
  /// 1. Получает время последнего показа сообщения по его ID
  /// 2. Если сообщение показывается впервые, возвращает false
  /// 3. Сравнивает текущее время с временем последнего показа
  /// 4. Если разница меньше порогового значения, возвращает true (спам)
  ///
  /// Параметры:
  /// - [message] - сообщение для проверки
  ///
  /// Возвращает: true если сообщение является спамом, false - иначе
  ///
  /// ---
  ///
  /// Checks if message is spam.
  ///
  /// Message is considered spam if it was shown too frequently
  /// (interval between shows is less than [_spamPreventionDuration]).
  ///
  /// Algorithm:
  /// 1. Gets last shown time of message by its ID
  /// 2. If message is shown for first time, returns false
  /// 3. Compares current time with last shown time
  /// 4. If difference is less than threshold, returns true (spam)
  ///
  /// Parameters:
  /// - [message] - message to check
  ///
  /// Returns: true if message is spam, false otherwise
  bool _isSpam(SnackbarMessage message) {
    final lastShown = _state.lastShownTimes[message.id];
    if (lastShown == null) return false;

    return DateTime.now().difference(lastShown) < _spamPreventionDuration;
  }
}

/// Расширения для удобства использования [SnackbarController].
///
/// Предоставляет дополнительные методы для массовых операций
/// и управления группами снэкбаров.
///
/// ---
///
/// Extensions for convenient [SnackbarController] usage.
///
/// Provides additional methods for bulk operations
/// and snackbar group management.
extension SnackbarControllerExtensions on SnackbarController {
  /// Показывает несколько снэкбаров одновременно.
  ///
  /// Последовательно вызывает `showSnackbar()` для каждого сообщения в списке.
  /// Сообщения будут отображены в порядке их приоритета и времени добавления.
  ///
  /// Параметры:
  /// - [messages] - список сообщений для отображения
  ///
  /// Пример использования:
  /// ```dart
  /// controller.showMultiple([
  ///   SnackbarMessage(id: 'msg1', message: 'Первое', type: SnackbarType.info),
  ///   SnackbarMessage(id: 'msg2', message: 'Второе', type: SnackbarType.success),
  /// ]);
  /// ```
  ///
  /// ---
  ///
  /// Shows multiple snackbars simultaneously.
  ///
  /// Sequentially calls `showSnackbar()` for each message in the list.
  /// Messages will be displayed according to their priority and addition time.
  ///
  /// Parameters:
  /// - [messages] - list of messages to display
  ///
  /// Usage example:
  /// ```dart
  /// controller.showMultiple([
  ///   SnackbarMessage(id: 'msg1', message: 'First', type: SnackbarType.info),
  ///   SnackbarMessage(id: 'msg2', message: 'Second', type: SnackbarType.success),
  /// ]);
  /// ```
  void showMultiple(List<SnackbarMessage> messages) {
    for (final message in messages) {
      showSnackbar(message);
    }
  }

  /// Обновляет существующее сообщение новым содержимым.
  ///
  /// Если сообщение с указанным ID существует, оно заменяется новым.
  /// Если сообщение не найдено, новое сообщение просто добавляется.
  ///
  /// Параметры:
  /// - [id] - идентификатор сообщения для обновления
  /// - [newMessage] - новое сообщение для отображения
  ///
  /// Пример использования:
  /// ```dart
  /// // Обновляем прогресс загрузки
  /// controller.updateMessage('download_progress',
  ///   SnackbarMessage(
  ///     id: 'download_progress',
  ///     message: 'Загрузка... 75%',
  ///     type: SnackbarType.loading,
  ///   ),
  /// );
  /// ```
  ///
  /// ---
  ///
  /// Updates an existing message with new content.
  ///
  /// If a message with the specified ID exists, it is replaced with the new one.
  /// If the message is not found, the new message is simply added.
  ///
  /// Parameters:
  /// - [id] - identifier of the message to update
  /// - [newMessage] - new message to display
  ///
  /// Usage example:
  /// ```dart
  /// // Update download progress
  /// controller.updateMessage('download_progress',
  ///   SnackbarMessage(
  ///     id: 'download_progress',
  ///     message: 'Loading... 75%',
  ///     type: SnackbarType.loading,
  ///   ),
  /// );
  /// ```
  void updateMessage(String id, SnackbarMessage newMessage) {
    // Удаляем предыдущее сообщение с тем же id
    var filteredMessages = _state.messages.where((m) => m.id != id).toList();
    
    // Добавляем новое сообщение
    _state = _state.copyWith(messages: [...filteredMessages, newMessage]);
    
    // Обновляем время показа
    final newLastShownTimes = Map<String, DateTime>.from(_state.lastShownTimes);
    newLastShownTimes[newMessage.id] = DateTime.now();
    _state = _state.copyWith(lastShownTimes: newLastShownTimes);
    
    notifyListeners();
  }

  /// Заменяет все сообщения в группе новым набором сообщений.
  ///
  /// Сначала скрывает все существующие сообщения с указанным `groupId`,
  /// затем показывает новые сообщения. Полезно для обновления статуса
  /// группы операций (например, синхронизация, сетевые операции).
  ///
  /// Параметры:
  /// - [groupId] - идентификатор группы для замены
  /// - [newMessages] - новые сообщения для группы
  ///
  /// Пример использования:
  /// ```dart
  /// // Заменяем все сетевые уведомления новым статусом
  /// controller.replaceGroup('network', [
  ///   NetworkSnackbarMessage.connectionRestored(),
  /// ]);
  /// ```
  ///
  /// ---
  ///
  /// Replaces all messages in a group with a new set of messages.
  ///
  /// First hides all existing messages with the specified `groupId`,
  /// then shows new messages. Useful for updating the status
  /// of operation groups (e.g., sync, network operations).
  ///
  /// Parameters:
  /// - [groupId] - group identifier to replace
  /// - [newMessages] - new messages for the group
  ///
  /// Usage example:
  /// ```dart
  /// // Replace all network notifications with new status
  /// controller.replaceGroup('network', [
  ///   NetworkSnackbarMessage.connectionRestored(),
  /// ]);
  /// ```
  void replaceGroup(String groupId, List<SnackbarMessage> newMessages) {
    hideGroup(groupId);
    showMultiple(newMessages);
  }
}
