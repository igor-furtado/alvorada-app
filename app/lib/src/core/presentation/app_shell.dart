import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../brand/app_brand.dart';
import '../content/app_messages.dart';
import '../theme/app_theme.dart';
import '../theme/app_theme_mode.dart';
import '../ui/app_ui.dart';
import 'app_shell_controller.dart';

/// Estrutura de navegação compartilhada pelas telas principais.
class AppShell extends StatefulWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _commandController = TextEditingController();
  final _shellController = AppShellController();
  var _commandQuery = '';
  var _lastPrimaryIndex = 0;

  static const _administrationBranchIndex = 6;

  void _select(int index) {
    if (_commandQuery.isNotEmpty || _commandController.text.isNotEmpty) {
      _clearCommand();
    }
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
    _lastPrimaryIndex = index;
  }

  void _openAdministration() {
    if (_commandQuery.isNotEmpty || _commandController.text.isNotEmpty) {
      _clearCommand();
    }
    widget.navigationShell.goBranch(
      _administrationBranchIndex,
      initialLocation: widget.navigationShell.currentIndex == _administrationBranchIndex,
    );
  }

  void _submitCommand(String value) {
    if (widget.navigationShell.currentIndex == 3 && _shellController.value != null) return;
    final query = value.trim().toLowerCase();
    if (query.isEmpty) return;
    final index = _destinations.indexWhere(
      (destination) => destination.label.toLowerCase().contains(query),
    );
    if (index < 0) return;
    _select(index);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _changeCommand(String value) {
    setState(() => _commandQuery = value);
    if (widget.navigationShell.currentIndex == 3) {
      _shellController.value?.onChanged(value);
    }
  }

  void _clearCommand() {
    _commandController.clear();
    if (_commandQuery.isNotEmpty) {
      setState(() => _commandQuery = '');
    }
    _shellController.value?.onChanged('');
  }

  @override
  void dispose() {
    _commandController.dispose();
    _shellController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShellScope(
    controller: _shellController,
    child: ValueListenableBuilder<AppShellSearchConfig?>(
      valueListenable: _shellController,
      builder: (context, searchConfig, child) => ResponsiveBuilder(
        builder: (context, windowClass) => FocusTraversalGroup(
          child: Scaffold(
            bottomNavigationBar: windowClass.isCompact
                ? _CompactNavigation(
                    selectedIndex: widget.navigationShell.currentIndex < _destinations.length
                        ? widget.navigationShell.currentIndex
                        : _lastPrimaryIndex,
                    onSelected: _select,
                  )
                : null,
            body: Row(
              children: [
                if (!windowClass.isCompact)
                  _IconRail(
                    selectedIndex: widget.navigationShell.currentIndex,
                    onSelected: _select,
                    onOpenAdministration: _openAdministration,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      _CommandBar(
                        compact: windowClass.isCompact,
                        controller: _commandController,
                        query: _commandQuery,
                        searchConfig: widget.navigationShell.currentIndex == 3 ? searchConfig : null,
                        onChanged: _changeCommand,
                        onClear: _clearCommand,
                        onSubmitted: _submitCommand,
                      ),
                      Expanded(child: widget.navigationShell),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

@immutable
class _AppDestination {
  const _AppDestination({required this.label, required this.icon, required this.selectedIcon});

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _destinations = [
  _AppDestination(label: AppMessages.navigationToday, icon: AppIcons.today, selectedIcon: AppIcons.todayActive),
  _AppDestination(label: AppMessages.navigationWeek, icon: AppIcons.calendar, selectedIcon: AppIcons.calendarActive),
  _AppDestination(
    label: AppMessages.navigationContests,
    icon: AppIcons.contests,
    selectedIcon: AppIcons.contestsActive,
  ),
  _AppDestination(
    label: AppMessages.navigationDisciplines,
    icon: AppIcons.bookText,
    selectedIcon: AppIcons.bookText,
  ),
  _AppDestination(label: AppMessages.navigationReviews, icon: AppIcons.reviews, selectedIcon: AppIcons.reviewsActive),
  _AppDestination(
    label: AppMessages.navigationErrors,
    icon: AppIcons.errorNotebook,
    selectedIcon: AppIcons.errorNotebookActive,
  ),
];

class _IconRail extends StatelessWidget {
  const _IconRail({
    required this.selectedIndex,
    required this.onSelected,
    required this.onOpenAdministration,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onOpenAdministration;

  @override
  Widget build(BuildContext context) => Container(
    width: context.tokens.layout.iconRailWidth,
    decoration: BoxDecoration(
      color: context.tokens.colors.surface,
      border: Border(
        right: BorderSide(color: context.tokens.colors.border),
      ),
    ),
    child: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.lg),
            child: const _BrandMark(),
          ),
          const AppDivider(margin: EdgeInsets.zero),
          SizedBox(height: context.tokens.spacing.md),
          for (var index = 0; index < _destinations.length; index++)
            Padding(
              padding: EdgeInsets.only(bottom: context.tokens.spacing.xxs),
              child: Semantics(
                selected: selectedIndex == index,
                child: AppAccessibleIconButton(
                  key: ValueKey('shell-destination-$index'),
                  icon: selectedIndex == index ? _destinations[index].selectedIcon : _destinations[index].icon,
                  label: _destinations[index].label,
                  selected: selectedIndex == index,
                  onPressed: () => onSelected(index),
                ),
              ),
            ),
          const Spacer(),
          const AppDivider(margin: EdgeInsets.zero),
          Padding(
            padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.md),
            child: Semantics(
              selected: selectedIndex == _AppShellState._administrationBranchIndex,
              child: AppAccessibleIconButton(
                key: const ValueKey('shell-administration'),
                icon: AppIcons.settings,
                label: AppMessages.administration,
                selected: selectedIndex == _AppShellState._administrationBranchIndex,
                onPressed: onOpenAdministration,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _CommandBar extends StatelessWidget {
  const _CommandBar({
    required this.compact,
    required this.controller,
    required this.query,
    required this.searchConfig,
    required this.onChanged,
    required this.onClear,
    required this.onSubmitted,
  });

  final bool compact;
  final TextEditingController controller;
  final String query;
  final AppShellSearchConfig? searchConfig;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.tokens.colors.surface,
      border: Border(
        bottom: BorderSide(color: context.tokens.colors.border),
      ),
    ),
    child: SafeArea(
      bottom: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: context.tokens.layout.commandBarHeight),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.xl),
          child: compact
              ? Padding(
                  padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.sm),
                  child: Row(
                    children: [
                      Expanded(
                        child: _CommandSearch(
                          controller: controller,
                          query: query,
                          searchConfig: searchConfig,
                          onChanged: onChanged,
                          onClear: onClear,
                          onSubmitted: onSubmitted,
                        ),
                      ),
                      SizedBox(width: context.tokens.spacing.sm),
                      if (searchConfig?.actionIcon case final icon?) ...[
                        AppAccessibleIconButton(
                          key: const ValueKey('shell-search-action'),
                          icon: icon,
                          label: searchConfig?.actionLabel ?? AppMessages.update,
                          onPressed: searchConfig?.onAction,
                        ),
                        SizedBox(width: context.tokens.spacing.sm),
                      ],
                      const _ThemeToggle(),
                    ],
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: Align(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: context.tokens.layout.commandSearchWidth),
                          child: _CommandSearch(
                            controller: controller,
                            query: query,
                            searchConfig: searchConfig,
                            onChanged: onChanged,
                            onClear: onClear,
                            onSubmitted: onSubmitted,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.tokens.spacing.xxl),
                    if (searchConfig?.actionIcon case final icon?) ...[
                      AppAccessibleIconButton(
                        key: const ValueKey('shell-search-action'),
                        icon: icon,
                        label: searchConfig?.actionLabel ?? AppMessages.update,
                        onPressed: searchConfig?.onAction,
                      ),
                      SizedBox(width: context.tokens.spacing.sm),
                    ],
                    const _ThemeToggle(),
                  ],
                ),
        ),
      ),
    ),
  );
}

class _CommandSearch extends StatelessWidget {
  const _CommandSearch({
    required this.controller,
    required this.query,
    required this.searchConfig,
    required this.onChanged,
    required this.onClear,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String query;
  final AppShellSearchConfig? searchConfig;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) => AppSearchField(
    controller: controller,
    placeholder: searchConfig?.placeholder ?? AppMessages.navigationSearch,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
    onClear: query.isEmpty ? null : onClear,
  );
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AppAccessibleIconButton(
      key: const ValueKey('theme-toggle'),
      icon: dark ? AppIcons.sun : AppIcons.moon,
      label: dark ? AppMessages.useLightTheme : AppMessages.useDarkTheme,
      onPressed: () => AppThemeModeScope.of(context).toggle(Theme.of(context).brightness),
    );
  }
}

class _CompactNavigation extends StatelessWidget {
  const _CompactNavigation({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: context.tokens.colors.border),
      ),
    ),
    child: NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      destinations: [
        for (var index = 0; index < _destinations.length; index++)
          NavigationDestination(
            icon: Icon(_destinations[index].icon),
            selectedIcon: Container(
              padding: EdgeInsets.all(context.tokens.spacing.sm),
              decoration: BoxDecoration(
                color: context.tokens.colors.surfaceSubtle,
                borderRadius: context.tokens.borders.sm,
              ),
              child: Icon(_destinations[index].selectedIcon),
            ),
            label: _destinations[index].label,
          ),
      ],
    ),
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) => SvgPicture.asset(
    AppBrand.appIcon,
    width: context.tokens.spacing.xxxl,
    height: context.tokens.spacing.xxxl,
    semanticsLabel: AppBrand.productName,
  );
}
