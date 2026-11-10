import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_button.dart';

class AppPagination extends StatelessWidget {
  const AppPagination({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    super.key,
  }) : assert(currentPage > 0, 'Current page must be positive.'),
       assert(totalPages > 0, 'Total pages must be positive.'),
       assert(currentPage <= totalPages, 'Current page must not exceed total pages.');

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final first = math.max(1, currentPage - 2);
    final last = math.min(totalPages, first + 4);
    return Semantics(
      label: 'Paginação',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _PaginationLink(
              label: 'Anterior',
              leadingIcon: AppIcons.chevronLeft,
              onPressed: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
            ),
            SizedBox(width: context.tokens.spacing.xxs),
            for (var page = first; page <= last; page++) ...[
              Semantics(
                selected: page == currentPage,
                child: AppButton(
                  label: '$page',
                  variant: page == currentPage ? AppButtonVariant.outline : AppButtonVariant.text,
                  semanticLabel: 'Página $page',
                  onPressed: () {
                    if (page != currentPage) onPageChanged(page);
                  },
                ),
              ),
              SizedBox(width: context.tokens.spacing.xxs),
            ],
            _PaginationLink(
              label: 'Próxima',
              trailingIcon: AppIcons.chevronRight,
              onPressed: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _PaginationLink extends StatelessWidget {
  const _PaginationLink({
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: label,
    child: Opacity(
      opacity: onPressed == null ? context.tokens.opacity.half : 1,
      child: InkWell(
        onTap: onPressed,
        borderRadius: context.tokens.borders.lg,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: context.tokens.layout.controlHeight),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: context.tokens.icons.sm),
                  SizedBox(width: context.tokens.spacing.xxs),
                ],
                Text(label, style: context.tokens.typography.button),
                if (trailingIcon != null) ...[
                  SizedBox(width: context.tokens.spacing.xxs),
                  Icon(trailingIcon, size: context.tokens.icons.sm),
                ],
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
