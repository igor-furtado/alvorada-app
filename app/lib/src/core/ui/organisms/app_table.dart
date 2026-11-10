import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../atoms/app_checkbox.dart';
import '../atoms/app_text_input.dart';
import '../molecules/app_pagination.dart';

@immutable
class AppTableColumn<T> {
  const AppTableColumn({
    required this.label,
    required this.cellBuilder,
    this.compare,
    this.flex = 1,
    this.alignment = Alignment.centerLeft,
    this.hideable = true,
  });

  final String label;
  final Widget Function(BuildContext context, T row) cellBuilder;
  final int Function(T left, T right)? compare;
  final int flex;
  final Alignment alignment;
  final bool hideable;
}

class AppTable<T> extends StatelessWidget {
  const AppTable({
    required this.columns,
    required this.rows,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.leadingBuilder,
    this.onRowTap,
    super.key,
  });

  final List<AppTableColumn<T>> columns;
  final List<T> rows;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex)? onSort;
  final Widget Function(BuildContext context, T row)? leadingBuilder;
  final ValueChanged<T>? onRowTap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: constraints.hasBoundedWidth
            ? math.max(constraints.maxWidth, context.tokens.layout.toolbar)
            : context.tokens.layout.toolbar,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _TableRow<T>(
              columns: columns,
              leading: leadingBuilder == null ? null : const SizedBox.shrink(),
              header: true,
              sortColumnIndex: sortColumnIndex,
              sortAscending: sortAscending,
              onSort: onSort,
            ),
            for (final row in rows)
              _TableRow<T>(
                columns: columns,
                row: row,
                leading: leadingBuilder?.call(context, row),
                onTap: onRowTap == null ? null : () => onRowTap!(row),
              ),
          ],
        ),
      ),
    ),
  );
}

class _TableRow<T> extends StatelessWidget {
  const _TableRow({
    required this.columns,
    this.row,
    this.leading,
    this.header = false,
    this.sortColumnIndex,
    this.sortAscending = true,
    this.onSort,
    this.onTap,
  });

  final List<AppTableColumn<T>> columns;
  final T? row;
  final Widget? leading;
  final bool header;
  final int? sortColumnIndex;
  final bool sortAscending;
  final void Function(int columnIndex)? onSort;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      constraints: BoxConstraints(
        minHeight: context.tokens.layout.controlHeight + context.tokens.spacing.md,
      ),
      decoration: BoxDecoration(
        color: context.tokens.colors.card,
        border: Border(bottom: BorderSide(color: context.tokens.colors.border)),
      ),
      child: Row(
        children: [
          if (leading != null)
            SizedBox(
              width: context.tokens.layout.tableActionsColumn,
              child: Center(child: leading),
            ),
          for (var index = 0; index < columns.length; index++)
            Expanded(
              flex: columns[index].flex,
              child: _TableCell<T>(
                column: columns[index],
                row: row,
                header: header,
                sorted: sortColumnIndex == index,
                sortAscending: sortAscending,
                onSort: columns[index].compare != null && onSort != null ? () => onSort!(index) : null,
              ),
            ),
        ],
      ),
    );
    if (onTap == null || header) return content;
    return InkWell(onTap: onTap, child: content);
  }
}

class _TableCell<T> extends StatelessWidget {
  const _TableCell({
    required this.column,
    required this.row,
    required this.header,
    required this.sorted,
    required this.sortAscending,
    required this.onSort,
  });

  final AppTableColumn<T> column;
  final T? row;
  final bool header;
  final bool sorted;
  final bool sortAscending;
  final VoidCallback? onSort;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      alignment: column.alignment,
      padding: EdgeInsets.symmetric(
        horizontal: context.tokens.spacing.md,
        vertical: context.tokens.spacing.xs,
      ),
      child: header
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(column.label, style: context.tokens.typography.labelMedium),
                if (onSort != null) ...[
                  SizedBox(width: context.tokens.spacing.xxs),
                  ExcludeSemantics(
                    child: Icon(
                      sorted
                          ? (sortAscending ? AppIcons.sortAscending : AppIcons.sortDescending)
                          : AppIcons.arrowsDownUp,
                      size: context.tokens.icons.sm,
                    ),
                  ),
                ],
              ],
            )
          : column.cellBuilder(context, row as T),
    );
    if (onSort == null) return child;
    return Semantics(
      button: true,
      label: sorted
          ? '${column.label}, ordenação ${sortAscending ? 'crescente' : 'decrescente'}'
          : '${column.label}, ordenar',
      child: InkWell(onTap: onSort, child: child),
    );
  }
}

