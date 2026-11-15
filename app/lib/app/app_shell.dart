import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../core/design_system/design_system.dart';
import 'app_brand.dart';
import 'app_theme_controller.dart';

/// Estrutura de navegação compartilhada pelas telas principais.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _select(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) => ResponsiveBuilder(
    builder: (context, windowClass) => FocusTraversalGroup(
      child: Scaffold(
        bottomNavigationBar: windowClass.isCompact
            ? _CompactNavigation(
                selectedIndex: navigationShell.currentIndex,
                onSelected: _select,
              )
            : null,
        body: Row(
          children: [
            if (!windowClass.isCompact)
              _IconRail(
                selectedIndex: navigationShell.currentIndex,
                onSelected: _select,
              ),
            Expanded(child: navigationShell),
          ],
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

class _IconRail extends StatelessWidget {
  const _IconRail({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations(context);
    return Container(
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
            for (var index = 0; index < destinations.length; index++)
              Padding(
                padding: EdgeInsets.only(bottom: context.tokens.spacing.xxs),
                child: Semantics(
                  selected: selectedIndex == index,
                  child: AppAccessibleIconButton(
                    key: ValueKey('shell-destination-$index'),
                    icon: selectedIndex == index ? destinations[index].selectedIcon : destinations[index].icon,
                    label: destinations[index].label,
                    selected: selectedIndex == index,
                    onPressed: () => onSelected(index),
                  ),
                ),
              ),
            const Spacer(),
            const AppDivider(margin: EdgeInsets.zero),
            Padding(
              padding: EdgeInsets.symmetric(vertical: context.tokens.spacing.md),
              child: const _ThemeModeButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactNavigation extends StatelessWidget {
  const _CompactNavigation({required this.selectedIndex, required this.onSelected});

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final destinations = _destinations(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.tokens.colors.surface,
        border: Border(top: BorderSide(color: context.tokens.colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              Expanded(
                child: NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: onSelected,
                  destinations: [
                    for (var index = 0; index < destinations.length; index++)
                      NavigationDestination(
                        key: ValueKey('shell-destination-$index'),
                        icon: Icon(destinations[index].icon),
                        selectedIcon: Container(
                          padding: EdgeInsets.all(context.tokens.spacing.sm),
                          decoration: BoxDecoration(
                            color: context.tokens.colors.surfaceSubtle,
                            borderRadius: context.tokens.borders.sm,
                          ),
                          child: Icon(destinations[index].selectedIcon),
                        ),
                        label: destinations[index].label,
                      ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.tokens.spacing.sm),
                child: const _ThemeModeButton(),
              ),
            ],
          ),
        ),
      ),
    );
  }
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

class _ThemeModeButton extends StatelessWidget {
  const _ThemeModeButton();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final dark = brightness == Brightness.dark;
    return AppAccessibleIconButton(
      key: const ValueKey('theme-toggle'),
      icon: dark ? AppIcons.sun : AppIcons.moon,
      label: dark ? context.l10n.useLightTheme : context.l10n.useDarkTheme,
      onPressed: () => AppThemeScope.of(context).toggle(brightness),
    );
  }
}

List<_AppDestination> _destinations(BuildContext context) => [
  _AppDestination(
    label: context.l10n.navigationConcursos,
    icon: AppIcons.concursos,
    selectedIcon: AppIcons.concursosActive,
  ),
  _AppDestination(
    label: context.l10n.navigationDisciplines,
    icon: AppIcons.bookText,
    selectedIcon: AppIcons.bookText,
  ),
];
