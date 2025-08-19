import 'dart:async';
import 'package:flutter/material.dart';
import 'snackbar_controller.dart';
import 'snackbar_message.dart';
import 'snackbar_adapters.dart';
import 'snackbar_types.dart';
import 'stacked_snackbar_widget.dart';

/// Перечисление для определения позиции стека снэкбаров на экране.
///
/// Определяет, в каком углу экрана будут появляться и располагаться
/// снэкбары друг относительно друга.
///
/// Варианты расположения:
/// - [topLeft] - левый верхний угол
/// - [topRight] - правый верхний угол (по умолчанию)
/// - [bottomLeft] - левый нижний угол
/// - [bottomRight] - правый нижний угол
///
/// ---
///
/// Enumeration for defining snackbar stack position on screen.
///
/// Determines in which corner of the screen snackbars will appear
/// and stack relative to each other.
///
/// Position options:
/// - [topLeft] - top left corner
/// - [topRight] - top right corner (default)
/// - [bottomLeft] - bottom left corner
/// - [bottomRight] - bottom right corner
enum StackAlignment {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// Главный виджет для отображения снэкбаров поверх интерфейса приложения.
///
/// [SnackbarOverlay] - это комплексное решение для управления снэкбарами,
/// которое объединяет в себе:
/// - Систему overlay для отображения поверх других виджетов
/// - Менеджер адаптеров для интеграции с внешними системами
/// - Анимированное стекирование нескольких сообщений
/// - Автоматическое скрытие с настраиваемыми таймерами
/// - Гибкое позиционирование на экране
///
/// Основные возможности:
/// - Поддержка множественных адаптеров
/// - Ограничение количества одновременно видимых сообщений
/// - Анимации появления, стекирования и исчезновения
/// - Автоматическое управление жизненным циклом сообщений
/// - Реактивная интеграция с SnackbarController
///
/// Пример базового использования:
/// ```dart
/// MaterialApp(
///   home: SnackbarOverlay(
///     child: MyHomePage(),
///     stackAlignment: StackAlignment.topRight,
///     maxVisibleMessages: 3,
///     padding: EdgeInsets.all(16),
///   ),
/// );
/// ```
///
/// Пример с адаптерами:
/// ```dart
/// SnackbarOverlay(
///   child: MyApp(),
///   adapters: [
///     NetworkSnackbarAdapter(),
///     AuthSnackbarAdapter(),
///   ],
///   maxVisibleMessages: 5,
/// );
/// ```
///
/// ---
///
/// Main widget for displaying snackbars over application interface.
///
/// [SnackbarOverlay] is a comprehensive solution for snackbar management
/// that combines:
/// - Overlay system for displaying over other widgets
/// - Adapter manager for external system integration
/// - Animated stacking of multiple messages
/// - Automatic hiding with configurable timers
/// - Flexible screen positioning
///
/// Key features:
/// - Multiple adapter support
/// - Limit of simultaneously visible messages
/// - Appearance, stacking and disappearance animations
/// - Automatic message lifecycle management
/// - Reactive SnackbarController integration
///
/// Basic usage example:
/// ```dart
/// MaterialApp(
///   home: SnackbarOverlay(
///     child: MyHomePage(),
///     stackAlignment: StackAlignment.topRight,
///     maxVisibleMessages: 3,
///     padding: EdgeInsets.all(16),
///   ),
/// );
/// ```
///
/// Example with adapters:
/// ```dart
/// SnackbarOverlay(
///   child: MyApp(),
///   adapters: [
///     NetworkSnackbarAdapter(),
///     AuthSnackbarAdapter(),
///   ],
///   maxVisibleMessages: 5,
/// );
/// ```
class SnackbarOverlay extends StatefulWidget {
  /// Дочерний виджет, поверх которого будут отображаться снэкбары.
  /// Обычно это корневой виджет приложения или конкретного экрана.
  ///
  /// ---
  ///
  /// Child widget over which snackbars will be displayed.
  /// Usually this is the root widget of the app or specific screen.
  final Widget child;

  /// Список адаптеров для интеграции с внешними системами.
  ///
  /// Адаптеры позволяют автоматически реагировать на события в приложении
  /// и показывать соответствующие уведомления. Например:
  /// - Network адаптер для статуса соединения
  /// - Auth адаптер для статуса аутентификации
  /// - Sync адаптер для процесса синхронизации
  ///
  /// ---
  ///
  /// List of adapters for external system integration.
  ///
  /// Adapters allow automatic reaction to app events
  /// and show corresponding notifications. For example:
  /// - Network adapter for connection status
  /// - Auth adapter for authentication status
  /// - Sync adapter for synchronization process
  final List<SnackbarAdapter> adapters;