@immutable
class AppDataTableAction {
  const AppDataTableAction({
    required this.label,
    required this.onPressed,
    this.separatedBefore = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool separatedBefore;
}

class AppDataTable<T> extends StatefulWidget {
  const AppDataTable({
    required this.columns,
    required this.rows,
    this.pageSize = 10,
    this.selectable = false,
    this.onSelectionChanged,
    this.filterValueBuilder,
    this.filterPlaceholder = 'Filtrar...',
    this.showColumnSelector = true,
    this.columnsLabel = 'Colunas',
    this.rowActionsBuilder,
    this.actionsLabel = 'Ações',
    this.empty,
    this.emptyLabel = 'Nenhum resultado.',
    super.key,
  }) : assert(pageSize > 0, 'Page size must be positive.');

  final List<AppTableColumn<T>> columns;
  final List<T> rows;
  final int pageSize;
  final bool selectable;
  final ValueChanged<Set<T>>? onSelectionChanged;
  final String Function(T row)? filterValueBuilder;
  final String filterPlaceholder;
  final bool showColumnSelector;
  final String columnsLabel;
  final List<AppDataTableAction> Function(T row)? rowActionsBuilder;
  final String actionsLabel;
  final Widget? empty;
  final String emptyLabel;

  @override
  State<AppDataTable<T>> createState() => _AppDataTableState<T>();
}

class _AppDataTableState<T> extends State<AppDataTable<T>> {
  int? _sortColumnIndex;
  var _sortAscending = true;
  var _page = 1;
  var _query = '';
  final _selection = <T>{};
  final _hiddenColumns = <int>{};

  @override
  void didUpdateWidget(covariant AppDataTable<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _selection.removeWhere((row) => !widget.rows.contains(row));
    _hiddenColumns.removeWhere((index) => index >= widget.columns.length);
    if (_sortColumnIndex != null && _sortColumnIndex! >= widget.columns.length) {
      _sortColumnIndex = null;
    }
  }

  List<T> get _filteredRows {
    final filterValueBuilder = widget.filterValueBuilder;
    final query = _query.trim().toLowerCase();
    if (filterValueBuilder == null || query.isEmpty) return [...widget.rows];
    return widget.rows.where((row) => filterValueBuilder(row).toLowerCase().contains(query)).toList(growable: false);
  }

  List<T> _sortRows(List<T> source) {
    final rows = [...source];
    final index = _sortColumnIndex;
    if (index == null) return rows;
    final compare = widget.columns[index].compare;
    if (compare == null) return rows;
    rows.sort((left, right) => _sortAscending ? compare(left, right) : compare(right, left));
    return rows;
  }

  void _sort(int index) {
    setState(() {
      if (_sortColumnIndex == index) {
        _sortAscending = !_sortAscending;
      } else {
        _sortColumnIndex = index;
        _sortAscending = true;
      }
      _page = 1;
    });
  }

  void _notifySelection() => widget.onSelectionChanged?.call(Set.unmodifiable(_selection));

  void _toggle(T row, bool? selected) {
    setState(() {
      if (selected ?? false) {
        _selection.add(row);
      } else {
        _selection.remove(row);
      }
    });
    _notifySelection();
  }

  void _toggleVisibleRows(List<T> rows, bool? selected) {
    setState(() {
      if (selected ?? false) {
        _selection.addAll(rows);
      } else {
        _selection.removeAll(rows);
      }
    });
    _notifySelection();
  }

  void _toggleColumn(int index) => setState(() {
    if (_hiddenColumns.contains(index)) {
      _hiddenColumns.remove(index);
    } else {
      _hiddenColumns.add(index);
    }
  });

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredRows;
    final rows = _sortRows(filtered);
    final totalPages = math.max(1, (rows.length / widget.pageSize).ceil());
    final safePage = _page.clamp(1, totalPages);
    final start = (safePage - 1) * widget.pageSize;
    final visibleRows = rows.skip(start).take(widget.pageSize).toList(growable: false);
    final visibleColumns = <_IndexedColumn<T>>[
      for (var index = 0; index < widget.columns.length; index++)
        if (!_hiddenColumns.contains(index)) _IndexedColumn(index, widget.columns[index]),
    ];
    final selectedVisibleCount = visibleRows.where(_selection.contains).length;
    final allVisibleSelected = visibleRows.isNotEmpty && selectedVisibleCount == visibleRows.length;
    final someVisibleSelected = selectedVisibleCount > 0 && !allVisibleSelected;
    final filteredSelectionCount = filtered.where(_selection.contains).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.filterValueBuilder != null || widget.showColumnSelector) ...[
          _DataTableToolbar<T>(
            columns: widget.columns,
            hiddenColumns: _hiddenColumns,
            filterPlaceholder: widget.filterPlaceholder,
            showFilter: widget.filterValueBuilder != null,
            showColumnSelector: widget.showColumnSelector,
            columnsLabel: widget.columnsLabel,
            onFilterChanged: (value) => setState(() {
              _query = value;
              _page = 1;
            }),
            onColumnSelected: _toggleColumn,
          ),
          SizedBox(height: context.tokens.spacing.md),
        ],
        Container(
          decoration: BoxDecoration(
            color: context.tokens.colors.card,
            border: Border.all(color: context.tokens.colors.border),
            borderRadius: context.tokens.borders.lg,
          ),
          clipBehavior: Clip.antiAlias,
          child: _DataTableGrid<T>(
            columns: visibleColumns,
            rows: visibleRows,
            selectable: widget.selectable,
            sortColumnIndex: _sortColumnIndex,
            sortAscending: _sortAscending,
            selectedRows: _selection,
            selectAllValue: allVisibleSelected ? true : (someVisibleSelected ? null : false),
            onSelectAll: (selected) => _toggleVisibleRows(visibleRows, selected),
            onSelectRow: _toggle,
            onSort: _sort,
            rowActionsBuilder: widget.rowActionsBuilder,
            actionsLabel: widget.actionsLabel,
            empty: widget.empty,
            emptyLabel: widget.emptyLabel,
          ),
        ),
        SizedBox(height: context.tokens.spacing.lg),
        _DataTableFooter(
          showSelectionCount: widget.selectable,
          selectionCount: filteredSelectionCount,
          rowCount: filtered.length,
          currentPage: safePage,
          totalPages: totalPages,
          onPageChanged: (page) => setState(() => _page = page),
        ),
      ],
    );
  }
}

