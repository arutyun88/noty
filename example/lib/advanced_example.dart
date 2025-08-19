import 'package:flutter/material.dart';
import 'package:noty/noty.dart';

/// Расширенный пример использования пакета Noty.
///
/// Демонстрирует все основные возможности:
/// - Различные типы сообщений
/// - Настройка приоритетов
/// - Интерактивные действия
/// - Группировка сообщений
/// - Адаптеры для внешних систем
/// - Различные позиции на экране
/// - Утилитарные методы и миксины
///
/// ---
///
/// Advanced example of Noty package usage.
///
/// Demonstrates all main features:
/// - Different message types
/// - Priority configuration
/// - Interactive actions
/// - Message grouping
/// - Adapters for external systems
/// - Different screen positions
/// - Utility methods and mixins
class AdvancedExampleApp extends StatelessWidget {
  const AdvancedExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noty Advanced Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> with SnackbarMixin {
  /// Контроллер снэкбаров для управления сообщениями.
  /// Controller for managing snackbar messages.
  late final SnackbarController _controller;

  /// Текущая позиция стека снэкбаров.
  /// Current snackbar stack position.
  StackAlignment _stackAlignment = StackAlignment.topRight;

  /// Максимальное количество видимых сообщений.
  /// Maximum number of visible messages.
  int _maxVisibleMessages = 5;

  /// Счетчик для генерации уникальных ID сообщений.
  /// Counter for generating unique message IDs.
  int _messageCounter = 0;

  @override
  void initState() {
    super.initState();
    _controller = SnackbarController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Генерирует уникальный ID для сообщения.
  /// Generates unique ID for message.
  String _generateMessageId() => 'msg_${++_messageCounter}';

  @override
  Widget build(BuildContext context) {
    return SnackbarOverlay(
      controller: _controller,
      alignment: _stackAlignment,
      maxVisibleMessages: _maxVisibleMessages,
      adapters: [
        // Адаптер для мониторинга сети
        // Network monitoring adapter
        const NetworkSnackbarAdapter(),
        
        // Пользовательский адаптер для демонстрации
        // Custom adapter for demonstration
        CustomSnackbarAdapter(
          id: 'demo_adapter',
          initialize: (controller) {
            // Показываем приветственное сообщение через 2 секунды
            // Show welcome message after 2 seconds
            Future.delayed(const Duration(seconds: 2), () {
              controller.showSnackbar(
                BasicSnackbarMessage(
                  id: 'welcome',
                  message: 'Добро пожаловать в Noty! 🎉',
                  type: SnackbarType.info,
                  priority: SnackbarPriority.high,
                  actions: [
                    SnackbarAction(
                      label: 'Спасибо',
                      onPressed: () {
                        debugPrint('Welcome acknowledged');
                      },
                    ),
                  ],
                ),
              );
            });
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Noty Advanced Example'),
          actions: [
            // Кнопка для очистки всех сообщений
            // Button to clear all messages
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () => clearAllSnackbars(_controller),
              tooltip: 'Очистить все сообщения',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Настройки позиции и лимитов
              // Position and limits settings
              _buildSettingsSection(),
              
              const SizedBox(height: 24),
              
              // Базовые типы сообщений
              // Basic message types
              _buildBasicMessagesSection(),
              
              const SizedBox(height: 24),
              
              // Сообщения с приоритетами
              // Priority messages
              _buildPriorityMessagesSection(),
              
              const SizedBox(height: 24),
              
              // Сообщения с действиями
              // Messages with actions
              _buildActionMessagesSection(),
              
              const SizedBox(height: 24),
              
              // Группированные сообщения
              // Grouped messages
              _buildGroupedMessagesSection(),
              
              const SizedBox(height: 24),
              
              // Специальные сценарии
              // Special scenarios
              _buildSpecialScenariosSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// Строит секцию настроек.
  /// Builds settings section.
  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Настройки / Settings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Выбор позиции стека
            // Stack position selection
            Text('Позиция стека / Stack Position:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: StackAlignment.values.map((alignment) {
                return ChoiceChip(
                  label: Text(_getAlignmentLabel(alignment)),
                  selected: _stackAlignment == alignment,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _stackAlignment = alignment;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Настройка максимального количества сообщений
            // Maximum messages configuration
            Text('Максимум сообщений / Max Messages: $_maxVisibleMessages'),
            Slider(
              value: _maxVisibleMessages.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (value) {
                setState(() {
                  _maxVisibleMessages = value.round();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Строит секцию базовых сообщений.
  /// Builds basic messages section.
  Widget _buildBasicMessagesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Базовые типы / Basic Types',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.info),
                  label: const Text('Info'),
                  onPressed: () => showInfo(_controller, 'Информационное сообщение'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Success'),
                  onPressed: () => showSuccess(_controller, 'Операция выполнена успешно!'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.warning),
                  label: const Text('Warning'),
                  onPressed: () => showWarning(_controller, 'Внимание! Проверьте данные'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.error),
                  label: const Text('Error'),
                  onPressed: () => showError(_controller, 'Произошла ошибка при выполнении операции'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Loading'),
                  onPressed: () {
                    final id = _generateMessageId();
                    showLoading(_controller, 'Загрузка данных...', id: id);
                    
                    // Автоматически скрываем через 3 секунды
                    // Auto-hide after 3 seconds
                    Future.delayed(const Duration(seconds: 3), () {
                      hideLoading(_controller, id: id);
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Строит секцию сообщений с приоритетами.
  /// Builds priority messages section.
  Widget _buildPriorityMessagesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Приоритеты / Priorities',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _controller.showSnackbar(
                    BasicSnackbarMessage(
                      id: _generateMessageId(),
                      message: 'Низкий приоритет - второстепенная информация',
                      type: SnackbarType.info,
                      priority: SnackbarPriority.low,
                    ),
                  ),
                  child: const Text('Low Priority'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.showSnackbar(
                    BasicSnackbarMessage(
                      id: _generateMessageId(),
                      message: 'Обычный приоритет - стандартное уведомление',
                      type: SnackbarType.info,
                      priority: SnackbarPriority.normal,
                    ),
                  ),
                  child: const Text('Normal Priority'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.showSnackbar(
                    BasicSnackbarMessage(
                      id: _generateMessageId(),
                      message: 'Высокий приоритет - важное уведомление',
                      type: SnackbarType.warning,
                      priority: SnackbarPriority.high,
                    ),
                  ),
                  child: const Text('High Priority'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.showSnackbar(
                    BasicSnackbarMessage(
                      id: _generateMessageId(),
                      message: '🚨 КРИТИЧЕСКИЙ ПРИОРИТЕТ - требует немедленного внимания!',
                      type: SnackbarType.error,
                      priority: SnackbarPriority.critical,
                      persistent: true,
                    ),
                  ),
                  child: const Text('Critical Priority'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Строит секцию сообщений с действиями.
  /// Builds action messages section.
  Widget _buildActionMessagesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Интерактивные действия / Interactive Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _controller.showSnackbar(
                    BasicSnackbarMessage(
                      id: _generateMessageId(),
                      message: 'Ошибка сети. Проверьте подключение к интернету.',
                      type: SnackbarType.error,
                      actions: [
                        SnackbarAction(
                          label: 'Повторить',
                          onPressed: () {
                            showSuccess(_controller, 'Повторная попытка...');
                          },
                        ),
                        SnackbarAction(
                          label: 'Настройки',
                          onPressed: () {
                            showInfo(_controller, 'Открываем настройки сети');
                          },
                          textColor: Colors.yellow,
                        ),
                      ],
                    ),
                  ),
                  child: const Text('Network Error'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.showSnackbar(
                    BasicSnackbarMessage(
                      id: _generateMessageId(),
                      message: 'Доступно обновление приложения до версии 2.0',
                      type: SnackbarType.info,
                      persistent: true,
                      actions: [
                        SnackbarAction(
                          label: 'Обновить',
                          onPressed: () {
                            showLoading(_controller, 'Скачивание обновления...', id: 'update_download');
                            Future.delayed(const Duration(seconds: 2), () {
                              hideLoading(_controller, id: 'update_download');
                              showSuccess(_controller, 'Обновление установлено!');
                            });
                          },
                        ),
                        SnackbarAction(
                          label: 'Позже',
                          onPressed: () {
                            showInfo(_controller, 'Напомним позже');
                          },
                        ),
                      ],
                    ),
                  ),
                  child: const Text('App Update'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.showSnackbar(
                    BasicSnackbarMessage(
                      id: _generateMessageId(),
                      message: 'Файл "document.pdf" готов к загрузке',
                      type: SnackbarType.success,
                      actions: [
                        SnackbarAction(
                          label: 'Скачать',
                          onPressed: () {
                            showSuccess(_controller, 'Начинаем загрузку файла');
                          },
                        ),
                        SnackbarAction(
                          label: 'Поделиться',
                          onPressed: () {
                            showInfo(_controller, 'Открываем меню "Поделиться"');
                          },
                        ),
                        SnackbarAction(
                          label: 'Просмотр',
                          onPressed: () {
                            showInfo(_controller, 'Открываем файл для просмотра');
                          },
                        ),
                      ],
                    ),
                  ),
                  child: const Text('File Ready'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Строит секцию группированных сообщений.
  /// Builds grouped messages section.
  Widget _buildGroupedMessagesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Группированные сообщения / Grouped Messages',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _showSyncMessages(),
                  child: const Text('Sync Messages'),
                ),
                ElevatedButton(
                  onPressed: () => _showDownloadMessages(),
                  child: const Text('Download Messages'),
                ),
                ElevatedButton(
                  onPressed: () => _showNotificationMessages(),
                  child: const Text('Notification Messages'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.hideGroup('sync'),
                  child: const Text('Hide Sync Group'),
                ),
                ElevatedButton(
                  onPressed: () => _controller.hideGroup('downloads'),
                  child: const Text('Hide Download Group'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Строит секцию специальных сценариев.
  /// Builds special scenarios section.
  Widget _buildSpecialScenariosSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Специальные сценарии / Special Scenarios',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _showMessageFlood(),
                  child: const Text('Message Flood'),
                ),
                ElevatedButton(
                  onPressed: () => _showProgressSequence(),
                  child: const Text('Progress Sequence'),
                ),
                ElevatedButton(
                  onPressed: () => _showCustomStyledMessage(),
                  child: const Text('Custom Styled'),
                ),
                ElevatedButton(
                  onPressed: () => _showLongMessage(),
                  child: const Text('Long Message'),
                ),
                ElevatedButton(
                  onPressed: () => _testSpamPrevention(),
                  child: const Text('Test Spam Prevention'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Показывает сообщения синхронизации.
  /// Shows sync messages.
  void _showSyncMessages() {
    _controller.showMultiple([
      BasicSnackbarMessage(
        id: 'sync_start',
        message: 'Начинаем синхронизацию данных...',
        type: SnackbarType.loading,
        groupId: 'sync',
      ),
      BasicSnackbarMessage(
        id: 'sync_contacts',
        message: 'Синхронизация контактов (1/3)',
        type: SnackbarType.info,
        groupId: 'sync',
      ),
      BasicSnackbarMessage(
        id: 'sync_photos',
        message: 'Синхронизация фотографий (2/3)',
        type: SnackbarType.info,
        groupId: 'sync',
      ),
    ]);

    // Имитируем завершение синхронизации
    // Simulate sync completion
    Future.delayed(const Duration(seconds: 3), () {
      _controller.updateMessage(
        'sync_start',
        BasicSnackbarMessage(
          id: 'sync_complete',
          message: '✅ Синхронизация завершена успешно!',
          type: SnackbarType.success,
          groupId: 'sync',
        ),
      );
    });
  }

  /// Показывает сообщения загрузки.
  /// Shows download messages.
  void _showDownloadMessages() {
    final files = ['photo1.jpg', 'document.pdf', 'video.mp4'];
    
    for (int i = 0; i < files.length; i++) {
      Future.delayed(Duration(milliseconds: i * 500), () {
        _controller.showSnackbar(
          BasicSnackbarMessage(
            id: 'download_${files[i]}',
            message: 'Загружается ${files[i]}...',
            type: SnackbarType.loading,
            groupId: 'downloads',
          ),
        );
        
        // Завершаем загрузку через случайное время
        // Complete download after random time
        Future.delayed(Duration(seconds: 2 + i), () {
          _controller.updateMessage(
            'download_${files[i]}',
            BasicSnackbarMessage(
              id: 'download_${files[i]}_complete',
              message: '📁 ${files[i]} загружен',
              type: SnackbarType.success,
              groupId: 'downloads',
            ),
          );
        });
      });
    }
  }

  /// Показывает уведомления.
  /// Shows notification messages.
  void _showNotificationMessages() {
    final notifications = [
      'У вас 3 новых сообщения',
      'Напоминание: встреча через 15 минут',
      'Обновление статуса проекта',
    ];

    for (int i = 0; i < notifications.length; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () {
        _controller.showSnackbar(
          BasicSnackbarMessage(
            id: 'notification_$i',
            message: notifications[i],
            type: SnackbarType.info,
            groupId: 'notifications',
            priority: SnackbarPriority.high,
          ),
        );
      });
    }
  }

  /// Показывает поток сообщений для тестирования лимитов.
  /// Shows message flood to test limits.
  void _showMessageFlood() {
    for (int i = 0; i < 15; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        _controller.showSnackbar(
          BasicSnackbarMessage(
            id: 'flood_$i',
            message: 'Сообщение #${i + 1} из потока',
            type: SnackbarType.values[i % SnackbarType.values.length],
            priority: SnackbarPriority.values[i % SnackbarPriority.values.length],
          ),
        );
      });
    }
  }

  /// Показывает последовательность прогресса.
  /// Shows progress sequence.
  void _showProgressSequence() {
    final steps = [
      'Инициализация...',
      'Подключение к серверу...',
      'Аутентификация...',
      'Загрузка данных...',
      'Обработка результатов...',
      'Завершение...',
    ];

    for (int i = 0; i < steps.length; i++) {
      Future.delayed(Duration(seconds: i), () {
        if (i == steps.length - 1) {
          _controller.showSnackbar(
            BasicSnackbarMessage(
              id: 'progress',
              message: '🎉 ${steps[i]}',
              type: SnackbarType.success,
            ),
          );
        } else {
          _controller.updateMessage(
            'progress',
            BasicSnackbarMessage(
              id: 'progress',
              message: '⏳ ${steps[i]} (${i + 1}/${steps.length})',
              type: SnackbarType.loading,
            ),
          );
        }
      });
    }
  }

  /// Показывает сообщение с пользовательским стилем.
  /// Shows custom styled message.
  void _showCustomStyledMessage() {
    _controller.showSnackbar(
      BasicSnackbarMessage(
        id: _generateMessageId(),
        message: 'Пользовательское сообщение с иконкой',
        type: SnackbarType.info,
        icon: const Icon(Icons.star, color: Colors.amber),
        duration: const Duration(seconds: 5),
        actions: [
          SnackbarAction(
            label: '⭐ Нравится',
            onPressed: () {
              showSuccess(_controller, 'Спасибо за оценку!');
            },
            textColor: Colors.amber,
          ),
        ],
      ),
    );
  }

  /// Показывает длинное сообщение.
  /// Shows long message.
  void _showLongMessage() {
    _controller.showSnackbar(
      BasicSnackbarMessage(
        id: _generateMessageId(),
        message: 'Это очень длинное сообщение, которое демонстрирует, как система обрабатывает '
                'большие объемы текста. Сообщение может содержать подробную информацию о '
                'произошедшем событии, инструкции для пользователя или детальное описание ошибки.',
        type: SnackbarType.warning,
        duration: const Duration(seconds: 8),
        actions: [
          SnackbarAction(
            label: 'Подробнее',
            onPressed: () {
              showInfo(_controller, 'Открываем подробную информацию');
            },
          ),
        ],
      ),
    );
  }

  /// Тестирует защиту от спама.
  /// Tests spam prevention.
  void _testSpamPrevention() {
    // Пытаемся показать одно и то же сообщение несколько раз быстро
    // Try to show the same message multiple times quickly
    for (int i = 0; i < 5; i++) {
      _controller.showSnackbar(
        BasicSnackbarMessage(
          id: 'spam_test',
          message: 'Тест защиты от спама - попытка #${i + 1}',
          type: SnackbarType.info,
        ),
      );
    }
    
    showInfo(_controller, 'Защита от спама активирована! Дублирующиеся сообщения заблокированы.');
  }

  /// Возвращает читаемое название для позиции стека.
  /// Returns readable label for stack alignment.
  String _getAlignmentLabel(StackAlignment alignment) {
    return switch (alignment) {
      StackAlignment.topLeft => 'Верх-Лево',
      StackAlignment.topRight => 'Верх-Право',
      StackAlignment.bottomLeft => 'Низ-Лево',
      StackAlignment.bottomRight => 'Низ-Право',
    };
  }
}

void main() {
  runApp(const AdvancedExampleApp());
}
