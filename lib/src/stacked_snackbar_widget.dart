import 'package:flutter/material.dart';
import 'snackbar_message.dart';
import 'snackbar_types.dart';
import 'snackbar_overlay.dart';

/// Виджет для отображения отдельного снэкбара в стеке.
///
/// [StackedSnackbarWidget] - это анимированный виджет, который:
/// - Отображает одно сообщение с соответствующим стилем
/// - Поддерживает анимации появления, стекирования и исчезновения
/// - Автоматически позиционируется в стеке относительно других сообщений
/// - Реагирует на изменения позиции в стеке с плавными переходами
///
/// Особенности анимации:
/// - Slide animation: появление сбоку экрана
/// - Scale animation: уменьшение масштаба для элементов в глубине стека
/// - Opacity animation: снижение прозрачности для создания эффекта глубины
/// - Position animation: плавное изменение позиции при перестановке
///
/// Визуальные эффекты стекирования:
/// - Каждый последующий элемент немного меньше по размеру
/// - Каждый последующий элемент немного прозрачнее
/// - Каждый последующий элемент имеет большую высоту (elevation)
/// - Каждый последующий элемент имеет более темный цвет фона
///
/// ---
///
/// Widget for displaying individual snackbar in stack.
///
/// [StackedSnackbarWidget] is an animated widget that:
/// - Displays single message with appropriate styling
/// - Supports appearance, stacking and disappearance animations
/// - Automatically positions in stack relative to other messages
/// - Reacts to stack position changes with smooth transitions
///
/// Animation features:
/// - Slide animation: appearance from screen side
/// - Scale animation: size reduction for elements deeper in stack
/// - Opacity animation: transparency reduction for depth effect
/// - Position animation: smooth position change during reordering
///
/// Stacking visual effects:
/// - Each subsequent element is slightly smaller
/// - Each subsequent element is slightly more transparent
/// - Each subsequent element has higher elevation
/// - Each subsequent element has darker background color
class StackedSnackbarWidget extends StatefulWidget {
  /// Сообщение для отображения.
  ///
  /// ---
  ///
  /// Message to display.
  final SnackbarMessage message;

  /// Позиция сообщения в стеке (0 = верхнее, видимое полностью).
  ///
  /// Используется для расчета:
  /// - Вертикального смещения (каждый элемент ниже предыдущего)
  /// - Масштаба (элементы в глубине стека меньше)
  /// - Прозрачности (элементы в глубине стека прозрачнее)
  /// - Цвета фона (элементы в глубине стека темнее)
  ///
  /// ---
  ///
  /// Position of message in stack (0 = top, fully visible).
  ///
  /// Used for calculating:
  /// - Vertical offset (each element below previous)
  /// - Scale (elements deeper in stack are smaller)
  /// - Opacity (elements deeper in stack are more transparent)
  /// - Background color (elements deeper in stack are darker)
  final int index;

  /// Выравнивание стека на экране.
  ///
  /// Определяет направление анимации появления и позиционирование элементов.
  ///
  /// ---
  ///
  /// Stack alignment on screen.
  ///
  /// Determines appearance animation direction and element positioning.
  final StackAlignment alignment;

  /// Отступы от краев экрана.
  ///
  /// ---
  ///
  /// Padding from screen edges.
  final EdgeInsets padding;

  /// Колбэк для обработки закрытия снэкбара.
  ///
  /// Вызывается при:
  /// - Тапе на снэкбар (если нет действий)
  /// - Нажатии на кнопку закрытия (для персистентных)
  /// - Выполнении действия (для неперсистентных)
  /// - Завершении анимации исчезновения
  ///
  /// ---
  ///
  /// Callback for handling snackbar dismissal.
  ///
  /// Called when:
  /// - Tapping on snackbar (if no actions)
  /// - Pressing close button (for persistent)
  /// - Executing action (for non-persistent)
  /// - Completion of disappearance animation
  final VoidCallback onDismiss;

  const StackedSnackbarWidget({
    required this.message,
    required this.index,
    required this.alignment,
    required this.padding,
    required this.onDismiss,
  });

  @override
  State<StackedSnackbarWidget> createState() => __StackedSnackbarWidgetState();
}