class _IndexedColumn<T> {
  const _IndexedColumn(this.index, this.column);

  final int index;
  final AppTableColumn<T> column;
}

class _DataTableToolbar<T> extends StatelessWidget {
  const _DataTableToolbar({
    required this.columns,
    required this.hiddenColumns,
    required this.filterPlaceholder,
    required this.showFilter,
    required this.showColumnSelector,
    required this.columnsLabel,
    required this.onFilterChanged,
    required this.onColumnSelected,
  });

  final List<AppTableColumn<T>> columns;
  final Set<int> hiddenColumns;
  final String filterPlaceholder;
  final bool showFilter;
  final bool showColumnSelector;
  final String columnsLabel;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<int> onColumnSelected;

  @override
  Widget build(BuildContext context) {
    final filter = AppTextInput(
      placeholder: filterPlaceholder,
      semanticLabel: filterPlaceholder,
      onChanged: onFilterChanged,
    );
    final selector = _ColumnSelector<T>(
      columns: columns,
      hiddenColumns: hiddenColumns,
      label: columnsLabel,
      onSelected: onColumnSelected,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < context.tokens.layout.narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showFilter) filter,
              if (showFilter && showColumnSelector) SizedBox(height: context.tokens.spacing.sm),
              if (showColumnSelector) Align(alignment: Alignment.centerRight, child: selector),
            ],
          );
        }
        return Row(
          children: [
            if (showFilter)
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.tokens.sizes.dialogMedium),
                    child: filter,
                  ),
                ),
              )
            else
              const Spacer(),
            if (showColumnSelector) selector,
          ],
        );
      },
    );
  }
}

class _ColumnSelector<T> extends StatelessWidget {
  const _ColumnSelector({
    required this.columns,
    required this.hiddenColumns,
    required this.label,
    required this.onSelected,
  });

