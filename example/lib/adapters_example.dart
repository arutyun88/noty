import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:noty/noty.dart';

/// Пример использования адаптеров Noty.
///
/// Демонстрирует:
/// - Встроенные адаптеры (NetworkSnackbarAdapter)
/// - Пользовательские адаптеры
/// - Наборы адаптеров
/// - Интеграцию с внешними системами
///
/// ---
///
/// Example of Noty adapters usage.
///
/// Demonstrates:
/// - Built-in adapters (NetworkSnackbarAdapter)
/// - Custom adapters
/// - Adapter sets
/// - External systems integration
class AdaptersExampleApp extends StatelessWidget {
  const AdaptersExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noty Adapters Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const AdaptersHomePage(),
    );
  }
}

class AdaptersHomePage extends StatefulWidget {
  const AdaptersHomePage({super.key});

  @override
  State<AdaptersHomePage> createState() => _AdaptersHomePageState();
}

class _AdaptersHomePageState extends State<AdaptersHomePage> {
  /// Контроллер снэкбаров.
  /// Snackbar controller.
  late final SnackbarController _controller;

  /// Активные адаптеры.
  /// Active adapters.
  List<SnackbarAdapter> _adapters = [];

  /// Счетчики для демонстрации работы адаптеров.
  /// Counters for adapter demonstration.
  int _notificationCount = 0;
  int _errorCount = 0;
  Timer? _periodicTimer;