class __StackedSnackbarWidgetState extends State<StackedSnackbarWidget> with SingleTickerProviderStateMixin {
  /// Основной контроллер анимации.
  ///
  /// Управляет всеми анимациями виджета синхронно.
  /// Значение от 0.0 (начальное состояние) до 1.0 (конечное состояние).
  ///
  /// ---
  ///
  /// Main animation controller.
  ///
  /// Controls all widget animations synchronously.
  /// Value from 0.0 (initial state) to 1.0 (final state).
  late AnimationController _controller;

  /// Анимация скольжения для появления снэкбара.
  ///
  /// Начальное положение зависит от [stackAlignment]:
  /// - Правые позиции: появление справа (1.0, 0.0)
  /// - Левые позиции: появление слева (-1.0, 0.0)
  /// Конечное положение: (0.0, 0.0)
  ///
  /// ---
  ///
  /// Slide animation for snackbar appearance.
  ///
  /// Initial position depends on [stackAlignment]:
  /// - Right positions: appear from right (1.0, 0.0)
  /// - Left positions: appear from left (-1.0, 0.0)
  /// Final position: (0.0, 0.0)
  late Animation<Offset> _slideAnimation;

  /// Анимация масштабирования для эффекта стекирования.
  ///
  /// Рассчитывается динамически на основе позиции в стеке:
  /// - Верхний элемент (index 0): масштаб 1.0
  /// - Каждый следующий: масштаб уменьшается на 0.05
  /// - Максимальное уменьшение: до 0.7 (30% уменьшение)
  ///
  /// ---
  ///
  /// Scale animation for stacking effect.
  ///
  /// Calculated dynamically based on stack position:
  /// - Top element (index 0): scale 1.0
  /// - Each next: scale decreases by 0.05
  /// - Maximum reduction: to 0.7 (30% reduction)
  late Animation<double> _scaleAnimation;