  final List<AppTableColumn<T>> columns;
  final Set<int> hiddenColumns;
  final String label;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => PopupMenuButton<int>(
    tooltip: label,
    color: context.tokens.colors.popover,
    surfaceTintColor: context.tokens.colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: context.tokens.borders.lg,
      side: BorderSide(color: context.tokens.colors.border),
    ),
    constraints: BoxConstraints(minWidth: context.tokens.sizes.navigationBrand),
    onSelected: onSelected,
    itemBuilder: (context) => [
      for (var index = 0; index < columns.length; index++)
        if (columns[index].hideable)
          CheckedPopupMenuItem<int>(
            value: index,
            checked: !hiddenColumns.contains(index),
            child: Text(
              columns[index].label,
              style: context.tokens.typography.bodySmall,
            ),
          ),
    ],
    child: Semantics(
      button: true,
      label: label,
      child: Container(
        height: context.tokens.layout.controlHeight,
        padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.md),
        decoration: BoxDecoration(
          color: context.tokens.colors.surface,
          border: Border.all(color: context.tokens.colors.border),
          borderRadius: context.tokens.borders.lg,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: context.tokens.typography.button),
            SizedBox(width: context.tokens.spacing.sm),
            ExcludeSemantics(
              child: Icon(AppIcons.expandMore, size: context.tokens.icons.sm),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DataTableGrid<T> extends StatelessWidget {
  const _DataTableGrid({
    required this.columns,
    required this.rows,
    required this.selectable,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.selectedRows,
    required this.selectAllValue,
    required this.onSelectAll,
    required this.onSelectRow,
    required this.onSort,
    required this.rowActionsBuilder,
    required this.actionsLabel,
    required this.empty,
    required this.emptyLabel,
  });

  final List<_IndexedColumn<T>> columns;
  final List<T> rows;
  final bool selectable;
  final int? sortColumnIndex;
  final bool sortAscending;
  final Set<T> selectedRows;
  final bool? selectAllValue;
  final ValueChanged<bool?> onSelectAll;
  final void Function(T row, bool? selected) onSelectRow;
  final ValueChanged<int> onSort;
  final List<AppDataTableAction> Function(T row)? rowActionsBuilder;
  final String actionsLabel;
  final Widget? empty;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.hasBoundedWidth
          ? math.max(constraints.maxWidth, context.tokens.layout.toolbar)
          : context.tokens.layout.toolbar;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DataTableRow<T>(
                columns: columns,
                header: true,
                selectable: selectable,
                sortColumnIndex: sortColumnIndex,
                sortAscending: sortAscending,
                leading: selectable
                    ? AppCheckbox(
                        value: selectAllValue,
                        tristate: true,
                        semanticLabel: 'Selecionar todas as linhas da página',
                        onChanged: onSelectAll,
                      )
                    : null,
                onSort: onSort,
                showActions: rowActionsBuilder != null,
              ),
              if (rows.isEmpty)
                Container(
                  constraints: BoxConstraints(
                    minHeight: context.tokens.layout.controlHeight * 3,
                  ),
                  alignment: Alignment.center,
                  child: empty ?? Text(emptyLabel, style: context.tokens.typography.bodySmall),
                )
              else
                for (var index = 0; index < rows.length; index++)
                  _DataTableRow<T>(
                    columns: columns,
                    row: rows[index],
                    selectable: selectable,
                    selected: selectedRows.contains(rows[index]),
                    sortColumnIndex: sortColumnIndex,
                    sortAscending: sortAscending,
                    leading: selectable
                        ? AppCheckbox(
                            value: selectedRows.contains(rows[index]),
                            semanticLabel: 'Selecionar linha',
                            onChanged: (selected) => onSelectRow(rows[index], selected),
                          )
                        : null,
                    onSort: onSort,
                    actions: rowActionsBuilder?.call(rows[index]),
                    actionsLabel: actionsLabel,
                    showActions: rowActionsBuilder != null,
                    showBottomBorder: index < rows.length - 1,
                  ),
            ],
          ),
        ),
      );
    },
  );
}

class _DataTableRow<T> extends StatelessWidget {
  const _DataTableRow({
    required this.columns,
    required this.selectable,
    required this.sortColumnIndex,
    required this.sortAscending,
    required this.onSort,
    required this.showActions,
    this.row,
    this.header = false,
    this.selected = false,
    this.leading,
    this.actions,
    this.actionsLabel = 'Ações',
    this.showBottomBorder = true,
  });

