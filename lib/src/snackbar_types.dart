import 'package:flutter/material.dart';

/// Перечисление типов снэкбар-сообщений.
///
/// Каждый тип имеет свои визуальные характеристики
/// и время автоматического скрытия
///
/// ---
///
/// Enumeration of snackbar message types.
///
/// Each type has its visual characteristics
/// and auto-hide duration
enum SnackbarType {
  /// Информационное сообщение.
  /// Используется для нейтральной информации, подсказок, статусов.
  ///
  /// Information message.
  /// Used for neutral information, hints, statuses.
  info,

  /// Сообщение об успехе.
  /// Используется для подтверждения успешных операций.
  ///
  /// Success message.
  /// Used to confirm successful operations.
  success,

  /// Предупреждение.
  /// Используется для потенциальных проблем, которые не блокируют работу.
  ///
  /// Warning message.
  /// Used for potential issues that don't block functionality.
  warning,

  /// Сообщение об ошибке.
  /// Используется для критических ошибок и проблем.
  ///
  /// Error message.
  /// Used for critical errors and problems.
  error,

  /// Сообщение о загрузке.
  /// Используется для отображения процессов, требующих времени.
  ///
  /// Loading message.
  /// Used to display time-consuming processes.
  loading,
}

/// Перечисление приоритетов снэкбар-сообщений.
///
/// Определяет важность сообщения и влияет на:
/// - Порядок отображения (высокий приоритет выше)
/// - Поведение при превышении лимитов сообщений
///
/// ---
///
/// Enumeration of snackbar message priorities.
///
/// Determines message importance and affects:
/// - Display order (high priority above others)
/// - Behavior when message limits are exceeded
enum SnackbarPriority {
  /// Низкий приоритет (значение 0).
  /// Для второстепенной информации, которая может быть пропущена.
  ///
  /// Low priority (value 0).
  /// For secondary information that can be missed.
  low(0),

  /// Обычный приоритет (значение 1).
  /// Для стандартных уведомлений и информационных сообщений.
  ///
  /// Normal priority (value 1).
  /// For standard notifications and informational messages.
  normal(1),

  /// Высокий приоритет (значение 2).
  /// Для важных уведомлений, требующих внимания пользователя.
  ///
  /// High priority (value 2).
  /// For important notifications requiring user attention.
  high(2),

  /// Критический приоритет (значение 3).
  /// Для критических ошибок и ситуаций, требующих немедленных действий.
  ///
  /// Critical priority (value 3).
  /// For critical errors and situations requiring immediate action.
  critical(3);

  const SnackbarPriority(this.value);

  /// Числовое значение приоритета для сравнения и сортировки.
  /// Большее значение означает более высокий приоритет.
  ///
  /// Numeric priority value for comparison and sorting.
  /// Higher value means higher priority.
  final int value;
}

/// Класс для интерактивных действий в снэкбар-сообщениях.
///
/// Представляет кнопку с текстом и обработчиком нажатия,
/// которая отображается внутри снэкбара для выполнения
/// связанных с уведомлением действий.
///
/// ---
///
/// Class for interactive actions in snackbar messages.
///
/// Represents a button with text and tap handler,
/// displayed inside snackbar to perform
/// notification-related actions.
class SnackbarAction {
  /// Текст кнопки действия.
  ///
  /// ---
  ///
  /// Action button text.
  final String label;

  /// Обработчик нажатия на кнопку действия.
  ///
  /// Вызывается при нажатии пользователем на кнопку.
  /// Может выполнять любые действия: навигацию, API-вызовы,
  /// изменение состояния приложения и т.д.
  ///
  /// После выполнения действия снэкбар может быть автоматически
  /// скрыт (зависит от настройки persistent).
  ///
  /// ---
  ///
  /// Action button tap handler.
  ///
  /// Called when user taps the button.
  /// Can perform any actions: navigation, API calls,
  /// app state changes, etc.
  ///
  /// After action execution snackbar may be automatically
  /// hidden (depends on persistent setting).
  final VoidCallback onPressed;

  /// Цвет текста кнопки действия.
  ///
  /// Если не указан, используется цвет по умолчанию.
  /// Можно использовать для выделения основного действия или
  /// создания визуальной иерархии между действиями.
  ///
  /// ---
  ///
  /// Action button text color.
  ///
  /// If not specified, default color is used.
  /// Can be used to highlight primary action or
  /// create visual hierarchy between actions.
  final Color? textColor;

  /// Создает новое действие для снэкбар-сообщения.
  ///
  /// Обязательные параметры:
  /// - [label] - текст кнопки
  /// - [onPressed] - обработчик нажатия
  ///
  /// Пример:
  /// ```dart
  /// SnackbarAction(
  ///   label: 'Повторить',
  ///   onPressed: () => retryOperation(),
  ///   textColor: Colors.yellow,
  /// )
  /// ```
  ///
  /// ---
  ///
  /// Creates new action for snackbar message.
  ///
  /// Required parameters:
  /// - [label] - button text
  /// - [onPressed] - tap handler
  ///
  /// Example:
  /// ```dart
  /// SnackbarAction(
  ///   label: 'Retry',
  ///   onPressed: () => retryOperation(),
  ///   textColor: Colors.yellow,
  /// )
  /// ```
  const SnackbarAction({
    required this.label,
    required this.onPressed,
    this.textColor,
  });
}
