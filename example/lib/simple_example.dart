import 'package:flutter/material.dart';
import 'package:noty/noty.dart';

/// Простой пример использования пакета Noty.
///
/// Демонстрирует базовые возможности:
/// - Основные типы сообщений
/// - Простое управление
/// - Минимальная настройка
///
/// ---
///
/// Simple example of Noty package usage.
///
/// Demonstrates basic features:
/// - Main message types
/// - Simple management
/// - Minimal configuration
class SimpleExampleApp extends StatelessWidget {
  const SimpleExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Noty Simple Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SimpleHomePage(),
    );
  }
}

class SimpleHomePage extends StatelessWidget {
  const SimpleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Создаем контроллер для управления снэкбарами
    // Create controller for managing snackbars
    final controller = SnackbarController();

    return SnackbarOverlay(
      controller: controller,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Noty Simple Example'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Попробуйте различные типы сообщений:',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Информационное сообщение
                // Info message
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.info),
                    label: const Text('Показать информацию'),
                    onPressed: () {
                      controller.showSnackbar(
                        SnackbarMessages.info('Это информационное сообщение'),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Сообщение об успехе
                // Success message
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Показать успех'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      controller.showSnackbar(
                        SnackbarMessages.success('Операция выполнена успешно!'),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Предупреждение
                // Warning message
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.warning),
                    label: const Text('Показать предупреждение'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      controller.showSnackbar(
                        SnackbarMessages.warning('Внимание! Проверьте данные'),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Сообщение об ошибке
                // Error message
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.error),
                    label: const Text('Показать ошибку'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      controller.showSnackbar(
                        SnackbarMessages.error(
                          'Произошла ошибка при выполнении операции',
                          actions: [
                            SnackbarAction(
                              label: 'Повторить',
                              onPressed: () {
                                controller.showSnackbar(
                                  SnackbarMessages.info('Повторная попытка...'),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Индикатор загрузки
                // Loading indicator
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Показать загрузку'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      // Показываем индикатор загрузки
                      // Show loading indicator
                      controller.showSnackbar(
                        SnackbarMessages.loading(
                          'Загрузка данных...',
                          customId: 'loading_demo',
                        ),
                      );
                      
                      // Скрываем через 3 секунды
                      // Hide after 3 seconds
                      Future.delayed(const Duration(seconds: 3), () {
                        controller.hideSnackbar('loading_demo');
                        controller.showSnackbar(
                          SnackbarMessages.success('Данные загружены!'),
                        );
                      });
                    },
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Кнопка для очистки всех сообщений
                // Button to clear all messages
                OutlinedButton.icon(
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Очистить все сообщения'),
                  onPressed: () {
                    controller.clearAll();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const SimpleExampleApp());
}
