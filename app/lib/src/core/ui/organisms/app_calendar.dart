import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppCalendar extends StatefulWidget {
  const AppCalendar({
    this.selectedDate,
    this.displayedMonth,
    this.firstDate,
    this.lastDate,
    this.onSelected,
    this.onMonthChanged,
    super.key,
  });

  final DateTime? selectedDate;
  final DateTime? displayedMonth;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime>? onSelected;
  final ValueChanged<DateTime>? onMonthChanged;

  @override
  State<AppCalendar> createState() => _AppCalendarState();
}

class _AppCalendarState extends State<AppCalendar> {
  static const _months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];
  static const _shortMonths = [
    'jan.',
    'fev.',
    'mar.',
    'abr.',
    'mai.',
    'jun.',
    'jul.',
    'ago.',
    'set.',
    'out.',
    'nov.',
    'dez.',
  ];
  static const _weekdays = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

  late DateTime _month = _resolveMonth(
    widget.displayedMonth ?? widget.selectedDate ?? DateTime.now(),
    widget.firstDate,
    widget.lastDate,
  );

  static DateTime _normalizeMonth(DateTime value) => DateTime(value.year, value.month);

  static DateTime _resolveMonth(DateTime preferred, DateTime? firstDate, DateTime? lastDate) {
    final month = _normalizeMonth(preferred);
    final firstMonth = firstDate == null ? null : _normalizeMonth(firstDate);
    final lastMonth = lastDate == null ? null : _normalizeMonth(lastDate);
    if (firstMonth != null && month.isBefore(firstMonth)) return firstMonth;
    if (lastMonth != null && month.isAfter(lastMonth)) return lastMonth;
    return month;
  }

  @override
  void didUpdateWidget(covariant AppCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _month = _resolveMonth(
      widget.displayedMonth ?? _month,
      widget.firstDate,
      widget.lastDate,
    );
  }

  bool _sameDay(DateTime? left, DateTime right) =>
      left != null && left.year == right.year && left.month == right.month && left.day == right.day;

  bool _enabled(DateTime date) =>
      (widget.firstDate == null || !date.isBefore(DateUtils.dateOnly(widget.firstDate!))) &&
      (widget.lastDate == null || !date.isAfter(DateUtils.dateOnly(widget.lastDate!)));

  bool _monthEnabled(DateTime month) {
    final normalized = _normalizeMonth(month);
    final firstMonth = widget.firstDate == null ? null : _normalizeMonth(widget.firstDate!);
    final lastMonth = widget.lastDate == null ? null : _normalizeMonth(widget.lastDate!);
    return (firstMonth == null || !normalized.isBefore(firstMonth)) &&
        (lastMonth == null || !normalized.isAfter(lastMonth));
  }

  void _setMonth(DateTime month) {
    final normalized = _normalizeMonth(month);
    if (!_monthEnabled(normalized) || normalized == _month) return;
    setState(() => _month = normalized);
    widget.onMonthChanged?.call(normalized);
  }

  void _moveMonth(int offset) => _setMonth(DateTime(_month.year, _month.month + offset));

  void _selectDate(DateTime date) {
    if (date.month != _month.month || date.year != _month.year) {
      _setMonth(date);
    }
    widget.onSelected?.call(date);
  }

  void _selectYear(int year) {
    final firstMonth = widget.firstDate?.year == year ? widget.firstDate!.month : DateTime.january;
    final lastMonth = widget.lastDate?.year == year ? widget.lastDate!.month : DateTime.december;
    _setMonth(DateTime(year, _month.month.clamp(firstMonth, lastMonth)));
  }

  int get _firstYear {
    if (widget.firstDate != null) return widget.firstDate!.year;
    final defaultFirstYear = DateTime.now().year - 100;
    return _month.year < defaultFirstYear ? _month.year : defaultFirstYear;
  }

  int get _lastYear {
    if (widget.lastDate != null) return widget.lastDate!.year;
    final currentYear = DateTime.now().year;
    return _month.year > currentYear ? _month.year : currentYear;
  }

  @override
  Widget build(BuildContext context) {
    final firstWeekday = DateTime(_month.year, _month.month).weekday % DateTime.daysPerWeek;
    final days = DateUtils.getDaysInMonth(_month.year, _month.month);
    final rows = ((firstWeekday + days) / DateTime.daysPerWeek).ceil();
    final gridStart = DateTime(
      _month.year,
      _month.month,
      DateTime.daysPerWeek - firstWeekday + 1,
    ).subtract(const Duration(days: DateTime.daysPerWeek));
    final previousMonthEnabled = _monthEnabled(DateTime(_month.year, _month.month - 1));
    final nextMonthEnabled = _monthEnabled(DateTime(_month.year, _month.month + 1));

    return Semantics(
      label: 'Calendário de ${_months[_month.month - 1]} de ${_month.year}',
      child: Container(
        padding: EdgeInsets.all(context.tokens.spacing.sm),
        decoration: BoxDecoration(
          color: context.tokens.colors.card,
          border: Border.all(color: context.tokens.colors.border),
          borderRadius: context.tokens.borders.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _CalendarNavigationButton(
                  icon: AppIcons.chevronLeftStrong,
                  label: 'Mês anterior',
                  onPressed: previousMonthEnabled ? () => _moveMonth(-1) : null,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CalendarSelector<int>(
                        key: const ValueKey('calendar-month-selector'),
                        value: _month.month,
                        semanticLabel: 'Selecionar mês',
                        values: List<int>.generate(DateTime.monthsPerYear, (index) => index + 1),
                        labelFor: (month) => _shortMonths[month - 1],
                        enabledFor: (month) => _monthEnabled(DateTime(_month.year, month)),
                        onChanged: (month) => _setMonth(DateTime(_month.year, month)),
                      ),
                      SizedBox(width: context.tokens.spacing.xs),
                      _CalendarSelector<int>(
                        key: const ValueKey('calendar-year-selector'),
                        value: _month.year,
                        semanticLabel: 'Selecionar ano',
                        values: [for (var year = _firstYear; year <= _lastYear; year++) year],
                        labelFor: (year) => '$year',
                        onChanged: _selectYear,
                      ),
                    ],
                  ),
                ),
                _CalendarNavigationButton(
                  icon: AppIcons.chevronRightStrong,
                  label: 'Próximo mês',
                  onPressed: nextMonthEnabled ? () => _moveMonth(1) : null,
                ),
              ],
            ),
            SizedBox(height: context.tokens.spacing.sm),
            Row(
              children: [
                for (final weekday in _weekdays)
                  Expanded(
                    child: Center(
                      child: Text(
                        weekday,
                        style: context.tokens.typography.labelSmall.copyWith(
                          color: context.tokens.colors.onSurfaceMuted,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: context.tokens.spacing.xs),
            for (var row = 0; row < rows; row++)
              Row(
                children: [
                  for (var column = 0; column < DateTime.daysPerWeek; column++)
                    Expanded(
                      child: _CalendarDay(
                        date: gridStart.add(
                          Duration(days: row * DateTime.daysPerWeek + column),
                        ),
                        selectedDate: widget.selectedDate,
                        enabled: _enabled(
                          gridStart.add(
                            Duration(days: row * DateTime.daysPerWeek + column),
                          ),
                        ),
                        outside:
                            gridStart.add(Duration(days: row * DateTime.daysPerWeek + column)).month != _month.month,
                        sameDay: _sameDay,
                        onSelected: widget.onSelected == null ? null : _selectDate,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _CalendarNavigationButton extends StatelessWidget {
  const _CalendarNavigationButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    button: true,
    enabled: onPressed != null,
    onTap: onPressed,
    excludeSemantics: true,
    child: Tooltip(
      message: label,
      child: Material(
        color: context.tokens.colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: context.tokens.borders.sm,
          child: SizedBox.square(
            dimension: context.tokens.layout.controlHeight,
            child: Icon(
              icon,
              size: context.tokens.icons.sm,
              color: onPressed == null
                  ? context.tokens.colors.onSurfaceMuted.withValues(
                      alpha: context.tokens.opacity.half,
                    )
                  : context.tokens.colors.onSurface,
            ),
          ),
        ),
      ),
    ),
  );
}

class _CalendarSelector<T> extends StatelessWidget {
  const _CalendarSelector({
    required this.value,
    required this.semanticLabel,
    required this.values,
    required this.labelFor,
    required this.onChanged,
    this.enabledFor,
    super.key,
  });

  final T value;
  final String semanticLabel;
  final List<T> values;
  final String Function(T value) labelFor;
  final bool Function(T value)? enabledFor;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final textStyle = context.tokens.typography.button.copyWith(
      color: context.tokens.colors.onSurface,
    );

    return Semantics(
      label: semanticLabel,
      button: true,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          borderRadius: context.tokens.borders.lg,
          dropdownColor: context.tokens.colors.popover,
          focusColor: context.tokens.colors.transparent,
          icon: Padding(
            padding: EdgeInsets.only(left: context.tokens.spacing.xxs),
            child: Icon(
              AppIcons.expandMoreStrong,
              size: context.tokens.icons.sm,
              color: context.tokens.colors.onSurfaceMuted,
            ),
          ),
          style: textStyle,
          selectedItemBuilder: (context) => [
            for (final item in values)
              Align(
                alignment: Alignment.center,
                child: Text(labelFor(item), style: textStyle),
              ),
          ],
          items: [
            for (final item in values)
              DropdownMenuItem<T>(
                value: item,
                enabled: enabledFor?.call(item) ?? true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: context.tokens.icons.md,
                      child: item == value
                          ? Icon(
                              AppIcons.check,
                              size: context.tokens.icons.sm,
                              color: context.tokens.colors.onSurface,
                            )
                          : null,
                    ),
                    SizedBox(width: context.tokens.spacing.xs),
                    Text(labelFor(item), style: textStyle),
                  ],
                ),
              ),
          ],
          onChanged: (next) {
            if (next != null) onChanged(next);
          },
        ),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.date,
    required this.selectedDate,
    required this.enabled,
    required this.outside,
    required this.sameDay,
    required this.onSelected,
  });

  final DateTime date;
  final DateTime? selectedDate;
  final bool enabled;
  final bool outside;
  final bool Function(DateTime?, DateTime) sameDay;
  final ValueChanged<DateTime>? onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = sameDay(selectedDate, date);
    final foreground = selected
        ? context.tokens.colors.onPrimary
        : outside || !enabled
        ? context.tokens.colors.onSurfaceMuted
        : context.tokens.colors.onSurface;
    return Semantics(
      label: '${date.day}/${date.month}/${date.year}',
      selected: selected,
      button: true,
      enabled: enabled && onSelected != null,
      child: InkWell(
        onTap: enabled && onSelected != null ? () => onSelected!(date) : null,
        borderRadius: context.tokens.borders.sm,
        child: Opacity(
          opacity: enabled ? 1 : context.tokens.opacity.half,
          child: Container(
            height: context.tokens.layout.controlHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? context.tokens.colors.primary : context.tokens.colors.transparent,
              borderRadius: context.tokens.borders.sm,
            ),
            child: Text(
              '${date.day}',
              style: context.tokens.typography.bodySmall.copyWith(color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}