  /// Отступы от краев экрана для позиционирования снэкбаров.
  ///
  /// Если не указано, используются отступы по умолчанию (16px со всех сторон).
  /// Учитывает безопасные зоны устройства автоматически.
  ///
  /// ---
  ///
  /// Padding from screen edges for snackbar positioning.
  ///
  /// If not specified, default padding is used (16px from all sides).
  /// Automatically considers device safe areas.
  final EdgeInsets? padding;

  /// Максимальное количество одновременно видимых сообщений.
  ///
  /// При превышении лимита старые сообщения автоматически скрываются.
  /// Помогает избежать переполнения интерфейса уведомлениями.
  /// Рекомендуемые значения: 3-7 сообщений.
  ///
  /// ---
  ///
  /// Maximum number of simultaneously visible messages.
  ///
  /// When limit is exceeded, old messages are automatically hidden.
  /// Helps avoid interface overflow with notifications.
  /// Recommended values: 3-7 messages.
  final int maxVisibleMessages;

  /// Позиция стека снэкбаров на экране.
  ///
  /// Определяет, в каком углу экрана будут появляться снэкбары
  /// и в каком направлении они будут стекироваться.
  ///
  /// ---
  ///
  /// Position of snackbar stack on screen.
  ///
  /// Determines in which corner snackbars will appear
  /// and in which direction they will stack.
  final StackAlignment alignment;

  /// Контроллер снэкбаров для управления сообщениями.
  ///
  /// Если не указан, создается новый экземпляр.
  ///
  /// ---
  ///
  /// Snackbar controller for message management.
  ///
  /// If not specified, new instance is created.
  final SnackbarController? controller;

  const SnackbarOverlay({
    super.key,
    required this.child,
    this.adapters = const [],
    this.padding,
    this.maxVisibleMessages = 5,
    this.alignment = StackAlignment.topRight,
    this.controller,
  });

  @override
  State<SnackbarOverlay> createState() => _SnackbarOverlayState();
}

class _SnackbarOverlayState extends State<SnackbarOverlay> {
  /// Ключ для доступа к состоянию Overlay.
  /// Используется для добавления и удаления overlay entries.
  ///
  /// ---
  ///
  /// Key for accessing Overlay state.
  /// Used for adding and removing overlay entries.
  final GlobalKey<OverlayState> _overlayKey = GlobalKey<OverlayState>();

  /// Карта активных overlay entries по ID сообщений.
  /// Позволяет быстро находить и управлять конкретными снэкбарами.
  ///
  /// ---
  ///
  /// Map of active overlay entries by message IDs.
  /// Allows quick finding and managing of specific snackbars.
  final Map<String, OverlayEntry> _overlayEntries = {};

  /// Карта таймеров автоскрытия по ID сообщений.
  /// Каждое непостоянное сообщение имеет таймер для автоматического скрытия.
  ///
  /// ---
  ///
  /// Map of auto-hide timers by message IDs.
  /// Each non-persistent message has a timer for automatic hiding.
  final Map<String, Timer> _autoHideTimers = {};

  /// Набор ID инициализированных адаптеров.
  /// Предотвращает повторную инициализацию и отслеживает состояние.
  ///
  /// ---
  ///
  /// Set of initialized adapter IDs.
  /// Prevents duplicate initialization and tracks state.
  final Set<String> _initializedAdapters = {};

  /// Контроллер снэкбаров для управления сообщениями.
  ///
  /// ---
  ///
  /// Snackbar controller for message management.
  late SnackbarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SnackbarController();
    _initializeAdapters();
  }

  @override
  void didUpdateWidget(covariant SnackbarOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Проверяем, изменился ли список адаптеров
    // Check if adapter list changed
    final oldAdapterIds = oldWidget.adapters.map((adapter) => adapter.id).toSet();
    final newAdapterIds = widget.adapters.map((adapter) => adapter.id).toSet();

    if (!oldAdapterIds.containsAll(newAdapterIds) || !newAdapterIds.containsAll(oldAdapterIds)) {
      _reinitializeAdapters();
    }
  }

