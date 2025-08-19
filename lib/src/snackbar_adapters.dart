import 'package:flutter/material.dart';
import 'snackbar_controller.dart';
import 'snackbar_message.dart';
import 'snackbar_types.dart';

/// Абстрактный базовый класс для адаптеров снэкбаров.
///
/// Адаптеры позволяют подключать внешние источники данных или события
/// к системе снэкбаров. Они следят за изменениями в состоянии приложения
/// и автоматически показывают соответствующие уведомления.
///
/// Типичные примеры адаптеров:
/// - Сетевой адаптер (следит за подключением к интернету)
/// - Адаптер синхронизации (отслеживает процесс синхронизации данных)
/// - Адаптер обновлений (проверяет доступность новых версий)
/// - Адаптер аутентификации (реагирует на изменения статуса входа)
///
/// ---
///
/// Abstract base class for snackbar adapters.
///
/// Adapters allow connecting external data sources or events
/// to the snackbar system. They monitor app state changes
/// and automatically show corresponding notifications.
///
/// Typical adapter examples:
/// - Network adapter (monitors internet connection)
/// - Sync adapter (tracks data synchronization process)
/// - Update adapter (checks for new version availability)
/// - Auth adapter (reacts to login status changes)
abstract class SnackbarAdapter {
  const SnackbarAdapter();

  /// Инициализирует адаптер с доступом к контроллеру снэкбаров.
  ///
  /// Вызывается один раз при регистрации адаптера в системе.
  /// Здесь адаптер должен:
  /// - Подписаться на необходимые источники данных
  /// - Настроить слушатели изменений
  /// - Инициализировать внутренние ресурсы
  ///
  /// Параметры:
  /// - [controller] - контроллер снэкбаров для показа уведомлений
  ///
  /// Пример реализации:
  /// ```dart
  /// @override
  /// void initialize(SnackbarController controller) {
  ///   _connectivitySubscription = Connectivity()
  ///     .onConnectivityChanged
  ///     .listen((result) {
  ///       if (result == ConnectivityResult.none) {
  ///         controller.showSnackbar(
  ///           NetworkSnackbarMessage.connectionLost(),
  ///         );
  ///       }
  ///     });
  /// }
  /// ```
  ///
  /// ---
  ///
  /// Initializes adapter with access to snackbar controller.
  ///
  /// Called once when adapter is registered in the system.
  /// Here adapter should:
  /// - Subscribe to necessary data sources
  /// - Set up change listeners
  /// - Initialize internal resources
  ///
  /// Parameters:
  /// - [controller] - snackbar controller for showing notifications
  ///
  /// Implementation example:
  /// ```dart
  /// @override
  /// void initialize(SnackbarController controller) {
  ///   _connectivitySubscription = Connectivity()
  ///     .onConnectivityChanged
  ///     .listen((result) {
  ///       if (result == ConnectivityResult.none) {
  ///         controller.showSnackbar(
  ///           NetworkSnackbarMessage.connectionLost(),
  ///         );
  ///       }
  ///     });
  /// }
  /// ```
  void initialize(SnackbarController controller);

  /// Освобождает ресурсы адаптера при его удалении.
  ///
  /// Вызывается когда адаптер больше не нужен. Используется для:
  /// - Отмены подписок на потоки данных
  /// - Закрытия сетевых соединений
  /// - Освобождения памяти
  /// - Сохранения состояния (если необходимо)
  ///
  /// По умолчанию не делает ничего. Переопределите в наследниках
  /// если требуется специальная логика очистки.
  ///
  /// Пример реализации:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   _networkSubscription?.cancel();
  ///   _timer?.cancel();
  ///   _saveState();
  /// }
  /// ```
  ///
  /// ---
  ///
  /// Releases adapter resources when it's removed.
  ///
  /// Called when adapter is no longer needed. Used for:
  /// - Canceling data stream subscriptions
  /// - Closing network connections
  /// - Freeing memory
  /// - Saving state (if necessary)
  ///
  /// Does nothing by default. Override in inheritors
  /// if special cleanup logic is required.
  ///
  /// Implementation example:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   _networkSubscription?.cancel();
  ///   _timer?.cancel();
  ///   _saveState();
  /// }
  /// ```
  void dispose() {}

  /// Уникальный идентификатор адаптера.
  ///
  /// Используется для:
  /// - Предотвращения дублирования адаптеров
  /// - Поиска и управления конкретными адаптерами
  /// - Отладки и логирования
  ///
  /// Должен быть уникальным в рамках приложения.
  /// Рекомендуется использовать описательные имена:
  /// 'network_adapter', 'sync_adapter', 'auth_adapter'.
  ///
  /// ---
  ///
  /// Unique adapter identifier.
  ///
  /// Used for:
  /// - Preventing adapter duplication
  /// - Finding and managing specific adapters
  /// - Debugging and logging
  ///
  /// Must be unique within the application.
  /// Recommended to use descriptive names:
  /// 'network_adapter', 'sync_adapter', 'auth_adapter'.
  String get id;
}

