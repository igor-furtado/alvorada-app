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
  static const _administrationBranchIndex = 2;

  final _shellController = AppShellController();
  var _lastPrimaryIndex = 0;

  void _select(int index) {
    _shellController.resetBreadcrumbs();
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
    setState(() => _lastPrimaryIndex = index);
  }

  void _openAdministration() {
    _shellController.resetBreadcrumbs();
    widget.navigationShell.goBranch(
      _administrationBranchIndex,
      initialLocation: widget.navigationShell.currentIndex == _administrationBranchIndex,
    );
  }

  @override
  void dispose() {
    _shellController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppShellScope(
    controller: _shellController,
    child: ValueListenableBuilder<List<AppShellBreadcrumb>?>(
      valueListenable: _shellController,
      builder: (context, breadcrumbs, child) => ResponsiveBuilder(
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
                      _HeaderBar(
                        breadcrumbs: breadcrumbs ?? _defaultBreadcrumbs(widget.navigationShell.currentIndex),
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

List<AppShellBreadcrumb> _defaultBreadcrumbs(int branchIndex) => [
  AppShellBreadcrumb(
    label: switch (branchIndex) {
      0 => AppMessages.navigationConcursos,
      1 => AppMessages.navigationDisciplines,
      _ => AppMessages.administration,
    },
  ),
];

@immutable
class _AppDestination {
  const _AppDestination({required this.label, required this.icon, required this.selectedIcon});

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _destinations = [
  _AppDestination(
    label: AppMessages.navigationConcursos,
    icon: AppIcons.concursos,
    selectedIcon: AppIcons.concursosActive,
  ),
  _AppDestination(
    label: AppMessages.navigationDisciplines,
    icon: AppIcons.bookText,
    selectedIcon: AppIcons.bookText,
  ),
];

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.breadcrumbs});

  final List<AppShellBreadcrumb> breadcrumbs;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: context.tokens.colors.surface,
      border: Border(bottom: BorderSide(color: context.tokens.colors.border)),
    ),
    child: SafeArea(
      bottom: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: context.tokens.layout.commandBarHeight),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.xl),
          child: Row(
            children: [
              Expanded(
                child: AppBreadcrumbs(
                  items: [
                    for (final item in breadcrumbs) AppBreadcrumbItem(label: item.label, route: item.route),
                  ],
                ),
              ),
              SizedBox(width: context.tokens.spacing.lg),
              const _ThemeToggle(),
            ],
          ),
        ),
      ),
    ),
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
      border: Border(right: BorderSide(color: context.tokens.colors.border)),
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

class _CompactNavigation extends StatelessWidget {
  const _CompactNavigation({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      border: Border(top: BorderSide(color: context.tokens.colors.border)),
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