  /// Инициализирует все адаптеры после построения виджета.
  ///
  /// Обрабатывает ошибки инициализации без прерывания работы.
  ///
  /// Процесс инициализации:
  /// 1. Проверка, что виджет все еще смонтирован
  /// 2. Перебор всех адаптеров
  /// 3. Проверка, что адаптер еще не инициализирован
  /// 4. Вызов метода initialize адаптера
  /// 5. Добавление ID в набор инициализированных
  /// 6. Логирование результатов
  ///
  /// ---
  ///
  /// Initializes all adapters after widget build.
  ///
  /// Handles initialization errors without breaking functionality.
  ///
  /// Initialization process:
  /// 1. Check that widget is still mounted
  /// 2. Iterate through all adapters
  /// 3. Check that adapter is not yet initialized
  /// 4. Call adapter's initialize method
  /// 5. Add ID to initialized set
  /// 6. Log results
  void _initializeAdapters() {
    for (final adapter in widget.adapters) {
      if (!_initializedAdapters.contains(adapter.id)) {
        try {
          adapter.initialize(_controller);
          _initializedAdapters.add(adapter.id);
          debugPrint('Adapter ${adapter.id} initialized');
        } catch (e) {
          debugPrint('Adapter ${adapter.id} initialization error: $e');
        }
      }
    }
  }

