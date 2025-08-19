import 'package:flutter/material.dart';
import 'snackbar_types.dart';

/// Абстрактный базовый класс для всех типов снэкбар-сообщений.
///
/// Определяет общую структуру и свойства для всех уведомлений в системе.
/// Содержит основные поля для идентификации, отображения и управления
/// жизненным циклом сообщений.
///
/// Наследники должны реализовать конкретную логику для различных типов
/// уведомлений (сетевые, синхронизация, обновления и т.д.).
///
/// ---
///
/// Abstract base class for all snackbar message types.
///
/// Defines common structure and properties for all notifications in the system.
/// Contains basic fields for identification, display and lifecycle management
/// of messages.
///
/// Inheritors should implement specific logic for different types
/// of notifications (network, sync, updates, etc.).
abstract class SnackbarMessage {
  /// Уникальный идентификатор сообщения.
  ///
  /// Используется для:
  /// - Предотвращения дублирования сообщений
  /// - Обновления существующих сообщений
  /// - Программного скрытия конкретного сообщения
  ///
  /// Рекомендуется использовать описательные имена, например:
  /// 'network_error', 'sync_progress', 'download_complete'
  ///
  /// ---
  ///
  /// Unique message identifier.
  ///
  /// Used for:
  /// - Preventing message duplication
  /// - Updating existing messages
  /// - Programmatic hiding of specific message
  ///
  /// Recommended to use descriptive names, e.g.:
  /// 'network_error', 'sync_progress', 'download_complete'
  final String id;

  /// Текст сообщения для отображения пользователю.
  ///
  /// ---
  ///
  /// Message text to display to user.
  final String message;

  /// Тип сообщения, определяющий его внешний вид и поведение.
  ///
  /// Влияет на:
  /// - Цвет фона и иконку
  /// - Время автоматического скрытия
  ///
  /// ---
  ///
  /// Message type that determines its appearance and behavior.
  ///
  /// Affects:
  /// - Background color and icon
  /// - Auto-hide duration
  final SnackbarType type;

  /// Время отображения сообщения перед автоматическим скрытием.
  ///
  /// Если не указано, используется значение по умолчанию для данного типа:
  /// - info: 2 секунды
  /// - success: 2 секунды
  /// - warning: 3 секунды
  /// - error: 4 секунды
  /// - loading: бесконечно (пока не скрыто вручную)
  ///
  /// Null означает, что сообщение не будет скрыто автоматически.
  ///
  /// ---
  ///
  /// Display duration before automatic hiding.
  ///
  /// If not specified, default value for the type is used:
  /// - info: 2 seconds
  /// - success: 2 seconds
  /// - warning: 3 seconds
  /// - error: 4 seconds
  /// - loading: infinite (until manually hidden)
  ///
  /// Null means message won't be hidden automatically.
  final Duration? duration;

  /// Пользовательская иконка для отображения в сообщении.
  ///
  /// Если не указана, используется иконка по умолчанию для данного типа:
  /// - info: Icons.info
  /// - success: Icons.check_circle
  /// - warning: Icons.warning
  /// - error: Icons.error
  /// - loading: CircularProgressIndicator
  ///
  /// ---
  ///
  /// Custom icon to display in message.
  ///
  /// If not specified, default icon for the type is used:
  /// - info: Icons.info
  /// - success: Icons.check_circle
  /// - warning: Icons.warning
  /// - error: Icons.error
  /// - loading: CircularProgressIndicator
  final Widget? icon;

  /// Приоритет сообщения для определения порядка отображения.
  ///
  /// Сообщения с более высоким приоритетом отображаются выше.
  ///
  /// Приоритеты по убыванию:
  /// - critical: критические ошибки, требующие немедленного внимания
  /// - high: важные уведомления
  /// - normal: обычные сообщения (по умолчанию)
  /// - low: второстепенная информация
  ///
  /// ---
  ///
  /// Message priority for display order determination.
  ///
  /// Messages with higher priority are displayed above others.
  ///
  /// Priorities in descending order:
  /// - critical: critical errors requiring immediate attention
  /// - high: important notifications
  /// - normal: regular messages (default)
  /// - low: secondary information
  final SnackbarPriority priority;

  /// Определяет, должно ли сообщение оставаться на экране постоянно.
  ///
  /// Если true:
  /// - Сообщение не скрывается автоматически по таймеру
  /// - Показывается кнопка закрытия для ручного скрытия
  /// - Остается видимым при навигации между экранами
  ///
  /// Используется для:
  /// - Процессов загрузки/синхронизации
  /// - Критических ошибок
  /// - Важных уведомлений, требующих действий пользователя
  ///
  /// ---
  ///
  /// Determines if message should remain on screen permanently.
  ///
  /// If true:
  /// - Message is not auto-hidden by timer
  /// - Close button is shown for manual hiding
  /// - Remains visible when navigating between screens
  ///
  /// Used for:
  /// - Loading/sync processes
  /// - Critical errors
  /// - Important notifications requiring user action
  final bool persistent;