  final List<_IndexedColumn<T>> columns;
  final T? row;
  final bool header;
  final bool selected;
  final bool selectable;
  final int? sortColumnIndex;
  final bool sortAscending;
  final Widget? leading;
  final ValueChanged<int> onSort;
  final List<AppDataTableAction>? actions;
  final String actionsLabel;
  final bool showActions;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(
      minHeight: context.tokens.layout.controlHeight + context.tokens.spacing.md,
    ),
    decoration: BoxDecoration(
      color: selected ? context.tokens.colors.surfaceSubtle : context.tokens.colors.card,
      border: showBottomBorder ? Border(bottom: BorderSide(color: context.tokens.colors.border)) : null,
    ),
    child: Row(
      children: [
        if (selectable)
          SizedBox(
            width: context.tokens.layout.tableActionsColumn,
            child: Center(child: leading),
          ),
        for (final indexedColumn in columns)
          Expanded(
            flex: indexedColumn.column.flex,
            child: _TableCell<T>(
              column: indexedColumn.column,
              row: row,
              header: header,
              sorted: sortColumnIndex == indexedColumn.index,
              sortAscending: sortAscending,
              onSort: header && indexedColumn.column.compare != null ? () => onSort(indexedColumn.index) : null,
            ),
          ),
        if (showActions)
          SizedBox(
            width: context.tokens.layout.tableActionsColumn,
            child: header || actions == null
                ? null
                : Center(
                    child: _RowActionsMenu(
                      label: actionsLabel,
                      actions: actions!,
                    ),
                  ),
          ),
      ],
    ),
  );
}

class _RowActionsMenu extends StatelessWidget {
  const _RowActionsMenu({required this.label, required this.actions});

  final String label;
  final List<AppDataTableAction> actions;

  @override
  Widget build(BuildContext context) => PopupMenuButton<int>(
    tooltip: label,
    color: context.tokens.colors.popover,
    surfaceTintColor: context.tokens.colors.transparent,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: context.tokens.borders.lg,
      side: BorderSide(color: context.tokens.colors.border),
    ),
    constraints: BoxConstraints(minWidth: context.tokens.sizes.navigationBrand),
    onSelected: (index) => actions[index].onPressed(),
    itemBuilder: (context) {
      final entries = <PopupMenuEntry<int>>[
        PopupMenuItem<int>(
          enabled: false,
          height: context.tokens.layout.controlHeight,
          child: Text(
            label,
            style: context.tokens.typography.labelSmall.copyWith(
              color: context.tokens.colors.onSurfaceMuted,
            ),
          ),
        ),
      ];
      for (var index = 0; index < actions.length; index++) {
        if (actions[index].separatedBefore) {
          entries.add(PopupMenuDivider(height: context.tokens.spacing.hairline));
        }
        entries.add(
          PopupMenuItem<int>(
            value: index,
            child: Text(actions[index].label, style: context.tokens.typography.bodySmall),
          ),
        );
      }
      return entries;
    },
    child: Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: context.tokens.layout.controlHeight,
        child: Icon(AppIcons.more, size: context.tokens.icons.sm),
      ),
    ),
  );
}

class _DataTableFooter extends StatelessWidget {
  const _DataTableFooter({
    required this.showSelectionCount,
    required this.selectionCount,
    required this.rowCount,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  final bool showSelectionCount;
  final int selectionCount;
  final int rowCount;
  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final count = showSelectionCount
          ? Text(
              '$selectionCount de $rowCount linha(s) selecionada(s).',
              style: context.tokens.typography.bodySmall.copyWith(
                color: context.tokens.colors.onSurfaceMuted,
              ),
            )
          : const SizedBox.shrink();
      final pagination = totalPages > 1
          ? AppPagination(
              currentPage: currentPage,
              totalPages: totalPages,
              onPageChanged: onPageChanged,
            )
          : const SizedBox.shrink();
      if (constraints.maxWidth < context.tokens.layout.narrow) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showSelectionCount) count,
            if (showSelectionCount && totalPages > 1) SizedBox(height: context.tokens.spacing.sm),
            if (totalPages > 1) Align(alignment: Alignment.centerRight, child: pagination),
          ],
        );
      }
      return Row(
        children: [
          if (showSelectionCount) Expanded(child: count) else const Spacer(),
          if (totalPages > 1) pagination,
        ],
      );
    },
  );
}
