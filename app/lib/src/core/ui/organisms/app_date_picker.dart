import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_button.dart';
import 'app_calendar.dart';
import 'app_dialog.dart';

class AppDatePicker extends StatelessWidget {
  const AppDatePicker({
    this.value,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.placeholder = 'Selecionar data',
    super.key,
  });

  final DateTime? value;
  final ValueChanged<DateTime>? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String placeholder;

  Future<void> _open(BuildContext context) async {
    final selected = await showDialog<DateTime>(
      context: context,
      barrierColor: context.tokens.colors.scrim.withValues(alpha: context.tokens.opacity.dialogBarrier),
      builder: (context) => AppDialog(
        title: placeholder,
        content: AppCalendar(
          selectedDate: value,
          firstDate: firstDate,
          lastDate: lastDate,
          onSelected: (date) => Navigator.pop(context, date),
        ),
      ),
    );
    if (selected != null) onChanged?.call(selected);
  }

  @override
  Widget build(BuildContext context) => AppButton(
    label: value == null ? placeholder : '${value!.day}/${value!.month}/${value!.year}',
    icon: AppIcons.calendar,
    variant: AppButtonVariant.outline,
    onPressed: onChanged == null ? null : () => _open(context),
  );
}