/// Фабрика для создания пользовательских адаптеров без наследования.
///
/// Позволяет создавать адаптеры "на лету" с помощью функций,
/// без необходимости создания отдельных классов. Удобно для:
/// - Простых адаптеров с минимальной логикой
/// - Прототипирования и тестирования
/// - Одноразовых адаптеров для специфических случаев
///
/// Пример использования:
/// ```dart
/// final networkAdapter = CustomSnackbarAdapter(
///   id: 'network_monitor',
///   initialize: (controller) {
///     Timer.periodic(Duration(seconds: 30), (_) {
///       // Проверяем подключение к интернету
///       if (!isConnected) {
///         controller.showSnackbar(
///           NetworkSnackbarMessage.connectionLost(),
///         );
///       }
///     });
///   },
/// );
/// ```
///
/// ---
///
/// Factory for creating custom adapters without inheritance.
///
/// Allows creating adapters "on the fly" using functions,
/// without needing to create separate classes. Convenient for:
/// - Simple adapters with minimal logic
/// - Prototyping and testing
/// - One-off adapters for specific cases
///
/// Usage example:
/// ```dart
/// final networkAdapter = CustomSnackbarAdapter(
///   id: 'network_monitor',
///   initialize: (controller) {
///     Timer.periodic(Duration(seconds: 30), (_) {
///       // Check internet connection
///       if (!isConnected) {
///         controller.showSnackbar(
///           NetworkSnackbarMessage.connectionLost(),
///         );
///       }
///     });
///   },
/// );
/// ```
class CustomSnackbarAdapter extends SnackbarAdapter {
  final String _id;
  final void Function(SnackbarController controller) _initialize;
  final VoidCallback? _dispose;

  /// Создает пользовательский адаптер с заданными функциями.
  ///
  /// Параметры:
  /// - [id] - уникальный идентификатор адаптера
  /// - [initialize] - функция инициализации, принимающая SnackbarController
  /// - [dispose] - опциональная функция очистки ресурсов
  ///
  /// Пример создания адаптера для мониторинга времени:
  /// ```dart
  /// final timeAdapter = CustomSnackbarAdapter(
  ///   id: 'time_monitor',
  ///   initialize: (controller) {
  ///     Timer.periodic(Duration(hours: 1), (_) {
  ///       controller.showSnackbar(
  ///         BasicSnackbarMessage(
  ///           id: 'hourly_reminder',
  ///           message: 'Прошел еще один час',
  ///           type: SnackbarType.info,
  ///         ),
  ///       );
  ///     });
  ///   },
  ///   dispose: () => timer?.cancel(),
  /// );
  /// ```
  ///
  /// ---
  ///
  /// Creates custom adapter with given functions.
  ///
  /// Parameters:
  /// - [id] - unique adapter identifier
  /// - [initialize] - initialization function accepting SnackbarController
  /// - [dispose] - optional resource cleanup function
  ///
  /// Example creating adapter for time monitoring:
  /// ```dart
  /// final timeAdapter = CustomSnackbarAdapter(
  ///   id: 'time_monitor',
  ///   initialize: (controller) {
  ///     Timer.periodic(Duration(hours: 1), (_) {
  ///       controller.showSnackbar(
  ///         BasicSnackbarMessage(
  ///           id: 'hourly_reminder',
  ///           message: 'Another hour has passed',
  ///           type: SnackbarType.info,
  ///         ),
  ///       );
  ///     });
  ///   },
  ///   dispose: () => timer?.cancel(),
  /// );
  /// ```
  const CustomSnackbarAdapter({
    required String id,
    required void Function(SnackbarController controller) initialize,
    VoidCallback? dispose,
  })  : _id = id,
        _initialize = initialize,
        _dispose = dispose;

  /// Возвращает уникальный идентификатор адаптера
  ///
  /// Returns unique adapter identifier
  @override
  String get id => _id;

  /// Выполняет инициализацию адаптера с помощью переданной функции
  ///
  /// Performs adapter initialization using provided function
  @override
  void initialize(SnackbarController controller) => _initialize(controller);

  /// Выполняет очистку ресурсов с помощью переданной функции (если есть)
  ///
  /// Performs resource cleanup using provided function (if exists)
  @override
  void dispose() => _dispose?.call();
}