  /// Список интерактивных действий (кнопок) в сообщении.
  ///
  /// Позволяет пользователю выполнить связанные действия прямо
  /// из уведомления без перехода на другой экран.
  ///
  /// Примеры использования:
  /// - "Повторить" для ошибок сети
  /// - "Отменить" для процессов загрузки
  /// - "Обновить" для уведомлений о новых версиях
  /// - "Подробнее" для информационных сообщений
  ///
  /// ---
  ///
  /// List of interactive actions (buttons) in message.
  ///
  /// Allows user to perform related actions directly
  /// from notification without navigating to another screen.
  ///
  /// Usage examples:
  /// - "Retry" for network errors
  /// - "Cancel" for download processes
  /// - "Update" for new version notifications
  /// - "Learn more" for informational messages
  final List<SnackbarAction>? actions;

  /// Идентификатор группы для связанных сообщений.
  ///
  /// Позволяет группировать связанные уведомления и управлять ими
  /// как единым целым. Полезно для:
  ///
  /// - Сетевых операций ('network')
  /// - Синхронизации данных ('sync')
  /// - Процессов обновления ('updates')
  /// - Загрузки файлов ('downloads')
  ///
  /// Сообщения в одной группе могут заменять друг друга или
  /// ограничиваться по количеству одновременно показываемых.
  ///
  /// ---
  ///
  /// Group identifier for related messages.
  ///
  /// Allows grouping related notifications and managing them
  /// as a single unit. Useful for:
  ///
  /// - Network operations ('network')
  /// - Data synchronization ('sync')
  /// - Update processes ('updates')
  /// - File downloads ('downloads')
  ///
  /// Messages in same group can replace each other or
  /// be limited by concurrent display count.
  final String? groupId;

  /// Создает новое снэкбар-сообщение с заданными параметрами.
  ///
  /// Обязательные параметры:
  /// - [id] - уникальный идентификатор
  /// - [message] - текст для отображения
  /// - [type] - тип сообщения
  ///
  /// ---
  ///
  /// Creates new snackbar message with given parameters.
  ///
  /// Required parameters:
  /// - [id] - unique identifier
  /// - [message] - text to display
  /// - [type] - message type
  const SnackbarMessage({
    required this.id,
    required this.message,
    required this.type,
    this.duration,
    this.icon,
    this.priority = SnackbarPriority.normal,
    this.persistent = false,
    this.actions,
    this.groupId,
  });
}

/// Базовая реализация [SnackbarMessage] для простых уведомлений.
///
/// Предоставляет конкретную реализацию абстрактного класса [SnackbarMessage]
/// без дополнительной логики. Подходит для создания обычных уведомлений,
/// когда не требуется специализированное поведение.
///
/// Для более сложных сценариев рекомендуется создавать специализированные
/// классы (например, NetworkSnackbarMessage, SyncSnackbarMessage).
///
/// ---
///
/// Basic [SnackbarMessage] implementation for simple notifications.
///
/// Provides concrete implementation of abstract [SnackbarMessage] class
/// without additional logic. Suitable for creating regular notifications
/// when specialized behavior is not required.
///
/// For more complex scenarios, it's recommended to create specialized
/// classes (e.g., NetworkSnackbarMessage, SyncSnackbarMessage).
class BasicSnackbarMessage extends SnackbarMessage {
  /// Создает базовое снэкбар-сообщение.
  ///
  /// Принимает все те же параметры, что и родительский класс,
  /// и передает их без изменений. Используется как простая
  /// конкретная реализация для обычных уведомлений.
  ///
  /// Пример использования:
  /// ```dart
  /// final message = BasicSnackbarMessage(
  ///   id: 'welcome',
  ///   message: 'Добро пожаловать в приложение!',
  ///   type: SnackbarType.info,
  ///   duration: Duration(seconds: 3),
  /// );
  /// ```
  ///
  /// ---
  ///
  /// Creates basic snackbar message.
  ///
  /// Accepts all same parameters as parent class
  /// and passes them unchanged. Used as simple
  /// concrete implementation for regular notifications.
  ///
  /// Usage example:
  /// ```dart
  /// final message = BasicSnackbarMessage(
  ///   id: 'welcome',
  ///   message: 'Welcome to the app!',
  ///   type: SnackbarType.info,
  ///   duration: Duration(seconds: 3),
  /// );
  /// ```
  const BasicSnackbarMessage({
    required super.id,
    required super.message,
    required super.type,
    super.duration,
    super.icon,
    super.priority,
    super.persistent,
    super.actions,
    super.groupId,
  });
}
