import '../snackbar_adapters.dart';
import 'network_adapter.dart';

/// Наборы предустановленных адаптеров для различных сценариев использования.
///
/// Предоставляет готовые комбинации адаптеров для быстрого старта
/// без необходимости настройки каждого адаптера отдельно.
///
/// ---
///
/// Sets of predefined adapters for various usage scenarios.
///
/// Provides ready-made adapter combinations for quick start
/// without needing to configure each adapter separately.
class SnackbarAdapterSets {
  /// Базовый набор адаптеров.
  ///
  /// Включает:
  /// - Сетевой адаптер (мониторинг подключения к интернету)
  ///
  /// Подходит для простых приложений с минимальными требованиями
  /// к уведомлениям.
  ///
  /// ---
  ///
  /// Basic adapter set.
  ///
  /// Includes:
  /// - Network adapter (internet connection monitoring)
  ///
  /// Suitable for simple apps with minimal notification requirements.
  static const List<SnackbarAdapter> basic = [
    NetworkSnackbarAdapter(),
  ];

  /// Расширенный набор адаптеров.
  ///
  /// Включает:
  /// - Сетевой адаптер
  /// - Адаптер синхронизации (когда будет реализован)
  /// - Адаптер обновлений (когда будет реализован)
  /// - Адаптер аутентификации (когда будет реализован)
  ///
  /// Подходит для полнофункциональных приложений с богатой
  /// системой уведомлений.
  ///
  /// ---
  ///
  /// Extended adapter set.
  ///
  /// Includes:
  /// - Network adapter
  /// - Sync adapter (when implemented)
  /// - Update adapter (when implemented)
  /// - Auth adapter (when implemented)
  ///
  /// Suitable for full-featured apps with rich notification system.
  static const List<SnackbarAdapter> advanced = [
    NetworkSnackbarAdapter(),
    // TODO: Add SyncSnackbarAdapter when implemented
    // TODO: Add UpdateSnackbarAdapter when implemented
    // TODO: Add AuthSnackbarAdapter when implemented
  ];

  /// Полный набор адаптеров.
  ///
  /// Включает все доступные адаптеры для максимальной
  /// функциональности системы уведомлений.
  ///
  /// ---
  ///
  /// Complete adapter set.
  ///
  /// Includes all available adapters for maximum
  /// notification system functionality.
  static const List<SnackbarAdapter> complete = [
    NetworkSnackbarAdapter(),
    // TODO: Add SyncSnackbarAdapter when implemented
    // TODO: Add UpdateSnackbarAdapter when implemented
    // TODO: Add AuthSnackbarAdapter when implemented
  ];

  /// Минимальный набор адаптеров.
  ///
  /// Включает только сетевой адаптер для критически важных
  /// уведомлений о состоянии подключения.
  ///
  /// ---
  ///
  /// Minimal adapter set.
  ///
  /// Includes only network adapter for critically important
  /// connection state notifications.
  static const List<SnackbarAdapter> minimal = [
    NetworkSnackbarAdapter(),
  ];

  /// Набор адаптеров без синхронизации.
  ///
  /// Включает адаптеры для сетевых операций и аутентификации,
  /// но исключает синхронизацию данных.
  ///
  /// ---
  ///
  /// Adapter set without synchronization.
  ///
  /// Includes adapters for network operations and authentication,
  /// but excludes data synchronization.
  static const List<SnackbarAdapter> noSync = [
    NetworkSnackbarAdapter(),
    // TODO: Add AuthSnackbarAdapter when implemented
  ];

  /// Создает пользовательский набор адаптеров.
  ///
  /// Позволяет комбинировать адаптеры по своему усмотрению
  /// для создания специализированных конфигураций.
  ///
  /// Параметры:
  /// - [adapters] - список адаптеров для включения в набор
  ///
  /// Возвращает: новый список адаптеров
  ///
  /// Пример использования:
  /// ```dart
  /// final customSet = SnackbarAdapterSets.custom([
  ///   NetworkSnackbarAdapter(),
  ///   CustomSnackbarAdapter(
  ///     id: 'custom_monitor',
  ///     initialize: (controller) {
  ///       // Пользовательская логика
  ///     },
  ///   ),
  /// ]);
  /// ```
  ///
  /// ---
  ///
  /// Creates custom adapter set.
  ///
  /// Allows combining adapters at your discretion
  /// to create specialized configurations.
  ///
  /// Parameters:
  /// - [adapters] - list of adapters to include in set
  ///
  /// Returns: new list of adapters
  ///
  /// Usage example:
  /// ```dart
  /// final customSet = SnackbarAdapterSets.custom([
  ///   NetworkSnackbarAdapter(),
  ///   CustomSnackbarAdapter(
  ///     id: 'custom_monitor',
  ///     initialize: (controller) {
  ///       // Custom logic
  ///     },
  ///   ),
  /// ]);
  /// ```
  static List<SnackbarAdapter> custom(List<SnackbarAdapter> adapters) {
    return List.from(adapters);
  }

  /// Получает список всех доступных адаптеров.
  ///
  /// Возвращает список всех предустановленных адаптеров,
  /// которые можно использовать в приложении.
  ///
  /// ---
  ///
  /// Gets list of all available adapters.
  ///
  /// Returns list of all predefined adapters
  /// that can be used in application.
  static List<SnackbarAdapter> get allAvailable => [
        NetworkSnackbarAdapter(),
        // TODO: Add other adapters when implemented
      ];

  /// Получает адаптер по идентификатору.
  ///
  /// Ищет адаптер среди всех доступных по его ID.
  ///
  /// Параметры:
  /// - [id] - идентификатор искомого адаптера
  ///
  /// Возвращает: найденный адаптер или null
  ///
  /// ---
  ///
  /// Gets adapter by identifier.
  ///
  /// Searches for adapter among all available by its ID.
  ///
  /// Parameters:
  /// - [id] - identifier of adapter to find
  ///
  /// Returns: found adapter or null
  static SnackbarAdapter? getById(String id) {
    try {
      return allAvailable.firstWhere((adapter) => adapter.id == id);
    } catch (e) {
      return null;
    }
  }
}