  /// Анимация прозрачности для эффекта глубины.
  ///
  /// Рассчитывается динамически на основе позиции в стеке:
  /// - Верхний элемент (index 0): прозрачность 1.0
  /// - Каждый следующий: прозрачность уменьшается на 0.15
  /// - Минимальная прозрачность: 0.3 (70% прозрачности)
  ///
  /// ---
  ///
  /// Opacity animation for depth effect.
  ///
  /// Calculated dynamically based on stack position:
  /// - Top element (index 0): opacity 1.0
  /// - Each next: opacity decreases by 0.15
  /// - Minimum opacity: 0.3 (70% transparency)
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Анимация появления сбоку
    // Side appearance animation
    _slideAnimation = Tween<Offset>(
      begin: _getSlideBeginOffset(),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Анимация масштаба для стекинга
    // Scale animation for stacking
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: _getTargetScale(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Анимация прозрачности для стекинга
    // Opacity animation for stacking
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: _getTargetOpacity(),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  Offset _getSlideBeginOffset() => switch (widget.alignment) {
        StackAlignment.topRight || StackAlignment.bottomRight => const Offset(1.0, 0.0),
        StackAlignment.topLeft || StackAlignment.bottomLeft => const Offset(-1.0, 0.0),
      };

  /// Рассчитывает целевой масштаб элемента в стеке.
  ///
  /// Формула: 1.0 - (index * 0.05), ограничено диапазоном [0.7, 1.0]
  ///
  /// Примеры:
  /// - index 0: масштаб 1.0 (100%)
  /// - index 1: масштаб 0.95 (95%)
  /// - index 2: масштаб 0.90 (90%)
  /// - index 6+: масштаб 0.7 (70%, минимум)
  ///
  /// Возвращает: целевой масштаб от 0.7 до 1.0
  ///
  /// ---
  ///
  /// Calculates target scale of element in stack.
  ///
  /// Formula: 1.0 - (index * 0.05), clamped to [0.7, 1.0] range
  ///
  /// Examples:
  /// - index 0: scale 1.0 (100%)
  /// - index 1: scale 0.95 (95%)
  /// - index 2: scale 0.90 (90%)
  /// - index 6+: scale 0.7 (70%, minimum)
  ///
  /// Returns: target scale from 0.7 to 1.0
  double _getTargetScale() {
    // Чем дальше в стеке, тем меньше масштаб
    // The deeper in stack, the smaller the scale
    return 1.0 - (widget.index * 0.05).clamp(0.0, 0.3);
  }

  /// Рассчитывает целевую прозрачность элемента в стеке.
  ///
  /// Формула: 1.0 - (index * 0.15), ограничено диапазоном [0.3, 1.0]
  ///
  /// Примеры:
  /// - index 0: прозрачность 1.0 (полностью видимый)
  /// - index 1: прозрачность 0.85 (15% прозрачности)
  /// - index 2: прозрачность 0.70 (30% прозрачности)
  /// - index 4+: прозрачность 0.3 (70% прозрачности, минимум)
  ///
  /// Возвращает: целевую прозрачность от 0.3 до 1.0
  ///
  /// ---
  ///
  /// Calculates target opacity of element in stack.
  ///
  /// Formula: 1.0 - (index * 0.15), clamped to [0.3, 1.0] range
  ///
  /// Examples:
  /// - index 0: opacity 1.0 (fully visible)
  /// - index 1: opacity 0.85 (15% transparency)
  /// - index 2: opacity 0.70 (30% transparency)
  /// - index 4+: opacity 0.3 (70% transparency, minimum)
  ///
  /// Returns: target opacity from 0.3 to 1.0
  double _getTargetOpacity() {
    // Чем дальше в стеке, тем прозрачнее
    // The deeper in stack, the more transparent
    return (1.0 - (widget.index * 0.15)).clamp(0.3, 1.0);
  }

  @override
  void didUpdateWidget(covariant StackedSnackbarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Анимируем изменение позиции в стеке
    // Animate stack position change
    if (oldWidget.index != widget.index) {
      _scaleAnimation = Tween<double>(
        begin: _scaleAnimation.value,
        end: _getTargetScale(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));

      _opacityAnimation = Tween<double>(
        begin: _opacityAnimation.value,
        end: _getTargetOpacity(),
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Запускает анимацию исчезновения и закрывает снэкбар.
  ///
  /// Процесс:
  /// 1. Запускает обратную анимацию (reverse)
  /// 2. Ждет завершения анимации
  /// 3. Проверяет, что виджет все еще смонтирован
  /// 4. Вызывает колбэк onDismiss для удаления из overlay
  ///
  /// ---
  ///
  /// Starts disappearance animation and closes snackbar.
  ///
  /// Process:
  /// 1. Starts reverse animation
  /// 2. Waits for animation completion
  /// 3. Checks that widget is still mounted
  /// 4. Calls onDismiss callback to remove from overlay
  void _animateOut() {
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) => Positioned(
        top: _getTopPosition(mediaQuery),
        bottom: _getBottomPosition(mediaQuery),
        left: _getLeftPosition(),
        right: _getRightPosition(),
        child: Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: SlideTransition(
              position: _slideAnimation,
              child: child,
            ),
          ),
        ),
      ),
      child: _buildSnackbarContent(),
    );
  }

  /// Рассчитывает позицию сверху для верхних выравниваний.
  ///
  /// Учитывает:
  /// - Безопасную зону устройства (MediaQuery.padding.top)
  /// - Отступы виджета (widget.padding.top)
  /// - Смещение по индексу (index * 70.0 пикселей)
  ///
  /// Возвращает: позицию сверху или null для нижних выравниваний
  ///
  /// ---
  ///
  /// Calculates top position for top alignments.
  ///
  /// Considers:
  /// - Device safe area (MediaQuery.padding.top)
  /// - Widget padding (widget.padding.top)
  /// - Index offset (index * 70.0 pixels)
  ///
  /// Returns: top position or null for bottom alignments
  double? _getTopPosition(MediaQueryData mediaQuery) {
    return switch (widget.alignment) {
      StackAlignment.topLeft ||
      StackAlignment.topRight =>
        mediaQuery.padding.top + widget.padding.top + (widget.index * 70.0),
      StackAlignment.bottomLeft || StackAlignment.bottomRight => null,
    };
  }

  /// Рассчитывает позицию снизу для нижних выравниваний.
  ///
  /// Учитывает:
  /// - Безопасную зону устройства (MediaQuery.padding.bottom)
  /// - Отступы виджета (widget.padding.bottom)
  /// - Смещение по индексу (index * 70.0 пикселей)
  ///
  /// Возвращает: позицию снизу или null для верхних выравниваний
  ///
  /// ---
  ///
  /// Calculates bottom position for bottom alignments.
  ///
  /// Considers:
  /// - Device safe area (MediaQuery.padding.bottom)
  /// - Widget padding (widget.padding.bottom)
  /// - Index offset (index * 70.0 pixels)
  ///
  /// Returns: bottom position or null for top alignments
  double? _getBottomPosition(MediaQueryData mediaQuery) {
    return switch (widget.alignment) {
      StackAlignment.bottomLeft ||
      StackAlignment.bottomRight =>
        mediaQuery.padding.bottom + widget.padding.bottom + (widget.index * 70.0),
      StackAlignment.topLeft || StackAlignment.topRight => null,
    };
  }

  /// Рассчитывает позицию слева для левых выравниваний.
  ///
  /// Возвращает: отступ слева или null для правых выравниваний
  ///
  /// ---
  ///
  /// Calculates left position for left alignments.
  ///
  /// Returns: left padding or null for right alignments
  double? _getLeftPosition() {
    return switch (widget.alignment) {
      StackAlignment.topLeft || StackAlignment.bottomLeft => widget.padding.left,
      StackAlignment.topRight || StackAlignment.bottomRight => null,
    };
  }

  /// Рассчитывает позицию справа для правых выравниваний.
  ///
  /// Возвращает: отступ справа или null для левых выравниваний
  ///
  /// ---
  ///
  /// Calculates right position for right alignments.
  ///
  /// Returns: right padding or null for left alignments
  double? _getRightPosition() {
    return switch (widget.alignment) {
      StackAlignment.topRight || StackAlignment.bottomRight => widget.padding.right,
      StackAlignment.topLeft || StackAlignment.bottomLeft => null,
    };
  }

  /// Строит содержимое снэкбара с материальным дизайном.
  ///
  /// Структура:
  /// - Material с elevation, растущим с глубиной стека
  /// - GestureDetector для обработки тапов
  /// - Container с цветом фона, зависящим от типа и позиции
  /// - Column с основным содержимым и действиями
  /// - Row с иконкой, текстом и кнопкой закрытия
  /// - Опциональный ряд с кнопками действий
  ///
  /// Особенности:
  /// - Elevation увеличивается с индексом для эффекта глубины
  /// - Цвет фона темнеет для элементов в глубине стека
  /// - Критические сообщения имеют белую рамку
  /// - Персистентные сообщения показывают кнопку закрытия
  ///
  /// Возвращает: полностью построенный виджет снэкбара
  ///
  /// ---
  ///
  /// Builds snackbar content with material design.
  ///
  /// Structure:
  /// - Material with elevation growing with stack depth
  /// - GestureDetector for tap handling
  /// - Container with background color depending on type and position
  /// - Column with main content and actions
  /// - Row with icon, text and close button
  /// - Optional row with action buttons
  ///
  /// Features:
  /// - Elevation increases with index for depth effect
  /// - Background color darkens for elements deeper in stack
  /// - Critical messages have white border
  /// - Persistent messages show close button
  ///
  /// Returns: fully built snackbar widget
  Widget _buildSnackbarContent() {
    return Material(
      elevation: 6 + widget.index.toDouble(), // Больше высота для верхних элементов
      borderRadius: BorderRadius.circular(8),
      child: GestureDetector(
        onTap: widget.message.actions?.isEmpty ?? true ? _animateOut : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          constraints: const BoxConstraints(maxWidth: 300, minWidth: 200),
          decoration: BoxDecoration(
            color: _getBackgroundColor(widget.message.type),
            borderRadius: BorderRadius.circular(8),
            border:
                widget.message.priority == SnackbarPriority.critical ? Border.all(color: Colors.white, width: 2) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIcon(widget.message),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.message.message,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.message.priority == SnackbarPriority.critical ? 15 : 14,
                        fontWeight:
                            widget.message.priority == SnackbarPriority.critical ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (widget.message.persistent)
                    GestureDetector(
                      onTap: _animateOut,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                ],
              ),
              if (widget.message.actions?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.message.actions!.map((action) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: TextButton(
                        onPressed: () {
                          action.onPressed();
                          if (!widget.message.persistent) {
                            _animateOut();
                          }
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: action.textColor ?? Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          action.label,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Определяет цвет фона снэкбара на основе типа и позиции в стеке.
  ///
  /// Алгоритм:
  /// 1. Выбирает базовый цвет по типу сообщения
  /// 2. Затемняет цвет пропорционально индексу в стеке
  /// 3. Использует Color.lerp для плавного перехода к черному
  ///
  /// Базовые цвета:
  /// - Info: синий (Colors.blue)
  /// - Success: зеленый (Colors.green)
  /// - Warning: оранжевый (Colors.orange)
  /// - Error: красный (Colors.red)
  /// - Loading: синий (Colors.blue)
  ///
  /// Затемнение: каждый индекс добавляет 10% черного цвета
  ///
  /// Параметры:
  /// - [type] - тип сообщения
  ///
  /// Возвращает: рассчитанный цвет фона
  ///
  /// ---
  ///
  /// Determines snackbar background color based on type and stack position.
  ///
  /// Algorithm:
  /// 1. Selects base color by message type
  /// 2. Darkens color proportionally to stack index
  /// 3. Uses Color.lerp for smooth transition to black
  ///
  /// Base colors:
  /// - Info: blue (Colors.blue)
  /// - Success: green (Colors.green)
  /// - Warning: orange (Colors.orange)
  /// - Error: red (Colors.red)
  /// - Loading: blue (Colors.blue)
  ///
  /// Darkening: each index adds 10% black color
  ///
  /// Parameters:
  /// - [type] - message type
  ///
  /// Returns: calculated background color
  Color _getBackgroundColor(SnackbarType type) {
    final baseColor = switch (type) {
      SnackbarType.info => Colors.blue,
      SnackbarType.success => Colors.green,
      SnackbarType.warning => Colors.orange,
      SnackbarType.error => Colors.red,
      SnackbarType.loading => Colors.blue,
    };

    // Делаем цвет темнее для элементов в стеке
    // Make color darker for elements in stack
    return Color.lerp(baseColor, Colors.black, widget.index * 0.1) ?? baseColor;
  }

  /// Строит иконку для сообщения с индикаторами приоритета.
  ///
  /// Логика выбора иконки:
  /// 1. Если у сообщения есть пользовательская иконка - использует её
  /// 2. Иначе выбирает стандартную иконку по типу:
  ///    - Loading: анимированный CircularProgressIndicator
  ///    - Success: галочка (check_circle)
  ///    - Error: ошибка (error)
  ///    - Warning: предупреждение (warning)
  ///    - Info: информация (info)
  ///
  /// Для критических сообщений добавляет желтый индикатор в правом верхнем углу.
  ///
  /// Параметры:
  /// - [message] - сообщение для построения иконки
  ///
  /// Возвращает: виджет иконки с возможными индикаторами
  ///
  /// ---
  ///
  /// Builds icon for message with priority indicators.
  ///
  /// Icon selection logic:
  /// 1. If message has custom icon - uses it
  /// 2. Otherwise selects standard icon by type:
  ///    - Loading: animated CircularProgressIndicator
  ///    - Success: checkmark (check_circle)
  ///    - Error: error (error)
  ///    - Warning: warning (warning)
  ///    - Info: information (info)
  ///
  /// For critical messages adds yellow indicator in top-right corner.
  ///
  /// Parameters:
  /// - [message] - message to build icon for
  ///
  /// Returns: icon widget with possible indicators
  Widget _buildIcon(SnackbarMessage message) {
    if (message.icon != null) {
      return message.icon!;
    }

    final iconWidget = switch (message.type) {
      SnackbarType.loading => const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      SnackbarType.success => const Icon(Icons.check_circle, color: Colors.white, size: 16),
      SnackbarType.error => const Icon(Icons.error, color: Colors.white, size: 16),
      SnackbarType.warning => const Icon(Icons.warning, color: Colors.white, size: 16),
      SnackbarType.info => const Icon(Icons.info, color: Colors.white, size: 16),
    };

    // Добавляем индикатор приоритета для критических сообщений
    // Add priority indicator for critical messages
    if (message.priority == SnackbarPriority.critical) {
      return Stack(
        children: [
          iconWidget,
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.yellow,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      );
    }

    return iconWidget;
  }
}