  @override
  void initState() {
    super.initState();
    _controller = SnackbarController();
    _setupInitialAdapters();
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Настраивает начальные адаптеры.
  /// Sets up initial adapters.
  void _setupInitialAdapters() {
    setState(() {
      _adapters = [
        // Встроенный адаптер для мониторинга сети
        // Built-in network monitoring adapter
        const NetworkSnackbarAdapter(),
        
        // Пользовательский адаптер для уведомлений
        // Custom notifications adapter
        _createNotificationAdapter(),
        
        // Адаптер для мониторинга ошибок
        // Error monitoring adapter
        _createErrorMonitorAdapter(),
      ];
    });
  }

  /// Создает адаптер для уведомлений.
  /// Creates notifications adapter.
  SnackbarAdapter _createNotificationAdapter() {
    return CustomSnackbarAdapter(
      id: 'notification_adapter',
      initialize: (controller) {
        // Показываем уведомление каждые 10 секунд
        // Show notification every 10 seconds
        Timer.periodic(const Duration(seconds: 10), (timer) {
          _notificationCount++;
          
          final notifications = [
            'У вас новое сообщение 📧',
            'Напоминание о встрече через 15 минут ⏰',
            'Обновление статуса проекта 📊',
            'Новый комментарий к вашему посту 💬',
            'Завершена синхронизация данных ✅',
          ];
          
          final message = notifications[_notificationCount % notifications.length];
          
          controller.showSnackbar(
            BasicSnackbarMessage(
              id: 'notification_$_notificationCount',
              message: message,
              type: SnackbarType.info,
              groupId: 'notifications',
              priority: SnackbarPriority.normal,
              actions: [
                SnackbarAction(
                  label: 'Просмотр',
                  onPressed: () {
                    controller.showSnackbar(
                      SnackbarMessages.success('Открываем уведомление...'),
                    );
                  },
                ),
              ],
            ),
          );
        });
      },
      dispose: () {
        debugPrint('Notification adapter disposed');
      },
    );
  }

  /// Создает адаптер для мониторинга ошибок.
  /// Creates error monitoring adapter.
  SnackbarAdapter _createErrorMonitorAdapter() {
    return CustomSnackbarAdapter(
      id: 'error_monitor',
      initialize: (controller) {
        // Симулируем случайные ошибки
        // Simulate random errors
        Timer.periodic(const Duration(seconds: 15), (timer) {
          if (Random().nextBool()) {
            _errorCount++;
            
            final errors = [
              'Ошибка подключения к базе данных',
              'Превышено время ожидания запроса',
              'Недостаточно места на диске',
              'Ошибка аутентификации пользователя',
              'Сервис временно недоступен',
            ];
            
            final error = errors[_errorCount % errors.length];
            
            controller.showSnackbar(
              BasicSnackbarMessage(
                id: 'error_$_errorCount',
                message: '⚠️ $error',
                type: SnackbarType.error,
                priority: SnackbarPriority.high,
                groupId: 'errors',
                actions: [
                  SnackbarAction(
                    label: 'Повторить',
                    onPressed: () {
                      controller.showSnackbar(
                        SnackbarMessages.loading('Повторная попытка...', customId: 'retry_$_errorCount'),
                      );
                      
                      Future.delayed(const Duration(seconds: 2), () {
                        controller.hideSnackbar('retry_$_errorCount');
                        controller.showSnackbar(
                          SnackbarMessages.success('Проблема решена!'),
                        );
                      });
                    },
                  ),
                  SnackbarAction(
                    label: 'Отчет',
                    onPressed: () {
                      controller.showSnackbar(
                        SnackbarMessages.info('Отправляем отчет об ошибке...'),
                      );
                    },
                  ),
                ],
              ),
            );
          }
        });
      },
    );
  }

  /// Создает адаптер для системных событий.
  /// Creates system events adapter.
  SnackbarAdapter _createSystemEventsAdapter() {
    return CustomSnackbarAdapter(
      id: 'system_events',
      initialize: (controller) {
        // Показываем системные события
        // Show system events
        final events = [
          'Система обновлена до версии 1.2.3',
          'Очистка кэша завершена',
          'Резервное копирование данных',
          'Оптимизация производительности',
        ];
        
        for (int i = 0; i < events.length; i++) {
          Future.delayed(Duration(seconds: 5 + i * 3), () {
            controller.showSnackbar(
              BasicSnackbarMessage(
                id: 'system_event_$i',
                message: '🔧 ${events[i]}',
                type: SnackbarType.info,
                groupId: 'system',
                priority: SnackbarPriority.low,
              ),
            );
          });
        }
      },
    );
  }

  /// Создает адаптер для мониторинга производительности.
  /// Creates performance monitoring adapter.
  SnackbarAdapter _createPerformanceAdapter() {
    return CustomSnackbarAdapter(
      id: 'performance_monitor',
      initialize: (controller) {
        Timer.periodic(const Duration(seconds: 20), (timer) {
          final memoryUsage = Random().nextInt(100);
          final cpuUsage = Random().nextInt(100);
          
          if (memoryUsage > 80 || cpuUsage > 90) {
            controller.showSnackbar(
              BasicSnackbarMessage(
                id: 'performance_warning',
                message: '⚡ Высокая нагрузка: CPU $cpuUsage%, RAM $memoryUsage%',
                type: SnackbarType.warning,
                priority: SnackbarPriority.high,
                persistent: true,
                actions: [
                  SnackbarAction(
                    label: 'Оптимизировать',
                    onPressed: () {
                      controller.showSnackbar(
                        SnackbarMessages.loading('Оптимизация системы...', customId: 'optimization'),
                      );
                      
                      Future.delayed(const Duration(seconds: 3), () {
                        controller.hideSnackbar('optimization');
                        controller.showSnackbar(
                          SnackbarMessages.success('Система оптимизирована!'),
                        );
                      });
                    },
                  ),
                ],
              ),
            );
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SnackbarOverlay(
      controller: _controller,
      adapters: _adapters,
      maxVisibleMessages: 6,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Noty Adapters Example'),
          actions: [
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => _controller.clearAll(),
              tooltip: 'Очистить все сообщения',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Информация о текущих адаптерах
              // Current adapters information
              _buildAdaptersInfoCard(),
              
              const SizedBox(height: 16),
              
              // Управление адаптерами
              // Adapters management
              _buildAdaptersManagementCard(),
              
              const SizedBox(height: 16),
              
              // Предустановленные наборы
              // Predefined sets
              _buildAdapterSetsCard(),
              
              const SizedBox(height: 16),
              
              // Ручное управление группами
              // Manual group management
              _buildGroupManagementCard(),
              
              const SizedBox(height: 16),
              
              // Статистика
              // Statistics
              _buildStatisticsCard(),
            ],
          ),
        ),
      ),
    );
  }

  /// Строит карточку с информацией об адаптерах.
  /// Builds adapters information card.
  Widget _buildAdaptersInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Активные адаптеры (${_adapters.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (_adapters.isEmpty)
              const Text('Нет активных адаптеров')
            else
              ..._adapters.map((adapter) => Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.extension, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(adapter.id)),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => _removeAdapter(adapter.id),
                      tooltip: 'Удалить адаптер',
                    ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  /// Строит карточку управления адаптерами.
  /// Builds adapters management card.
  Widget _buildAdaptersManagementCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Добавить адаптеры',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _addAdapter(_createSystemEventsAdapter()),
                  child: const Text('System Events'),
                ),
                ElevatedButton(
                  onPressed: () => _addAdapter(_createPerformanceAdapter()),
                  child: const Text('Performance Monitor'),
                ),
                ElevatedButton(
                  onPressed: () => _addAdapter(const NetworkSnackbarAdapter()),
                  child: const Text('Network Monitor'),
                ),
                ElevatedButton(
                  onPressed: () => _addCustomTimerAdapter(),
                  child: const Text('Custom Timer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Строит карточку наборов адаптеров.
  /// Builds adapter sets card.
  Widget _buildAdapterSetsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Предустановленные наборы',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _loadAdapterSet(SnackbarAdapterSets.basic),
                  child: const Text('Basic Set'),
                ),
                ElevatedButton(
                  onPressed: () => _loadAdapterSet(SnackbarAdapterSets.minimal),
                  child: const Text('Minimal Set'),
                ),
                ElevatedButton(
                  onPressed: () => _loadAdapterSet(SnackbarAdapterSets.custom([
                    const NetworkSnackbarAdapter(),
                    _createNotificationAdapter(),
                  ])),
                  child: const Text('Custom Set'),
                ),
                ElevatedButton(
                  onPressed: () => _clearAllAdapters(),
                  child: const Text('Clear All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Строит карточку управления группами.
  /// Builds group management card.
  Widget _buildGroupManagementCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Управление группами',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _controller.hideGroup('notifications'),
                  child: const Text('Hide Notifications'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.hideGroup('errors'),
                  child: const Text('Hide Errors'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.hideGroup('system'),
                  child: const Text('Hide System'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.clearNonPersistent(),
                  child: const Text('Clear Non-Persistent'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Строит карточку статистики.
  /// Builds statistics card.
  Widget _buildStatisticsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Статистика',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ListenableBuilder(
              listenable: _controller,
              builder: (context, child) {
                final messages = _controller.messages;
                final groupedMessages = <String?, List<SnackbarMessage>>{};
                // Группируем сообщения вручную для демонстрации
                // Group messages manually for demonstration
                for (final message in messages) {
                  final group = message.groupId;
                  groupedMessages[group] = [...(groupedMessages[group] ?? []), message];
                }
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Всего сообщений: ${messages.length}'),
                    Text('Уведомлений создано: $_notificationCount'),
                    Text('Ошибок обнаружено: $_errorCount'),
                    Text('Активных групп: ${groupedMessages.length}'),
                    const SizedBox(height: 8),
                    if (groupedMessages.isNotEmpty) ...[
                      const Text('Сообщения по группам:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...groupedMessages.entries.map((entry) =>
                        Text('  ${entry.key}: ${entry.value.length} сообщений')),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Добавляет адаптер.
  /// Adds adapter.
  void _addAdapter(SnackbarAdapter adapter) {
    if (!_adapters.any((a) => a.id == adapter.id)) {
      setState(() {
        _adapters = [..._adapters, adapter];
      });
      
      _controller.showSnackbar(
        SnackbarMessages.success('Адаптер "${adapter.id}" добавлен'),
      );
    } else {
      _controller.showSnackbar(
        SnackbarMessages.warning('Адаптер "${adapter.id}" уже активен'),
      );
    }
  }

  /// Удаляет адаптер.
  /// Removes adapter.
  void _removeAdapter(String adapterId) {
    setState(() {
      _adapters = _adapters.where((a) => a.id != adapterId).toList();
    });
    
    _controller.showSnackbar(
      SnackbarMessages.info('Адаптер "$adapterId" удален'),
    );
  }

  /// Загружает набор адаптеров.
  /// Loads adapter set.
  void _loadAdapterSet(List<SnackbarAdapter> adapters) {
    setState(() {
      _adapters = [...adapters];
    });
    
    _controller.showSnackbar(
      SnackbarMessages.success('Загружен набор из ${adapters.length} адаптеров'),
    );
  }

  /// Очищает все адаптеры.
  /// Clears all adapters.
  void _clearAllAdapters() {
    setState(() {
      _adapters = [];
    });
    
    _controller.showSnackbar(
      SnackbarMessages.info('Все адаптеры удалены'),
    );
  }

  /// Добавляет пользовательский таймер-адаптер.
  /// Adds custom timer adapter.
  void _addCustomTimerAdapter() {
    final adapter = CustomSnackbarAdapter(
      id: 'timer_${DateTime.now().millisecondsSinceEpoch}',
      initialize: (controller) {
        int countdown = 5;
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (countdown > 0) {
            controller.updateMessage(
              'countdown',
              BasicSnackbarMessage(
                id: 'countdown',
                message: '⏰ Таймер: $countdown секунд',
                type: SnackbarType.info,
                persistent: true,
              ),
            );
            countdown--;
          } else {
            timer.cancel();
            controller.hideSnackbar('countdown');
            controller.showSnackbar(
              SnackbarMessages.success('⏰ Время истекло!'),
            );
          }
        });
      },
    );
    
    _addAdapter(adapter);
  }
}

void main() {
  runApp(const AdaptersExampleApp());
}