/// Расширения для удобной работы со списками адаптеров.
///
/// Предоставляет методы для безопасного управления коллекцией адаптеров:
/// добавление без дублирования, удаление по ID, замена существующих.
///
/// ---
///
/// Extensions for convenient work with adapter lists.
///
/// Provides methods for safe adapter collection management:
/// adding without duplication, removing by ID, replacing existing ones.
extension SnackbarAdapterListExtension on List<SnackbarAdapter> {
  /// Добавляет адаптер в список, если адаптера с таким ID еще нет.
  ///
  /// Предотвращает дублирование адаптеров с одинаковыми идентификаторами.
  /// Если адаптер с таким ID уже существует, возвращает исходный список
  /// без изменений.
  ///
  /// Параметры:
  /// - [adapter] - адаптер для добавления
  ///
  /// Возвращает: новый список с добавленным адаптером или исходный список
  ///
  /// Пример использования:
  /// ```dart
  /// final adapters = <SnackbarAdapter>[];
  /// final newAdapters = adapters
  ///   .addIfNotExists(networkAdapter)
  ///   .addIfNotExists(syncAdapter);
  /// ```
  ///
  /// ---
  ///
  /// Adds adapter to list if adapter with such ID doesn't exist yet.
  ///
  /// Prevents duplication of adapters with same identifiers.
  /// If adapter with such ID already exists, returns original list
  /// without changes.
  ///
  /// Parameters:
  /// - [adapter] - adapter to add
  ///
  /// Returns: new list with added adapter or original list
  ///
  /// Usage example:
  /// ```dart
  /// final adapters = <SnackbarAdapter>[];
  /// final newAdapters = adapters
  ///   .addIfNotExists(networkAdapter)
  ///   .addIfNotExists(syncAdapter);
  /// ```
  List<SnackbarAdapter> addIfNotExists(SnackbarAdapter adapter) {
    // Проверяем существование адаптера с таким ID
    // Check if adapter with such ID exists
    if (any((a) => a.id == adapter.id)) {
      return this;
    }

    // Возвращаем новый список с добавленным адаптером
    // Return new list with added adapter
    return [...this, adapter];
  }

  /// Удаляет адаптер с указанным идентификатором из списка.
  ///
  /// Создает новый список без адаптера с указанным ID.
  /// Если адаптер с таким ID не найден, возвращает список
  /// без изменений.
  ///
  /// Параметры:
  /// - [id] - идентификатор адаптера для удаления
  ///
  /// Возвращает: новый список без указанного адаптера
  ///
  /// Пример использования:
  /// ```dart
  /// final adaptersWithoutNetwork = adapters.removeById('network_adapter');
  /// ```
  ///
  /// ---
  ///
  /// Removes adapter with specified identifier from list.
  ///
  /// Creates new list without adapter with specified ID.
  /// If adapter with such ID is not found, returns list
  /// without changes.
  ///
  /// Parameters:
  /// - [id] - identifier of adapter to remove
  ///
  /// Returns: new list without specified adapter
  ///
  /// Usage example:
  /// ```dart
  /// final adaptersWithoutNetwork = adapters.removeById('network_adapter');
  /// ```
  List<SnackbarAdapter> removeById(String id) {
    // Фильтруем список, исключая адаптер с указанным ID
    // Filter list, excluding adapter with specified ID
    return where((a) => a.id != id).toList();
  }

  /// Заменяет существующий адаптер новым с тем же идентификатором.
  ///
  /// Если адаптер с таким ID существует, заменяет его новым.
  /// Если адаптер не найден, добавляет новый в конец списка.
  ///
  /// Полезно для обновления конфигурации адаптеров или
  /// замены их улучшенными версиями.
  ///
  /// Параметры:
  /// - [adapter] - новый адаптер для замены/добавления
  ///
  /// Возвращает: новый список с замененным/добавленным адаптером
  ///
  /// Пример использования:
  /// ```dart
  /// final updatedAdapters = adapters.replace(improvedNetworkAdapter);
  /// ```
  ///
  /// ---
  ///
  /// Replaces existing adapter with new one having same identifier.
  ///
  /// If adapter with such ID exists, replaces it with new one.
  /// If adapter is not found, adds new one to the end of list.
  ///
  /// Useful for updating adapter configuration or
  /// replacing them with improved versions.
  ///
  /// Parameters:
  /// - [adapter] - new adapter for replacement/addition
  ///
  /// Returns: new list with replaced/added adapter
  ///
  /// Usage example:
  /// ```dart
  /// final updatedAdapters = adapters.replace(improvedNetworkAdapter);
  /// ```
  List<SnackbarAdapter> replace(SnackbarAdapter adapter) {
    // Проверяем существование адаптера с таким ID
    // Check if adapter with such ID exists
    final existingIndex = indexWhere((a) => a.id == adapter.id);

    if (existingIndex != -1) {
      // Заменяем существующий адаптер
      // Replace existing adapter
      return map((a) => a.id == adapter.id ? adapter : a).toList();
    }

    // Добавляем новый адаптер в конец списка
    // Add new adapter to the end of list
    return [...this, adapter];
  }
}