  /// Переинициализирует адаптеры при изменении их списка.
  ///
  /// Процедура:
  /// 1. Очищает все существующие адаптеры
  /// 2. Вызывает dispose() для каждого инициализированного адаптера
  /// 3. Очищает набор инициализированных адаптеров
  /// 4. Запускает повторную инициализацию
  ///
  /// Используется при hot reload или динамическом изменении конфигурации.
  ///
  /// ---
  ///
  /// Reinitializes adapters when their list changes.
  ///
  /// Procedure:
  /// 1. Clears all existing adapters
  /// 2. Calls dispose() for each initialized adapter
  /// 3. Clears initialized adapters set
  /// 4. Starts reinitialization
  ///
  /// Used during hot reload or dynamic configuration changes.
  void _reinitializeAdapters() {
    for (final adapter in widget.adapters) {
      if (_initializedAdapters.contains(adapter.id)) {
        try {
          adapter.dispose();
        } catch (e) {
          debugPrint('Adapter ${adapter.id} disposing error: $e');
        }
      }
    }

    _initializedAdapters.clear();
    _initializeAdapters();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateOverlays(_controller.messages);
          }
        });

        return Overlay(
          key: _overlayKey,
          initialEntries: [
            OverlayEntry(builder: (context) => widget.child),
          ],
        );
      },
    );
  }

  /// Обновляет состояние overlay в соответствии с изменениями сообщений.
  ///
  /// Алгоритм обновления:
  /// 1. Определяет удаленные сообщения и скрывает их overlay
  /// 2. Ограничивает количество видимых сообщений максимумом
  /// 3. Скрывает сообщения, превышающие лимит видимости
  /// 4. Добавляет новые сообщения или обновляет позиции существующих
  ///
  /// Параметры:
  /// - [currentMessages] - текущий список сообщений
  ///
  /// ---
  ///
  /// Updates overlay state according to message changes.
  ///
  /// Update algorithm:
  /// 1. Identifies removed messages and hides their overlays
  /// 2. Limits visible messages count to maximum
  /// 3. Hides messages exceeding visibility limit
  /// 4. Adds new messages or updates existing positions
  ///
  /// Parameters:
  /// - [currentMessages] - current message list
  void _updateOverlays(List<SnackbarMessage> currentMessages) {
    final currentIds = currentMessages.map((m) => m.id).toSet();
    final existingIds = _overlayEntries.keys.toSet();

    // Удаляем исчезнувшие снэкбары
    // Remove disappeared snackbars
    final removedIds = existingIds.difference(currentIds);
    for (final id in removedIds) {
      _removeOverlay(id);
    }

    // Ограничиваем количество видимых сообщений
    // Limit visible messages count
    final visibleMessages = currentMessages.take(widget.maxVisibleMessages).toList();
    final visibleIds = visibleMessages.map((m) => m.id).toSet();

    // Скрываем сообщения, которые превышают лимит
    // Hide messages exceeding limit
    final hiddenIds = existingIds.difference(visibleIds);
    for (final id in hiddenIds) {
      _removeOverlay(id);
    }

    // Добавляем/обновляем видимые снэкбары
    // Add/update visible snackbars
    for (int i = 0; i < visibleMessages.length; i++) {
      final message = visibleMessages[i];
      if (!existingIds.contains(message.id)) {
        _showOverlay(message, i);
      } else {
        _updateOverlayPosition(message.id, i);
      }
    }
  }

  /// Создает и показывает overlay для нового сообщения.
  ///
  /// Процесс создания:
  /// 1. Проверка, что виджет все еще смонтирован
  /// 2. Создание OverlayEntry с анимированным виджетом
  /// 3. Вставка entry в overlay state
  /// 4. Сохранение ссылки в карте активных entries
  /// 5. Настройка таймера автоскрытия
  ///
  /// Параметры:
  /// - [message] - сообщение для отображения
  /// - [index] - позиция в стеке (0 = верхнее)
  ///
  /// ---
  ///
  /// Creates and shows overlay for new message.
  ///
  /// Creation process:
  /// 1. Check that widget is still mounted
  /// 2. Create OverlayEntry with animated widget
  /// 3. Insert entry into overlay state
  /// 4. Save reference in active entries map
  /// 5. Set up auto-hide timer
  ///
  /// Parameters:
  /// - [message] - message to display
  /// - [index] - position in stack (0 = top)
  void _showOverlay(SnackbarMessage message, int index) {
    if (!mounted) return;

    try {
      final entry = OverlayEntry(
        builder: (context) => StackedSnackbarWidget(
          message: message,
          index: index,
          alignment: widget.alignment,
          padding: widget.padding ?? const EdgeInsets.all(16.0),
          onDismiss: () => _removeOverlay(message.id),
        ),
      );

      final overlay = _overlayKey.currentState;
      if (overlay != null) {
        overlay.insert(entry);
        _overlayEntries[message.id] = entry;

        // Настройка автоскрытия
        // Set up auto-hide
        _scheduleAutoHide(message);
      }
    } catch (e) {
      debugPrint('Snackbar creating error: $e');
    }
  }

  /// Настраивает таймер автоматического скрытия для сообщения.
  ///
  /// Логика работы:
  /// 1. Отменяет предыдущий таймер для этого ID (если есть)
  /// 2. Пропускает персистентные сообщения и loading индикаторы
  /// 3. Использует duration из сообщения или стандартное для типа
  /// 4. Создает Timer, который скроет сообщение через заданное время
  ///
  /// Стандартные длительности:
  /// - Success: 2 секунды
  /// - Info: 2 секунды
  /// - Warning: 3 секунды
  /// - Error: 4 секунды
  /// - Loading: не скрывается автоматически
  ///
  /// Параметры:
  /// - [message] - сообщение для настройки автоскрытия
  ///
  /// ---
  ///
  /// Sets up automatic hide timer for message.
  ///
  /// Logic:
  /// 1. Cancels previous timer for this ID (if exists)
  /// 2. Skips persistent messages and loading indicators
  /// 3. Uses duration from message or default for type
  /// 4. Creates Timer that will hide message after specified time
  ///
  /// Default durations:
  /// - Success: 2 seconds
  /// - Info: 2 seconds
  /// - Warning: 3 seconds
  /// - Error: 4 seconds
  /// - Loading: not hidden automatically
  ///
  /// Parameters:
  /// - [message] - message to set up auto-hide for
  void _scheduleAutoHide(SnackbarMessage message) {
    // Отменяем предыдущий таймер
    // Cancel previous timer
    _autoHideTimers[message.id]?.cancel();

    // Не устанавливаем таймер для персистентных сообщений или loading
    // Don't set timer for persistent messages or loading
    if (message.persistent || message.type == SnackbarType.loading) {
      return;
    }

    final duration = message.duration ?? _getDefaultDuration(message.type);
    if (duration != null) {
      _autoHideTimers[message.id] = Timer(
        duration,
        () {
          if (mounted) {
            _controller.hideSnackbar(message.id);
          }
        },
      );
    }
  }

  /// Обновляет позицию существующего overlay в стеке.
  ///
  /// В текущей реализации для простоты пересоздает overlay с новой позицией.
  /// В более сложной реализации можно добавить анимацию плавного перемещения.
  ///
  /// Процесс:
  /// 1. Находит сообщение по ID в текущем состоянии
  /// 2. Удаляет старый overlay
  /// 3. Создает новый overlay с обновленной позицией
  ///
  /// Параметры:
  /// - [id] - идентификатор сообщения
  /// - [newIndex] - новая позиция в стеке
  ///
  /// ---
  ///
  /// Updates position of existing overlay in stack.
  ///
  /// Current implementation recreates overlay with new position for simplicity.
  /// More complex implementation could add smooth movement animation.
  ///
  /// Process:
  /// 1. Finds message by ID in current state
  /// 2. Removes old overlay
  /// 3. Creates new overlay with updated position
  ///
  /// Parameters:
  /// - [id] - message identifier
  /// - [newIndex] - new position in stack
  void _updateOverlayPosition(String id, int newIndex) {
    final message = _controller.messages.firstWhere((m) => m.id == id);
    _removeOverlay(id);
    _showOverlay(message, newIndex);
  }

  /// Удаляет overlay и очищает связанные ресурсы.
  ///
  /// Процедура очистки:
  /// 1. Отменяет и удаляет таймер автоскрытия
  /// 2. Извлекает OverlayEntry из карты активных
  /// 3. Проверяет, что entry смонтирован
  /// 4. Удаляет entry из overlay
  /// 5. Удаляет ссылку из карты
  /// 6. Обрабатывает возможные ошибки
  ///
  /// Параметры:
  /// - [id] - идентификатор сообщения для удаления
  ///
  /// ---
  ///
  /// Removes overlay and cleans up related resources.
  ///
  /// Cleanup procedure:
  /// 1. Cancels and removes auto-hide timer
  /// 2. Retrieves OverlayEntry from active map
  /// 3. Checks that entry is mounted
  /// 4. Removes entry from overlay
  /// 5. Removes reference from map
  /// 6. Handles possible errors
  ///
  /// Parameters:
  /// - [id] - message identifier to remove
  void _removeOverlay(String id) {
    _autoHideTimers[id]?.cancel();
    _autoHideTimers.remove(id);

    final entry = _overlayEntries[id];
    if (entry != null) {
      try {
        if (entry.mounted) {
          entry.remove();
        }
      } catch (e) {
        debugPrint('Snackbar remove error: $e');
      } finally {
        _overlayEntries.remove(id);
      }
    }
  }

  /// Возвращает стандартную продолжительность отображения для типа сообщения.
  ///
  /// Стандартные значения:
  /// - Success: 2 секунды (быстрое подтверждение)
  /// - Info: 2 секунды (нейтральная информация)
  /// - Warning: 3 секунды (требует внимания)
  /// - Error: 4 секунды (важная информация)
  /// - Loading: null (персистентное, скрывается вручную)
  ///
  /// Параметры:
  /// - [type] - тип сообщения
  ///
  /// Возвращает: продолжительность или null для персистентных
  ///
  /// ---
  ///
  /// Returns default display duration for message type.
  ///
  /// Default values:
  /// - Success: 2 seconds (quick confirmation)
  /// - Info: 2 seconds (neutral information)
  /// - Warning: 3 seconds (requires attention)
  /// - Error: 4 seconds (important information)
  /// - Loading: null (persistent, hidden manually)
  ///
  /// Parameters:
  /// - [type] - message type
  ///
  /// Returns: duration or null for persistent
  Duration? _getDefaultDuration(SnackbarType type) => switch (type) {
        SnackbarType.success => const Duration(seconds: 2),
        SnackbarType.info => const Duration(seconds: 2),
        SnackbarType.warning => const Duration(seconds: 3),
        SnackbarType.error => const Duration(seconds: 4),
        SnackbarType.loading => null,
      };

  @override
  void dispose() {
    // Очищаем все адаптеры
    // Clean up all adapters
    for (final adapter in widget.adapters) {
      if (_initializedAdapters.contains(adapter.id)) {
        try {
          adapter.dispose();
        } catch (e) {
          debugPrint('Adapter ${adapter.id} when disposing error: $e');
        }
      }
    }
    _initializedAdapters.clear();

    // Очищаем таймеры и overlay entries
    // Clean up timers and overlay entries
    for (final timer in _autoHideTimers.values) {
      timer.cancel();
    }
    _autoHideTimers.clear();

    for (final entry in _overlayEntries.values) {
      if (entry.mounted) {
        entry.remove();
      }
    }
    _overlayEntries.clear();

    super.dispose();
  }
}
